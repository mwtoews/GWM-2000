      MODULE GWM1DCV1
C     VERSION: 20FEB2005
      IMPLICIT NONE
      PRIVATE  
      PUBLIC::NFVAR,FVNAME,FVMIN,FVMAX,FVBASE,FVINI,FVRATIO,FVILOC,EVSP,
     &        FVJLOC,FVKLOC,FVNCELL,FVON,FVDIR,FVSP,EVNAME,EVMIN,EVMAX,
     &        EVBASE,EVDIR,NEVAR,BVNAME,BVBASE,BVNLIST,BVLIST,NBVAR
      PUBLIC::GWM1DCV1AR,GWM1DCV1FM,GWF1DCV1FM,GWF1DCV1BD
C
      INTEGER, PARAMETER :: I4B = SELECTED_INT_KIND(9)
      INTEGER, PARAMETER :: I2B = SELECTED_INT_KIND(4)
      INTEGER, PARAMETER :: SP = KIND(1.0)
      INTEGER, PARAMETER :: DP = KIND(1.0D0)
      INTEGER, PARAMETER :: LGT = KIND(.TRUE.)
C
C-----VARIABLES FOR FLOW DECISION VARIABLES
      INTEGER(I4B),SAVE::NFVAR
      CHARACTER(LEN=10),SAVE,ALLOCATABLE::FVNAME(:)
      REAL(SP),SAVE,ALLOCATABLE::FVRATIO(:,:)
      REAL(DP),SAVE,ALLOCATABLE::FVMIN(:),FVMAX(:),FVBASE(:),FVINI(:)
      INTEGER(I4B),SAVE,ALLOCATABLE::FVILOC(:,:),FVJLOC(:,:),FVKLOC(:,:)
      INTEGER(I4B),SAVE,ALLOCATABLE::FVNCELL(:),FVON(:),FVDIR(:)
      LOGICAL(LGT),SAVE,ALLOCATABLE ::FVSP(:,:)
C
C      NFVAR    -number of flow-rate variables
C      FVNAME   -name of flow-rate variable (10 digits)
C      FVMIN    -lower bound for flow-rate variable
C      FVMAX    -upper bound for flow-rate variable
C      FVBASE   -current value of flow-rate variable during solution process 
C      FVINI    -initial value of flow-rate variables
C      FVRATIO  -fraction of total flow applied at each cell associated with
C                  the flow-rate variable
C      FVILOC(I,J), FVJLOC(I,J), FVKLOC(I,J)
C               -i,j,k location in MODFLOW grid of the jth cell associated  
C                  with the ith flow-rate variable
C      FVNCELL  -number of cells associated with the flow-rate variable
C      FVON     -flag for availability of flow-rate variable (>0-yes, =<0-no) 
C      FVDIR    -flag for direction of flow for flow-rate variable 
C                 1 => inject, 2 => withdrawal
C      FVSP     -logical array (NFVAR x # stress periods) which records if a
C                  flow-rate variable is a candidate during a stress period
C
C-----VARIABLES FOR EXTERNAL DECISION VARIABLES
      INTEGER(I4B),SAVE::NEVAR
      CHARACTER(LEN=10),SAVE,ALLOCATABLE::EVNAME(:)
      REAL(DP),SAVE,ALLOCATABLE::EVMIN(:),EVMAX(:)
      REAL(DP),SAVE,ALLOCATABLE::EVBASE(:)
      INTEGER(I4B),SAVE,ALLOCATABLE::EVDIR(:)
      LOGICAL(LGT),SAVE,ALLOCATABLE::EVSP(:,:)
C
C      NEVAR    -number of external variables
C      EVNAME   -name of external variable (10 digits)
C      EVMIN    -lower bound for external variable
C      EVMAX    -upper bound for external variable
C      EVBASE   -current value of external variable during solution process 
C      EVDIR    -flag for direction of flow for external variable 
C                 1 => import, 2 => export
C      EVSP     -logical array (NEVAR x # stress periods) which records if a
C                  external variable is a candidate during a stress period
C
C-----VARIABLES FOR BINARY DECISION VARIABLES
      INTEGER(I4B),SAVE::NBVAR
      CHARACTER(LEN=10),SAVE,ALLOCATABLE::BVNAME(:)
      REAL(DP),SAVE,ALLOCATABLE::BVBASE(:)
      INTEGER(I4B),SAVE,ALLOCATABLE::BVNLIST(:),BVLIST(:,:)
C
C      NBVAR    -number of binary variables
C      BVNAME   -name of binary variable (10 digits)
C      BVBASE   -current value of binary variable during solution process 
C      BVNLIST  -number of variables associated with the binary variable
C      BVLIST(I,J)-index of the jth variable associated with the ith constraint
C
C-----ERROR HANDLING
      INTEGER(I2B)::ISTAT  
      CHARACTER(LEN=200)::FLNM
      CHARACTER(LEN=20)::FILACT,FMTARG,ACCARG 
      INTEGER(I4B)::NDUM
      REAL(SP)::RDUM
C
      CONTAINS 
C*************************************************************************
      SUBROUTINE GWM1DCV1AR(FNAME,IOUT,NROW,NCOL,NLAY,NPER,
     &                      NFVAR,NEVAR,NBVAR,NDV)
C*************************************************************************
C     VERSION: 14AUG2006
C     PURPOSE: READ INPUT FROM THE DECISION-VARIABLE FILE 
C---------------------------------------------------------------------------
      USE GWM1BAS1, ONLY : ONE,ZERO,GWMWFILE,GWM1BAS1PS
      INTEGER(I4B),INTENT(IN)::IOUT,NROW,NCOL,NLAY,NPER
      INTEGER(I4B),INTENT(OUT)::NFVAR,NEVAR,NBVAR,NDV
      INTERFACE 
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
C
        SUBROUTINE USTOP(STOPMESS)
        CHARACTER STOPMESS*(*)
        END
      END INTERFACE
C-----LOCAL VARIABLES
      CHARACTER(LEN=10)::TFVNAME
      REAL(SP)::TRAT
      INTEGER(I4B)::I,II,J,JJ,IR,IC,IL,NPVMAX,BYTES
      INTEGER(I4B)::LLOC,INMS,INMF,INMVS,INMVF,N,TNPV
      INTEGER(I4B)::LOCAT,NUNOPN,ISTART,ISTOP,IPRN
      INTEGER(I4B)::NC
      INTEGER(I4B)::IPSS,IPSF,IPTS,IPTF,ITYPES,ITYPEF
      CHARACTER(LEN=1)::FTYPE,FSTAT
      CHARACTER(LEN=2)::ETYPE
      LOGICAL(LGT)::NFOUND
      CHARACTER(LEN=200)::FNAME,LINE
      DATA NUNOPN/99/
      INTEGER(I2B)::NCMAX
C-----ALLOCATE TEMPORARY STORAGE UNTIL SIZE CAN BE DETERMINED
      INTEGER(I4B),ALLOCATABLE::TBVLIST(:,:)
      CHARACTER(LEN=120),ALLOCATABLE::WSP(:),ESP(:)
C++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C
C1----OPEN FILE
      LOCAT=NUNOPN
      WRITE(IOUT,1000,ERR=990)LOCAT,FNAME
      OPEN(UNIT=LOCAT,FILE=FNAME,ACTION='READ',ERR=999)
C
C-----CHECK FOR COMMENT LINES
      CALL URDCOM(LOCAT,IOUT,LINE)
C
C-----READ IPRN
      LLOC=1
      CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,IPRN,RDUM,IOUT,LOCAT)
      IF(IPRN.NE.0 .AND. IPRN.NE.1)THEN
        WRITE(IOUT,2000,ERR=990)IPRN
        CALL USTOP(' ')
      ENDIF
C
C-----READ GWMWFILE IF PRESENT
      CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,GWMWFILE,RDUM,IOUT,LOCAT)
      IF(GWMWFILE.GT.0)WRITE(IOUT,2100,ERR=990)GWMWFILE
C
C-----READ NFVAR, NEVAR, AND NBVAR
      READ(LOCAT,'(A)',ERR=991)LINE
      LLOC=1
      CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,NFVAR,RDUM,IOUT,LOCAT)
      CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,NEVAR,RDUM,IOUT,LOCAT)
      CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,NBVAR,RDUM,IOUT,LOCAT)
      IF(NFVAR.LE.0)THEN
        CALL GWM1BAS1PS(' PROGRAM STOPPED: NFVAR MUST BE > 0',0)
        CALL USTOP(' ')
      ENDIF
      WRITE(IOUT,3000,ERR=990)NFVAR,NEVAR
      IF(NBVAR.GE.1)THEN
        WRITE(IOUT,3010,ERR=990)NBVAR
      ELSE
        WRITE(IOUT,3020,ERR=990)
      ENDIF
C
C-----DETERMINE NCMAX FOR ALLOCATION OF STORAGE SPACE
      IF(NFVAR.GT.0)THEN
        NCMAX = 0
        DO 100 J=1,NFVAR
          READ(LOCAT,'(A)',ERR=991,END=991)LINE
          LLOC=1
          CALL URWORD(LINE,LLOC,INMS,INMF,0,NDUM,RDUM,IOUT,LOCAT)
          CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,NC,RDUM,IOUT,LOCAT)
          IF(NC.GT.NCMAX)NCMAX=NC
          IF(NC.GT.1)THEN
            DO 110 JJ=1,NC                       ! LOOP OVER THE MULTIPLE CELLS
              READ(LOCAT,*,ERR=991)
  110       ENDDO
          ENDIF
  100   ENDDO
        REWIND(LOCAT)
        CALL URDCOM(LOCAT,0,LINE)                ! RE-READ COMMENTS AND IPRN
        READ(LOCAT,'(A)',ERR=991)LINE
C
C-------ALLOCATE SPACE FOR FLOW-RATE VARIABLE INFORMATION
        NDV = NFVAR+NEVAR+NBVAR+1                ! NUMBER OF DECISION VARIABLES
        ALLOCATE (FVNAME(NFVAR),FVMIN(NFVAR),FVMAX(NFVAR),FVBASE(NFVAR),
     &            FVINI(NFVAR),FVNCELL(NFVAR),FVON(NFVAR),FVDIR(NFVAR),
     &            FVSP(NFVAR,NPER),STAT=ISTAT) 
        IF(ISTAT.NE.0)GOTO 992 
        BYTES = 10*NFVAR + 8*4*NFVAR + 4*3*NFVAR + (NFVAR*NPER)/8
        ALLOCATE (FVILOC(NFVAR,NCMAX),FVJLOC(NFVAR,NCMAX),
     &            FVKLOC(NFVAR,NCMAX),FVRATIO(NFVAR,NCMAX),STAT=ISTAT)
        IF(ISTAT.NE.0)GOTO 992 
        BYTES = BYTES + 4*3*(NFVAR*NCMAX) + 4*NFVAR*NCMAX
        ALLOCATE (WSP(NFVAR),STAT=ISTAT)         ! TEMPORARY ARRAY FOR OUTPUT
        IF(ISTAT.NE.0)GOTO 992 
C
C-----READ FLOW-RATE VARIABLE INFORMATION 
        DO 200 J=1,NFVAR
          READ(LOCAT,'(A)',ERR=991)LINE
          LLOC=1
          CALL URWORD(LINE,LLOC,INMS,INMF,0,NDUM,RDUM,IOUT,LOCAT)
          CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,NC,RDUM,IOUT,LOCAT)
          CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,IL,RDUM,IOUT,LOCAT)
          CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,IR,RDUM,IOUT,LOCAT)
          CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,IC,RDUM,IOUT,LOCAT)
          CALL URWORD(LINE,LLOC,IPTS,IPTF,0,NDUM,RDUM,IOUT,LOCAT)
          CALL URWORD(LINE,LLOC,IPSS,IPSF,0,NDUM,RDUM,IOUT,LOCAT)
          CALL URWORD(LINE,LLOC,ITYPES,ITYPEF,0,NDUM,RDUM,IOUT,LOCAT)
C
C--------CHECK THAT DECISION-VARIABLE NAME HAS NOT BEEN USED
          DO 210 JJ=1,J-1
            IF(LINE(INMS:INMF).EQ.FVNAME(JJ))THEN
              WRITE(IOUT,4000,ERR=990)FVNAME(JJ)
              CALL USTOP(' ')
            ENDIF
  210     ENDDO
          FVNAME(J)=LINE(INMS:INMF)
C
C---------PROCESS NC, THE NUMBER OF CELLS FOR THIS VARIABLE
          IF(NC.LT.1)THEN
            WRITE(IOUT,4010,ERR=990)NC           ! VALUE OF NC IS INVALID
            CALL USTOP(' ')
          ENDIF
          FVNCELL(J)=NC                          ! STORE THE NUMBER OF CELLS
C
C---------PROCESS ROW, COLUMN, LAYER LOCATIONS FOR THIS VARIABLE
          IF(NC.EQ.1)THEN
            CALL LOADDV(1)                       ! TEST INPUT AND STORE LOCATION
            FVRATIO(J,1)=1.0                     ! ONLY ONE CELL
          ELSE                                   ! MULTIPLE CELLS
            TRAT=0.0
            DO 220 JJ=1,NC                       ! LOOP OVER THE MULTIPLE CELLS
              READ(LOCAT,*,ERR=991,END=991)FVRATIO(J,JJ),IL,IR,IC
              CALL LOADDV(JJ)                    ! TEST INPUT AND STORE LOCATION
              TRAT=FVRATIO(J,JJ)+TRAT
  220       ENDDO
            IF(REAL(TRAT,DP).NE.ONE)THEN         ! FRACTIONS DO NOT ADD TO ONE
              DO 230 JJ=1,NC
                FVRATIO(J,JJ)=FVRATIO(J,JJ)/TRAT ! NORMALIZE FRACTIONS
  230         ENDDO
            ENDIF
          ENDIF
C
C---------PROCESS FTYPE, THE FLOW-RATE VARIABLE DIRECTION 
          FTYPE=LINE(IPTS:IPTF)
          IF(FTYPE.EQ.'i'.OR.FTYPE.EQ.'I')THEN
            FVDIR(J)=1
          ELSEIF(FTYPE.EQ.'w'.OR.FTYPE.EQ.'W')THEN
            FVDIR(J)=2
          ELSE
            WRITE(IOUT,4020,ERR=990)FTYPE        ! VALUE OF FTYPE IS INVALID 
            CALL USTOP(' ')
          ENDIF
C
C---------PROCESS FSTAT, THE FLAG TO INDICATE FLOW-RATE VARIABLE IS ACTIVE
          FSTAT=LINE(IPSS:IPSF)
          IF(FSTAT.EQ.'y'.OR.FSTAT.EQ.'Y')THEN
		  FVON(J) = 1
          ELSEIF(FSTAT.EQ.'n'.OR.FSTAT.EQ.'N')THEN
            FVON(J) = -1
          ELSE
            WRITE(IOUT,4030,ERR=990)FSTAT        ! VALUE OF FSTAT IS INVALID
            CALL USTOP(' ')
          ENDIF
C
C---------ASSIGN WELLSP TO IDENTIFY STRESS PERIODS VARIABLE IS ACTIVE
          WSP(J)=LINE(ITYPES:ITYPEF)
          CALL SPARRAY(WSP(J),FVSP,NFVAR,NPER,J)
  200   ENDDO
      ENDIF
C
C----READ EXTERNAL VARIABLES INFORMATION
      IF(NEVAR.GE.1)THEN
C
C-------ALLOCATE SPACE FOR EXTERNAL VARIABLES
        ALLOCATE (EVNAME(NEVAR),EVMAX(NEVAR),EVMIN(NEVAR),EVBASE(NEVAR),
     &            EVDIR(NEVAR),EVSP(NEVAR,NPER),STAT=ISTAT)
        IF(ISTAT.NE.0)GOTO 992 
        BYTES = BYTES + 10*NEVAR + 8*3*NEVAR + 4*NEVAR 
        ALLOCATE (ESP(NEVAR),STAT=ISTAT)         ! ESP IS TEMPORARY STORAGE
        IF(ISTAT.NE.0)GOTO 992 
        DO 300 J=1,NEVAR
          READ(LOCAT,'(A)',ERR=991)LINE
          LLOC=1
          CALL URWORD(LINE,LLOC,INMS,INMF,0,NDUM,RDUM,IOUT,LOCAT)
          CALL URWORD(LINE,LLOC,IPTS,IPTF,0,NDUM,RDUM,IOUT,LOCAT)
          CALL URWORD(LINE,LLOC,ITYPES,ITYPEF,0,NDUM,RDUM,IOUT,LOCAT)
C
C---------CHECK THAT EXTERNAL-VARIABLE NAME HAS NOT BEEN USED
          DO 310 JJ=1,J-1
            IF(LINE(INMS:INMF).EQ.EVNAME(JJ))THEN
              WRITE(IOUT,5000,ERR=990)EVNAME(JJ)
              CALL USTOP(' ')
            ENDIF
  310     ENDDO
          EVNAME(J)=LINE(INMS:INMF)
C
C---------PROCESS ETYPE, THE EXTERNAL VARIABLE DIRECTION 
          ETYPE=LINE(IPTS:IPTF)
          IF(ETYPE.EQ.'im'.OR.ETYPE.EQ.'IM')THEN
            EVDIR(J)=1
          ELSEIF(ETYPE.EQ.'EX'.OR.ETYPE.EQ.'ex')THEN
            EVDIR(J)=2
          ELSE
            WRITE(IOUT,4020,ERR=990)ETYPE        ! VALUE OF ETYPE IS INVALID 
            CALL USTOP(' ')
          ENDIF
C
C---------ASSIGN EVSP TO IDENTIFY STRESS PERIODS VARIABLE IS ACTIVE
          ESP(J)=LINE(ITYPES:ITYPEF)
          CALL SPARRAY(ESP(J),EVSP,NEVAR,NPER,J)
  300   ENDDO
      ENDIF
C
C----READ IN BINARY VARIABLE INFORMATION
      IF(NBVAR.GE.1)THEN
C
C-------ALLOCATE SPACE FOR BINARY VARIABLES
        ALLOCATE (BVNAME(NBVAR),BVBASE(NBVAR),BVNLIST(NBVAR),STAT=ISTAT)
        IF(ISTAT.NE.0)GOTO 992 
        BYTES = BYTES + 10*NBVAR + 8*NBVAR + 4*NBVAR 
        ALLOCATE (TBVLIST(NBVAR,NFVAR+NEVAR),STAT=ISTAT) ! TBVLIST IS TEMPORARY STORAGE
        IF(ISTAT.NE.0)GOTO 992 
        NPVMAX = 0
        DO 450 J=1,NBVAR
          READ(LOCAT,'(A)',ERR=991)LINE
          LLOC=1
          CALL URWORD(LINE,LLOC,INMS,INMF,0,NDUM,RDUM,IOUT,LOCAT)
          CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,TNPV,RDUM,IOUT,LOCAT)
C
C---------CHECK THAT BINARY-VARIABLE NAME HAS NOT BEEN USED
          DO 410 JJ=1,J-1
            IF(LINE(INMS:INMF).EQ.BVNAME(JJ))THEN
              WRITE(IOUT,6000,ERR=990)BVNAME(JJ)
              CALL USTOP(' ')
            ENDIF
  410     ENDDO
          BVNAME(J)=LINE(INMS:INMF)              ! STORE THE VARIABLE NAME
C
C---------PROCESS THE NUMBER OF VARIABLES ASSOCIATED WITH THE BINARY
          IF(TNPV.LT.1 .OR. TNPV.GT.NFVAR+NEVAR)THEN
            WRITE(IOUT,6010,ERR=990)BVNAME(J)
            CALL USTOP(' ')
          ENDIF
          BVNLIST(J)=TNPV                        ! STORE THE NUMBER OF VARIABLES
          NPVMAX = MAX(NPVMAX,TNPV)              ! FIND THE MAXIMUM NUMBER 
C
C---------READ DECISION VARIABLES ASSOCIATED WITH BINARY VARIABLE
          DO 440 JJ=1,TNPV
            CALL URWORD(LINE,LLOC,INMVS,INMVF,0,NDUM,RDUM,IOUT,LOCAT)
C
C-----------PROCESS THE ASSOCIATED VARIABLE
            TFVNAME=LINE(INMVS:INMVF)
            NFOUND=.TRUE.
            DO 420 I=1,NFVAR
              IF(FVNAME(I).EQ.TFVNAME)THEN
                TBVLIST(J,JJ)=I                  ! STORE THE VARIABLE NUMBER
                NFOUND=.FALSE.
                EXIT
              ENDIF
  420       ENDDO
            DO 430 I=1,NEVAR
              IF(EVNAME(I).EQ.TFVNAME)THEN
                TBVLIST(J,JJ)=NFVAR+I            ! STORE THE VARIABLE NUMBER
                NFOUND=.FALSE.
                EXIT
              ENDIF
  430       ENDDO
            IF(NFOUND)THEN
              WRITE(IOUT,6020,ERR=990)TFVNAME
              CALL USTOP(' ')
            ENDIF
  440     ENDDO
  450   ENDDO
C
C-------MOVE TEMPORARY BVLIST INTO PERMANENT STORAGE
        ALLOCATE (BVLIST(NBVAR,NPVMAX),STAT=ISTAT)
        IF(ISTAT.NE.0)GOTO 992
        BYTES = BYTES + 4*NBVAR*NPVMAX
        DO 510 J=1,NBVAR
          DO 500 JJ=1,BVNLIST(J)
            BVLIST(J,JJ) = TBVLIST(J,JJ)
  500     ENDDO
  510   ENDDO
        DEALLOCATE (TBVLIST,STAT=ISTAT)
        IF(ISTAT.NE.0)GOTO 993
      ENDIF
C
C-----WRITE INFORMATION TO OUTPUT FILE
      IF(IPRN.EQ.1)THEN
        IF(NFVAR.GT.0)THEN                       ! WRITE PUMPING-VARIABLE INFO
          WRITE(IOUT,7000,ERR=990)
          DO 610 J=1,NFVAR
            DO 600 JJ=1,FVNCELL(J)
              IF(FVDIR(J).EQ.1)THEN
                IF(JJ.EQ.1)THEN
                  WRITE(IOUT,7010,ERR=990)J,FVNAME(J),'INJECTION',
     1                 FVKLOC(J,1),FVILOC(J,1),FVJLOC(J,1),FVRATIO(J,JJ)
                ELSE
                  WRITE(IOUT,7020,ERR=990)FVKLOC(J,JJ),FVILOC(J,JJ),
     1                            FVJLOC(J,JJ),FVRATIO(J,JJ)
                ENDIF
              ELSEIF(FVDIR(J).EQ.2)THEN
                IF(JJ.EQ.1)THEN
                  WRITE(IOUT,7010,ERR=990)J,FVNAME(J),'WITHDRAWAL',
     1                 FVKLOC(J,1),FVILOC(J,1),FVJLOC(J,1),FVRATIO(J,JJ)
                ELSE
                  WRITE(IOUT,7020,ERR=990)FVKLOC(J,JJ),FVILOC(J,JJ),
     1                          FVJLOC(J,JJ),FVRATIO(J,JJ)
                ENDIF
              ENDIF
  600       ENDDO
            IF(FVON(J).GT.0)THEN
              WRITE(IOUT,7030,ERR=990)WSP(J)
            ELSE
              WRITE(IOUT,7040,ERR=990)
            ENDIF
  610     ENDDO
        ENDIF
C
        IF(NEVAR.GE.1)THEN                       ! WRITE EXTERNAL-VARIABLE INFO
          WRITE(IOUT,7050,ERR=990)
          DO 700 J=1,NEVAR
            WRITE(IOUT,7060,ERR=990)J,EVNAME(J),ESP(J)
  700     ENDDO
        ENDIF
C
        IF(NBVAR.GE.1)THEN                       ! WRITE BINARY-VARIABLE INFO
          WRITE(IOUT,7070,ERR=990)
          DO 800 I=1,NBVAR
            TNPV=BVNLIST(I)
            IF(BVLIST(I,1).LE.NFVAR)THEN
              TFVNAME=FVNAME(BVLIST(I,1))
            ELSE
              TFVNAME=EVNAME(BVLIST(I,1))
            ENDIF
            WRITE(IOUT,7080,ERR=990)I,BVNAME(I),TNPV,TFVNAME
            DO 810 II=2,TNPV
              IF(BVLIST(I,II).LE.NFVAR)THEN
                TFVNAME=FVNAME(BVLIST(I,II))
              ELSE
                TFVNAME=EVNAME(BVLIST(I,II))
              ENDIF
              WRITE(IOUT,7090,ERR=990)TFVNAME
  810       ENDDO
  800     ENDDO
        ENDIF
      ENDIF
C 
C----CLOSE FILE
      CLOSE(UNIT=LOCAT)
      WRITE(IOUT,7100,ERR=990)BYTES
      WRITE(IOUT,7110,ERR=990)
C
C-----DEALLOCATE LOCAL ALLOCATABLE ARRAYS
      IF(ALLOCATED(WSP))THEN
        DEALLOCATE(WSP,STAT=ISTAT)
        IF(ISTAT.NE.0)GOTO 993
      ENDIF
      IF(ALLOCATED(ESP))THEN
        DEALLOCATE(ESP,STAT=ISTAT)
        IF(ISTAT.NE.0)GOTO 993
      ENDIF
C
 1000 FORMAT(1X,/1X,'OPENING DECISION-VARIABLE FILE ON UNIT ',I4,':',
     1  /1X,A200)
 2000 FORMAT(1X,/1X,'PROGRAM STOPPED. IPRN MUST BE EQUAL TO 0 OR 1: ',
     1  I4)
 2100 FORMAT(1X,/1X,'OPTIMAL FLOW VARIABLE VALUES WILL BE WRITTEN ',
     1  'TO UNIT NUMBER:',I4)
 3000 FORMAT(1X,/1X,'NO. OF FLOW-RATE DECISION VARIABLES (NFVAR):',
     1  T45,I8,/1X,'NO. OF EXTERNAL DECISION VARIABLES (NEVAR):',
     2  T45,I8)
 3010 FORMAT(1X,'BINARY VARIABLES ARE ACTIVE. NBVAR:',T45,I8)
 3020 FORMAT(1X,'BINARY VARIABLES ARE NOT ACTIVE.')
 4000 FORMAT(1X,/1X,'PROGRAM STOPPED. DECISION-VARIABLE NAME ',A,
     1  ' HAS ALREADY BEEN USED.') 
 4010 FORMAT(1X,/1X,'PROGRAM STOPPED. FVNCELL MUST BE GREATER THAN OR',
     1  ' EQUAL TO 1, BUT IS: ',I5)
 4020 FORMAT(1X,/1X,'PROGRAM STOPPED. FTYPE MUST BE W OR I, BUT IS: ',
     1  A)
 4030 FORMAT(1X,/1X,'PROGRAM STOPPED. FSTAT MUST BE Y OR N, BUT IS: ',
     1  A)
 5000 FORMAT(1X,/1X,'PROGRAM STOPPED. EXTERNAL-VARIABLE NAME ',A,
     1  ' HAS ALREADY BEEN USED.')
 6000 FORMAT(1X,/1X,'PROGRAM STOPPED. BINARY-VARIABLE NAME ',A,
     1  ' HAS ALREADY BEEN USED.')
 6010 FORMAT(1X,/1X,'PROGRAM STOPPED. NUMBER OF DECISION VARIABLES',
     1  ' ASSOCIATED WITH BINARY VARIABLE ',A,' IS NOT VALID.')
 6020 FORMAT(1X,/1X,'PROGRAM STOPPED.',A,' WAS NOT DEFINED AS A', 
     1  ' VARIABLE NAME (FVNAME)')
 7000 FORMAT(/,T2,'FLOW-RATE VARIABLES:',/,T52,'FRACTION',/,
     1  T3,'NUMBER',T14,'NAME',T25,'TYPE',T35,'LAY',T41,'ROW',
     2  T47,'COL',T53,'OF FLOW',/,1X,'----------------------',
     3  '------------------------------------')
 7010 FORMAT(I5,6X,A10,1X,A10,1X,3I5,4X,F6.4)
 7020 FORMAT(T34,3I5,4X,F6.4)
 7030 FORMAT('   AVAILABLE IN STRESS PERIODS: ',A120,/)
 7040 FORMAT('   UNAVAILABLE IN ALL STRESS PERIODS',/)
 7050 FORMAT(/,T2,'EXTERNAL VARIABLES:',/,/,T3,'NUMBER',T14,'NAME',
     1  /,1X'------------------------------')
 7060 FORMAT(/,I5,8X,A10,/,'   AVAILABLE IN STRESS PERIODS: ',A120)
 7070 FORMAT(/,T2,'BINARY VARIABLES:',/,T24,'NUMBER OF',T46,
     1  'NAME OF',/,T3,'NUMBER',T14,'NAME',T20,
     2  'ASSOCIATED VARIABLES',T42,'ASSOCIATED VARIABLES',/,
     3  1X'-------------------------------------------------------',/)
 7080 FORMAT(I5,8X,A10,T25,I5,T46,A)
 7090 FORMAT(T46,A)
 7100 FORMAT(/,1X,I8,' BYTES OF MEMORY ALLOCATED TO STORE DATA FOR',
     1               ' DECISION VARIABLES')
 7110 FORMAT(/,1X,'CLOSING DECISION-VARIABLE FILE',/)
C
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
     &2X,'-- STOP EXECUTION (GWM1DCV1AR)')
      CALL USTOP(' ')
C
  991 CONTINUE
C-----FILE-READING ERROR
      INQUIRE(LOCAT,NAME=FLNM,FORM=FMTARG,ACCESS=ACCARG,ACTION=FILACT)
      WRITE(*,9910)TRIM(FLNM),LOCAT,FMTARG,ACCARG,FILACT
      WRITE(IOUT,9910)TRIM(FLNM),LOCAT,FMTARG,ACCARG,FILACT
 9910 FORMAT(/,1X,'*** ERROR READING FILE "',A,'" ON UNIT ',I5,/,
     &7X,'SPECIFIED FILE FORMAT: ',A,/
     &7X,'SPECIFIED FILE ACCESS: ',A,/
     &7X,'SPECIFIED FILE ACTION: ',A,/
     &2X,'-- STOP EXECUTION (GWM1DCV1AR)')
      CALL USTOP(' ')
C
  992 CONTINUE
C-----ARRAY-ALLOCATING ERROR
      WRITE(*,9920)
 9920 FORMAT(/,1X,'*** ERROR ALLOCATING ARRAY(S)',
     &2X,'-- STOP EXECUTION (GWM1DCV1AR)')
      CALL USTOP(' ')
C
  993 CONTINUE
C-----ARRAY-DEALLOCATING ERROR
      WRITE(*,9930)
 9930 FORMAT(/,1X,'*** ERROR DEALLOCATING ARRAY(S)',
     &2X,'-- STOP EXECUTION (GWM1DCV1AR)')
      CALL USTOP(' ')
C
  999 CONTINUE
C-----FILE-OPENING ERROR
      INQUIRE(LOCAT,NAME=FLNM,FORM=FMTARG,ACCESS=ACCARG,ACTION=FILACT)
      WRITE(*,9990)TRIM(FLNM),LOCAT,'OLD',FMTARG,ACCARG,FILACT
      WRITE(IOUT,9990)TRIM(FLNM),LOCAT,'OLD',FMTARG,ACCARG,
     &                 FILACT
 9990 FORMAT(/,1X,'*** ERROR OPENING FILE "',A,'" ON UNIT ',I5,/,
     &7X,'SPECIFIED FILE STATUS: ',A,/
     &7X,'SPECIFIED FILE FORMAT: ',A,/
     &7X,'SPECIFIED FILE ACCESS: ',A,/
     &7X,'SPECIFIED FILE ACTION: ',A,/
     &2X,'-- STOP EXECUTION (GWM1DCV1AR)')
      CALL USTOP(' ')
C
      CONTAINS
C***********************************************************************
      SUBROUTINE LOADDV(JJ)
C***********************************************************************
      INTEGER(I4B)::JJ
C+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C
C-----CHECK THAT CELL IS ON GRID      
      IF(IR.LT.1 .OR. IR.GT.NROW)THEN
        WRITE(IOUT,1000,ERR=990)IR
        CALL USTOP(' ')
      ENDIF
      IF(IC.LT.1 .OR. IC.GT.NCOL)THEN
        WRITE(IOUT,2000,ERR=990)IC
        CALL USTOP(' ')
      ENDIF
      IF(IL.LT.1 .OR. IL.GT.NLAY)THEN
        WRITE(IOUT,3000,ERR=990)IL
        CALL USTOP(' ')
      ENDIF
C
C-----LOAD VARIABLES 
      FVILOC(J,JJ)=IR                   
      FVJLOC(J,JJ)=IC
      FVKLOC(J,JJ)=IL
C
 1000 FORMAT(1X,/1X,'PROGRAM STOPPED. ROW NUMBER FOR WELL IS OUT OF',
     1  ' BOUNDS: ',I5)
 2000 FORMAT(1X,/1X,'PROGRAM STOPPED. COLUMN NUMBER FOR WELL IS OUT',
     1  ' OF BOUNDS: ',I5)
 3000 FORMAT(1X,/1X,'PROGRAM STOPPED. LAYER NUMBER FOR WELL IS OUT',
     1  ' OF BOUNDS: ',I5)
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
     &2X,'-- STOP EXECUTION (LOADDV)')
      CALL USTOP(' ')
C
      END SUBROUTINE LOADDV
C
C***********************************************************************
      SUBROUTINE SPARRAY(SPSTRNG,SARRAY,NV,NPER,J)
C***********************************************************************
C
C  PURPOSE - CONVERT CHARACTER STRING, SPSTRNG TO LOGICAL ARRAY, SARRAY
C-----------------------------------------------------------------------
      CHARACTER(LEN=120),INTENT(IN)::SPSTRNG
      INTEGER(I4B),INTENT(IN)::NV,NPER,J
      LOGICAL(LGT),INTENT(OUT)::SARRAY(NV,NPER)
C-----LOCAL VARIABLES
      INTEGER(I4B)::IP,IFLG,IN,IT,NUM,NUMOLD,K
C+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C
      DO 50 K=1,NPER
        SARRAY(J,K) = .FALSE.
   50 ENDDO
      IP = 0
      IFLG = 0
C
C-----SET POINTERS TO ELEMENTS OF THE STRESS PERIOD CHARACTER STRING
  100 IP = IP + 1
      IN=IP
C
C-----FIND NEXT PUNCTUATION MARK IN THE STRESS PERIOD STRING
      CALL CHREAD(SPSTRNG,IP,IN,IT,NUM)
      IF(NUM.LT.1 .OR. NUM.GT.NPER)THEN
        CALL USTOP('PROGRAM STOPPED: INVALID STRESS PERIOD NUMBER')
      ENDIF
C
C-----PROCESS THE PUNCTUATION MARK AND MOST RECENT NUMBER
      IF(IFLG.EQ.1) THEN                         ! PRIOR MARK WAS A DASH 
        DO 200 K=NUMOLD,NUM                      ! FOR ALL VARIABLES IN SEQUENCE
          SARRAY(J,K)=.TRUE.                     ! SET VARIABLE AS ACTIVE
  200   ENDDO
        IFLG = 0
      ENDIF
      IF(IT.EQ.1) THEN                           ! PUNCTUATION IS A DASH
        IFLG = 1                                 ! SET FLAG FOR DASH
        NUMOLD = NUM                             ! SAVE FIRST NUMBER IN SEQUENCE
      ELSEIF(IT.EQ.2) THEN                       ! PUNCTUATION IS A COLON
        SARRAY(J,NUM)=.TRUE.                     ! SET VARIABLE AS ACTIVE
      ELSEIF(IT.EQ.3) THEN                       ! PUNCTUATION IS A BLANK
        SARRAY(J,NUM)=.TRUE.                     ! SET VARIABLE AS ACTIVE
      ENDIF

      IF(IT.NE.3)GOTO 100                        ! CURRENT CHARACTER NOT A BLANK
C
      RETURN
      END SUBROUTINE SPARRAY
C
C***********************************************************************
      SUBROUTINE CHREAD(WSP,IP,IN,IT,NUM)
C***********************************************************************
C
C  PURPOSE - RETURN THE NEXT PUNCTUATION MARK AND THE PREVIOUS NUMERAL
C           VALUE IN A CHARACTER STRING OF STRESS PERIODS
C
C    INPUT:
C      WSP     CHARACTER STRING WITH LIST OF STRESS PERIODS
C      IP, IN  LOCATION OF FIRST DIGIT IN NEXT NUMERAL
C    OUTPUT:
C      IP      LOCATION OF NEXT PUNCTUATION MARK
C      IT      INTEGER WHICH INDICATES VALUE OF NEXT PUNCTUATION MARK
C      NUM     VALUE OF NEXT NUMERAL
C-----------------------------------------------------------------------
      CHARACTER(LEN=120),INTENT(IN)::WSP
      INTEGER(I4B),INTENT(INOUT)::IP
      INTEGER(I4B),INTENT(IN)::IN
      INTEGER(I4B),INTENT(OUT)::IT,NUM
      CHARACTER(LEN=1)::CT
      INTEGER(I4B)::II
C+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C
C-----FIND NEXT PUNCTUATION MARK
  100 IF(WSP(IP:IP).EQ.'-') THEN
        IT = 1                                   ! MARK IS A DASH
      ELSEIF(WSP(IP:IP).EQ.':') THEN
        IT = 2                                   ! MARK IS A COLON
      ELSEIF(IP.EQ.INDEX(WSP,' ')) THEN
        IT = 3                                   ! MARK IS A SPACE
      ELSE
        IP = IP + 1
        GOTO 100
      ENDIF
C
C--- EVALUATE CURRENT NUMERAL
      NUM=0
      DO 200 II=IN,IP-1
        CT = WSP(II:II)
        IF(.NOT. (CT.EQ.'0' .OR. CT.EQ.'1' .OR. CT.EQ.'2' .OR.
     &     CT.EQ.'3' .OR. CT.EQ.'4' .OR. CT.EQ.'5' .OR. CT.EQ.'6'
     &     .OR. CT.EQ.'7' .OR.  CT.EQ.'8' .OR. CT.EQ.'9'))
     &  CALL USTOP('STRESS PERIOD STRING CONTAINS NON-DIGIT')
        NUM = NUM + (ICHAR(CT)-48)*10**(IP-1-II)
  200 ENDDO
C
      RETURN
      END SUBROUTINE CHREAD

      END SUBROUTINE GWM1DCV1AR
C
C
C***********************************************************************
      SUBROUTINE GWM1DCV1FM
C***********************************************************************
C     VERSION: 20FEB2005
C     PURPOSE: FORMULATE THE BOUNDS ON DECISION VARIABLES
C-----------------------------------------------------------------------
      USE GWM1BAS1, ONLY : ONE,SMALLEPS
      USE GWM1RMS1, ONLY : BNDS
C-----LOCAL VARIABLES
      INTEGER(I4B)::I
C+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C
      DO 100 I=1,NFVAR
        IF(FVON(I).GT.0)THEN
          BNDS(I) = FVMAX(I)                     ! LOAD FLOW VARIABLE BOUNDS 
        ELSEIF(FVON(I).LT.0)THEN
          BNDS(I) = SQRT(SMALLEPS)              ! MAKE VARIABLE UNAVAILABLE 
        ENDIF
  100 ENDDO
      DO 200 I=1,NEVAR
        BNDS(NFVAR+I) = EVMAX(I)                   ! LOAD EXTERNAL VARIABLE BOUNDS 
  200 ENDDO
      DO 300 I=NFVAR+NEVAR+1,NFVAR+NEVAR+NBVAR
        BNDS(I) = ONE                            ! LOAD BINARY VARIABLE BOUNDS
  300 ENDDO
C
      RETURN
      END SUBROUTINE GWM1DCV1FM
C
C
C***********************************************************************
      SUBROUTINE GWF1DCV1FM(RHS,IBOUND,NCOL,NROW,NLAY,KPER)
C***********************************************************************
C     VERSION: 20FEB2005
C     PURPOSE: FORMULATE THE MANAGED FLOW VARIABLES INTO THE SIMULATION RHS
C-----------------------------------------------------------------------
      INTEGER(I4B),INTENT(IN)::NCOL,NROW,NLAY,KPER
      REAL(SP),INTENT(INOUT)::RHS(NCOL,NROW,NLAY)
      INTEGER(I4B),INTENT(IN)::IBOUND(NCOL,NROW,NLAY)
C-----LOCAL VARIABLES
      INTEGER(I4B)::I,K,IL,IR,IC
      REAL(SP)::Q 
C+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C
      DO 100 I=1,NFVAR                      ! LOOP OVER GWM FLOW VARIABLES
        IF(FVSP(I,KPER)) THEN               ! FLOW VARIABLE ACTIVE IN STRESS PERIOD
          DO 110 K=1,FVNCELL(I)             ! LOOP OVER CELLS FOR THIS VARIABLE
            IL = FVKLOC(I,K)                ! ASSIGN CELL LAYER
            IR = FVILOC(I,K)                ! ASSIGN CELL ROW
            IC = FVJLOC(I,K)                ! ASSIGN CELL COLUMN
            Q  = REAL(FVBASE(I),KIND=4)*FVRATIO(I,K)! ASSIGN FLOW RATE 
            IF(IBOUND(IC,IR,IL).GT.0)THEN   ! CELL IS ACTIVE 
              RHS(IC,IR,IL)=RHS(IC,IR,IL)-Q ! SUBTRACT FROM THE RHS ACCUMULATOR
            ENDIF
  110     ENDDO
        ENDIF
  100 ENDDO
C
      RETURN
      END SUBROUTINE GWF1DCV1FM
C
C***********************************************************************
      SUBROUTINE GWF1DCV1BD(VBNM,VBVL,MSUM,IBOUND,
     1        DELT,NCOL,NROW,NLAY,KSTP,KPER,IWELCB,ICBCFL,BUFF,IOUT,
     2        PERTIM,TOTIM)
C***********************************************************************
C     VERSION: 20FEB2005
C     PURPOSE: CALCULATE VOLUMETRIC BUDGET FOR THE MANAGED FLOW VARIABLES 
C-----------------------------------------------------------------------
      USE GWM1BAS1, ONLY: ZERO 
      INTEGER(I4B),INTENT(INOUT)::MSUM
      CHARACTER(LEN=16),INTENT(OUT)::VBNM(MSUM)
      REAL(SP),INTENT(INOUT)::VBVL(4,MSUM)
      INTEGER(I4B),INTENT(IN)::NCOL,NROW,NLAY,KSTP,KPER,IWELCB,
     &                         ICBCFL,IOUT
      INTEGER(I4B),INTENT(IN)::IBOUND(NCOL,NROW,NLAY)
      REAL(SP),INTENT(OUT)::BUFF(NCOL,NROW,NLAY)
      REAL(SP),INTENT(IN)::DELT
      REAL(SP),INTENT(IN)::PERTIM,TOTIM     
C-----LOCAL VARIABLES
      INTEGER(I4B)::I,K,IL,IR,IC,IBD
      REAL(SP)::Q 
      REAL(DP)::RATIN,RATOUT,QQ,RIN,ROUT 
      CHARACTER(LEN=16)::TEXT='    MANAGED FLOW' 
C+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C
CGWM TO AVOID EXCESSIVE OUTPUT CELL-BY-CELL WRITING NOT IMPLEMENTED
C1------CLEAR RATIN AND RATOUT ACCUMULATORS, AND SET CELL-BY-CELL
C1------BUDGET FLAG.
      RATIN=ZERO
      RATOUT=ZERO
      IBD=0
      IF(IWELCB.LT.0 .AND. ICBCFL.NE.0) IBD=-1
      IF(IWELCB.GT.0) IBD=ICBCFL
C      IBDLBL=0
C
C2-----IF CELL-BY-CELL FLOWS WILL BE SAVED AS A LIST, WRITE HEADER.
C      IF(IBD.EQ.2) CALL UBDSV2(KSTP,KPER,TEXT,IWELCB,NCOL,NROW,NLAY,
C     1          NWELLS,IOUT,DELT,PERTIM,TOTIM,IBOUND)
C
C3------CLEAR THE BUFFER.
   50 BUFF=ZERO
C
C4------IF THERE ARE NO WELLS, DO NOT ACCUMULATE FLOW.
      IF(NFVAR.EQ.0)GOTO 200
C
C5------LOOP THROUGH EACH WELL CALCULATING FLOW.
      DO 100 I=1,NFVAR                      ! LOOP OVER GWM FLOW VARIABLES
        IF(FVSP(I,KPER)) THEN               ! FLOW VARIABLE ACTIVE IN STRESS PERIOD
          DO 110 K=1,FVNCELL(I)             ! LOOP OVER CELLS FOR THIS VARIABLE
C
C5A-----GET LAYER, ROW & COLUMN OF CELL CONTAINING WELL.
            IL = FVKLOC(I,K)                ! ASSIGN CELL LAYER
            IR = FVILOC(I,K)                ! ASSIGN CELL ROW
            IC = FVJLOC(I,K)                ! ASSIGN CELL COLUMN
            Q=ZERO
C
C5B-----IF THE CELL IS NO-FLOW OR CONSTANT_HEAD, IGNORE IT.
            IF(IBOUND(IC,IR,IL).LE.0)GOTO 99
C
C5C-----GET FLOW RATE FROM WELL LIST.
            Q  = REAL(FVBASE(I),KIND=4)*FVRATIO(I,K)! ASSIGN FLOW RATE 
            QQ=Q
C
C5D-----PRINT FLOW RATE IF REQUESTED.
C      IF(IBD.LT.0) THEN
C         IF(IBDLBL.EQ.0) WRITE(IOUT,61) TEXT,KPER,KSTP
C   61    FORMAT(1X,/1X,A,'   PERIOD',I3,'   STEP',I3)
C         WRITE(IOUT,62) L,IL,IR,IC,Q
C   62    FORMAT(1X,'WELL',I4,'   LAYER',I3,'   ROW',I4,'   COL',I4,
C     1       '   RATE',1PG15.6)
C         IBDLBL=1
C      END IF
C
C5E-----ADD FLOW RATE TO BUFFER.
            BUFF(IC,IR,IL)=BUFF(IC,IR,IL)+Q
C
C5F-----SEE IF FLOW IS POSITIVE OR NEGATIVE.
            IF(Q) 90,99,80
C
C5G-----FLOW RATE IS POSITIVE (RECHARGE). ADD IT TO RATIN.
   80       RATIN=RATIN+QQ
            GOTO 99
C
C5H-----FLOW RATE IS NEGATIVE (DISCHARGE). ADD IT TO RATOUT.
   90       RATOUT=RATOUT-QQ
C
C5I-----IF CELL-BY-CELL FLOWS ARE BEING SAVED AS A LIST, WRITE FLOW.
C5I-----OR IF RETURNING THE FLOW IN THE WELL ARRAY, COPY FLOW TO WELL.
   99       CONTINUE
CGWM   IF(IBD.EQ.2) CALL UBDSVA(IWELCB,NCOL,NROW,IC,IR,IL,Q,IBOUND,NLAY)
  110     ENDDO
        ENDIF
  100 ENDDO
C
C6------IF CELL-BY-CELL FLOWS WILL BE SAVED AS A 3-D ARRAY,
C6------CALL UBUDSV TO SAVE THEM.
CGWM      IF(IBD.EQ.1) CALL UBUDSV(KSTP,KPER,TEXT,IWELCB,BUFF,NCOL,NROW,
CGWM     1                          NLAY,IOUT)
C
C7------MOVE RATES, VOLUMES & LABELS INTO ARRAYS FOR PRINTING.
  200 RIN=RATIN
      ROUT=RATOUT
      VBVL(3,MSUM)=RIN
      VBVL(4,MSUM)=ROUT
      VBVL(1,MSUM)=VBVL(1,MSUM)+RIN*DELT
      VBVL(2,MSUM)=VBVL(2,MSUM)+ROUT*DELT
      VBNM(MSUM)=TEXT
C
C8------INCREMENT BUDGET TERM COUNTER(MSUM).
      MSUM=MSUM+1
C
C9------RETURN
      RETURN
      END SUBROUTINE GWF1DCV1BD 
C
C                              
      END MODULE GWM1DCV1