      SUBROUTINE REDDAM55(K,J,KRA,HDD,CLL,HSPD,SPL,CRESL,HCRESL,CSD,
     * HGTD,CGD,CDOD,QTD,HFDD,TFH,BBD,ZBCH,YBMIN,RHI,RQI,TCG,QGH,CGCG,
     * QHT,NG,LAD,ICG,NFAILD,DTHDB,BREXP,CPIP,TIBQH,NUMLAD,GSIL,GWID,
     * TGHT,GHT,DTFMN,DTIN,NU,QTT,TQT,ICHAN,PTAR,CHTW,GZPL,POLH,ITWT,
     * SAR,HSAR,IRES,NODESC,LQTT,LTQT,IERR,K1,K3,K16,K19,K20,
     * K21,IUSEW,NRC)

      CHARACTER*80 DESC

      COMMON/GT55/KCG,NCG
      COMMON/M655/KTIME,DTHYD,J1
      COMMON/M3255/IOBS,KTERM,KPL,JNK,TEH
      COMMON/METR55/METRIC
      COMMON/TKEP55/DTHII,MDT,NDT,DTHS,TFH1
      COMMON/IDOS55/IDOS,IFCST
      COMMON/FDBUG/IODBUG,ITRACE,IDBALL,NDEBUG,IDEBUG(20)
      COMMON/IONUM/IN,IPR,IPU

      DIMENSION HDD(K16,K1),CLL(K16,K1),HSPD(K16,K1),SPL(K16,K1)
      DIMENSION CRESL(8,K16,K1),HCRESL(8,K16,K1),CSD(K16,K1)
      DIMENSION HGTD(K16,K1),CGD(K16,K1),CDOD(K16,K1),QTD(K16,K1)
      DIMENSION HFDD(K16,K1),TFH(K16,K1),BBD(K16,K1),ZBCH(K16,K1)
      DIMENSION YBMIN(K16,K1),RHI(112,K16,K1),RQI(112,K16,K1)
      DIMENSION TCG(K21,K16,K1),QGH(K21,K16,K1),CGCG(K21,K16,K1)
      DIMENSION QHT(8,8,K16,K1),NG(K16,K1),LAD(K16,K1),ICG(K16,K1)
      DIMENSION NFAILD(K16,K1),DTHDB(K16,K1),BREXP(K16,K1),CPIP(K16,K1)
      DIMENSION TIBQH(K16,K1),NUMLAD(K1),DTIN(1)
      DIMENSION GSIL(K19,K20,K1),GWID(K19,K20,K1)
      DIMENSION TGHT(K21,K19,K20,K1),GHT(K21,K19,K20,K1)
      DIMENSION QTT(1),TQT(1),ICHAN(K16,K1),PTAR(K16,K1)
      DIMENSION CHTW(K16,K1),POLH(1),ITWT(1)
      DIMENSION SAR(8,K16,K1),HSAR(8,K16,K1),GZPL(K16,K1)
      DIMENSION LQTT(K16,K1),LTQT(K16,K1)
      CHARACTER*8  SNAME
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcinit_fldwav/RCS/reddam55.f,v $
     . $',                                                             '
     .$Id: reddam55.f,v 1.4 2004/09/23 19:44:26 wkwock Exp $
     . $' /
C    ===================================================================
C

      DATA   SNAME / 'REDDAM55' /

      CALL FPRBUG(SNAME, 1, 55, IBUG)

C  THIS SUBROUTINE READS DAM PARAMETERS INCLUDING RESERVIOR
C  HDD= ELEV. OF NON-SPILLWAY CREST OF DAM
C  CLL= LENGTH OF NON-SPILLWAY CREST OF DAM
C  CDOD= DISCHARGE COEFF. OF NON-SPILLWAY CREST OF DAM
C  QTD= TURBINE FLOW (CONSTANT)
C  QTT= VARIABLE TURBINE FLOW
C  TQT= TIME OF QTT
C  TIBQH= COE RES. OPTION TIME TO CHANGE Q-RATING TO H-RATING
C  ICG= 0, NO GATE; 2, MULTIPLE GATE; 1, AVERAGE GATE FROM COE
C  HSPD= ELEV. OF SPILLWAY CREST OF DAM
C  SPL= LENGTH OF SPILLWAY CREST OF DAM
C  CSD= DISCH. COEFF. OF SPILLWAY OF DAM
C  HGTD= ELEV. OF CENTER OF GATE
C  CGD= GATE COEFF. * GATE OPENING AREA
C  GSIL= ELEV OF GATE SILL (MULGAT)
C  GWID= GATE WIDTH ASSOCIATED WITH GSIL (MULGAT)
C  TGHT= TIME OF MOVEABLE GATE CURVE (MULGAT)
C  GHT= GATE HEIGHT ABOVE SILL ASSOCIATED W/TGHT (MULGAT)
C  TCG= TIME OF MOVEABLE GATE CURVE (AVGGAT)
C  CGCG= TOTAL MOVABLE GATE WIDTH ASSOCIATED W/TCG (AVGGAT)
C  CRESL= CREST LENGTH FOR NON-LEVEL DAM
C  HCRESL= ELEV ASSOCIATED W/CRESL
C  ICHAN= CHANNEL FLOW SWITCH OPTION (0/1 WITH/WITHOUT)
C  PTAR= RES. POOL TARGET ELEVATION
C  CHTW= TAIL-WATER FOR CHANNEL FLOW SWITCHING
C  POLH= POOL ELEVATION TIME SERIES
C  ITWT= CHANNEL FLOW SWITCH TIME SERIES
C
C      KRA=10  DAM
C      KRA=11  DAM  +  Q=F(Y)
C      KRA=21  DAM  +  Y=F(Q)
C      KRA=12  DAM  +  Q=F(YY)
C      KRA=22  DAM  +  YY=F(Q)
C      KRA=13  DAM  +  Q=F(Y-YY)
C      KRA=23  DAM  +  Y-YY=F(Q)
C      KRA=14  DAM  +  MULGAT (MULTIPLE MOVEABLE GATES)
C      KRA=15  DAM  +  AVGGAT (MOVEABLE GATE-CORPS ENGR. TYPE)
C      KRA=16  DAM  +  Q=F(Y), Y=F(T); OBSERVED POOL ELEV. AVAILABLE
C      KRA=17  DAM  +  Q=F(C,Y-YY)  C=F(Y)
C      KRA=18  DAM  +  CULVERT FLOW USING INPUT RATING CURVE Q=F(Y,YY)
C                      FOR THE CULVERT
C      KRA=19  DAM  +  CULVERT FLOW USING INPUTED CULVERT RELATED DATA
C      KRA=25  DAM  +  Y=F(T)
C      KRA=26  DAM  +  Q=F(T)
C      KRA=27  DAM  +  COE RESERVOIR CONTROL OPERATION
C      KRA=28  DAM  +  READ IN POOL ELEVATION TIME SERIES (POLH)

      IERR=0
      TOL=0.000001
      NUM=NUMLAD(J)
      NFAILD(K,J)=1
C.......................................................................
C     LAD   --  REACH NUMBER CORRESPONDING TO INTERNAL BOUNDARY
C     HDD   --  ELEVATION OF TOP DAM
C     CLL   --  DAM CREST LENGTH < THE LENGTH OF SPILLWAY AND GATES
C     CDOD  --  COEFFICIENT FOR UNCONTROLLED WEIR FLOW OVER THE DAM
C     QTD   --  DISCHARGE THROUGH TURBINES
C.......................................................................
      IF(KRA.GE.10.AND.KRA.LE.30) GO TO 100
C      KRA=10,11,21,12,22,13,23,14,15,16,17,18,19,25,26,28

  100 READ(IN,'(A)',END=1000) DESC
      READ(IN,*)LAD(K,J),HDD(K,J),CLL(K,J),CDOD(K,J),QTD(K,J),ICHAN(K,J)
      IF(NODESC.EQ.0)THEN
      IF(IBUG.EQ.1)
     . WRITE(IODBUG,808)LAD(K,J),HDD(K,J),CLL(K,J),CDOD(K,J),QTD(K,J),
     .  ICHAN(K,J)
  808 FORMAT(//
     .10X,'REACH NUMBER CORRESPONDING TO INTERNAL BOUNDARY  LAD',2X,I10/
     .10X,'ELEVATION OF TOP DAM                             HDD',2X,
     .F10.2/10X,'DAM CREST LENGTH                                 CLL',2
     .X,F10.2/10X,'COEFFICIENT FOR UNCONTROLLED WEIR FLOW           CDOD
     .',1X,F10.2/10X,'DISCHARGE THROUGH TURBINES                       Q
     .TD',2X,F10.2/10X,'CHANNEL CONTROL SWITCH
     . ICHAN',I10/)
      ELSE
      IF(IBUG.EQ.1)
     . WRITE(IODBUG,11)LAD(K,J),HDD(K,J),CLL(K,J),CDOD(K,J),QTD(K,J),
     .  ICHAN(K,J)
      ENDIF
C.......................................................................
C     ICG   --  PARAMETER FOR TYPE OF GATE STRUCTURE
C     HSPD  --  ELEVATION OF UNCONTROLLED SPILLWAY CREST
C     SPL   --  CREST LENGTH OF UNCONTROLLED SPILLWAY
C     CSD   --  DISCHARGE COEFFICIENT OF UNCONTROLLED SPILLWAY
C     HGTD  --  ELEVATION OF CENTER OF GATE OPENINGS
C     CGD   --  DISCHARGE COEFFICIENT FOR GATE FLOW
C.......................................................................
      READ(IN,'(A)',END=1000) DESC
      READ(IN,*) ICG(K,J),HSPD(K,J),SPL(K,J),CSD(K,J),HGTD(K,J),CGD(K,J)
      IF(NODESC.EQ.0)THEN
      IF(IBUG.EQ.1)
     * WRITE(IODBUG,816)ICG(K,J),HSPD(K,J),SPL(K,J),CSD(K,J),HGTD(K,J),
     *CGD(K,J)
  816 FORMAT(/
     .10X,'PARAMETER FOR TYPE OF GATE STRUCTURE             ICG',2X,I10/
     .10X,'ELEVATION OF UNCONTROLLED SPILLWAY CREST         HSPD',1X,
     .F10.2/10X,'CREST LENGTH OF UNCONTROLLED SPILLWAY            SPL',2
     .X,F10.2/10X,'DISCHARGE COEFFICIENT OF UNCONTROLLED SPILLWAY   CSD'
     .,2X,F10.2/10X,'ELEVATION OF CENTER OF GATE OPENINGS             HG
     .TD',1X,F10.2/10X,'DISCHARGE COEFFICIENT FOR GATE FLOW',14X,
     .'CGD',2X,F10.2)
      ELSE
      IF(IBUG.EQ.1)
     * WRITE(IODBUG,12) ICG(K,J),HSPD(K,J),SPL(K,J),CSD(K,J),HGTD(K,J),
     *CGD(K,J)
      ENDIF
      IF(CLL(K,J).GT.0.1.OR.HDD(K,J).LE.0.) GO TO 90
C......................................................................
C     HCRESL--  ELEVATION ASSOCIATED WITH VARIABLE LENGTH OF DAM CREST
C     CRESL --  VARIABLE LENGTH OF DAM CREST FOR A GIVEN ELEVATION
C......................................................................
      READ(IN,'(A)',END=1000) DESC
      READ(IN,*) (HCRESL(L,K,J),L=1,8)
      IF(NODESC.EQ.0)THEN
      IF(IBUG.EQ.1) WRITE(IODBUG,703)
  703 FORMAT(//9X,
     .'HCRESL = ELEVATION ASSOCIATED WITH VARIABLE LENGTH OF DAM CREST'
     ./9X,'CRESL  = VARIABLE LENGTH OF DAM CREST FOR A GIVEN ELEVATION'
     .//)
      IF(IBUG.EQ.1) WRITE(IODBUG,16) (HCRESL(L,K,J),L=1,8)
      ELSE
        IF(IBUG.EQ.1) WRITE(IODBUG,116) K,J,(HCRESL(L,K,J),L=1,8)
  116   FORMAT(5X,'HCRESL(L,',I2,',',I2,'), L=1,8'/8F10.2)
      ENDIF
      READ(IN,'(A)',END=1000) DESC
      READ(IN,*) (CRESL(L,K,J),L=1,8)
      IF(NODESC.EQ.0)THEN
        IF(IBUG.EQ.1) WRITE(IODBUG,15) (CRESL(L,K,J),L=1,8)
      ELSE
        IF(IBUG.EQ.1) WRITE(IODBUG,115) K,J,(CRESL(L,K,J),L=1,8)
  115   FORMAT(5X,'CRESL(L,',I2,',',I2,'), L=1,8'/8F10.2)
      ENDIF

C......................................................................
C  QTT  = VARIABLE TURBINE FLOW
C  TQT  = TIME OF QTT
C  LQTT = LOCATOR OF QTT
C  LTQT = LOCATOR OF TQT
C......................................................................
   90 IF (QTD(K,J).GE.0.0) GOTO 101
      IF(IDOS.GE.3) THEN
        WRITE(IPR,1022)
        CALL ERROR
        IERR=1
        GOTO 9000
      ENDIF
      LQTT(K,J)=IUSEW
      READ(IN,'(A)',END=1000) DESC
      READ(IN,*) (QTT(IUSEW+L-1),L=1,NU)
      IF(NODESC.EQ.0)THEN
        IF(IBUG.EQ.1) WRITE(IODBUG,95)
   95   FORMAT(//10X,
     .   'QTD = VARIABLE FLOW THROUGH TURBINES'/10X,
     .   'TQT = TIME ASSOCIATED WITH VARIABLE FLOW THROUGH TURBINES'//)
        IF(IBUG.EQ.1) WRITE(IODBUG,17) (QTT(IUSEW+L-1),L=1,NU)
      ELSE
        IF(IBUG.EQ.1) WRITE(IODBUG,117) K,J,(QTT(IUSEW+L-1),L=1,NU)
  117   FORMAT(5X,'QTT(L,',I2,',',I2,'), L=1,NU',100(/8F10.2))
      ENDIF
      IUSEW=IUSEW+NU

      LTQT(K,J)=IUSEW
        READ(IN,'(A)',END=1000) DESC
      READ(IN,*) (TQT(IUSEW+L-1),L=1,NU)
      IF(NODESC.EQ.0) THEN
        IF(IBUG.EQ.1) WRITE(IODBUG,18) (TQT(IUSEW+L-1),L=1,NU)
      ELSE
        IF(IBUG.EQ.1) WRITE(IODBUG,118) K,J,(TQT(IUSEW+L-1),L=1,NU)
  118   FORMAT(5X,'TQT(L,',I2,',',I2,'), L=1,NU',100(/8F10.2))
      ENDIF
        IUSEW=IUSEW+NU
  101 CONTINUE

      IF(KRA.EQ.10) GO TO 130
      IF(KRA.EQ.14) GO TO 30
      IF(KRA.EQ.15) GO TO 105
      IF(KRA.EQ.18.OR.KRA.EQ.19) GO TO 112
CC      IF(KRA.EQ.18) GO TO 112
C      IF(KRA.EQ.19) GO TO 115
      IF(KRA.EQ.25.OR.KRA.EQ.26) GO TO 120
      IF(KRA.EQ.27) GO TO 121
      IF(KRA.EQ.28) GO TO 125

C      KRA=11,21,12,22,13,23,16,17
C.......................................................................
C     RHI   --  HEAD ABOVE SPILLWAY CREST OR GATE CENTER
C     RQI   --  DISCHARGE IN SPILLWAY OR GATE RATING CURVE
C.......................................................................
      IF(IDOS.GE.3) THEN
        NRC=NRC+1
        GOTO 130
      ENDIF
      NRCP=8
      READ(IN,'(A)',END=1000) DESC
      READ(IN,*)  (RHI(L,K,J),L=1,NRCP)
      IF(NODESC.EQ.0)THEN
        IF(IBUG.EQ.1) WRITE(IODBUG,704)
  704   FORMAT(//20X,'SPILLWAY HEAD-DISCHARGE TABLE'/)
        IF(IBUG.EQ.1) WRITE(IODBUG,1002) (RHI(L,K,J),L=1,NRCP)
 1002   FORMAT(/7X,'RHI: ',(8F10.2))
      ELSE
        IF(IBUG.EQ.1) WRITE(IODBUG,1012) K,J,(RHI(L,K,J),L=1,NRCP)
 1012   FORMAT(5X,'RHI(L,',I2,',',I2,'), L=1,8'/8F10.2)
      ENDIF
      READ(IN,'(A)',END=1000) DESC
      READ(IN,*)  (RQI(L,K,J),L=1,NRCP)
      IF(NODESC.EQ.0) THEN
        IF(IBUG.EQ.1) WRITE(IODBUG,1003) (RQI(L,K,J),L=1,NRCP)
 1003   FORMAT(7X,'RQI: ',(8F10.2))
      ELSE
        IF(IBUG.EQ.1) WRITE(IODBUG,1013) K,J,(RQI(L,K,J),L=1,NRCP)
 1013   FORMAT(5X,'RQI(L,',I2,',',I2,'), L=1,8'/8F10.2)
      ENDIF

      HTEMP=0.0
      DO 180 L=1,NRCP
      TEMP=ABS(RHI(L,K,J))
      IF(HSPD(K,J).GE.0.1.AND.SPL(K,J).LE.0.001) HTEMP=HSPD(K,J)
      IF(HGTD(K,J).GE.0.1.AND.CGD(K,J).LE.0.001) HTEMP=HGTD(K,J)
      RHI(L,K,J)=RHI(L,K,J)+HTEMP
      IF(L.GE.2.AND.TEMP.LE.0.0001) RHI(L,K,J)=0.0
180   CONTINUE
      IF(KRA.LT.21 .OR. KRA.GT.23) GO TO 205

C  FLIP FLOP RHI AND RQI
      DO 200 L=1,NRCP
      DUM=RHI(L,K,J)
      RHI(L,K,J)=RQI(L,K,J)
      RQI(L,K,J)=DUM
200   CONTINUE
C  FILL IN ZERO VALUES BY LINEAR EXTRA-POLATION
  205 IF(HSPD(K,J).LT.0.001) HSPD(K,J)=RHI(1,K,J)
      RHA=ABS(RHI(NRCP,K,J))
      IF(RHA.GT.0.001) GO TO 218
      DO 211 L=1,NRCP
      LT=8-L+1
      RHA=ABS(RHI(LT,K,J))
      IF(RHA.GT.0.001) GO TO 212
  211 CONTINUE

C  ANALYTICAL CURVE USED! NO FILL IN NEEDED
      GO TO 218
  212 LTM=LT-1
      LT1=LT+1
      DO 213 L=LT1,8
      RHI(L,K,J)=RHI(LT,K,J)+L-LT
      XR=0.0
      DH=RHI(LT,K,J)-RHI(LTM,K,J)
      IF(ABS(DH).GE.0.01) XR=(L-LT)/DH
      RQI(L,K,J)=RQI(LT,K,J)+(RQI(LT,K,J)-RQI(LTM,K,J))*XR
  213 CONTINUE
  218 IF(KRA.EQ.16) GO TO 105
      IF(KRA.NE.14) GO TO 130

C      KRA=14
C.......................................................................
C     GSIL  --  ELEV OF GATE SILL (MULGAT)
C     TGHT  --  TIME OF MOVEABLE GATE CURVE (MULGAT)
C     GHT   --  GATE HEIGHT ABOVE SILL ASSOCIATED W/TGHT (MULGAT)
C.......................................................................
   30 IF (ICG(K,J).NE.2) GOTO 130
      IF(IDOS.GE.3) THEN
        WRITE(IPR,1024)
        CALL ERROR
        IERR=1
        GOTO 9000
      ENDIF
      READ(IN,'(A)',END=1000) DESC
      READ(IN,*) NG(K,J)
      NCG=NG(K,J)
      IF(NODESC.EQ.0.AND.IBUG.EQ.1) THEN
      WRITE(IODBUG,'(/5X,40HMULTIPLE MOVEBLE GATES DATA WHEN ICG = 2)')
      WRITE(IODBUG,'(5X,22HNUMBER OF GATES   NG =,I2)') NG(K,J)
        WRITE(IODBUG,601)
  601   FORMAT(/
     .  10X,'GSIL  --  ELEV OF GATE SILL (MULGAT)'/
     .  10X,'TGHT  --  TIME OF MOVEABLE GATE CURVE (MULGAT)'/
     .  10X,'GHT   --  GATE HEIGHT ABOVE SILL ASSOCIATED W/TGHT'/)
      ELSE
        IF(IBUG.EQ.1) WRITE(IODBUG,32) K,J,NG(K,J)
   32   FORMAT(5X,'NG(',I2,',',I2,')'/I10)
      ENDIF

      DO 102 L=1,NCG
      READ(IN,'(A)',END=1000) DESC
      READ(IN,*) GSIL(L,K,J),GWID(L,K,J)
      IF(NODESC.EQ.0) THEN
      IF(IBUG.EQ.1) WRITE(IODBUG,'(/5X,5HGATE ,I2)') L
      IF(IBUG.EQ.1) WRITE(IODBUG,'(5X,6HGSIL =,F8.2,7X,6HGWID =,F8.2)')
     .          GSIL(L,K,J),GWID(L,K,J)
      ELSE
        IF(IBUG.EQ.1) WRITE(IODBUG,'(/6X,4HGSIL,6X,4HGWID/2F10.2)')
     .          GSIL(L,K,J),GWID(L,K,J)
      ENDIF

      READ(IN,'(A)',END=1000) DESC
      READ(IN,*) (TGHT(I,L,K,J),I=1,KCG)
      IF(NODESC.EQ.0) THEN
      IF(IBUG.EQ.1) WRITE(IODBUG,'(5X,6HTGHT =,8F10.2)')
     *(TGHT(I,L,K,J),I=1,KCG)
      ELSE
      IF(IBUG.EQ.1)
     .WRITE(IODBUG,'(5X,6HTGHT(I,I2,1H,,I2,1H,,I2,9H) I=1,KCG,
     .30(/8F10.2))') L,K,J,(TGHT(I,L,K,J),I=1,KCG)
      ENDIF

      READ(IN,'(A)',END=1000) DESC
      READ(IN,*) (GHT(I,L,K,J),I=1,KCG)
      IF(NODESC.EQ.0) THEN
      IF(IBUG.EQ.1) WRITE(IODBUG,'(5X,6H GHT =,8F10.2)')
     .  (GHT(I,L,K,J),I=1,KCG)
      ELSE
      IF(IBUG.EQ.1)
     . WRITE(IODBUG,'(5X,6HGHT(I,,I2,1H,,I2,1H,,I2,9H) I=1,KCG,
     . 30(/8F10.2))') L,K,J,(GHT(I,L,K,J),I=1,KCG)
      ENDIF
  102 CONTINUE
      GO TO 130

C      KRA=15,16
C.......................................................................
C     TCG   --  TIME OF MOVEABLE GATE CURVE (AVGGAT)
C     QGH   --  OBSERVED WSEL OR DISCHARGE HYDROGRAPH AT THE DAM
C     CGCG  --  TOTAL MOVABLE GATE WIDTH ASSOCIATED W/TCG (AVGGAT)
C.......................................................................
  105 IF(IDOS.GE.3) THEN
        WRITE(IPR,1024)
        CALL ERROR
        IERR=1
        GOTO 9000
      ENDIF
      IF(NODESC.EQ.0) THEN
        IF(IBUG.EQ.1) WRITE(IODBUG,602)
  602   FORMAT(/10X,
     .   'TCG  - TIME OF MOVEABLE GATE CURVE (AVGGAT)'/10X,
     .   'QGH  - OBSERVED WSEL OR DISCHARGE HYDROGRAPH AT THE DAM'/10X,
     .   'CGCG - TOTAL MOVABLE GATE WIDTH ASSOCIATED W/TCG (AVGGAT)'/)
      ENDIF
      READ(IN,'(A)',END=1000) DESC
      READ(IN,*)  (TCG(L,K,J),L=1,KCG)
      IF(IBUG.EQ.1) WRITE(IODBUG,500) K,J
  500 FORMAT(/5X,'(TCG(L,',I2,',',I1,'), L=1,KCG)')
      IF(IBUG.EQ.1) WRITE(IODBUG,1001) (TCG(L,K,J),L=1,KCG)

      READ(IN,'(A)',END=1000) DESC
      READ(IN,*)  (QGH(L,K,J),L=1,KCG)
      IF(IBUG.EQ.1) WRITE(IODBUG,502) K,J
  502 FORMAT(/5X,'(QGH(L,',I2,',',I1,'), L=1,KCG)')
      IF(IBUG.EQ.1) WRITE(IODBUG,1001) (QGH(L,K,J),L=1,KCG)

      IF (KRA.EQ.15) THEN
        READ(IN,'(A)',END=1000) DESC
        READ(IN,*)  (CGCG(L,K,J),L=1,KCG)
        IF(IBUG.EQ.1) WRITE(IODBUG,504) K,J
  504   FORMAT(/5X,'(CGCG(L,',I2,',',I1,'), L=1,KCG)')
        IF(IBUG.EQ.1) WRITE(IODBUG,1001) (CGCG(L,K,J),L=1,KCG)
      ENDIF
      GO TO 130

C      KRA=16
  107 READ(IN,'(A)',END=1000) DESC
      READ(IN,*)  (QGH(L,K,J),L=1,KCG)
      IF(IBUG.EQ.1) WRITE(IODBUG,502) K,J
      IF(IBUG.EQ.1) WRITE(IODBUG,1001) (QGH(L,K,J),L=1,KCG)
      GO TO 130

C     KRA=18
C......................................................................
C     QHT   --  DUMMY VARIABLE
C     RHI   --  HEAD ABOVE SPILLWAY CREST OR GATE CENTER
C.......................................................................
  112 DO 113 L=1,8
      READ(IN,'(A)',END=1000) DESC
      READ(IN,*) (QHT(I,L,K,J),I=1,8)
      IF(IBUG.EQ.1)
     . WRITE(IODBUG,'(5X,6HQHT(I,,I2,1H,,I2,1H,,I2,8H), I=1,8)') L,K,J
      IF(IBUG.EQ.1) WRITE(IODBUG,1001) (QHT(I,L,K,J),I=1,8)
  113 CONTINUE
      READ(IN,'(A)',END=1000) DESC
      READ(IN,*)  (RHI(L,K,J),L=1,8)
      IF(IBUG.EQ.1)
     . WRITE(IODBUG,'(5X,6HRHI(I,,I2,1H,,I2,1H,,I2,8H), I=1,8)') L,K,J
      IF(IBUG.EQ.1) WRITE(IODBUG,1001) (RHI(L,K,J),L=1,8)
      GO TO 130

C    KRA=19  (CULVERT FLOW)  NOT AVAILABLE NOW
C     GO TO 130

C      KRA=25,26
C.......................................................................
C     TCG   --  TIME ASSOCIATED WITH CGCG
C     QGH   --  DISTANCE FROM BOTTOM OF GATE TO GATE SILL
C.......................................................................
  120 IF(IDOS.GE.3) THEN
        WRITE(IPR,1024)
        CALL ERROR
        IERR=1
        GOTO 9000
      ENDIF
      READ(IN,'(A)',END=1000) DESC
      READ(IN,*)  (TCG(L,K,J),L=1,KCG)
      IF(IBUG.EQ.1)
     . WRITE(IODBUG,'(5X,6HTCG(L,,I2,1H,,I2,10H), L=1,KCG)') K,J
      IF(IBUG.EQ.1) WRITE(IODBUG,1001) (TCG(L,K,J),L=1,KCG)
      READ(IN,'(A)',END=1000) DESC
      READ(IN,*)  (QGH(L,K,J),L=1,KCG)
      IF(IBUG.EQ.1)
     . WRITE(IODBUG,'(5X,6HQGH(L,,I2,1H,,I2,10H), L=1,KCG)') K,J
      IF(IBUG.EQ.1) WRITE(IODBUG,1001) (QGH(L,K,J),L=1,KCG)
      GO TO 130

C    KRA=27
C.......................................................................
C     TIBQH --  COE RES. OPTION TIME TO CHANGE Q-RATING TO H-RATING
C.......................................................................
  121 IF(IDOS.GE.3) THEN
        WRITE(IPR,1026)
        CALL ERROR
        IERR=1
        GOTO 9000
      ENDIF
      READ(IN,'(A)',END=1000) DESC
      READ(IN,*) TIBQH(K,J)
      IF(IBUG.EQ.1) WRITE(IODBUG,'(/5X,6HTIBQH(,I2,1H,,I2,1H))') K,J
      IF(IBUG.EQ.1) WRITE(IODBUG,1001) TIBQH(K,J)
      GOTO 130

C    KRA=28  POOL ELEVATION TIME SERIES READ (PTAR,CHTW,POLH,ITWT)
C.......................................................................
C  PTAR - TARGET POOL ELEVATION FOR LOCK & DAM OPTION
C  CHTW - CRITICAL TAILWATER ELEVATION (+) OR DISCHARGE (-)
C  GZPL - GAGE ZERO FOR POOL STAGE T.S.
C  POLT - POOL STAGE TIME SERIES
C  ITWT - POOL/CHANNEL SWITCH TIME SERIES
C    =0   POOL/CHANNEL AUTOMATICAL SWITCHING BASED ON TAILWATER CONDITION
C    =1   FORCE MODEL TO SWITCH OR KEEP CHANNEL CONDITION
C    =2   FORCE MODEL TO SWITCH OR KEEP POOL-IN-CONTROL
C.......................................................................
C  ICHAN=0 ONLY READ IN POLT, ITWT SET TO ZERO AS DEFAULT
C  ICHAN=1 ALSO READ IN CHANNEL SWITCH CONTROL T.S. (ITWT)
C  ICHAN=2 READ IN H=f(Q) RATING (8 PAIRS), NO POLT/ITWT NEEDED
C  ICHAN=3 POLT/ITWT USING DEFAULT VALUE (PTAR/0), READ NOTHING
  125 SL=1.0
      SQ=1.0
      IF (METRIC.EQ.1) SL=3.281
      IF (METRIC.EQ.1) SQ=35.32
      READ(IN,'(A)',END=1000) DESC
      READ(IN,*) PTAR(K,J),CHTW(K,J),GZPL(K,J)
      IF(NODESC.EQ.0) THEN
      IF(IBUG.EQ.1) WRITE(IODBUG,19) PTAR(K,J),CHTW(K,J),GZPL(K,J)
   19 FORMAT(/10X,
     .'TARGET POOL ELEVATION FOR LOCK & DAM          PTAR  ',F10.2/10X,
     .'CRITICAL TAILWATER ELEVATION FOR LOCK & DAM   CHTW  ',F10.2/10X,
     .'POOL ELEVATION GAGE ZERO                      GZPL',2X,F10.2/)
      ELSE
      IF(IBUG.EQ.1)
     . WRITE(IODBUG,'(/6X,4HPTAR,6X,4HCHTW,6X,4HGZPL/3F10.2)')
     . PTAR(K,J),CHTW(K,J), GZPL(K,J)
      ENDIF

  130 CONTINUE
C.......................................................................
C     TFH   --  TIME OF FAILURE OF THE STRUCTURE
C     DTHDB --  COMPUTATIONAL TIME STEP AFTER DAM/BRIDGE FAILURE
C     HFDD  --  ELEVATION OF WATER WHEN DAM FAILURE COMMENCES
C     BBD   --  FINAL WIDTH AT BOTTOM OF BREACH
C     ZBCH  --  SLIDE SLOPE OF BREACH
C     YBMIN --  LOWEST ELEVATION THAT BOTTOM BREACH REACHES
C     BREXP --  EXPONENT USED IN DEVELOPMENT OF BREACH
C     CPIP  --  CENTERLINE ELEVATION OF PIPING BREACH
C.......................................................................
      READ(IN,'(A)',END=1000) DESC
      READ(IN,*) TFH(K,J),DTHDB(K,J),HFDD(K,J),BBD(K,J),ZBCH(K,J),
     1YBMIN(K,J),BREXP(K,J),CPIP(K,J)
      IF(NODESC.EQ.1)THEN
      IF(IBUG.EQ.1)
     .WRITE(IODBUG,13) TFH(K,J),DTHDB(K,J),HFDD(K,J),BBD(K,J),ZBCH(K,J),
     1 YBMIN(K,J),BREXP(K,J),CPIP(K,J)
      ELSE
      IF(IBUG.EQ.1) WRITE(IODBUG,2213) TFH(K,J),DTHDB(K,J),HFDD(K,J),
     . BBD(K,J),ZBCH(K,J),YBMIN(K,J),BREXP(K,J),CPIP(K,J)
 2213 FORMAT(/
     .10X,'TIME OF FAILURE OF THE STRUCTURE                 TFH',2X,
     .F10.3/10X,'COMPUTATIONAL TIME STEP AFTER DAM/BRIDGE FAILURE DTHDB'
     .,F10.5/10X,'ELEVATION OF WATER WHEN DAM FAILURE COMMENCES    HFDD'
     .,1X,F10.2/10X,'FINAL WIDTH AT BOTTOM OF BREACH                  BB
     .D  ',F10.2/10X,'SLIDE SLOPE OF BREACH                            Z
     .BCH',1X,F10.2/10X,'LOWEST ELEVATION THAT BOTTOM BREACH REACHES',6X
     .,'YBMIN',F10.2/10X,'EXPONENT USED IN DEVELOPMENT OF BREACH',11X,
     .'BREXP',F10.2/10X,'CENTERLINE ELEVATION OF PIPING BREACH',12X,
     .'CPIP',1X,F10.2)
      ENDIF
C      IF(HFDD(K,J).LT.TOL) HFDD(K,J)=100000.
      TFH1=TFH(1,1)
      IF(HFDD(K,J).EQ.0.0) HFDD(K,J)=100000.
      IF(DTHDB(K,J).LT.TOL) DTHDB(K,J)=TFH(K,J)/MDT
      IF(DTHDB(K,J).LT.TOL) DTHDB(K,J)=DTIN(1)
      IF(BREXP(K,J).LT.TOL) BREXP(K,J)=1.0
      IF(CDOD(K,J).LE.0.0) CDOD(K,J)=3.0
      IF(HDD(K,J).LT.TOL) HDD(K,J)=100000.
      IF(HSPD(K,J).LT.TOL) HSPD(K,J)=100000.
      IF(HGTD(K,J).LT.TOL) HGTD(K,J)=100000.
      IF(DTFMN.GT.DTHDB(K,J).AND.TFH(K,J).GT.0.0) DTFMN=DTHDB(K,J)
C   1 FORMAT(8F10.2)
    2 FORMAT(8I10)
    3 FORMAT(8F10.2)
   11 FORMAT(/7X,3HLAD,7X,3HHDD,7X,3HCLL,6X,4HCDOD,7X,3HQTD,
     . 5X,5HICHAN/I10,4F10.2,I10)
   12 FORMAT(/7X,3HICG,6X,4HHSPD,7X,3HSPL,7X,3HCSD,6X,4HHGTD,7X,3HCGD,
     & /I10,8F10.2)
   13 FORMAT(/7X,3HTFH,5X,5HDTHDB,6X,4HHFDD,7X,3HBBD,6X,4HZBCH,
     & 5X,5HYBMIN,5X,5HBREXP,6X,4HCPIP/F10.3,F10.5,6F10.2)
   15 FORMAT(1X,' CRESL=',8F8.2)
   16 FORMAT(/1X,'HCRESL=',8F8.2)
   17 FORMAT(/1X,' QTT=',8F8.0)
   18 FORMAT(1X, ' TQT=',8F8.2)
 1001 FORMAT(1X,(8F10.2))

C      IF(IBUG.EQ.1) WRITE(IODBUG,11111)
11111 FORMAT(1X,'** EXIT REDDAM **')
      GO TO 9000
 1000 IF(IBUG.EQ.1) WRITE(IODBUG,1010)
      CALL ERROR
      IERR=1
 1010 FORMAT(/5X,'**ERROR** END OF FILE ENCOUNTERED WHILE READING INPUT
     * FOR DAM INFO.'/)
 1020 FORMAT(10X,'**ERROR** KRCH=',I3,' OPTION IS CURRENTLY NOT AVAILABL
     .E IN OPERATIONAL PROGRAM')
 1022 FORMAT(10X,'**ERROR** VARIABLE TURBINE FLOW (QTD<0) CURRENTLY NOT
     .AVAILABLE IN OPERATIONAL MODEL')
 1024 FORMAT(10X,'**ERROR** TIME DEPENDENT GATES (ICG=2) CURRENTLY NOT A
     .VAILABLE IN OPERATIONAL MODEL')
 1026 FORMAT(10X,'**ERROR** TIME RATING CURVES (KRCH=27) CURRENTLY NOT A
     .VAILABLE IN OPERATIONAL MODEL')
 9000 RETURN
      END

