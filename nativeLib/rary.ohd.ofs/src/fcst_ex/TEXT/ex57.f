C MEMBER EX57
C-----------------------------------------------------------------------
C
C                             LAST UPDATE:
C
C @PROCESS LVL(77)
C
      SUBROUTINE EX57 (P,C,T,PE,QNAT,QADJ,QDIV,QRFIN,QRFOUT,QOL,QCD,CE)

C     THIS IS THE EXECUTION ROUTINE FOR CONSUMPTIVE USE

C     THIS ROUTINE INITIALLY WRITTEN BY
C          JOE PICA  --  NWRFC    JUNE 1997

C        1         2         3         4         5         6         7
C23456789012345678901234567890123456789012345678901234567890123456789012

C     POSITION     CONTENTS OF P ARRAY
C      1           VERSION NUMBER OF OPERATION
C      2-19        GENERAL NAME OR TITLE

C     TEMPERATURE INPUT FOR ESTIMATING ET
C     20-21       MEAN AREAL TEMPERATURE TIME SERIES IDENTIFIER
C     22          MEAN AREAL TEMPERATURE DATA TYPE CODE

C     POTENTIAL EVAPORATION INPUT FOR ESTIMATING ET
C     23-24       POTENTIAL EVAPORATION TIME SERIES IDENTIFIER
C     25          POTENTIAL EVAPORATION DATA TYPE CODE

C     NATURAL FLOW WHICH IS AVAILABLE FOR DIVERSIONS
C     26-27       NATURAL FLOW TIME SERIES IDENTIFIER
C     28          NATURAL FLOW DATA TYPE CODE

C     FLOW AFTER ACCOUNTING FOR DIVERSIONS AND RETURN FLOW OUT
C     29-30       ADJUSTED FLOW TIME SERIES IDENTIFIER
C     31          ADJUSTED FLOW DATA TYPE CODE

C     WATER DIVERTED BASED ON CROP DEMAND AND IRRIGATION EFFICIENCY
C     32-33       DIVERSION FLOW TIME SERIES IDENTIFIER
C     34          DIVERSION FLOW DATA TYPE CODE

C     RETURN FLOW STORAGE ACCUMULATION
C     RETURN FLOW IN IS A FRACTION OF THE DIVERSION FLOW
C     35-36       RETURN FLOW IN TIME SERIES IDENTIFIER
C     37          RETURN FLOW IN DATA TYPE CODE

C     RETURN FLOW STORAGE DECAY
C     RETURN FLOW OUT IS PART OF THE ADJUSTED FLOW
C     38-39       RETURN FLOW OUT TIME SERIES IDENTIFIER
C     40          RETURN FLOW OUT DATA TYPE CODE

C     OTHER LOSSES ARE TRANSPORTATION AND SUBSURFACE LOSSES
C     OTHER LOSSES ARE A FRACTION OF THE DIVERSION FLOW
C     41-42       OTHER LOSSES FLOW TIME SERIES IDENTIFIER
C     43          OTHER LOSSES FLOW DATA TYPE CODE

C     CROP DEMAND IS THE AMOUNT OF FLOW REQUIRED FOR THE CROPS
C     CROP DEMAND IS A FRACTION OF THE DIVERSION FLOW
C     44-45       CROP DEMAND FLOW TIME SERIES IDENTIFIER
C     46          CROP DEMAND FLOW DATA TYPE CODE

C     CROP EVAPOTRANSPIRATION
C     47-48       CROP EVAPOTRANSPIRATION TIME SERIES IDENTIFIER
C     49          CROP EVAPOTRANSPIRATION DATA TYPE CODE

C     50              OPTION FOR ET ESTIMATION METHOD
C     51              LATTITUDE OF IRRIGATED AREA
C     52              IRRIGATED AREA
C     53              IRRIGATION EFFICIENCY
C     54              MINIMUM FLOW
C     55              RETURN FLOW ACCUMULATION RATE
C     56              RETURN FLOW DECAY RATE
C     57              ANNUAL DAYLIGHT HOURS

C     58-422          DAILY EMPIRICAL CROP/METEOROLOGICAL
C                     COEFFICIENTS

C     THE NUMBER OF ELEMENTS REQUIRED IN THE P ARRAY IS  422

C     POSITION     CONTENTS OF C ARRAY
C      1           RETURN FLOW STORAGE

C     THE NUMBER OF ELEMENTS REQUIRED IN THE C ARRAY IS   1

C        1         2         3         4         5         6         7
C23456789012345678901234567890123456789012345678901234567890123456789012
C
C     CONSUMPTIVE USE OPERATION FLOWCHART
C     -----------------------------------
C
C        1.  READ IN TIME-SERIES
C
C            OPTION 0 :  NATURAL SIMULATED FLOW (24 HOUR)
C                        MEAN AREAL TEMPERATURE (6 HOUR)
C            OPTION 1 :  NATURAL SIMULATED FLOW (24 HOUR)
C                        POTENTIAL EVAPORATION (24 HOUR)
C
C        2.  DETERMINE CROP EVAPOTRANSPIRATION
C
C            a) OPTION 0 : BLANEY CRIDDLE ET ESTIMATION
C
C               i)    CALCULATE MEAN DAILY TEMPERATURE (6 --> 24 HR MAT)
C               ii)   CONVERT TEMPERATURES FROM CELCIUS TO FAHRENHEIT
C               iii)  IF TEMPERATURE < 0.0, SET TEMPERATURE = 0.0
C               iv)   CALCULATE DAILY PERCENTAGE OF ANNUAL DAYTIME HOURS
C               v)    CALCULATE CROP ET  (CE = K * T * Perc / 100)
C
C            b) OPTION 1 : POTENTIAL ET TIME-SERIES SUPPLIED
C
C               i)    CALCULATE CROP ET  (CE = K * PE)
C
C        3.  DETERMINE CROP DEMAND  (QCD = CE * Area)
C
C        4.  CALCULATE DIVERSION (QDIV = QCD / Efficiency)
C
C        5.  CALCULATE RETURN FLOW OUT (QRFOUT = RFstor(0) * Decay)
C
C        6.  IF (QNAT + QRFOUT) >= (QDIV + MFLOW)
C
C            a)  THEN, QDIV = QDIV
C            b)  ELSE, IS (MFLOW) > (QNAT + QRFOUT)
C
C                     i)  THEN, QDIV = 0.0
C                     ii) ELSE, QDIV = (QNAT + QRFOUT - MFLOW)
C
C                QCD = QDIV * e,
C                CE = QCD / Area
C
C        7. CALCULATE ADJUSTED FLOW  (QADJ = (QNAT + QRFOUT) - QDIV)
C
C        8. CALCULATE RETURN FLOW IN  (QRFIN = QDIV * ACCUM)
C
C        9. CALCULATE OTHER LOSSES  (QOL = QDIV - QCD - QRFIN)
C
C        10. CALCULATE RETURN FLOW STORAGE
C                          RFstor(1) = RFstor(0) + QRFIN - QRFOUT

C        1         2         3         4         5         6         7
C23456789012345678901234567890123456789012345678901234567890123456789012

C     UNITS CONVERSION

C     1 INCH = 25.4 MM
C     1 MM*KM*KM / DAY = 0.011574 CMSD

C        1         2         3         4         5         6         7
C23456789012345678901234567890123456789012345678901234567890123456789012

C     VARIABLE DEFINITIONS

C     OPTION    - ET ESTIMATION OPTION: TEMPERATURE OR POTENTIAL ET

C     T(*)      - OPTION 0 : MEAN AREAL TEMPERATURE TIME SERIES
C     PE(*)     - OPTION 1 : POTENTIAL ET TIME SERIES

C     QNAT(*)   - NATURAL FLOW TIME SERIES
C     QADJ(*)   - ADJUSTED FLOW TIMER SERIES
C     QDIV(*)   - DIVERSION FLOW TIME SERIES
C     QRFIN(*)  - RETURN FLOW IN TIME SERIES
C     QRFOUT(*) - RETURN FLOW OUT TIME SERIES
C     QOL(*)    - OTHER LOSSES TIME SERIES
C     QCD(*)    - CROP DEMAND TIME SERIES
C     CE(*)     - CROP EVAPOTRANSPIRATION

C     K         - DAILY EMPIRICAL CROP COEFFICIENTS

C     H         - DAILY NUMBER OF DAYTIME HOURS
C     HYEAR     - ANNUAL DAYTIME HOURS
C     PI        - CONSTANT, 3.141592654
C     RLAT      - LATITUDE OF IRRIGATED AREA IN RADIANS
C     DEC       - DECLINATION OF THE SUN
C     SSANGLE   - SUNSET ANGLE OF THE SUN
C     PERC      - DAILY PERCENTAGE OF ANNUAL DAYTIME HOURS

C     W         - LOCATION OF FIRST 6 HOUR TEMPERATURE ON GIVEN DAY
C     X         - LOCATION OF SECOND 6 HOUR TEMPERATURE ON GIVEN DAY
C     Y         - LOCATION OF THIRD 6 HOUR TEMPERATURE ON GIVEN DAY
C     Z         - LOCATION OF FOURTH 6 HOUR TEMPERATURE ON GIVEN DAY
C     MATC      - MEAN DAILY TEMPERATURE IN DEGREES CELCIUS
C     MATF      - MEAN DAILY TEMPERATURE IN DEGREES FAHRENHEIT

C     BASE      - BASE JULIAN DAY FROM DECEMBER 31, 1899
C     LDAY      - DAY OF THE FOUR YEAR LEAP YEAR CYCLE (1-1461)
C     YDAY      - MODIFIED DAY OF THE FOUR LEAP YEAR CYCLE
C     DAY       - DAY OF THE YEAR (1-366)

C     A         - CONVERSION FACTOR FROM (MM*KM^2/DAY) TO CMSD
C     AREA      - IRRIGATED AREA
C     EFF       - IRRIGATION EFFICIENCY
C     ACCUM     - RETURN FLOW ACCUMULATION RATE
C     DECAY     - RETURN FLOW DECAY RATE
C     QSUM      - SUM OF NATURAL FLOW AND RETURN FLOW OUT
C     QADD      - SUM OF DIVERSION FLOW AND MINIMUM STREAMFLOW
C     MFLOW     - MINIMUM FLOW

C     RFSTOR    - RETURN FLOW STORAGE

      REAL * 4  P(*),C(*),T(*),PE(*),QNAT(*),QADJ(*)
      REAL * 4  QDIV(*),QRFIN(*),QRFOUT(*),QOL(*),QCD(*),CE(*)
      REAL * 4  CTEMP(1)
      REAL K
      REAL PI,RLAT,DEC,SSANGLE,H,HYEAR
      REAL MATC,MATF,PERC
      REAL A,AREA,EFF,ACCUM,DECAY,QSUM,QADD
      REAL RFSTOR,MFLOW

      INTEGER OPTION,W,X,Y,Z,DAY,LDAY,YDAY,BASE

C        1         2         3         4         5         6         7
C23456789012345678901234567890123456789012345678901234567890123456789012

C     COMMON BLOCKS

C     DEBUG COMMON
C        IODBUG - UNIT NUMBER TO WRITE OUT ALL DEBUG OUTPUT

      COMMON /FDBUG/IODBUG,ITRACE,IDBALL,NDEBUG,IDEBUG(20)

C     UNIT NUMBERS COMMON
C     ALWAYS USE THE VARIABLES IN IONUM TO SPECIFY UNIT NUMBER

      COMMON /IONUM/IN,IPR,IPU

C     TIMING INFORMATION COMMON

      COMMON /FCTIME/IDARUN,IHRRUN,LDARUN,LHRRUN,LDACPD,LHRCPD,NOW(5),
     +               LOCAL,NOUTZ,NOUTDS,NLSTZ,IDA,IHR,LDA,LHR,IDADAT

C     IDARUN - I* 4 - INITIAL JULIAN DAY OF THE ENTIRE RUN
C     IHRRUN - I* 4 - INITIAL HOUR OF THE ENTIRE RUN
C     LDARUN - I* 4 - JULIAN DAY OF LAST DAY OF THE ENTIRE RUN
C     LHRRUN - I* 4 - LAST HOUR OF ENTIRE RUN
C     LDACPD - I* 4 - JULIAN DAY OF LAST DAY WITH OBSERVED DATA
C     LHRCPD - I* 4 - LAST HOUR WITH OBSERVED DATA
C     NOW    - I* 4 - CURRENT TIME FROM THE COMPUTER'S CLOCK
C                     NOW(1) - MONTH
C                     NOW(2) - DAY
C                     NOW(3) - YEAR (4 DIGIT)
C     LOCAL  - I* 4 - HOUR OFFSET TO LOCAL TIME
C     NOUTZ  - I* 4 - DEFAULT TIME ZONE NUMBER FOR OUTPUT
C     NOUTDS - I* 4 - DEFAULT DAYLIGHT SAVING TIME SWITCH FOR OUTPUT
C                     =0, STANDARD TIME
C                     =1, DAYLIGHT SAVING TIME
C     NLSTZ  - I* 4 - TIME ZONE NUMBER OF LOCAL STANDARD TIME
C     IDA    - I* 4 - JULIAN DATE OF THE FIRST DAY TO BE COMPUTED
C     IHR    - I* 4 - FIRST HOUR TO BE COMPUTED IN THE CURRENT PASS
C     LDA    - I* 4 - JULIAN DATE OF THE LAST DAY TO BE COMPUTED
C     LHR    - I* 4 - LAST HOUR TO BE COMPUTED IN THE CURRENT PASS
C     IDADAT - I* 4 - JULIAN DATE OF THE FIRST DAY OF TIME SERIES DATA

C     CONTROL INFORMATION FOR SAVING CARRYOVER

      COMMON /FCARY/IFILLC,NCSTOR,ICDAY(20),ICHOUR(20)

C     IFILLC - I* 4 - CONTROLS UPDATE OF C ARRAY AND STORING CARRYOVER
C                     =0, NO OPERATION CAN MODIFY THE C ARRAY; NO
C                         CARRYOVER STORED
C                     =1, C ARRAY SHOULD BE MODIFIED
C     NCSTOR - I* 4 - NUMBER OF CARRYOVER DATES SAVED TO BE SAVED
C                     IGNORED IF IFILLC=0
C     ICDAY  - I* 4 - JULIAN DAYS TO STORE CARRYOVER
C     ICHOUR - I* 4 - HOURS TO STORE CARRYOVER

C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcst_ex/RCS/ex57.f,v $
     . $',                                                             '
     .$Id: ex57.f,v 1.2 2004/02/05 19:46:22 edwin Exp $
     . $' /
C    ===================================================================

C     CHECK THE TRACE LEVEL AND WHETHER DEBUG OUTPUT IS NEEDED
      CALL FPRBUG ('EX57    ',1,57,IBUG)

C        1         2         3         4         5         6         7
C23456789012345678901234567890123456789012345678901234567890123456789012

C     LOCATE FIRST DATA VALUE IN THE 'DAILY' TIME SERIES DATA ARRAYS

      KDA = IDA
      KHR = IHR
      ITS = (KDA-IDADAT) + 1

C  DEBUG OUTPUT FOR FIRST DATA VALUE LOCATION

      IF (IBUG.EQ.1) WRITE(IODBUG,1001) KDA,KHR,IDADAT,ITS
 1001 FORMAT(' EX57: KDA,KHR,IDADAT,ITS: ',4I6)

C     LOCATE LAST DATA VALUE IN THE 'DAILY' TIME SERIES DATA ARRAYS

      LTS = (LDA-IDADAT) + 1

C  DEBUG OUTPUT FOR LAST DATA VALUE LOCATION

      IF (IBUG.EQ.1) WRITE(IODBUG,1002) LDA,LTS
 1002 FORMAT(' EX57: LDA,LTS: ',2I6)

C        1         2         3         4         5         6         7
C23456789012345678901234567890123456789012345678901234567890123456789012

C  DETERMINATION OF CROP EVAPOTRANSPIRATION

      OPTION = INT(P(50))
      IF (OPTION.EQ.0) THEN

C  SCS BLANEY CRIDDLE TEMPERATURE METHOD

         PI = 3.141592654
         RLAT = P(51)*2*PI/360
         HYEAR = P(57)

C  DEBUG OUTPUT FOR THE FLOW COMPUTATIONS

         IF (IBUG.EQ.1) THEN
            WRITE (IODBUG,1003)
 1003       FORMAT (/,' EX57: CROP ET: OPTION 0: DATE',8X,'DAY',2X,
     +              '6HR MATs(4) ',16X,'MATC',3X,'MATF',2X,'PERC',
     +              2X,'K',4X,'CE')
         END IF

C  DO LOOP TO CALCULATE CROP ET FOR EACH DAY OF THE RUN

         DO I = ITS,LTS

C  CALCULATE MEAN DAILY TEMPERATURE FROM THE 6 HOUR MAT TIME SERIES

            W = ((I-1)*4)+1
            X = ((I-1)*4)+2
            Y = ((I-1)*4)+3
            Z = ((I-1)*4)+4
            MATC = (T(W)+T(X)+T(Y)+T(Z))/4

C  CONVERT MEAN DAILY TEMPERATURE FROM CELCIUS TO FAHRENHEIT

            MATF = (MATC*1.8)+32

C  CHECK TO SEE IF TEMPERATURE < 0.0 : IF SO, SET EQUAL TO 0.0

            IF (MATF.LT.0) THEN
               MATF = 0.0
            END IF

C  CONVERT FROM BASE JULIAN DAY TO DAY OF THE FOUR YEAR LEAP YEAR CYCLE
C  TO DAY OF THE CURRENT YEAR -- LEAP YEAR IS 1ST IN 4 YEAR CYCLE

            BASE = KDA + 1
            LDAY = MOD(BASE,1461)
            IF (LDAY.GT.366) THEN
               YDAY = LDAY - 366
            ELSE
               YDAY = LDAY
            ENDIF
            DAY = MOD(YDAY,365)
            IF (DAY.EQ.0) THEN
               DAY = 365
            ENDIF

C  CALCULATE DAILY PERCENTAGE OF ANNUAL DAYTIME HOURS -- H(1) = H(366)

            DEC = 0.4093*SIN(2*PI*(284+DAY)/365)
            SSANGLE = ACOS(-1*TAN(RLAT)*TAN(DEC))
            H = SSANGLE*24/PI
            PERC = 100*H/HYEAR

C  SCS BLANEY CRIDDLE ET ESTIMATION EQUATION

            K = P(DAY+57)
            CE(I) = 25.4*K*MATF*PERC/100

C  DEBUG OUTPUT FOR CROP ET COMPUTATIONS USING TEMPERATURE INPUT

            IF (IBUG.EQ.1) THEN
               CALL MDYH1(KDA,KHR,ILM,ILD,ILY,ILH,NOUTZ,NOUTDS,NTZCD)
               WRITE (IODBUG,1004) ILM,ILD,ILY,DAY,T(W),T(X),T(Y),T(Z),
     +                             MATC,MATF,PERC,K,CE(I)
 1004          FORMAT (' EX57: CROP ET: OPTION 0: ',I2,I3,2I5,6F7.2,
     +                 2F5.2,F6.2)
            END IF

C        1         2         3         4         5         6         7
C23456789012345678901234567890123456789012345678901234567890123456789012

C  INCREMENTING THE JULIAN DAY VARIABLE

            KDA = KDA + 1
         END DO

C  DEBUG OUTPUT DESCRIPTOR INFORMATION

         IF (IBUG.EQ.1) THEN
            WRITE (IODBUG,1005)
 1005       FORMAT (' EX57: CROP ET: OPTION 0: ',/,
     +              30X,'DATE        - Month  Day  Year',/,
     +              30X,'DAY         - Day of the Year (1-365)',/,
     +              30X,'6HR MATs(4) - Input temperatures (deg C)',/,
     +              30X,'MATC        - Average temperature (deg C)',/,
     +              30X,'MATF        - Average temperature (deg F)',/,
     +              30X,'PERC        - Daily percent annual daylight ',
     +              'hours',/,
     +              30X,'K           - Daily empirical coefficient',/,
     +              30X,'CE          - Crop evapotranspiration (mm)',/)
         END IF
      ELSE

C  POTENTIAL EVAPORATION TIME SERIES SUPPLIED

C  DEBUG OUTPUT FOR THE FLOW COMPUTATIONS

         IF (IBUG.EQ.1) THEN
            WRITE (IODBUG,1006)
 1006       FORMAT (' EX57: CROP ET: OPTION 1: DATE',8X,'DAY',2X,
     +              'K',4X,'PE',4X,'CE')
         END IF

C  DO LOOP TO CALCULATE THE CROP ET FOR EACH DAY OF THE RUN

         DO I = ITS,LTS

C  CONVERT FROM BASE JULIAN DAY TO DAY OF THE FOUR YEAR LEAP YEAR CYCLE
C  TO DAY OF THE CURRENT YEAR -- LEAP YEAR IS 1ST IN 4 YEAR CYCLE

            BASE = KDA + 1
            LDAY = MOD(BASE,1461)
            IF (LDAY.GT.366) THEN
               YDAY = LDAY - 366
            ELSE
               YDAY = LDAY
            ENDIF
            DAY = MOD(YDAY,365)
            IF (DAY.EQ.0) THEN
               DAY = 365
            ENDIF

C  ET ESTIMATION WITH POTENTIAL ET, SIMILAR TO PAN EQUATIONS

            K = P(DAY+57)
            CE(I) = K*PE(I)

C  DEBUG OUTPUT FOR CROP ET COMPUTATIONS USING POTENTIAL ET INPUT

            IF (IBUG.EQ.1) THEN
               CALL MDYH1(KDA,KHR,ILM,ILD,ILY,ILH,NOUTZ,NOUTDS,NTZCD)
               WRITE (IODBUG,1007) ILM,ILD,ILY,DAY,K,PE(I),CE(I)
 1007          FORMAT (' EX57: CROP ET: OPTION 1: ',I2,I3,2I5,F5.2,
     +                 2F6.2)
            END IF

C  INCREMENTING THE JULIAN DAY VARIABLE

            KDA = KDA + 1
         END DO

C  DEBUG OUTPUT DESCRIPTOR INFORMATION

         IF (IBUG.EQ.1) THEN
            WRITE (IODBUG,1008)
 1008       FORMAT (' EX57: CROP ET: OPTION 1: ',/,
     +              30X,'DATE   - Month  Day  Year',/,
     +              30X,'DAY    - Day of the Year (1-365)',/,
     +              30X,'K      - Daily empirical coefficient',/,
     +              30X,'PE     - Input potential ',
     +              'evapotranspiration (mm)',/,
     +              30X,'CE     - Crop evapotranspiration (mm)',/)
         END IF
      ENDIF

C        1         2         3         4         5         6         7
C23456789012345678901234567890123456789012345678901234567890123456789012

C  CROP DEMAND, DIVERSION, RETURN FLOW, AND OTHER LOSS CALCULATIONS

      A = 0.011574
      AREA = P(52)
      EFF = P(53)
      MFLOW = P(54)
      ACCUM = P(55)
      DECAY = P(56)

C  SETTING UP FOR SAVING VALUES TO C ARRAY, COPY C ARRAY TO CTEMP ARRAY

      ICARY = 1
      KDA = IDA
      NCO = 1
      CTEMP(1) = C(1)

C  INITIAL RETURN FLOW STORAGE FROM C ARRAY

      RFSTOR = CTEMP(1)

C  DEBUG OUTPUT FOR THE FLOW COMPUTATIONS

      IF (IBUG.EQ.1) THEN
         WRITE (IODBUG,1009)
 1009    FORMAT (/,' EX57:   FLOWS: DATE',10X,'CE',5X,'QCD',4X,'QDIV',
     +           4X,'QSUM',4X,'QNAT',4X,'QADJ',4X,'QRFIN',3X,
     +           'QRFOUT',3X,'QOL',4X,'RFSTOR')
      END IF

C  LOOP TO PERFORM PRIMARY CONSUMPTIVE USE CALCULATIONS

      DO I = ITS,LTS
         QCD(I) = CE(I)*AREA*A
         QDIV(I) = QCD(I)/EFF
         QRFOUT(I) = RFSTOR*AREA*A*DECAY
         QSUM = QNAT(I)+QRFOUT(I)
         QADD = QDIV(I)+MFLOW

C  CHECK TO SEE IF WATER IS AVAILABLE FOR DIVERSION

         IF (QSUM.LT.QADD) THEN
            IF (MFLOW.GT.QSUM) THEN
               QDIV(I) = 0.0
            ELSE
               QDIV(I) = QSUM-MFLOW
            ENDIF
            QCD(I) = QDIV(I)*EFF
            CE(I) = QCD(I)/(AREA*A)
         END IF

         QRFIN(I) = QDIV(I)*ACCUM
         QOL(I) = QDIV(I)-QCD(I)-QRFIN(I)
         RFSTOR = ((RFSTOR*AREA*A)+QRFIN(I)-QRFOUT(I))/(AREA*A)
         QADJ(I) = QSUM-QDIV(I)

C  SAVE CTEMP ARRAY BACK TO C ARRAY

         CTEMP(1) = RFSTOR
cew added condition on ncstor.  Wont work with espvs without it and other 
cew  operations included this condition.
         IF (IFILLC.EQ.1 .and. ncstor .ne. 0) THEN
c         IF (IFILLC.EQ.1) THEN
            IF (KDA.EQ.ICDAY(ICARY).AND.KHR.EQ.ICHOUR(ICARY)) THEN
               CALL FCWTCO (KDA,KHR,CTEMP,NCO)
               ICARY = ICARY + 1
            ENDIF
         ENDIF

C  DEBUG OUTPUT FOR THE FLOW COMPUTATIONS

         IF (IBUG.EQ.1) THEN
            CALL MDYH1(KDA,KHR,ILM,ILD,ILY,ILH,NOUTZ,NOUTDS,NTZCD)
            WRITE (IODBUG,1010) ILM,ILD,ILY,CE(I),QCD(I),QDIV(I),QSUM,
     +                          QNAT(I),QADJ(I),QRFIN(I),QRFOUT(I),
     +                          QOL(I),CTEMP(1)
 1010       FORMAT (' EX57:   FLOWS: ',I2,I3,I5,10F8.2)
         END IF

C  INCREMENT DAY VARIABLE

         KDA = KDA + 1
      END DO

C  DEBUG OUTPUT DESCRIPTOR INFORMATION

      IF (IBUG.EQ.1) THEN
         WRITE (IODBUG,1011)
 1011    FORMAT (' EX57:   FLOWS: ',/,
     +           20X,'DATE    - Month  Day  Year',/,
     +           20X,'CE      - Crop evapotranspiration (mm)',/,
     +           20X,'QCD     - Crop Demand (cmsd)',/,
     +           20X,'QDIV    - Diversion Flow (cmsd)',/,
     +           20X,'QSUM    - Natural + Return Flow Out (cmsd)',/,
     +           20X,'QNAT    - Natural Runoff (cmsd)',/,
     +           20X,'QADJ    - Adjusted Runoff (cmsd)',/,
     +           20X,'QRFIN   - Return Flow In (cmsd)',/,
     +           20X,'QRFOUT  - Return Flow Out (cmsd)',/,
     +           20X,'QOL     - Other Losses (cmsd)',/,
     +           20X,'RFSTOR  - Return Flow Storage (mm)',/)
      END IF

C        1         2         3         4         5         6         7
C23456789012345678901234567890123456789012345678901234567890123456789012

C  SAVE CARRYOVER VALUES BACK TO THE C ARRAY

      IF (IFILLC.EQ.1) THEN
         C(1) = CTEMP(1)
      ENDIF

      IF (IBUG.GE.1) WRITE(IODBUG,990) ICARY
 990  FORMAT (' EX57: ICARY:',I5)

 992  IF (ITRACE.GE.1) WRITE(IODBUG,991)
 991  FORMAT (//,' EX57: EXITED:')

      RETURN
      END
