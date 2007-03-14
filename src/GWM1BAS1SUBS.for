C
C
      MODULE GWM1BAS1SUBS
C     VERSION: 20FEB2005
      IMPLICIT NONE
      PRIVATE
      PUBLIC::GWM1BAS1AR,GWM1BAS1RW,GWM1BAS1RPP
C
      INTEGER, PARAMETER :: I4B = SELECTED_INT_KIND(9)
      INTEGER, PARAMETER :: I2B = SELECTED_INT_KIND(4)
      INTEGER, PARAMETER :: SP = KIND(1.0)
      INTEGER, PARAMETER :: DP = KIND(1.0D0)
      INTEGER, PARAMETER :: LGT = KIND(.TRUE.)
C
C-----FOR ERROR HANDLING
      CHARACTER(LEN=200)::FLNM 
      CHARACTER(LEN=20)::FILACT,FMTARG,ACCARG,FILSTAT
      INTEGER(I4B)::NDUM
      REAL(SP)::RDUM
C

      CONTAINS
C***********************************************************************
      SUBROUTINE GWM1BAS1AR(IN,IOUT,IOUTG,NROW,NCOL,NLAY,NPER,
     1                      PERLEN,HCLOSE)
C***********************************************************************
C     VERSION: 09AUG2006
C     PURPOSE: READ AND PREPARE ALL INFORMATION FOR GWM
C-----------------------------------------------------------------------
      USE GWM1BAS1, ONLY : GWMOUT,SMALLEPS,NSTRESS
      USE GWM1DCV1, ONLY : NFVAR,NEVAR,NBVAR,GWM1DCV1AR
      USE GWM1OBJ1, ONLY : GWM1OBJ1AR
      USE GWM1RMS1, ONLY : NRMC,NCON,NV,NDV,HCLOSEG
      USE GWM1RMS1SUBS, ONLY : GWM1RMS1AR
      USE GWM1DCC1, ONLY : GWM1DCC1AR
      USE GWM1STC1, ONLY : GWM1STC1AR
      USE GWM1HDC1, ONLY : GWM1HDC1AR
      USE GWM1SMC1, ONLY : GWM1SMC1AR
      INTEGER(I4B),INTENT(IN)::IN,IOUT,IOUTG,NROW,NCOL,NLAY,NPER
      REAL(SP),INTENT(IN)::PERLEN(:)
      REAL(SP),INTENT(IN)::HCLOSE
      INTERFACE  
        SUBROUTINE USTOP(STOPMESS)
        CHARACTER STOPMESS*(*)
        END
C
        SUBROUTINE URDCOM(IN,IOUT,LINE)
        CHARACTER*(*) LINE
        END
C
        SUBROUTINE URWORD(LINE,ICOL,ISTART,ISTOP,NCODE,N,R,IOUT,IN)
        CHARACTER*(*) LINE
        CHARACTER*20 STRING
        CHARACTER*30 RW
        CHARACTER*1 TAB
        END
      END INTERFACE
C-----LOCAL VARIABLES
      INTEGER(I4B)::LLOC,IKEYS,IKEYF,INAMES,INAMEF,I
      CHARACTER(LEN=200)::FNAME,LINE
      CHARACTER(LEN=10)::KEYWORD
C+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C
C-----CHECK THAT BOTH A LISTING AND GLOBAL FILE ARE PRESENT
      IF(IOUT.EQ.IOUTG)THEN
        WRITE(IOUTG,1000,ERR=990)
        CALL USTOP(' ')
      ENDIF
C1----IDENTIFY PACKAGE.
      WRITE(IOUTG,1010)IN
C-----GWM OUTPUT UNIT NUMBERS - ASSIGN GWMOUT THE GLOBAL OUTPUT UNIT NUMBER
      GWMOUT = IOUTG 
C
C-----DEFINE THE INTERNAL HCLOSE VALUE
      IF(HCLOSE.NE.0.0)THEN
	  HCLOSEG = REAL(HCLOSE,DP)
      ELSE
        HCLOSEG = SMALLEPS
      ENDIF
C
C-----ASSIGN NPER TO NSTRESS; NSTRESS CAN BE OBTAINED THROUGH MODULES; NEEDED FOR MF2K
      NSTRESS=NPER      
C
C-----WRITE HEADER
      WRITE(GWMOUT,1020,ERR=990)'Reading GWM Input'
C
C-----CHECK FOR COMMENT LINES
      CALL URDCOM(IN,GWMOUT,LINE)
C
C-----READ DECISION VARIABLE FILE NAME AND CALL SGWM1ARDV 
      LLOC=1
      CALL URWORD(LINE,LLOC,IKEYS,IKEYF,1,NDUM,RDUM,GWMOUT,IN)
      CALL URWORD(LINE,LLOC,INAMES,INAMEF,0,NDUM,RDUM,GWMOUT,IN)
      IF(LINE(IKEYS:IKEYF).EQ.'DECVAR')THEN
        FNAME=LINE(INAMES:INAMEF)
        CALL GWM1DCV1AR(FNAME,GWMOUT,NROW,NCOL,NLAY,NPER,
     &                  NFVAR,NEVAR,NBVAR,NDV)
      ELSE
        WRITE(GWMOUT,1030,ERR=990)
        CALL USTOP(' ')
      ENDIF
C
C-----READ OBJECTIVE FUNCTION FILE AND CALL SGWM1AROF 
      CALL URDCOM(IN,GWMOUT,LINE)
      LLOC=1
      CALL URWORD(LINE,LLOC,IKEYS,IKEYF,1,NDUM,RDUM,GWMOUT,IN)
      CALL URWORD(LINE,LLOC,INAMES,INAMEF,0,NDUM,RDUM,GWMOUT,IN)
      IF(LINE(IKEYS:IKEYF).EQ.'OBJFNC')THEN
        FNAME=LINE(INAMES:INAMEF)
        CALL GWM1OBJ1AR(FNAME,GWMOUT,NPER,REAL(PERLEN,DP),NFVAR,NEVAR,
     &                  NBVAR)
      ELSE
        WRITE(GWMOUT,1040,ERR=990)
        CALL USTOP(' ')
      ENDIF
C
C-----INITIALIZE THE NUMBER OF VARIABLES CONSTRAINTS
      NV = NDV - 1
      NCON = 0
      NRMC = 0
C
C-----READ DECISION-VARIABLE CONSTRAINT FILE AND CALL SGWM1ARVC 
      CALL URDCOM(IN,GWMOUT,LINE)
      LLOC=1
      CALL URWORD(LINE,LLOC,IKEYS,IKEYF,1,NDUM,RDUM,GWMOUT,IN)
      CALL URWORD(LINE,LLOC,INAMES,INAMEF,0,NDUM,RDUM,GWMOUT,IN)
      IF(LINE(IKEYS:IKEYF).EQ.'VARCON')THEN
        FNAME=LINE(INAMES:INAMEF)
        CALL GWM1DCC1AR(FNAME,GWMOUT,NFVAR,NEVAR,NBVAR,NV,NCON)
      ELSE
        WRITE(GWMOUT,2000,ERR=990)
        CALL USTOP(' ')
      ENDIF
C
C-----READ REMAINING CONSTRAINT FILES AND SOLUTION FILE
C      IREF=0                                     ! INITIALIZE REFERENCE FLAG
  100 CONTINUE
        READ(IN,'(A)',END=900)LINE
        LLOC=1
        CALL URWORD(LINE,LLOC,IKEYS,IKEYF,1,NDUM,RDUM,GWMOUT,IN)
        CALL URWORD(LINE,LLOC,INAMES,INAMEF,0,NDUM,RDUM,GWMOUT,IN)
        KEYWORD = LINE(IKEYS:IKEYF)
        FNAME=LINE(INAMES:INAMEF)
C
C-------PROCESS KEYWORD AND ACCESS APPROPRIATE INPUT FILE
        IF(LINE(1:1).EQ.'#')THEN                 ! LINE HAS BEEN COMMENTED
          WRITE(GWMOUT,'(1X,A)')LINE
        ELSEIF(KEYWORD.EQ.'SUMCON')THEN
          CALL GWM1SMC1AR(FNAME,GWMOUT,NFVAR,NEVAR,NBVAR,NV,NCON)
        ELSEIF(KEYWORD.EQ.'HEDCON')THEN
          CALL GWM1HDC1AR(FNAME,GWMOUT,NPER,NROW,NCOL,NLAY,NV,NCON,NRMC)
        ELSEIF(KEYWORD.EQ.'STRMCON')THEN
          CALL GWM1STC1AR(FNAME,GWMOUT,NPER,NV,NCON,NRMC)
        ELSEIF(KEYWORD.EQ.'SOLN')THEN
          CALL GWM1RMS1AR(FNAME,GWMOUT,NFVAR,NEVAR,NBVAR,NDV,NV,NCON)
          RETURN                                 ! SOLUTION FILE IS LAST INPUT
        ELSE
          WRITE(GWMOUT,3000,ERR=990)KEYWORD
          CALL USTOP(' ')
        ENDIF
      GOTO 100                                   ! READ NEXT KEYWORD
C
C-----DONE READING IN INPUT DATA
  900 WRITE(GWMOUT,4000,ERR=990)
      CALL USTOP(' ')
C
 1000 FORMAT('PROGRAM STOPPED: GWM REQUIRES SEPARATE LIST',
     &       ' AND GLOBAL FILES')
 1010 FORMAT(/,/,1X,/1X,'GWM1 -- GROUND-WATER MANAGEMENT PROCESS,',
     1  ' VERSION 1.1.1 031507',/,' INPUT READ FROM UNIT',I4,/)
 1020 FORMAT(/,70('-'),/,T16,A,/,70('-'))
 1030 FORMAT(1X,/1X,'PROGRAM STOPPED. USER MUST SPECIFY A',
     1  ' DECISION VARIABLE FILE')
 1040 FORMAT(1X,/1X,'PROGRAM STOPPED. USER MUST SPECIFY AN',
     1  ' OBJECTIVE FUNCTION FILE')
 2000 FORMAT(1X,/1X,'PROGRAM STOPPED. USER MUST SPECIFY A',
     1  ' DECISION-VARIABLES CONSTRAINT FILE')
 3000 FORMAT(1X,/1X,'PROGRAM STOPPED. ',A10,' NOT A VALID CONSTRAINT',
     1  /,' OR SOLUTION KEYWORD')
 4000 FORMAT(1X,/1X,'PROGRAM STOPPED. USER MUST SPECIFY A',
     1  ' SOLUTION FILE AS THE LAST FILE IN THE GWM FILE')
C
      RETURN
C
C-----ERROR HANDLING
  990 CONTINUE
C-----FILE-WRITING ERROR
      INQUIRE(GWMOUT,NAME=FLNM,FORM=FMTARG,ACCESS=ACCARG,ACTION=FILACT)
      WRITE(*,9900)TRIM(FLNM),IOUT,FMTARG,ACCARG,FILACT
 9900 FORMAT(/,1X,'*** ERROR WRITING FILE "',A,'" ON UNIT ',I5,/,
     &7X,'SPECIFIED FILE FORMAT: ',A,/
     &7X,'SPECIFIED FILE ACCESS: ',A,/
     &7X,'SPECIFIED FILE ACTION: ',A,/
     &2X,'-- STOP EXECUTION (GWM1BAS1AR)')
      CALL USTOP(' ')
C
  991 CONTINUE
C-----FILE-READING ERROR
      INQUIRE(IN,NAME=FLNM,FORM=FMTARG,ACCESS=ACCARG,ACTION=FILACT)
      WRITE(*,9910)TRIM(FLNM),IN,FMTARG,ACCARG,FILACT
      WRITE(IOUT,9910)TRIM(FLNM),IN,FMTARG,ACCARG,FILACT
 9910 FORMAT(/,1X,'*** ERROR READING FILE "',A,'" ON UNIT ',I5,/,
     &7X,'SPECIFIED FILE FORMAT: ',A,/
     &7X,'SPECIFIED FILE ACCESS: ',A,/
     &7X,'SPECIFIED FILE ACTION: ',A,/
     &2X,'-- STOP EXECUTION (GWM1BAS1AR)')
      CALL USTOP(' ')
C
      END SUBROUTINE GWM1BAS1AR
C
C
C***********************************************************************
      SUBROUTINE GWM1BAS1RW(INUNIT,FNAME,CUNIT,IREWND,NIUNIT,IOUT,IOUTG,
     &                      VERSION)
C***********************************************************************
C     
C-----GWM1BAS1RW CREATED FROM PES1BAS6RW VERSION 19990811ERB 
C     ******************************************************************
C     VERSION: 20FEB2005
C     REWIND FILES.
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      INTEGER(I4B),INTENT(INOUT)::INUNIT
      CHARACTER(LEN=*),INTENT(IN)::FNAME
      INTEGER(I4B),INTENT(IN)::NIUNIT,IOUT,IOUTG
      CHARACTER(LEN=4),INTENT(IN)::CUNIT(NIUNIT)
      INTEGER(I4B),INTENT(IN)::IREWND(NIUNIT)
      CHARACTER(LEN=40),INTENT(IN)::VERSION
      INTERFACE
        INTEGER FUNCTION NONB_LEN(CHARVAR,LENGTH)
        CHARACTER*(*) CHARVAR,C*1
        INTEGER LENGTH
        END
C
        SUBROUTINE URWORD(LINE,ICOL,ISTART,ISTOP,NCODE,N,R,IOUT,IN)
        CHARACTER*(*) LINE
        CHARACTER*20 STRING
        CHARACTER*30 RW
        CHARACTER*1 TAB
        END
C
        SUBROUTINE USTOP(STOPMESS)
        CHARACTER STOPMESS*(*)
        END
      END INTERFACE
      CHARACTER(len=40)::SPACES
      CHARACTER(len=200)::LINE
      LOGICAL(LGT)::LOP
      INTEGER(I4B)::LLOC,ITYP1,ITYP2,ISTART,ISTOP,INAM1,INAM2,I 
      INTEGER(I4B)::LENVER,INDENT,IU 
      INCLUDE 'openspec.inc'
C     ------------------------------------------------------------------
C
      SPACES=' '
      LENVER=NONB_LEN(VERSION,40)
      INDENT=40-(LENVER+8)/2
C
C1------OPEN THE NAME FILE.
      FILSTAT='OLD'
      OPEN(UNIT=INUNIT,FILE=FNAME,STATUS=FILSTAT,ACTION=ACTION(1),
     &     ERR=999)
C
C2------READ A LINE; IGNORE BLANK LINES AND COMMENT LINES.
   10 READ(INUNIT,'(A)',END=100) LINE
      IF(LINE.EQ.' ')GOTO 10
      IF(LINE(1:1).EQ.'#')GOTO 10
C
C3------DECODE THE FILE TYPE, UNIT NUMBER, AND NAME.
      LLOC=1
      CALL URWORD(LINE,LLOC,ITYP1,ITYP2,1,NDUM,RDUM,IOUT,INUNIT)
      CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,IU,RDUM,IOUT,INUNIT)
      CALL URWORD(LINE,LLOC,INAM1,INAM2,0,NDUM,RDUM,IOUT,INUNIT)
C
C4------REWIND IF MAJOR OPTION FILE AND IF IREWND FLAG IS SET
      DO 20 I=1,NIUNIT
         IF(LINE(ITYP1:ITYP2).EQ.CUNIT(I))THEN
            IF(IREWND(I).NE.0)GOTO 30
            GOTO 10
         END IF
   20 ENDDO
C
C5------REWIND IF BAS OR NONGLOBAL LIST FILE
      IF(LINE(ITYP1:ITYP2).EQ.'BAS6')GOTO 30
      IF(LINE(ITYP1:ITYP2).EQ.'LIST')THEN
         IF(IU.EQ.IOUTG)GOTO 10
         GOTO 30
      END IF
C
C5------DO NOT REWIND GLOBAL FILE
      IF(LINE(ITYP1:ITYP2).EQ.'GLOBAL')GOTO 10
C
C5------NOT A MAJOR OPTION.  REWIND IF FILE TYPE IS DATA.
      IF(LINE(ITYP1:ITYP2).NE.'DATA'         .AND.
     1   LINE(ITYP1:ITYP2).NE.'DATA(BINARY)' )GOTO 10
C
C6------REWIND THE FILE
   30 REWIND(IU)
C
      IF(LINE(ITYP1:ITYP2).EQ.'LIST')THEN
         WRITE(IOUT,1000)SPACES(1:INDENT),VERSION(1:LENVER)
 1000    FORMAT(34X,'MODFLOW-2000',/,
     1          6X,'U.S. GEOLOGICAL SURVEY MODULAR',
     2          ' FINITE-DIFFERENCE GROUND-WATER FLOW MODEL',/,
     3          A,'VERSION ',A,/)
         WRITE(IOUT,2000)'LIST file.'
 2000    FORMAT(/,1X,'This model run produced both GLOBAL and ',
     1          'LIST files.  This is the ',A,/)
C
      ENDIF
      WRITE(IOUT,3000)LINE(INAM1:INAM2),LINE(ITYP1:ITYP2),IU
 3000 FORMAT(1X,/1X,'REWOUND ',A,/
     1       1X,'FILE TYPE:',A,'   UNIT ',I4)
      GOTO 10
C
C7------END OF NAME FILE.
  100 CONTINUE
      INQUIRE(UNIT=INUNIT,OPENED=LOP)
      IF(LOP)CLOSE(UNIT=INUNIT)
C
      RETURN
C
C-----ERROR HANDLING
  999 CONTINUE
C-----FILE-OPENING ERROR
      INQUIRE(INUNIT,NAME=FLNM,FORM=FMTARG,ACCESS=ACCARG,ACTION=FILACT)
      WRITE(*,9990)TRIM(FLNM),INUNIT,FILSTAT,FMTARG,ACCARG,FILACT
      WRITE(IOUT,9990)TRIM(FLNM),INUNIT,FILSTAT,FMTARG,ACCARG,FILACT
 9990 FORMAT(/,1X,'*** ERROR OPENING FILE "',A,'" ON UNIT ',I5,/,
     &7X,'SPECIFIED FILE STATUS: ',A,/
     &7X,'SPECIFIED FILE FORMAT: ',A,/
     &7X,'SPECIFIED FILE ACCESS: ',A,/
     &7X,'SPECIFIED FILE ACTION: ',A,/
     &2X,'-- STOP EXECUTION (GWM1BAS1RW)')
      CALL USTOP(' ')
C
      END SUBROUTINE GWM1BAS1RW
C
C
C***********************************************************************
      SUBROUTINE GWM1BAS1RPP(IBOUND,HNEW,STRT,INBAS,HEADNG,NCOL,
     1    NROW,NLAY,VBVL,IOFLG,INOC,IHEDFM,IDDNFM,IHEDUN,IDDNUN,IOUT,
     2    IPEROC,ITSOC,CHEDFM,CDDNFM,IBDOPT,IXSEC,LBHDSV,LBDDSV,IFREFM,
     3    IBOUUN,LBBOSV,CBOUFM,HNOFLO,NIUNIT,IAUXSV,RESETDD,
     4    RESETDDNEXT,ITRSS)
C***********************************************************************
C
C-----GWM1BAS1RPP CREATED FROM GWF1BAS6RPP VERSION 11JAN2000
C     ******************************************************************
C     VERSION: 07JUL2006
C     PREPARE BAS DATA FOR NEXT FLOW PROCESS SIMULATION
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      USE GWM1BAS1, ONLY : ZERO
      INTEGER(I4B),INTENT(IN)::NCOL,NROW,NLAY,NIUNIT,INBAS,INOC,IOUT,
     &                         IXSEC,IFREFM,ITRSS
      INTEGER(I4B),INTENT(IN)::IBOUND(NCOL,NROW,NLAY)
      REAL(DP),INTENT(INOUT)::HNEW(NCOL,NROW,NLAY)
      REAL(SP),INTENT(IN)::STRT(NCOL,NROW,NLAY)
      CHARACTER(LEN=80),INTENT(IN)::HEADNG(2) 
      REAL(SP),INTENT(OUT)::VBVL(4,NIUNIT)
      INTEGER(I4B),INTENT(OUT)::IOFLG(NLAY,5)
      INTEGER(I4B),INTENT(OUT)::IHEDFM,IDDNFM,IHEDUN,IDDNUN,IBOUUN,
     1                          IPEROC,ITSOC,IBDOPT,LBHDSV,LBDDSV, 
     2                          LBBOSV,IAUXSV
      CHARACTER(LEN=20),INTENT(OUT)::CHEDFM,CDDNFM,CBOUFM
      REAL(SP),INTENT(INOUT)::HNOFLO
      LOGICAL(LGT),INTENT(OUT)::RESETDD,RESETDDNEXT
      INTERFACE
        SUBROUTINE U2DINT(IA,ANAME,II,JJ,K,IN,IOUT)
        CHARACTER*24 ANAME
        DIMENSION IA(JJ,II)
        CHARACTER*20 FMTIN
        CHARACTER*200 CNTRL
        CHARACTER*200 FNAME
        END
C
        SUBROUTINE U2DREL(A,ANAME,II,JJ,K,IN,IOUT)
        CHARACTER*24 ANAME
        DIMENSION A(JJ,II)
        CHARACTER*20 FMTIN
        CHARACTER*200 CNTRL
        CHARACTER*16 TEXT
        CHARACTER*200 FNAME
        END
C
        SUBROUTINE SGWF1BAS6I(NLAY,IOFLG,INOC,IOUT,IHEDFM,IDDNFM,IHEDUN,
     1    IDDNUN,IPEROC,ITSOC,CHEDFM,CDDNFM,IBDOPT,LBHDSV,LBDDSV,IFREFM,
     2    IBOUUN,LBBOSV,CBOUFM,IAUXSV,RESETDD,RESETDDNEXT)
        DIMENSION IOFLG(NLAY,5)
        CHARACTER*20 CHEDFM,CDDNFM,CBOUFM
        CHARACTER*200 LINE
        LOGICAL RESETDD, RESETDDNEXT
        END
C
        SUBROUTINE USTOP(STOPMESS)
        CHARACTER STOPMESS*(*)
        END
      END INTERFACE
      REAL(DP)::HNF
      INTEGER(I4B)::I,J,K,KK
      CHARACTER(LEN=24)::ANAME(2)=(/'          BOUNDARY ARRAY',
     &                             '            INITIAL HEAD'/)
C     ------------------------------------------------------------------
C
C1------PRINT SIMULATION TITLE, CALCULATE # OF CELLS IN A LAYER.
      WRITE(IOUT,'(''1'',/1X,A)',ERR=990)HEADNG(1)
      WRITE(IOUT,'(1X,A)',ERR=990) HEADNG(2)
C
      IF(ITRSS.EQ.0)THEN                         ! STEADY STATE SIMULATION
C-------DON'T READ IBOUND - USE IBOUND VALUES FROM PRIOR SIMULATION
C       DON'T READ HNOFLO - USE ORIGINAL VALUE
        HNF=HNOFLO
        WRITE(IOUT,1000,ERR=990)HNOFLO
C-------DON'T READ STRT - USE HNEW DIRECTLY AS INITIAL CONDITION
        WRITE(IOUT,2000,ERR=990) 
C
      ELSE                                       ! NON-STEADY STATE SIMULATION
C-------FOR NON-STEADY FLOW PROCESS READ AND INITIALIZE BASIC MODEL ARRAYS
C
C2------READ BOUNDARY ARRAY(IBOUND) ONE LAYER AT A TIME.
        IF(IXSEC.EQ.0)THEN
          DO 100 K=1,NLAY
            KK=K
            CALL U2DINT(IBOUND(1,1,KK),ANAME(1),NROW,NCOL,KK,INBAS,IOUT)
  100     ENDDO
        ELSE
          CALL U2DINT(IBOUND(1,1,1),ANAME(1),NLAY,NCOL,-1,INBAS,IOUT)
        ENDIF
C
C3------READ AND PRINT HEAD VALUE TO BE PRINTED FOR NO-FLOW CELLS.
        IF(IFREFM.EQ.0) THEN
          READ(INBAS,'(F10.0)',ERR=991) HNOFLO
        ELSE
          READ(INBAS,*) HNOFLO
        ENDIF
        HNF=HNOFLO
        WRITE(IOUT,1000,ERR=990)HNOFLO
C
C4------READ INITIAL HEADS.
        IF(IXSEC.EQ.0)THEN
          DO 200 K=1,NLAY
            KK=K
            CALL U2DREL(STRT(1,1,KK),ANAME(2),NROW,NCOL,KK,INBAS,IOUT)
  200     ENDDO
        ELSE
          CALL U2DREL(STRT(1,1,1),ANAME(2),NLAY,NCOL,-1,INBAS,IOUT)
        END IF
C
C5------COPY INITIAL HEADS FROM STRT TO HNEW.
        DO 400 K=1,NLAY
        DO 400 I=1,NROW
        DO 400 J=1,NCOL
          HNEW(J,I,K)=STRT(J,I,K)
          IF(IBOUND(J,I,K).EQ.0) HNEW(J,I,K)=HNF
  400   CONTINUE
      ENDIF
C
C7------INITIALIZE VOLUMETRIC BUDGET ACCUMULATORS TO ZERO.
      VBVL=ZERO
C
C8------SET UP OUTPUT CONTROL.
      CALL SGWF1BAS6I(NLAY,IOFLG,INOC,IOUT,IHEDFM,IDDNFM,IHEDUN,
     1   IDDNUN,IPEROC,ITSOC,CHEDFM,CDDNFM,IBDOPT,LBHDSV,LBDDSV,IFREFM,
     2   IBOUUN,LBBOSV,CBOUFM,IAUXSV,RESETDD,RESETDDNEXT)
C
 1000   FORMAT(1X,/1X,'AQUIFER HEAD WILL BE SET TO ',1PG11.5,
     1         ' AT ALL NO-FLOW NODES (IBOUND=0).')
 2000   FORMAT(1X,/1X,'INITIAL HEAD WILL BE SET TO ',
     1         'THE SOLUTION FROM THE PRIOR FLOW-PROCESS SIMULATION')
C
C9----RETURN
      RETURN
C
C-----ERROR HANDLING
  990 CONTINUE
C-----FILE-WRITING ERROR
      INQUIRE(IOUT,NAME=FLNM,FORM=FMTARG,ACCESS=ACCARG,ACTION=FILACT)
      WRITE(*,9900)TRIM(FLNM),IOUT,FMTARG,ACCARG,FILACT
 9900 FORMAT(/,1X,'*** ERROR WRITING FILE "',A,'" ON UNIT ',I5,/,
     &7X,'SPECIFIED FILE FORMAT: ',A,/
     &7X,'SPECIFIED FILE ACCESS: ',A,/
     &7X,'SPECIFIED FILE ACTION: ',A,/
     &2X,'-- STOP EXECUTION (GWM1BAS1RPP)')
      CALL USTOP(' ')
C
  991 CONTINUE
C-----FILE-READING ERROR
      INQUIRE(INBAS,NAME=FLNM,FORM=FMTARG,ACCESS=ACCARG,ACTION=FILACT)
      WRITE(*,9910)TRIM(FLNM),INBAS,FMTARG,ACCARG,FILACT
      WRITE(IOUT,9910)TRIM(FLNM),INBAS,FMTARG,ACCARG,FILACT
 9910 FORMAT(/,1X,'*** ERROR READING FILE "',A,'" ON UNIT ',I5,/,
     &7X,'SPECIFIED FILE FORMAT: ',A,/
     &7X,'SPECIFIED FILE ACCESS: ',A,/
     &7X,'SPECIFIED FILE ACTION: ',A,/
     &2X,'-- STOP EXECUTION (GWM1BAS1RPP)')
      CALL USTOP(' ')
C
      END SUBROUTINE GWM1BAS1RPP
C
C
      END MODULE GWM1BAS1SUBS
C
C