C MEMBER GSIXFL
C  (from old member PPGSIXFL)
C
      SUBROUTINE GSIXFL(PG24, GP6, W6, PPVR, PTVR, GP24, WP, NUM)
C
C.....THIS SUBROUTINE FILLS UP THE PERMANENT BASIC SIX HOURLY DATA ARRAY
C.....ARRAYS WITH THE PRECIP DATA AND THE PERCENTAGE DISTRIBUTION
C.....FACTORS.
C
C.....THE SUBROUTINE HAS THE FOLLOWING ARGUMENTS:
C
C.....PG24   - THE 24-HOUR PRECIPITATION ARRAY.
C.....GP6    - POINTER TO W6 ARRAY.
C.....W6     - THE 6-HOUR DISTRIBUTION PERCENTAGE ARRAY.
C.....PPVR   - THE ARRAY OF LESS THAN 24-HOUR PRECIPITATION.
C.....PTVR   - THE PPVR POINTER ARRAY.
C.....GP24   - THE GP24 PARAMETRIC ARRAY.
C.....WP     - A POINTER TO THE NEXT AVAILABLE ADDRESS IN THE WY ARRAY.
C.....NUM    - THE NUMBER OF PPVR DATA ELEMENTS RETURNED FROM THE PPDB.
C
C.....JERRY M. NUNN, WGRFC FT. WORTH       AUGUST 1986
C
C
      INCLUDE 'gcommon/explicit'
      INTEGER*2 PPVR(1), PTVR(1), GP24(1), PG24(1), GP6(1), W6(1)
C
      DIMENSION SNAME(2)
C
      INCLUDE 'common/where'
      INCLUDE 'common/ionum'
      INCLUDE 'common/pudbug'
      INCLUDE 'common/errdat'
      INCLUDE 'gcommon/gsize'
      INCLUDE 'gcommon/gopt'
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcst_maro/RCS/gsixfl.f,v $
     . $',                                                             '
     .$Id: gsixfl.f,v 1.1 1995/09/17 19:02:37 dws Exp $
     . $' /
C    ===================================================================
C
C
      DATA SNAME /4hGSIX, 4hFL  /
      DATA GSIX, PVRTYP, PPVRX, GGP6 /4hGSIX, 4hPVRX, 4hPPVR, 4hGP6 /
C
C
  900 FORMAT(1H0, '*** GSIXFL ENTERED ***')
  901 FORMAT(1H0, '*** EXIT GSIXFL ***')
  902 FORMAT(1H0, '*** 6HR PERCENTAGE COMPUTATIONS -- BASED ON LESS THAN
     * 24HR (PPVR) PRECIPITATION ***')
  903 FORMAT(5X, 'TIME INTERVAL IN HRS', 11X, '= ', I5)
  904 FORMAT(3X, 'BEGINNING POINTER ARRAY LOCATION = ', I5)
  905 FORMAT(5X, 'PPVR POINTER ARRAY ADDRESS ', I4, ' CONTAINS ', I4,
     * '.  THIS POINTS TO PP24 DATA ARRAY LOCATION ', I4, ' AND GP24 ARR
     *AY LOCATION ', I4, '.', /, 5X, 'GP24 ARRAY LOCATION ', I4, ' CONTA
     *INS GRID POINT ADDRESS ', I4, '.')
  906 FORMAT(5X, 'PG24(', I5, ') = ', I5)
  907 FORMAT(7X, 'W6(', I5, ') = ', I5)
  908 FORMAT(6X, 'GP6(', I5, ') = ', I5)
  909 FORMAT(1X, '*** THERE ARE ', I5, ' STATIONS WITH VALID SIX-HOURLY
     *DATA ***')
  910 FORMAT(1H0, '*** WARNING ***  6-HOURLY PRECIPITATION AMOUNT OF ',
     * I6, ' AT ARRAY LOCATION ', I4, ' IS OUT OF PERMISSIBLE RANGE.',
     * /, 5X, 'THE AMOUNT IS BEING SET TO ZERO.')
  911 FORMAT(5X, 'PPVR(', I4, ') CHANGED FROM ', I6, ' TO ', I6)
  912 FORMAT(5X, 'GRID POINT ADDRESS IS ', I5, '...NO ENTRY FOR THIS STA
     *TION EXISTS IN THE PG24 ARRAY.')
  913 FORMAT(1H0, '*** LAST USED SLOT IN THE W6 ARRAY (WP) = ', I10,
     * ' ***')
  914 FORMAT(1H0, '*** WARNING ***  A TIME INTERVAL OF ZERO WAS FOUND IN
     * THE PPVR POINTERS ARRAY.', /, 1X, 'THIS OCCURRED ', I4, ' TIMES.
     *THE STATION(S) CONTAINING THE INVALID DATA WERE NOT PROCESSED.')
C
C.....SET WHERE.
C
      OPNAME(1) = SNAME(1)
      OPNAME(2) = SNAME(2)
      IOPNUM    = -1
      IXERR     =  0
C
      IBUG = IPBUG(GSIX)
      JBUG = IPBUG(PVRTYP)
      KBUG = IPBUG(PPVRX)
C
C.....CHECK TRACE LEVEL, AND SPIT OUT OBLIGATORY MESSAGE IF DEEMED NECES
C.....TO BE NECESSARY.
C
      IF(IPTRCE .GE. 3) WRITE(IOPDBG,900)
      IF(IBUG .EQ. 1) WRITE(IOPDBG,902)
C
C.....GET READY TO COMPUTE NORMALIZED 6 HOUR AMOUNTS IN TERMS OF THE
C.....PERCENTAGE OF THE 24 HOUR TOTAL.
C
C.....SCAN THE ARRAY OF LESS THAN 24 HOUR PRECIPITATION VALUES. IF THERE
C.....ARE PRESENT ANY NON-SIX HOUR AMOUNTS...IGNORE THEM.
C
C
C.....DUMP OUT PPVR ARRAY...IF SUCH IS CALLED FOR.
C
      IF(JBUG .EQ. 1) CALL GPDDMP(PPVRX, NUM, PPVR)
      IF(KBUG .EQ. 1) CALL GLPTVR(NUM, PTVR)
C
      N6 = 0
      JP = 1
C
      DO 400 NP = 1, NUM, 4
      IF(IBUG. EQ. 1) WRITE(IOPDBG,904) NP
C
C.....THE POINTER ARRAY FOR LESS THAN 24 HOUR PRECIPITATION HAS THE
C.....TIME INTERVAL.
C
      NX = PTVR(NP+2)
      IF(IBUG .EQ. 1) WRITE(IOPDBG,903) NX
C
C.....DO NOT USE THE TIME INTERVAL IF IT IS NOT SIX HOURS. FOR SURE
C.....DO NOT USE THE TIME INTERVAL IF IT IS ZERO.
C
      IF(NX .EQ. 0) GOTO 292
      IF(NX .EQ. 6) GOTO 293
      GOTO 303
C
  292 IXERR = IXERR + 1
      GOTO 303
C
  293 LP = 24/NX
C
C.....GET THE POINTER FOR THE LOCATION OF THE 24 HOUR PRECIPITATION, IF
C.....ONE IS PRESENT.
C
      MP = NP + 1
      IP = PTVR(MP)
      KP = IP/5 + 1
      LX = 2*KP - 1
      IPGRID = GP24(LX)
      IF(IBUG .EQ. 1) WRITE(IOPDBG,905) MP, IP, KP, LX, LX, IPGRID
C
      IF(IPGRID .LT. 100) GOTO 294
      IF(IBUG .EQ. 1) WRITE(IOPDBG,906) IPGRID, PG24(IPGRID)
      GOTO 295
C
  294 IF(IBUG .EQ. 1) WRITE(IOPDBG,912) IPGRID
      GOTO 303
C
C.....GET THE SUM OF THE SIX HOURLY PRECIPITATION VALUES.
C
  295 ISUM = 0
      MP = JP - 1 + LP
C
      DO 301 KX = JP, MP
C
C.....IF THE 6-HR PRECIP IS OUT OF RANGE...SET TO ZERO AND ISSUE
C.....WARNING.
C
      IF(PPVR(KX) .GT. MAXPC6) GOTO 297
      IF(PPVR(KX) .GE. 0) GOTO 299
C
C.....WHEN MISSING 6-HOUR REPORTS ARE ENCOUNTERED...DO NOT ATTEMPT TO
C.....USE THEM IN THE COMPUTATION OF THE SUM.
C
C.....IF THERE IS AN ESTIMATION ROUTINE AVAILABLE FOR 6-HOURLY DATA,
C.....AND THE SIX-HOURLY ESTIMATION FLAG IS ON...CALL THE SUBROUTINE.
C.....OTHERWISE...SET THE MISSING 6-HOUR REPORT TO ZERO.
C
      IF(PPVR(KX) .EQ. MSNG6) GOTO 296
C
  297 WRITE(IPR,910) PPVR(KX), KX
      CALL WARN
      GOTO 298
C
  296 IF(NOEST6 .EQ. 0) GOTO 298
  298 PPVR(KX) = 0
      IF(JBUG .EQ. 1) WRITE(IOPDBG,911) KX, MSNG6, PPVR(KX)
  299 ISUM = ISUM + PPVR(KX)
  301 CONTINUE
      IF(ISUM .LE. 0) GOTO 303
      SUM = ISUM
C
C.....UPDATE THE COUNT OF THE NUMBER OF SIX HOUR VALUES WE HAVE
C.....PROCESSED.
C
      N6 = N6 + 1
C
C.....NOW COMPUTE THE NORMALIZED VALUES, WHICH ARE PERCENTAGES OF THE
C.....TOTAL PRECIPITATION FALLEN IN EACH SIX HOUR PERIOD.
C
      NN = -1
      K  = 0
C
      DO 302 KX = JP, MP
      PP6 = PPVR(KX)
      PCT = PP6/SUM
      K = K + 1
C
C.....STORE THE NORMALIZED VALUE IN THE NEXT AVAILABLE SPACE IN THE
C.....W6 ARRAY.
C
      WP = (N6-1)*4 + K
C
C.....IF THIS IS THE BEGINNING ENTRY OF THE PERCENTAGE DISTRIBUTION FOR
C.....A NEW STATION, STORE THE BEGINNING ADDRESS, SO WE WILL LATER KNOW
C.....WHERE TO FIND IT.
C
      IF(K .EQ. 1) NN = WP
C
      W6(WP) = (PCT*100.) + 0.5
      IF(IBUG .EQ. 1) WRITE(IOPDBG,907) WP, W6(WP)
C
  302 CONTINUE
C
C.....STORE IN THE GP6 ARRAY A POINTER TO THE BEGINNING ADDRESS OF THE
C.....NORMALIZED DISTRIBUTION. THE LOCATION IN THE GP6 ARRAY IS THE
C.....LOCATION CORRESPONDING TO THE GRID POINT ADDRESS OF THE STATION
C.....THAT WE ARE PROCESSING.
C
      GP6(IPGRID) = NN
      IF(IBUG. EQ. 1) WRITE(IOPDBG,908) IPGRID, GP6(IPGRID)
C
C.....END OF LOOP. BEFORE GOING THRU THE NEXT PASS OF THE LOOP, UPDATE
C.....THE BEGINNING ADDRESS OF THE PPVR ARRAY TO BEGIN LOOKING AT THE
C.....NEXT STATION'S DATA.
C
  303 JP = JP + LP
C
  400 CONTINUE
C
      IF(IXERR .LT. 1) GOTO 410
      WRITE(IPR,914) IXERR
      NWARN = NWARN + IXERR
      CALL WARN
C
  410 IF(IBUG .EQ. 1) WRITE(IOPDBG,909) N6
C
C.....WRITE THE MESSAGE, IF THE TRACE LEVEL IS OF A SUFFICIENT
C.....MAGNITUDE.
C
      IF(IPTRCE .GE. 3) WRITE(IOPDBG,901)
C
      IF(IBUG .EQ. 1) WRITE(IOPDBG,913) WP
C
      RETURN
      END
