C MEMBER MK6C29
C  (from old member FCPIN29)
C
      SUBROUTINE MK6C29 (IDNO,C1,C2,C3,C4,C5,C6,REG1,REG2,IERR)
C
C***********************************************************************
C
C  THIS SUBROUTINE PROVIDES THE PIN ROUTINE WITH THE KANSAS CITY
C  API/AI/RUNOFF RELATIONSHIP CONSTANTS.
C
C***********************************************************************
C  SUBROUTINE INITIALLY WRITTEN BY
C        LARRY BLACK - MBRFC     JULY 1982
C***********************************************************************
C
C
      DIMENSION CON1(35),CON2(35),CON3(35),CON4(35),CON5(35),CON6(35),
     1          AREG1(35),AREG2(35)
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcinit_pntb/RCS/mk6c29.f,v $
     . $',                                                             '
     .$Id: mk6c29.f,v 1.1 1995/09/17 18:47:58 dws Exp $
     . $' /
C    ===================================================================
C
C
      DATA CON1/  0.550,  0.357,  0.330,  0.587,  1.315,  0.951,  0.827,
     1            0.611,  0.970,  0.848,  0.927,  0.0  ,  0.0  ,  0.0  ,
     2            0.0  ,  0.748,  0.0  ,  0.0  ,  0.0  ,  0.0  ,  0.0  ,
     3            0.0  ,  0.0  ,  0.969,  0.0  ,  0.750,  0.550,  0.496,
     4            0.260,  0.536,  0.203,  0.279,  0.504,  0.0  ,  0.0  /
C
      DATA CON2/  0.410,  0.422,  0.448,  0.138,  0.312,  0.172,  0.202,
     1            0.129,  0.106,  0.166,  0.355,  0.0  ,  0.0  ,  0.0  ,
     2            0.0  ,  0.437,  0.0  ,  0.0  ,  0.0  ,  0.0  ,  0.0  ,
     3            0.0  ,  0.0  ,  0.060,  0.0  ,  0.500,  0.400,  0.403,
     4            0.098,  0.339,  0.094,  0.242,  0.409,  0.0  ,  0.0  /
C
      DATA CON3/  3.733,  3.515,  3.623,  3.457,  4.731,  4.421,  3.617,
     1            3.223,  3.299,  3.216,  2.980,  0.0  ,  0.0  ,  0.0  ,
     2            0.0  ,  3.532,  0.0  ,  0.0  ,  0.0  ,  0.0  ,  0.0  ,
     3            0.0  ,  0.0  ,  5.688,  0.0  ,  4.076,  4.000,  3.639,
     4            3.624,  3.751,  4.041,  3.434,  3.834,  0.0  ,  0.0  /
C
      DATA CON4/ -0.890, -0.912, -1.232, -1.110, -0.868, -1.212, -1.295,
     1           -1.274, -1.322, -1.317, -1.205,  0.0  ,  0.0  ,  0.0  ,
     2            0.0  , -0.613,  0.0  ,  0.0  ,  0.0  ,  0.0  ,  0.0  ,
     3            0.0  ,  0.0  , -0.728,  0.0  , -0.800, -0.811, -0.811,
     4           -0.800, -0.800, -0.800, -0.800, -0.800,  0.0  ,  0.0  /
C
      DATA CON5/ -1.500, -0.902, -1.240, -1.186, -0.750, -0.692, -1.050,
     1           -1.274, -1.456, -1.196, -1.411,  0.0  ,  0.0  ,  0.0  ,
     2            0.0  , -1.058,  0.0  ,  0.0  ,  0.0  ,  0.0  ,  0.0  ,
     3            0.0  ,  0.0  , -0.645,  0.0  , -1.200, -1.150, -1.078,
     4           -1.532, -1.451, -1.624, -1.827, -1.996,  0.0  ,  0.0  /
C
      DATA CON6/  0.000,  0.000,  0.024,  0.000,  0.106,  0.103,  0.024,
     1            0.160,  0.008,  0.017,  0.003,  0.0  ,  0.0  ,  0.0  ,
     2            0.0  ,  0.008,  0.0  ,  0.0  ,  0.0  ,  0.0  ,  0.0  ,
     3            0.0  ,  0.0  ,  0.060,  0.0  ,  0.002,  0.002,  0.002,
     4            0.002,  0.002,  0.001,  0.002,  0.001,  0.0  ,  0.0  /
C
      DATA AREG1/11*0.70,4*0.00,0.90,7*0.00,0.70,0.00,8*0.93,2*0.00/,
     1     AREG2/11*0.84,4*0.00,0.90,7*0.00,0.84,0.00,8*0.93,2*0.00/
C
C
C  SET INITIAL ERROR VALUE TO ZERO.  THEN CHECK FOR VALID API/AI
C  NUMBER.  IF INVALID NUMBER, RETURN POSITIVE ERROR VALUE.
C
      IF(CON3(IDNO).LE.0.001) GO TO 999
C
C  IF VALID API/AI RELATIONSHIP NUMBER, SET CONSTANT VALUES AND RETURN.
C
      C1=CON1(IDNO)
      C2=CON2(IDNO)
      C3=CON3(IDNO)
      C4=CON4(IDNO)
      C5=CON5(IDNO)
      C6=CON6(IDNO)
      REG1=AREG1(IDNO)
      REG2=AREG2(IDNO)
      IERR=0
      RETURN
C
C  SET ERROR FLAG.
C
  999 IERR=10
      RETURN
C
C
      END
