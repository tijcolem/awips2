C MODULE CARD51
C--------------------------------------------------------------------
C
      SUBROUTINE CARD51
C
C DESC READS INPUT CARDS FOR SSARRESV OPERATION AND WRITES TO UNIT 89
C...................................................................
C
C  READS ALL INPUT CARDS FOR SSARRESV OPERATION (QUITS UPON 'END' CARD),
C  MARKS LOCATION (I.E. LINE NUMBER) OF 'SAR', 'UPERBKWR', 'LWERBKWR', 
C  AND '3-VAR' LINES IF FOUND.
C  A MISSING KEY COMMAND IS MARKED BY A LOCATION OF ZERO.
C
C  INPUT IS WRITTEN TO UNIT 89 TO ALLOW REWINDING AND BACKSPACING OF
C  INPUT RECORDS.
C
C.......................................................................
C
C  KUANG HSU  - HRL - APRIL 1994
C................................................................
      INCLUDE 'uiox'
      INCLUDE 'common/fdbug'
      INCLUDE 'common/comn51'
      INCLUDE 'common/err51'
      INCLUDE 'common/read51'
      INCLUDE 'common/fld51'

      DIMENSION LOC(5),TYPE(2,5),NTOTAL(5),ETYPE(2,5),SEEK(1)
      DIMENSION LOC1(2),TYPE1(2,2),CHAR80(20)
C
      EQUIVALENCE (LOC(1),LINFL),(LOC(2),LUPB),(LOC(3),LSAR),
     &            (LOC(4),LTRP),(LOC(5),LLWB)
      EQUIVALENCE (NTOTAL(1),NINFL),(NTOTAL(2),NUPB),
     &            (NTOTAL(3),NSAR),(NTOTAL(4),NTRP),(NTOTAL(5),NLWB)
      EQUIVALENCE (LOC1(1),LTITLE),(LOC1(2),LUNITS)
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcinit_ssarresv/RCS/card51.f,v $
     . $',                                                             '
     .$Id: card51.f,v 1.3 2001/06/13 09:58:29 mgm Exp $
     . $' /
C    ===================================================================
C
C
      DATA  TYPE1/4HTITL,4HE   ,4HUNIT,4HS   /
      DATA  TYPE/4HINFL,4HOW  ,4HUPER,4HBKWR,4HSAR ,4H    ,
     &           4H3-VA,4HR   ,4HLWER,4HBKWR/
      DATA ETYPE/4HENDI,4HNFLW,4HENDU,4HPERB,4HENDS,4HAR  ,
     &           4HEND3,4H-VAR,4HENDL,4HWERB/
      DATA SEEK/4HEND /
C
      NSEEK = 1
      NUMERR = 0
C
C  TRANSFER ALL INPUT FOR SSARRESV FROM UNIT 5 TO UNIT 89
C
      CALL TRAN51(SEEK,NSEEK)
C
      IF(IBUG.LE.1) GO TO 30
      REWIND MUNI51
      DO 20 I=1,NCD51
      READ(MUNI51,10,END=30) CHAR80
 10   FORMAT(20A4)
      WRITE(IODBUG,11) I,CHAR80
 11   FORMAT(1X,I3,1X,20A4)
 20   CONTINUE
 30   IF (NUMERR.GT.0) CALL EROT51
C
C  INITIALIZE LOCATIONS AND COUNTERS,
C  LOC(I) AND NTOTAL(I) HAVE ALSO BEEN
C  INTIALIZED THRU EQUIVALENCE HERE.
C
      LTITLE = 0
      LUNITS = 0
      LINFL = 0
      LSAR = 0
      LUPB = 0
      LLWB = 0
      LTRP = 0
      NINFL = -999
      NSAR = -999
      NUPB = -999
      NLWB = -999
      NTRP = -999
      MUNI51 = 89
      IOLICD = ICD
      ICD = MUNI51
      NCHAR = 25
C
C  REDEFINE TOTAL NUMBER OF INPUT CARDS WITHOUT
C  COMMENT CARDS
      REWIND MUNI51
      USEDUP = .FALSE.
      NF51 = 0
      DO 290 J=1,NCD51
      JS = J
      CALL UFLD51(NF51,IRF)
      IF(IRF.EQ.3) GO TO 295
 290  CONTINUE
 295  NCD51 = JS-1
      IRF = 0
C
C
C  LOOP THROUGH ALL INPUT LOOKING FOR (IN ORDER) THE FIELDS, AS THE
C  FIRST FIELDS ON THE LINES OF INPUT, 'TITLE', AND 'UNITS'.
C
      DO 200 I=1,2
      REWIND MUNI51
      USEDUP = .FALSE.
      NF51 = 0
      NCARD = 0
C
      DO 190 J=1,NCD51
C
      CALL UFLD51(NF51,IRF)
      IF (IRF.GT.0) GO TO 190
      IF (LEN.GT.8) GO TO 190
C
C  LOOK FOR MATCH WITH FIRST FIELD ON CARD
C
      IF (IUSAME(CHAR(1),TYPE1(1,I),2).NE.1) GO TO 190
C
C  MATCH FOUND MARK LOCATION
C
      LOC1(I) = NCARD
      GO TO 200
C
  190 CONTINUE
  200 CONTINUE
C
C  LOOP THROUGH ALL INPUT LOOKING FOR (IN ORDER) THE FIELDS, AS THE
C  FIRST FIELDS ON THE LINES OF INPUT, 'INFLOW', 'SAR'. 'UPERBKWR',
C  'LWERBKWR', AND '3-VAR'
C
      DO 100 I=1,5
      REWIND MUNI51
      USEDUP = .FALSE.
      NF51 = 0
      NCARD = 0
C
      DO 90 J=1,NCD51
C
C  IF HEADER CARD FOR SECTION ALREADY FOUND, LOOK FOR END CARD
C
      IF (LOC(I).GT.0) GO TO 25
C
      CALL UFLD51(NF51,IRF)
      IF (IRF.GT.0) GO TO 90
      IF (LEN.GT.8) GO TO 90
C
C  LOOK FOR MATCH WITH FIRST FIELD ON CARD
C
      IF (IUSAME(CHAR(1),TYPE(1,I),2).NE.1) GO TO 90
C
C  MATCH FOUND MARK LOCATION
C
      LOC(I) = NCARD
C
C  NOW LOOK FOR END CARD FOR SECTION
C
   25 CALL UFLD51(NF51,IRF)
      IF (IRF.GT.0) GO TO 90
      IF (LEN.GT.8) GO TO 90
C
      IF (IUSAME(CHAR(1),ETYPE(1,I),2).NE.1) GO TO 90
C
C  SET NUMBER OF CARDS IN THIS SECTION IF MATCH IS FOUND
C
      NTOTAL(I) = NCARD-LOC(I)+1
      GO TO 100
C
   90 CONTINUE
  100 CONTINUE
C
      ICD = IOLICD
C
      RETURN
      END
