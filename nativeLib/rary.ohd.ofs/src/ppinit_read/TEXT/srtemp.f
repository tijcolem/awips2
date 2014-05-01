C MODULE SRTEMP
C-----------------------------------------------------------------------
C
C  ROUTINE TO READ STATION TEMP PARAMETERS.
C
      SUBROUTINE SRTEMP (IVTEMP,STAID,NBRSTA,DESCRP,STATE,
     *   ITYOBS,IMTN,TEMPCF,ITFMM,TEMPFE,ITNTWK,IPMMMT,
     *   IPDMMT,WTMMT,IPDINS,WTINS,IPDFMM,WTFMM,ITTAVR,UNUSED,
     *   LARRAY,ARRAY,IPTR,IPRERR,IPTRNX,IREAD,ISTAT)
C
      DIMENSION ARRAY(LARRAY)
      DIMENSION UNUSED(1)
C
      INCLUDE 'scommon/dimsta'
      INCLUDE 'scommon/dimtemp'
C
      INCLUDE 'uio'
      INCLUDE 'scommon/sudbgx'
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/ppinit_read/RCS/srtemp.f,v $
     . $',                                                             '
     .$Id: srtemp.f,v 1.2 1998/04/07 18:08:02 page Exp $
     . $' /
C    ===================================================================
C
C
C
      IF (ISTRCE.GT.0) THEN
         WRITE (IOSDBG,180)
         CALL SULINE (IOSDBG,1)
         ENDIF
C
C  SET DEBUG LEVEL
      LDEBUG=ISBUG('TEMP')
      LPDUMP=ISBUG('PDMP')
C
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,*) 'LARRAY=',LARRAY
         CALL SULINE (IOSDBG,1)
         ENDIF
C
      ISTAT=0
C
      IF (IREAD.EQ.0) GO TO 10
C
C  OPEN DATA BASE 
      CALL SUDOPN (1,'PPP ',IERR)
      IF (IERR.GT.0) THEN
         ISTAT=1
         GO TO 170
         ENDIF    
C
C  READ PARAMETER RECORD
      CALL SUDOPN (1,'PPP ',IERR)
      CALL RPPREC (STAID,'TEMP',IPTR,LARRAY,ARRAY,NFILL,IPTRNX,
     *   IERR)
      IF (IERR.NE.0) THEN
         ISTAT=IERR
         IF (ISTAT.EQ.6) GO TO 170
         IF (IPRERR.GT.0) THEN
            CALL SRPPST (STAID,'TEMP',IPTR,LARRAY,NFILL,IPTRNX,IERR)
            ENDIF
         GO TO 170
         ENDIF
C
10    NPOS=0

C  SET PARAMETER ARRAY VERSION NUMBER
      NPOS=NPOS+1
      IVTEMP=ARRAY(NPOS)
C
C  SET STATION IDENTIFIER
      NCHAR=4
      NWORDS=LEN(STAID)/NCHAR
      NCHK=2
      IF (NWORDS.NE.NCHK) THEN
         WR ITE (LP,240) 'STAID',NWORDS,NCHK,STAID
         CALL SUERRS (LP,2,-1)
         ISTAT=1
         GO TO 170
         ENDIF
      DO 20 I=1,NWORDS
         NPOS=NPOS+1
         N=(I-1)*NCHAR+1
         CALL SUBSTR (ARRAY(NPOS),1,4,STAID(N:N),1)
20       CONTINUE
C
C  SET USER SPECIFIED STATION NUMBER
      NPOS=NPOS+1
      NBRSTA=ARRAY(NPOS)
C
C  SET DESCRIPTIVE INFORMATION
      NCHAR=4
      NWORDS=LEN(DESCRP)/NCHAR
      NCHK=5
      IF (NWORDS.NE.NCHK) THEN
         WRITE (LP,240) 'DESCRP',NWORDS,NCHK,STAID
         CALL SUERRS (LP,2,-1)
         ISTAT=1
         GO TO 170
         ENDIF
      DO 30 I=1,NWORDS
         NPOS=NPOS+1
         N=(I-1)*NCHAR+1
         CALL SUBSTR (ARRAY(NPOS),1,NCHAR,DESCRP(N:N),1)
30       CONTINUE
C
C  SET INDICATOR FOR TYPES OF DATA OBSERVED BY STATION
      NPOS=NPOS+1
      ITYOBS=ARRAY(NPOS)
C
C  SET MOUNTAINOUS INDICATOR
      NPOS=NPOS+1
      IMTN=ARRAY(NPOS)
C
C  SET MAX AND MIN CORRECTION FACTORS
      DO 40 I=1,2
         NPOS=NPOS+1
         TEMPCF(I)=ARRAY(NPOS)
40       CONTINUE
C
C  SET INDICATOR WHETHER STATION HAS FORECAST MAX/MIN DATA
      NPOS=NPOS+1
      ITFMM=ARRAY(NPOS)
C
C  SET THE ELEVATION WEIGHTING FACTOR (FE)
      NPOS=NPOS+1
      TEMPFE=ARRAY(NPOS)
C
C  SET NETWORK INDICATOR
      NPOS=NPOS+1
      ITNTWK=ARRAY(NPOS)
C
C  SET ARRAY LOCATION OF MEAN MONTHLY MAX/MIN TEMPERATURES
      NPOS=NPOS+1
      IPMMMT=ARRAY(NPOS)
C
C  SET ARRAY LOCATION OF POINTERS FOR 3 CLOSEST STATIONS WITH MAX/MIN
C  TEMP DATA IN EACH QUADRANT
      DO 60 I=1,4
         DO 50 J=1,3
            NPOS=NPOS+1
            IPDMMT(J,I)=ARRAY(NPOS)
50          CONTINUE
60       CONTINUE
C
C  SET WEIGHTS FOR STATIONS WITH MAX/MIN DATA
      DO 80 I=1,4
         DO 70 J=1,3
            NPOS=NPOS+1
            WTMMT(J,I)=ARRAY(NPOS)
70          CONTINUE
80       CONTINUE
C
C  SET ARRAY LOCATION OF POINTERS FOR 3 CLOSEST STATIONS WITH
C  INSTANTANEOUS TEMP DATA IN EACH QUADRANT
      DO 100 I=1,4
         DO 90 J=1,3
            NPOS=NPOS+1
            IPDINS(J,I)=ARRAY(NPOS)
90          CONTINUE
100      CONTINUE
C
C  SET WEIGHTS FOR STATIONS WITH INSTANTANEOUS DATA
      DO 120 I=1,4
         DO 110 J=1,3
            NPOS=NPOS+1
            WTINS(J,I)=ARRAY(NPOS)
110         CONTINUE
120      CONTINUE
C
C  SET ARRAY LOCATION OF POINTERS FOR 2 CLOSEST STATIONS WITH
C  FORECAST TEMP IN EACH QUADRANT
      DO 140 I=1,4
         DO 130 J=1,2
            NPOS=NPOS+1
            IPDFMM(J,I)=ARRAY(NPOS)
130         CONTINUE
140      CONTINUE
C
C  SET WEIGHTS FOR STATIONS WITH FORECAST TEMP DATA
      DO 160 I=1,4
         DO 150 J=1,2
            NPOS=NPOS+1
            WTFMM(J,I)=ARRAY(NPOS)
150         CONTINUE
160      CONTINUE
C
C  SET TIME INTERVAL OF INSTANTANEOUS DATA
      NPOS=NPOS+1
      ITTAVR=ARRAY(NPOS)
C
C  SET STATE IDENTIFIER
      NPOS=NPOS+1
      STATE=ARRAY(NPOS)
C
C  THE NEXT POSITION IS UNUSED
      NPOS=NPOS+1
      UNUSED(I)=ARRAY(NPOS)
C
      IF (LPDUMP.GT.0) THEN
         WRITE (IOSDBG,*)
     *      ' NPOS=',NPOS,
     *      ' NFILL=',NFILL,
     *      ' IPTRNX=',IPTRNX,
     *      ' IVTEMP=',IVTEMP,
     *      ' '
         CALL SULINE (IOSDBG,1)
         CALL SUPDMP ('TEMP','BOTH',0,NPOS,ARRAY,ARRAY)
         ENDIF
C
170   IF (ISTRCE.GT.0) THEN
         WRITE (IOSDBG,210) ISTAT
         CALL SULINE (IOSDBG,1)
         ENDIF
C
      RETURN
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
180   FORMAT (' *** ENTER SRTEMP')
240   FORMAT ('0*** ERROR - IN SRTEMP - NUMBER OF WORDS IN VARIABLE ',
     *   A,'(',I2,') IS NOT ',I2,' FOR STATION ',A,'.')
210   FORMAT (' *** EXIT SRTEMP : STATUS CODE=',I2)
C
      END
