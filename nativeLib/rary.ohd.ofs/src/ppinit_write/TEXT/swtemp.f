C MODULE SWTEMP
C-----------------------------------------------------------------------
C
C  ROUTINE TO WRITE STATION TEMP PARAMETERS.
C
      SUBROUTINE SWTEMP (IVTEMP,STAID,NBRSTA,DESCRP,STATE,ITYOBS,
     *   IMTN,TEMPCF,IFMM,TEMPFE,ITNTWK,IPMMMT,IPDMMT,WTMMT,IPDINS,
     *   WTINS,IPDFMM,WTFMM,ITMINS,
     *   UNSD,LARRAY,ARRAY,IPTR,DISP,NSPACE,
     *   IWRITE,NPOS,ISTAT)
C
      CHARACTER*1 CARCTL
      CHARACTER*4 DISP
C
      DIMENSION ARRAY(LARRAY)
C
      INCLUDE 'scommon/dimsta' 
      INCLUDE 'scommon/dimtemp'      
C
      INCLUDE 'uio'
      INCLUDE 'scommon/sudbgx'
      INCLUDE 'scommon/suoptx'
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/ppinit_write/RCS/swtemp.f,v $
     . $',                                                             '
     .$Id: swtemp.f,v 1.2 1998/04/07 18:38:05 page Exp $
     . $' /
C    ===================================================================
C
C
C
      IF (ISTRCE.GT.1) THEN
         WRITE (IOSDBG,180)
         CALL SULINE (IOSDBG,1)
         ENDIF
C
C  SET DEBUG LEVEL
      LDEBUG=ISBUG('TEMP')
C
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,*)
     *      ' IVTEMP=',IVTEMP,
     *      ' UNWD=',UNSD,
     *      ' LARRAY=',LARRAY,
     *      ' '
         CALL SULINE (IOSDBG,1)
         ENDIF
C
      ISTAT=0
C
      IF (IWRITE.EQ.-1) GO TO 160
C
C  CHECK FOR SUFFICIENT SPACE IN PARAMETER ARRAY
      MINLEN=84
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,*) ' MINLEN=',MINLEN
         CALL SULINE (IOSDBG,1)
         ENDIF
      IF (MINLEN.GT.LARRAY) THEN
         WRITE (LP,190) LARRAY,MINLEN
         CALL SUERRS (LP,2,-1)
         ISTAT=1
         GO TO 170
         ENDIF
C
      NPOS=0
C
C  STORE PARAMETER ARRAY VERSION NUMBER
      NPOS=NPOS+1
      ARRAY(NPOS)=IVTEMP+.01
C
C  STORE STATION IDENTIFIER
      NCHAR=4
      NWORDS=LEN(STAID)/NCHAR
      NCHK=2
      IF (NWORDS.NE.NCHK) THEN
         WRITE (LP,305) 'STAID',NWORDS,NCHK,STAID
         CALL SUERRS (LP,2,-1)
         ISTAT=1
         GO TO 170
         ENDIF
      DO 10 I=1,NWORDS
         NPOS=NPOS+1
         N=(I-1)*NCHAR+1
         CALL SUBSTR (STAID(N:N),1,4,ARRAY(NPOS),1)
10       CONTINUE
C
C  STORE USER SPECIFIED STATION NUMBER
      NPOS=NPOS+1
      ARRAY(NPOS)=NBRSTA+.01
C
C  STORE DESCRIPTIVE INFORMATION
      NCHAR=4
      NWORDS=LEN(DESCRP)/NCHAR
      NCHK=5
      IF (NWORDS.NE.NCHK) THEN
         WRITE (LP,305) 'DESCRP',NWORDS,NCHK,STAID
         CALL SUERRS (LP,2,-1)
         ISTAT=1
         GO TO 170
         ENDIF
      DO 20 I=1,NWORDS
         NPOS=NPOS+1
         N=(I-1)*NCHAR+1
         CALL SUBSTR (DESCRP(N:N),1,NCHAR,ARRAY(NPOS),1)
20       CONTINUE
C
C  STORE INDICATOR FOR TYPES OF DATA OBSERVED BY STATION
      NPOS=NPOS+1
      ARRAY(NPOS)=ITYOBS+.01
C
C  STORE MOUNTAINOUS INDICATOR
      NPOS=NPOS+1
      ARRAY(NPOS)=IMTN+.01
C
C  STORE MAX AND MIN CORRECTION FACTORS
      DO 30 I=1,2
         NPOS=NPOS+1
         ARRAY(NPOS)=TEMPCF(I)
30       CONTINUE
C
C  STORE INDICATOR WHETHER STATION HAS FORECAST MAX/MIN DATA
      NPOS=NPOS+1
      ARRAY(NPOS)=IFMM+.01
C
C  SET ELEVATION WEIGHTING FACTOR (FE)
      NPOS=NPOS+1
      ARRAY(NPOS)=TEMPFE
C
C  STORE NETWORK INDICATOR
      NPOS=NPOS+1
      IF (ITNTWK.GE.0) ARRAY(NPOS)=ITNTWK+.01
      IF (ITNTWK.LT.0) ARRAY(NPOS)=ITNTWK-.02
C
C  STORE ARRAY LOCATION OF MEAN MONTHLY MAX/MIN TEMPERATURES
      NPOS=NPOS+1
      IF (IPMMMT.GT.0) ARRAY(NPOS)=IPMMMT+.01
      IF (IPMMMT.LT.0) ARRAY(NPOS)=IPMMMT-.02
      IF (IWRITE.EQ.1) THEN
         IF (IPMMMT.EQ.0) THEN
            WRITE (LP,200) STAID
            CALL SUWRNS (LP,2,-1)
            ENDIF
         ENDIF
C
C  STORE ARRAY LOCATION OF POINTERS FOR 3 CLOSEST STATIONS WITH MAX/MIN
C  TEMP DATA IN EACH QUADRANT
      DO 50 I=1,4
         DO 40 J=1,3
            NPOS=NPOS+1
            ARRAY(NPOS)=IPDMMT(J,I)+.01
            IF (IPDMMT(J,I).LT.0) ARRAY(NPOS)=IPDMMT(J,I)-.02
40          CONTINUE
50       CONTINUE
C
C  STORE WEIGHTS FOR STATIONS WITH MAX/MIN DATA
      DO 70 I=1,4
         DO 60 J=1,3
            NPOS=NPOS+1
            ARRAY(NPOS)=WTMMT(J,I)
60          CONTINUE
70       CONTINUE
C
C  STORE ARRAY LOCATION OF POINTERS FOR 3 CLOSEST STATIONS WITH
C  INSTANTANEOUS TEMP DATA IN EACH QUADRANT
      DO 90 I=1,4
         DO 80 J=1,3
            NPOS=NPOS+1
            ARRAY(NPOS)=IPDINS(J,I)+.01
            IF (IPDINS(J,I).LT.0) ARRAY(NPOS)=IPDINS(J,I)-.02
80          CONTINUE
90       CONTINUE
C
C  STORE WEIGHTS FOR STATIONS WITH INSTANTANEOUS DATA
      DO 110 I=1,4
         DO 100 J=1,3
            NPOS=NPOS+1
            ARRAY(NPOS)=WTINS(J,I)
100         CONTINUE
110      CONTINUE
C
C  STORE ARRAY LOCATION OF POINTERS FOR 2 CLOSEST STATIONS WITH
C  FORECAST TEMP IN EACH QUADRANT
      DO 130 I=1,4
         DO 120 J=1,2
            NPOS=NPOS+1
            ARRAY(NPOS)=IPDFMM(J,I)+.01
            IF (IPDFMM(J,I).LT.0) ARRAY(NPOS)=IPDFMM(J,I)-.02
120         CONTINUE
130      CONTINUE
C
C  STORE WEIGHTS FOR STATIONS WITH FORECAST TEMP DATA
      DO 150 I=1,4
         DO 140 J=1,2
            NPOS=NPOS+1
            ARRAY(NPOS)=WTFMM(J,I)
140         CONTINUE
150      CONTINUE
C
C  STORE TIME INTERVAL OF INSTANTANEOUS DATA
      NPOS=NPOS+1
      ARRAY(NPOS)=ITMINS+.01
C
C  STORE STATE IDENTIFIER
      NPOS=NPOS+1
      ARRAY(NPOS)=STATE
C
C  THE NEXT POSITION IS UNUSED
      NPOS=NPOS+1
      ARRAY(NPOS)=UNSD
C
      IF (IWRITE.EQ.0) GO TO 170
C
C  OPEN DATA BASE
160   CALL SUDOPN (1,'PPP ',IERR)
      IF (IERR.NE.0) THEN
         ISTAT=1
         GO TO 170
         ENDIF
C
C  WRITE PARAMTER RECORD
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,*) ' NPOS=',NPOS
         CALL SULINE (IOSDBG,1)
         ENDIF
      IPTR=0
      CALL WPPREC (STAID,'TEMP',NPOS,ARRAY,IPTR,IERR)
      IF (IERR.GT.0) THEN
         CALL SWPPST (STAID,'TEMP',NPOS,IPTR,IERR)
         WRITE (LP,210) IERR
         CALL SUERRS (LP,2,-1)
         ISTAT=3
         ENDIF
C
      IF (ISTAT.GT.0) THEN
         IF (DISP.EQ.'NEW') THEN
            WRITE (LP,240) 'WRITTEN',STAID
            CALL SULINE (LP,2)
            ENDIF
         IF (DISP.EQ.'OLD') THEN
            WRITE (LP,240) 'UPDATED',STAID
            CALL SULINE (LP,2)
            ENDIF
         GO TO 170
         ENDIF
C
      IF (LDEBUG.GT.0) CALL SUPDMP ('TEMP','BOTH',0,NPOS,ARRAY,ARRAY)
C
      CALL SUDWRT (1,'PPP ',IERR)
C
C  CHECK MESSAGE LEVEL VALUE
      IF (IOPMLV.GT.1) THEN
         CARCTL=' '
         NULINE=1
         IF (NSPACE.EQ.1) THEN
            CARCTL='0'
            NULINE=1
            ENDIF
         IF (DISP.EQ.'NEW') THEN
            WRITE (LP,220) CARCTL,'WRITTEN',STAID
            CALL SULINE (LP,NULINE)
            ENDIF
         IF (DISP.EQ.'OLD') THEN
            WRITE (LP,220) CARCTL,'UPDATED',STAID
            CALL SULINE (LP,NULINE)
            ENDIF
         ENDIF
C
170   IF (ISTRCE.GT.1) THEN
         WRITE (IOSDBG,260)
         CALL SULINE (IOSDBG,1)
         ENDIF
C
      RETURN
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
180   FORMAT (' *** ENTER SWTEMP')
190   FORMAT ('0*** ERROR - IN SWTEMP - NOT ENOUGH SPACE IN PARAMETER ',
     *   'ARRAY: NUMBER OF WORDS IN PARAMETER ARRAY=',I5,3X,
     *   'NUMBER OF WORDS NEEDED=',I5)
305   FORMAT ('0*** ERROR - IN SWSTAN - NUMBER OF WORDS IN VARIABLE ',
     *   A,'(',I2,') IS NOT ',I2,' FOR STATION ',A,'.')
200   FORMAT ('0*** WARNING - IN SWTEMP - SLOT NUMBER FOR ',
     *   'MAX/MIN TEMPERATURES ',
     *   'IS ZERO FOR STATION ',A,'.')
210   FORMAT ('0*** ERROR - IN SWTEMP - UNSUCCESSFUL CALL TO WPPREC : ',
     *   'STATUS CODE=',I3)
220   FORMAT (A,'*** NOTE - TEMP PARAMETERS SUCCESSFULLY ',A,' ',
     *   'FOR STATION ',A,'.')
240   FORMAT ('0*** NOTE - TEMP PARAMETERS NOT SUCCESSFULLY ',A,' ',
     *   'FOR STATION ',A,'.')
260   FORMAT (' *** EXIT SWTEMP')
C
      END
