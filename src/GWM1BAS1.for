      MODULE GWM1BAS1
C     VERSION: 09AUG2006
      IMPLICIT NONE
      PRIVATE
      PUBLIC::GWMOUT,MPSFILE,RMFILE,RMFILEF,GWMWFILE,ZERO,ONE,
     &        SMALLEPS,BIGINF,NSTRESS
      PUBLIC:: GWM1BAS1PS, GWM1BAS1PF, GWM1BAS1CS
C
      INTEGER, PARAMETER :: I2B = SELECTED_INT_KIND(4)
      INTEGER, PARAMETER :: I4B = SELECTED_INT_KIND(9)
      INTEGER, PARAMETER :: SP = KIND(1.0)
      INTEGER, PARAMETER :: DP = KIND(1.0D0)
C
C-----DEFINE NUMERIC CONSTANTS AND UNIT NAMES
      REAL(DP),PARAMETER::ZERO=0.0D0, ONE=1.0D0
      REAL(DP),PARAMETER::SMALLEPS = 10.0D0**(-1*PRECISION(ONE) + 1)
      REAL(DP),PARAMETER::BIGINF   = 10.0D0**(RANGE(ONE)/2)
      INTEGER(I4B),SAVE::GWMOUT,MPSFILE,RMFILE,RMFILEF,NSTRESS,GWMWFILE
C
C      SMALLEPS -value used to represent machine precision. SMALLEPS is used to 
C                 estimate round-off error.  If the linear programming solution
C                 is within SMALLEPS of bounds, values are reset.  Upper bounds 
C                 of SQRT(SMALLEPS) are used to produce offset between lower
C                 and upper bounds on variables.
C      BIGINF  - value used to define machine infinity. BIGINF is used to set 
C                 infinite upper bounds on slack and other variables, as the 
C                 starting objective value in the branch and bound algorithm and
C                 as a flag in range analysis and computation of shadow prices.
C      GWMOUT   -unit number for writing GWM output
C      MPSFILE  -unit number for writing the MPS file
C      RMFILE   -unit number for saving the response matrix (unformatted)
C      RMFILEF  -unit number for printing the response matrix (formatted)
C      GWMWFILE -unit number for a printing the optimal flow values as a well file
C      NSTRESS  -takes the value of MF2K variable NPER. Needed so that number of 
C                 stress periods can be accessed through Modules
C
C-----FOR ERROR HANDLING
      CHARACTER(LEN=200)::FLNM 
      CHARACTER(LEN=20)::FILACT,FMTARG,ACCARG 
C
      CONTAINS
C***********************************************************************
      SUBROUTINE GWM1BAS1PS(LINE,INDEX)
C***********************************************************************
C     VERSION: 20FEB2005
C     PURPOSE: WRITE A LINE TO SCREEN AND FILE REPORTING GWM PROGRESS
C-----------------------------------------------------------------------
      CHARACTER(LEN=*),INTENT(IN)::LINE
      INTEGER(I4B),INTENT(IN)::INDEX
      INTERFACE 
        SUBROUTINE USTOP(STOPMESS)
        CHARACTER STOPMESS*(*)
        END
      END INTERFACE
C+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C
C-----WRITE TO THE SCREEN
      IF(INDEX.EQ.0)THEN
        WRITE(*,1000,ERR=990)LINE
      ELSE
        WRITE(*,1100)LINE,INDEX
      ENDIF
C
C-----WRITE TO THE FILE
      IF(INDEX.EQ.0)THEN
        WRITE(GWMOUT,1000,ERR=990)LINE
      ELSE
        WRITE(GWMOUT,1100,ERR=990)LINE,INDEX
      ENDIF
C
 1000 FORMAT(A)
 1100 FORMAT(A,I5)
C
      RETURN
C
C-----ERROR HANDLING
  990 CONTINUE
C-----FILE-WRITING ERROR
      INQUIRE(GWMOUT,NAME=FLNM,FORM=FMTARG,ACCESS=ACCARG,ACTION=FILACT)
      WRITE(*,9900)TRIM(FLNM),GWMOUT,FMTARG,ACCARG,FILACT
 9900 FORMAT(/,1X,'*** ERROR WRITING FILE "',A,'" ON UNIT ',I5,/,
     &7X,'SPECIFIED FILE FORMAT: ',A,/
     &7X,'SPECIFIED FILE ACCESS: ',A,/
     &7X,'SPECIFIED FILE ACTION: ',A,/
     &2X,'-- STOP EXECUTION (GWM1BAS1PS)')
      CALL USTOP(' ')
C
      END SUBROUTINE GWM1BAS1PS
C
C
C***********************************************************************
      SUBROUTINE GWM1BAS1PF(LINE,INDEX,VALUE)
C***********************************************************************
C     VERSION: 20FEB2005
C     PURPOSE: WRITE A LINE TO FILE THAT REPORTS ON GWM PROGRESS
C-----------------------------------------------------------------------
      CHARACTER (LEN=* ),INTENT(IN)::LINE
      INTEGER(I4B),INTENT(IN)::INDEX
      REAL(DP),INTENT(IN)::VALUE
      INTERFACE
        SUBROUTINE USTOP(STOPMESS)
        CHARACTER STOPMESS*(*)
        END
      END INTERFACE
C++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C
C-----USE INDEX AND FILE VALUES TO DETERMINE CORRECT FORMAT
      IF(INDEX.EQ.1)THEN
        WRITE(GWMOUT,1000,ERR=990)LINE,VALUE
      ELSEIF(INDEX.EQ.0 .AND. VALUE.EQ.ZERO)THEN
        WRITE(GWMOUT,1020,ERR=990)LINE
      ELSE
        WRITE(GWMOUT,1030,ERR=990)LINE,INDEX,VALUE
      ENDIF
C
 1000 FORMAT(A,ES14.6)
 1020 FORMAT(A)
 1030 FORMAT(A,I5,ES14.6)
C
      RETURN
C
C-----FOR ERROR HANDLING
  990 CONTINUE
C-----FILE-WRITING ERROR
      INQUIRE(GWMOUT,NAME=FLNM,FORM=FMTARG,ACCESS=ACCARG,ACTION=FILACT)
      WRITE(*,9900)TRIM(FLNM),GWMOUT,FMTARG,ACCARG,FILACT
 9900 FORMAT(/,1X,'*** ERROR WRITING FILE "',A,'" ON UNIT ',I5,/,
     &7X,'SPECIFIED FILE FORMAT: ',A,/
     &7X,'SPECIFIED FILE ACCESS: ',A,/
     &7X,'SPECIFIED FILE ACTION: ',A,/
     &2X,'-- STOP EXECUTION (GWM1BAS1PF)')
      CALL USTOP(' ')
C
      END SUBROUTINE GWM1BAS1PF
C
C
C***********************************************************************
      SUBROUTINE GWM1BAS1CS(CTYPE,CNAME,CARHS,CDIR,TFLG)
C***********************************************************************
C     VERSION: 21SEPT2005
C     PURPOSE: WRITE STATUS OF CONSTRAINTS
C-----------------------------------------------------------------------
      CHARACTER (LEN=*),INTENT(IN)::CTYPE
      CHARACTER (LEN=*),INTENT(IN)::CNAME
      REAL(DP),INTENT(IN)::CARHS
      INTEGER(I4B),INTENT(IN)::CDIR,TFLG
      INTERFACE  
        SUBROUTINE USTOP(STOPMESS)
        CHARACTER STOPMESS*(*)
        END
      END INTERFACE
      CHARACTER(LEN=12)::CSTAT
C++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C
C-----WRITE INITIAL STATUS OF CONSTRAINT
      IF((CARHS.LE.ZERO .AND. CDIR.EQ.2)  .OR.
     &   (CARHS.GE.ZERO .AND. CDIR.EQ.1) ) THEN
        CSTAT =  'Satisfied'
      ELSEIF(CDIR.EQ.0)THEN
        IF(TFLG.EQ.0)THEN
          CSTAT =  'Binding'
        ELSEIF(TFLG.EQ.1)THEN
          CSTAT =  'Near-Binding'
        ENDIF
      ELSE
        CSTAT =  'Not Met'
      ENDIF
C
	IF(TFLG.EQ.1)THEN                          ! WRITE CONSTRAINT STATUS
	  WRITE(GWMOUT,1100)CTYPE,CNAME,CSTAT,ABS(CARHS) 
	ELSEIF(TFLG.EQ.0)THEN                      ! WRITE SHADOW PRICE INFO
        IF(CARHS.EQ.BIGINF)THEN                  ! CONSTRAINT BINDING BUT 
          WRITE(GWMOUT,1000)CTYPE,CNAME,CSTAT,ZERO  ! BUT SHADOW PRICE IS ZERO
        ELSEIF(CARHS.NE.ZERO)THEN 
	    WRITE(GWMOUT,1000)CTYPE,CNAME,CSTAT,CARHS 
        ELSE                                     ! NO SHADOW PRICE AVAILABLE
	    WRITE(GWMOUT,1050)CTYPE,CNAME,CSTAT
        ENDIF
      ENDIF
C
 1000 FORMAT(T1,A,T24,A,T33,A,T44,ES12.4)
 1050 FORMAT(T1,A,T24,A,T33,A,T44,'Not Available')
 1100 FORMAT(T7,A,T30,A,T39,A,T54,ES11.4)
      RETURN
C
C-----ERROR HANDLING
  990 CONTINUE
C-----FILE-WRITING ERROR
      INQUIRE(GWMOUT,NAME=FLNM,FORM=FMTARG,ACCESS=ACCARG,ACTION=FILACT)
      WRITE(*,9900)TRIM(FLNM),GWMOUT,FMTARG,ACCARG,FILACT
 9900 FORMAT(/,1X,'*** ERROR WRITING FILE "',A,'" ON UNIT ',I5,/,
     &7X,'SPECIFIED FILE FORMAT: ',A,/
     &7X,'SPECIFIED FILE ACCESS: ',A,/
     &7X,'SPECIFIED FILE ACTION: ',A,/
     &2X,'-- STOP EXECUTION (GWM1BAS1CS)')
      CALL USTOP(' ')
C
      END SUBROUTINE GWM1BAS1CS
C
C
      END MODULE GWM1BAS1
