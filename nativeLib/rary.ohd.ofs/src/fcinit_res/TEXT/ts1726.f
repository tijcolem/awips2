C MEMBER TS1726
C  (from old member FCTS1726)
C
      SUBROUTINE TS1726(WORK,IUSEW,LEFTW,NTS17,GETPC,
     .            LENDSU,JDEST,IERR)
C--------------------------------------------------------------------
C  ROUTINE TO GET AND CHECK TS SPECIFICATIONS FOR S/U #17 -
C  ADJUST POOL AND DISCHARGE UTILITY
C---------------------------------------------------------------------
C  JTOSTROWSKI - HRL - MARCH 1983
C----------------------------------------------------------------
C
C
      INCLUDE 'common/comn26'
C
C
      INCLUDE 'common/err26'
C
C
      INCLUDE 'common/fld26'
C
C
      INCLUDE 'common/read26'
C
C
      INCLUDE 'common/suin26'
C
C
      INCLUDE 'common/suky26'
C
C
      INCLUDE 'common/warn26'
C
C
      DIMENSION TSID(2,7),TSKEY(2,7),LKEY(7),IDT(7),DTYPE(7),ENTOUT(7)
      DIMENSION WORK(1),IT(7)
C
      LOGICAL TSOK(7),ALLOK,ENDFND,INFND,OUTFND,GETPC
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcinit_res/RCS/ts1726.f,v $
     . $',                                                             '
     .$Id: ts1726.f,v 1.1 1995/09/17 18:53:22 dws Exp $
     . $' /
C    ===================================================================
C
C
      DATA TSKEY/
     .            4HOBSQ,4HO   ,4HOBSQ,4HOM  ,4HOBSH,4H    ,
     .            4HADJQ,4HO   ,4HADJQ,4HOM  ,4HADJH,4H    ,
     .            4HADJS,4H    /
      DATA LKEY/2,2,1,2,2,1,1/
      DATA NKEY/7/
      DATA NTS/7/
      DATA NDKEY/2/
C
      DATA ENTOUT/0.01,0.01,0.01,1.01,1.01,1.01,1.01/
C
      DATA BLANK/4H    /
C
C  INITIALIZE LOCAL VARIABLES AND COUNTERS
C
      ALLOK = .TRUE.
      ENDFND = .FALSE.
      INFND = .FALSE.
      OUTFND = .FALSE.
      GETPC = .FALSE.
      NTSPXX = NTS
C
      DO 1 I=1,NTS
      TSID(1,I) = BLANK
      TSID(2,I) = BLANK
C
      IT(I) = 0
      TSOK(I) = .FALSE.
    1 CONTINUE
C
      NTS17 = 0
C
      IERR = 0
C
C  TS FOUND, LOOKING FOR ENDT
C
      LPOS = LSPEC + NCARD + 1
      LASTCD = LENDSU
      IBLOCK = 1
C
    5 IF (NCARD .LT. LASTCD) GO TO 8
           CALL STRN26(59,1,SUKYWD(1,9),3)
           IERR = 99
           GO TO 9
    8 NUMFLD = 0
      CALL UFLD26(NUMFLD,IERF)
      IF(IERF .GT. 0 ) GO TO 9000
      NUMWD = (LEN -1)/4 + 1
      IDEST = IKEY26(CHAR,NUMWD,SUKYWD,LSUKEY,NSUKEY,NDSUKY)
      IF (IDEST.EQ.0) GO TO 5
C
C  IDEST = 9 IS FOR ENDT
C
      IF (IDEST.EQ.9.OR.IDEST.EQ.10) GO TO 9
          CALL STRN26(59,1,SUKYWD(1,9),3)
          JDEST = IDEST
          IERR = 89
    9 LENDT = NCARD
C
C  ENDT CARD OR PARMS OR CO FOUND AT LENDT,
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
      IDEST = IKEY26(CHAR,NUMWD,TSKEY,LKEY,NKEY,NDKEY)
      IF(IDEST .GT. 0) GO TO 50
      IF(NCARD .GE. LENDT) GO TO 900
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
      NPR = IDEST
      GO TO (100,200,300,400,500,600,700), NPR
C
C----------------------------------------------------------------------
C  'OBSQO' FOUND. GET THE TS INFO FROM THE REST OF THE LINE.
C
  100 CONTINUE
      IT(NPR) = IT(NPR) + 1
      IF (IT(NPR).GT.1) CALL STER26(39,1)
C
C  INDICATE THAT AN INPUT TS WAS FOUND.
C
      INFND = .TRUE.
C
C  INDICATE THAT PARMS AND CARRYOVER INPUT IS ALLOWED (THESE ARE ONLY
C  NEEDED IF INSTANTANEOUS DATA IS USED FOR ADJUSTING.)
C
      GETPC = .TRUE.
C
C  GET INFO FROM REST OF LINE.
C
      CALL TSID26(TSID(1,NPR),DTYPE(NPR),IDT(NPR),TSOK(NPR))
      IF (.NOT.TSOK(NPR)) GO TO 10
C
C  TIME INTERVAL MUST BE MULTIPLE OF THE OPERATION TIME INTERVAL.
C
      IF (MOD(IDT(NPR),MINODT).EQ.0) GO TO 140
C
      CALL STER26(47,1)
      GO TO 10
C
C  SEE IF TIME SERIES EXISTS, MISSING ARE ALLOWED.
C
  140 CONTINUE
      CALL CHEKTS(TSID(1,NPR),DTYPE(NPR),IDT(NPR),0,DCODE,1,1,IERCK)
      IF (IERCK.EQ.0) GO TO 145
C
      CALL STER26(45,1)
      GO TO 10
C
C  CHECK UNITS FOR THIS TIME-SERIES.
C
  145 CONTINUE
      CALL FDCODE(DTYPE(NPR),UCODE,X,IX,IX,X,IX,IERD)
      IF (UCODE.EQ.UCMS) GO TO 150
C
      CALL STRN26(93,1,UCODE,1)
      GO TO 10
C
C  CHECK DIMENSIONS AGAINST ALLOWED FOR THIS TIME SERIES.
C
  150 CONTINUE
      IF (DCODE.EQ.DIMLT) GO TO 160
C
      CALL STER26(46,1)
      GO TO 10
C
C  SEE IF THIS TIME SERIES WAS ALREADY DEFINED, AND ADD ID TO LIST
C  OF INPUT TIME-SERIES IF IT'S NEW.
C
  160 CONTINUE
      IO = 0
      CALL MLTS26(TSID(1,NPR),DTYPE(NPR),IDT(NPR),IO,IERM)
      IF (IERM.GT.0) GO TO 10
C
C  INPUT IS OK
C
      TSOK(NPR) = .TRUE.
      GO TO 10
C
C----------------------------------------------------------------------
C  'OBSQOM' FOUND. GET THE TS INFO FROM THE REST OF THE LINE.
C
  200 CONTINUE
      IT(NPR) = IT(NPR) + 1
      IF (IT(NPR).GT.1) CALL STER26(39,1)
C
C  INDICATE THAT AN INPUT TS WAS FOUND.
C
      INFND = .TRUE.
C
C  GET INFO FROM REST OF LINE.
C
      CALL TSID26(TSID(1,NPR),DTYPE(NPR),IDT(NPR),TSOK(NPR))
      IF (.NOT.TSOK(NPR)) GO TO 10
C
C  TIME INTERVAL MUST BE MULTIPLE OF THE OPERATION TIME INTERVAL.
C
      IF (MOD(IDT(NPR),MINODT).EQ.0) GO TO 240
C
      CALL STER26(47,1)
      GO TO 10
C
C  SEE IF TIME SERIES EXISTS, MISSING ARE ALLOWED.
C
  240 CONTINUE
      CALL CHEKTS(TSID(1,NPR),DTYPE(NPR),IDT(NPR),0,DCODE,1,1,IERCK)
      IF (IERCK.EQ.0) GO TO 245
C
      CALL STER26(45,1)
      GO TO 10
C
C  CHECK UNITS FOR THIS TIME-SERIES.
C
  245 CONTINUE
      CALL FDCODE(DTYPE(NPR),UCODE,X,IX,IX,X,IX,IERD)
      IF (UCODE.EQ.UCMSD) GO TO 250
C
      CALL STRN26(93,1,UCODE,1)
      GO TO 10
C
C  CHECK DIMENSIONS AGAINST ALLOWED FOR THIS TIME SERIES.
C
  250 CONTINUE
      IF (DCODE.EQ.DIML3) GO TO 260
C
      CALL STER26(46,1)
      GO TO 10
C
C  SEE IF THIS TIME SERIES WAS ALREADY DEFINED, AND ADD ID TO LIST
C  OF INPUT TIME-SERIES IF IT'S NEW.
C
  260 CONTINUE
      IO = 0
      CALL MLTS26(TSID(1,NPR),DTYPE(NPR),IDT(NPR),IO,IERM)
      IF (IERM.GT.0) GO TO 10
C
C  INPUT IS OK
C
      TSOK(NPR) = .TRUE.
      GO TO 10
C
C----------------------------------------------------------------------
C  'OBSH' FOUND. GET THE TS INFO FROM THE REST OF THE LINE.
C
  300 CONTINUE
      IT(NPR) = IT(NPR) + 1
      IF (IT(NPR).GT.1) CALL STER26(39,1)
C
C
C  INDICATE THAT AN INPUT TS WAS FOUND.
C
      INFND = .TRUE.
C
C  GET INFO FROM REST OF LINE.
C
      CALL TSID26(TSID(1,NPR),DTYPE(NPR),IDT(NPR),TSOK(NPR))
      IF (.NOT.TSOK(NPR)) GO TO 10
C
C  TIME INTERVAL MUST BE MULTIPLE OF THE OPERATION TIME INTERVAL.
C
      IF (MOD(IDT(NPR),MINODT).EQ.0) GO TO 340
C
      CALL STER26(47,1)
      GO TO 10
C
C  SEE IF TIME SERIES EXISTS, MISSING ARE ALLOWED.
C
  340 CONTINUE
      CALL CHEKTS(TSID(1,NPR),DTYPE(NPR),IDT(NPR),0,DCODE,1,1,IERCK)
      IF (IERCK.EQ.0) GO TO 345
C
      CALL STER26(45,1)
      GO TO 10
C
C  CHECK UNITS FOR THIS TIME-SERIES.
C
  345 CONTINUE
      CALL FDCODE(DTYPE(NPR),UCODE,X,IX,IX,X,IX,IERD)
      IF (UCODE.EQ.UM) GO TO 350
C
      CALL STRN26(93,1,UCODE,1)
      GO TO 10
C
C  CHECK DIMENSIONS AGAINST ALLOWED FOR THIS TIME SERIES.
C
  350 CONTINUE
      IF (DCODE.EQ.DIML) GO TO 360
C
      CALL STER26(46,1)
      GO TO 10
C
C  SEE IF THIS TIME SERIES WAS ALREADY DEFINED, AND ADD ID TO LIST
C  OF INPUT TIME-SERIES IF IT'S NEW.
C
  360 CONTINUE
      IO = 0
      CALL MLTS26(TSID(1,NPR),DTYPE(NPR),IDT(NPR),IO,IERM)
      IF (IERM.GT.0) GO TO 10
C
C  INPUT IS OK
C
      TSOK(NPR) = .TRUE.
      GO TO 10
C
C----------------------------------------------------------------------
C  'ADJQO' FOUND. GET INFO FROM REST OF LINE.
C
  400 CONTINUE
      IT(NPR) = IT(NPR) + 1
      IF (IT(NPR).GT.1) CALL STER26(39,1)
C
C  INDICATE THAT AN OUTPUT TIME SERIES WAS FOUND.
C
      OUTFND = .TRUE.
C
C  GET REST OF TS SPECIFICATION
C
      CALL TSID26(TSID(1,NPR),DTYPE(NPR),IDT(NPR),TSOK(NPR))
      IF (.NOT.TSOK(NPR)) GO TO 10
C
C  SEE IF TIME INTERVAL IS MULTIPLE OF OPERATION TIME INTERVAL.
C
      IF (MOD(IDT(NPR),MINODT).EQ.0) GO TO 440
C
      CALL STER26(47,1)
      GO TO 10
C
C  SEE IF TIME SERIES EXISTS, MISSING NOT ALLOWED.
C
  440 CONTINUE
      CALL CHEKTS(TSID(1,NPR),DTYPE(NPR),IDT(NPR),0,DCODE,0,1,IERCK)
      IF (IERCK.EQ.0) GO TO 445
C
      CALL STER26(45,1)
      GO TO 10
C
C  CHECK UNITS FOR THIS TIME-SERIES.
C
  445 CONTINUE
      CALL FDCODE(DTYPE(NPR),UCODE,X,IX,IX,X,IX,IERD)
      IF (UCODE.EQ.UCMS) GO TO 450
C
      CALL STRN26(93,1,UCODE,1)
      GO TO 10
C
C  CHECK DIMENSIONS AGAINST ALLOWED FOR THIS TIME SERIES.
C
  450 CONTINUE
      IF (DCODE.EQ.DIMLT) GO TO 460
C
      CALL STER26(46,1)
      GO TO 10
C
C  SEE IF THIS TIME SERIES WAS ALREADY DEFINED, AND ADD ID TO LIST
C  OF INPUT TIME-SERIES IF IT'S NEW.
C
  460 CONTINUE
      IO = 1
      CALL MLTS26(TSID(1,NPR),DTYPE(NPR),IDT(NPR),IO,IERM)
      IF (IERM.GT.0) GO TO 10
C
C  INPUT IS OK
C
      TSOK(NPR) = .TRUE.
      GO TO 10
C
C----------------------------------------------------------------------
C  'ADJQOM' FOUND. GET INFO FROM REST OF LINE.
C
  500 CONTINUE
      IT(NPR) = IT(NPR) + 1
      IF (IT(NPR).GT.1) CALL STER26(39,1)
C
C  INDICATE THAT AN OUTPUT TIME SERIES WAS FOUND.
C
      OUTFND = .TRUE.
C
C  GET REST OF TS SPECIFICATION
C
      CALL TSID26(TSID(1,NPR),DTYPE(NPR),IDT(NPR),TSOK(NPR))
      IF (.NOT.TSOK(NPR)) GO TO 10
C
C  SEE IF TIME INTERVAL IS MULTIPLE OF OPERATION TIME INTERVAL.
C
      IF (MOD(IDT(NPR),MINODT).EQ.0) GO TO 540
C
      CALL STER26(47,1)
      GO TO 10
C
C  SEE IF TIME SERIES EXISTS, MISSING NOT ALLOWED.
C
  540 CONTINUE
      CALL CHEKTS(TSID(1,NPR),DTYPE(NPR),IDT(NPR),0,DCODE,0,1,IERCK)
      IF (IERCK.EQ.0) GO TO 545
C
      CALL STER26(45,1)
      GO TO 10
C
C  CHECK UNITS FOR THIS TIME-SERIES.
C
  545 CONTINUE
      CALL FDCODE(DTYPE(NPR),UCODE,X,IX,IX,X,IX,IERD)
      IF (UCODE.EQ.UCMSD) GO TO 550
C
      CALL STRN26(93,1,UCODE,1)
      GO TO 10
C
C  CHECK DIMENSIONS AGAINST ALLOWED FOR THIS TIME SERIES.
C
  550 CONTINUE
      IF (DCODE.EQ.DIML3) GO TO 560
C
      CALL STER26(46,1)
      GO TO 10
C
C  SEE IF THIS TIME SERIES WAS ALREADY DEFINED, AND ADD ID TO LIST
C  OF INPUT TIME-SERIES IF IT'S NEW.
C
  560 CONTINUE
      IO = 1
      CALL MLTS26(TSID(1,NPR),DTYPE(NPR),IDT(NPR),IO,IERM)
      IF (IERM.GT.0) GO TO 10
C
C  INPUT IS OK
C
      TSOK(NPR) = .TRUE.
      GO TO 10
C
C----------------------------------------------------------------------
C  'ADJH' FOUND. GET INFO FROM REST OF LINE.
C
  600 CONTINUE
      IT(NPR) = IT(NPR) + 1
      IF (IT(NPR).GT.1) CALL STER26(39,1)
C
C  INDICATE THAT AN OUTPUT TIME SERIES WAS FOUND.
C
      OUTFND = .TRUE.
C
C  GET REST OF TS SPECIFICATION
C
      CALL TSID26(TSID(1,NPR),DTYPE(NPR),IDT(NPR),TSOK(NPR))
      IF (.NOT.TSOK(NPR)) GO TO 10
C
C  SEE IF TIME INTERVAL IS MULTIPLE OF OPERATION TIME INTERVAL.
C
      IF (MOD(IDT(NPR),MINODT).EQ.0) GO TO 640
C
      CALL STER26(47,1)
      GO TO 10
C
C  SEE IF TIME SERIES EXISTS, MISSING NOT ALLOWED.
C
  640 CONTINUE
      CALL CHEKTS(TSID(1,NPR),DTYPE(NPR),IDT(NPR),0,DCODE,0,1,IERCK)
      IF (IERCK.EQ.0) GO TO 645
C
      CALL STER26(45,1)
      GO TO 10
C
C  CHECK UNITS FOR THIS TIME-SERIES.
C
  645 CONTINUE
      CALL FDCODE(DTYPE(NPR),UCODE,X,IX,IX,X,IX,IERD)
      IF (UCODE.EQ.UM) GO TO 650
C
      CALL STRN26(93,1,UCODE,1)
      GO TO 10
C
C  CHECK DIMENSIONS AGAINST ALLOWED FOR THIS TIME SERIES.
C
  650 CONTINUE
      IF (DCODE.EQ.DIML) GO TO 660
C
      CALL STER26(46,1)
      GO TO 10
C
C  SEE IF THIS TIME SERIES WAS ALREADY DEFINED, AND ADD ID TO LIST
C  OF INPUT TIME-SERIES IF IT'S NEW.
C
  660 CONTINUE
      IO = 1
      CALL MLTS26(TSID(1,NPR),DTYPE(NPR),IDT(NPR),IO,IERM)
      IF (IERM.GT.0) GO TO 10
C
C  INPUT IS OK
C
      TSOK(NPR) = .TRUE.
      GO TO 10
C
C----------------------------------------------------------------------
C  'ADJS' FOUND. GET INFO FROM REST OF LINE.
C
  700 CONTINUE
      IT(NPR) = IT(NPR) + 1
      IF (IT(NPR).GT.1) CALL STER26(39,1)
C
C  INDICATE THAT AN OUTPUT TIME SERIES WAS FOUND.
C
      OUTFND = .TRUE.
C
C  GET REST OF TS SPECIFICATION
C
      CALL TSID26(TSID(1,NPR),DTYPE(NPR),IDT(NPR),TSOK(NPR))
      IF (.NOT.TSOK(NPR)) GO TO 10
C
C  SEE IF TIME INTERVAL IS MULTIPLE OF OPERATION TIME INTERVAL.
C
      IF (MOD(IDT(NPR),MINODT).EQ.0) GO TO 740
C
      CALL STER26(47,1)
      GO TO 10
C
C  SEE IF TIME SERIES EXISTS, MISSING NOT ALLOWED.
C
  740 CONTINUE
      CALL CHEKTS(TSID(1,NPR),DTYPE(NPR),IDT(NPR),0,DCODE,0,1,IERCK)
      IF (IERCK.EQ.0) GO TO 745
C
      CALL STER26(45,1)
      GO TO 10
C
C  CHECK UNITS FOR THIS TIME-SERIES.
C
  745 CONTINUE
      CALL FDCODE(DTYPE(NPR),UCODE,X,IX,IX,X,IX,IERD)
      IF (UCODE.EQ.UCMSD) GO TO 750
C
      CALL STRN26(93,1,UCODE,1)
      GO TO 10
C
C  CHECK DIMENSIONS AGAINST ALLOWED FOR THIS TIME SERIES.
C
  750 CONTINUE
      IF (DCODE.EQ.DIML3) GO TO 760
C
      CALL STER26(46,1)
      GO TO 10
C
C  SEE IF THIS TIME SERIES WAS ALREADY DEFINED, AND ADD ID TO LIST
C  OF INPUT TIME-SERIES IF IT'S NEW.
C
  760 CONTINUE
      IO = 1
      CALL MLTS26(TSID(1,NPR),DTYPE(NPR),IDT(NPR),IO,IERM)
      IF (IERM.GT.0) GO TO 10
C
C  INPUT IS OK
C
      TSOK(NPR) = .TRUE.
      GO TO 10
C
C------------------------------------------------------------------
C  'ENDT' FOUND. STORE TS INFO IF INPUT WAS ERROR FREE
C
  900 CONTINUE
C
      DO 905 I =1,NTS
           IF (IT(I).EQ.0) TSOK(I) = .TRUE.
  905 CONTINUE
C
C
C  AN INPUT AND OUTPUT TIME SERIES MUST HAVE BEEN FOUND.
C
      IF (INFND.AND.OUTFND) GO TO 910
C
      CALL STER26(70,1)
      GO TO 9999
C
C  NO ERRORS IN TS SPECIFICATION MUST HAVE OCCURRED.
C
  910 CONTINUE
      IF (.NOT.ALLOK) GO TO 9999
C
      DO 920 I=1,NTS
      IF (.NOT.TSOK(I)) GO TO 9999
  920 CONTINUE
C
      DO 990 NPR = 1,NTS
C
      CALL FLWK26(WORK,IUSEW,LEFTW,TSID(1,NPR),501)
      CALL FLWK26(WORK,IUSEW,LEFTW,TSID(2,NPR),501)
      NEXTRA = 2
C
C  IF NO TIME SERIES WAS ENTERED FOR THAT TYPE. ONLY STORE
C  THE BLANK ID
C
      IF (IT(NPR) .EQ. 0) GO TO 940
C
      CALL FLWK26(WORK,IUSEW,LEFTW,DTYPE(NPR),501)
      DT = IDT(NPR) + 0.01
      CALL FLWK26(WORK,IUSEW,LEFTW,DT,501)
      CALL FLWK26(WORK,IUSEW,LEFTW,ENTOUT(NPR),501)
      NEXTRA = 5
C
  940 CONTINUE
      NTS17 = NTS17 + NEXTRA
C
  990 CONTINUE
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
C
      RETURN
      END
