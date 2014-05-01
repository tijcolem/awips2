C MODULE WPD1S
C-----------------------------------------------------------------------
C
      SUBROUTINE WPD1S (ISTAID,IDTYPE,NTYPES,IDATYP,IUNITS,IFHOUR,
     *   LHOUR,LDATA,DATA,IWRITE,IREV,ISTAT)
C
C  THIS ROUTINE WRITES OBSERVED DATA FOR DATA TYPES OTHER THAN RRS,
C  MDR6 AND PPSR TO THE PPDB FOR ONE STATION AND UPDATES THE
C  STATISTICS.
C
C   ARGUMENT LIST:
C
C       NAME    TYPE  I/O   DIM   DESCRIPTION
C       ------  ----  ---   ---   -----------
C       ISTAID  A8/I   I     1    CHARACTER OR NUMERIC ID
C       IDTYPE   I     I     1    IDENTIFIER TYPE:
C                                   0=ISTAID IS CHARACTER
C                                   1=ISTAID IS INTEGER
C       NTYPES   I     I     1     NUMBER OF DATA TYPES
C       IDATYP   A4    I   NTYPES  DATA TYPES
C       IUNITS   A4    I   NTYPES  UNITS FOR EACH TYPE
C       IFHOUR   I     I     1     JULIAN HOUR OF FIRST DATA
C       LHOUR    I     I     1     JULIAN HOUR OF LAST DATA
C       LDATA    I     I     1     LENGTH OF DATA ARRAY
C       DATA     R     I   LDATA   DATA ALL DAYS FOR EACH TYPE
C       IWRITE   I     O   NTYPES  WRITE STATUS FOR EACH TYPE:
C                                    0=WRITTEN
C                                    1=INVALID TYPE
C                                    2=INVALID PERIOD
C                                    3=INVALID UNITS
C                                    4=INVALID REV FLAG
C                                    5=INVALID VALUE
C       IREV     I     I     1     REVISION FLAG:
C                                    0=NEW
C                                    1=REVISION
C       ISTAT      I     O     1    STATUS:
C                                    0=OK
C                                    1=IDENTIFIER NOT FOUND
C                                    2=ONE OR MORE TYPES NOT FOUND
C                                    3=ONE OR MORE PERIODS INVALID
C                                    4=SYSTEM ERROR
C                                    5=2 AND 3 COMBINATION
C                                    6=2 AND 4 COMBINATION
C                                    7=3 AND 4 COMBINATION
C                                    8=2,3 AND 4 COMBINATION
C                                    9=NOT VALID DATA TYPE
C                                    10=SYSTEM ERROR
C                                    11=NOT ENOUGH DATA VALUES FOR TIME
C                                       INTERVAL DEFINED IN PPDB
C                                    12=DATA EXISTS FOR ALL OR PART 
C                                       OF THE TIME PERIOD BEING WRITTEN
C                                    13=DATA OUTSIDE OF ALLOWABLE RANGE
C                                    20+=INVALID REVISION FLAG
C                                    30+=INVALID VALUE
C                                    100+=SOME DATA TOO EARLY
C
      PARAMETER (LSIBUF=128)
      INTEGER*2 ISIRAY(LSIBUF)
      INTEGER*2 ITMPTY(2)
      INTEGER*2 IDTREC(32)
      INTEGER*2 ICVTYP(2,4)
      INTEGER*2 LVR,ITYPE
      INTEGER*2 IOLDTA,LPP
      LOGICAL INCPST
      DIMENSION DATA(1),ISTAID(1),IUNITS(1),IDATYP(1),IWRITE(1)
      EQUIVALENCE (LPP,ICVTYP(1,1))
      DIMENSION RMAGNI(2,7)
C
      INCLUDE 'uio'
      INCLUDE 'udebug'
      INCLUDE 'hclcommon/hdflts'
      INCLUDE 'pdbcommon/pdunts'
      INCLUDE 'pdbcommon/pddtdr'
      INCLUDE 'pdbcommon/pdsifc'
      INCLUDE 'pdbcommon/pdincs'
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/db_pdbrw/RCS/wpd1s.f,v $
     . $',                                                             '
     .$Id: wpd1s.f,v 1.3 2000/07/21 18:33:26 page Exp $
     . $' /
C    ===================================================================
C
      DATA LPPSR/4HPPSR/,LMDR6/4HMDR6/,LTF24/4HTF24/,LTFMX/4HTFMX/
      DATA LTFMN/4HTFMN/
      DATA LPP24/4HPP24/
      DATA ICVTYP/2HPP,1,2HTM,2,2HEA,2,2HTA,2/
      DATA RMAGNI/4HIN  ,100.0,4HDEGF,10.0,4HDEGF,10.0,4HMI/H,10.0,
     *            4HPCTD,10.0,4HPCT ,1.0,4HLY  ,1.0/
      DATA LVR/2HVR/
C
C
      IF (IPDTR.GT.0) WRITE (IOGDB,*) 'ENTER WPD1S'
C
      CALL UMEMST (0,IWRITE,NTYPES)
      LRCPD2=LRCPDD*2
C
C  SET SWITCH TO INDICATE IF POSTING OF INCREMENTAL PRECIP BASED ON
C   PARTIAL DAY PP24 VALUES HAS BEEN DONE
C
      RUNINC=.FALSE.
C
C  COPY INPUT ARGUMENTS TO TEMPORARY VARIABLES TO ALLOW USE OF
C  EXISTING CODING TO POST INCREMENTAL VALUES COMPUTED FROM PARTIAL
C  DAY PP24 TOTALS (SHEF TYPE PPP)
C
      NTYPEX=NTYPES
      LDATX=LDATA
      IFHRX=IFHOUR
      LHRX=LHOUR
      CALL UMEMOV (IDATYP,IDTYPX,1)
      CALL UMEMOV (IUNITS,IUNITX,1)
      CALL UMEMOV (DATA,DATX,1)
C
C  SET VALUES FOR POSTING INCREMENTAL VALUES
      NINCP=0
      INCPST=.FALSE.
      CALL UMEMST (0,INCSTA,2)
C
C  CHECK IF STATION EXISTS
      IFIND=0
      IF (IDTYPE.EQ.0) THEN
         CALL PDFNDR (ISTAID,LSIBUF,IFIND,ISIREC,ISIRAY,IFREE,ISTAT)
         IF (ISTAT.NE.0) GO TO 280
         ENDIF
      IF (IDTYPE.EQ.1) THEN
         CALL PDFNDI (ISTAID,LSIBUF,IFIND,ISIREC,ISIRAY,IFREE,ISTAT)
         IF (ISTAT.NE.0) GO TO 280
         ENDIF
      IF (IFIND.EQ.0) THEN
         ISTAT=1
         GO TO 310
         ENDIF
C
C  CHECK NUMBER OF DATA TYPES TO BE PROCESSED
10    IF (NTYPES.LE.0) THEN
         ISTAT=2
         GO TO 310
         ENDIF
C
C  INCREASE COUNTER FOR NUMBER OF INCREMENTAL POSTINGS DONE
      IF (INCPST) NINCP=NINCP+1
C
C  COMPUTE JULIAN DAYS FROM JULIAN HOURS
      IFHPDB=IFHOUR-NHOPDB
      IFDAY=((IFHPDB+23)/24)+1
      LDAY=((LHOUR-NHOPDB+23)/24)+1
      IF (IPDDB.GT.0) WRITE (IOGDB,330) NHOPDB,IFDAY,LDAY
C
C  CHECK IF FILES ARE EMPTY
      DO 20 I=1,NMDTYP
         IF (IDDTDR(8,I).NE.0.OR.IDDTDR(9,I).NE.0) GO TO 30
20       CONTINUE
C
C  FILES ARE EMPTY SO MUST INITIALIZE FIRST AND LAST DAY
      CALL PDDAY1 (IFDAY)
      IF (IPDDB.GT.0) WRITE (IOGDB,*) 'IFDAY=',IFDAY
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  JDATA IS THE SUBSCRIPT OF THE INCOMING DATA
30    JDATA=1
      NDAYS=LDAY-IFDAY+1
C
C  PROCESS EACH TYPE
C
      DO 250 IT=1,NTYPES
C     MAKE SURE THIS IS A DAILY TYPE THAT CAN BE WRITTEN BY THIS ROUTINE
         IF (IDATYP(IT).EQ.LMDR6.OR.IDATYP(IT).EQ.LPPSR.OR.
     *      IDATYP(IT).EQ.LTF24.OR.IDATYP(IT).EQ.LTFMN.OR.
     *      IDATYP(IT).EQ.LTFMX) GO TO 60
         ITX=IPDCKD(IDATYP(IT))
         ITXNEW=0
         IF (ITX.EQ.0) GO TO 60
C     NDTWDS IS NUMBER OF WORDS IN ONE DAY IN DATA BASE
C     NINWDS IS TOTAL NUMBER OF INPUT WORDS IN DATA ARRAY FOR TYPE
         NDTWDS=IDDTDR(6,ITX)
         NDTSAV=NDTWDS
         NINWDS=NDTWDS*NDAYS
C     IFIXDT IS THE AMOUNT TO SKIP FOR EACH DATA WORD IN INPUT
         IFIXDT=1
C     IPOINT IS POINTER TO DATA IN PPDB
         IPOINT=IPDFDT(ISIRAY,IDATYP(IT))
         IF (IPOINT.NE.0) GO TO 70
C     INPUT TYPE IS NOT IN RECORD - CHECK IF A WRITE ONLY TYPE
C     ITXNEW IS THE SUBSCRIPT OF THE ACTUAL DATA TYPE IN DIRECTORY
         ITXNEW=IPDCDW(IDATYP(IT))
         IF (ITXNEW.EQ.0) GO TO 60
         IF (IPDDB.GT.0) WRITE (IOGDB,340) (IDDTDR(K,ITXNEW),K=1,6)
C     FIND THE OFFICIAL READ TYPE IN THE DATA RECORD
         ITXPDB=ITXNEW
         CALL UMEMOV(IDDTDR(2,ITX),JDDTDR,1)
         IPOINT=IPDFDT(ISIRAY,JDDTDR)
         IF (IPOINT.NE.0) GO TO 70
C     STILL NOT FOUND - CHECK IF IT IS A SMALLER TIME INTERVAL
         IF (IDDTDR(3,ITX).NE.LVR) GO TO 60
C     CHECK FOR THE SAME FIRST LETTERS IN STATION INFORMATION REC
         CALL UMEMOV (IDATYP(IT),ITMPTY,1)
         N=ISIRAY(10)
         J=11
         DO 40 I=1,N
            IF (ISIRAY(J).EQ.ITMPTY(1)) GO TO 50
            J=J+3
40          CONTINUE
         GO TO 60
C     FOUND TYPE - CHECK IF DELTA T IS BIGGER
50       IFIXDT=0
         ITXPDB=IPDCDW(ISIRAY(J))
         IFIXDT=IDDTDR(5,ITXPDB)/IDDTDR(5,ITXNEW)
         IPOINT=ISIRAY(J+2)
         IF (IFIXDT.NE.0) GO TO 80
C     DATA TYPE NOT FOUND
60       IWRITE(IT)=1
         IF (NDTWDS.EQ.-1.OR.ITX.EQ.0) GO TO 290
         GO TO 120
70       IF (IPDDB.GT.0) WRITE (IOGDB,350) ITX,(IDDTDR(K,ITX),K=1,24)
C     ADJUST POINTERS IN CASE WHERE THIS IS A WRITE ONLY TYPE AND NOT
C     WRITING TO ALL PPDB WORDS (FOR TYPES TN24, EX24 AND EA24)
         IF (ITXNEW.EQ.0) GO TO 80
C     MOVE IPOINT TO CORRECT WORD IN RECORD
         IPOINT=IPOINT+IDDTDR(5,ITXNEW)
C     RESET NUMBER OF DATA WORDS IN PPDB
         NDTWDS=IDDTDR(6,ITXNEW)
         NDTSAV=NDTWDS
C     COMPUTE NUMBER OF INPUT WORDS
         NINWDS=NDTWDS*NDAYS
C     CHECK FOR UNEVEN DAY WHICH IS ALLOWED FOR TAVR AND PPVR
C     RESET IFDAY IN CASE IT WAS CHANGED IN PREVIOUS PASS
C     PP24 CAN HAVE AN OFFSET ON THE ENDING HR AND IF IFHOUR=ENDING HR
80       IHOFST=MOD(IFHPDB,24)
         IHREND=MOD(LHOUR-NHOPDB,24)
         IFDAY=((IFHPDB+23)/24)+1
         IF (IDDTDR(3,ITX).EQ.LVR) GO TO 90
            N1DAY=NDTWDS
            IF (IHOFST.EQ.0) GO TO 100
            IF (IDDTDR(2,ITX).NE.LPP) GO TO 110
            IF (IFHOUR.NE.LHOUR) GO TO 110
            IHOFST=0
            GO TO 100
C     COMPUTE HOUR OFFSET FOR IFHOUR
90       IF (IHREND.NE.0) LDAY=LDAY+1
C     COMPUTE NUMBER OF DATA WORDS IN PPDB RECORD
         IF (ITXNEW.EQ.0) ITXNEW=IPDCDW(IDATYP(IT))
         NDTWDS=24/(IFIXDT*IDDTDR(5,ITXNEW))
         NDTSAV=IDDTDR(6,ITXNEW)
         NHR=LHOUR-IFHOUR
         NINWDS=NHR/IDDTDR(5,ITXNEW)+1
         IF (IPDDB.GT.0) WRITE (IOGDB,370) IDATYP(IT),IHOFST,IFDAY,
     *      NDTWDS,NINWDS
100      CALL UMEMOV (IDDTDR(8,ITX),IEDATE,1)
         CALL UMEMOV (IDDTDR(11,ITX),ILDATE,1)
         IF (IPDDB.GT.0) WRITE (IOGDB,360) IEDATE,ILDATE
C     CHECK IF FIRST DATE TOO EARLY OR TOO LATE FOR CONTENTS OF PPDB
         IF (IFDAY.GE.IEDATE.AND.IFDAY.LE.ILDATE+1) GO TO 140
         IF (LDAY.GE.IEDATE.AND.IFDAY.LE.ILDATE+1) GO TO 130
C     INVALID PERIOD
110      IWRITE(IT)=2
120      JDATA=JDATA+NINWDS
         IF (ITX.EQ.0) GO TO 290
         ISTAT=0
         GO TO 250
C     ADJUST BEGINNING OF DATA TO MATCH FILE
130      IN=1
         IF (IDDTDR(2,ITX).EQ.ICVTYP(1,2)) IN=2
         IFHNEW=IFHPDB
         CALL PDADJB (IFHNEW,NDTSAV,IEDATE,JDATA,NINWDS,IFDAY,IHOFST,IN)
         IWRITE(IT)=6
C      SET UP WORDS AND RECORDS FOR WRITE
140      CALL PDVALS (ITX,NREC1D,NRECAL,LSTREC)
         IFILE=IDDTDR(4,ITX)
C     CHECK IF NEED TO ADD A NEW DAY
         IF (IFDAY.LE.ILDATE) GO TO 150
C        CREATE A NEW FIRST DAY
            CALL PDNEWD (IFDAY,ISTAT)
            IF (ISTAT.NE.0) GO TO 280
            CALL UMEMOV (IDDTDR(8,ITX),IEDATE,1)
C        RECHECK FIRST DAY
            IF (IFDAY.GE.IEDATE) GO TO 150
            GO TO 110
C     READY TO WRITE THE DATA
150      IF (IPDDB.GT.0) WRITE (IOGDB,350) ITX,(IDDTDR(K,ITX),K=1,24)
         IREC=IDDTDR(10,ITX)
C     SET UP FOR UNITS CONVERSION BY GETTING THE MAGNITUDE FOR EACH TYPE
         DO 160 I=1,4
            IF (IDDTDR(2,ITX).EQ.ICVTYP(1,I)) GO TO 170
160         CONTINUE
         WRITE (LP,380) IDDTDR(2,ITX)
         IWRITE(IT)=1
         GO TO 120
C     SET POINTER FOR MAGNITUDE
170      ISTSAV=ICVTYP(2,I)
C     IF EA24, RESET UNITS POINTER
         IF (I.EQ.3.AND.ITXNEW.LT.1) GO TO 60
         IF (I.EQ.3) ISTSAV=ISTSAV+IDDTDR(5,ITXNEW)
         CALL UDUCNV (IUNITS(IT),RMAGNI(1,ISTSAV),2,1,FACTOR,TFACT,
     *      ISTAT)
          IF (ISTAT.NE.0) IWRITE(IT)=3
          IF (ISTAT.NE.0) GO TO 120
C     CHECK IF WE ARE WRITING THE FIRST DAY
         NUMDAY=IFDAY
         JEND=JDATA+NINWDS-1
C     CHECK FOR ENOUGH DATA
         IF (JEND.GT.LDATA) GO TO 300
         IF (IFDAY.EQ.IEDATE) GO TO 180
         N=IFDAY-IEDATE
         IREC=IREC+(N*NREC1D)
         IF (IREC.LE.LSTREC) GO TO 180
C     RECOMPUTE RECORD NUMBER BECAUSE OF WRAP-AROUND
         N=IREC-LSTREC
         IREC=IDDTDR(15,ITX)+(N-NREC1D)
C     COMPUTE WHICH LOGICAL RECORD HAS THIS STATION
180      IRCOFS=IUNRCD(IPOINT,LRCPD2)
         IDXSAV=IPOINT-(IRCOFS-1)*LRCPD2
         IDX=IDXSAV
C     RECOMPUTE INDEX TO IDTREC IF LESS THAN 24 HOUR DATA
         IF (IPDDB.GT.0) WRITE (IOGDB,390) IHOFST
         IF (IDDTDR(3,ITX).NE.LVR) GO TO 200
C     SET TIME INTERVAL - IF DATA IS SAME AS PPDB, USE IT, ELSE
C     TIME INTERVAL OF FILE TO CHECK HOUR OFFSET
         IDT=24/NDTWDS
C     CHECK IF HOUR IS EXACT
      IF (IHOFST.EQ.0) J=24/IDT
      IF (IHOFST.GT.0) J=IUNRCD(IHOFST,IDT)
C     ADJUST IDX (OFFSET IN FILE IN STATION), IF IHOFST=0 IT IS END
C     OF HYDROLOGIC DAY (LAST POSITION), ELSE IT IS ROUNDED UP
         IDX=IDX+J-1
         N1DAY=NDTWDS-J+1
C     CORRECT IFHOUR IS NOT EVEN WITH PPDB
         IF ((IHOFST.EQ.0.OR.IHOFST.EQ.IDT*J).AND.IFIXDT.EQ.1)
     *      GO TO 200
         IF ((IHOFST.EQ.0.OR.IHOFST.EQ.IDT*J).AND.ISTSAV.NE.1)
     *      GO TO 200
         IF (IFIXDT.EQ.1) GO TO 110
C     CHECK FOR CORRECT HOUR FOR PRECIP OR ADJUST FOR TEMP
C     THIS IS FOR THE SUBSCRIPT OF THE INPUT DATA (NOW IHOFST IS OFFSET
C     IN DATA) IF TEMP, PICK OFF, IF PRECIP, MUST ADD THEM UP
C     CHANGE IDT TO DELTA T OF DATA. IHOFST MUST BE MULTIPLE OF IDT
         IHOFST=IHOFST-IDT*(J-1)
         IDT=IDDTDR(5,ITXNEW)
         IF (MOD(IHOFST,IDT).NE.0) GO TO 110
         IF (ISTSAV.NE.1) GO TO 190
C     THIS IS PRECIP - IHOFST MUST BE FIRST HOUR OF DAY (TIME INTERVAL)
         IF (IHOFST.NE.IDT) GO TO 110
         GO TO 200
190      JIX=IFIXDT-IHOFST
         IF (IFIXDT.EQ.2) JIX=1
         JDATA=JDATA+JIX
C     CHECK IF ENOUGH DATA TO GET CORRECT TIME
         IF (JDATA.GT.JEND) GO TO 300
         IF (IPDDB.GT.0) WRITE (IOGDB,410) IHOFST,JIX,JDATA
200      IRCRED=IREC+IRCOFS-1
C     MAKE SURE NOT PAST RECORD END
         IF (IDX.LE.LRCPD2) GO TO 210
         IDX=IDX-LRCPD2
         IRCRED=IRCRED+1
210      IF (IPDDB.GT.0)
     *      WRITE (IOGDB,400) IREC,IRCOFS,IPOINT,IRCRED,IDX,JDATA
         CALL UREADT (KPDDDF(IFILE),IRCRED,IDTREC,ISTAT)
         IF (ISTAT.NE.0) GO TO 280
C     MOVE IN THE DATA - CONVERT UNITS FIRST IF NECESSARY
         I=1
C     SAVE OLD VALUE FOR PP24 STATS (AND FOR POSSIBLE INCREMENTAL PRECIP
C     CALCULATIONS)
         IOLDTA=IDTREC(IDX)
C     GET TYPE FOR RANGE CHECK - MUST BE A WRITE TYPE
         ITYPE=IDDTDR(2,ITX)
         IF (ITXNEW.NE.0) ITYPE=IDDTDR(2,ITXNEW)
         IF (IDATYP(IT).NE.LPP24) GO TO 220
C     DETERMINE IF THE PP24 VALUE IS A PARTIAL DAY TOTAL AND IF AN
C     INCREMENTAL 3 OR 6 HOUR VALUE CAN BE COMPUTED FROM THE OLD
C     PARTIAL DAY TOTAL AND THE NEW PARTIAL DAY TOTAL
C     EVEN IF A SERIES OF PP24 VALUES ARE PASSED TO WPD1S, ONLY THE
C     FIRST VALUE CAN BE USED FOR INCREMENTAL CALCULATIONS.
         IF (NUMDAY.EQ.IFDAY)
     *      CALL PDINCP (ISIRAY,IOLDTA,MOD(IFHPDB,24),DATA(JDATA))
C     ENCODE THE 24 HR PRECIP AND PLACE INTO PROPER WORD IN RECORD
         IHR=0
         IF (NUMDAY.EQ.LDAY) IHR=IHREND
         CALL PDCVPP (DATA(JDATA),FACTOR,IREV,IHR,IDTREC(IDX),JDATA,
     *      ISTAID,ISTA)
         IF (ISTA.EQ.30) IWRITE(IT)=5
         IF (ISTA.EQ.20) IWRITE(IT)=4
         IF (ISTA.NE.0) GO TO 240
         GO TO 230
C     WRITE THE NON-24 HOUR PRECIP VALUE
220      CALL PDCVDD (DATA,IFIXDT,RMAGNI(2,ISTSAV),IUNITS(IT),
     *      RMAGNI(1,ISTSAV),JDATA,JEND,IDTREC(IDX),IREV,ITYPE,ISTAID,
     *      ISTA)
         CALL UMEMOV (IDDTDR(8,ITX),IXEDTE,1)
         CALL UMEMOV (IDDTDR(11,ITX),IXLDTE,1)
         IF (IPDDB.GT.0) WRITE (IOGDB,420) ITX,IXEDTE,IXLDTE
C     SET STATUS CODES FOR INCREMENTAL PRECIP POSTING
         IF (INCPST.AND.ISTA.NE.0) INCSTA(NINCP)=1
         IF (ISTA.EQ.30) IWRITE(IT)=5
         IF (ISTA.EQ.20) IWRITE(IT)=4
         IF (I.EQ.N1DAY) GO TO 230
         IF (JDATA.GT.JEND) GO TO 230
         CALL PGTNXP (ITX,IDX,IDTREC,IRCRED,ISTAT)
         IF (ISTAT.NE.0) GO TO 280
         I=I+1
         GO TO 220
C    WRITE RECORD
230      CALL UWRITT (KPDDDF(IFILE),IRCRED,IDTREC,ISTAT)
         IF (ISTAT.NE.0) GO TO 280
         IF (IOLDTA.NE.IDTREC(IDX).AND.IDATYP(IT).EQ.LPP24)
     *      CALL PDSTPP (NUMDAY,IDTREC(IDX),IOLDTA,ISIREC,IDX,IRCOFS,
     *         ISIRAY)
240      IF (JDATA.GT.JEND) GO TO 250
         IF (NUMDAY.EQ.LDAY) GO TO 250
         NUMDAY=NUMDAY+1
         IF (NUMDAY.GT.ILDATE) THEN
            CALL PDNEWD (NUMDAY,ISTAT)
            IF (ISTAT.NE.0) GO TO 280
            ENDIF
         IREC=IREC+NREC1D
         IF (IREC.GT.LSTREC) IREC=IDDTDR(15,ITX)
         IDX=IDXSAV
         N1DAY=NDTWDS
         GO TO 200
250      CONTINUE
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  CHECK TO CHECK IF ANY INCREMENTAL VALUES MUST BE POSTED.
C  THE SAME CODE JUST USED FOR POSTING IS USED TO POST THE
C  INCREMENTAL VALUES.  CERTAIN ARGUMENTS IS RESET TO LET THIS
C  HAPPEN.  ORIGINAL ARGS HAVE BEEN SAVED INTO TEMPORARY VARIABLES FOR
C  LATER RESTORATION.  THE REVISION FLAG IS NOT RESET SO THAT THE RULES
C  FOR REVISION IN PLACE AT THE TIME OF THE FIRST PASS STILL APPLY.
C
C  IF MORE THAN ONE INCREMENTAL VALUE IS TO BE POSTED, THEY ARE DONE
C  ONE AT A TIME
C
      IF (.NOT.INCPST) CALL UMEMOV (IWRITE,IWRITX,1)
      IF (.NOT.RUNINC) GO TO 260
      IF (NINCP .GE. NDATIN) GO TO 260
C
      IFHOUR=IFHRX-INCINT*(NINCP)
      LHOUR=IFHOUR
      NTYPES=1
      LDATA=1
      IDATYP(1)=INCTYP
      DATA(1)=DATINC
      CALL PDFUNT (INCTYP,0,IUNITS(1))
      INCPST=.TRUE.
      GO TO 10
C
C  FINISHED WITH ALL POSTING NOW.  IF INCREMENTAL PRECIP VALUES
C  WERE POSTED THEN RESET THE ORIGINAL ARGUMENTS FROM THEIR
C  TEMPORARY LOCATIONS.  IF NO INC. POSTING DONE, NO NEED TO
C  RESTORE
C
260   IF (.NOT.INCPST) GO TO 270
C
      NTYPES=NTYPEX
      LDATA=LDATX
      IFHOUR=IFHRX
      LHOUR=LHRX
      CALL UMEMOV (IDTYPX,IDATYP,1)
      CALL UMEMOV (IUNITX,IUNITS,1)
      CALL UMEMOV (DATX,DATA,1)
      CALL UMEMOV (IWRITX,IWRITE,1)
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  CHECK STATUS CODES
C
270   CALL PDWRST (IWRITE,NTYPES,ISTAT)
      GO TO 310
C
C  READ/WRITE ERROR
280   ISTAT=10
      GO TO 310
C
C  INVALID DATA TYPE
290   ISTAT=9
C
C  IF ONLY ONE TYPE, SET TO TYPE NOT FOUND IN STATION
      IF (NTYPES.EQ.1) ISTAT=2
      GO TO 310
C
C  NOT ENOUGH DATA VALUES
300   ISTAT=11
C
310   IF (IPDDB.GT.0) WRITE (IOGDB,430) (ISIRAY(I),I=2,5)
C
      IF (IPDTR.GT.0) WRITE (IOGDB,*) 'EXIT WPD1S - ISTAT=',ISTAT
C
      RETURN
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
330   FORMAT (' NHOPDB=',I5,3X,
     *   'IFDAY=',I8,3X,
     *   'LDAY=',I8)
340   FORMAT (' IDDTDR(1...6,ITXNEW)=',I3,2A2,3I5)
350   FORMAT (' IDDTDR(1...24,',I2,')=',I3,2A2,21I5)
360   FORMAT (' IEDATE=',I8,3X,'ILDATE=',I8)
370   FORMAT (' IDATYP(II)=',A4,3X,
     *   'IHOFST=',I5,3X,
     *   'IFDAY=',I5,3X,
     *   'NDTWDS=',I5,3X,
     *   'NINWDS=',I5)
380   FORMAT ('0**ERROR** IN WPD1S - CANNOT FIND TYPE ',A2,
     *   ' IN CONVERSION TABLE.')
390   FORMAT (' IHOFST=',I4)
400   FORMAT (' IREC=',I6,3X,
     *   'IRCOFS=',I6,3X,
     *   'IPOINT=',I6,3X,
     *   'IRCRED=',I6,3X,
     *   'IDX=',I6,3X,
     *   'JDATA=',I6)
410   FORMAT (' IHOFST=',I6,3X,
     *   'JIX=',I6,3X,
     *   'JDATA=',I6)
420   FORMAT (' IT=',I2,3X,'IXEDTE=',I6,3X,'IXLDTE=',I6)
430   FORMAT (' ISIRAY=',4A2)
C
      END
