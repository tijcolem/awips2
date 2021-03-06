C MEMBER HCNUNV
C  (from old member HCLCNUNV)
C-----------------------------------------------------------------------
C
C                             LAST UPDATE: 01/13/95.15:34:35 BY $WC20SV
C
C @PROCESS LVL(77)
C
       SUBROUTINE HCNUNV (ID,IVALUE,LWORK,IWORK,IHNUNV)
C
C          ROUTINE:  HCNUNV
C
C
C             VERSION:  1.0.0
C
C                DATE:  3-10-83
C
C              AUTHOR:  SONJA R SIEGEL
C                       DATA SCIENCES INC
C                       8555 16TH ST, SILVER SPRING, MD 587-3700
C***********************************************************************
C
C          DESCRIPTION:
C
C  ROUTINE TO DETERMINE IF AN HCL TECHNIQUE IS CHANGED FROM A SPECIFIED
C  VALUE AT ANY TIME DURING THE COMPUTATION OF A FUNCTION.
C
C***********************************************************************
C
C          ARGUMENT LIST:
C
C         NAME    TYPE  I/O   DIM   DESCRIPTION
C
C        ID         A8   I      2     TECHNIQUE NAME
C        IVALUE     I    I      1     VALUE TO CHECK
C        LWORK      I    I      1     DIMENSION OF IWORK
C        IWORK      I    O     LWORK  WORK BUFFER TO READ TECH DEF
C
C
C
C
C***********************************************************************
C
C          COMMON:
C
      INCLUDE 'uio'
      INCLUDE 'udebug'
      INCLUDE 'udatas'
      INCLUDE 'hclcommon/hcurfc'
      INCLUDE 'hclcommon/hseg1'
      INCLUDE 'hclcommon/hgtech'
      INCLUDE 'hclcommon/htechn'
      INCLUDE 'common/where'
C
C***********************************************************************
C
C          DIMENSION AND TYPE DECLARATIONS:
C
      DIMENSION ITEMP(2),IROUT(2)
      DIMENSION IWORK(LWORK)
      DIMENSION ID(2)
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/db_hclrw/RCS/hcnunv.f,v $
     . $',                                                             '
     .$Id: hcnunv.f,v 1.1 1995/09/17 18:41:49 dws Exp $
     . $' /
C    ===================================================================
C
C
C
C***********************************************************************
C
C          DATA:
C
      DATA IROUT/4HHCNU,4HNV  /
C
C***********************************************************************
C
C
      IF (IHCLTR.GT.0) WRITE (IOGDB,*) '*** ENTER HCNUNV'
C
      CALL UMEMOV (OPNAME,ITEMP,2)
      CALL UMEMOV (IROUT,OPNAME,2)
C
C GET THE TECHNIQUE DEFINITION TO RETRIEVE INTERNAL NUMBER
C
      ITYPE=3
      CALL HGTRCD (ITYPE,ID,LWORK,IWORK,ISTATS)
      IF (ISTATS.NE.0) GO TO 150
      ITECHN=IWORK(2)
C
C SET NEG IF GLOBAL
C
      IF (IWORK(3).LT.0) ITECHN=-ITECHN
      IF (IHCLDB.GT.0) WRITE (IOGDB,10) ID,ITECHN
10    FORMAT (' IN HCNUNV - TECH ',2A4,' FOUND. NUMBER=',I5)
C
C START AT BEGINNING OF RUNTIME OPTION FILE AND SEARCH FOR PERTINENT
C IDENTIFIERS
C
      NUMRED=0
      NMOD=0
      IHNUNV=0
C IF ALL DONE, TECH VALUE WAS ALWAYS THE SAME
C
C
20    NXOPT=LRECOP
      CALL HINCNX
      IF (ISTAT.NE.0) GO TO 110
      NXREC=IOPTRC(1)+NUMRED-1
      IF (IOPTRC(2).NE.0.AND.IOPTRC(2).NE.IHCFUN) GO TO 80
      NXOPT=2
C SEE IF RECORD IS FINISHED AND NEED TO GET NEXT OPTION
      CALL HINCNX
      IF (ISTAT.NE.0) GO TO 110
40    IF (IOPTRC(NXOPT).EQ.0) GO TO 20
C NEXT IS THE START OF THE NEXT TECH OR MOD IN THIS OPTION
C NRSAVE IS THE NEXT OPTION RECORD NUMBER IN CURRENT OPTION
C NR IS NUMBER OF RECORDS UNTIL NEXT OPTION WITHIN THIS OPTION REC
      NEXT=IOPTRC(NXOPT)+NXOPT+1
      NR=(NEXT-1)/LRECOP
      NRSAVE=NUMRED+NR
C
C THIS IS AN OPTION TO BE EXAMINED
C STEP THROUGH THE RECORD, CHECKING AS WE GO
C
      CALL HINCNX
      IF (ISTAT.NE.0) GO TO 130
C
C PICK UP TECHNIQUE NUMBER OR MOD (ZERO)
C
      ITN=IOPTRC(NXOPT)
C
C IS IT MOD??
C IF SO SKIP IT
C
      IF (ITN.NE.ITECHN) GO TO 50
C
C IT IS THE TECHNIQUE WE WANT, GET VALUE
C
      CALL HINCNX
      IF (ISTAT.NE.0) GO TO 130
      IVAL=IOPTRC(NXOPT)
C
C DONT BOTHER TO CHECK IDS ANYMORE
C
CCC   CALL HINCNX
CCC   IF (ISTAT.NE.0) GO TO 900
CCC   IF (IOPTRC(NXOPT).EQ.0) GO TO 150
C
C THERE ARE IDENTIFIERS, COMPARE VALUE
      IF (IVAL.NE.IVALUE) GO TO 90
C
C VALUE IS THE SAME TO GO TO NEXT OPTION
C
C NOT USING THIS TECH OR MOD, TRY NEXT TECH OR MOD
C
50    CONTINUE
      IF (NRSAVE.LE.NUMRED) GO TO 60
C
C NEED TO READ RECORDS TO GET TO NEXT OPTION
C
          NXOPT=LRECOP
         CALL HINCNX
         IF (ISTAT.NE.0) GO TO 130
      GO TO 50
60    NXOPT=NEXT-NR*LRECOP
      IF (IHCLDB.GT.0) WRITE (IOGDB,70) NEXT,NR,NRSAVE,NUMRED,NXOPT
70    FORMAT (' IN HCNUNV - SKIPPING TO NEXT OPTION : NEXT=',I4,
     1       ' NR=',I4,' NRSAVE=',I4,' NUMRED=',I4,' NXOPT=',I4)
      GO TO 40
C
C WE DON'T WANT THIS OPTION, SKIP TO NEXT
C
80    IF (NXREC.EQ.NUMRED) GO TO 20
      NUMRED=NXREC
      GO TO 20
C
C DIFFERENT VALUE
C
90    IHNUNV=1
      IF (IHCLDB.GT.0) WRITE (IOGDB,100) ITECHN,IVAL
100   FORMAT (' IN HCNUNV - DIFF VALUE FOUND FOR TECH',2I6)
      GO TO 170
C
C CHECK VALUE IN DEFAULT TECH ARRAYS
C
110   IF (IWORK(3).LT.0) GO TO 120
      IVAL=ITECH(ITECHN)
      IF (IVAL.NE.IVALUE) GO TO 90
      GO TO 170
120   IVAL=IGTECH(IABS(ITECHN))
      IF (IVAL.NE.IVALUE) GO TO 90
      GO TO 170
C
C ERROR
C
130   WRITE (LPE,140)
140   FORMAT (' **ERROR** UNEXPECTED EOF ON RUN OPTIONS')
      GO TO 170
150   WRITE (LPE,160) ID
160   FORMAT (' **ERROR** TECHNIQUE ',2A4,' NOT FOUND')
      IHNUNV=-1
170   IF (IHCLDB.GT.0) WRITE (IOGDB,180) ID,IVALUE,IHNUNV
180   FORMAT (' IN HCNUNV - TECH=',2A4,' VALUE=',I5,' IHNUNV=',I2)
      CALL UMEMOV (ITEMP,OPNAME,2)
C
      IF (IHCLTR.GT.0) WRITE (IOGDB,*) '*** EXIT HCNUNV'
C
      RETURN
C
      END
