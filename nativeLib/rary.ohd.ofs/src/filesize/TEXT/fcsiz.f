C MODULE FCSIZ
C-----------------------------------------------------------------------
C
      SUBROUTINE FCSIZ (USER,XCMD,DCBDDN,DCBMBR,DSKUNT,MDSTRK,NDSTRK,
     *   LDEBUG,LPUNCH,ISTAT)
C
C  ROUTINE TO COMPUTE THE NUMBER OF TRACKS FOR EACH OF THE NWSRFS
C  FORECAST SYSTEM FORECAST COMPONENT DATA BASE DATASETS.
C
      CHARACTER*(*) USER,DCBDDN,DCBMBR,XCMD
      CHARACTER*8 XWORD

C jgg following added by jto to fix bug r25-12 12/05
      CHARACTER*8 CHAR
      CHARACTER*80 LINE
      CHARACTER DLIM
      DATA DLIM/' '/
      INTEGER CLEN
C end of additions
C
      DIMENSION NDSTRK(MDSTRK)
      DIMENSION NAPRP(5),NACAP(5)
      DIMENSION NAPRS(5),NACAS(5)
C
      INCLUDE 'uio'
      INCLUDE 'ufreei'
      INCLUDE 'common/fcunit'
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/filesize/RCS/fcsiz.f,v $
     . $',                                                             '
     .$Id: fcsiz.f,v 1.3 2006/05/09 13:13:33 jgofus Exp $
     . $' /
C    ===================================================================
C
C
      ISTAT=0
C
      MPCTP=5
      MPCTC=5
      NPCTP=0
      NPCTC=0
C
C  PRINT CARD
      CALL WPCARD (IBUF)
C
      NCARRY=0
      NFG=0
      NSEG=0
      NRC=0
      NTTRKS=0
C
C  READ CARD
10    CALL RPCARD (IBUF,IERR)
      IF (IERR.GT.0) GO TO 130
      CALL ULINE (LP,1)
      WRITE (LP,*) ' '
      CALL WPCARD (IBUF)
C
C  FIND FIELDS ON CARD
      CALL UFREE (1,72)
C
C  CHECK FOR BLANK CARD
      IF (NFIELD.EQ.0) GO TO 10
C
      NFLD=1
      NCHAR=IFSTOP(NFLD)-IFSTRT(NFLD)+1
      XWORD=' '
      CALL UPACK1 (IBUF(IFSTRT(NFLD)),XWORD,NCHAR)
C
C  CHECK FOR COMMENT
      IF (XWORD.EQ.'$') GO TO 10
C
      IF (XWORD.EQ.'END') GO TO 80
      NFLD=2
      IF (XWORD.EQ.'NCARRY') GO TO 20
      IF (XWORD.EQ.'NFG') GO TO 30
      IF (XWORD.EQ.'NSEG') GO TO 40
      IF (XWORD.EQ.'NRC') GO TO 50
      IF (XWORD.EQ.'PCTPARM') GO TO 60
      IF (XWORD.EQ.'PCTCARRY') GO TO 70
C
C  INVALID COMMAND
      CALL UEROR (LP,1,-1)
      WRITE (LP,150) XWORD
      GO TO 10
C
C  SET NUMBER OF CARRYOVER GROUPS
20    CALL UNUMIC (IBUF,IFSTRT(NFLD),IFSTOP(NFLD),NCARRY)
      MCARRY=10
      IF (NCARRY.GT.MCARRY) THEN
         CALL UEROR (LP,2,-1)
         WRITE (LP,155) NCARRY,MCARRY
         NCARRY=MCARRY
         ENDIF
      GO TO 10
C
C  SET NUMBER OF FORECAST GROUPS
30    CALL UNUMIC (IBUF,IFSTRT(NFLD),IFSTOP(NFLD),NFG)
      GO TO 10
C
C  SET NUMBER OF SEGMENTS
40    CALL UNUMIC (IBUF,IFSTRT(NFLD),IFSTOP(NFLD),NSEG)
      GO TO 10
C
C  SET NUMBER OF RATING CURVES
50    CALL UNUMIC (IBUF,IFSTRT(NFLD),IFSTOP(NFLD),NRC)
      GO TO 10
C
C  SET PERCENT OF FULL SIZE ALLOTMENT FOR PARAMETER FILES
60    CALL UNUMIC (IBUF,IFSTRT(NFLD),IFSTOP(NFLD),INTEGR)
      IF (NPCTP+1.GT.MPCTP) THEN
         CALL UEROR (LP,1,-1)
         WRITE (LP,160) 'PCTPARM',MPCTP
         GO TO 10
         ENDIF
      NPCTP=NPCTP+1
      NAPRP(NPCTP)=INTEGR
      NAPRS(NPCTP)=NSEG
      IF (NFIELD.LT.NFLD+1) GO TO 10
      CALL UNUMIC (IBUF,IFSTRT(NFLD+1),IFSTOP(NFLD+1),INTEGR)
      NAPRS(NPCTP)=INTEGR
      GO TO 10
C
C  READ PERCENT OF FULL SIZE ALLOTMENT FOR CARRYOVER FILES
70    CALL UNUMIC (IBUF,IFSTRT(NFLD),IFSTOP(NFLD),INTEGR)
      IF (NPCTC+1.GT.MPCTC) THEN
         CALL UEROR (LP,1,-1)
         WRITE (LP,160) 'PCTCARRY',MPCTC
         GO TO 10
         ENDIF
      NPCTC=NPCTC+1
      NACAP(NPCTC)=INTEGR
      NACAS(NPCTC)=NSEG
      IF (NFIELD.LT.NFLD+1) GO TO 10
      CALL UNUMIC (IBUF,IFSTRT(NFLD+1),IFSTOP(NFLD+1),INTEGR)
      NACAS(NPCTC)=INTEGR
      GO TO 10
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
80    IPRINT=2
C
C  COMPUTE TRACKS FOR CARRYOVER GROUP DEFINITION FILE
      CALL UFLDCB (DCBDDN,DCBMBR,'FCCOGDEF',LRECL,LBLOCK,IERR)
      IF (IERR.GT.0) GO TO 130
      CALL UDKBLK ('    ',0,DSKUNT,LBLOCK,IPRINT,NBLKS,IPCNT,IERR)
      IF (IERR.GT.0) GO TO 130
      TRKS=1.*26/(LBLOCK/LRECL*NBLKS)
      NTRKS=TRKS
      IF (TRKS-NTRKS.GT.0) NTRKS=NTRKS+1
      IF (NTRKS.LE.0) NTRKS=1
      NTTRKS=NTTRKS+NTRKS
      NDSTRK(KFCGD)=NTRKS
      CALL ULINE (LP,2)
      WRITE (LP,170) 'FCCOGDEF',KFCGD,NTRKS
C
C  COMPUTE TRACKS FOR CARRYOVER FILE
      CALL UFLDCB (DCBDDN,DCBMBR,'FCCARRY',LRECL,LBLOCK,IERR)
      IF (IERR.GT.0) GO TO 130
      CALL UDKBLK ('    ',0,DSKUNT,LBLOCK,IPRINT,NBLKS,IPCNT,IERR)
      IF (IERR.GT.0) GO TO 130
      NWORDS=200
      NPRTRK=(LBLOCK/LRECL*NBLKS)/(NWORDS*4/LRECL)
      NTIME=NPCTC
      IF (NTIME.GT.0) GO TO 90
         NTIME=1
         NACAP(1)=100
         NACAS(1)=NSEG
90    TRKS=0.0
      DO 100 I=1,NTIME
         XTRKS=1.*(NACAS(I)*NCARRY*NACAP(I))/(NPRTRK*100)
         TRKS=TRKS+XTRKS
         IF (LDEBUG.GT.0) THEN
            CALL ULINE (LP,1)
            WRITE (LP,180) I,NACAS(I),NACAP(I),NPRTRK,XTRKS
            ENDIF
100      CONTINUE
      NTRKS=TRKS
      IF (TRKS-NTRKS.GT.0) NTRKS=NTRKS+1
      IF (NTRKS.LE.0) NTRKS=1
      NTTRKS=NTTRKS+NTRKS
      NDSTRK(KFCRY)=NTRKS
      CALL ULINE (LP,2)
      WRITE (LP,170) 'FCCARRY ',KFCRY,NTRKS
C
C  COMPUTE TRACKS FOR FORECAST GROUP DEFINITION FILE
      CALL UFLDCB (DCBDDN,DCBMBR,'FCFGSTAT',LRECL,LBLOCK,IERR)
      IF (IERR.GT.0) GO TO 130
      CALL UDKBLK ('    ',0,DSKUNT,LBLOCK,IPRINT,NBLKS,IPCNT,IERR)
      IF (IERR.GT.0) GO TO 130
      TRKS=1.*NFG/(LBLOCK/LRECL*NBLKS)
      NTRKS=TRKS
      IF (TRKS-NTRKS.GT.0) NTRKS=NTRKS+1
      IF (NTRKS.LE.0) NTRKS=1
      NTTRKS=NTTRKS+NTRKS
      NDSTRK(KFFGST)=NTRKS
      CALL ULINE (LP,2)
      WRITE (LP,170) 'FCFGSTAT',KFFGST,NTRKS
C
C  COMPUTE TRACKS FOR FORECAST GROUP SEGMENT LIST FILE
      ITRKS=0
      IF (ITRKS.EQ.1) THEN
         NTRKS=1
         ENDIF
      IF (ITRKS.EQ.0) THEN
         CALL UFLDCB (DCBDDN,DCBMBR,'FCFGLIST',LRECL,LBLOCK,IERR)
         IF (IERR.GT.0) GO TO 130
         CALL UDKBLK ('    ',0,DSKUNT,LBLOCK,IPRINT,NBLKS,IPCNT,IERR)
         IF (IERR.GT.0) GO TO 130
         TRKS=1.*NSEG/(LBLOCK/LRECL*NBLKS)
         NTRKS=TRKS
         IF (TRKS-NTRKS.GT.0) NTRKS=NTRKS+1
         IF (NTRKS.LE.0) NTRKS=1
         ENDIF
      NTTRKS=NTTRKS+NTRKS      
      NDSTRK(KFFGL)=NTRKS
      CALL ULINE (LP,2)
      WRITE (LP,170) 'FCFGLIST',KFFGL,NTRKS
C
C  COMPUTE TRACKS FOR SEGMENT POINTER FILE
      CALL UFLDCB (DCBDDN,DCBMBR,'FCSEGPTR',LRECL,LBLOCK,IERR)
      IF (IERR.GT.0) GO TO 130
      CALL UDKBLK ('    ',0,DSKUNT,LBLOCK,IPRINT,NBLKS,IPCNT,IERR)
      IF (IERR.GT.0) GO TO 130
      TRKS=1.*NSEG/(LBLOCK/LRECL*NBLKS)
      NTRKS=TRKS
      IF (TRKS-NTRKS.GT.0) NTRKS=NTRKS+1
      IF (NTRKS.LE.0) NTRKS=1
      NTTRKS=NTTRKS+NTRKS
      NDSTRK(KFSGPT)=NTRKS
      CALL ULINE (LP,2)
      WRITE (LP,170) 'FCSEGPTR',KFSGPT,NTRKS
C
C  COMPUTE TRACKS FOR SEGMENT DEFINITION FILE
      CALL UFLDCB (DCBDDN,DCBMBR,'FCSEGSTS',LRECL,LBLOCK,IERR)
      IF (IERR.GT.0) GO TO 130
      CALL UDKBLK ('    ',0,DSKUNT,LBLOCK,IPRINT,NBLKS,IPCNT,IERR)
      IF (IERR.GT.0) GO TO 130
      TRKS=1.*NSEG/(LBLOCK/LRECL*NBLKS)
      NTRKS=TRKS
      IF (TRKS-NTRKS.GT.0) NTRKS=NTRKS+1
      IF (NTRKS.LE.0) NTRKS=1
      NTTRKS=NTTRKS+NTRKS
      NDSTRK(KFSGST)=NTRKS
      CALL ULINE (LP,2)
      WRITE (LP,170) 'FCSEGSTS',KFSGST,NTRKS
C
C  COMPUTE TRACKS FOR PARAMETER FILE
      CALL UFLDCB (DCBDDN,DCBMBR,'FCPARAM',LRECL,LBLOCK,IERR)
      IF (IERR.GT.0) GO TO 130
      CALL UDKBLK ('    ',0,DSKUNT,LBLOCK,IPRINT,NBLKS,IPCNT,IERR)
      IF (IERR.GT.0) GO TO 130
      NWORDS=1000
      NPRTRK=(LBLOCK/LRECL*NBLKS)/(NWORDS*4/LRECL)
      NTIME=NPCTP
      IF (NTIME.GT.0) GO TO 110
         NTIME=1
         NAPRP(1)=100
         NAPRS(1)=NSEG
110   TRKS=0.0
      DO 120 I=1,NTIME
         XTRKS=1.*(NAPRS(I)*NAPRP(I))/(NPRTRK*100)
         TRKS=TRKS+XTRKS
         IF (LDEBUG.GT.0) THEN
            CALL ULINE (LP,1)
            WRITE (LP,190) I,NAPRS(I),NAPRP(I),NPRTRK,XTRKS
         ENDIF
120      CONTINUE
      NTRKS=TRKS
      IF (TRKS-NTRKS.GT.0) NTRKS=NTRKS+1
      IF (NTRKS.LE.0) NTRKS=1
      NTTRKS=NTTRKS+NTRKS
      NDSTRK(KFPARM)=NTRKS
      CALL ULINE (LP,2)
      WRITE (LP,170) 'FCPARAM ',KFPARM,NTRKS
C
C  COMPUTE TRACKS FOR RATING CURVE DEFINITION FILE
      CALL UFLDCB (DCBDDN,DCBMBR,'FCRATING',LRECL,LBLOCK,IERR)
      IF (IERR.GT.0) GO TO 130
      CALL UDKBLK ('    ',0,DSKUNT,LBLOCK,IPRINT,NBLKS,IPCNT,IERR)
      IF (IERR.GT.0) GO TO 130
      TRKS=1.*NRC/(LBLOCK/LRECL*NBLKS)
      NTRKS=TRKS
      IF (TRKS-NTRKS.GT.0) NTRKS=NTRKS+1
      IF (NTRKS.LE.0) NTRKS=1
      NTTRKS=NTTRKS+NTRKS
      NDSTRK(KFRTCV)=NTRKS
      CALL ULINE (LP,2)
      WRITE (LP,170) 'FCRATING',KFRTCV,NTRKS
C
C  COMPUTE TRACKS FOR RATING CURVE POINTER FILE
      CALL UFLDCB (DCBDDN,DCBMBR,'FCRCPTR',LRECL,LBLOCK,IERR)
      IF (IERR.GT.0) GO TO 130
      CALL UDKBLK ('    ',0,DSKUNT,LBLOCK,IPRINT,NBLKS,IPCNT,IERR)
      IF (IERR.GT.0) GO TO 130
      TRKS=1.*NRC/(LBLOCK/LRECL*NBLKS)
      NTRKS=TRKS
      IF (TRKS-NTRKS.GT.0) NTRKS=NTRKS+1
      IF (NTRKS.LE.0) NTRKS=1
      NTTRKS=NTTRKS+NTRKS
      NDSTRK(KFRCPT)=NTRKS
      CALL ULINE (LP,2)
      WRITE (LP,170) 'FCRCPTR ',KFRCPT,NTRKS
C
C  PRINT TOTAL TRACKS
      CALL ULINE (LP,2)
      WRITE (LP,200) NTTRKS
      GO TO 140
C
130   ISTAT=1
C
140   IF (ISTAT.EQ.0) THEN
         CALL ULINE (LPUNCH,6)
C jgg following lines replaced by jto with below for bug r25-12
C           WRITE (LPUNCH,210) 'FC',
C       *      'NCARRY',NCARRY,
C       *      'NFG',NFG,
C       *      'NSEG',NSEG,
C       *      'NRC',NRC
         WRITE (LPUNCH,230) ' '
         WRITE (LPUNCH,230) 'FC'
         LINE=' NCARRY'
         CALL KKI2AP(NCARRY,CHAR,CLEN)
         CALL KKCONC(LINE,CHAR,DLIM)
         WRITE (LPUNCH,230) LINE(1:LENSTR(LINE))
         LINE=' NFG'
         CALL KKI2AP(NFG,CHAR,CLEN)
         CALL KKCONC(LINE,CHAR,DLIM)
         WRITE (LPUNCH,230) LINE(1:LENSTR(LINE))
         LINE=' NSEG'
         CALL KKI2AP(NSEG,CHAR,CLEN)
         CALL KKCONC(LINE,CHAR,DLIM)
         WRITE (LPUNCH,230) LINE(1:LENSTR(LINE))
         LINE=' NRC'
         CALL KKI2AP(NRC,CHAR,CLEN)
         CALL KKCONC(LINE,CHAR,DLIM)
         WRITE (LPUNCH,230) LINE(1:LENSTR(LINE))
C end of changes

         CALL ULINE (LPUNCH,1)
C jgg following lines replaced by jto with below for bug r25-12
C           WRITE (LPUNCH,220) 'TRACKS',
C       *      NDSTRK(KFCGD),
C       *      NDSTRK(KFCRY),
C       *      NDSTRK(KFFGST),
C       *      NDSTRK(KFFGL),
C       *      NDSTRK(KFSGPT),
C       *      NDSTRK(KFSGST),
C       *      NDSTRK(KFPARM),
C       *      NDSTRK(KFRTCV),
C       *      NDSTRK(KFRCPT)
	 
         LINE=' TRACKS'
         CALL KKI2AP(NDSTRK(KFCGD),CHAR,CLEN)
         CALL KKCONC(LINE,CHAR,DLIM)
         CALL KKI2AP(NDSTRK(KFCRY),CHAR,CLEN)
         CALL KKCONC(LINE,CHAR,DLIM)
         CALL KKI2AP(NDSTRK(KFFGST),CHAR,CLEN)
         CALL KKCONC(LINE,CHAR,DLIM)
         CALL KKI2AP(NDSTRK(KFFGL),CHAR,CLEN)
         CALL KKCONC(LINE,CHAR,DLIM)
         CALL KKI2AP(NDSTRK(KFSGPT),CHAR,CLEN)
         CALL KKCONC(LINE,CHAR,DLIM)
         CALL KKI2AP(NDSTRK(KFSGST),CHAR,CLEN)
         CALL KKCONC(LINE,CHAR,DLIM)
         CALL KKI2AP(NDSTRK(KFPARM),CHAR,CLEN)
         CALL KKCONC(LINE,CHAR,DLIM)
         CALL KKI2AP(NDSTRK(KFRTCV),CHAR,CLEN)
         CALL KKCONC(LINE,CHAR,DLIM)
         CALL KKI2AP(NDSTRK(KFRCPT),CHAR,CLEN)
         CALL KKCONC(LINE,CHAR,DLIM)
         WRITE (LPUNCH,230) LINE(1:LENSTR(LINE))
C end of changes
         CALL ULINE (LPUNCH,1)
         WRITE (LPUNCH,230) 'END'
         ENDIF
C
      RETURN
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
150   FORMAT ('+*** ERROR - INVALID OPTION: ',A)
C jgg following lines replaced by jto with below for bug r25-12
C 155   FORMAT ('+*** ERROR - NUMBER OF CARRYOVER GROUPS SPECIFIED (',
C       *   I3,') EXCEEDS MAXIMUM ALLOWED (',
C       *   I2,').')
C 160   FORMAT ('+*** ERROR - MAXIMUM NUMBER OF ',A,' OPTIONS (',I2,
C      *   ') EXCEEDED.')
C 170   FORMAT ('0',15X,'TRACKS FOR FILE ',A,' UNIT ',I2.2,' = ',I3)
C 180   FORMAT (' I=',I2,3X,'NACAS(I)=',I3,3X,'NACAP(I)=',I3,3X,
C      *   'NPRTRK=',I2,3X,'XTRKS=',F6.2)
C 190   FORMAT (' I=',I2,3X,'NAPRS(I)=',I3,3X,'NAPRP(I)=',I3,3X,
C      *   'NPRTRK=',I2,3X,'XTRKS=',F6.2)
C 200   FORMAT ('0TOTAL TRACKS = ',I5)
C 210   FORMAT (/ A / A,1X,I4 / A,1X,I4 / A,1X,I4 / A,1X,I4)
C 220   FORMAT (A,1X,9(I3,1X))

155   FORMAT ('+*** ERROR - NUMBER OF CARRYOVER GROUPS SPECIFIED (',
     *   I4,') EXCEEDS MAXIMUM ALLOWED (',
     *   I4,').')
160   FORMAT ('+*** ERROR - MAXIMUM NUMBER OF ',A,' OPTIONS (',I2,
     *   ') EXCEEDED.')
170   FORMAT ('0',15X,'TRACKS FOR FILE ',A,' UNIT ',I2.2,' = ',I4)
180   FORMAT (' I=',I2,3X,'NACAS(I)=',I4,3X,'NACAP(I)=',I4,3X,
     *   'NPRTRK=',I2,3X,'XTRKS=',F6.2)
190   FORMAT (' I=',I2,3X,'NAPRS(I)=',I4,3X,'NAPRP(I)=',I4,3X,
     *   'NPRTRK=',I2,3X,'XTRKS=',F6.2)
200   FORMAT ('0TOTAL TRACKS = ',I6)
C end of changes
230   FORMAT (A)
C
      END
