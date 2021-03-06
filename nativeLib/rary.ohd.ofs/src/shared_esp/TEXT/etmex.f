C MODULE ETMEX
C
C   THIS SUBROUTINE WILL:
C
C   1) CALCULATE START OF RUN IN LST
C   2) CALCULATE SHIFT NECESSARY TO MAKE RUN TIMES COMPATIBLE
C      WITH IDTE
C   3) CALCULATE IDARUN
C   4) CHECK IF END OF RUN IS LESS THAN START OF RUN
C   5) CHECK IF START OF WINDOW IS LESS THAN START OF RUN
C   6) CHECK IF END OF WINDOW IS LESS THAN START OF WINDOW.
C
C   THIS SUBROUTINE WAS ORIGINALLY WRITTEN BY GERALD N. DAY .
C
      SUBROUTINE ETMEX
C
      INCLUDE 'common/fctime'
      INCLUDE 'common/ionum'
      INCLUDE 'common/esprun'
      INCLUDE 'common/etime'
      INCLUDE 'common/fdbug'
      INCLUDE 'common/where'
C
      DIMENSION SBNAME(2),OLDOPN(2)
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/shared_esp/RCS/etmex.f,v $
     . $',                                                             '
     .$Id: etmex.f,v 1.2 1998/07/06 11:37:59 page Exp $
     . $' /
C    ===================================================================
C
C
      DATA SBNAME / 4hETME,4hX    /, ILT / 2hLT /
C
      IOLDOP=IOPNUM
      IOPNUM=0
      DO 10 I=1,2
      OLDOPN(I)=OPNAME(I)
   10 OPNAME(I)=SBNAME(I)
C
      IF(ITRACE.GE.1) WRITE(IODBUG,900)
  900 FORMAT(1H0,16H** FAZE2 ENTERED)
C
C   CALCULATE START TIME OF RUN IN LST
C
      CALL EFCLST(IJDFC,IHFC,IJDLST,IHLST)
C
C   CALCULATE SHIFT NEEDED FOR MINDT
C
      CALL ESHFT(IJDLST,IHLST,IDTE,IMOVE)
      ISHIFT=IMOVE
C
C   CALCULATE IDARUN
C
      CALL MDYH1(IJDLST,IHLST,KM,KD,KY,KH,100,0,TZC)
      KY=IHYR
      IF(KM.GE.10) KY=KY-1
      IF(KM.EQ.9.AND.KD.EQ.30.AND.KH.EQ.24) KY=KY-1
C
C   IF IDARUN = 2/29 AND THIS IS NOT A LEAP YEAR,
C   SET IDARUN =2/28.
C
      KDLOOP=KD
      IF(KM.NE.2.OR.KD.NE.29) GO TO 50
      IF(KY.EQ.(4*(KY/4))) GO TO 50
      KDLOOP=28
   50 CALL FCTZC(100,0,TZC)
      CALL JULDA(IDARUN,IHRRUN,KM,KDLOOP,KY,KH,100,0,TZC)
C
C  CHECK IF END OF RUN IS LESS THAN START OF RUN
C
      CALL FDATCK(LJDLST,LHLST,IJDLST,IHLST,ILT,ISW)
      IF(ISW.EQ.0) GO TO 100
      WRITE(IPR,600)
  600 FORMAT(1H0,10X,46H**ERROR** END OF RUN IS LESS THAN START OF RUN)
      CALL KILLFN(8hESP     )
      GO TO 999
C
C   CHECK IF START OF WINDOW IS LESS THAN START OF RUN
C
  100 CONTINUE
      DO 200 I=1,NUMWIN
      CALL FDATCK(IWJD(I),IWH(I),IJDLST,IHLST,ILT,ISW)
      IF(ISW.EQ.0) GO TO 200
      IWJD(I)=IJDLST
      IWH(I)=IHLST
      WRITE(IPR,605)
  605 FORMAT(1H0,10X,45H**WARNING** START OF WINDOW WAS SET TO START ,
     1 6HOF RUN)
      CALL WARN
C
C   CHECK IF END OF WINDOW IS LESS THAN START OF WINDOW
C
      CALL FDATCK(LWJD(I),LWH(I),IWJD(I),IWH(I),ILT,ISW)
      IF(ISW.EQ.0) GO TO 200
      WRITE(IPR,610)
  610 FORMAT(1H0,10X,47H**ERROR** END OF WINDOW WAS LESS THAN START OF ,
     1 6HWINDOW)
      IWJD(I)=0
      CALL ERROR
      GO TO 999
C
  200 CONTINUE
C
  999 CONTINUE
C
      IOPNUM=IOLDOP
      OPNAME(1)=OLDOPN(1)
      OPNAME(2)=OLDOPN(2)
C
      RETURN
      END
