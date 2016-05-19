C MEMBER PIN40
C  (from old member MCPIN40)
C-----------------------------------------------------------------------
C
C                             LAST UPDATE: 12/17/93.09:40:36 BY $WC20SV
C
      SUBROUTINE PIN40(PO,LEFTP,IUSEP,CO,LEFTC,IUSEC,P,MP,LOCPL,ML)
C**************************************
C
C     THIS IS THE INPUT SUBROUTINE FOR THE 'WATERBAL' OPERATION. THE
C     FUNCTION OF THIS SUBROUTINE IS TO READ ALL INPUT CARDS, PERFORM
C     THE NECESSARY CHECKS AND FILL THE PO ARRAY.
C
C     THIS SUBROUTINE WAS INITIALLY WRITTEN BY:
C     ROBERT M. HARPER     HRL     MARCH, 1991
C**************************************
C
C     THE CONTENTS OF THE PO ARRAY ARE AS FOLLOWS:
C
C     POSITION                            CONTENTS
C
C        1              VERSION NUMBER OF THE OPERATION.
C
C       2-6             20 CHARACTER BASIN DESCRIPTION.
C
C       7-8             OBSERVED DISCHARGE TIME SERIES (MEAN DAILY)
C                       IDENTIFIER.
C
C        9              OBSERVED DISCHARGE TIME SERIES DATA TYPE.
C
C      10-11            SIMULATED DISCHARGE TIME SERIES (MEAN DAILY)
C                       IDENTIFIER.
C
C       12              SIMULATED DISCHARGE TIME SERIES DATA TYPE.
C
C       13              AREA (KM2)
C
C       14              NUMBER OF SUB-AREAS
C
C       15              FLAG TO DISPLAY YEARLY (WATER YEAR) WATER
C                       BALANCE.
C                       0 IF OFF, 1 IF ON.
C
C       16              RECORD NUMBER OF THE FIRST RECORD USED BY THIS
C                       OPERATION ON THE WATER YEAR SCRATCH FILE.
C
C       17              LOCATION OF FIRST SCRATCH FILE RECORD USED BY
C                       THE MULTI-YEAR ZONE CONTENTS DISPLAY OPTION.
C                       0 IF DISPLAY OPTION IS NOT SELECTED.
C
C      18-22            VACANT
C
C      23-27            SUB-AREA NAME
C
C       28              FRACTION OF AREA REPRESENTED.
C
C      29-30            SNOW OPERATION TYPE
C
C      31-32            SNOW OPERATION NAME
C
C       33              LOCATION OF WATER BALANCE SUMS AND MELT
C                       COMPONENTS IN THE PS ARRAY. 0 IF NO SUMS STORED.
C
C      34-35            RAINFALL-RUNOFF OPERATION TYPE
C
C      36-37            RAINFALL-RUNOFF OPERATION NAME
C
C       38              LOCATION OF SUMS OF WATER BALANCE, RUNOFF, AND
C                       ET COMPONENTS IN THE PL/PO ARRAY.
C                       0 IF NO SUMS STORED.
C
C       39              LOCATION OF PARAMETER VALUES IN THE PL/PO ARRAY.
C
C     * PO(23)-PO(39) ARE REPEATED FOR EACH OF THE BASIN SUB-AREAS.
C**************************************
C
      DIMENSION P(MP),PO(1),CO(1),LOCPL(ML)
      DIMENSION SNAME(2),IVALS(1),IVALR(2),OBSTS(2),SIMTS(2)
      DIMENSION BASNAM(5)
C
      INCLUDE 'common/fdbug'
      INCLUDE 'common/ionum'
      INCLUDE 'common/fwyds'
      INCLUDE 'common/fwydat'
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/calb/src/calb_waterbal/RCS/pin40.f,v $
     . $',                                                             '
     .$Id: pin40.f,v 1.2 1996/07/11 19:34:02 dws Exp $
     . $' /
C    ===================================================================
C
C
      DATA SNAME/'PIN4','0   '/
      DATA IVALS/19/
      DATA IVALR/1,24/
      DATA DIMS/'L3  '/
      DATA BLANK/'    '/
      DATA YES/'YES '/
C**************************************
C
      CALL FPRBUG(SNAME,1,40,IBUG)
C
C     SET DEFAULT VALUES
      LWY=0
      LZN=0
      LWB=0
C
C     SET INITIAL VALUES
      INTRVL=24
      IUSEP=0
      IUSEC=0
      NOMO=0
      NSAC=0
      ICHCKR=0
C**************************************
C
C     READ CARD 1
      READ(IN,900) BASNAM
  900 FORMAT(5A4)
C**************************************
C
C     READ CARD 2 - CHECK TIME SERIES
      READ(IN,910) OBSTS,OTYPE,SIMTS,STYPE,AREA,NOSUB,FLAGWB,FLAGZN
  910 FORMAT(2A4,2X,A4,2X,2A4,2X,A4,2X,F10.3,2X,I5,2X,A4,2X,A4)
      CALL CHEKTS(OBSTS,OTYPE,INTRVL,1,DIMS,1,1,IERR)
      CALL CHEKTS(SIMTS,STYPE,INTRVL,1,DIMS,0,1,IERR)
C
C     CHECK IF NUMBER OF SUBAREAS EXCEEDS AVAILABLE SPACE IN LOCPL.
      IF(NOSUB .LE. ML) GO TO 2
      WRITE(IPR,1060) NOSUB,ML
 1060 FORMAT(/,5X,'**ERROR** THE NUMBER OF SUBAREAS',I5,' EXCEEDS THE MA
     &XIMUM NUMBER OF SPACES ',I5,' IN ARRAY LOCPL')
      CALL ERROR
C***************************************
C
C     READ CARD 3 DIRECTLY INTO PO ARRAY - PERFORM NECESSARY CHECKS
    2 NEEDP=22+17*NOSUB
      CALL CHECKP(NEEDP,LEFTP,IERR)
      IF(IERR .EQ. 0) GO TO 5
      DO 10 I=1,NOSUB
        READ(IN,920) DUMMY
   10 CONTINUE
      GO TO 90
C
C     SPACE IS AVAILABLE - READ INFO INTO PO ARRAY - PERFORM CHECKS
    5 WEIGHT=0.0
      DO 20 I=1,NOSUB
        I1=23+(I-1)*17
        I6=I1+6
        I9=I1+9
        LSUMSN=I1+10
        I11=I1+11
        I14=I1+14
        LSUMRR=I1+15
        LPARM=I1+16
C
C       CHECK FOR SNOW MODEL
        READ(IN,920) (PO(N),N=I1,I9), (PO(N),N=I11,I14)
  920   FORMAT(5A4,2X,F5.3,2X,2A4,2X,2A4,2X,2A4,2X,2A4)
        IF(PO(I6) .EQ. BLANK) GO TO 30
        CALL FOPCDE(PO(I6),NUMSNW)
        IF(NUMSNW .GT. 0) GO TO 35
        WRITE(IPR,930) (PO(N), N=I6,I9)
  930   FORMAT(/,5X,'**ERROR** THIS OPERATION; ',2A4,1X,2A4,' DOES NOT E
     &XIST. CHECK OPERATION TYPE.')
        CALL ERROR
   35   DO 15 N=1,1
          IF(NUMSNW .EQ. IVALS(N)) GO TO 40
   15   CONTINUE
        WRITE(IPR,935) (PO(N),N=I6,I9)
  935   FORMAT(/,5X,'**ERROR** OPERATION; ',2A4,1X,2A4,' IS NOT A VALID
     &SNOW OPERATION FOR USE WITH THE WATERBAL OPERATION.')
        CALL ERROR
   40   IPS=0
        CALL FSERCH(NUMSNW,PO(I1+8),IPS,P,MP)
        IF(P(IPS+22) .GT. 1.0) GO TO 50
        PO(LSUMSN)=0.0
        WRITE(IPR,940) (PO(N),N=I6,I9)
  940   FORMAT(/,5X,'**ERROR** THE OPTION TO STORE SUMS HAS NOT BEEN TUR
     &NED ON FOR ',1X,2A4,1X,2A4)
        CALL ERROR
        GO TO 30
   50   K=P(IPS+22)
        PO(LSUMSN)=K
C
C       CHECK FOR RAINFALL-RUNOFF MODEL
   30   IF(PO(I1+11) .NE. BLANK) GO TO 60
        WRITE(IPR,950)
  950   FORMAT(/,5X,'**ERROR** THIS OPERATION CANNOT BE USED WITHOUT A R
     &AINFALL-RUNOFF MODEL')
        CALL ERROR
   60   CALL FOPCDE(PO(I1+11),NUMRR)
        IF(NUMRR .GT. 0) GO TO 63
        WRITE(IPR,960) PO(I1+11),PO(I1+12)
  960   FORMAT(/,5X,'**ERROR** THIS OPERATION DOES NOT EXIST. CHECK OPER
     &ATION IDENTIFIER',1X,2A4)
        CALL ERROR
   63   DO 65 N=1,2
          IF(NUMRR .EQ. 1) NSAC=1
          IF(NUMRR .EQ. IVALR(N)) GO TO 70
   65   CONTINUE
        WRITE(IPR,965) (PO(J),J=I11,I14)
  965   FORMAT(/,5X,'**ERROR** OPERATION; ',2A4,1X,2A4,' IS NOT A VALID
     &RAINFALL-RUNOFF OPERATION FOR USE WITH THE WATERBAL OPERATION.')
        CALL ERROR
        IF(NOSUB .LT. 2) GO TO 75
        IF(ICHCKR .EQ. NUMRR) GO TO 75
        WRITE(IPR,985)
  985   FORMAT(/,5X,'**ERROR** TWO DIFFERENT TYPES OF RAINFALL-RUNOFF MO
     &DELS MAY NOT BE USED WITH THIS OPERATION.')
   75   ICHCKR=NUMRR
   70   IPL=0
        CALL FSERCH(NUMRR,PO(I1+13),IPL,P,MP)
        LOCPL(I)=IPL
        IF(NUMRR .EQ. 24) GO TO 95
C
C       STORE PARAMETER LOCATION AND SUMS FOR SACRAMENTO MODEL.
        IF(P(IPL+17) .GT. 1.0) GO TO 80
        PO(LSUMRR)=0.0
        PO(LPARM)=IPL+19
        WRITE(IPR,970) (PO(N),N=I11,I14)
  970   FORMAT(/,5X,'**ERROR** THE OPTION TO STORE SUMS HAS NOT BEEN TUR
     &NED ON FOR',1X,2A4,1X,2A4)
        CALL ERROR
        GO TO 85
   80   J=P(IPL+17)
        JJ=P(IPL+19)
        PO(LSUMRR)=J
        PO(LPARM)=JJ
        GO TO 85
C
   95   IF(FLAGZN .NE. YES) GO TO 87
        WRITE(IPR,977)
  977   FORMAT(/,5X,'**ERROR** THE MULTI-YEAR ZONE CONTENTS DISPLAY MAY
     &ONLY BE USED WITH THE SACRAMNETO MODEL')
        CALL ERROR
C
C       STORE PARAMETER LOCATION AND SUMS FOR CONTINUOUS API MODEL.
   87   IF(P(IPL+31) .GT. 1.0) GO TO 97
        PO(LSUMRR)=0.0
        PO(LPARM)=IPL+19
        WRITE(IPR,975) (PO(N),N=I11,I14)
  975   FORMAT(/,5X,'**ERROR** THE OPTION TO STORE SUMS HAS NOT BEEN TUR
     &NED ON FOR',1X,2A4,1X,2A4)
        CALL ERROR
        GO TO 85
   97   J=P(IPL+31)
        JJ=P(IPL+25)
        PO(LSUMRR)=J
        PO(LPARM)=JJ
C
C       ADD ALL SUB-AREA WEIGHTS FOR LATER CHECK
   85   I5=I1+5
        WEIGHT=WEIGHT+PO(I5)
   20 CONTINUE
      IF ((WEIGHT.GT.0.999).AND.(WEIGHT.LT.1.001)) GO TO 90
      WRITE(IPR,980)
  980 FORMAT(/,5X,'**ERROR** THE SUM OF THE SUB-AREA WEIGHTS DOES NOT EQ
     &UAL 1.00')
      CALL ERROR
C**************************************
C
C     OBTAIN SCRATCH FILE INFORMATION
   90 NEEDWY=NOSUB*12
      IF(NSAC .NE. 1) GO TO 105
      IF(FLAGZN .EQ. YES) NEEDWY=NEEDWY+NOSUB
  105 LEFTWY=NTWY-NXWY+1
      IF(NEEDWY .LE. LEFTWY) GO TO 100
      WRITE(IPR,990) NEEDWY,LEFTWY
  990 FORMAT(/,5X,'**ERROR** THIS OPERATION NEEDS',I3,1X,'RECORDS ON THE
     & WATER YEAR SCRATCH FILE. ONLY',I4,1X,'ARE AVAILABLE.')
      CALL ERROR
      GO TO 110
C
C     SPACE IS AVAILABLE ON WATER YEAR SCRATCH FILE - STORE LOCATION OF
C     FIRST RECORD TO BE USED. STORE LOCATION OF FIRST RECORD NEEDED FOR
C     THE MULTI-YEAR AVERAGE ZONE CONTENTS DISPLAY, IF OPTION HAS BEEN
C     SELECTED.
  100 LWY=NXWY
      IF(NSAC .NE. 1) GO TO 110
      IF(FLAGZN .EQ. YES) LZN=NXWY+NOSUB*12
C**************************************
C
C     CHECK IF SPACE IS AVAILABLE FOR CO ARRAY - MULTI-YEAR DISPLAY FOR
C     ENTIRE AREA IS OPTIONAL ON A WATER YEAR BASIS.
  110 IF(NSAC .EQ. 1) GO TO 115
      NEEDC=7
      GO TO 125
  115 NEEDC=10
  125 IF(FLAGWB .NE. YES) GO TO 120
      NEEDC=NEEDC*2
      LWB=1
  120 CALL CHECKC(NEEDC,LEFTC,IERR)
      IF(IERR .EQ. 0) GO TO 130
      GO TO 180
C***************************************
C
C     ALL INPUT CARDS HAVE BEEN READ. STORE REMAINING VALUES IN PO ARRAY
  130 PO(1)=1.001
      DO 150 I=2,6
        K=I-1
  150   PO(I)=BASNAM(K)
      PO(7)=OBSTS(1)
      PO(8)=OBSTS(2)
      PO(9)=OTYPE
      PO(10)=SIMTS(1)
      PO(11)=SIMTS(2)
      PO(12)=STYPE
      PO(13)=AREA
      PO(14)=NOSUB+0.01
      PO(15)=LWB+0.01
      PO(16)=LWY+0.01
      PO(17)=LZN+0.01
      PO(18)=0.01
      PO(19)=0.01
      PO(20)=0.01
      PO(21)=0.01
      PO(22)=0.01
      IUSEP=NEEDP
C***************************************
C
C     INITIALIZE CO ARRAY TO MISSING INDICATOR
      DO 160 I=1,NEEDC
  160   CO(I)=0.001
      IUSEC=NEEDC
C
      IF(NSAC .LT. 1) GO TO 170
      IF(FLAGZN .NE. YES) GO TO 170
      NREC=LZN
C
C     INITIALIZE SCRATCH FILES TO BE USED BY THE MULTI-YEAR AVERAGE
C     ZONE CONTENTS DISPLAY TO THE APPROPRIATE VALUE. AVG=0.0, HI=0.0,
C     LO=PARAMETER.
C
      DO 174 I=1,NOSUB
        I1=23+(I-1)*17
        LPL=LOCPL(I)
        LPARM=LPL+PO(I1+16)-1
        UZTWM=P(LPARM+2)
        UZFWM=P(LPARM+3)
        XLZTWM=P(LPARM+10)
        XLZFSM=P(LPARM+11)
        XLZFPM=P(LPARM+12)
        DO 176 J=1,192,16
          WY(J)=0.0
          WY(J+1)=0.0
          WY(J+2)=UZTWM
          WY(J+3)=0.0
          WY(J+4)=0.0
          WY(J+5)=UZFWM
          WY(J+6)=0.0
          WY(J+7)=0.0
          WY(J+8)=XLZTWM
          WY(J+9)=0.0
          WY(J+10)=0.0
          WY(J+11)=XLZFSM
          WY(J+12)=0.0
          WY(J+13)=0.0
          WY(J+14)=XLZFPM
          WY(J+15)=0
  176   CONTINUE
C
C       DEBUG OUTPUT - PRINT INITIALIZED SCRATCH FILES USED IN MULTI-
C       YEAR AVERAGE ZONE CONTENTS DISPLAY. DEBUG SWITCH=1.
        IF(IBUG .EQ. 0) GO TO 175
        WRITE(IODBUG,1040) I
 1040   FORMAT(/5X,'INITIALIZED SCRATCH FILES USED BY MULTI-YEAR AVERAGE
     & ZONE CONTENTS DISPLAY. SUBAREA NO.',I5)
        WRITE(IODBUG,1050) (WY(L),L=1,192)
 1050   FORMAT(5X,F6.2,1X,F6.2,1X,F6.2,1X,F6.2,1X,F6.2,1X,F6.2,1X,F6.2,
     &1X,F6.2,1X,F6.2,1X,F6.2,1X,F6.2,1X,F6.2,1X,F6.2,1X,F6.2,1X,F6.2,1X
     &,I3)
C
  175   WRITE(IRWY,REC=NREC) WY
        NREC=NREC+1
  174 CONTINUE
C
C     INCREMENT NEXT AVAILABLE RECORD LOCATION ON SCRATCH FILE.
  170 NXWY=NXWY+NEEDWY
C
C     ALL ENTRIES HAVE BEEN MADE
C***************************************
C
C     DEBUG OUTPUT - PRINT PO ARRAY - DEBUG SWITCH=1
      IF(IBUG .EQ. 0) GO TO 180
      WRITE(IODBUG,1000) IUSEP
 1000 FORMAT(/,5X,'PIN40 DEBUG-CONTENTS OF THE PO ARRAY. NUMBER OF VALUE
     &S =',I3)
      WRITE(IODBUG,1005)
 1005 FORMAT(/,5X,'THE CONTENTS OF PO(1-11)')
      WRITE(IODBUG,1010) (PO(I),I=1,11)
 1010 FORMAT(5X,F5.0,2X,A4,2X,A4,2X,A4,2X,A4,2X,A4,2X,A4,2X,A4,2X,A4,2X,
     &A4,2X,A4)
      WRITE(IODBUG,1015)
 1015 FORMAT(/,5X,'THE CONTENTS OF PO(12-22)')
      WRITE(IODBUG,1020) (PO(I),I=12,22)
 1020 FORMAT(5X,A4,2X,F10.1,2X,F5.0,2X,F5.0,2X,F5.0,2X,F5.0,2X,F5.0,2X,F
     &5.0,2X,F5.0,2X,F5.0,2X,F5.0)
      DO 190 I=1,NOSUB
        I1=23+(I-1)*17
        LPARM=I1+16
        WRITE(IODBUG,1025)
 1025   FORMAT(/5X,'THE CONTENTS OF PO(23-39) REPEATED FOR EACH SUBAREA'
     &)
        WRITE(IODBUG,1030) (PO(N),N=I1,LPARM)
 1030   FORMAT(5X,A4,2X,A4,2X,A4,2X,A4,2X,A4,2X,F5.2,2X,A4,2X,A4,2X,A4,2
     &X,A4,2X,F5.0,/,5X,A4,2X,A4,2X,A4,2X,A4,2X,F5.0,2X,F5.0)
  190 CONTINUE
C***************************************
C
C     TRACE LEVEL=1
  180 IF(ITRACE .GE. 1) WRITE(IODBUG,1500) SNAME
 1500 FORMAT(/1X,'** ',2A4,' EXITED')
C
      RETURN
      END
