C MEMBER EVAC26
C  (from old member FCEVAC26)
C
      SUBROUTINE EVAC26(STOR,ELEV)
C
C SUBROUTINE EVAC26 IS A UTILITY SUBROUTINE USED IN EVACUATION OPTIONS
C 8,9, AND 10.  FOR OPTION 8, THE PROGRAM COMES TO EVAC26 DIRECTLY FROM
C NDUC26.  IN OPTION 8 OUTFLOW IS REDUCED TO A SPECIFIED DISCHARGE
C (QTARG1) OR TO INFLOW PLUS A SPECIFIED ADDITION (DIFQI2) WHICHEVER IS
C GREATER.  AFTER OUTFLOW DROPS TO THE SPECIFIED DISCHARGE (OPTION 8)
C THE PROCEDURE IN EVAB26 IS USED BY CALLING THAT SUBROUTINE.  FOR
C OPTIONS 9 AMD 10, THE PROGRAM GOES FROM NDUC26 TO EVAA26 AND CALLS
C EVAC26 AND EVAB26 FROM EVAA26.  SEE EVAA26 FOR A DESCRIPTION OF THE
C OPTIONS.
C
C THIS SUBROUTINE WAS ORIGINALLY PROGRAMMED BY
C     WILLIAM E. FOX -- CONSULTING HYDROLOGIST
C     FEBRUARY, 1982
C
C SUBROUTINE EVAC26 IS IN
C
C VARIABLES PASSED TO OR FROM THIS SUBROUTINE ARE DEFINED AS FOLLOWS:
C     IOUT -- SURCHARGE EVACUATION OPERATION NO LONGER NEEDED (IOUT=1)
C       OR NEEDED (IOUT=0).
C     IOPTEV -- EVACUATION OPTION.  CAN BE 8 IN THIS SUBROUTINE BUT
C       EVAC26 IS CALLED BY EVAA26 FOR OPTIONS 9 AND 10.  OPTIONS ARE
C       DEFINED IN EVAA26.
C     QTARG1 -- SPECIFIED MINIMUM OUTFLOW FOR EVACUATION PROCEDURE IN
C       THIS SUBROUTINE.
C     DIFQI2 -- SPECIFIED ADDITION TO INFLOW  FOR COMPUTING OUTFLOW IN
C       THIS SUBROUTINE.
C       OTHER VARIABLES ARE DEFINED IN NDUC26.  EXCEPT WHEN COMPUTATIONS
C       ARE IN EVAB26, THIS SUBROUTINE WILL COMPUTE OUTFLOW (QQOM),
C       STORAGE(SS2) AND ELEVATION (ELRES2) AT THE END OF THE TIME STEP
C       AND SETS AN INDICATOR (IOUT) FOR NEED TO CONTINUE EVACUATION.
C
      INCLUDE 'common/fdbug'
      INCLUDE 'common/resv26'
      INCLUDE 'common/srcg26'
      INCLUDE 'common/evak26'
C
      DIMENSION STOR(1),ELEV(1)
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcst_res/RCS/evac26.f,v $
     . $',                                                             '
     .$Id: evac26.f,v 1.2 1996/07/12 14:00:48 dws Exp $
     . $' /
C    ===================================================================
C
C
C WRITE TRACE AND DEBUG IF REQUIRED
C
      IF(IBUG-1)50,10,20
   10 WRITE(IODBUG,30)
      GO TO 50
   20 WRITE(IODBUG,30)
   30 FORMAT(1H0,10X,17H** EVAC26 ENTERED)
      WRITE(IODBUG,40) IOUT,IOPTEV,QTARG1,DIFQI2,
     $FRPD,SFRPD,QIMSUR,QQIM,QQO1,QQO2,SS1,SS2,ELRES1,ELRES2,
     $RULEL1,RULEL2,IBUG
   40 FORMAT(1H0,'   IOUT,IOPTEV,QTARG1,DIFQI2,',
     $'FRPD,SFRPD,QIMSUR,QQIM,QQO1,QQO2,SS1,SS2,ELRES1,ELRES2',
     $'RULEL1,RULEL2,IBUG'/1X,2I6,8F12.3/1X,6F12.3,I6)
C
C SET IOUT TO 0.  MAY BE CHANGED LATER IN EVAB26.  COMPUTE OUTFLOW
C (QQO2) FOR FIRST PART OF OPTION 8 WHERE OUTFLOW IS THE GREATER VALUE
C OF A SPECIFIED DISCHARGE (QTARG1) OR INFLOW (QIMSUR) PLUS A SPECIFIED
C ADDITION (DIFQI2).  WHEN OUTFLOW DROPS TO QTARG1, OPTION 3B IS USED.
C (SEE EVAA26 FOR DESCRIPTION).
C
   50 IOUT=0
C
C  QTARG1 = QTARGET1
      IF(QQO1.LE.QTARG1) GO TO 70
C
C  DIFQI2 = DIFFQI2
      QQO2=QIMSUR+DIFQI2
      IF(QQO2.GT.QTARG1) GO TO 60
      QQO2=QTARG1
   60 SS2=SS1+QQIM-(QQO1+QQO2)*0.5*FRPD
      CALL NTER26(SS2,ELRES2,STOR,ELEV,NSE,IFLAG,NTERP,IBUG)
      GO TO 80
C
C EVACUATION SCHEDULE NOW CHANGES TO OPTION 3B IN EVAB26.
C
   70 CALL EVAB26(STOR,ELEV)
C
C WRITE TRACE AND DEBUG IF REQUIRED.
C
   80 CALL BETA26(STOR,ELEV)
      IF(IBUG-1)140,120,90
   90 WRITE(IODBUG,100)
  100 FORMAT(1H0,41H FOLLOWING ARE VARIABLES AT END OF EVAC26)
      WRITE(IODBUG,40) IOUT,IOPTEV,QTARG1,DIFQI2,
     $FRPD,SFRPD,QIMSUR,QQIM,QQO1,QQO2,SS1,SS2,ELRES1,ELRES2,
     $RULEL1,RULEL2,IBUG
      WRITE(IODBUG,110)(STOR(I),ELEV(I),I=1,NSE)
  110 FORMAT(1H0,78H ALTERNATING VALUES OF STORAGE AND ELEVATION FOR THE
     $ STORAGE - ELEV. CURVE ARE/(1X,5(F12.3,F10.3,2X)))
  120 WRITE(IODBUG,130)
  130 FORMAT(1H0,10X,17H** LEAVING EVAC26)
  140 RETURN
      END






