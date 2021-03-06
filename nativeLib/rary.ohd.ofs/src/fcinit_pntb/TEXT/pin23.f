C MODULE PIN23
C-----------------------------------------------------------------------
C
      SUBROUTINE PIN23 (PO,LEFTP,IUSEP,CO,LEFTC,IUSEC)
C
C  THIS SUBROUTINE IS THE INPUT SUBROUTINE FOR THE STAGE-Q OPERATION
C
C   CONTENTS OF THE P ARRAY:
C
C    GENERAL INFORMATION
C
C    POSITION      NAME      DESCRIPTION
C       1          IVERS     VERSION NUMBER
C      2-6         PNTNAM    20-CHAR NAME OF GAGING STATION OR FORECAST
C                            POINT
C       7          ICNVRT    CONVERSION INDICATOR
C                            =1, STAGE TO DISCHARGE
C                            =2, DISCHARGE TO STAGE
C                            (DEFAULT IS 1)
C      8-9         STGID     8-CHAR STAGE T.S. IDENTIFIER
C       10         STGTYP    4-CHAR STAGE T.S. DATA TYPE CODE
C       11         IDTSTG    TIME INTERVAL IN HOURS FOR STAGE T.S.
C     12-13        QDATID    8-CHAR DISCHARGE T.S. IDENTIFIER
C       14         QTYPE     4-CHAR DISCHARGE T.S. DATA TYPE CODE
C       15         IDTQ      TIME INTERVAL IN HOURS FOR DISCHARGE T.S.
C     16-17        RCID      8-CHAR RATING CURVE IDENTIFIER
C       18         ICO       DEFAULT CARRYOVER INDICATOR
C                            =0, DEFAULT CARRYOVER (ALL ZEROES) USED
C                            =1, INITIAL CARRYOVER READ IN
C
C---------------------------------------------------------------------
C
C   CONTENTS OF THE C ARRAY -
C
C    GENERAL INFORMATION
C
C    POSITION      NAME      DESCRIPTION
C       1           HP       PREVIOUS STAGE VALUE
C       2           QP       PREVIOUS DISCHARGE VALUE
C       3           DQ       RATE OF CHANGE IN DISCHARGE (ICNVRT=1)
C                   DH       RATE OF CHANGE IN STAGE  (ICNVRT=2)
C       4           MISING   NO. OF MISSING VALUES IMMEDIATLY PRECEDING
C                            FIRST VALUE OF T.S. TO CONVERT
C
C.......................................................................
C
C  ROUTINE ORIGINALLY WRITTEN BY JONATHAN WETMORE - HRL - 4/1981
C
C***********************************************************************
C
      INCLUDE 'common/ionum'
      INCLUDE 'common/fdbug'
C
      CHARACTER*80 CARD
      DIMENSION PO(*),CO(*)
      DIMENSION RCID(2),STGID(2),QDATID(2),PNTNAM(5),CINPUT(2),OUTPUT(2)
      DIMENSION STAGE(2),DISCHG(2),SUBNAM(2)
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcinit_pntb/RCS/pin23.f,v $
     . $',                                                             '
     .$Id: pin23.f,v 1.3 2002/02/11 20:20:38 dws Exp $
     . $' /
C    ===================================================================
C
C
      DATA RDCO,STUNIT,STGDIM,QUNIT,QDIM/4HRDCO,4HM   ,4HL   ,4HCMS ,4HL
     13/T /
      DATA CINPUT,OUTPUT/4HINPU,4HT   ,4HOUTP,4HUT  /
      DATA STAGE,DISCHG/4HSTAG,4HE   ,4HDISC,4HHARG/
      DATA SUBNAM/4HPIN2,4H3   /
      DATA LTRACE,NOP/1,23/
C
C
      CALL FPRBUG (SUBNAM,LTRACE,NOP,IBUG)
C
C  SET VERSION NUMBER
      IVERS=1
C
C  INITIALIZE VARIABLES
      HP=0.
      QP=0.
      DH=0.
      DQ=0.
      MISING=0
      NOFILL=0
      IERFND=0
      IUSEP=0
      IUSEC=0
C
C  READ INPUT CARDS
C
      READ(IN,1) (PNTNAM(J),J=1,5),(RCID(I),I=1,2),ICNVRT,READCO
      READ(IN,2) (STGID(I),I=1,2),STGTYP,IDTSTG,(QDATID(J),J=1,2),QTYPE,
     1IDTQ
C
C  CHECK TO SEE IF DEFAULT VALUE FOR ICNVRT IS TO BE USED
      IF(ICNVRT.NE.2) ICNVRT=1
C CARRYOVER GIVEN?
      IF(READCO.NE.RDCO) GO TO 10
C C.O. IS GIVEN. - READ IN DEPENDING ON ICNVRT
      IF(ICNVRT.EQ.1) THEN
         READ (IN,'(A)') CARD
         READ (CARD,3,ERR=551) HP,QP,DQ,MISING
         GO TO 552
551      CALL FRDERR (IPR,' ',CARD)
552      ENDIF
      IF(ICNVRT.EQ.2) THEN
         READ (IN,'(A)') CARD
         READ (CARD,3,ERR=553) HP,QP,DH,MISING
         GO TO 554
553      CALL FRDERR (IPR,' ',CARD)
554      ENDIF
C
  10  CONTINUE
C  PRINT DEBUG INFO
      IF(IBUG.LT.1) GO TO 15
      WRITE(IODBUG,5) PNTNAM,RCID,ICNVRT,READCO,STGID,STGTYP,IDTSTG,
     1QDATID,QTYPE,IDTQ
      IF(READCO.NE.RDCO) GO TO 11
      IF(ICNVRT.EQ.1) WRITE(IODBUG,31) HP,QP,DQ,MISING
      IF(ICNVRT.EQ.2) WRITE(IODBUG,31) HP,QP,DH,MISING
C
  11  WRITE(IODBUG,32)
C  PRINT INTERPRETAION OF CARD INPUT
      WRITE(IODBUG,6) PNTNAM
      IF(ICNVRT.EQ.1) WRITE(IODBUG,7) ICNVRT,STAGE,DISCHG
      IF(ICNVRT.EQ.2) WRITE(IODBUG,7) ICNVRT,DISCHG,STAGE
      WRITE(IODBUG,8) STAGE,STGID,STAGE,STGTYP,STAGE,IDTSTG
      WRITE(IODBUG,8) DISCHG,QDATID,DISCHG,QTYPE,DISCHG,IDTQ
      WRITE(IODBUG,81) RCID
      IF(READCO.NE.RDCO) WRITE(IODBUG,83)
      IF(READCO.NE.RDCO) GO TO 12
      IF(ICNVRT.EQ.1) WRITE(IODBUG,82) HP,QP,DISCHG,DQ,MISING
      IF(ICNVRT.EQ.2) WRITE(IODBUG,82) HP,QP,STAGE,DH,MISING
 12   WRITE(IODBUG,84)
C
  15  CONTINUE
C  CHECK TO ASSURE ENOUGH SPACE IS IN P ARRAY
      I18=18
      CALL CHECKP(I18,LEFTP,KFLAG)
      IF(KFLAG.EQ.0) GO TO 20
C  NOT ENOUGH SPACE
      NOFILL=1
      IERFND=1
C
C  CHECK TO ASSURE ENOUGH SPACE IN C.O. ARRAY
  20  IFOUR=4
      CALL CHECKC(IFOUR,LEFTC,LFLAG)
      IF(LFLAG.EQ.0) GO TO 30
C  NOT ENOUGH SPACE
      NOFILL=1
      IERFND=1
C
  30  CONTINUE
C  COMPARE TIME STEP SIZES OF STAGE AND DISCHARGE TIME SERIES
      IF(IDTSTG.EQ.IDTQ) GO TO 40
C  UNEQUAL TIME STEPS - THIS IS AN ERROR
      WRITE(IPR,1003) PNTNAM,IDTSTG,IDTQ
      CALL ERROR
      IERFND=1
C
  40  CONTINUE
      IF (ICNVRT.EQ.2) GO TO 149
C
C   *********** THIS SECTION CHCKS TIME SERIES FOR ************
C   *********** INPUT STAGE AND OUTPUT DISCHARGE *************
C
C CHECK LEGITIMACY OF STAGE T.S.
      CALL CHEKTS(STGID,STGTYP,IDTSTG,1,STGDIM,1,1,IERR)
      IF(IERR.EQ.0) GO TO 50
C  PROB ENCOUNTERED BY CHEKTS
      IERFND=1
      GO TO 54
 50   CONTINUE
C  CHECK DOCUMENTATION OF INPUT STAGE T.S.
      CALL FDCODE(STGTYP,HUNOUT,HDIMOU,MSNG,NVPTI,TSCALE,NADINF,IERRO)
      IF(IERRO.EQ.0) GO TO 51
C STAGE TYPE CODE ERROR FOUND
      IERFND=1
      GO TO 54
  51  CONTINUE
C  CHECK DIMENSION OF INPUT T.S.
      IF(HDIMOU.EQ.STGDIM) GO TO 52
C  DIM PROBLEM
      WRITE(IPR,1007) CINPUT,STAGE,STGID,HDIMOU,STGDIM
      CALL ERROR
      IERFND=1
 52   CONTINUE
C  CHECK UNITS OF INPUT T.S.
      IF(HUNOUT.EQ.STUNIT) GO TO 53
C  PROB WITH UNITS
      WRITE(IPR,1006) CINPUT,STAGE,STGID,HUNOUT,STUNIT
      CALL ERROR
      IERFND=1
 53   CONTINUE
C  CHECK NUMBER OF VALUES PER TIME INTERVAL (SHOULD BE=1)
      IF(NVPTI.EQ.1) GO TO 54
C  TOO MANY PTS PER TIME INTERVAL
      IERFND=1
 54   CONTINUE
C  CHECK OUTPUT T.S. TO MAKE SURE IT EXISTS AND IS COMPATIBLE W/ INPUT
C
      CALL CHEKTS(QDATID,QTYPE,IDTQ,1,QDIM,1,1,IEROR)
      IF(IEROR.EQ.0) GO TO 55
C  PROB ENCOUNTERED BY CHEKTS FOR OUTPUT T.S.
      IERFND=1
      GO TO 59
 55   CONTINUE
C CHECK OUTPUT T.S. DOCUMENTATION
      CALL FDCODE(QTYPE,QUNOUT,QDIMOU,MISS,NUMPTI,TSCALE,NADINF,JERRO)
CC ** EV CHANGE ** PUT CHEKTS IN AGAIN TO CHECK ABOUT MSG VALS
      CALL CHEKTS(STGID,STGTYP,IDTSTG,1,STGDIM,MISS,1,IERR)
      IF(JERRO.EQ.0 .AND. IERR.EQ.0) GO TO 56
C  PROB WITH DATA TYPE CODE
      IERFND=1
      GO TO 59
 56   CONTINUE
C  CHECK OUTPUT T.S. DIMENSION
      IF(QDIMOU.EQ.QDIM) GO TO 57
C  DIM PROBLEM
      WRITE(IPR,1007) OUTPUT,DISCHG,QDATID,QDIMOU,QDIM
      CALL ERROR
      IERFND=1
 57   CONTINUE
C  CHECK OUTPUT T.S. UNITS
      IF(QUNOUT.EQ.QUNIT) GO TO 58
C  PROB WITH UNITS
      WRITE(IPR,1006) OUTPUT,DISCHG,QDATID,QUNOUT,QUNIT
      CALL ERROR
      IERFND=1
 58   CONTINUE
C  CHECK NUM PTS PER TIME INTERVAL
      IF(NUMPTI.LE.1) GO TO 59
C  TOO MANY PTS PER INTERVAL
      IERFND=1
 59   CONTINUE
C
C  *************** INPUT STAGE AND OUTPUT DISCHARGE TIME SERIES ********
C  ***** HAVE BEEN CHECKED.  GO TO 200 AND CHECK R.C. ID EXISTENCE *****
C
      GO TO 200
C
 149  CONTINUE
C
C
C   *********** THIS SECTION CHCKS TIME SERIES FOR ************
C   *********** INPUT DISCHARGE AND OUTPUT STAGE *************
C
C CHECK LEGITIMACY OF DISCHARGE T.S.
      CALL CHEKTS(QDATID,QTYPE,IDTQ,1,QDIM,1,1,IERR)
      IF(IERR.EQ.0) GO TO 150
C  PROB ENCOUNTERED BY CHEKTS
      IERFND=1
      GO TO 154
 150   CONTINUE
C  CHECK DOCUMENTATION OF INPUT T.S.
      CALL FDCODE(QTYPE,QUNOUT,QDIMOU,MSNG,NVPTI,TSCALE,NADINF,IERRO)
      IF(IERRO.EQ.0) GO TO 151
C DISCHARGE TYPE CODE ERROR FOUND
      IERFND=1
      GO TO 154
 151   CONTINUE
C  CHECK DIMENSION OF INPUT T.S.
      IF(QDIMOU.EQ.QDIM) GO TO 152
C  DIM PROBLEM
      WRITE(IPR,1007) CINPUT,DISCHG,QDATID,QDIMOU,QDIM
      CALL ERROR
      IERFND=1
 152   CONTINUE
C  CHECK UNITS OF INPUT T.S.
      IF(QUNOUT.EQ.QUNIT) GO TO 153
C  PROB WITH UNITS
      WRITE(IPR,1006) CINPUT,DISCHG,QDATID,QUNOUT,QUNIT
      CALL ERROR
      IERFND=1
 153   CONTINUE
C  CHECK NUMBER OF VALUES PER TIME INTERVAL (SHOULD BE=1)
      IF(NVPTI.EQ.1) GO TO 154
C  TOO MANY PTS PER TIME INTERVAL
      IERFND=1
 154   CONTINUE
C  CHECK OUTPUT T.S. TO MAKE SURE IT EXISTS AND IS COMPATIBLE W/ INPUT
C
C
      CALL CHEKTS(STGID,STGTYP,IDTSTG,1,STGDIM,1,1,IEROR)
      IF(IEROR.EQ.0) GO TO 155
C  PROB ENCOUNTERED BY CHEKTS FOR OUTPUT T.S.
      IERFND=1
      GO TO 159
 155   CONTINUE
C CHECK OUTPUT T.S. DOCUMENTATION
      CALL FDCODE(STGTYP,HUNOUT,HDIMOU,MISS,NUMPTI,TSCALE,NADINF,JERRO)
CC ** EV CHANGE ** PUT CHEKTS IN AGAIN TO CHECK ABOUT MSG VALS
      CALL CHEKTS(QDATID,QTYPE,IDTQ,1,QDIM,MISS,1,IERR)
      IF(JERRO.EQ.0 .AND. IERR.EQ.0) GO TO 156
C  PROB WITH DATA TYPE CODE
      IERFND=1
      GO TO 159
 156   CONTINUE
C  CHECK OUTPUT T.S. DIMENSION
      IF(HDIMOU.EQ.STGDIM) GO TO 157
C  DIM PROBLEM
      WRITE(IPR,1007) OUTPUT,STAGE,STGID,HDIMOU,STGDIM
      CALL ERROR
      IERFND=1
 157   CONTINUE
C  CHECK OUTPUT T.S. UNITS
      IF(HUNOUT.EQ.STUNIT) GO TO 158
C  PROB WITH UNITS
      WRITE(IPR,1006) OUTPUT,STAGE,STGID,HUNOUT,STUNIT
      CALL ERROR
      IERFND=1
 158   CONTINUE
C  CHECK NUM PTS PER TIME INTERVAL
      IF(NUMPTI.LE.1) GO TO 159
C  TOO MANY PTS PER INTERVAL
      IERFND=1
 159   CONTINUE
C
C  *************** INPUT DISCHARGE AND OUTPUT STAGE TIME SERIES ********
C  ***** HAVE BEEN CHECKED.  GO TO 200 AND CHECK R.C. ID EXISTENCE *****
C
C  CHECK RATING CURVE EXISTENCE
C
 200  CALL CHEKRC(RCID,IERFLG)
      IF(IERFLG.EQ.0) GO TO 210
C  ERROR ENCOUNTERED BY CHEKRC
      IERFND=1
C
  210 CONTINUE
C
C
C ***************  CHECK LEGITIMACY OF CARRYOVER VALUES  **************
      IF(READCO.NE.RDCO) GO TO 220
 211  CONTINUE
      IF(QP.GE.0.) GO TO 212
      WRITE(IPR,1011) DISCHG,PNTNAM,QP
      CALL WARN
      QP=0.
 212  CONTINUE
      IF(MISING.GE.0) GO TO 213
      WRITE(IPR,1012) PNTNAM,MISING
      CALL WARN
      MISING=0
 213  CONTINUE
C
C  CHECK RATE OF CHANGE -VS- PREVIOUS VALUE
      IF(ICNVRT.EQ.2) GO TO 214
      IF(QP.GE.DQ) GO TO 220
      WRITE(IPR,1013) PNTNAM,DISCHG,DQ,DISCHG,QP
      CALL WARN
      DQ=0.
      GO TO 220
 214  CONTINUE
      IF(HP.GE.DH) GO TO 220
      WRITE(IPR,1013) PNTNAM,STAGE,DH,STAGE,HP
      CALL WARN
      DH=0.
 220  CONTINUE
C
C ** EV CHANGE **
C CHECK IERFND...IF ANY ERRORS (IERFND NE 0) DONT FILL PO
C
      IF (IERFND.EQ.0) GO TO 290
      WRITE(IPR,1020)
      CALL ERROR
1020  FORMAT('0**ERROR** INPUT AND OUTPUT TIME SERIES',
     1 ' ARE INCOMPATIBLE')
      NOFILL=1
290   CONTINUE
C
C  NOW ALL CHECKS HAVE BEEN MADE AND VALUES INITIALIZED AS NECESSARY AND
C  IT IS TIME TO FILL PO AND CO ARRAYS IF POSSIBLE
      IF(NOFILL.EQ.1) GO TO 999
C
 300  CONTINUE
C
C  FILL PO ARRAY
C
      PO(1)=IVERS+0.01
      DO 310 I=1,5
 310  PO(I+1)=PNTNAM(I)
      PO(7)=ICNVRT+0.01
      DO 320 I=1,2
      PO(I+7)=STGID(I)
      PO(I+11)=QDATID(I)
      PO(I+15)=RCID(I)
 320  CONTINUE
      PO(10)=STGTYP
      PO(11)=IDTSTG+0.01
      PO(14)=QTYPE
      PO(15)=IDTQ+0.01
      PO(18)=0.01
      IF(READCO.EQ.RDCO) PO(18)=1.01
C
C  FILL CO ARRAY
C
      CO(1)=HP
      CO(2)=QP
      CO(3)=DQ
      IF(ICNVRT.EQ.2) CO(3)=DH
      CO(4)=MISING+0.01
C
C  SET NO. OF PLACES IN PO AND CO ARRAYS
C
      IUSEP=18
      IUSEC=4
C
C  DBUG INFO ON PO AND CO ARRAY REQUESTED?
      IF(IBUG.LT.1) GO TO 999
      WRITE(IODBUG,90) (PO(I),I=1,6)
      WRITE(IODBUG,91) (PO(I),I=7,11)
      WRITE(IODBUG,92) (PO(I),I=12,18)
      WRITE(IODBUG,93) (CO(I),I=1,4)
C
C
C
C  INPUT FORMAT STATEMENTS
C
  1   FORMAT(5A4,2X,2A4,9X,I1,1X,A4)
  2   FORMAT(2X,2A4,1X,A4,3X,I2,2X,2A4,1X,A4,3X,I2)
  3   FORMAT(F10.2,F10.0,F10.2,I10)
C  DEBUG FORMAT STATEMENTS
  31  FORMAT(1X,F10.2,F10.0,F10.2,I10)
  32  FORMAT(/1X,16(5H----+) /)
  5   FORMAT(01H0,20X,32HCARD INPUT FOR STAGE-Q OPERATION //9X,02H10,8X,
     1   02H20,8X,02H30,8X,02H40,8X,02H50,8X,02H60,8X,02H70,8X,02H80 /1X
     1,         16(05H----+) //1X,5A4,2X,2A4,9X,I1,1X,A4 /1X,2X,2A4,1X,A
     14,3X,I2,2X,2A4,1X,A4,3X,I2)
  6   FORMAT(/1X,    14(1H*),52H INTERPRETATION OF CARD INPUT FOR STAGE-
     1Q OPERATION ,14(1H*) //1X,39HGAGING STATION OR FORECAST POINT NAME
     .: ,5A4)
  7   FORMAT(01H0,2X,22HCONVERSION INDICATOR= ,I2,02H (,2A4,04H TO ,2A4,
     .01H))
  8   FORMAT(01H0,2X,2A4,26H TIME SERIES IDENTIFIER = ,2A4 /3X,2A4,5H TI
     1ME,25H SERIES DATA TYPE CODE = ,A4 /2X,28H TIME INTERVAL IN HOURS
     1FOR ,2A4,08H T.S. = ,I2)
 81   FORMAT(01H0,1X,27H RATING CURVE IDENTIFIER = ,2A4 /)
 82   FORMAT(3X,    21HPREVIOUS STAGE (M) = ,F10.2,4X,27HPREVIOUS DISCHA
     1RGE (CMS) = ,F10.0 /3X,18HRATE OF CHANGE IN ,2A4,3H = ,F10.2 /3X,
     149HNUMBER OF MISSING VALUES PRIOR TO START OF RUN = ,I5)
 83   FORMAT(1H0,3X,28HNO CARRYOVER VALUES READ IN.)
 84   FORMAT(/1X,80(1H*),2(1H0))
 90   FORMAT(1H0,2X,18HPO ARRAY CONTENTS: //2X,6HPO(1)=,F4.2,3X,07HPO(2)
     1= ,A4,3X,06HPO(3)=,A4,3X,07HPO(4)= ,A4,3X,07HPO(5)= ,A4,3X,07HPO(
     .6)= ,A4)
 91   FORMAT(01H0,2X,07HPO(7)= ,F4.2,3X,07HPO(8)= ,A4,3X,07HPO(9)= ,A4,3
     1X,  08HPO(10)= ,A4,3X,08HPO(11)= ,F5.2)
 92   FORMAT(01H0,2X,07HPO(12)=,A4,2X,07HPO(13)=,A4,2X,07HPO(14)=,A4,
     13X, 07HPO(15)=,F5.2,3X,07HPO(16)=,A4,3X,07HPO(17)=,A4,07HPO(18)=,
     1F5.2)
 93   FORMAT(01H0,2X,19H CO ARRAY CONTENTS: //2X,07HCO(1)= ,F10.2,3X,
     1   07HCO(2)= ,F10.0,3X,07HCO(3)= ,F10.2,3X,07HCO(4)= ,F10.2)
C
C  ERROR MSG FORMAT STATEMENTS
C
 1003 FORMAT(01H0,10X,48H**ERROR** UNEQUAL TIME INTERVALS IN T.S.DATA FO
     1R, 18H STAGE-Q OPERATION /21X,14HLOCATION NAME ,5A4 /21X,09HTHE ST
     1AGE, 17H T.S. DELTA T IS ,I2,6H HOURS /21X,32HWHILE THE DISCHARGE
     1T.S. DELTA T, 04H IS ,I2,07H HOURS.)
 1006 FORMAT(01H0,10X,10H**ERROR** ,2A4,1X,2A4,17H TIME SERIES (ID=,2A4,
     11H) /21X,13HHAS UNITS OF ,A4,28H WHEN IT MUST HAVE UNITS OF ,A4)
 1007 FORMAT(01H0,10X,10H**ERROR** ,2A4,1X,2A4,17H TIME SERIES (ID=,2A4,
     11H) /21X,17HHAS DIMENSION OF ,A4,32H WHEN IT MUST HAVE DIMENSION O
     1F ,   A4)
 1011 FORMAT(01H0,10X,39H*WARNING* CARRYYOVER VALUE FOR PREVIOUS ,2A4,
     1  23H READ IN BY STAGE-Q OP. /21X,18HFOR LOCATION NAME ,5A4,07H IS
     1.LT.,08H ZERO (=,F10.2,02H). /21X,35HTHIS IS NOT ALLOWED, VALUE WI
     1LL BE , 12HSET TO ZERO.)
 1012 FORMAT(01H0,10X,48H*WARNING* CARRYYOVER VALUE READ IN BY STAGE-Q O
     1P /21X,15H(LOCATION NAME=,5A4,1H) /21X,30HFOR NUMBER OF MISSING VA
     1LUES(=,I5,19H) IMMEDIATELY PRIOR /21X,25HTO START OF RUN IS .LT. 0
     1, 22H  THIS IS NOT ALLOWED. /21X,26HVALUE WILL BE SET TO ZERO.)
 1013 FORMAT(01H0,10X,46H*WARNING* CARRYOVER VALUES READ IN BY STAGE-Q ,
     121HOP. FOR LOCATION NAME /21X,5A4,28H ARE OUT OF ORDER. I.E. THE
     1/21X,18HRATE OF CHANGE IN ,2A4,03H (=,F10.2,1H) /21X,16HGREATER TH
     1AN THE,10H PREVIOUS ,2A4,02H(=,F10.2,01H) /21X,26HRATE OF CHANGE W
     1ILL BE SET,09H TO ZERO.)
C
 999  IF(ITRACE.GE.1) WRITE(IODBUG,*) 'EXIT PIN23'
C
       RETURN
C
       END
