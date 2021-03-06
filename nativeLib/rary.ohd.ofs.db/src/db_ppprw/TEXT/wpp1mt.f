C MEMBER WPP1MT
C  (from old member PPWPP1MT)
C-----------------------------------------------------------------------
C
       SUBROUTINE WPP1MT (TMPMAX,TMPMIN,IPTRMT,ISTAT)
C
C          SUBROUTINE:  WPP1MT
C
C    VERSION 1.1.0 6-27-83 IF IPTRMT GT 0 REUSE SLOT
C VERSION 1.0.1 4-14-83 CORRECT TO STORE IN TENTH OF A DEGREE
C             VERSION:  1.0.0
C
C                DATE:  12-9-82
C
C              AUTHOR:  SONJA R SIEGEL
C                       DATA SCIENCES INC
C                       8555 16TH ST, SILVER SPRING, MD 587-3700
C***********************************************************************
C
C          DESCRIPTION:
C
C    THIS ROUTINE WILL WRITE THE MEAN MONTHLY TEMPS FOR 1 STATION
C    TO THE RESERVED MMMT RECORDS IN THE PPPDB               *
C    IT WRITES 2*12 VALUES, TWO FOR EACH MONTH.  UNUSED SLOTS CREATED
C    WHEN STATIONS ARE DELETED, ARE REUSED.
C
C
C***********************************************************************
C
C          ARGUMENT LIST:
C
C         NAME    TYPE  I/O   DIM   DESCRIPTION
C
C       TMPMAX       R    I    12    MEAN MONTHLY MAXS, 1/MONTH
C       TMPMIN        R    I    12    MEAN MONTHLY MINS 1/MONTH
C       IPTRMT      I   I/O    1    SUBSCRIPT IN MMMT RECORD FOR THIS
C                                       STATION
C       ISTAT       I    O     1    STATUS, 0=OK, 1=SYSTEM ERROR
C                                             2=FILE IS FULL
C                                              3 IPTRMT TOO BIG
C***********************************************************************
C
C          COMMON:
C
      INCLUDE 'uio'
      INCLUDE 'udebug'
      INCLUDE 'pppcommon/ppdtdr'
      INCLUDE 'pppcommon/pppdta'
      INCLUDE 'pppcommon/ppunts'
C
C***********************************************************************
C
C          DIMENSION AND TYPE DECLARATIONS:
C
      DIMENSION TMPMAX(12),TMPMIN(12),ICNTL(16)
      INTEGER*2 WORK(32)
      INTEGER*2 NOMMMT
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/db_ppprw/RCS/wpp1mt.f,v $
     . $',                                                             '
     .$Id: wpp1mt.f,v 1.1 1995/09/17 18:45:19 dws Exp $
     . $' /
C    ===================================================================
C
C
C***********************************************************************
C
C          DATA:
C
      DATA LMMMT/4hMMMT/,NOMMMT/-9999/
C
C***********************************************************************
C
C
      IF (IPPTR.GT.0) WRITE(IOGDB,2000)
2000  FORMAT(' ENTERING SUBROUTINE WPP1MT')
      ISTAT=0
C
C COMPUTE 2 LRECLS SINCE USING I*2 FOR MMMTS
C
      LREC2=LRECPP*2
C
C GET MEAN MONTHLY TEMPS CONTROL RECORD
C
      IDXDAT=IPCKDT(LMMMT)
      ICREC=IPDTDR(3,IDXDAT)
C
C CHECK THAT MMMTS IS VALID IN THIS SYSTEM
C
      IF (IDXDAT.NE.0) GO TO 5
      IF (IPPDB.GT.0) WRITE(LPE,2005)
2005  FORMAT(' **NOTE** IN WPP1MT. MEAN MONTHLY TEMPS NOT DEFINED IN ',
     1  'THIS DATA BASE')
      ISTAT=3
      GO TO 999
5     LUFILE=KPPRMU(IPDTDR(2,IDXDAT))
C
      CALL UREADT(LUFILE,ICREC,ICNTL,ISTAT)
      IF (ISTAT.NE.0) GO TO 900
C
      IF (IPPDB.GT.0) WRITE(IOGDB,2002) ICNTL
2002  FORMAT(' SUB WPP1MT. MMMT CONTROL:',4I4,2X,A4,2X,11I4)
C
C SEE IF CAN ADD MMMTS
C
      IF (ICNTL(5).EQ.LMMMT) GO TO 10
      IF (IPPDB.GT.0) WRITE(LPE,2001) ICNTL
2001  FORMAT(' **ERROR** IN WPP1MT. INVALID CONTROL RECORD',4I4,2X,
     1 A4,2X,11A4)
      ISTAT=1
      GO TO 999
C
C SEE IF THERE ARE UNUSED SLOTS
C NUMBER OF STATIONS IS LESS THAN LAST USED SLOT
C
10    IF (IPTRMT.GT.0 .AND. IPTRMT.LE.ICNTL(9)) GO TO 30
      IF (IPTRMT.GT.ICNTL(9)) GO TO 910
      IF (ICNTL(7).LT.ICNTL(9)) GO TO 100
C
C NO EMPTY SLOTS, PUT IN NEXT AVAILABLE.  MAKE SURE NOT FULL
C
15    IF (ICNTL(9).LT.ICNTL(8)) GO TO 20
      ISTAT=2
      GO TO 999
C
20    IPTRMT=ICNTL(9)+1
      ICNTL(7)=ICNTL(7)+1
30    CONTINUE
      IREC=IUNRCD(IPTRMT,LREC2)+ICNTL(2)-1
      JSLOT=IPTRMT-(IREC-ICNTL(2))*LREC2
      GO TO 200
C
C FIND AN UNUSED SLOT BY LOOKING THRU FIRST RECORD
C
100   IREC=ICNTL(2)
      NREC=ICNTL(3)
      MN=LREC2
      LASTLP=ICNTL(9)-(NREC-1)*LREC2
C
C READ FIRST MONTHS RECORD, 1 LREC2 AT A TIME TO FIND EMPTY SLOT
C
      DO 120 I=1,NREC
             CALL UREADT(LUFILE,IREC,WORK,ISTAT)
        IF (ISTAT.NE.0) GO TO 900
        IF (I.EQ.NREC) MN=LASTLP
C
C LOOK FOR EMPTY SLOT
C
         DO 110 JSLOT=1,MN
                IF (WORK(JSLOT).EQ.NOMMMT) GO TO 160
110      CONTINUE
           IREC=IREC+1
120   CONTINUE
C
C NO EMPTY SLOT, COUNTERS ARE OFF, FIX THEM
C
      ICNTL(7)=ICNTL(9)
      GO TO 15
C
C FOUND ONE
C
160   IPTRMT=JSLOT+(I-1)*LREC2
      ICNTL(7)=ICNTL(7)+1
      IF (IPPDB.GT.0) WRITE(IOGDB,2006) IPTRMT
2006  FORMAT(' SUB WPP1MT, REUSING SLOT',I5,' FOR MMMTS')
C
C ENTER THE MEAN MONTHLY TEMPS
C
200   CONTINUE
C
C GET THE RECORD CONTAINING THIS SLOT
C
C
C LOOP ON 12 MONTHS
C
      DO 250  IMO=1,12
           CALL UREADT(LUFILE,IREC,WORK,ISTAT)
           IF (ISTAT.NE.0) GO TO 900
C
C ENTER THE MEAN MAX FOR THIS MONTH
C
           ROUND=0.5
           IF (TMPMAX(IMO).LT.0) ROUND=-ROUND
           WORK(JSLOT)=TMPMAX(IMO)*10.0+ROUND
           CALL UWRITT(LUFILE,IREC,WORK,ISTAT)
      IF (IPPDB.GT.0) WRITE(IOGDB,2009) IMO,IREC,WORK(JSLOT),TMPMAX(IMO)
           IF (ISTAT.NE.0) GO TO 900
           IREC=IREC+ICNTL(3)
           CALL UREADT(LUFILE,IREC,WORK,ISTAT)
           IF (ISTAT.NE.0) GO TO 900
C
C ENTER THE MEAN MIN FOR THIS MONTH
C
           ROUND=0.5
           IF (TMPMIN(IMO).LT.0) ROUND=-ROUND
           WORK(JSLOT)=TMPMIN(IMO)*10.0+ROUND
           CALL UWRITT(LUFILE,IREC,WORK,ISTAT)
           IF (ISTAT.NE.0) GO TO 900
      IF (IPPDB.GT.0) WRITE(IOGDB,2009) IMO,IREC,WORK(JSLOT),TMPMIN(IMO)
           IREC=IREC+ICNTL(3)
2009  FORMAT(' SUB WPP1MT. MONTH, RECORD:',2I6,' VALUES',I6,2X,F12.6)
250   CONTINUE
      IF (IPPDB.GT.0) WRITE(IOGDB,2008) IPTRMT,WORK(JSLOT)
2008  FORMAT(' SUB WPP1MT, MEAN MONTHLY TEMPS WRITTEN IPTRMT=',I5,
     1    ' LAST VALUE=',I6)
C
C UPDATE CONTROL RECORDS
C
      IF (ICNTL(9).LT.IPTRMT) ICNTL(9)=IPTRMT
      CALL UWRITT(LUFILE,ICREC,ICNTL,ISTAT)
      IF (ISTAT.EQ.0) GO TO 999
C
C READ/WRITE ERROR
C
900   IF (IPPDB.GT.0) WRITE(LPE,2003) LUFILE,ISTAT
2003  FORMAT(' **ERROR** IN WPP1MT. READING OR WRITING TO FILE',I4,
     1     ' ISTAT=',I5)
      GO TO 999
910   ISTAT=3
999   IF (IPPDB.GT.0.OR.IPPTR.GT.0) WRITE(IOGDB,2004) ISTAT
2004  FORMAT(' SUB WPP1MT COMPLETE, STATUS=',I5)
C
      RETURN
C
      END
