C     MODULE MRAINS
C
C     THIS SUBROUTINE PERFORMS THE RAINSNOW MOD.
C
C
      SUBROUTINE MRAINS(NCARDS,MODCRD,IHZERO)
C
C     FOR EACH SUBSEQUENT CARD THERE ARE 'NDATES' DATES WHICH ARE
C     TO BE PUT IN CB FCHGRS.  THE DATES ARE IN 'JDATES' AND
C     THE TYPE OF DATE IS IN 'IRNGDT' WITH THE
C     FOLLOWING RULES:
C      IRNGDT=0, DATE IS A SINGLE DATE
C            =1, DATE IS THE START OF A PERIOD
C            =2, DATE IS THE END OF A PERIOD
C     NOTE THAT VALUES IN IRNGDT OF '1' AND '2' MUST
C     ALWAYS OCCUR IN PAIRS.
C
C <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
C
      INTEGER DA,YR,HR
      LOGICAL LBUG,FIRST
C
      COMMON/FCHGRS/NCHGRS,ICHGRS(5,20)
      INCLUDE 'common/ionum'
      INCLUDE 'common/fdbug'
      INCLUDE 'common/fctime'
      INCLUDE 'common/fctim2'
      INCLUDE 'common/fpwarn'
      INCLUDE 'ufreex'
C
      DIMENSION OLDOPN(2)
      DIMENSION JDATES(7,20),IRNGDT(20),IRNSN(2),IRS(2)
      DIMENSION MODCRD(20,NCARDS),IFIELD(2)
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcst_mods/RCS/mrains.f,v $
     . $',                                                             '
     .$Id: mrains.f,v 1.2 1998/07/02 20:46:11 page Exp $
     . $' /
C    ===================================================================
C
C
      DATA IRNSN/4HRAIN,4HSNOW/,IRS/4HR   ,4HS   /
      DATA IBLANK/4H    /
C
      CALL FSTWHR(8HMRAINS  ,0,OLDOPN,IOLDOP)
C
      MAXDTS=20
C
      LBUG=.FALSE.
      IF(IFBUG(4HMODS).EQ.1.OR.IFBUG(4HRAIN).EQ.1)LBUG=.TRUE.
C
      IF(LBUG)WRITE(IODBUG,842)
  842 FORMAT(11X,'*** ENTERING MRAINS ***')
C
      FIRST=.TRUE.
C
      IF(NRDCRD.EQ.NCARDS)GO TO 13
C
    1 IF(NRDCRD.EQ.NCARDS)GO TO 999
C
      IF(MISCMD(NCARDS,MODCRD).EQ.0)GO TO 17
C
      IF(.NOT.FIRST)GO TO 999
C
C     HAVE FOUND COMMAND AS FIRST SUBSEQUENT CARD - ERROR
C
   13 IF(MODWRN.EQ.0)GO TO 999
      WRITE(IPR,920)
  920 FORMAT(1H0,10X,'**WARNING** NO SUBSEQUENT CARDS FOUND FOR THE ',
     1  'RAINSNOW MOD.  PROCESSING CONTINUES')
      CALL WARN
      GO TO 999
C
   17 FIRST=.FALSE.
      NRDCRD=NRDCRD+1
C
      NFLD=1
      ISTRT=-3
      NCHAR=2
      ICKDAT=0
C
      CALL UFIEL2(NCARDS,MODCRD,NFLD,ISTRT,LEN,ITYPE,NREP,INTGER,REAL,
     1  NCHAR,IFIELD,LLPAR,LRPAR,LASK,LATSGN,LAMPS,LEQUAL,ISTAT)
C
      IF(ITYPE.NE.-1)GO TO 5
C
      IF(MODWRN.EQ.0)GO TO 1
      WRITE(IPR,608)(MODCRD(I,NRDCRD),I=1,20)
  608 FORMAT(1H0,10X,'** WARNING ** UNEXPECTED END OF INPUT IN ',
     1 'RAINSNOW MOD - CARD IMAGE IS'/11X,20A4)
      CALL WARN
      GO TO 1
C
C     SEE IF FIELD DECODED IS 'RAIN' OR 'SNOW'
C
    5 IFLAG=0
      IF(IFIELD(1).EQ.IRNSN(1))IFLAG=1
      IF(IFIELD(1).EQ.IRNSN(2))IFLAG=2
      IF(IFLAG.GT.0)GO TO 10
C
C     SEE IF FIELD DECODED IS 'R' OR 'S'
C
      IF(IFIELD(1).EQ.IRS(1))IFLAG=1
      IF(IFIELD(1).EQ.IRS(2))IFLAG=2
      IF(IFLAG.GT.0)GO TO 10
C
C     INVALID FIELD DECODED
C
      IF(MODWRN.EQ.0)GO TO 1
      WRITE(IPR,609)IFIELD,(MODCRD(I,NRDCRD),I=1,20)
  609 FORMAT(1H0,10X,'** WARNING ** INVALID FIELD DECODED WHERE ',
     1 '''RAIN'' OR ''SNOW'' WAS EXPECTED.  FIELD DECODED WAS ',2A4/
     2 11X,'ENTIRE MOD CARD IMAGE IS'/11X,20A4)
      CALL WARN
      GO TO 1
C
   10 CALL MDCDAT(NCARDS,MODCRD,NFLD,MAXDTS,NDATES,JDATES,IRNGDT,ISTAT)
C
      IF(LBUG)WRITE(IODBUG,900)NDATES,ISTAT
  900 FORMAT(11X,'IN RAINSNOW MOD AFTER CALL TO MDCDAT - NDATES = ',I2,
     1 ', ISTAT = ',I2)
      IF(LBUG.AND.NDATES.GT.0)WRITE(IODBUG,901)((JDATES(I,J),I=1,7),
     1 IRNGDT(J),J=1,NDATES)
  901 FORMAT(5X,'JDATES = ',5I11,1X,A4,I11,', IRNGDT = ',I3)
C
C     GO THROUGH DATES AND SEE IF SINGLE DATES ARE WITHIN THE
C     RUN PERIOD, OR IF THE RANGE OF DATES REQUESTED IS TOTALLY
C     WITHIN THE RUN PERIOD
C
C     IF THEY ARE, SET VALUES IN CB /FCHGRS/
C     IF NOT, CHECK TO SEE IF MESSAGE SHOULD BE PRINTED
C
C <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
C
      IF(NDATES.GT.0)GO TO 40
C
      IF(MODWRN.EQ.0)GO TO 1
      WRITE(IPR,601)IRNSN(IFLAG),(MODCRD(I,NRDCRD),I=1,20)
  601 FORMAT(1H0,10X,'**WARNING** IN THE RAINSNOW MOD'/
     1 11X,'NO DATES HAVE BEEN ENTERED FOR SETTING VALUES TO ',A4/
     2 11X,'THE ENTIRE MOD CARD IMAGE IS'/11X,20A4)
      CALL WARN
      GO TO 1
C
C     SEE IF A SLASH WAS ENTERED
C
   40 IFIELD(1)=IBLANK
      IFIELD(2)=IBLANK
      IF(ISTAT.NE.2)GO TO 45
C
C     SLASH ENTERED - MUST DECODE AN OPERATION NAME
C
      ISTRT=-3
      NCHAR=2
      ICKDAT=0
C
      CALL UFIEL2(NCARDS,MODCRD,NFLD,ISTRT,LEN,ITYPE,NREP,INTGER,REAL,
     1  NCHAR,IFIELD,LLPAR,LRPAR,LASK,LATSGN,LAMPS,LEQUAL,ISTAT)
C
      IF(ITYPE.NE.-1)GO TO 45
C
C     NO OPERATION NAME ENTERED - IGNORE MOD CARD
C
      IF(MODWRN.EQ.0)GO TO 1
      WRITE(IPR,610)(MODCRD(I,NRDCRD),I=1,20)
  610 FORMAT(1H0,10X,'** WARNING ** IN THE RAINSNOW MOD - NO ',
     1 'OPERATION NAME WAS ENTERED AFTER A SLASH (/) ON A ',
     2 'SUBSEQUENT CARD'/11X,'NO CHANGES ENTERED ON THIS CARD WILL ',
     3 'BE MADE.  THE CURRENT MOD CARD IMAGE IS'/11X,20A4)
      CALL WARN
      GO TO 1
C
   45 INITHR=(IDA-1)*24+IHZERO
      LASTHR=(LDA-1)*24+LHR
C
      DO 100 IDATE=1,NDATES
C
      IF(IRNGDT(IDATE).GT.0)GO TO 60
C
C     ONE DATE
C
      IF(JDATES(1,IDATE).LT.INITHR.OR.JDATES(1,IDATE).GT.LASTHR)GO TO 50
C
C     DATE OK
      GO TO 80
C
   50 CONTINUE
C
C     BAD DATE
C
      JJDA=JDATES(1,IDATE)/24+1
      JJHR=JDATES(1,IDATE)-(JJDA-1)*24
C
      CALL MDYH2(JJDA,JJHR,MO,DA,YR,HR,ID1,ID2,INPTZC)
C
      IF(MODWRN.EQ.0)GO TO 100
      WRITE(IPR,606)IRNSN(IFLAG),MO,DA,YR,HR,INPTZC
  606 FORMAT(1H0,10X,'**WARNING** IN RAINSNOW MOD - TRYING TO ',
     1 'SET VALUE TO ',A4,'.'/11X,
     2 'DATE ',I2,1H/,I2,1H/,I4,1H-,I2,1X,A4,' IS NOT IN THE ',
     3 'CURRENT RUN PERIOD.')
      CALL WARN
      GO TO 100
C
C <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
C
   60 CONTINUE
C
C     RANGE OF DATES - IF START OF RANGE JUST GO ON
C                    - IF END OF RANGE PROCESS DATES
C
      IF(IRNGDT(IDATE).EQ.1)GO TO 100
C
C     NOW HAVE START OF RANGE IN (IDATE-1) AND END OF RANGE
C     IN (IDATE).
C
      IDATM1=IDATE-1
C
C     SEE IF THIS IS A VALID RANGE OF DATES
C     (I.E., THE FIRST DATE IS AT OR BEFORE THE SECOND DATE)
C
      IF(JDATES(1,IDATM1).LE.JDATES(1,IDATE))GO TO 65
C
C     NOT A VALID RANGE
C
      JJDA=JDATES(1,IDATM1)/24+1
      JJHR=JDATES(1,IDATM1)-(JJDA-1)*24
C
      CALL MDYH2(JJDA,JJHR,IIMO,IIDA,IIYR,IIHR,ID1,ID2,INPTZC)
C
      JJDA=JDATES(1,IDATE)/24+1
      JJHR=JDATES(1,IDATE)-(JJDA-1)*24
C
      CALL MDYH2(JJDA,JJHR,LLMO,LLDA,LLYR,LLHR,ID1,ID2,INPTZC)
C
      IF(MODWRN.EQ.0)GO TO 100
      WRITE(IPR,612)IRNSN(IFLAG),IIMO,IIDA,IIYR,IIHR,INPTZC,
     1                             LLMO,LLDA,LLYR,LLHR,INPTZC
  612 FORMAT(1H0,10X,'**WARNING** IN RAINSNOW MOD - TRYING TO ',
     1 'SET VALUE TO ',A4,'.'/11X,
     2 'THE PERIOD TO BE SET ',I2,1H/,I2,1H/,I4,1H-,
     3 I2,1X,A4,' TO ',I2,1H/,I2,1H/,I4,1H-,I2,1X,A4,
     4 ' IS NOT A VALID RANGE OF DATES.'/11X,
     5 'NO VALUES WILL BE CHANGED.')
      CALL WARN
      GO TO 100
C
   65 CONTINUE
C
C     SEE IF ENTIRE RANGE OF DATES IS WITHIN THE RUN PERIOD.
C
      IF(JDATES(1,IDATM1).GE.INITHR.AND.JDATES(1,IDATE).LE.LASTHR)
     1            GO TO 80
C
C     ENTIRE PERIOD NOT WITHIN RUN
C
      JJDA=JDATES(1,IDATM1)/24+1
      JJHR=JDATES(1,IDATM1)-(JJDA-1)*24
C
      CALL MDYH2(JJDA,JJHR,IIMO,IIDA,IIYR,IIHR,ID1,ID2,INPTZC)
C
      JJDA=JDATES(1,IDATE)/24+1
      JJHR=JDATES(1,IDATE)-(JJDA-1)*24
C
      CALL MDYH2(JJDA,JJHR,LLMO,LLDA,LLYR,LLHR,ID1,ID2,INPTZC)
C
      IF(JDATES(1,IDATM1).GT.LASTHR.OR.JDATES(1,IDATE).LT.INITHR)
     1 GO TO 67
C
C     SOME OF PERIOD ENTERED IS IN THE RUN PERIOD
C
      IF(MODWRN.EQ.0)GO TO 80
      WRITE(IPR,607)IRNSN(IFLAG),IIMO,IIDA,IIYR,IIHR,INPTZC,
     1                             LLMO,LLDA,LLYR,LLHR,INPTZC
  607 FORMAT(1H0,10X,'**WARNING** IN RAINSNOW MOD - TRYING TO ',
     1 'SET VALUE TO ',A4,'.'/11X,
     2 'THE PERIOD TO BE SET ',I2,1H/,I2,1H/,I4,1H-,
     3 I2,1X,A4,' TO ',I2,1H/,I2,1H/,I4,1H-,I2,1X,A4,
     4 ' IS NOT COMPLETELY WITHIN THE RUN PERIOD.'/11X,
     5 'THOSE VALUES WITHIN THE RUN PERIOD WILL BE CHANGED.')
      CALL WARN
      GO TO 80
C
C     ENTIRE PERIOD ENTERED IS OUTSIDE THE RUN PERIOD
C
   67 IF(MODWRN.EQ.0)GO TO 100
      WRITE(IPR,844)IRNSN(IFLAG),IIMO,IIDA,IIYR,IIHR,INPTZC,
     1                             LLMO,LLDA,LLYR,LLHR,INPTZC
  844 FORMAT(1H0,10X,'**WARNING** IN RAINSNOW MOD - TRYING TO ',
     1 'SET VALUE TO ',A4,'.'/11X,
     2 'THE PERIOD TO BE SET ',I2,1H/,I2,1H/,I4,1H-,
     3 I2,1X,A4,' TO ',I2,1H/,I2,1H/,I4,1H-,I2,1X,A4,
     4 ' IS COMPLETELY OUTSIDE THE RUN PERIOD.'/11X,
     5 'NO VALUES WILL BE CHANGED.')
      CALL WARN
      GO TO 100
C
C     SOME OF PERIOD IS TO BE SET
C
C     STORE VALUES IN CB /FCHGRS/ IF THERE IS ROOM
C
   80 IF(NCHGRS.LT.20)GO TO 90
C
C     NOT ENOUGH ROOM
C
      IF(MODWRN.EQ.0)GO TO 999
      WRITE(IPR,611)(MODCRD(I,NRDCRD),I=1,20)
  611 FORMAT(1H0,10X,'** WARNING ** IN RAINSNOW MOD - NO MORE ROOM ',
     1 'IN FCHGRS COMMON BLOCK.'/11X,
     2 'THE FOLLOWING MOD CARD AND ANY AFTER IT ARE IGNORED'/11X,20A4)
      CALL WARN
      GO TO 999
C
C     PUT VALUES AND DATES INTO CB /FCHGRS/
C
   90 NCHGRS=NCHGRS+1
      ICHGRS(1,NCHGRS)=IFIELD(1)
      ICHGRS(2,NCHGRS)=IFIELD(2)
      ICHGRS(3,NCHGRS)=JDATES(1,IDATE)
      IF(IRNGDT(IDATE).EQ.2)ICHGRS(3,NCHGRS)=JDATES(1,IDATM1)
      ICHGRS(4,NCHGRS)=JDATES(1,IDATE)
      ICHGRS(5,NCHGRS)=IFLAG-1
      IF(LBUG)WRITE(IODBUG,848)NCHGRS,(ICHGRS(I,NCHGRS),I=1,5)
  848 FORMAT(11X,'ENTRY NUMBER ',I2,' IN /FCHGRS/ - ',2A4,3I11)
C
  100 CONTINUE
      GO TO 1
C
  999 IF(LBUG)WRITE(IODBUG,902)NCHGRS
  902 FORMAT(11X,'** LEAVING MRAINS ** - NCHGRS = ',I2)
      IF(LBUG.AND.NCHGRS.GT.0)WRITE(IODBUG,846)
     1 ((ICHGRS(I,J),I=1,5),J=1,NCHGRS)
  846 FORMAT(11X,2A4,3I11)
C
      CALL FSTWHR(OLDOPN,IOLDOP,OLDOPN,IOLDOP)
C
      RETURN
      END
