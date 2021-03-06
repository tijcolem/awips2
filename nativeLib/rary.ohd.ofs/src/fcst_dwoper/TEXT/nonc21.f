C MODULE NONC21
C DESC -- THIS SUBROUTINE SETS INFLOW EQUAL TO OUTFLOW WHEN THE MAXIMUM
C DESC -- NO. OF EXTRAPOLATIONS HAVE BEEN EXCEEDED DUE TO NONCONVERGENCE
C                             LAST UPDATE: 03/01/94.13:10:46 BY $WC30JL
C
C @PROCESS LVL(77)
C
      SUBROUTINE NONC21(STC,LOSTC,QTC,LOQTC,CCO,NB,NRT1,NT,YD,QD,ICO,
     *NSTR,NST,KTYP,GZO,QSTR,LOQSR,KTIME,NPD,JN,K4,ISTRT,PO,QL,LOQL,DIV,
     *LODIV,POOLT,LOPLT,ITWT,LOIWT,T1,DDX,IHRCO,JHRCO,JSIZE)
C
C           THIS SUBROUTINE WAS WRITTEN  BY:
C           JANICE LEWIS      HRL   NOVEMBER,1982     VERSION NO. 1
C
C   *****   UPDATED 03/10/88 BY JANICE LEWIS TO CALL SAVC21 SO THAT
C           CARRYOVER CAN BE SAVED AFTER NONCONVERGENCE
C
      COMMON/FCARY/IFILLC,NCSTOR,ICDAY(20),ICHOUR(20)
      COMMON/FDBUG/IODBUG,ITRACE,IDBALL,NDEBUG,IDEBUG(20)
      COMMON/IONUM/IN,IPR,IPU
      COMMON/DV21/LONDV,LOLDV,LZIDV
      COMMON/OX21/LOFKC,LONT1,LONQL,LOLQ,LZRCP,LZQQD,LZYQD,LONT
      COMMON/LD21/LONLD,LOCTW,LOLAD,LOPTR
C
      DIMENSION STC(*),LOSTC(*),QTC(*),LOQTC(*),NB(*),NRT1(*),NT(*)
      DIMENSION SNAME(2),NSTR(*),NST(*),KTYP(*),QSTR(*),LOQSR(*)
      DIMENSION GZO(*),YD(*),QD(*),CCO(*),PO(*),QL(*),LOQL(*),DIV(*)
      DIMENSION LODIV(*),POOLT(*),LOPLT(*),ITWT(*),LOIWT(*),DDX(*)
      DIMENSION T1(*)
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcst_dwoper/RCS/nonc21.f,v $
     . $',                                                             '
     .$Id: nonc21.f,v 1.4 2001/06/13 12:30:35 dws Exp $
     . $' /
C    ===================================================================
C
C
      DATA SNAME/4HNONC,4H21  /
C
C
      CALL FPRBUG(SNAME,1,21,IBUG)
C
C           SET COMPUTED TIME SERIES VALUES EQUAL TO PREVIOUSLY
C           COMPUTED VALUES
C
      DO 100 J=1,JN
      N=NB(J)
      NRT=NRT1(J)
      IF(NRT.EQ.0) GO TO 100
      LIJ=LCAT21(1,J,NB)-1
      DO 40 K=1,NRT
      KIJ=LCAT21(K,J,NRT1)
      DO 10 I=1,N
      IF(I.EQ.NT(KIJ)) GO TO 20
   10 CONTINUE
      GO TO 40
   20 LOST=LOSTC(KIJ)-1
      LOQT=LOQTC(KIJ)-1
      STGE=YD(I+LIJ)
      FLOW=QD(I+LIJ)*0.001
      IF(KTIME.EQ.0) KTIME=1
      DO 30 L=KTIME,NPD
      STC(L+LOST)=STGE
      QTC(L+LOQT)=FLOW
   30 CONTINUE
   40 CONTINUE
  100 CONTINUE
C
C        FINISH FILLING CARRYOVER ARRAY WITH PREVIOUSLY COMPUTED VALUES
C
  150 IF(IFILLC*NCSTOR.EQ.0) GO TO 200
      IF(ICO.GT.NCSTOR) GO TO 200
      TT=JHRCO-ISTRT
      CALL SAVC21(PO,CCO,CCO,YD,QD,NB,PO(LONQL),PO(LOLQ),QL,LOQL,
     1 PO(LONDV),DIV,LODIV,PO(LONLD),LOPLT,LOIWT,POOLT,ITWT,T1,DDX,
     2 PO(LOLAD),PO(LOCTW))
cc      WRITE(6,9998)JHRCO,IHRCO,ISTRT,TT,ICO,ICDAY(ICO),ICHOUR(ICO),JSIZE
cc 9998 FORMAT(1H0,'     JHRCO     IHRCO     ISTRT   TT       ICO     ICDA
cc     *Y    ICHOUR   K4='/1H ,3I10,F5.0,3I10,I5)
C
      CALL FCWTCO(ICDAY(ICO),ICHOUR(ICO),CCO,JSIZE)
      ICO=ICO+1
      JHRCO=(ICDAY(ICO)-1)*24+ICHOUR(ICO)
      GO TO 150
C
C
C        FINISH FILLING OUTPUT TIME SERIES ARRAYS WITH PREVIOUSLY
C        COMPUTED VALUES
C
  200 DO 250 J=1,JN
      IF(NSTR(J).EQ.0) GO TO 250
      NSR=NSTR(J)
      N=NB(J)
      LIJ=LCAT21(1,J,NB)-1
      KIJ=LCAT21(1,J,NSTR)-1
      DO 240 K=1,NSR
      DO 210 I=1,N
      IF(I.EQ.NST(KIJ+K)) GO TO 220
  210 CONTINUE
      GO TO 240
  220 VAL=YD(I+LIJ)-GZO(K+KIJ)
      IF(KTYP(K+KIJ).EQ.2) VAL=QD(I+LIJ)
      LOQS=LOQSR(K+KIJ)-1
      DO 230 L=KTIME,NPD
      QSTR(L+LOQS)=VAL
  230 CONTINUE
  240 CONTINUE
  250 CONTINUE
C
  300 KTIME=NPD
C
      WRITE(IPR,8000)
 8000 FORMAT(1H0,70H**WARNING** THE TOTAL NO. OF EXTRAPOLATIONS ALLOWED
     *HAS BEEN EXCEEDED./1H ,10X,90HALL FUTURE TIME STEP VALUES HAVE BEE
     *N SET TO THE LAST COMPUTED STAGE AND DISCHARGE VALUES.//1H ,10X,63
     *HCARRYOVER ARRAYS AS WELL AS OUTPUT TIME SERIES ARRAYS WILL ALSO /
     *1H ,10X,60HBE FILLED WITH THE LAST COMPUTED STAGE AND DISCHARGE VA
     *LUES.//1H0,15X,53HFOR FURTHER EXPLANATION OF AUTOMATIC FIXIUP PROC
     *EDURE/1H ,15X,56HPLEASE REFER TO PAGE V.3.3-DWOPER-5 OF THE USERS
     *MANUAL.//1H ,10X,19HPROGRAM TERMINATED.)
      CALL WARN
C
      IF(ITRACE.EQ.1) WRITE(IODBUG,9000) SNAME
 9000 FORMAT(1H0,2H**,1X,2A4,8H EXITED.)
      RETURN
      END
