C MODULE PIN13
C-----------------------------------------------------------------------
C
      SUBROUTINE PIN13(P,LEFTP,IUSEP,C,LEFTC,IUSEC,NEEDC)
C
C     THIS THE INPUT SUBROUTINE FOR TATUM COEFFICIENT ROUTING.
C     THIS SUBROUTINE INPUTS ALL CARDS FOR THE OPERATION
C     AND FILLS THE P ARRAY AND PLACES INITIAL VALUES OF THE
C     STATE VARIABLES IN THE C ARRAY.
C
C     ROUTINE ORIGINALLY WRITTEN BY - DAVID REED - HRL 12/1979
C
      DIMENSION P(*),C(*)
      DIMENSION TITLE(5),QIN(2),QOUT(2)
C
C
C     DEFINITION OF VARIABLES
C
C     QIN         INTERNAL IDENTIFIER FOR INFLOW TIME SERIES
C     QITYPE      DATA TYPE CODE FOR INFLOW TIME SERIES
C     IDTQI       TIME INTERVAL FOR INFLOW TIME SERIES
C     QOUT        INTERNAL IDENTIFIER FOR OUTFLOW TIME SERIES
C     QOTYPE      DATA TYPE CODE FOR OUTFLOW TIME SERIES
C     IDTQO       TIME INTERVAL FOR OUTFLOW TIME SERIES
C     TITLE       GENERAL TITLE OF REACH OR PROBLEM
C     NL          NUMBER OF LAYERS FOR ROUTING
C     ICVAL       CARRYOVER DECISION PARAMETER
C                 IF ICVAL=0,ALL RESIDUAL CARRYOVER SET TO 0 BY DEFAULT
C                 IF ICVAL=1,ALL RESIDUAL CARRYOVER IS READ FROM
C                      DATA CARD
C
      CHARACTER*8 RTNNAM
C
      INCLUDE 'common/ionum'
      INCLUDE 'common/fdbug'
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcinit_pntb/RCS/pin13.f,v $
     . $',                                                             '
     .$Id: pin13.f,v 1.2 2002/02/11 19:00:07 dws Exp $
     . $' /
C    ===================================================================
C
      DATA DIMQI/4HL3/T/,DIMQO/4HL3/T/
C
C
      RTNNAM='PIN13'
      LTRACE=1
      NUMOP=13
      CALL FPRBUG (RTNNAM,LTRACE,NUMOP,IBUG)
C
C     READ IN CARD #1-TITLE,INFLOW AND OUTFLOW TIME SERIES IDENTIFIER,
C                    NUMBER OF LAYERS, AND CARRYOVER DECISION PARAMETERS
C
      READ(IN,901)TITLE,QIN,QITYPE,IDTQI,QOUT,QOTYPE,IDTQO,NL,ICVAL
  901 FORMAT(5A4,2X,2A4,1X,A4,3X,I2,2X,2A4,1X,A4,3X,I2,2X,I3,4X,I1)
      IVER=1
      NOFILL=0
      NEEDC=0
      NLM1=NL-1
      NQST=17+NL
      NCST=NQST+NLM1
      IF(NL.GT.0) GO TO 209
      WRITE(IPR,927)
  927 FORMAT(1H0,10X,38H**ERROR**THE NUMBER OF LAYERS IS ZERO.)
      CALL ERROR
      IUSEP=0
      IUSEC=0
      NOFILL=1
C
C     CHECK INFLOW TIME SERIES USING SUBROUTINE CHEKTS
C
  209 CALL CHEKTS(QIN,QITYPE,IDTQI,1,DIMQI,0,1,IERFLG)
C
C     CHECK OUTFLOW TIME SERIES
C
      IF(IDTQO.EQ.0) GO TO 103
      IF(IDTQO.GE.IDTQI) GO TO 102
      WRITE(IPR,905)IDTQO,IDTQI
  905 FORMAT(1H0,10X,33H**ERROR** OUTFLOW TIME INTERVAL =,I3,6H HOURS,
     136H IS LESS THAN INFLOW TIME INTERVAL =,I3,6H HOURS/
     21H ,20X,39H THIS IS NOT ALLOWED FOR THIS OPERATION)
C
      CALL ERROR
C
C     CHECK OUTFLOW TIME SERIES BY USING SUBROUTINE CHEKTS
C
  102 CALL CHEKTS(QOUT,QOTYPE,IDTQO,1,DIMQO,0,1,IERFLG)
C
C
C     CALCULATE THE SPACES NEEDED IN THE P AND C ARRAYS
  103 IF(NOFILL.EQ.1) GO TO 114
C
C     CHECK INITIALLY FOR SIZE OF P ARRAY
C
      IF(LEFTP.GE.NCST+NL-1)GO TO 231
      WRITE(IPR,908)
      CALL ERROR
      IUSEP=0
      IUSEC=0
      GO TO 114
C
C     READ IN NUMBER OF COEFFICIENTS PER LAYER
C
  231 READ(IN,917,ERR=235)(P(16+I),I=1,NL)
      GO TO 236
235   CALL FRDERR (IPR,'NUMBER OF COEFFICIENTS PER LAYER',' ')
236   NCOEF=0
      DO 232 I=1,NL
      P(16+I)=P(16+I)+0.01
      NCL = P(16+I)
      IF (NCL.GT.1) NEEDC = 1
      IF (NCL.GT.0) GO TO 232
      IUSEP=0
      IUSEC=0
      WRITE(IPR,942)
  942 FORMAT(1H0,61H**ERROR**THE NUMBER OF TATUM COEFFICIENTS FOR A LAYE
     1R IS ZERO)
      CALL ERROR
      GO TO 114
  232 NCOEF=NCOEF+NCL
C
C     DETERMINE TOTAL SPACE NEEDED
C
      IUSEC=NCOEF-NL
      IUSEP=16+NL+NLM1+NCOEF
C
C     CHECK TO SEE IF THERE IS ENOUGH ROOM IN THE P AND C ARRAYS
C
      IF(IUSEP.LE.LEFTP) GO TO 111
      WRITE(IPR,908)
  908 FORMAT(1H0,10X,74H**ERROR** THIS OPERATION NEEDS MORE SPACE THAN I
     1S AVAILABLE IN THE P ARRAY)
      CALL ERROR
      NOFILL=1
  111 IF(IUSEC.LE.LEFTC) GO TO 112
      WRITE(IPR,909)
  909 FORMAT(1H0,10X,74H**ERROR** THIS OPERATION NEEDS MORE SPACE THAN I
     1S AVAILABLE IN THE C ARRAY)
      CALL ERROR
      NOFILL=1
C
C
  112 IF(NOFILL.EQ.0) GO TO 113
      IUSEC=0
      IUSEP=0
      GO TO 114
C
C     CHECK QRANGE DATA FOR ERRORS
C        THESE VALUES MUST BE IN INCREASING ORDER
  113 IF(NL.LE.1) GO TO 107
      READ(IN,917,ERR=118)(P(NQST+I-1),I=1,NLM1)
      GO TO 119
118   CALL FRDERR (IPR,'FLOW RANGES FOR LAYERS',' ')
119   IERFLG=0
      IF(NL.LE.2) GO TO 107
      NM2=NLM1-1
      DO 106 I=1,NM2
  106 IF(P(NQST+I-1).GE.P(NQST+I))IERFLG=1
      IF(IERFLG.EQ.0)GO TO 107
      WRITE(IPR,907)
  907 FORMAT(1H0,10X,56H**ERROR** FLOW RANGES FOR LAYERS NOT IN INCREASI
     1NG ORDER)
      CALL ERROR
C
C     READ IN TATUM COEFFICIENTS - ONE LAYER AT A TIME
C
  107 IPTR=NCST-1
      DO 243 I=1,NL
      NCL=P(16+I)
      READ(IN,917,ERR=246)(P(IPTR+J),J=1,NCL)
  917 FORMAT(7F10.0)
      GO TO 248
246   CALL FRDERR (IPR,'TATUM COEFFICIENTS',' ')
248   TOTAL=0.
      DO 244 J=1,NCL
  244 TOTAL=TOTAL+P(IPTR+J)
      DIFF=ABS(TOTAL-1.0)
      IF(DIFF.LT.0.001)GO TO 243
      WRITE(IPR,941) I
  941 FORMAT(1H0,10X,52H**WARNING** COEFFICIENTS DO NOT SUM TO 1.0 FOR L
     .AYER,I3,38H.  A GAIN OR LOSS OCCURS IN THE REACH.)
      CALL WARN
  243 IPTR=IPTR+NCL
C
C     CHECK TO SEE IF CARRYOVER SHOULD BE READ IN INITIALLY OR
C           SET EQUAL TO ZERO BY DEFAULT
C
      IF (NEEDC.EQ.0) GO TO 109
      IF(ICVAL.EQ.0) GO TO 108
      IPTR=0
      DO 261 I=1,NL
      NCL=P(16+I)
      NCLM=NCL-1
      IF(NCL.EQ.1)GO TO 261
      READ(IN,917,ERR=262)(C(IPTR+J),J=1,NCLM)
      GO TO 261
262   CALL FRDERR (IPR,'CARRYOVER',' ')
  261 IPTR=IPTR+NCLM
      GO TO 109
  108 DO 110 I=1,IUSEC
  110 C(I)=0.
C
C     PUT VALUES IN THE P ARRAY
C
  109 P(1)=IVER+0.01
      DO 116 I=2,6
  116 P(I)=TITLE(I-1)
      P(7)=QIN(1)
      P(8)=QIN(2)
      P(9)=QITYPE
      P(10)=IDTQI+0.01
      P(11)=QOUT(1)
      P(12)=QOUT(2)
      P(13)=QOTYPE
      P(14)=IDTQO+0.01
      P(15)=ICVAL+0.01
      P(16)=NL+0.01
      IF(IBUG.EQ.0) GO TO 114
C
C     PRINT DEBUG OUTPUT  P AND C ARRAYS
C
      WRITE(IODBUG,910)IUSEP,IUSEC
  910 FORMAT(1H0,10X,26HCONTENTS OF P AND C ARRAYS,5X,
     124HNUMBER OF VARIABLES---P=,I3,5H  C =,I3)
      WRITE(IODBUG,911)(P(I),I=1,IUSEP)
  911 FORMAT(1H0,14(F8.3,1X))
      IF (NEEDC.EQ.0) GO TO 114
      WRITE(IODBUG,911)(C(I),I=1,IUSEC)
C
C     POSITION         CONTENTS OF P ARRAY
C     1                VERSION NUMBER OF OPERATION
C     2-6              GENERAL NAME OR TITLE
C     7-8              INFLOW TIME SERIES I.D.
C     9                INFLOW TIME SERIES DATA TYPE
C     10               INFLOW TIME SERIES TIME INTERVAL
C     11-12            OUTFLOW TIME SERIES I.D.
C     13               OUTFLOW TIME SERIES DATA TYPE
C     14               OUTFLOW TIME SERIES TIME INTERVAL
C     15               CARRYOVER DECISION PARAMETER
C                        =0--RESIDUALS =0 BY DEFAULT
C                        =1--RESIDUALS ARE READ IN FROM NEXT DATA CARD
C     16               NUMBER OF LAYERS
C
C
C                STARTING LOCATION OF NUMBER OF COEFFICIENTS FOR A LAYER
C                          IS POSITION 17
C
C                STARTING LOCATION OF FLOW RANGES IS POSITION (17+NL)
C
C                STARTING LOCATION OF COEFFICIENTS IS POSITION
C                          (17+2*NL-1)
C
  114 RETURN
      END
