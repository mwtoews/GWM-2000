      MODULE GWM1SMC1
C     VERSION: 20FEB2005
      IMPLICIT NONE
      PRIVATE
      PUBLIC::GWM1SMC1AR,GWM1SMC1FM,GWM1SMC1OT
C
      INTEGER, PARAMETER :: I4B = SELECTED_INT_KIND(9)
      INTEGER, PARAMETER :: I2B = SELECTED_INT_KIND(4)
      INTEGER, PARAMETER :: SP = KIND(1.0)
      INTEGER, PARAMETER :: DP = KIND(1.0D0)
      INTEGER, PARAMETER :: LGT = KIND(.TRUE.)
C
C-----VARIABLES FOR SUMMATION CONSTRAINTS
      CHARACTER(LEN=10),SAVE,ALLOCATABLE::SMCNAME(:)
      REAL(DP),SAVE,ALLOCATABLE::SMCRHS(:)
      REAL(SP),SAVE,ALLOCATABLE::SMCCOEF(:,:)
      INTEGER(I4B),SAVE,ALLOCATABLE::SMCNTERMS(:),SMCCLOC(:,:),SMCDIR(:)
      INTEGER(I4B),SAVE::SMCNUM
C
C      SMCNAME  -name of constraint 
C      SMCRHS   -value of the right hand side for this constraint 
C      SMCCOEF(I,J)-coefficient on jth variable in ith constraint
C      SMCNTERMS-number of terms in the ith summation constraint
C      SMCCLOC(I,J)-index of jth variable in ith constraint
C      SMCDIR   -flag to determine direction of inequality for this constraint
C                 1 => left hand side < right hand side
C                 2 => left hand side > right hand side
C      SMCNUM   -total number of summation constraints
C
C-----FOR ERROR HANDLING
      INTEGER(I2B)::ISTAT  
      CHARACTER(LEN=200)::FLNM
      CHARACTER(LEN=20)::FILACT,FMTARG,ACCARG 
      INTEGER(I4B)::NDUM
      REAL(SP)::RDUM
C
      CONTAINS
C***********************************************************************
      SUBROUTINE GWM1SMC1AR(FNAME,IOUT,NFVAR,NEVAR,NBVAR,NV,NCON)
C***********************************************************************
C   VERSION: 20FEB2005
C   PURPOSE: READ INPUT FROM THE GENERALIZED-SUMMATION CONSTRAINTS
C-----------------------------------------------------------------------
      USE GWM1BAS1, ONLY : ZERO
      USE GWM1DCV1, ONLY : FVNAME,EVNAME,BVNAME
      CHARACTER(LEN=200),INTENT(IN)::FNAME
      INTEGER(I4B),INTENT(IN)::IOUT,NFVAR,NEVAR,NBVAR
      INTEGER(I4B),INTENT(INOUT)::NV,NCON
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
      CHARACTER(LEN=10)::TFVNAME,TBALNM,TGVNM
      INTEGER(I4B)::NTERMS,I,II,J,JJ,ITYPES,ITYPEF,LOCAT,N,BYTES
      INTEGER(I4B)::NCAP,NPROW,J1,J2,NPLACES,LLOC,INMS,INMF,ISTART,ISTOP
      INTEGER(I4B)::IPRN
      INTEGER(I4B)::NBTMAX,NVAR
      REAL(SP)::TRHS,TCOEFF
      REAL(SP)::R
      CHARACTER(LEN=200)::LINE
      CHARACTER(LEN=2)::BTYPE
      LOGICAL(LGT)::NFOUND
      INTEGER(I4B)::NUNOPN=99
C-----ALLOCATE TEMPORARY STORAGE UNTIL SIZE CAN BE DETERMINED
      REAL(SP),ALLOCATABLE::TSMCCOEF(:,:)
      INTEGER(I4B),ALLOCATABLE::TSMCCLOC(:,:)
      CHARACTER(LEN=10),ALLOCATABLE::SMCCNM(:,:)
      CHARACTER(LEN=1),ALLOCATABLE::CSW(:,:)
C++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C
C1----OPEN FILE
      LOCAT=NUNOPN
      WRITE(IOUT,1000,ERR=990) LOCAT,FNAME
      OPEN(UNIT=LOCAT,FILE=FNAME,ACTION='READ',ERR=999)
C
C  CHECK FOR COMMENT LINES
      CALL URDCOM(LOCAT,IOUT,LINE)
C
C-----READ IPRN
      LLOC=1
      CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,IPRN,R,IOUT,LOCAT)
      IF(IPRN.NE.0 .AND. IPRN.NE.1)THEN
        WRITE(IOUT,2000,ERR=990)IPRN
        CALL USTOP(' ')
      ENDIF
C
C-----READ NUMBER OF SUMMATION CONSTRAINTS (SMCNUM)
      READ(LOCAT,*,ERR=991)SMCNUM
      WRITE(IOUT,3000,ERR=990)SMCNUM
      IF(SMCNUM.EQ.0)RETURN
      NCON = NCON + SMCNUM                       ! INCREMENT CONSTRAINT NUMBER
      NV   = NV   + SMCNUM                       ! ADD CONSTRAINT SLACKS TO NV
C
C-----ALLOCATE ARRAYS TO STORE SUMMATION CONSTRAINTS
      ALLOCATE (SMCNAME(SMCNUM),SMCNTERMS(SMCNUM),SMCDIR(SMCNUM),
     &          SMCRHS(SMCNUM),STAT=ISTAT)
      IF(ISTAT.NE.0)GOTO 992
      BYTES = 10*SMCNUM + 4*2*SMCNUM + 8*SMCNUM
C-----ALLOCATE TEMPORARY STORAGE UNTIL SIZE CAN BE DETERMINED
      NBTMAX = 0
      NVAR = NFVAR + NEVAR + NBVAR
      ALLOCATE (TSMCCLOC(SMCNUM,NVAR),TSMCCOEF(SMCNUM,NVAR),
C-----ALLOCATE LOCAL WORK ARRAYS FOR OUPUT
     &          SMCCNM(SMCNUM,NVAR),CSW(SMCNUM,NVAR),STAT=ISTAT)
      IF(ISTAT.NE.0)GOTO 992
C
C----READ MASS-BALANCE CONSTRAINTS
      DO 200 I=1,SMCNUM
        READ(LOCAT,'(A)',ERR=991)LINE
        LLOC=1
        CALL URWORD(LINE,LLOC,INMS,INMF,0,NDUM,RDUM,IOUT,LOCAT)
        CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,NTERMS,RDUM,IOUT,LOCAT)
        CALL URWORD(LINE,LLOC,ITYPES,ITYPEF,1,NDUM,RDUM,IOUT,LOCAT) 
        CALL URWORD(LINE,LLOC,ISTART,ISTOP,3,NDUM,TRHS,IOUT,LOCAT)
C
C-------PROCESS THE CONSTRAINT NAME
        TBALNM=LINE(INMS:INMF)
C-------CHECK THAT BALANCE NAME HAS NOT BEEN USED
        DO 110 II=1,I-1
          IF(SMCNAME(II).EQ.TBALNM)THEN
            WRITE(IOUT,4000,ERR=990)TBALNM
            CALL USTOP(' ')
          ENDIF
  110   CONTINUE
        SMCNAME(I)=TBALNM                        ! STORE THE CONSTRAINT NAME         
C
C-------PROCESS NTERMS, THE NUMBER OF TERMS IN THE CONSTRAINT
        IF(NTERMS.LT.1)THEN
          WRITE(IOUT,4010,ERR=990)NTERMS         ! NTERMS MUST BE GREATER THAN 1
          CALL USTOP(' ')
        ELSEIF(NTERMS.GT.NVAR)THEN
          WRITE(IOUT,4020,ERR=990)NVAR           ! NTERMS MUST BE LESS THAN MAX
          CALL USTOP(' ')
        ELSE
          NBTMAX = MAX(NBTMAX,NTERMS)
          SMCNTERMS(I)=NTERMS                    ! STORE THE NUMBER OF TERMS
        ENDIF
C
C-------PROCESS TYPE, THE TYPE OF CONSTRAINT RELATION
        BTYPE=LINE(ITYPES:ITYPEF)
        IF(BTYPE.EQ.'LE')THEN
          SMCDIR(I) =  1                         ! STORE THE INDEX FOR <=
        ELSEIF(BTYPE.EQ.'EQ')THEN
          SMCDIR(I) =  0                         ! STORE THE INDEX FOR  =
          NV = NV - 1                            ! DECREMENT NUMBER OF SLACKS
        ELSEIF(BTYPE.EQ.'GE')THEN
          SMCDIR(I) = -1                         ! STORE THE INDEX FOR >=
        ELSE                                     
          WRITE(IOUT,4030,ERR=990)BTYPE          ! NOT A VALID INPUT
          CALL USTOP(' ')
        ENDIF
C
C-------PROCESS RHS, THE CONSTRAINT RIGHT HAND SIDE
        SMCRHS(I)=REAL(TRHS,DP)                  ! STORE THE CONSTRAINT RHS
C
C-----READ EXPRESSIONS FOR LEFT-HAND SIDE OF EQUATION
        DO 170 JJ=1,SMCNTERMS(I)
          READ(LOCAT,'(A)',ERR=991)LINE
          LLOC=1
          CALL URWORD(LINE,LLOC,INMS,INMF,0,N,R,IOUT,LOCAT)
          CALL URWORD(LINE,LLOC,ISTART,ISTOP,3,N,TCOEFF,IOUT,LOCAT)
          TGVNM=LINE(INMS:INMF)
          DO 120 II=1,JJ-1                       ! CHECK ALL PRIOR COEFFICIENTS
            IF(TGVNM.EQ.SMCCNM(I,II))THEN        ! COEFFICIENT ALREADY INPUT
              WRITE(IOUT,4050,ERR=990)TGVNM,SMCNAME(I)
              CALL USTOP(' ')
            ENDIF
  120     ENDDO
          NFOUND=.TRUE.
C
C---------PROCESS GVNM AND COEFF, NAME OF VARIABLE AND COEFFICIENT
          DO 130 II=1,NFVAR
            IF(FVNAME(II).EQ.TGVNM)THEN
              SMCCNM(I,JJ)=FVNAME(II)            ! THIS IS A FLOW VARIABLE
              TSMCCLOC(I,JJ)=II                  ! STORE COLUMN FOR COEFFICIENT
              NFOUND=.FALSE.
              GOTO 160
            ENDIF
  130     ENDDO
          DO 140 II=1,NEVAR
            IF(EVNAME(II).EQ.TGVNM)THEN
              SMCCNM(I,JJ)=EVNAME(II)            ! THIS IS A EXTERNAL VARIABLE
              TSMCCLOC(I,JJ)=II+NFVAR            ! STORE COLUMN FOR COEFFICIENT
              NFOUND=.FALSE.
              GOTO 160
            ENDIF
  140     ENDDO
          DO 150 II=1,NBVAR                   
            IF(BVNAME(II).EQ.TGVNM)THEN
              SMCCNM(I,JJ)=BVNAME(II)            ! THIS IS A BINARY VARIABLE
              TSMCCLOC(I,JJ)=II+NFVAR+NEVAR      ! STORE COLUMN FOR COEFFICIENT
              NFOUND=.FALSE.
              GOTO 160
            ENDIF
  150     ENDDO
C
          IF(NFOUND)THEN
            WRITE(IOUT,5000,ERR=990)TGVNM
            CALL USTOP(' ')
          ENDIF
 
  160     TSMCCOEF(I,JJ)=TCOEFF                  ! STORE COEFFICIENT 
          IF(REAL(TSMCCOEF(I,JJ),DP).LT.ZERO)THEN
            CSW(I,JJ)=CHAR(45)                   ! LOAD LOCAL OUTPUT STORAGE
          ELSE
            CSW(I,JJ)=CHAR(43)
          ENDIF
  170   ENDDO
C
  200 CONTINUE
C
C-----MOVE TEMPORARY STORAGE INTO PERMANENT LOCATIONS
      ALLOCATE (SMCCLOC(SMCNUM,NBTMAX),SMCCOEF(SMCNUM,NBTMAX),
     &          STAT=ISTAT)
      IF(ISTAT.NE.0)GOTO 992 
      BYTES = BYTES +  4*SMCNUM*NBTMAX + 4*SMCNUM*NBTMAX
C
      DO 310 I=1,SMCNUM
        DO 300 J=1,SMCNTERMS(I)
          SMCCLOC(I,J) = TSMCCLOC(I,J)
          SMCCOEF(I,J) = TSMCCOEF(I,J)
  300   ENDDO
  310 ENDDO
      DEALLOCATE (TSMCCLOC,TSMCCOEF,STAT=ISTAT)
      IF(ISTAT.NE.0)GOTO 993
C 
C----WRITE INFORMATION TO OUTPUT FILE
      IF(IPRN.EQ.1)THEN
        WRITE(IOUT,6000,ERR=990)
        DO 410 I=1,SMCNUM
          WRITE(IOUT,6010,ERR=990)SMCNAME(I)
          NCAP=3
          NPROW=(SMCNTERMS(I)-1)/NCAP + 1
          J1=1-NCAP
          J2=0
          DO 400 II=1,NPROW
            J1=J1+NCAP
            J2=J2+NCAP
            IF(II.EQ.NPROW)THEN
C-------------THIS IS THE LAST ROW OF TERMS:
              J2=SMCNTERMS(I)
              WRITE(IOUT,6020,ERR=990)(CSW(I,J),ABS(SMCCOEF(I,J)),
     1          SMCCNM(I,J),J=J1,J2)
              IF(SMCDIR(I).EQ. 1)WRITE(IOUT,6030,ERR=990)SMCRHS(I)
              IF(SMCDIR(I).EQ. 0)WRITE(IOUT,6040)SMCRHS(I)
              IF(SMCDIR(I).EQ.-1)WRITE(IOUT,6050)SMCRHS(I)
            ELSE
C-------------WRITE A FULL ROW
              WRITE(IOUT,6020,ERR=990)(CSW(I,J),ABS(SMCCOEF(I,J)),
     1          SMCCNM(I,J),J=J1,J2)
            ENDIF
  400     ENDDO
  410   ENDDO
      ENDIF
C
C-----CLOSE FILE
      WRITE(IOUT,7000,ERR=990)BYTES
      WRITE(IOUT,7010,ERR=990)
      CLOSE(UNIT=LOCAT)
      DEALLOCATE (CSW,SMCCNM,STAT=ISTAT)
      IF(ISTAT.NE.0)GOTO 993
C
 1000 FORMAT(1X,/1X,'OPENING SUMMATION CONSTRAINTS FILE',/,
     1  ' ON UNIT ',I4,':',/1X,A200)
 2000 FORMAT(1X,/1X,'PROGRAM STOPPED. IPRN MUST BE EQUAL TO 0 OR 1: ',
     1  I4)
 3000 FORMAT(1X,/1X,'NUMBER OF SUMMATION CONSTRAINTS: ',I5)
 4000 FORMAT(1X,/1X,'PROGRAM STOPPED. CONSTRAINT NAME ',A10,
     1  ' HAS ALREADY BEEN USED.') 
 4010 FORMAT(1X,/1X,'PROGRAM STOPPED. NUMBER OF SUMMATION',
     1  ' TERMS (NTERMS) MUST BE GREATER THAN OR EQUAL TO 1, BUT',
     2  ' WAS SPECIFIED AS ',I5)
 4020 FORMAT(1X,/1X,'PROGRAM STOPPED. NUMBER OF SUMMATION',
     1  ' TERMS (NTERMS) MUST BE LESS THAN OR EQUAL TO ',I5)
 4030 FORMAT(1X,/1X,'PROGRAM STOPPED. SUMMATION CONSTRAINT ',A2,
     1  ' MUST BE SET TO EITHER LT, GT, OR EQ')
 4050 FORMAT(1X,/1X,'PROGRAM STOPPED. SUMMATION COEFFICIENT ',A10,/,
     1       '                 ALREADY DEFINED IN CONSTRAINT ',A10)
 5000 FORMAT(1X,/1X,'PROGRAM STOPPED. ',A10,' WAS NOT DEFINED AS A',
     1  ' VARIABLE',/,
     1  ' NAME (FVNAME, EVNAME, OR BVNAME) IN THE DECISION-',
     2  'VARIABLE FILE')
 6000 FORMAT(1X,/1X,'SUMMATION CONSTRAINTS:')
 6010 FORMAT(/,1X,A10)
 6020 FORMAT(2X,3(1X,A1,ES10.2,1X,A10))
 6030 FORMAT(/,2X,'<= ',ES10.2)
 6040 FORMAT(/,2X,'= ',ES10.2)
 6050 FORMAT(/,2X,'>= ',ES10.2)
 7000 FORMAT(/,1X,I8,' BYTES OF MEMORY ALLOCATED TO STORE DATA FOR',
     1               ' SUMMATION CONSTRAINTS')
 7010 FORMAT(/,1X,'CLOSING SUMMATION CONSTRAINTS FILE',/)
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
     &2X,'-- STOP EXECUTION (GWM1SMC1AR)')
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
     &2X,'-- STOP EXECUTION (GWM1SMC1AR)')
      CALL USTOP(' ')
C
  992 CONTINUE
C-----ARRAY-ALLOCATING ERROR
      WRITE(*,9920)
 9920 FORMAT(/,1X,'*** ERROR ALLOCATING ARRAY(S)',
     &2X,'-- STOP EXECUTION (GWM1SMC1AR)')
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
     &2X,'-- STOP EXECUTION (GWM1SMC1AR)')
      CALL USTOP(' ')
C
      END SUBROUTINE GWM1SMC1AR
C
C
C***********************************************************************
      SUBROUTINE GWM1SMC1FM(RSTRT,NSLK)
C***********************************************************************
C   VERSION: 20FEB2005
C   PURPOSE: PLACE SUMMATION CONSTRAINTS IN LP MATRIX STARTING IN ROW RSTRT
C-----------------------------------------------------------------------
      USE GWM1RMS1, ONLY : AMAT,RHS,
     &                     RHSIN,RHSINF,RANGENAME,RANGENAMEF,NDV,CONEQU
      INTEGER(I4B),INTENT(IN)::NSLK
      INTEGER(I4B),INTENT(INOUT)::RSTRT
C-----LOCAL VARIABLES
      INTEGER(I4B)::ISMC,ROW,J,K
C++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C
      ISMC = 0
      DO 110 ROW=RSTRT,RSTRT+SMCNUM-1
        ISMC = ISMC + 1                          ! DETERMINE CONSTRAINT INDEX
        DO 100 J=1,SMCNTERMS(ISMC)               ! LOOP OVER TERMS IN ROW
          K = SMCCLOC(ISMC,J)                    ! FIND COLUMN FOR JTH TERM
          AMAT(ROW,K)=REAL(SMCCOEF(ISMC,J),DP)   ! ASSIGN COEFFICIENT TO A
  100   ENDDO
        AMAT(ROW,NSLK) = DBLE(SMCDIR(ISMC))      ! ASSIGN SLACK 
        RHS(ROW) = SMCRHS(ISMC)                  ! ASSIGN RIGHT HAND SIDE
        RHSIN(ROW)= SMCRHS(ISMC)                 ! STORE THE INPUT RHS
        RANGENAME(ROW+NDV-1)=SMCNAME(ISMC)       ! LOAD FOR RANGE ANALYSIS OUTPUT
        RHSINF(ROW)= SMCRHS(ISMC)                ! STORE THE INPUT RHS
        RANGENAMEF(ROW+NDV-1)=SMCNAME(ISMC)      ! LOAD FOR RANGE ANALYSIS OUTPUT
        IF(SMCDIR(ISMC).EQ.0)THEN                ! CONSTRAINT IS EQUALITY
          CONEQU(ROW) = .TRUE.                   ! SET LOGICAL FOR OUTPUT
        ELSEIF(SMCDIR(ISMC).NE.0)THEN            ! CONSTRAINT IS INEQUALITY
          CONEQU(ROW) = .FALSE.                  ! SET LOGICAL FOR OUTPUT
        ENDIF
  110 ENDDO
C
C-----SET NEXT STARTING LOCATION
      RSTRT = RSTRT+SMCNUM
C
      RETURN
      END SUBROUTINE GWM1SMC1FM
C
C
C***********************************************************************
      SUBROUTINE GWM1SMC1OT(RSTRT)
C***********************************************************************
C  VERSION: 20FEB2005
C  PURPOSE - WRITE STATUS OF CONSTRAINT
C-----------------------------------------------------------------------
      USE GWM1BAS1, ONLY : ZERO,BIGINF,SMALLEPS
      USE GWM1RMS1, ONLY : CST,RHS,RHSIN,RANGENAME,NDV
      USE GWM1BAS1, ONLY : GWM1BAS1CS
      INTEGER(I4B),INTENT(INOUT)::RSTRT
C-----LOCAL VARIABLES
      CHARACTER(LEN=25)::CTYPE
      INTEGER(I4B)::J,ISMC,ROW
	REAL(DP)::LHS
C+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      ISMC = 0
      DO 110 ROW=RSTRT,RSTRT+SMCNUM-1
        ISMC = ISMC + 1
        IF(RHS(ROW).EQ.BIGINF*2.0D0)THEN         ! THIS CONSTRAINT WAS NOT IN LP
          LHS = ZERO
          DO 100 J=1,SMCNTERMS(ISMC)             ! COMPUTE CONSTRAINT LEFT SIDE
            LHS = LHS + REAL(SMCCOEF(ISMC,J),DP)*CST(SMCCLOC(ISMC,J))  
  100     ENDDO
          IF(ABS(LHS-RHSIN(ROW)).LT.SMALLEPS)THEN ! CONSTRAINT IS BINDING
            CTYPE = 'Summation'
            CALL GWM1BAS1CS(CTYPE,SMCNAME(ISMC),ZERO,0,0) 
          ENDIF
        ELSEIF(ABS(RHS(ROW)).GT.ZERO)THEN        ! DUAL VARIABLE IS NON-ZERO 
C                                                ! CONSTRAINT IS BINDING         
          CTYPE = 'Summation'
          CALL GWM1BAS1CS(CTYPE,SMCNAME(ISMC),RHS(ROW),0,0) 
        ENDIF
  110 ENDDO
C
C-----SET NEXT STARTING LOCATION
      RSTRT = RSTRT+SMCNUM
      RETURN
      END SUBROUTINE GWM1SMC1OT
C
C
      END MODULE GWM1SMC1