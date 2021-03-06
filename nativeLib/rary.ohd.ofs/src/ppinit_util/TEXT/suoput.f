C MODULE SUOPUT
C-----------------------------------------------------------------------
C
C  ROUTINE TO OUTPUT CHARACTER STRINGS TO PRINT OR PUNCH UNIT.
C
      SUBROUTINE SUOPUT (NFLD,LCHAR,CHAR,LCHK,CHK,OUTPUT,ISTAT)
C
      CHARACTER*1 CHAR1
      CHARACTER*4 OUTPUT
      CHARACTER*8 DDN
      CHARACTER*8 XFT/'FT??F001'/
      CHARACTER*80 RECORD
C
      CHARACTER*(*) CHAR,CHK
C
      INCLUDE 'uio'
      INCLUDE 'scommon/sudbgx'
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/ppinit_util/RCS/suoput.f,v $
     . $',                                                             '
     .$Id: suoput.f,v 1.2 1998/07/06 12:44:12 page Exp $
     . $' /
C    ===================================================================
C
C
      IF (ISTRCE.GT.0) THEN
         WRITE (IOSDBG,70)
         CALL SULINE (IOSDBG,1)
         ENDIF
C
C  SET DEBUG LEVEL
      LDEBUG=ISBUG('UTIL')
C
      ISTAT=0
C
      IFOUND=0
C
C  SET OPTION TO REREAD CURRENT FIELD
      ISTRT=-1
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  CHECK FIELD FOR OUTPUT OPTIONS
C
10    CALL UFIELD (NFLD,ISTRT,LENGTH,ITYPE,NREP,INTEGR,REAL,LCHAR,
     *   CHAR,LLPAR,LRPAR,LASK,LATSGN,LAMPS,LEQUAL,IERR)
      IF (NFLD.EQ.-1) GO TO 60
      IF (LDEBUG.GT.0) THEN
         CALL UPRFLD (NFLD,ISTRT,LENGTH,ITYPE,NREP,INTEGR,REAL,LCHAR,
     *      CHAR,LLPAR,LRPAR,LASK,LATSGN,LAMPS,LEQUAL,IERR)
         ENDIF
      IF (IERR.EQ.1) THEN
         IF (LDEBUG.GT.0) THEN
            WRITE (IOSDBG,130) NFLD
            CALL SULINE (IOSDBG,1)
            ENDIF
         GO TO 50
         ENDIF
C
      IF (NFLD.EQ.1) CALL SUPCRD
C
C  CHECK FOR PARENTHESES IN FIELD
      IF (LLPAR.GT.0) CALL UFPACK (LCHK,CHK,ISTRT,1,LLPAR-1,IERR)
      IF (LLPAR.EQ.0) CALL UFPACK (LCHK,CHK,ISTRT,1,LENGTH,IERR)
C
C  CHECK IF OUTPUT OPTION
      IF (CHK.EQ.'OUTPUT') GO TO 20
      IF (IFOUND.EQ.1) GO TO 60
C
C  INVALID OPTION
      WRITE (LP,80) 'OUTPUT',NFLD,CHK(1:LENSTR(CHK))
      CALL SUERRS (LP,2,-1)
      GO TO 50
C
20    IFOUND=1
C
C  CHECK IF LEFT PARENTHESES FOUND
      IF (LLPAR.EQ.0) THEN
         WRITE (LP,100)
         CALL SUWRNS (LP,2,-1)
         GO TO 50
         ENDIF
C
C  CHECK IF RIGHT PARENTHESES IS LAST CHARACTER
      CALL SUBSTR (CHAR,LENGTH,1,CHAR1,1)
      IF (CHAR1.NE.')') THEN
         WRITE (LP,90) NFLD
         CALL SULINE (LP,2)
         LRPAR=LENGTH+1
         ELSE
            LRPAR=LENGTH
         ENDIF
C
C  CHECK IF OUTPUT UNIT SPECIFIED
      CALL UFPACK (LCHK,CHK,ISTRT,LLPAR+1,LRPAR-1,IERR)
      ICOLON=1
      CALL UINDEX (CHK,LCHK*4,':',1,LCOLON)
      IF (LCOLON.GT.0) GO TO 30
      ICOLON=0
C
C  OUTPUT UNIT NOT SPECIFIED
      IF (OUTPUT.EQ.' ') THEN
         IUNIT=LP
         WRITE (LP,110) IUNIT
         CALL SULINE (LP,2)
         GO TO 30
         ENDIF
      IF (OUTPUT.EQ.'PRNT'.OR.
     *    OUTPUT.EQ.'PNCH'.OR.
     *    OUTPUT.EQ.'BOTH') THEN
         ELSE
            IUNIT=LP
            IF (LDEBUG.GT.0) THEN
               WRITE (IOSDBG,*) 'IUNIT=',IUNIT
               CALL SULINE (IOSDBG,1)
               ENDIF
            GO TO 30
         ENDIF
      IF (OUTPUT.EQ.'PRNT') IUNIT=LP
      IF (OUTPUT.EQ.'PNCH') IUNIT=ICDPUN
      IF (OUTPUT.EQ.'BOTH') IUNIT=-1
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,*) 'IUNIT=',IUNIT
         CALL SULINE (IOSDBG,1)
         ENDIF
C
C  SET OUTPUT BUFFER
30    CALL UREPET (' ',RECORD,LEN(RECORD))
      IF (LCOLON.EQ.0) LCOLON=LRPAR-1
      LENBUF=LCOLON-1
      CALL SUBSTR (CHK,1,LENBUF,RECORD,1)
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,*) 'RECORD=',RECORD
         CALL SULINE (IOSDBG,1)
         ENDIF
      IF (ICOLON.EQ.0) GO TO 40
C
C  CHECK IF OUTPUT UNIT IS INTEGER
      CALL UFINFX (IUNIT,ISTRT,LLPAR+LCOLON+1,LRPAR-1,IERR)
      IF (IERR.NE.0) THEN
         WRITE (LP,120)
         CALL SUERRS (LP,2,-1)
         GO TO 50
         ENDIF
C
C  CHECK IF OUTPUT UNIT ALLOCATED
      DDN=XFT
      CALL UFXDDN (DDN,IUNIT,IERR)
      IF (IERR.NE.0) THEN
         IPRERR=1
         CALL UDDST (DDN,IPRERR,IERR)
         IF (IERR.GT.0) GO TO 50
         ENDIF
C
C  CHANGE SPECIAL CHARACTER INDICATOR FOR BLANK SPACE
40    CALL UCHNGE (RECORD,'_',' ',LENBUF)
C
C  OUTPUT BUFFER
      IF (IUNIT.EQ.-1) THEN
         IUNIT=LP
         WRITE (IUNIT,140) RECORD
         CALL SULINE (IUNIT,1)
         IUNIT=ICDPUN
         WRITE (IUNIT,140) RECORD
         CALL SULINE (IUNIT,1)
         ELSE
            WRITE (IUNIT,140) RECORD
            CALL SULINE (IUNIT,1)
         ENDIF
C
50    GO TO 10
C
60    IF (ISTRCE.GT.0) THEN
         WRITE (IOSDBG,150)
         CALL SULINE (IOSDBG,1)
         ENDIF
C
      RETURN
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
70    FORMAT (' *** ENTER SUOPUT')
80    FORMAT ('0*** ERROR - IN SUOPUT - THE CHARACTERS ',A,
     *   'WERE EXPECTED IN FIELD ',I2,' BUT ',2A4,' WERE FOUND.')
90    FORMAT ('0*** NOTE - RIGHT PARENTHESES ASSUMED IN FIELD ',I2,
     *   '.')
100   FORMAT ('0*** WARNING - NO LEFT PARENTHESES FOUND FOR OUTPUT ',
     *   'OPTION.')
110   FORMAT ('0*** NOTE - A COLON (:) WAS NOT FOUND IN THE ',
     *   'OUTPUT OPTION. OUTPUT UNIT SET TO ',I2,'.')
120   FORMAT ('0*** ERROR - UNIT NUMBER IN OUTPUT OPTION IS NOT AN ',
     *   'INTEGER NUMBER.')
130   FORMAT (' BLANK STRING FOUND IN FIELD ',I2)
140   FORMAT (A)
150   FORMAT (' *** EXIT SUOPUT')
C
      END
