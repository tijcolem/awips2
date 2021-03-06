C MEMBER PM1626
C  (from old member FCPM1626)
C
C @PROCESS LVL(77)
      SUBROUTINE PM1626(WORK,IUSEW,LEFTW,NP16,NEEDEP,LOCWHC,
     .                  LENDSU,JDEST,IERR)
C                             LAST UPDATE: 02/10/94.09:55:04 BY $WC30KH
C
C---------------------------------------------------------------------
C  SUBROUTINE TO READ AND INTERPRET PARAMETER INPUT FOR PARAMETER #16
C    RAIN/EVAP ON RESERVOIR
C---------------------------------------------------------------------
C  JTOSTROWSKI - HRL - MARCH 1983
C----------------------------------------------------------------
C
      INCLUDE 'common/ionum'
      INCLUDE 'common/comn26'
      INCLUDE 'common/err26'
      INCLUDE 'common/fld26'
      INCLUDE 'common/read26'
      INCLUDE 'common/suky26'
      INCLUDE 'common/warn26'
C
      DIMENSION INPUT(4),LINPUT(4),EVAP(12),EDIST(24),IP(4)
      DIMENSION WORK(1),ELS(250),SEL(250),ELA(250),AEL(250),SELMN(250)
      LOGICAL ENDFND,EVOK,DISTOK,TOLOK,HREAOK,ALLOK,NEEDEP
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcinit_res/RCS/pm1626.f,v $
     . $',                                                             '
     .$Id: pm1626.f,v 1.2 2002/10/10 17:22:55 wkwock Exp $
     . $' /
C    ===================================================================
C
C
      DATA INPUT/4HEVAP,4HDIST,4HTOL ,4HHREA/
      DATA LINPUT/1,1,1,1/
      DATA NINPUT/4/
      DATA NDINPU/1/
C
C  INITIALIZE LOCAL VARIABLES AND COUNTERS
C
      NP16 = 0
      EVOK = .TRUE.
      DISTOK = .TRUE.
      TOLOK = .TRUE.
      HREAOK = .TRUE.
      ALLOK = .TRUE.
      NEEDEP = .TRUE.
      NEVAP = 0
      NEDIST = 0
C  NO NEED TO ITERATE ON RAIN-EVAP COMPUTATION
C  SET A HIGH ITERATION TOLERANCE TO AVOID RAIN-EVAP ITERATION
C  USE THE LOCATION FOR CONSTANT RESERVOIR SURFACE AREA OPTION
C  FOR BACKWARD COMPATIBILITY -- BY HSU -- 3/27/2002
      TOL= 0.5
      HREA= TOL
      LOCWHC = IUSEW + 1
C
C  NOW PROCESS INPUT UP TO 'ENDP', LOOKING FOR 'EVAP'(OPTIONAL -
C  CURVE INPUT IF FOUND), 'DIST' (OPTIONAL - NEEDED IF
C  'EVAP' ENTERED), AND TOL (OPTIONAL - DEFAULT OF 0.10)
C
      DO 3 I = 1,4
           IP(I) = 0
    3 CONTINUE
C
      IERR = 0
C
C  PARMS FOUND, LOOKING FOR ENDP
C
      LPOS = LSPEC + NCARD + 1
      LASTCD = LENDSU
      IBLOCK = 1
C
    5 IF (NCARD .LT. LASTCD) GO TO 8
           CALL STRN26(59,1,SUKYWD(1,7),3)
           IERR = 99
           GO TO 9
    8 NUMFLD = 0
      CALL UFLD26(NUMFLD,IERF)
      IF(IERF .GT. 0 ) GO TO 9000
      NUMWD = (LEN -1)/4 + 1
      IDEST = IKEY26(CHAR,NUMWD,SUKYWD,LSUKEY,NSUKEY,NDSUKY)
      IF (IDEST.EQ.0) GO TO 5
C
C  IDEST = 7 IS FOR ENDP
C
      IF (IDEST.EQ.7.OR.IDEST.EQ.8) GO TO 9
          CALL STRN26(59,1,SUKYWD(1,7),3)
          JDEST = IDEST
          IERR = 89
    9 LENDP = NCARD
C
C  ENDP CARD OR TS OR CO FOUND AT LENDP,
C  ALSO ERR RECOVERY IF NEITHER ONE OF THEM FOUND.
C
C
      IBLOCK = 2
      CALL POSN26(MUNI26,LPOS)
      NCARD = LPOS - LSPEC -1
C
   10 CONTINUE
      NUMFLD = 0
      CALL UFLD26(NUMFLD,IERF)
      IF(IERF .GT. 0) GO TO 9000
      NUMWD = (LEN -1)/4 + 1
      IDEST = IKEY26(CHAR,NUMWD,INPUT,LINPUT,NINPUT,NDINPU)
      IF(IDEST .GT. 0) GO TO 50
      IF(NCARD .GE. LENDP) GO TO 900
C
C  NO VALID KEYWORD FOUND
C
      CALL STER26(1,1)
      ALLOK = .FALSE.
      GO TO 10
C
C  NOW SEND CONTROL TO PROPER LOCATION FOR PROCESSING EXPECTED INPUT
C
   50 CONTINUE
      GO TO (100,200,300,400) , IDEST
C-----------------------------------------------------------------
C  'EVAP' EXPECTED HERE. IF NOT FOUND, SET OPTION TO NO EVAP.
C   IF FOUND, GET MEAN EVAP INPUT CURVE.
C
  100 CONTINUE
      IP(1) = IP(1) + 1
      IF (IP(1).GT.1) CALL STER26(39,1)
C
      WHICH = 0.01
      NEEDEP = .FALSE.
C
C  GET LIST OF VALUES
C
      NEVAP=12
      CALL GLST26(1,1,IX,EVAP,IX,NEVAP,EVOK)
C
C  MUST HAVE 12 VALUES
C
      IF (NEVAP.EQ.12) GO TO 120
C
      CALL STER26(84,1)
      GO TO 10
C
C  ALL VALUES MUST BE POSITIVE
C  CONVERT TO MM HERE ALSO.
C
  120 CONTINUE
C
      CONVMM = 1.0
      IF (IMETEN.LE.0) CALL FCONVT('MM  ','L   ',UNITSE,CONVMM,CON,IER)
C
      DO 130 I=1,NEVAP
      IF (EVAP(I).GE.0.00) GO TO 125
      CALL STER26(95,1)
      GO TO 10
C
  125 CONTINUE
      EVAP(I) = EVAP(I)/CONVMM
C
  130 CONTINUE
      EVOK = .TRUE.
      GO TO 10
C
C-----------------------------------------------------------------
C  'DIST' KEYWORD EXPECTED. ONLY ALLOWED IF EVAPORATION IS CURVE
C   SPECIFIED. IF FOUND, GET NEXT FIELD ON CARD.
C   IT'S AN ERROR IF NOT FOUND.
C
  200 CONTINUE
C
      IP(2) = IP(2) + 1
      IF (IP(2).GT.1) CALL STER26(39,1)
C  THE FOLLOWING CHANGE MADE ON 10/17/90
C      IF (.NOT.NEEDEP) GO TO 210
C           IF(IP(1).GT.0) CALL STRN26(60,1,INPUT(IDEST),LINPUT(IDEST))
C           IF(IP(1).EQ.0) CALL STRN26(59,1,INPUT(1),LINPUT(1))
C           DISTOK = .FALSE.
C           GO TO 10
C  END OF CHANGE OF 10/17/90
C
C  ONE VALUE PER TIME PERIOD MUST FOLLOW
C
  210 CONTINUE
      DISTOK = .FALSE.
C
C  GET LIST OF VALUES
C
      NEDIST=24
      CALL GLST26(1,1,IX,EDIST,IX,NEDIST,DISTOK)
C
C  MUST HAVE 24/MINODT VALUES
C
      IF (NEDIST.EQ.24/MINODT) GO TO 220
C
      CALL STER26(62,1)
      GO TO 10
C
C  ALL VALUES MUST BE POSITIVE
C
  220 CONTINUE
C
      TOTAL = 0.000
      DO 230 I=1,NEDIST
C
      IF (EDIST(I) .GE. 0.00) GO TO 225
C
      CALL STER26(61,1)
      GO TO 10
C
  225 CONTINUE
      TOTAL = TOTAL + EDIST(I)
  230 CONTINUE
C
C  TOTAL MUST SUM TO 1.000 +- .001
C
      DIFF = ABS(TOTAL-1.000)
      IF (DIFF .LE. 0.001) GO TO 240
C
      CALL STER26(71,1)
      GO TO 10
C
C  EVERYTHING IS OK
C
  240 CONTINUE
      DISTOK = .TRUE.
      GO TO 10
C
C----------------------------------------------------------------
C  'TOL' EXPECTED HERE. IF NOT FOUND, SET TOLERANCE TO 0.10.
C   IF FOUND, GET THE NEXT FIELD. IT MUST BE A POSITIVE REAL NUMBER
C   BETWEEN 0.0 AND 1.00
C
  300 CONTINUE
      IP(3) = IP(3) + 1
      IF (IP(3).GT.1) CALL STER26(39,1)
C
      TOLOK = .FALSE.
      NUMFLD = -2
      CALL UFLD26(NUMFLD,IERF)
      IF (IERF.GT.0) GO TO 9000
C
C  REAL VALUE MUST HAVE BEEN INPUT
C
  310 CONTINUE
      IF (ITYPE.EQ.1) GO TO 315
C
      CALL STER26(4,1)
      GO TO 10
C
C  SEE IF VALUE IS POSITIVE
C
  315 CONTINUE
      IF (REAL.GT.0.00) GO TO 320
C
      CALL STER26(61,1)
      GO TO 10
C
C  VALUE MUST BE BETWEEN 0.01 AND 1.00
C
  320 CONTINUE
      IF (0.00999.LE.REAL.AND.REAL.LE.1.00) GO TO 330
C
      CALL STER26(68,1)
      GO TO 10
C
C  EVERYTHING IS OK
C
  330 CONTINUE
      TOL = REAL
      TOLOK = .TRUE.
      GO TO 10
C
C----------------------------------------------------------------
C  'HREA' EXPECTED HERE. 
C   CONSTANT SURFACE AREA WILL BE USED FOR DIRECT RAINFALL AND 
C   EVAPORATION.  IF NOT FOUND, SET TO MISSING.
C   IF FOUND, GET THE NEXT FIELD. IT MUST BE A POSITIVE REAL NUMBER
C
  400 CONTINUE
      IP(4) = IP(4) + 1
      IF (IP(4).GT.1) CALL STER26(39,1)
C
      HREAOK = .FALSE.
      NUMFLD = -2
      CALL UFLD26(NUMFLD,IERF)
      IF (IERF.GT.0) GO TO 9000
C
C  REAL VALUE MUST HAVE BEEN INPUT
C
  410 CONTINUE
      IF (ITYPE.EQ.1) GO TO 415
C
      CALL STER26(4,1)
      GO TO 10
C
C  SEE IF VALUE IS POSITIVE
C
  415 CONTINUE
      IF (REAL.GT.0.00) GO TO 420
C
      CALL STER26(61,1)
      GO TO 10
C
C  EVERYTHING IS OK
C
  420 CONTINUE
      HREA = REAL
      HREAOK = .TRUE.
      GO TO 10
C
C--------------------------------------------------------------------
C  END OF INPUT. STORE VALUES IN WORK ARRAY IF EVERYTHING WAS ENTERED
C  WITHOUT ERROR.
C
  900 CONTINUE
      IF(HREA.GT.1.0 .OR. TOL.GT.1.0) GO TO 910
      DO 438 I=1,NSE
      ELS(I)= ELSTOR(I)*CONVL
      SEL(I)= STORGE(I)*CONVST
 438  SELMN(I)= SEL(I)
      DO 435 I = 1,NSE-1
      DH= (ELS(I+1) - ELS(I))
      DV= (SEL(I+1) - SEL(I))
      ELA(I)= ELS(I) + DH/2.0
 435  AEL(I)= DV/DH
      DO 436 I= 1,NSE-2
      I1= I
      I2= I+1
      IF (AEL(I2).GE.(AEL(I1)-1.5)) GO TO 436
      DO 440 II=I1+1,NSE
 440     SELMN(II)=AEL(I1)*(ELS(II) - ELS(I1))+SEL(I1)
         GO TO 437
 436  CONTINUE
      GO TO 910
 437  CONTINUE
      WRITE(IPR,1610)
 1610 FORMAT(/'   ** ELEVATION VS. AREA CURVE USED IN',
     &' RAINEVAP UTILITY BUT',
     &/' RESERVOIR SURFACE AREA NOT IN ASCENDING ORDER')
C      WRITE(IPR,1611) (ELA(I),I=1,NSE-1)
C      WRITE(IPR,1612) (AEL(I),I=1,NSE-1)
C 1611 FORMAT((6F10.3))
C 1612 FORMAT((6F10.1))
      WRITE(IPR,1613) I1,I2,ELA(I1),ELA(I2),AEL(I1),AEL(I2),
     &ELS(I1),ELS(I2),ELS(I2+1),SEL(I1),SEL(I2),SEL(I2+1),AEL(I1)
 1613 FORMAT(' SURFACE AREA NOT IN ASCENDING ORDER BETW NO ',2I3,
     &/' POOL ELEVATION IS      ',2F10.3,
     &/'   SURFACE AREA IS      ',2F10.0,
     &/' POOL ELEVATION IS ',3F10.3,
     &/'   POOL STORAGE IS ',3F10.0,
     &/' RESERVOIR STORAGE MUST INCREASE AT LEAST ',F10.0,
     &' PER UNIT DEPTH')
      WRITE(IPR,1615)
 1615 FORMAT(/'   ** ELEVATION VS. STORAGE VS MINIMUM STROAGE CURVE ')
      NSE6=NSE/6
      ISE6=I1/6
      IF(ISE6.LE.0) ISE6=1
      I1=(ISE6-1)*6+1
      DO 1620 ISE=ISE6,NSE6
        I2=I1+5
      WRITE(IPR,1621) (ELS(I),I=I1,I2)
      WRITE(IPR,1622) (SEL(I),I=I1,I2)
      WRITE(IPR,1623) (SELMN(I),I=I1,I2)
      I1=I2
 1620  CONTINUE
      I1=I2+1
      I2=NSE
      WRITE(IPR,1621) (ELS(I),I=I1,I2)
      WRITE(IPR,1622) (SEL(I),I=I1,I2)
      WRITE(IPR,1623) (SELMN(I),I=I1,I2)
 1621 FORMAT('    ELEV:', 6F10.3)
 1622 FORMAT('    STOR:', 6F10.1)
 1623 FORMAT(' MINSTOR:', 6F10.1)

      CALL STER26(41,1)
      ALLOK = .FALSE.
 910  CONTINUE
C
      IF (IP(1).GT.0) GO TO 920
      WHICH = -1.01
  920 CONTINUE
      IF (IP(2).GT.0) GO TO 925
      NEDIST = 24/MINODT
      DO 924 I=1,NEDIST
  924 EDIST(I) = 1./NEDIST
  925 CONTINUE
      IF (TOL.LT.1.0) GO TO 930
      HREA = TOL
C
  930 CONTINUE
      IF (EVOK.AND.DISTOK.AND.TOLOK.AND.HREAOK.AND.ALLOK) GO TO 1010
      GO TO 9999
C
C  STORE EITHER:
C     1) SWITCH AND TOLERANCE IF NO EVAP CURVE WAS ENTERED, OR
C     2) SWITCH, EVAP CURVE, DAILY DIST'N AND TOLERANCE IF EVAP CURVE
C        WAS ENTERED.
C
 1010 CONTINUE
C
      CALL FLWK26(WORK,IUSEW,LEFTW,WHICH,501)
C
      NDSTN = 0
C  THE FOLLOWING CHANGE MADE ON 10/17/90
C      IF (NEVAP.EQ.0) GO TO 1030
      IF (NEVAP.EQ.0) GO TO 1021
C  END OF CHANGE OF 10/17/90
      DO 1020 I=1,NEVAP
      CALL FLWK26(WORK,IUSEW,LEFTW,EVAP(I),501)
 1020 CONTINUE
C
C  THE FOLLOWING CHANGE MADE ON 10/17/90
C      DO 1025 I=1,NEDIST
 1021 DO 1025 I=1,NEDIST
C  END OF CHANGE OF 10/17/90
      CALL FLWK26(WORK,IUSEW,LEFTW,EDIST(I),501)
 1025 CONTINUE
C
 1030 CONTINUE
      HREAX= HREA
      IF(HREA .GT. 1.0 .AND. IMETEN .LE. 0)
     &HREAX= HREA/CONVL
      CALL FLWK26(WORK,IUSEW,LEFTW,HREAX,501)
      NP16 = NP16 + 2 + NEVAP + NEDIST
C
      GO TO 9999
C
C--------------------------------------------------------------
C  ERROR IN UFLD26
C
 9000 CONTINUE
      IF (IERF.EQ.1) CALL STER26(19,1)
      IF (IERF.EQ.2) CALL STER26(20,1)
      IF (IERF.EQ.3) CALL STER26(21,1)
      IF (IERF.EQ.4) CALL STER26( 1,1)
C
      IF (NCARD.GE.LASTCD) GO TO 9100
      IF (IBLOCK.EQ.1)  GO TO 5
      IF (IBLOCK.EQ.2)  GO TO 10
C
 9100 USEDUP = .TRUE.
C
 9999 CONTINUE
      RETURN
      END
