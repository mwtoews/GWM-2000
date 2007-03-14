! Time of File Save by ERB: 3/31/2005 1:32PM
C     Last change:  ERB  10 Jan 2003   10:59 am
C=======================================================================
      SUBROUTINE UNOITER(RHS,HNEW,NODES,ISA)
C-----VERSION 20010329 ERB
C     ******************************************************************
C     CHECK FOR NONZERO VALUES IN HNEW OR RHS
C     ******************************************************************
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      INTEGER I, ISA, NODES
      REAL RHS
      DOUBLE PRECISION HNEW(NODES)
      DIMENSION RHS(NODES)
C     ------------------------------------------------------------------
C
      ISA = 0
      DO 10 I = 1, NODES
        IF (RHS(I).NE.0. .OR. HNEW(I).NE.0.0) THEN
          ISA = 1
          GOTO 20
        ENDIF
   10 CONTINUE
   20 RETURN
      END
C=======================================================================
! Remove SUBROUTINE UNOCONV for GWM
!      END
      SUBROUTINE UBUDSV(KSTP,KPER,TEXT,IBDCHN,BUFF,NCOL,NROW,NLAY,IOUT)
C
C
C-----VERSION 1039 26JUNE1992 UBUDSV
C     ******************************************************************
C     RECORD CELL-BY-CELL FLOW TERMS FOR ONE COMPONENT OF FLOW.
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*16 TEXT
      DIMENSION BUFF(NCOL,NROW,NLAY)
C     ------------------------------------------------------------------
C
C1------WRITE AN UNFORMATTED RECORD IDENTIFYING DATA.
      WRITE(IOUT,1) TEXT,IBDCHN,KSTP,KPER
    1 FORMAT(1X,'UBUDSV SAVING "',A16,'" ON UNIT',I3,
     1     ' AT TIME STEP',I3,', STRESS PERIOD ',I4)
      WRITE(IBDCHN) KSTP,KPER,TEXT,NCOL,NROW,NLAY
C
C2------WRITE AN UNFORMATTED RECORD CONTAINING VALUES FOR
C2------EACH CELL IN THE GRID.
      WRITE(IBDCHN) BUFF
C
C3------RETURN
      RETURN
      END
      SUBROUTINE UCOLNO(NLBL1,NLBL2,NSPACE,NCPL,NDIG,IOUT)
C
C
C-----VERSION 0934 22JUNE1992 UCOLNO
C     ******************************************************************
C     OUTPUT COLUMN NUMBERS ABOVE A MATRIX PRINTOUT
C        NLBL1 IS THE START COLUMN LABEL (NUMBER)
C        NLBL2 IS THE STOP COLUMN LABEL (NUMBER)
C        NSPACE IS NUMBER OF BLANK SPACES TO LEAVE AT START OF LINE
C        NCPL IS NUMBER OF COLUMN NUMBERS PER LINE
C        NDIG IS NUMBER OF CHARACTERS IN EACH COLUMN FIELD
C        IOUT IS OUTPUT CHANNEL
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*1 DOT,SPACE,DG,BF
      DIMENSION BF(130),DG(10)
C
      DATA DG(1),DG(2),DG(3),DG(4),DG(5),DG(6),DG(7),DG(8),DG(9),DG(10)/
     1         '0','1','2','3','4','5','6','7','8','9'/
      DATA DOT,SPACE/'.',' '/
C     ------------------------------------------------------------------
C
C1------CALCULATE # OF COLUMNS TO BE PRINTED (NLBL), WIDTH
C1------OF A LINE (NTOT), NUMBER OF LINES (NWRAP).
      WRITE(IOUT,1)
    1 FORMAT(1X)
      NLBL=NLBL2-NLBL1+1
      N=NLBL
      IF(NLBL.GT.NCPL) N=NCPL
      NTOT=NSPACE+N*NDIG
      IF(NTOT.GT.130) GO TO 50
      NWRAP=(NLBL-1)/NCPL + 1
      J1=NLBL1-NCPL
      J2=NLBL1-1
C
C2------BUILD AND PRINT EACH LINE
      DO 40 N=1,NWRAP
C
C3------CLEAR THE BUFFER (BF).
      DO 20 I=1,130
      BF(I)=SPACE
   20 CONTINUE
      NBF=NSPACE
C
C4------DETERMINE FIRST (J1) AND LAST (J2) COLUMN # FOR THIS LINE.
      J1=J1+NCPL
      J2=J2+NCPL
      IF(J2.GT.NLBL2) J2=NLBL2
C5------LOAD THE COLUMN #'S INTO THE BUFFER.
      DO 30 J=J1,J2
      NBF=NBF+NDIG
      I2=J/10
      I1=J-I2*10+1
      BF(NBF)=DG(I1)
      IF(I2.EQ.0) GO TO 30
      I3=I2/10
      I2=I2-I3*10+1
      BF(NBF-1)=DG(I2)
      IF(I3.EQ.0) GO TO 30
      I4=I3/10
      I3=I3-I4*10+1
      BF(NBF-2)=DG(I3)
      IF(I4.EQ.0) GO TO 30
      BF(NBF-3)=DG(I4+1)
   30 CONTINUE
C
C6------PRINT THE CONTENTS OF THE BUFFER (I.E. PRINT THE LINE).
      WRITE(IOUT,31) (BF(I),I=1,NBF)
   31 FORMAT(1X,130A1)
C
   40 CONTINUE
C
C7------PRINT A LINE OF DOTS (FOR ESTHETIC PURPOSES ONLY).
   50 NTOT=NTOT
      IF(NTOT.GT.130) NTOT=130
      WRITE(IOUT,51) (DOT,I=1,NTOT)
   51 FORMAT(1X,130A1)
C
C8------RETURN
      RETURN
      END
      SUBROUTINE ULAPRS(BUF,TEXT,KSTP,KPER,NCOL,NROW,ILAY,IPRN,IOUT)
C
C
C-----VERSION 0755 01NOV1995 ULAPRS
C     ******************************************************************
C     PRINT A 1 LAYER ARRAY IN STRIPS
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*16 TEXT
      DIMENSION BUF(NCOL,NROW)
C     ------------------------------------------------------------------
C
C1------MAKE SURE THE FORMAT CODE (IP OR IPRN) IS BETWEEN 1
C1------AND 21.
      IP=IPRN
      IF(IP.LT.1 .OR. IP.GT.21) IP=12
C
C2------DETERMINE THE NUMBER OF VALUES (NCAP) PRINTED ON ONE LINE.
      NCAP=10
      IF(IP.EQ.1) NCAP=11
      IF(IP.EQ.2) NCAP=9
      IF(IP.GT.2 .AND. IP.LT.7) NCAP=15
      IF(IP.GT.6 .AND. IP.LT.12) NCAP=20
      IF(IP.EQ.19) NCAP=5
      IF(IP.EQ.20) NCAP=6
      IF(IP.EQ.21) NCAP=7
C
C3------CALCULATE THE NUMBER OF STRIPS (NSTRIP).
      NCPF=129/NCAP
      IF(IP.GE.13 .AND. IP.LE.18) NCPF=7
      IF(IP.EQ.19) NCPF=13
      IF(IP.EQ.20) NCPF=12
      IF(IP.EQ.21) NCPF=10
      ISP=0
      IF(NCAP.GT.12 .OR. IP.GE.13) ISP=3
      NSTRIP=(NCOL-1)/NCAP + 1
      J1=1-NCAP
      J2=0
C
C4------LOOP THROUGH THE STRIPS.
      DO 2000 N=1,NSTRIP
C
C5------CALCULATE THE FIRST(J1) & THE LAST(J2) COLUMNS FOR THIS STRIP
      J1=J1+NCAP
      J2=J2+NCAP
      IF(J2.GT.NCOL) J2=NCOL
C
C6-------PRINT TITLE ON EACH STRIP DEPENDING ON ILAY
      IF(ILAY.GT.0) THEN
         WRITE(IOUT,1) TEXT,ILAY,KSTP,KPER
    1    FORMAT('1',/2X,A,' IN LAYER ',I3,' AT END OF TIME STEP ',I3,
     1     ' IN STRESS PERIOD ',I4/2X,75('-'))
      ELSE IF(ILAY.LT.0) THEN
         WRITE(IOUT,2) TEXT,KSTP,KPER
    2    FORMAT('1',/1X,A,' FOR CROSS SECTION AT END OF TIME STEP',I3,
     1     ' IN STRESS PERIOD ',I4/1X,79('-'))
      END IF
C
C7------PRINT COLUMN NUMBERS ABOVE THE STRIP
      CALL UCOLNO(J1,J2,ISP,NCAP,NCPF,IOUT)
C
C8------LOOP THROUGH THE ROWS PRINTING COLS J1 THRU J2 WITH FORMAT IP
      DO 1000 I=1,NROW
      GO TO(10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,
     1      180,190,200,210), IP
C
C------------FORMAT 11G10.3
   10 WRITE(IOUT,11) I,(BUF(J,I),J=J1,J2)
   11 FORMAT(1X,I3,2X,1PG10.3,10(1X,G10.3))
      GO TO 1000
C
C------------FORMAT 9G13.6
   20 WRITE(IOUT,21) I,(BUF(J,I),J=J1,J2)
   21 FORMAT(1X,I3,2X,1PG13.6,8(1X,G13.6))
      GO TO 1000
C
C------------FORMAT 15F7.1
   30 WRITE(IOUT,31) I,(BUF(J,I),J=J1,J2)
   31 FORMAT(1X,I3,1X,15(1X,F7.1))
      GO TO 1000
C
C------------FORMAT 15F7.2
   40 WRITE(IOUT,41) I,(BUF(J,I),J=J1,J2)
   41 FORMAT(1X,I3,1X,15(1X,F7.2))
      GO TO 1000
C
C------------FORMAT 15F7.3
   50 WRITE(IOUT,51) I,(BUF(J,I),J=J1,J2)
   51 FORMAT(1X,I3,1X,15(1X,F7.3))
      GO TO 1000
C
C------------FORMAT 15F7.4
   60 WRITE(IOUT,61) I,(BUF(J,I),J=J1,J2)
   61 FORMAT(1X,I3,1X,15(1X,F7.4))
      GO TO 1000
C
C------------FORMAT 20F5.0
   70 WRITE(IOUT,71) I,(BUF(J,I),J=J1,J2)
   71 FORMAT(1X,I3,1X,20(1X,F5.0))
      GO TO 1000
C
C------------FORMAT 20F5.1
   80 WRITE(IOUT,81) I,(BUF(J,I),J=J1,J2)
   81 FORMAT(1X,I3,1X,20(1X,F5.1))
      GO TO 1000
C
C------------FORMAT 20F5.2
   90 WRITE(IOUT,91) I,(BUF(J,I),J=J1,J2)
   91 FORMAT(1X,I3,1X,20(1X,F5.2))
      GO TO 1000
C
C------------FORMAT 20F5.3
  100 WRITE(IOUT,101) I,(BUF(J,I),J=J1,J2)
  101 FORMAT(1X,I3,1X,20(1X,F5.3))
      GO TO 1000
C
C------------FORMAT 20F5.4
  110 WRITE(IOUT,111) I,(BUF(J,I),J=J1,J2)
  111 FORMAT(1X,I3,1X,20(1X,F5.4))
      GO TO 1000
C
C------------FORMAT 10G11.4
  120 WRITE(IOUT,121) I,(BUF(J,I),J=J1,J2)
  121 FORMAT(1X,I3,2X,1PG11.4,9(1X,G11.4))
      GO TO 1000
C
C------------FORMAT 10F6.0
  130 WRITE(IOUT,131) I,(BUF(J,I),J=J1,J2)
  131 FORMAT(1X,I3,1X,10(1X,F6.0))
      GO TO 1000
C
C------------FORMAT 10F6.1
  140 WRITE(IOUT,141) I,(BUF(J,I),J=J1,J2)
  141 FORMAT(1X,I3,1X,10(1X,F6.1))
      GO TO 1000
C
C------------FORMAT 10F6.2
  150 WRITE(IOUT,151) I,(BUF(J,I),J=J1,J2)
  151 FORMAT(1X,I3,1X,10(1X,F6.2))
      GO TO 1000
C
C------------FORMAT 10F6.3
  160 WRITE(IOUT,161) I,(BUF(J,I),J=J1,J2)
  161 FORMAT(1X,I3,1X,10(1X,F6.3))
      GO TO 1000
C
C------------FORMAT 10F6.4
  170 WRITE(IOUT,171) I,(BUF(J,I),J=J1,J2)
  171 FORMAT(1X,I3,1X,10(1X,F6.4))
      GO TO 1000
C
C------------FORMAT 10F6.5
  180 WRITE(IOUT,181) I,(BUF(J,I),J=J1,J2)
  181 FORMAT(1X,I3,1X,10(1X,F6.5))
C
C------------FORMAT 5G12.5
  190 WRITE(IOUT,191) I,(BUF(J,I),J=J1,J2)
  191 FORMAT(1X,I3,1X,1PG12.5,4(1X,G12.5))
C
C------------FORMAT 6G11.4
  200 WRITE(IOUT,201) I,(BUF(J,I),J=J1,J2)
  201 FORMAT(1X,I3,1X,1PG11.4,5(1X,G11.4))
C
C------------FORMAT 7G9.2
  210 WRITE(IOUT,211) I,(BUF(J,I),J=J1,J2)
  211 FORMAT(1X,I3,1X,1PG9.2,6(1X,G9.2))
C
 1000 CONTINUE
 2000 CONTINUE
C
C9------RETURN
      RETURN
      END
      SUBROUTINE ULAPRW(BUF,TEXT,KSTP,KPER,NCOL,NROW,ILAY,IPRN,IOUT)
C
C
C-----VERSION 0758 01NOV1995 ULAPRW
C     ******************************************************************
C     PRINT 1 LAYER ARRAY
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*16 TEXT
      DIMENSION BUF(NCOL,NROW)
C     ------------------------------------------------------------------
C
C1------PRINT A HEADER DEPENDING ON ILAY
      IF(ILAY.GT.0) THEN
         WRITE(IOUT,1) TEXT,ILAY,KSTP,KPER
    1    FORMAT('1',/2X,A,' IN LAYER ',I3,' AT END OF TIME STEP ',I3,
     1     ' IN STRESS PERIOD ',I4/2X,75('-'))
      ELSE IF(ILAY.LT.0) THEN
         WRITE(IOUT,2) TEXT,KSTP,KPER
    2    FORMAT('1',/1X,A,' FOR CROSS SECTION AT END OF TIME STEP',I3,
     1     ' IN STRESS PERIOD ',I4/1X,79('-'))
      END IF
C
C2------MAKE SURE THE FORMAT CODE (IP OR IPRN) IS
C2------BETWEEN 1 AND 21.
    5 IP=IPRN
      IF(IP.LT.1 .OR. IP.GT.21) IP=12
C
C3------CALL THE UTILITY MODULE UCOLNO TO PRINT COLUMN NUMBERS.
      IF(IP.EQ.1) CALL UCOLNO(1,NCOL,0,11,11,IOUT)
      IF(IP.EQ.2) CALL UCOLNO(1,NCOL,0,9,14,IOUT)
      IF(IP.GE.3 .AND. IP.LE.6) CALL UCOLNO(1,NCOL,3,15,8,IOUT)
      IF(IP.GE.7 .AND. IP.LE.11) CALL UCOLNO(1,NCOL,3,20,6,IOUT)
      IF(IP.EQ.12) CALL UCOLNO(1,NCOL,0,10,12,IOUT)
      IF(IP.GE.13 .AND. IP.LE.18) CALL UCOLNO(1,NCOL,3,10,7,IOUT)
      IF(IP.EQ.19) CALL UCOLNO(1,NCOL,0,5,13,IOUT)
      IF(IP.EQ.20) CALL UCOLNO(1,NCOL,0,6,12,IOUT)
      IF(IP.EQ.21) CALL UCOLNO(1,NCOL,0,7,10,IOUT)
C
C4------LOOP THROUGH THE ROWS PRINTING EACH ONE IN ITS ENTIRETY.
      DO 1000 I=1,NROW
      GO TO(10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,
     1      180,190,200,210), IP
C
C------------ FORMAT 11G10.3
   10 WRITE(IOUT,11) I,(BUF(J,I),J=1,NCOL)
   11 FORMAT(1X,I3,2X,1PG10.3,10(1X,G10.3):/(5X,11(1X,G10.3)))
      GO TO 1000
C
C------------ FORMAT 9G13.6
   20 WRITE(IOUT,21) I,(BUF(J,I),J=1,NCOL)
   21 FORMAT(1X,I3,2X,1PG13.6,8(1X,G13.6):/(5X,9(1X,G13.6)))
      GO TO 1000
C
C------------ FORMAT 15F7.1
   30 WRITE(IOUT,31) I,(BUF(J,I),J=1,NCOL)
   31 FORMAT(1X,I3,1X,15(1X,F7.1):/(5X,15(1X,F7.1)))
      GO TO 1000
C
C------------ FORMAT 15F7.2
   40 WRITE(IOUT,41) I,(BUF(J,I),J=1,NCOL)
   41 FORMAT(1X,I3,1X,15(1X,F7.2):/(5X,15(1X,F7.2)))
      GO TO 1000
C
C------------ FORMAT 15F7.3
   50 WRITE(IOUT,51) I,(BUF(J,I),J=1,NCOL)
   51 FORMAT(1X,I3,1X,15(1X,F7.3):/(5X,15(1X,F7.3)))
      GO TO 1000
C
C------------ FORMAT 15F7.4
   60 WRITE(IOUT,61) I,(BUF(J,I),J=1,NCOL)
   61 FORMAT(1X,I3,1X,15(1X,F7.4):/(5X,15(1X,F7.4)))
      GO TO 1000
C
C------------ FORMAT 20F5.0
   70 WRITE(IOUT,71) I,(BUF(J,I),J=1,NCOL)
   71 FORMAT(1X,I3,1X,20(1X,F5.0):/(5X,20(1X,F5.0)))
      GO TO 1000
C
C------------ FORMAT 20F5.1
   80 WRITE(IOUT,81) I,(BUF(J,I),J=1,NCOL)
   81 FORMAT(1X,I3,1X,20(1X,F5.1):/(5X,20(1X,F5.1)))
      GO TO 1000
C
C------------ FORMAT 20F5.2
   90 WRITE(IOUT,91) I,(BUF(J,I),J=1,NCOL)
   91 FORMAT(1X,I3,1X,20(1X,F5.2):/(5X,20(1X,F5.2)))
      GO TO 1000
C
C------------ FORMAT 20F5.3
  100 WRITE(IOUT,101) I,(BUF(J,I),J=1,NCOL)
  101 FORMAT(1X,I3,1X,20(1X,F5.3):/(5X,20(1X,F5.3)))
      GO TO 1000
C
C------------ FORMAT 20F5.4
  110 WRITE(IOUT,111) I,(BUF(J,I),J=1,NCOL)
  111 FORMAT(1X,I3,1X,20(1X,F5.4):/(5X,20(1X,F5.4)))
      GO TO 1000
C
C------------ FORMAT 10G11.4
  120 WRITE(IOUT,121) I,(BUF(J,I),J=1,NCOL)
  121 FORMAT(1X,I3,2X,1PG11.4,9(1X,G11.4):/(5X,10(1X,G11.4)))
      GO TO 1000
C
C------------ FORMAT 10F6.0
  130 WRITE(IOUT,131) I,(BUF(J,I),J=1,NCOL)
  131 FORMAT(1X,I3,1X,10(1X,F6.0):/(5X,10(1X,F6.0)))
      GO TO 1000
C
C------------ FORMAT 10F6.1
  140 WRITE(IOUT,141) I,(BUF(J,I),J=1,NCOL)
  141 FORMAT(1X,I3,1X,10(1X,F6.1):/(5X,10(1X,F6.1)))
      GO TO 1000
C
C------------ FORMAT 10F6.2
  150 WRITE(IOUT,151) I,(BUF(J,I),J=1,NCOL)
  151 FORMAT(1X,I3,1X,10(1X,F6.2):/(5X,10(1X,F6.2)))
      GO TO 1000
C
C------------ FORMAT 10F6.3
  160 WRITE(IOUT,161) I,(BUF(J,I),J=1,NCOL)
  161 FORMAT(1X,I3,1X,10(1X,F6.3):/(5X,10(1X,F6.3)))
      GO TO 1000
C
C------------ FORMAT 10F6.4
  170 WRITE(IOUT,171) I,(BUF(J,I),J=1,NCOL)
  171 FORMAT(1X,I3,1X,10(1X,F6.4):/(5X,10(1X,F6.4)))
      GO TO 1000
C
C------------ FORMAT 10F6.5
  180 WRITE(IOUT,181) I,(BUF(J,I),J=1,NCOL)
  181 FORMAT(1X,I3,1X,10(1X,F6.5):/(5X,10(1X,F6.5)))
      GO TO 1000
C
C------------FORMAT 5G12.5
  190 WRITE(IOUT,191) I,(BUF(J,I),J=1,NCOL)
  191 FORMAT(1X,I3,2X,1PG12.5,4(1X,G12.5):/(5X,5(1X,G12.5)))
      GO TO 1000
C
C------------FORMAT 6G11.4
  200 WRITE(IOUT,201) I,(BUF(J,I),J=1,NCOL)
  201 FORMAT(1X,I3,2X,1PG11.4,5(1X,G11.4):/(5X,6(1X,G11.4)))
      GO TO 1000
C
C------------FORMAT 7G9.2
  210 WRITE(IOUT,211) I,(BUF(J,I),J=1,NCOL)
  211 FORMAT(1X,I3,2X,1PG9.2,6(1X,G9.2):/(5X,7(1X,G9.2)))
C
 1000 CONTINUE
C
C5------RETURN
      RETURN
      END
      SUBROUTINE ULASAV(BUF,TEXT,KSTP,KPER,PERTIM,TOTIM,NCOL,
     1                   NROW,ILAY,ICHN)
C
C-----VERSION 1642 12MAY1987 ULASAV
C     ******************************************************************
C     SAVE 1 LAYER ARRAY ON DISK
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*16 TEXT
      DIMENSION BUF(NCOL,NROW)
C     ------------------------------------------------------------------
C
C1------WRITE AN UNFORMATTED RECORD CONTAINING IDENTIFYING
C1------INFORMATION.
      WRITE(ICHN) KSTP,KPER,PERTIM,TOTIM,TEXT,NCOL,NROW,ILAY
C
C2------WRITE AN UNFORMATTED RECORD CONTAINING ARRAY VALUES
C2------THE ARRAY IS DIMENSIONED (NCOL,NROW)
      WRITE(ICHN) ((BUF(IC,IR),IC=1,NCOL),IR=1,NROW)
C
C3------RETURN
      RETURN
      END
      SUBROUTINE U1DREL(A,ANAME,JJ,IN,IOUT)
C
C
C-----VERSION 1740 18APRIL1993 U1DREL
C     ******************************************************************
C     ROUTINE TO INPUT 1-D REAL DATA MATRICES
C       A IS ARRAY TO INPUT
C       ANAME IS 24 CHARACTER DESCRIPTION OF A
C       JJ IS NO. OF ELEMENTS
C       IN IS INPUT UNIT
C       IOUT IS OUTPUT UNIT
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*24 ANAME
      DIMENSION A(JJ)
      CHARACTER*20 FMTIN
      CHARACTER*200 CNTRL
      CHARACTER*200 FNAME
      DATA NUNOPN/99/
      INCLUDE 'openspec.inc'
C     ------------------------------------------------------------------
C
C1------READ ARRAY CONTROL RECORD AS CHARACTER DATA.
      READ(IN,'(A)') CNTRL
C
C2------LOOK FOR ALPHABETIC WORD THAT INDICATES THAT THE RECORD IS FREE
C2------FORMAT.  SET A FLAG SPECIFYING IF FREE FORMAT OR FIXED FORMAT.
      ICLOSE=0
      IFREE=1
      ICOL=1
      CALL URWORD(CNTRL,ICOL,ISTART,ISTOP,1,N,R,IOUT,IN)
      IF (CNTRL(ISTART:ISTOP).EQ.'CONSTANT') THEN
         LOCAT=0
      ELSE IF(CNTRL(ISTART:ISTOP).EQ.'INTERNAL') THEN
         LOCAT=IN
      ELSE IF(CNTRL(ISTART:ISTOP).EQ.'EXTERNAL') THEN
         CALL URWORD(CNTRL,ICOL,ISTART,ISTOP,2,LOCAT,R,IOUT,IN)
      ELSE IF(CNTRL(ISTART:ISTOP).EQ.'OPEN/CLOSE') THEN
         CALL URWORD(CNTRL,ICOL,ISTART,ISTOP,0,N,R,IOUT,IN)
         FNAME=CNTRL(ISTART:ISTOP)
         LOCAT=NUNOPN
         WRITE(IOUT,15) LOCAT,FNAME
   15    FORMAT(1X,/1X,'OPENING FILE ON UNIT ',I4,':',/1X,A)
         OPEN(UNIT=LOCAT,FILE=FNAME,ACTION=ACTION(1))
         ICLOSE=1
      ELSE
C
C2A-----DID NOT FIND A RECOGNIZED WORD, SO NOT USING FREE FORMAT.
C2A-----READ THE CONTROL RECORD THE ORIGINAL WAY.
         IFREE=0
         READ(CNTRL,1,ERR=500) LOCAT,CNSTNT,FMTIN,IPRN
    1    FORMAT(I10,F10.0,A20,I10)
      END IF
C
C3------FOR FREE FORMAT CONTROL RECORD, READ REMAINING FIELDS.
      IF(IFREE.NE.0) THEN
         CALL URWORD(CNTRL,ICOL,ISTART,ISTOP,3,N,CNSTNT,IOUT,IN)
         IF(LOCAT.GT.0) THEN
            CALL URWORD(CNTRL,ICOL,ISTART,ISTOP,1,N,R,IOUT,IN)
            FMTIN=CNTRL(ISTART:ISTOP)
            CALL URWORD(CNTRL,ICOL,ISTART,ISTOP,2,IPRN,R,IOUT,IN)
         END IF
      END IF
C
C4------TEST LOCAT TO SEE HOW TO DEFINE ARRAY VALUES.
      IF(LOCAT.GT.0) GO TO 90
C
C4A-----LOCAT <0 OR =0; SET ALL ARRAY VALUES EQUAL TO CNSTNT. RETURN.
      DO 80 J=1,JJ
   80 A(J)=CNSTNT
      WRITE(IOUT,3) ANAME,CNSTNT
    3 FORMAT(1X,/1X,A,' =',1P,G14.6)
      RETURN
C
C4B-----LOCAT>0; READ FORMATTED RECORDS USING FORMAT FMTIN.
   90 CONTINUE
      WRITE(IOUT,5) ANAME,LOCAT,FMTIN
    5 FORMAT(1X,///11X,A,/
     1       1X,'READING ON UNIT ',I4,' WITH FORMAT: ',A20)
      IF(FMTIN.EQ.'(FREE)') THEN
      READ(LOCAT,*) (A(J),J=1,JJ)
      ELSE
         READ(LOCAT,FMTIN) (A(J),J=1,JJ)
      END IF
      IF(ICLOSE.NE.0) CLOSE(UNIT=LOCAT)
C
C5------IF CNSTNT NOT ZERO THEN MULTIPLY ARRAY VALUES BY CNSTNT.
      ZERO=0.
      IF(CNSTNT.EQ.ZERO) GO TO 120
      DO 100 J=1,JJ
  100 A(J)=A(J)*CNSTNT
C
C6------IF PRINT CODE (IPRN) =0 OR >0 THEN PRINT ARRAY VALUES.
120   CONTINUE
      IF(IPRN.EQ.0) THEN
         WRITE(IOUT,1001) (A(J),J=1,JJ)
1001     FORMAT((1X,1PG12.5,9(1X,G12.5)))
      ELSE IF(IPRN.GT.0) THEN
         WRITE(IOUT,1002) (A(J),J=1,JJ)
1002     FORMAT((1X,1PG12.5,4(1X,G12.5)))
      END IF
C
C7------RETURN
      RETURN
C
C8------CONTROL RECORD ERROR.
500   WRITE(IOUT,502) ANAME
502   FORMAT(1X,/1X,'ERROR READING ARRAY CONTROL RECORD FOR ',A,':')
      WRITE(IOUT,'(1X,A)') CNTRL
      CALL USTOP(' ')
      END
      SUBROUTINE U2DINT(IA,ANAME,II,JJ,K,IN,IOUT)
C
C
C-----VERSION 0801 01NOV1995 U2DINT
C     ******************************************************************
C     ROUTINE TO INPUT 2-D INTEGER DATA MATRICES
C       IA IS ARRAY TO INPUT
C       ANAME IS 24 CHARACTER DESCRIPTION OF IA
C       II IS NO. OF ROWS
C       JJ IS NO. OF COLS
C       K IS LAYER NO. (USED WITH NAME TO TITLE PRINTOUT --
C              IF K=0, NO LAYER IS PRINTED
C              IF K<0, CROSS SECTION IS PRINTED)
C       IN IS INPUT UNIT
C       IOUT IS OUTPUT UNIT
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*24 ANAME
      DIMENSION IA(JJ,II)
      CHARACTER*20 FMTIN
      CHARACTER*200 CNTRL
      CHARACTER*200 FNAME
      DATA NUNOPN/99/
      INCLUDE 'openspec.inc'
C     ------------------------------------------------------------------
C
C1------READ ARRAY CONTROL RECORD AS CHARACTER DATA.
      READ(IN,'(A)') CNTRL
C
C2------LOOK FOR ALPHABETIC WORD THAT INDICATES THAT THE RECORD IS FREE
C2------FORMAT.  SET A FLAG SPECIFYING IF FREE FORMAT OR FIXED FORMAT.
      ICLOSE=0
      IFREE=1
      ICOL=1
      CALL URWORD(CNTRL,ICOL,ISTART,ISTOP,1,N,R,IOUT,IN)
      IF (CNTRL(ISTART:ISTOP).EQ.'CONSTANT') THEN
         LOCAT=0
      ELSE IF(CNTRL(ISTART:ISTOP).EQ.'INTERNAL') THEN
         LOCAT=IN
      ELSE IF(CNTRL(ISTART:ISTOP).EQ.'EXTERNAL') THEN
         CALL URWORD(CNTRL,ICOL,ISTART,ISTOP,2,LOCAT,R,IOUT,IN)
      ELSE IF(CNTRL(ISTART:ISTOP).EQ.'OPEN/CLOSE') THEN
         CALL URWORD(CNTRL,ICOL,ISTART,ISTOP,0,N,R,IOUT,IN)
         FNAME=CNTRL(ISTART:ISTOP)
         LOCAT=NUNOPN
         WRITE(IOUT,15) LOCAT,FNAME
   15    FORMAT(1X,/1X,'OPENING FILE ON UNIT ',I4,':',/1X,A)
         ICLOSE=1
      ELSE
C
C2A-----DID NOT FIND A RECOGNIZED WORD, SO NOT USING FREE FORMAT.
C2A-----READ THE CONTROL RECORD THE ORIGINAL WAY.
         IFREE=0
         READ(CNTRL,1,ERR=600) LOCAT,ICONST,FMTIN,IPRN
    1    FORMAT(I10,I10,A20,I10)
      END IF
C
C3------FOR FREE FORMAT CONTROL RECORD, READ REMAINING FIELDS.
      IF(IFREE.NE.0) THEN
         CALL URWORD(CNTRL,ICOL,ISTART,ISTOP,2,ICONST,R,IOUT,IN)
         IF(LOCAT.NE.0) THEN
            CALL URWORD(CNTRL,ICOL,ISTART,ISTOP,1,N,R,IOUT,IN)
            FMTIN=CNTRL(ISTART:ISTOP)
            IF(ICLOSE.NE.0) THEN
               IF(FMTIN.EQ.'(BINARY)') THEN
                  OPEN(UNIT=LOCAT,FILE=FNAME,FORM=FORM,ACCESS=ACCESS,
     &                 ACTION=ACTION(1))
               ELSE
                  OPEN(UNIT=LOCAT,FILE=FNAME,ACTION=ACTION(1))
               END IF
            END IF
            IF(LOCAT.GT.0 .AND. FMTIN.EQ.'(BINARY)') LOCAT=-LOCAT
            CALL URWORD(CNTRL,ICOL,ISTART,ISTOP,2,IPRN,R,IOUT,IN)
         END IF
      END IF
C
C4------TEST LOCAT TO SEE HOW TO DEFINE ARRAY VALUES.
      IF(LOCAT) 200,50,90
C
C4A-----LOCAT=0; SET ALL ARRAY VALUES EQUAL TO ICONST. RETURN.
   50 DO 80 I=1,II
      DO 80 J=1,JJ
   80 IA(J,I)=ICONST
      IF(K.GT.0) WRITE(IOUT,82) ANAME,ICONST,K
   82 FORMAT(1X,/1X,A,' =',I15,' FOR LAYER',I4)
      IF(K.LE.0) WRITE(IOUT,83) ANAME,ICONST
   83 FORMAT(1X,/1X,A,' =',I15)
      RETURN
C
C4B-----LOCAT>0; READ FORMATTED RECORDS USING FORMAT FMTIN.
   90 CONTINUE
      IF(K.GT.0) THEN
         WRITE(IOUT,94) ANAME,K,LOCAT,FMTIN
   94    FORMAT(1X,///11X,A,' FOR LAYER',I4,/
     1    1X,'READING ON UNIT ',I4,' WITH FORMAT: ',A)
      ELSE IF(K.EQ.0) THEN
         WRITE(IOUT,95) ANAME,LOCAT,FMTIN
   95    FORMAT(1X,///11X,A,/
     1    1X,'READING ON UNIT ',I4,' WITH FORMAT: ',A)
      ELSE
         WRITE(IOUT,96) ANAME,LOCAT,FMTIN
   96    FORMAT(1X,///11X,A,' FOR CROSS SECTION',/
     1    1X,'READING ON UNIT ',I4,' WITH FORMAT: ',A)
      END IF
      DO 100 I=1,II
      IF(FMTIN.EQ.'(FREE)') THEN
         READ(LOCAT,*) (IA(J,I),J=1,JJ)
      ELSE
         READ(LOCAT,FMTIN) (IA(J,I),J=1,JJ)
      END IF
  100 CONTINUE
      GO TO 300
C
C4C-----LOCAT<0; READ UNFORMATTED RECORD CONTAINING ARRAY VALUES.
  200 LOCAT=-LOCAT
      IF(K.GT.0) THEN
         WRITE(IOUT,201) ANAME,K,LOCAT
  201    FORMAT(1X,///11X,A,' FOR LAYER',I4,/
     1    1X,'READING BINARY ON UNIT ',I4)
      ELSE IF(K.EQ.0) THEN
         WRITE(IOUT,202) ANAME,LOCAT
  202    FORMAT(1X,///11X,A,/
     1    1X,'READING BINARY ON UNIT ',I4)
      ELSE
         WRITE(IOUT,203) ANAME,LOCAT
  203    FORMAT(1X,///11X,A,' FOR CROSS SECTION',/
     1    1X,'READING BINARY ON UNIT ',I4)
      END IF
      READ(LOCAT)
      READ(LOCAT) IA
C
C5------IF ICONST NOT ZERO THEN MULTIPLY ARRAY VALUES BY ICONST.
  300 IF(ICLOSE.NE.0) CLOSE(UNIT=LOCAT)
      IF(ICONST.EQ.0) GO TO 320
      DO 310 I=1,II
      DO 310 J=1,JJ
      IA(J,I)=IA(J,I)*ICONST
  310 CONTINUE
C
C6------IF PRINT CODE (IPRN) <0 THEN RETURN.
  320 IF(IPRN.LT.0) RETURN
C
C7------PRINT COLUMN NUMBERS AT TOP OF PAGE.
      IF(IPRN.GT.9 .OR. IPRN.EQ.0) IPRN=6
      GO TO(401,402,403,404,405,406,407,408,409), IPRN
401   CALL UCOLNO(1,JJ,4,60,2,IOUT)
      GO TO 500
402   CALL UCOLNO(1,JJ,4,40,3,IOUT)
      GO TO 500
403   CALL UCOLNO(1,JJ,4,30,4,IOUT)
      GO TO 500
404   CALL UCOLNO(1,JJ,4,25,5,IOUT)
      GO TO 500
405   CALL UCOLNO(1,JJ,4,20,6,IOUT)
      GO TO 500
406   CALL UCOLNO(1,JJ,4,10,12,IOUT)
      GO TO 500
407   CALL UCOLNO(1,JJ,4,25,3,IOUT)
      GO TO 500
408   CALL UCOLNO(1,JJ,4,15,5,IOUT)
      GO TO 500
409   CALL UCOLNO(1,JJ,4,10,7,IOUT)
C
C8------PRINT EACH ROW IN THE ARRAY.
500   DO 510 I=1,II
      GO TO(501,502,503,504,505,506,507,508,509), IPRN
C
C----------------FORMAT 60I1
  501 WRITE(IOUT,551) I,(IA(J,I),J=1,JJ)
  551 FORMAT(1X,I3,1X,60(1X,I1):/(5X,60(1X,I1)))
      GO TO 510
C
C----------------FORMAT 40I2
  502 WRITE(IOUT,552) I,(IA(J,I),J=1,JJ)
  552 FORMAT(1X,I3,1X,40(1X,I2):/(5X,40(1X,I2)))
      GO TO 510
C
C----------------FORMAT 30I3
  503 WRITE(IOUT,553) I,(IA(J,I),J=1,JJ)
  553 FORMAT(1X,I3,1X,30(1X,I3):/(5X,30(1X,I3)))
      GO TO 510
C
C----------------FORMAT 25I4
  504 WRITE(IOUT,554) I,(IA(J,I),J=1,JJ)
  554 FORMAT(1X,I3,1X,25(1X,I4):/(5X,25(1X,I4)))
      GO TO 510
C
C----------------FORMAT 20I5
  505 WRITE(IOUT,555) I,(IA(J,I),J=1,JJ)
  555 FORMAT(1X,I3,1X,20(1X,I5):/(5X,20(1X,I5)))
      GO TO 510
C
C----------------FORMAT 10I11
  506 WRITE(IOUT,556) I,(IA(J,I),J=1,JJ)
  556 FORMAT(1X,I3,1X,10(1X,I11):/(5X,10(1X,I11)))
      GO TO 510
C
C----------------FORMAT 25I2
  507 WRITE(IOUT,557) I,(IA(J,I),J=1,JJ)
  557 FORMAT(1X,I3,1X,25(1X,I2):/(5X,25(1X,I2)))
      GO TO 510
C
C----------------FORMAT 15I4
  508 WRITE(IOUT,558) I,(IA(J,I),J=1,JJ)
  558 FORMAT(1X,I3,1X,15(1X,I4):/(5X,10(1X,I4)))
      GO TO 510
C
C----------------FORMAT 10I6
  509 WRITE(IOUT,559) I,(IA(J,I),J=1,JJ)
  559 FORMAT(1X,I3,1X,10(1X,I6):/(5X,10(1X,I6)))
C
  510 CONTINUE
C
C9------RETURN
      RETURN
C
C10-----CONTROL RECORD ERROR.
  600 IF(K.GT.0) THEN
         WRITE(IOUT,601) ANAME,K
  601    FORMAT(1X,/1X,'ERROR READING ARRAY CONTROL RECORD FOR ',A,
     1     ' FOR LAYER',I4,':')
      ELSE
         WRITE(IOUT,602) ANAME
  602    FORMAT(1X,/1X,'ERROR READING ARRAY CONTROL RECORD FOR ',A,':')
      END IF
      WRITE(IOUT,'(1X,A)') CNTRL
      CALL USTOP(' ')
      END
      SUBROUTINE U2DREL(A,ANAME,II,JJ,K,IN,IOUT)
C
C
C-----VERSION 1539 22JUNE1993 U2DREL
C     ******************************************************************
C     ROUTINE TO INPUT 2-D REAL DATA MATRICES
C       A IS ARRAY TO INPUT
C       ANAME IS 24 CHARACTER DESCRIPTION OF A
C       II IS NO. OF ROWS
C       JJ IS NO. OF COLS
C       K IS LAYER NO. (USED WITH NAME TO TITLE PRINTOUT --)
C              IF K=0, NO LAYER IS PRINTED
C              IF K<0, CROSS SECTION IS PRINTED)
C       IN IS INPUT UNIT
C       IOUT IS OUTPUT UNIT
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*24 ANAME
      DIMENSION A(JJ,II)
      CHARACTER*20 FMTIN
      CHARACTER*200 CNTRL
      CHARACTER*16 TEXT
      CHARACTER*200 FNAME
      DATA NUNOPN/99/
      INCLUDE 'openspec.inc'
C     ------------------------------------------------------------------
C
C1------READ ARRAY CONTROL RECORD AS CHARACTER DATA.
      READ(IN,'(A)') CNTRL
C
C2------LOOK FOR ALPHABETIC WORD THAT INDICATES THAT THE RECORD IS FREE
C2------FORMAT.  SET A FLAG SPECIFYING IF FREE FORMAT OR FIXED FORMAT.
      ICLOSE=0
      IFREE=1
      ICOL=1
      CALL URWORD(CNTRL,ICOL,ISTART,ISTOP,1,N,R,IOUT,IN)
      IF (CNTRL(ISTART:ISTOP).EQ.'CONSTANT') THEN
         LOCAT=0
      ELSE IF(CNTRL(ISTART:ISTOP).EQ.'INTERNAL') THEN
         LOCAT=IN
      ELSE IF(CNTRL(ISTART:ISTOP).EQ.'EXTERNAL') THEN
         CALL URWORD(CNTRL,ICOL,ISTART,ISTOP,2,LOCAT,R,IOUT,IN)
      ELSE IF(CNTRL(ISTART:ISTOP).EQ.'OPEN/CLOSE') THEN
         CALL URWORD(CNTRL,ICOL,ISTART,ISTOP,0,N,R,IOUT,IN)
         FNAME=CNTRL(ISTART:ISTOP)
         LOCAT=NUNOPN
         WRITE(IOUT,15) LOCAT,FNAME
   15    FORMAT(1X,/1X,'OPENING FILE ON UNIT ',I4,':',/1X,A)
         ICLOSE=1
      ELSE
C
C2A-----DID NOT FIND A RECOGNIZED WORD, SO NOT USING FREE FORMAT.
C2A-----READ THE CONTROL RECORD THE ORIGINAL WAY.
         IFREE=0
         READ(CNTRL,1,ERR=500) LOCAT,CNSTNT,FMTIN,IPRN
    1    FORMAT(I10,F10.0,A20,I10)
      END IF
C
C3------FOR FREE FORMAT CONTROL RECORD, READ REMAINING FIELDS.
      IF(IFREE.NE.0) THEN
         CALL URWORD(CNTRL,ICOL,ISTART,ISTOP,3,N,CNSTNT,IOUT,IN)
         IF(LOCAT.NE.0) THEN
            CALL URWORD(CNTRL,ICOL,ISTART,ISTOP,1,N,R,IOUT,IN)
            FMTIN=CNTRL(ISTART:ISTOP)
            IF(ICLOSE.NE.0) THEN
               IF(FMTIN.EQ.'(BINARY)') THEN
                  OPEN(UNIT=LOCAT,FILE=FNAME,FORM=FORM,ACCESS=ACCESS,
     &                 ACTION=ACTION(1))
               ELSE
                  OPEN(UNIT=LOCAT,FILE=FNAME,ACTION=ACTION(1))
               END IF
            END IF
            IF(LOCAT.GT.0 .AND. FMTIN.EQ.'(BINARY)') LOCAT=-LOCAT
            CALL URWORD(CNTRL,ICOL,ISTART,ISTOP,2,IPRN,R,IOUT,IN)
         END IF
      END IF
C
C4------TEST LOCAT TO SEE HOW TO DEFINE ARRAY VALUES.
      IF(LOCAT) 200,50,90
C
C4A-----LOCAT=0; SET ALL ARRAY VALUES EQUAL TO CNSTNT. RETURN.
   50 DO 80 I=1,II
      DO 80 J=1,JJ
   80 A(J,I)=CNSTNT
      IF(K.GT.0) WRITE(IOUT,2) ANAME,CNSTNT,K
    2 FORMAT(1X,/1X,A,' =',1P,G14.6,' FOR LAYER',I4)
      IF(K.LE.0) WRITE(IOUT,3) ANAME,CNSTNT
    3 FORMAT(1X,/1X,A,' =',1P,G14.6)
      RETURN
C
C4B-----LOCAT>0; READ FORMATTED RECORDS USING FORMAT FMTIN.
   90 CONTINUE
      IF(K.GT.0) THEN
         WRITE(IOUT,94) ANAME,K,LOCAT,FMTIN
   94    FORMAT(1X,///11X,A,' FOR LAYER',I4,/
     1    1X,'READING ON UNIT ',I4,' WITH FORMAT: ',A)
      ELSE IF(K.EQ.0) THEN
         WRITE(IOUT,95) ANAME,LOCAT,FMTIN
   95    FORMAT(1X,///11X,A,/
     1    1X,'READING ON UNIT ',I4,' WITH FORMAT: ',A)
      ELSE
         WRITE(IOUT,96) ANAME,LOCAT,FMTIN
   96    FORMAT(1X,///11X,A,' FOR CROSS SECTION',/
     1    1X,'READING ON UNIT ',I4,' WITH FORMAT: ',A)
      END IF
      DO 100 I=1,II
      IF(FMTIN.EQ.'(FREE)') THEN
         READ(LOCAT,*) (A(J,I),J=1,JJ)
      ELSE
         READ(LOCAT,FMTIN) (A(J,I),J=1,JJ)
      END IF
  100 CONTINUE
      GO TO 300
C
C4C-----LOCAT<0; READ UNFORMATTED ARRAY VALUES.
  200 LOCAT=-LOCAT
      IF(K.GT.0) THEN
         WRITE(IOUT,201) ANAME,K,LOCAT
  201    FORMAT(1X,///11X,A,' FOR LAYER',I4,/
     1    1X,'READING BINARY ON UNIT ',I4)
      ELSE IF(K.EQ.0) THEN
         WRITE(IOUT,202) ANAME,LOCAT
  202    FORMAT(1X,///1X,A,/
     1    1X,'READING BINARY ON UNIT ',I4)
      ELSE
         WRITE(IOUT,203) ANAME,LOCAT
  203    FORMAT(1X,///1X,A,' FOR CROSS SECTION',/
     1    1X,'READING BINARY ON UNIT ',I4)
      END IF
      READ(LOCAT) KSTP,KPER,PERTIM,TOTIM,TEXT,NCOL,NROW,ILAY
      READ(LOCAT) A
C
C5------IF CNSTNT NOT ZERO THEN MULTIPLY ARRAY VALUES BY CNSTNT.
  300 IF(ICLOSE.NE.0) CLOSE(UNIT=LOCAT)
      ZERO=0.
      IF(CNSTNT.EQ.ZERO) GO TO 320
      DO 310 I=1,II
      DO 310 J=1,JJ
      A(J,I)=A(J,I)*CNSTNT
  310 CONTINUE
C
C6------IF PRINT CODE (IPRN) >0 OR =0 THEN PRINT ARRAY VALUES.
  320 IF(IPRN.GE.0) CALL ULAPRW(A,ANAME,0,0,JJ,II,0,IPRN,IOUT)
C
C7------RETURN
      RETURN
C
C8------CONTROL RECORD ERROR.
  500 IF(K.GT.0) THEN
         WRITE(IOUT,501) ANAME,K
  501    FORMAT(1X,/1X,'ERROR READING ARRAY CONTROL RECORD FOR ',A,
     1     ' FOR LAYER',I4,':')
      ELSE
         WRITE(IOUT,502) ANAME
  502    FORMAT(1X,/1X,'ERROR READING ARRAY CONTROL RECORD FOR ',A,':')
      END IF
      WRITE(IOUT,'(1X,A)') CNTRL
      CALL USTOP(' ')
      END
      SUBROUTINE URWORD(LINE,ICOL,ISTART,ISTOP,NCODE,N,R,IOUT,IN)
C
C
C-----VERSION 1003 05AUG1992 URWORD
C     ******************************************************************
C     ROUTINE TO EXTRACT A WORD FROM A LINE OF TEXT, AND OPTIONALLY
C     CONVERT THE WORD TO A NUMBER.
C        ISTART AND ISTOP WILL BE RETURNED WITH THE STARTING AND
C          ENDING CHARACTER POSITIONS OF THE WORD.
C        THE LAST CHARACTER IN THE LINE IS SET TO BLANK SO THAT IF ANY
C          PROBLEMS OCCUR WITH FINDING A WORD, ISTART AND ISTOP WILL
C          POINT TO THIS BLANK CHARACTER.  THUS, A WORD WILL ALWAYS BE
C          RETURNED UNLESS THERE IS A NUMERIC CONVERSION ERROR.  BE SURE
C          THAT THE LAST CHARACTER IN LINE IS NOT AN IMPORTANT CHARACTER
C          BECAUSE IT WILL ALWAYS BE SET TO BLANK.
C        A WORD STARTS WITH THE FIRST CHARACTER THAT IS NOT A SPACE OR
C          COMMA, AND ENDS WHEN A SUBSEQUENT CHARACTER THAT IS A SPACE
C          OR COMMA.  NOTE THAT THESE PARSING RULES DO NOT TREAT TWO
C          COMMAS SEPARATED BY ONE OR MORE SPACES AS A NULL WORD.
C        FOR A WORD THAT BEGINS WITH "'", THE WORD STARTS WITH THE
C          CHARACTER AFTER THE QUOTE AND ENDS WITH THE CHARACTER
C          PRECEDING A SUBSEQUENT QUOTE.  THUS, A QUOTED WORD CAN
C          INCLUDE SPACES AND COMMAS.  THE QUOTED WORD CANNOT CONTAIN
C          A QUOTE CHARACTER.
C        IF NCODE IS 1, THE WORD IS CONVERTED TO UPPER CASE.
C        IF NCODE IS 2, THE WORD IS CONVERTED TO AN INTEGER.
C        IF NCODE IS 3, THE WORD IS CONVERTED TO A REAL NUMBER.
C        NUMBER CONVERSION ERROR IS WRITTEN TO UNIT IOUT IF IOUT IS
C          POSITIVE; ERROR IS WRITTEN TO DEFAULT OUTPUT IF IOUT IS 0;
C          NO ERROR MESSAGE IS WRITTEN IF IOUT IS NEGATIVE.
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*(*) LINE
      CHARACTER*20 STRING
      CHARACTER*30 RW
      CHARACTER*1 TAB
C     ------------------------------------------------------------------
      TAB=CHAR(9)
C
C1------Set last char in LINE to blank and set ISTART and ISTOP to point
C1------to this blank as a default situation when no word is found.  If
C1------starting location in LINE is out of bounds, do not look for a
C1------word.
      LINLEN=LEN(LINE)
      LINE(LINLEN:LINLEN)=' '
      ISTART=LINLEN
      ISTOP=LINLEN
      LINLEN=LINLEN-1
      IF(ICOL.LT.1 .OR. ICOL.GT.LINLEN) GO TO 100
C
C2------Find start of word, which is indicated by first character that
C2------is not a blank, a comma, or a tab.
      DO 10 I=ICOL,LINLEN
      IF(LINE(I:I).NE.' ' .AND. LINE(I:I).NE.','
     &    .AND. LINE(I:I).NE.TAB) GO TO 20
10    CONTINUE
      ICOL=LINLEN+1
      GO TO 100
C
C3------Found start of word.  Look for end.
C3A-----When word is quoted, only a quote can terminate it.
20    IF(LINE(I:I).EQ.'''') THEN
         I=I+1
         IF(I.LE.LINLEN) THEN
            DO 25 J=I,LINLEN
            IF(LINE(J:J).EQ.'''') GO TO 40
25          CONTINUE
         END IF
C
C3B-----When word is not quoted, space, comma, or tab will terminate.
      ELSE
         DO 30 J=I,LINLEN
         IF(LINE(J:J).EQ.' ' .OR. LINE(J:J).EQ.','
     &    .OR. LINE(J:J).EQ.TAB) GO TO 40
30       CONTINUE
      END IF
C
C3C-----End of line without finding end of word; set end of word to
C3C-----end of line.
      J=LINLEN+1
C
C4------Found end of word; set J to point to last character in WORD and
C-------set ICOL to point to location for scanning for another word.
40    ICOL=J+1
      J=J-1
      IF(J.LT.I) GO TO 100
      ISTART=I
      ISTOP=J
C
C5------Convert word to upper case and RETURN if NCODE is 1.
      IF(NCODE.EQ.1) THEN
         IDIFF=ICHAR('a')-ICHAR('A')
         DO 50 K=ISTART,ISTOP
            IF(LINE(K:K).GE.'a' .AND. LINE(K:K).LE.'z')
     1             LINE(K:K)=CHAR(ICHAR(LINE(K:K))-IDIFF)
50       CONTINUE
         RETURN
      END IF
C
C6------Convert word to a number if requested.
100   IF(NCODE.EQ.2 .OR. NCODE.EQ.3) THEN
         RW=' '
         L=30-ISTOP+ISTART
         IF(L.LT.1) GO TO 200
         RW(L:30)=LINE(ISTART:ISTOP)
         IF(NCODE.EQ.2) READ(RW,'(I30)',ERR=200) N
         IF(NCODE.EQ.3) READ(RW,'(F30.0)',ERR=200) R
      END IF
      RETURN
C
C7------Number conversion error.
200   IF(NCODE.EQ.3) THEN
         STRING= 'A REAL NUMBER'
         L=13
      ELSE
         STRING= 'AN INTEGER'
         L=10
      END IF
C
C7A-----If output unit is negative, set last character of string to 'E'.
      IF(IOUT.LT.0) THEN
         N=0
         R=0.
         LINE(LINLEN+1:LINLEN+1)='E'
         RETURN
C
C7B-----If output unit is positive; write a message to output unit.
      ELSE IF(IOUT.GT.0) THEN
         IF(IN.GT.0) THEN
            WRITE(IOUT,201) IN,LINE(ISTART:ISTOP),STRING(1:L),LINE
         ELSE
            WRITE(IOUT,202) LINE(ISTART:ISTOP),STRING(1:L),LINE
         END IF
201      FORMAT(1X,/1X,'FILE UNIT ',I4,' : ERROR CONVERTING "',A,
     1       '" TO ',A,' IN LINE:',/1X,A)
202      FORMAT(1X,/1X,'KEYBOARD INPUT : ERROR CONVERTING "',A,
     1       '" TO ',A,' IN LINE:',/1X,A)
C
C7C-----If output unit is 0; write a message to default output.
      ELSE
         IF(IN.GT.0) THEN
            WRITE(*,201) IN,LINE(ISTART:ISTOP),STRING(1:L),LINE
         ELSE
            WRITE(*,202) LINE(ISTART:ISTOP),STRING(1:L),LINE
         END IF
      END IF
C
C7D-----STOP after writing message.
      CALL USTOP(' ')
      END
      SUBROUTINE UBDSV1(KSTP,KPER,TEXT,IBDCHN,BUFF,NCOL,NROW,NLAY,IOUT,
     1          DELT,PERTIM,TOTIM,IBOUND)

C-----VERSION 1002 18DEC1992 UBDSV1
C     ******************************************************************
C     RECORD CELL-BY-CELL FLOW TERMS FOR ONE COMPONENT OF FLOW AS A 3-D
C     ARRAY WITH EXTRA RECORD TO INDICATE DELT, PERTIM, AND TOTIM.
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*16 TEXT
      DIMENSION BUFF(NCOL,NROW,NLAY),IBOUND(NCOL,NROW,NLAY)
C     ------------------------------------------------------------------
C
C1------WRITE TWO UNFORMATTED RECORDS IDENTIFYING DATA.
      IF(IOUT.GT.0) WRITE(IOUT,1) TEXT,IBDCHN,KSTP,KPER
    1 FORMAT(1X,'UBDSV1 SAVING "',A16,'" ON UNIT',I4,
     1     ' AT TIME STEP',I3,', STRESS PERIOD',I4)
      WRITE(IBDCHN) KSTP,KPER,TEXT,NCOL,NROW,-NLAY
      WRITE(IBDCHN) 1,DELT,PERTIM,TOTIM
C
C2------WRITE AN UNFORMATTED RECORD CONTAINING VALUES FOR
C2------EACH CELL IN THE GRID.
      WRITE(IBDCHN) BUFF
C
C3------RETURN
      RETURN
      END
      SUBROUTINE UBDSV2(KSTP,KPER,TEXT,IBDCHN,NCOL,NROW,NLAY,
     1          NLIST,IOUT,DELT,PERTIM,TOTIM,IBOUND)
C
C-----VERSION 0805 18DEC1992 UBDSV2
C     ******************************************************************
C     WRITE HEADER RECORDS FOR CELL-BY-CELL FLOW TERMS FOR ONE COMPONENT
C     OF FLOW USING A LIST STRUCTURE.  EACH ITEM IN THE LIST IS WRITTEN
C     BY MODULE UBDSVA
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*16 TEXT
      DIMENSION IBOUND(NCOL,NROW,NLAY)
C     ------------------------------------------------------------------
C
C1------WRITE THREE UNFORMATTED RECORDS IDENTIFYING DATA.
      IF(IOUT.GT.0) WRITE(IOUT,1) TEXT,IBDCHN,KSTP,KPER
    1 FORMAT(1X,'UBDSV2 SAVING "',A16,'" ON UNIT',I4,
     1     ' AT TIME STEP',I3,', STRESS PERIOD',I4)
      WRITE(IBDCHN) KSTP,KPER,TEXT,NCOL,NROW,-NLAY
      WRITE(IBDCHN) 2,DELT,PERTIM,TOTIM
      WRITE(IBDCHN) NLIST
C
C2------RETURN
      RETURN
      END
      SUBROUTINE UBDSVA(IBDCHN,NCOL,NROW,J,I,K,Q,IBOUND,NLAY)

C-----VERSION 0809 18DEC1992 UBDSVA
C     ******************************************************************
C     WRITE ONE VALUE OF CELL-BY-CELL FLOW USING A LIST STRUCTURE.
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      DIMENSION IBOUND(NCOL,NROW,NLAY)
C     ------------------------------------------------------------------
C
C1------CALCULATE CELL NUMBER
      ICRL= (K-1)*NROW*NCOL + (I-1)*NCOL + J
C
C2------WRITE CELL NUMBER AND FLOW RATE
      WRITE(IBDCHN) ICRL,Q
C
C3------RETURN
      RETURN
      END
      SUBROUTINE UBDSV3(KSTP,KPER,TEXT,IBDCHN,BUFF,IBUFF,NOPT,
     1              NCOL,NROW,NLAY,IOUT,DELT,PERTIM,TOTIM,IBOUND)
C
C
C-----VERSION 1609 18DEC1992 UBDSV3
C     ******************************************************************
C     RECORD CELL-BY-CELL FLOW TERMS FOR ONE COMPONENT OF FLOW AS A 2-D
C     ARRAY OF FLOW VALUES AND OPTIONALLY A 2-D ARRAY OF LAYER NUMBERS
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*16 TEXT
      DIMENSION BUFF(NCOL,NROW,NLAY),IBUFF(NCOL,NROW),
     1          IBOUND(NCOL,NROW,NLAY)
C     ------------------------------------------------------------------
C
C1------WRITE TWO UNFORMATTED RECORDS IDENTIFYING DATA.
      IF(IOUT.GT.0) WRITE(IOUT,1) TEXT,IBDCHN,KSTP,KPER
    1 FORMAT(1X,'UBDSV3 SAVING "',A16,'" ON UNIT',I4,
     1     ' AT TIME STEP',I3,', STRESS PERIOD',I4)
      WRITE(IBDCHN) KSTP,KPER,TEXT,NCOL,NROW,-NLAY
      IMETH=3
      IF(NOPT.EQ.1) IMETH=4
      WRITE(IBDCHN) IMETH,DELT,PERTIM,TOTIM
C
C2------WRITE DATA AS ONE OR TWO UNFORMATTED RECORDS CONTAINING ONE
C2------VALUE PER LAYER.
      IF(NOPT.EQ.1) THEN
C2A-----WRITE ONE RECORD WHEN NOPT IS 1.  THE VALUES ARE FLOW VALUES
C2A-----FOR LAYER 1.
         WRITE(IBDCHN) ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
      ELSE
C2B-----WRITE TWO RECORDS WHEN NOPT IS NOT 1.  FIRST RECORD CONTAINS
C2B-----LAYER NUMBERS;  SECOND RECORD CONTAINS FLOW VALUES.
         WRITE(IBDCHN) ((IBUFF(J,I),J=1,NCOL),I=1,NROW)
         WRITE(IBDCHN) ((BUFF(J,I,IBUFF(J,I)),J=1,NCOL),I=1,NROW)
      END IF
C
C3------RETURN
      RETURN
      END
      SUBROUTINE UBDSV4(KSTP,KPER,TEXT,NAUX,AUXTXT,IBDCHN,
     1          NCOL,NROW,NLAY,NLIST,IOUT,DELT,PERTIM,TOTIM,IBOUND)
C
C-----VERSION 05MAY2000 UBDSV4
C     ******************************************************************
C     WRITE HEADER RECORDS FOR CELL-BY-CELL FLOW TERMS FOR ONE COMPONENT
C     OF FLOW PLUS AUXILIARY DATA USING A LIST STRUCTURE.  EACH ITEM IN
C     THE LIST IS WRITTEN BY MODULE UBDSVB
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*16 TEXT,AUXTXT(5)
      DIMENSION IBOUND(NCOL,NROW,NLAY)
C     ------------------------------------------------------------------
C
C1------WRITE UNFORMATTED RECORDS IDENTIFYING DATA.
      IF(IOUT.GT.0) WRITE(IOUT,1) TEXT,IBDCHN,KSTP,KPER
    1 FORMAT(1X,'UBDSV4 SAVING "',A16,'" ON UNIT',I4,
     1     ' AT TIME STEP',I3,', STRESS PERIOD',I4)
      WRITE(IBDCHN) KSTP,KPER,TEXT,NCOL,NROW,-NLAY
      WRITE(IBDCHN) 5,DELT,PERTIM,TOTIM
      WRITE(IBDCHN) NAUX+1
      IF(NAUX.GT.0) WRITE(IBDCHN) (AUXTXT(N),N=1,NAUX)
      WRITE(IBDCHN) NLIST
C
C2------RETURN
      RETURN
      END
      SUBROUTINE UBDSVB(IBDCHN,NCOL,NROW,J,I,K,Q,VAL,NVL,NAUX,LAUX,
     1                  IBOUND,NLAY)

C-----VERSION 05MAY2000 UBDSVB
C     ******************************************************************
C     WRITE ONE VALUE OF CELL-BY-CELL FLOW PLUS AUXILIARY DATA USING
C     A LIST STRUCTURE.
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      DIMENSION IBOUND(NCOL,NROW,NLAY),VAL(NVL)
C     ------------------------------------------------------------------
C
C1------CALCULATE CELL NUMBER
      ICRL= (K-1)*NROW*NCOL + (I-1)*NCOL + J
C
C2------WRITE CELL NUMBER AND FLOW RATE
      IF(NAUX.GT.0) THEN
         N2=LAUX+NAUX-1
         WRITE(IBDCHN) ICRL,Q,(VAL(N),N=LAUX,N2)
      ELSE
         WRITE(IBDCHN) ICRL,Q
      END IF
C
C3------RETURN
      RETURN
      END
      SUBROUTINE ULASV2(BUFF,TEXT,KSTP,KPER,PERTIM,TOTIM,NCOL,
     1                   NROW,ILAY,ICHN,FMTOUT,LBLSAV,IBOUND)
C
C-----VERSION 0929 27NOV1992 ULASV2
C     ******************************************************************
C     SAVE 1 LAYER ARRAY ON DISK USING FORMATTED OUTPUT
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*16 TEXT
      DIMENSION BUFF(NCOL,NROW),IBOUND(NCOL,NROW)
      CHARACTER*20 FMTOUT
C     ------------------------------------------------------------------
C
C1------WRITE A LABEL IF LBLSAV IS NOT 0.
      IF(LBLSAV.NE.0) WRITE(ICHN,5) KSTP,KPER,PERTIM,TOTIM,TEXT,NCOL,
     1                 NROW,ILAY,FMTOUT
5     FORMAT(1X,2I5,1P,2E15.6,1X,A,3I6,1X,A)
C
C2------WRITE THE ARRAY USING THE SPECIFIED FORMAT.
      DO 10 IR=1,NROW
      WRITE(ICHN,FMTOUT) (BUFF(IC,IR),IC=1,NCOL)
10    CONTINUE
C
C3------RETURN
      RETURN
      END
      SUBROUTINE ULASV3(IDATA,TEXT,KSTP,KPER,PERTIM,TOTIM,NCOL,
     1                   NROW,ILAY,ICHN,FMTOUT,LBLSAV)
C
C-----VERSION 07MAY1998 ULASV3
C     ******************************************************************
C     SAVE 2-D (LAYER) INTEGER ARRAY ON DISK USING FORMATTED OUTPUT
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*16 TEXT
      DIMENSION IDATA(NCOL,NROW)
      CHARACTER*20 FMTOUT
C     ------------------------------------------------------------------
C
C1------WRITE A LABEL IF LBLSAV IS NOT 0.
      IF(LBLSAV.NE.0) WRITE(ICHN,5) KSTP,KPER,PERTIM,TOTIM,TEXT,NCOL,
     1                 NROW,ILAY,FMTOUT
5     FORMAT(1X,2I5,1P,2E15.6,1X,A,3I6,1X,A)
C
C2------WRITE THE ARRAY USING THE SPECIFIED FORMAT.
      DO 10 IR=1,NROW
      WRITE(ICHN,FMTOUT) (IDATA(IC,IR),IC=1,NCOL)
10    CONTINUE
C
C3------RETURN.
      RETURN
      END
      SUBROUTINE ULAPRWC(A,NCOL,NROW,ILAY,IOUT,IPRN,ANAME)
C
C-----VERSION 01JULY1998 ULAPRWC
C     ******************************************************************
C     CHECK TO SEE IF AN ARRAY IS CONSTANT, AND PRINT IT APPROPRIATELY
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      DIMENSION A(NCOL,NROW)
      CHARACTER*(*) ANAME
C     ------------------------------------------------------------------
C
C  Check to see if entire array is a constant.
      TMP=A(1,1)
      DO 300 I=1,NROW
      DO 300 J=1,NCOL
      IF(A(J,I).NE.TMP) GO TO 400
  300 CONTINUE
      IF(ILAY.GT.0) THEN
         WRITE(IOUT,302) ANAME,TMP,ILAY
  302    FORMAT(1X,/1X,A,' =',1P,G14.6,' FOR LAYER',I4)
      ELSE IF(ILAY.EQ.0) THEN
         WRITE(IOUT,303) ANAME,TMP
  303    FORMAT(1X,/1X,A,' =',1P,G14.6)
      ELSE
         WRITE(IOUT,304) ANAME,TMP
  304    FORMAT(1X,/1X,A,' =',1P,G14.6,' FOR CROSS SECTION')
      END IF
      RETURN
C
C  Print the array.
  400 IF(ILAY.GT.0) THEN
         WRITE(IOUT,494) ANAME,ILAY
  494    FORMAT(1X,//11X,A,' FOR LAYER',I4)
      ELSE IF(ILAY.EQ.0) THEN
         WRITE(IOUT,495) ANAME
  495    FORMAT(1X,//11X,A)
      ELSE
         WRITE(IOUT,496) ANAME
  496    FORMAT(1X,//11X,A,' FOR CROSS SECTION')
      END IF
      IF(IPRN.GE.0) CALL ULAPRW(A,ANAME,0,0,NCOL,NROW,0,IPRN,IOUT)
C
      RETURN
      END
      SUBROUTINE URDCOM(IN,IOUT,LINE)
C
C-----VERSION 02FEB1999 URDCOM
C     ******************************************************************
C     READ COMMENTS FROM A FILE AND PRINT THEM.  RETURN THE FIRST LINE
C     THAT IS NOT A COMMENT
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*(*) LINE
C     ------------------------------------------------------------------
   10 READ(IN,'(A)') LINE
      IF(LINE(1:1).NE.'#') RETURN
      L=LEN(LINE)
      IF(L.GT.79) L=79
      DO 20 I=L,1,-1
      IF(LINE(I:I).NE.' ') GO TO 30
   20 CONTINUE
   30 IF (IOUT.GT.0) WRITE(IOUT,'(1X,A)') LINE(1:I)
      GO TO 10
C
      END
      SUBROUTINE ULSTRD(NLIST,RLIST,LSTBEG,LDIM,MXLIST,IAL,INPACK,IOUT,
     1     LABEL,CAUX,NCAUX,NAUX,IFREFM,NCOL,NROW,NLAY,ISCLOC1,ISCLOC2,
     2     ITERP)
C
C-----VERSION 02FEB1999 ULSTRD
C     ******************************************************************
C     Read and print a list.  NAUX of the values in the list are
C     optional -- auxiliary data.
C     ******************************************************************
      CHARACTER*(*) LABEL
      CHARACTER*16 CAUX(NCAUX)
      DIMENSION RLIST(LDIM,MXLIST)
      CHARACTER*200 LINE,FNAME
      DATA NUNOPN/99/
      INCLUDE 'openspec.inc'
C     ------------------------------------------------------------------
C
      IF (NLIST.EQ.0) RETURN
C  Check for and decode EXTERNAL and SFAC records.
      IN=INPACK
      ICLOSE=0
      READ(IN,'(A)') LINE
      SFAC=1.
      LLOC=1
      CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,I,R,IOUT,IN)
      IF(LINE(ISTART:ISTOP).EQ.'EXTERNAL') THEN
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,I,R,IOUT,IN)
         IN=I
         IF(ITERP.EQ.1)WRITE(IOUT,111) IN
  111    FORMAT(1X,'Reading list on unit ',I4)
         READ(IN,'(A)') LINE
      ELSE IF(LINE(ISTART:ISTOP).EQ.'OPEN/CLOSE') THEN
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,0,N,R,IOUT,IN)
         FNAME=LINE(ISTART:ISTOP)
         IN=NUNOPN
         IF(ITERP.EQ.1)WRITE(IOUT,115) IN,FNAME
  115    FORMAT(1X,/1X,'OPENING FILE ON UNIT ',I4,':',/1X,A)
         OPEN(UNIT=IN,FILE=FNAME,ACTION=ACTION(1))
         ICLOSE=1
         READ(IN,'(A)') LINE
      END IF
      LLOC=1
      CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,I,R,IOUT,IN)
      IF(LINE(ISTART:ISTOP).EQ.'SFAC') THEN
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,3,I,SFAC,IOUT,IN)
         IF(ITERP.EQ.1) THEN
           WRITE(IOUT,116) SFAC
  116      FORMAT(1X,'LIST SCALING FACTOR=',1PG12.5)
           IF(ISCLOC1.EQ.ISCLOC2) THEN
              WRITE(IOUT,113) ISCLOC1
  113         FORMAT(1X,'(THE SCALE FACTOR WAS APPLIED TO FIELD',I2,')')
           ELSE
              WRITE(IOUT,114) ISCLOC1,ISCLOC2
  114         FORMAT(1X,'(THE SCALE FACTOR WAS APPLIED TO FIELDS',
     1           I2,'-',I2,')')
           END IF
         ENDIF
         READ(IN,'(A)') LINE
      END IF
C
C  Write a label for the list.
      IF(ITERP.EQ.1) THEN
         WRITE(IOUT,'(1X)')
         CALL ULSTLB(IOUT,LABEL,CAUX,NCAUX,NAUX)
      END IF
C
C  Read the list
      NREAD2=LDIM-IAL
      NREAD1=NREAD2-NAUX
      N=NLIST+LSTBEG-1
      DO 250 II=LSTBEG,N
C  Read a line into the buffer.  (The first line has already been read
C  in order to scan for EXTERNAL and SFAC records.)
      IF(II.NE.LSTBEG) READ(IN,'(A)') LINE
C
C  Read the non-optional values from the line.
      IF(IFREFM.EQ.0) THEN
         READ(LINE,'(3I10,9F10.0)') K,I,J,(RLIST(JJ,II),JJ=4,NREAD1)
         LLOC=10*NREAD1+1
      ELSE
         LLOC=1
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,K,R,IOUT,IN)
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,I,R,IOUT,IN)
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,J,R,IOUT,IN)
         DO 200 JJ=4,NREAD1
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,3,IDUM,RLIST(JJ,II),IOUT,IN)
200      CONTINUE
      END IF
      RLIST(1,II)=K
      RLIST(2,II)=I
      RLIST(3,II)=J
      DO 204 ILOC=ISCLOC1,ISCLOC2
        RLIST(ILOC,II)=RLIST(ILOC,II)*SFAC
204   CONTINUE
C
C  Read the optional values from the line
      IF(NAUX.GT.0) THEN
         DO 210 JJ=NREAD1+1,NREAD2
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,3,IDUM,RLIST(JJ,II),IOUT,IN)
210      CONTINUE
      END IF
C
C  Write the values that were read.
      NN=II-LSTBEG+1
      IF(ITERP.EQ.1) WRITE(IOUT,205) NN,K,I,J,(RLIST(JJ,II),JJ=4,NREAD2)
205   FORMAT(1X,I6,I7,I7,I7,14G16.4)
C
C  Check for illegal grid location
      IF(K.LT.1 .OR. K.GT.NLAY) THEN
         WRITE(IOUT,*) ' Layer number in list is outside of the grid'
         CALL USTOP(' ')
      END IF
      IF(I.LT.1 .OR. I.GT.NROW) THEN
         WRITE(IOUT,*) ' Row number in list is outside of the grid'
         CALL USTOP(' ')
      END IF
      IF(J.LT.1 .OR. J.GT.NCOL) THEN
         WRITE(IOUT,*) ' Column number in list is outside of the grid'
         CALL USTOP(' ')
      END IF
  250 CONTINUE
      IF(ICLOSE.NE.0) CLOSE(UNIT=IN)
C
      RETURN
      END
      SUBROUTINE ULSTLB(IOUT,LABEL,CAUX,NCAUX,NAUX)
C
C-----VERSION 12JAN2000 ULSTLB
C     ******************************************************************
C     PRINT A LABEL FOR A LIST
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*(*) LABEL
      CHARACTER*16 CAUX(NCAUX)
      CHARACTER*160 BUF
      CHARACTER*1 DASH(160)
      DATA DASH/160*'-'/
C     ------------------------------------------------------------------
C
C  Define the label
      BUF=LABEL
      NBUF=LEN(LABEL)+9
      IF(NAUX.GT.0) THEN
      DO 10 I=1,NAUX
         N1=NBUF+1
         NBUF=NBUF+16
         BUF(N1:NBUF)=CAUX(I)
10       CONTINUE
      END IF
C
C  Write the label.
      WRITE(IOUT,103) BUF(1:NBUF)
      WRITE(IOUT,104) (DASH(J),J=1,NBUF)
  103 FORMAT(1X,A)
  104 FORMAT(1X,160A)
C
      RETURN
      END
      SUBROUTINE UMESPR(TEXT1,TEXT2,IOUT)
C
C-----VERSION 02FEB1999 URDCOM
C     ******************************************************************
C     PRINT A LINE CONSISTING OF TWO TEXT VARIABLES.
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*(*) TEXT1,TEXT2
C     ------------------------------------------------------------------
      WRITE(IOUT,*)
      WRITE(IOUT,'(1X,2A)') TEXT1,TEXT2
C
      RETURN
      END
      SUBROUTINE UPCASE(WORD)
C     VERSION 17FEB1999
C     ******************************************************************
C     CONVERT A CHARACTER STRING TO ALL UPPER CASE
C     ******************************************************************
C       SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER WORD*(*)
C
C
      L = LEN(WORD)
      IDIFF=ICHAR('a')-ICHAR('A')
      DO 10 K=1,L
      IF(WORD(K:K).GE.'a' .AND. WORD(K:K).LE.'z')
     1   WORD(K:K)=CHAR(ICHAR(WORD(K:K))-IDIFF)
10    CONTINUE
C
      RETURN
      END
      SUBROUTINE UPOPRELARR(ARR,N,VALUE)
C-----VERSION 19980730 ERB
C     ******************************************************************
C     POPULATE A REAL ARRAY WITH A VALUE
C     ******************************************************************
C        SPECIFICATIONS:
      INTEGER N
      REAL ARR(N), VALUE
C
      DO 10 I = 1, N
        ARR(I) = VALUE
 10   CONTINUE
C
      RETURN
      END
      SUBROUTINE UCASE(WORDIN,WORDOUT,ICASE)
C-----VERSION 19980316 ERB
C     ******************************************************************
C     CONVERT A CHARACTER STRING TO ALL UPPER (ICASE > 0) OR ALL
C     LOWER (ICASE < 0) CASE.  IF ICASE = 0, NO CASE CONVERSION IS DONE.
C     ******************************************************************
C       SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER WORDIN*(*), WORDOUT*(*)
      INTEGER ICASE, LENGNB, LENGIN, LENGOUT
C
C     DETERMINE LENGTH OF STRING VARIABLES
      LENGIN = LEN(WORDIN)
      LENGOUT = LEN(WORDOUT)
C
C     DETERMINE IF WORDOUT IS LONG ENOUGH TO CONTAIN NON-BLANK LENGTH
C     OF WORDIN
      LENGNB = NONB_LEN(WORDIN,LENGIN)
      IF (LENGNB.GT.LENGOUT) CALL USTOP('STRING-LENGTH ERROR IN UCASE')
C
      WORDOUT = WORDIN
      IDIFF=ICHAR('a')-ICHAR('A')
      IF (ICASE.GT.0) THEN
C       CONVERT STRING TO UPPER CASE
        DO 10 K=1,LENGNB
          IF(WORDIN(K:K).GE.'a' .AND. WORDIN(K:K).LE.'z')
     1      WORDOUT(K:K)=CHAR(ICHAR(WORDIN(K:K))-IDIFF)
10      CONTINUE
C
      ELSEIF (ICASE.LT.0) THEN
C       CONVERT STRING TO LOWER CASE
        DO 20 K=1,LENGNB
          IF(WORDIN(K:K).GE.'A' .AND. WORDIN(K:K).LE.'Z')
     1      WORDOUT(K:K)=CHAR(ICHAR(WORDIN(K:K))+IDIFF)
20      CONTINUE
C
      ENDIF
C
      RETURN
      END
      SUBROUTINE UCOLLBL(NLBL1,NLBL2,NSPACE,NCPL,NDIG,IOUT)
C-----VERSION 19980825 ERB
C     ******************************************************************
C     LABEL THE COLUMNS OF MATRIX PRINTOUT WITH PARAMETER NAMES
C        NLBL1 IS THE START COLUMN (NUMBER)
C        NLBL2 IS THE STOP COLUMN (NUMBER)
C        NSPACE IS NUMBER OF BLANK SPACES TO LEAVE AT START OF LINE
C        NCPL IS NUMBER OF COLUMNS PER LINE
C        NDIG IS NUMBER OF CHARACTERS IN EACH COLUMN FIELD
C        IOUT IS OUTPUT UNIT
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*1 DOT, SPACE, BF*200
C
      INCLUDE 'param.inc'
      DATA DOT,SPACE/'.',' '/
C     ------------------------------------------------------------------
C
C1------CALCULATE # OF COLUMNS TO BE PRINTED (NLBL), WIDTH
C1------OF A LINE (NTOT), NUMBER OF LINES (NWRAP).
      WRITE(IOUT,1)
    1 FORMAT(1X)
      NLBL = NLBL2-NLBL1+1
      N = NLBL
      IF(NLBL.GT.NCPL) N = NCPL
      LENPN = LEN(PARNAM(1))
      MINCOLSP = LENPN+1
      IF (NDIG.LT.MINCOLSP) THEN
        WRITE(IOUT,200) NDIG,MINCOLSP
 200    FORMAT(' SPECIFIED FIELD WIDTH TOO SMALL FOR PARNAM',
     &         '--STOP EXECUTION (UCOLLBL)',/
     &         ' NDIG = ',I2,'   MINCOLSP = ',I2)
        CALL USTOP(' ')
      ENDIF
      NTOT = NSPACE+LENPN+N*NDIG
      IND = (NDIG-LENPN-1)/2
      NWRAP = (NLBL-1)/NCPL+1
      J1 = NLBL1-NCPL
      J2 = NLBL1-1
C
C2------BUILD AND PRINT EACH LINE
      DO 40 N=1,NWRAP
C
C3------CLEAR THE BUFFER (BF).
        DO 20 I=1,130
          BF(I:I)=SPACE
   20   CONTINUE
        NBF = MINCOLSP+1+IND-NDIG
C
C4------DETERMINE FIRST (J1) AND LAST (J2) COLUMN # FOR THIS LINE.
        J1=J1+NCPL
        J2=J2+NCPL
        IF(J2.GT.NLBL2) J2=NLBL2
C5------LOAD THE COLUMN LABELS INTO THE BUFFER.
        DO 30 J=J1,J2
          NBF=NBF+NDIG
          NBF2 = NBF+LENPN-1
          BF(NBF:NBF2) = PARNAM(IPPTR(J))
   30   CONTINUE
C
C6------PRINT THE CONTENTS OF THE BUFFER (I.E. PRINT THE LINE).
        WRITE(IOUT,31) BF(1:NBF2)
   31   FORMAT(1X,A)
C
   40 CONTINUE
C
C7------PRINT A LINE OF DOTS (FOR ESTHETIC PURPOSES ONLY).
   50 CONTINUE
      WRITE(IOUT,51) (DOT,I=1,NTOT)
   51 FORMAT(1X,200A1)
C
C8------RETURN
      RETURN
      END
      SUBROUTINE UCOLLBLDAT(NLBL1,NLBL2,NSPACE,NCPL,NDIG,IOUT,OBSNAM,
     &                      NDD)
C
C-----VERSION 19980930 ERB
C     ******************************************************************
C     LABEL THE COLUMNS OF MATRIX PRINTOUT WITH DATA-IDENTIFIER NAMES
C        NLBL1 IS THE START COLUMN (NUMBER)
C        NLBL2 IS THE STOP COLUMN (NUMBER)
C        NSPACE IS NUMBER OF BLANK SPACES TO LEAVE AT START OF LINE
C        NCPL IS NUMBER OF COLUMNS PER LINE
C        NDIG IS NUMBER OF CHARACTERS IN EACH COLUMN FIELD
C        IOUT IS OUTPUT UNIT
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*1 DOT, SPACE, BF*200
      CHARACTER*12 OBSNAM(NDD)
C
      DATA DOT,SPACE/'.',' '/
C     ------------------------------------------------------------------
C
C1------CALCULATE # OF COLUMNS TO BE PRINTED (NLBL), WIDTH
C1------OF A LINE (NTOT), NUMBER OF LINES (NWRAP).
      WRITE(IOUT,1)
    1 FORMAT(1X)
      NLBL = NLBL2-NLBL1+1
      N = NLBL
      IF(NLBL.GT.NCPL) N = NCPL
      LENPN = LEN(OBSNAM(1))
      MINCOLSP = LENPN+1
      IF (NDIG.LT.MINCOLSP) THEN
        WRITE(IOUT,200) NDIG,MINCOLSP
 200    FORMAT(' SPECIFIED FIELD WIDTH TOO SMALL FOR OBSNAM',
     &         '--STOP EXECUTION (UCOLLBLDAT)',/
     &         ' NDIG = ',I2,'   MINCOLSP = ',I2)
        CALL USTOP(' ')
      ENDIF
      NTOT = NSPACE+LENPN+N*NDIG
      IND = (NDIG-LENPN-1)/2
      NWRAP = (NLBL-1)/NCPL+1
      J1 = NLBL1-NCPL
      J2 = NLBL1-1
C
C2------BUILD AND PRINT EACH LINE
      DO 40 N=1,NWRAP
C
C3------CLEAR THE BUFFER (BF).
        DO 20 I=1,130
          BF(I:I)=SPACE
   20   CONTINUE
        NBF = MINCOLSP+1+IND-NDIG
C
C4------DETERMINE FIRST (J1) AND LAST (J2) COLUMN # FOR THIS LINE.
        J1=J1+NCPL
        J2=J2+NCPL
        IF(J2.GT.NLBL2) J2=NLBL2
C5------LOAD THE COLUMN LABELS INTO THE BUFFER.
        DO 30 J=J1,J2
          NBF=NBF+NDIG
          NBF2 = NBF+LENPN-1
          BF(NBF:NBF2) = OBSNAM(J)
   30   CONTINUE
C
C6------PRINT THE CONTENTS OF THE BUFFER (I.E. PRINT THE LINE).
        WRITE(IOUT,31) BF(1:NBF2)
   31   FORMAT(1X,A)
C
   40 CONTINUE
C
C7------PRINT A LINE OF DOTS (FOR ESTHETIC PURPOSES ONLY).
   50 CONTINUE
      WRITE(IOUT,51) (DOT,I=1,NTOT)
   51 FORMAT(1X,200A1)
C
C8------RETURN
      RETURN
      END
      SUBROUTINE UPARPM(BUF,NPE,IPRC,IOUT)
C
C-----VERSION 19980825 ERB
C     ******************************************************************
C     PRINT ONE NPE*NPE CORRELATION OR VARIANCE-COVARIANCE MATRIX
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      DIMENSION BUF(NPE,NPE)
      INCLUDE 'param.inc'
C     ------------------------------------------------------------------
C
C2------MAKE SURE THE FORMAT CODE (IPRC) IS VALID
      IP=IPRC
      IF(IP.LT.1 .OR. IP.GT.10) IP=1
C
C3------LABEL COLUMNS WITH PARAMETER NAMES.
      IF(IP.EQ.1) CALL UCOLLBL(1,NPE,0,11,11,IOUT)
      IF(IP.EQ.2) CALL UCOLLBL(1,NPE,0,10,12,IOUT)
      IF(IP.EQ.3) CALL UCOLLBL(1,NPE,0,9,13,IOUT)
      IF(IP.EQ.4) CALL UCOLLBL(1,NPE,0,8,14,IOUT)
      IF(IP.EQ.5) CALL UCOLLBL(1,NPE,0,8,15,IOUT)
      IF(IP.EQ.6) CALL UCOLLBL(1,NPE,0,6,11,IOUT)
      IF(IP.EQ.7) CALL UCOLLBL(1,NPE,0,5,12,IOUT)
      IF(IP.EQ.8) CALL UCOLLBL(1,NPE,0,5,13,IOUT)
      IF(IP.EQ.9) CALL UCOLLBL(1,NPE,0,4,14,IOUT)
      IF(IP.EQ.10 ) CALL UCOLLBL(1,NPE,0,4,15,IOUT)
C
C4------LOOP THROUGH THE ROWS PRINTING EACH ONE IN ITS ENTIRETY.
      DO 1000 I=1,NPE
C
C------------ FORMAT 11G10.3
        IF (IP.EQ.1) THEN
          WRITE(IOUT,11) PARNAM(IPPTR(I)),(BUF(J,I),J=1,NPE)
   11     FORMAT(1X,A,1X,1PG10.3,10(1X,G10.3):/(11X,11(1X,G10.3)))
C
C------------ FORMAT 10G11.4
        ELSEIF (IP.EQ.2) THEN
          WRITE(IOUT,21) PARNAM(IPPTR(I)),(BUF(J,I),J=1,NPE)
   21     FORMAT(1X,A,1X,1PG11.4,9(1X,G11.4):/(11X,10(1X,G11.4)))
C
C------------ FORMAT 9G12.5
        ELSEIF (IP.EQ.3) THEN
          WRITE(IOUT,31) PARNAM(IPPTR(I)),(BUF(J,I),J=1,NPE)
   31     FORMAT(1X,A,1X,1PG12.5,8(1X,G12.5):/(11X,9(1X,G12.5)))
C
C------------ FORMAT 8G13.6
        ELSEIF (IP.EQ.4) THEN
          WRITE(IOUT,41) PARNAM(IPPTR(I)),(BUF(J,I),J=1,NPE)
   41     FORMAT(1X,A,1X,1PG13.6,7(1X,G13.6):/(11X,8(1X,G13.6)))
C
C------------ FORMAT 8G14.7
        ELSEIF (IP.EQ.5) THEN
          WRITE(IOUT,51) PARNAM(IPPTR(I)),(BUF(J,I),J=1,NPE)
   51     FORMAT(1X,A,1X,1PG14.7,7(1X,G14.7):/(11X,8(1X,G14.7)))
C
C------------ FORMAT 6G10.3
        ELSEIF (IP.EQ.6) THEN
          WRITE(IOUT,61) PARNAM(IPPTR(I)),(BUF(J,I),J=1,NPE)
   61     FORMAT(1X,A,1X,1PG10.3,5(1X,G10.3):/(11X,6(1X,G10.3)))
C
C------------ FORMAT 5G11.4
        ELSEIF (IP.EQ.7) THEN
          WRITE(IOUT,71) PARNAM(IPPTR(I)),(BUF(J,I),J=1,NPE)
   71     FORMAT(1X,A,1X,1PG11.4,4(1X,G11.4):/(11X,5(1X,G11.4)))
C
C------------ FORMAT 5G12.5
        ELSEIF (IP.EQ.8) THEN
          WRITE(IOUT,81) PARNAM(IPPTR(I)),(BUF(J,I),J=1,NPE)
   81     FORMAT(1X,A,1X,1PG12.5,4(1X,G12.5):/(11X,5(1X,G12.5)))
C
C------------ FORMAT 4G13.6
        ELSEIF (IP.EQ.9) THEN
          WRITE(IOUT,91) PARNAM(IPPTR(I)),(BUF(J,I),J=1,NPE)
   91     FORMAT(1X,A,1X,1PG13.6,3(1X,G13.6):/(11X,4(1X,G13.6)))
C
C------------ FORMAT 4G14.7
        ELSEIF (IP.EQ.10) THEN
          WRITE(IOUT,101) PARNAM(IPPTR(I)),(BUF(J,I),J=1,NPE)
  101     FORMAT(1X,A,1X,1PG14.7,3(1X,G14.7):/(11X,4(1X,G14.7)))
C
        ENDIF
 1000 CONTINUE
C
C5------RETURN
      RETURN
      END
      SUBROUTINE UARRSUBPRW(BUF,IDIMC,IDIMR,IC1,IC2,IR1,IR2,IPRC,
     &                      IOUT,OBSNAM,NDD)
C
C-----VERSION 19980930 ERB
C     ******************************************************************
C     PRINT RECTANGULAR SUBSET OF OBSERVATION VARIANCE-COVARIANCE MATRIX
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*12 OBSNAM(NDD)
      DIMENSION BUF(IDIMC,IDIMR)
C     ------------------------------------------------------------------
C
C2------MAKE SURE THE FORMAT CODE (IPRC) IS VALID
      IP=IPRC
      IF(IP.LT.1 .OR. IP.GT.10) IP=1
C
C3------LABEL COLUMNS WITH DATA-IDENTIFIER NAMES.
      IF(IP.EQ.1) CALL UCOLLBLDAT(IC1,IC2,0,10,13,IOUT,OBSNAM,NDD)
      IF(IP.EQ.2) CALL UCOLLBLDAT(IC1,IC2,0,10,13,IOUT,OBSNAM,NDD)
      IF(IP.EQ.3) CALL UCOLLBLDAT(IC1,IC2,0,9,13,IOUT,OBSNAM,NDD)
      IF(IP.EQ.4) CALL UCOLLBLDAT(IC1,IC2,0,8,14,IOUT,OBSNAM,NDD)
      IF(IP.EQ.5) CALL UCOLLBLDAT(IC1,IC2,0,8,15,IOUT,OBSNAM,NDD)
      IF(IP.EQ.6) CALL UCOLLBLDAT(IC1,IC2,0,5,13,IOUT,OBSNAM,NDD)
      IF(IP.EQ.7) CALL UCOLLBLDAT(IC1,IC2,0,5,13,IOUT,OBSNAM,NDD)
      IF(IP.EQ.8) CALL UCOLLBLDAT(IC1,IC2,0,5,13,IOUT,OBSNAM,NDD)
      IF(IP.EQ.9) CALL UCOLLBLDAT(IC1,IC2,0,4,14,IOUT,OBSNAM,NDD)
      IF(IP.EQ.10 ) CALL UCOLLBLDAT(IC1,IC2,0,4,15,IOUT,OBSNAM,NDD)
C
C4------LOOP THROUGH THE ROWS PRINTING EACH ONE IN ITS ENTIRETY.
      DO 1000 I=IR1,IR2
C
C------------ FORMAT 10G12.3
        IF (IP.EQ.1) THEN
          WRITE(IOUT,11) OBSNAM(I),(BUF(J,I),J=IC1,IC2)
   11     FORMAT(1X,A,1X,1PG12.3,9(1X,G12.3):/(11X,10(1X,G12.3)))
C
C------------ FORMAT 10G12.4
        ELSEIF (IP.EQ.2) THEN
          WRITE(IOUT,21) OBSNAM(I),(BUF(J,I),J=IC1,IC2)
   21     FORMAT(1X,A,1X,1PG12.4,9(1X,G12.4):/(11X,10(1X,G12.4)))
C
C------------ FORMAT 9G12.5
        ELSEIF (IP.EQ.3) THEN
          WRITE(IOUT,31) OBSNAM(I),(BUF(J,I),J=IC1,IC2)
   31     FORMAT(1X,A,1X,1PG12.5,8(1X,G12.5):/(11X,9(1X,G12.5)))
C
C------------ FORMAT 8G13.6
        ELSEIF (IP.EQ.4) THEN
          WRITE(IOUT,41) OBSNAM(I),(BUF(J,I),J=IC1,IC2)
   41     FORMAT(1X,A,1X,1PG13.6,7(1X,G13.6):/(11X,8(1X,G13.6)))
C
C------------ FORMAT 8G14.7
        ELSEIF (IP.EQ.5) THEN
          WRITE(IOUT,51) OBSNAM(I),(BUF(J,I),J=IC1,IC2)
   51     FORMAT(1X,A,1X,1PG14.7,7(1X,G14.7):/(11X,8(1X,G14.7)))
C
C------------ FORMAT 5G12.3
        ELSEIF (IP.EQ.6) THEN
          WRITE(IOUT,61) OBSNAM(I),(BUF(J,I),J=IC1,IC2)
   61     FORMAT(1X,A,1X,1PG12.3,4(1X,G12.3):/(11X,5(1X,G12.3)))
C
C------------ FORMAT 5G12.4
        ELSEIF (IP.EQ.7) THEN
          WRITE(IOUT,71) OBSNAM(I),(BUF(J,I),J=IC1,IC2)
   71     FORMAT(1X,A,1X,1PG12.4,4(1X,G12.4):/(11X,5(1X,G12.4)))
C
C------------ FORMAT 5G12.5
        ELSEIF (IP.EQ.8) THEN
          WRITE(IOUT,81) OBSNAM(I),(BUF(J,I),J=IC1,IC2)
   81     FORMAT(1X,A,1X,1PG12.5,4(1X,G12.5):/(11X,5(1X,G12.5)))
C
C------------ FORMAT 4G13.6
        ELSEIF (IP.EQ.9) THEN
          WRITE(IOUT,91) OBSNAM(I),(BUF(J,I),J=IC1,IC2)
   91     FORMAT(1X,A,1X,1PG13.6,3(1X,G13.6):/(11X,4(1X,G13.6)))
C
C------------ FORMAT 4G14.7
        ELSEIF (IP.EQ.10) THEN
          WRITE(IOUT,101) OBSNAM(I),(BUF(J,I),J=IC1,IC2)
  101     FORMAT(1X,A,1X,1PG14.7,3(1X,G14.7):/(11X,4(1X,G14.7)))
C
        ENDIF
 1000 CONTINUE
C
C5------RETURN
      RETURN
      END
      SUBROUTINE UOBSTI(ID,IOUT,ISSA,ITRSS,NPER,NSTP,IREFSP,NUMTS,
     &                  PERLEN,TOFF1,TOFFSET,TOMULT,TSMULT,ITR1ST,
     &                  OBSTIME)
C-----VERSION 19990729 ERB
C     ******************************************************************
C     ASSIGN OBSERVATION TIME STEP (NUMTS) AND TOFF GIVEN REFERENCE
C     STRESS PERIOD (IREFSP), OBSERVATION-TIME OFFSET (TOFFSET), AND
C     TIME-OFFSET MULTIPLIER (TOMULT)
C     ******************************************************************
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*(*) ID
      INTEGER IREFSP, ISSA, ITR1ST, NPER, NSTP, NUMTS
      REAL DELT, ENDTIME, PERLEN, TIME, TOFF1, TOFFMULT, TOFFSET,
     &     TOMULT, TSMULT
      DIMENSION NSTP(NPER), PERLEN(NPER), TSMULT(NPER), ISSA(NPER)
C     ------------------------------------------------------------------
 500  FORMAT(/,' TIME SPECIFIED FOR OBSERVATION "',A,
     &'" IS AFTER END OF SIMULATION',/,' -- STOP EXECUTION (UOBSTI)')
 505  FORMAT(/,' REFERENCE STRESS PERIOD (IREFSP) WAS SPECIFIED AS ',
     &I5,', BUT IT MUST BE',/,
     &' BETWEEN 1 AND NPER (OF THE DISCRETIZATION INPUT FILE)',/,
     &' -- STOP EXECUTION (UOBSTI)')
 510  FORMAT(/,' TOFFSET IS NEGATIVE FOR OBSERVATION "',A,
     &'" -- STOP EXECUTION (UOBSTI)')
C
C-----ENSURE THAT SPECIFIED REFERENCE STRESS PERIOD IS VALID
      IF (IREFSP.LT.1 .OR. IREFSP.GT.NPER) THEN
        WRITE(IOUT,505) IREFSP
        CALL USTOP(' ')
      ENDIF
C
C-----ENSURE THAT TOFFSET IS NOT NEGATIVE
      IF (TOFFSET.LT.0.0) THEN
        WRITE(IOUT,510) TRIM(ID)
        CALL USTOP(' ')
      ENDIF
C
C-----FIND NUMBER OF TIME STEPS PRECEDING REFERENCE STRESS PERIOD
      NUMTS = 0
      OBSTIME = 0.0
      IF (IREFSP.GT.1) THEN
        DO 10 I = 1, IREFSP-1
          NUMTS = NUMTS + NSTP(I)
          OBSTIME = OBSTIME + PERLEN(I)
 10     CONTINUE
      ENDIF
C
      TIME = 0.0
C
C-----USE TOMULT TO CONVERT TOFFSET TO MODEL-TIME UNITS (ASSUMES THAT
C     USER HAS DEFINED TOMULT CORRECTLY)
      TOFFMULT = TOFFSET*TOMULT
      OBSTIME = OBSTIME + TOFFMULT
C
C-----FIND STRESS PERIOD IN WHICH OBSERVATION TIME FALLS.
C     LOOP THROUGH STRESS PERIODS STARTING AT REFERENCE STRESS PERIOD.
C     TOFF1 IS OBSERVATION TIME IN TIME STEP, AS A FRACTION OF THE TIME
C     STEP. NUMTS IS THE NUMBER OF THE TIME STEP PRECEDING THE TIME STEP
C     IN WHICH THE OBSERVATION TIME OCCURS.
C
      DO 60 I = IREFSP, NPER
        ENDTIME = TIME+PERLEN(I)
        IF (ENDTIME.GE.TOFFMULT) THEN
C---------FIND TIME STEP PRECEDING OBSERVATION TIME
C         CALCULATE LENGTH OF FIRST TIME STEP IN CURRENT STRESS PERIOD
          DELT = PERLEN(I)/FLOAT(NSTP(I))
          IF (TSMULT(I).NE.1.) DELT = PERLEN(I)*(1.-TSMULT(I))/
     &                                (1.-TSMULT(I)**NSTP(I))
C         LOOP THROUGH TIME STEPS
          DO 40 J = 1, NSTP(I)
            ENDTIME = TIME+DELT
            IF (ENDTIME.GE.TOFFMULT) THEN
              IF (ISSA(I).NE.0 .OR. ITRSS.EQ.0) THEN
C---------------FOR A STEADY-STATE STRESS PERIOD, SET NUMTS AS CURRENT
C               TIME STEP AND TOFF1 AS ZERO
                TOFF1 = 0.0
                NUMTS = NUMTS+1
              ELSE
C---------------CALCULATE TOFF1 AS FRACTION OF TIME-STEP DURATION
                TOFF1 = (TOFFMULT-TIME)/DELT
C               ITR1ST IS A FLAG THAT INDICATES IF, FOR A CERTAIN
C               OBSERVATION TYPE, THE OBSERVATION TIME CAN BE BEFORE THE
C               END OF AN INITIAL TRANSIENT TIME STEP.  ITR1ST=0
C               INDICATES THAT THE OBS. TIME CAN BE IN INITIAL TRANSIENT
C               TIME STEP.  ITR1ST=1 INDICATES IT CAN'T
                IF (NUMTS.EQ.0 .AND. ITR1ST.EQ.1) THEN
                  NUMTS = 1
                  TOFF1 = 0.0
                ENDIF
              ENDIF
              GOTO 80
            ENDIF
            TIME = TIME+DELT
            DELT = DELT*TSMULT(I)
            NUMTS = NUMTS+1
 40       CONTINUE
        ELSE
          NUMTS = NUMTS+NSTP(I)
          TIME = TIME+PERLEN(I)
        ENDIF
 60   CONTINUE
C
C     ALLOW FOR ROUND-OFF ERROR, SO THAT OBSERVATION TIMES SPECIFIED
C     AT THE EXACT END OF THE SIMULATION ARE NOT FLAGGED AS ERRORS
      TOLERANCE = 1.0E-6*PERLEN(NPER)
      TDIFF = TOFFMULT-TIME
      IF (TDIFF.LT.TOLERANCE) THEN
        TOFF1 = 0.0
      ELSE
        WRITE(IOUT,500) ID
        CALL USTOP(' ')
      ENDIF
C
 80   CONTINUE
      RETURN
      END
C=======================================================================
      SUBROUTINE SVD (IA,A,AS,DTLA,BUFF1,BUFF3,IAAR)
C-----VERSION 20000615 MCH
C     CALCULATE THE INVERSE AND THE SQUARE-ROOT OF THE INVERSE OF A
C     SQUARE MATRIX USING SVD (I.E. DECOMPOSE THE MATRIX INTO A MATRIX
C     OF EIGENVECTORS AND A DIAGONAL MATRIX OF CORRESPONDING
C     EIGENVALUES).
C     ******************************************************************
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      REAL DTLA, A, AS
      INTEGER I, J, IA
      DOUBLE PRECISION BUFF1(IAAR,IAAR), BUFF3(IAAR)
      DIMENSION A(IAAR,IAAR), AS(IAAR,IAAR)
C
C---WRITE INCOMING MATRIX
C      WRITE(*,*)' MATRIX'
C      DO 34 K=1,IA
C  34    WRITE(*,*) (A(K,I),I=1,IA)
C
      DO 30 I = 1,IA
        DO 20 J = 1, IA
          BUFF1(I,J) = A(I,J)
   20   CONTINUE
   30 CONTINUE
C     A is used as temporary storage of the off-diagonal elements of
C     the returned (by SSVD1) tridiagonal matrix used by
C     SSVD2
      CALL SSVD1(BUFF1,IA,IA,BUFF3,A)
      CALL SSVD2(BUFF3,A,IA,IA,BUFF1)
C     CALCULATE INVERSE MATRIX
      CALL SSVD3(IA,BUFF1,BUFF3,A)
CWRITE MATRIX INVERSE
C      WRITE(*,*) ' MATRIX INVERSE'
C      DO 35 K=1,IA
C      WRITE(*,*) (A(K,I),I=1,IA)
C   35 CONTINUE
C      CALL USTOP(' ')
C     CALCULATE LOG-DETERMINANT OF THE MATRIX
      DTLA = 0.
      DO 40 I = 1, IA
        DTLA = DTLA + SNGL(DLOG(BUFF3(I)))
   40 CONTINUE
C     CALCULATE SQUARE-ROOT OF THE INVERSE MATRIX
      DO 50 I = 1, IA
        BUFF3(I) = DSQRT(BUFF3(I))
   50 CONTINUE
      CALL SSVD3(IA,BUFF1,BUFF3,AS)
      RETURN
      END
C=======================================================================
      SUBROUTINE SSVD1(A,N,NP,D,E)
C-----VERSION 1000 01FEB1992
C
C     ******************************************************************
C     COPYRIGHT (C) 1986 NUMERICAL RECIPES SOFTWARE, TRED2S,
C     REPRODUCED BY PERMISSION FROM THE BOOK NUMERICAL RECIPES: THE ART
C     OF SCIENTIFIC COMPUTING, PUBLISHED BY CAMBRIDGE UNIVERSITY PRESS
C     MODIFIED FOR DOUBLE PRECISION
C     ******************************************************************
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      DOUBLE PRECISION A, D, F, G, H, HH, SCALE
      INTEGER I, J, K, L, N, NP
      DIMENSION A(NP,NP), D(NP), E(NP)
C     ------------------------------------------------------------------
      IF (N.GT.1) THEN
        DO 80 I = N, 2, -1
          L = I - 1
          H = 0.0
          SCALE = 0.0
          IF (L.GT.1) THEN
            DO 10 K = 1, L
              SCALE = SCALE + DABS(A(I,K))
   10       CONTINUE
            IF (SCALE.EQ.0.0) THEN
              E(I) = A(I,L)
            ELSE
              DO 20 K = 1, L
                A(I,K) = A(I,K)/SCALE
                H = H + A(I,K)**2
   20         CONTINUE
              F = A(I,L)
              G = -SIGN(DSQRT(H),F)
              E(I) = SCALE*G
              H = H - F*G
              A(I,L) = F - G
              F = 0.0
              DO 50 J = 1, L
                A(J,I) = A(I,J)/H
                G = 0.0
                DO 30 K = 1, J
                  G = G + A(J,K)*A(I,K)
   30           CONTINUE
                IF (L.GT.J) THEN
                  DO 40 K = J+1, L
                    G = G + A(K,J)*A(I,K)
   40             CONTINUE
                ENDIF
                E(J) = G/H
                F = F + E(J)*A(I,J)
   50         CONTINUE
              HH = F/(H+H)
              DO 70 J = 1, L
                F = A(I,J)
                G = E(J) - HH*F
                E(J) = G
                DO 60 K = 1, J
                  A(J,K) = A(J,K) - F*E(K) - G*A(I,K)
   60           CONTINUE
   70         CONTINUE
            ENDIF
          ELSE
            E(I) = A(I,L)
          ENDIF
          D(I) = H
   80   CONTINUE
      ENDIF
      D(1) = 0.0
      E(1) = 0.0
      DO 130 I = 1, N
        L = I - 1
        IF (D(I).NE.0.0) THEN
          DO 110 J = 1, L
            G = 0.0
            DO 90 K = 1, L
              G = G + A(I,K)*A(K,J)
   90       CONTINUE
            DO 100 K = 1, L
              A(K,J) = A(K,J) - G*A(K,I)
  100       CONTINUE
  110     CONTINUE
        ENDIF
        D(I) = A(I,I)
        A(I,I) = 1.0
        IF (L.GE.1) THEN
          DO 120 J = 1, L
            A(I,J) = 0.0
            A(J,I) = 0.0
  120     CONTINUE
        ENDIF
  130 CONTINUE
      RETURN
      END
C=======================================================================
      SUBROUTINE SSVD2(D,E,N,NP,Z)
C-----VERSION 1000 01FEB1992
C
C     ******************************************************************
C     COPYRIGHT (C) 1986 NUMERICAL RECIPES SOFTWARE, TQLIS,
C     REPRODUCED BY PERMISSION FROM THE BOOK NUMERICAL RECIPES: THE ART
C     OF SCIENTIFIC COMPUTING, PUBLISHED BY CAMBRIDGE UNIVERSITY PRESS
C     MODIFIED FOR DOUBLE PRECISION
C     ******************************************************************
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      DOUBLE PRECISION B, C, D, DD, F, G, P, R, S, Z
      INTEGER I, ITER, K, L, M, N, NP
      CHARACTER*1 CHR
      DIMENSION D(NP), E(NP), Z(NP,NP)
C     ------------------------------------------------------------------
      IF (N.GT.1) THEN
        DO 10 I = 2, N
          E(I-1) = E(I)
   10   CONTINUE
        E(N) = 0.0
        DO 70 L = 1, N
          ITER = 0
   20     DO 30 M = L, N-1
            DD = DABS(D(M)) + DABS(D(M+1))
            IF (ABS(E(M))+DD.EQ.DD) GOTO 40
   30     CONTINUE
          M = N
   40     IF (M.NE.L) THEN
            IF (ITER.EQ.30) THEN
              WRITE (*,*) ' TOO MANY ITERATIONS'
              READ (*,'(A)') CHR
            ENDIF
            ITER = ITER + 1
            G = (D(L+1)-D(L))/(2.0*E(L))
            R = DSQRT(G**2+1.0)
            G = D(M) - D(L) + E(L)/(G+SIGN(R,G))
            S = 1.0
            C = 1.0
            P = 0.0
            DO 60 I = M-1, L, -1
              F = S*E(I)
              B = C*E(I)
              IF (DABS(F).GE.DABS(G)) THEN
                C = G/F
                R = DSQRT(C**2+1.0)
                E(I+1) = F*R
                S = 1.0/R
                C = C*S
              ELSE
                S = F/G
                R = DSQRT(S**2+1.0)
                E(I+1) = G*R
                C = 1.0/R
                S = S*C
              ENDIF
              G = D(I+1) - P
              R = (D(I)-G)*S + 2.0*C*B
              P = S*R
              D(I+1) = G + P
              G = C*R - B
              DO 50 K = 1, N
                F = Z(K,I+1)
                Z(K,I+1) = S*Z(K,I) + C*F
                Z(K,I) = C*Z(K,I) - S*F
   50         CONTINUE
   60       CONTINUE
            D(L) = D(L) - P
            E(L) = G
            E(M) = 0.0
            GOTO 20
          ENDIF
   70   CONTINUE
      ENDIF
      RETURN
      END
C=======================================================================
      SUBROUTINE SSVD3(N,A,C,B)
C-----VERSION 19990504 ERB
C
C     ******************************************************************
C     FORMERLY SEN1MI
C     CALCULATE THE INVERSE (B) OF A SYMMETRIC MATRIX WITH THE EIGEN-
C     VECTORS STORED IN A AND THE EIGENVALUES IN C BY
C     B = A * C-1 * A(TRANSPOSE)
C=======================================================================
      REAL B, TMP
      INTEGER I, J, K, N
      DOUBLE PRECISION A(N,N), C(N)
      DIMENSION B(N,N)
C=======================================================================
      DO 20 I = 1, N
        DO 10 J = 1, N
          B(I,J) = A(I,J)/C(J)
   10   CONTINUE
   20 CONTINUE
      DO 50 I = 1, N
        DO 40 J = I, N
          TMP = 0.0
          DO 30 K = 1, N
            TMP = TMP + B(J,K)*A(I,K)
   30     CONTINUE
          B(I,J) = TMP
   40   CONTINUE
   50 CONTINUE
      DO 70 I = 1, N
        DO 60 J = I + 1, N
          B(J,I) = B(I,J)
   60   CONTINUE
   70 CONTINUE
      RETURN
      END
C=======================================================================
      INTEGER FUNCTION IGETUNIT(IFIRST,MAXUNIT)
C     VERSION 19981030 ERB
C     ******************************************************************
C     FIND FIRST UNUSED FILE UNIT NUMBER BETWEEN IFIRST AND MAXUNIT
C     ******************************************************************
C        SPECIFICATIONS:
C     -----------------------------------------------------------------
      INTEGER I, IFIRST, IOST, MAXUNIT
      LOGICAL LOP
C     -----------------------------------------------------------------
C
      LOP = .TRUE.
C
C     LOOP THROUGH RANGE PROVIDED TO FIND FIRST UNUSED UNIT NUMBER
      DO 10 I=IFIRST,MAXUNIT
        INQUIRE(UNIT=I,IOSTAT=IOST,OPENED=LOP,ERR=5)
        IF (IOST.EQ.0) THEN
          IF (.NOT.LOP) THEN
            IGETUNIT = I
            RETURN
          ENDIF
        ENDIF
 5      CONTINUE
10    CONTINUE
C
C     IF THERE ARE NO UNUSED UNIT NUMBERS IN RANGE PROVIDED, RETURN
C     A VALUE INDICATING AN ERROR
      IGETUNIT = -1
C
      RETURN
      END
C=======================================================================
      SUBROUTINE RSTAT(NDR,RN205,RN210,IFLAG)
C     ******************************************************************
C     CRITICAL VALUES Of R2N STATISTIC BELOW WHICH THE HYPOTHESIS THAT
C     WEIGHTED RESIDUALS ARE INDEPENDENT AND NORMALLY DISTRIBUTED IS
C     REJECTED. FROM SHAPIRO AND FRANCIA, 1972 AND BROCKWELL AND DAVIS,
C     1987, P. 304. LISTED IN APPENDIX D OF METHODS AND GUIDELNES
C     ******************************************************************
C        SPECIFICATIONS:
      REAL RN205, RN210, TABLE05, TABLE10
      INTEGER I, ITABLE
C     ------------------------------------------------------------------
      DIMENSION ITABLE(29), TABLE05(29), TABLE10(29)
      DATA (ITABLE(I),I=1,29)/35,50,51,53,55,57,59,61,63,65,67,69,71,73,
     &      75,77,79,81,83,85,87,89,91,93,95,97,99,131,200/
      DATA (TABLE05(I),I=1,29)/0.943, 0.953, 0.954, 0.957, 0.958, 0.961,
     &      0.962, 0.963, 0.964, 0.965, 0.966, 0.966, 0.967, 0.968,
     &      0.969, 0.969, 0.970, 0.970, 0.971, 0.972, 0.972, 0.972,
     &      0.973, 0.973, 0.974, 0.975, 0.976, 0.980, 0.987/
      DATA (TABLE10(I),I=1,29)/0.952, 0.963, 0.964, 0.964, 0.965, 0.966,
     &      0.967, 0.968, 0.970, 0.971, 0.971, 0.972, 0.972, 0.973,
     &      0.973, 0.974, 0.975, 0.975, 0.976, 0.977, 0.977, 0.977,
     &      0.978, 0.979, 0.979, 0.979, 0.980, 0.983, 0.989/
C     ------------------------------------------------------------------
C
      IF (NDR.LE.35) THEN
        RN205 = TABLE05(1)
        RN210 = TABLE10(1)
        IF (NDR.LT.35) IFLAG = 0
        IF (NDR.EQ.35) IFLAG = 1
        RETURN
      ENDIF
C
      DO 10 I=2,29
        IF(NDR.LE.ITABLE(I)) THEN
          RN205 = TABLE05(I-1)+(TABLE05(I)-TABLE05(I-1))*
     &         REAL(NDR-ITABLE(I-1))/REAL(ITABLE(I)-ITABLE(I-1))
          RN210 = TABLE10(I-1)+(TABLE10(I)-TABLE10(I-1))*
     &         REAL(NDR-ITABLE(I-1))/REAL(ITABLE(I)-ITABLE(I-1))
          IFLAG = 1
          RETURN
        ENDIF
   10 CONTINUE
C
      RN205 = TABLE05(29)
      RN210 = TABLE10(29)
      IFLAG = 2
C
      RETURN
      END
C=======================================================================
      INTEGER FUNCTION NONB_LEN(CHARVAR,LENGTH)
C     ******************************************************************
C     FUNCTION TO RETURN NON-BLANK LENGTH OF CONTENTS OF A CHARACTER
C     VARIABLE
C     ******************************************************************
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
C
C Variable list:
C   CHARVAR  = CHARACTER VARIABLE OF INTEREST
C   LENGTH   = DIMENSIONED LENGTH OF CHARVAR
C
      CHARACTER*(*) CHARVAR,C*1
      INTEGER LENGTH
C     ------------------------------------------------------------------
C
      C = ' '
      K = LENGTH+1
C
      DO 20 WHILE (C.EQ.' ' .AND. K.GE.1)
        K = K-1
        C = CHARVAR(K:K)
 20   CONTINUE
C
      NONB_LEN = K
C
      RETURN
      END
C=======================================================================
      SUBROUTINE CLOSEFILES(INUNIT,FNAME)
C
C-----VERSION 20000718
C     ******************************************************************
C     CLOSE ALL FILES IN THE NAME FILE
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER*(*) FNAME
      CHARACTER*200 LINE
      LOGICAL LOP
      INCLUDE 'openspec.inc'
C     ---------------------------------------------------------------
C
C1------OPEN THE NAME FILE.
      OPEN(UNIT=INUNIT,FILE=FNAME,STATUS='OLD',ACTION=ACTION(1))
C
C2------READ A LINE; IGNORE BLANK LINES AND COMMENT LINES.
10    READ(INUNIT,'(A)',END=1000) LINE
      IF(LINE.EQ.' ') GO TO 10
      IF(LINE(1:1).EQ.'#') GO TO 10
C
C3------DECODE THE FILE TYPE, UNIT NUMBER, AND NAME.
      LLOC=1
      CALL URWORD(LINE,LLOC,ITYP1,ITYP2,1,N,R,-1,INUNIT)
      CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,IU,R,-1,INUNIT)
      CALL URWORD(LINE,LLOC,INAM1,INAM2,0,N,R,-1,INUNIT)
C
C4------CLOSE THE FILE IF IT IS OPEN.
      INQUIRE(UNIT=IU,OPENED=LOP)
      IF (LOP) THEN
        CLOSE(UNIT=IU,ERR=100)
  100   CONTINUE
      ENDIF
      GO TO 10
C
C5------END OF NAME FILE.
 1000 CONTINUE
      CLOSE(UNIT=INUNIT)
      RETURN
C
      END
C=======================================================================
      SUBROUTINE USTOP(STOPMESS)
C     ******************************************************************
C     STOP PROGRAM, WITH OPTION TO PRINT MESSAGE BEFORE STOPPING
C     ******************************************************************
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      CHARACTER STOPMESS*(*)
C     ------------------------------------------------------------------
   10 FORMAT(1X,A)

      IF (STOPMESS.NE.' ') THEN
        WRITE(*,10) STOPMESS
      ENDIF
      STOP

      END
C=======================================================================
      SUBROUTINE SHELLSORT (X, N)
C
C      Algorithm obtained from http://www.nist.gov/dads/HTML/shellsort.html
C      Thank you NIST!
C
C        ALGORITHM AS 304.8 APPL.STATIST. (1996), VOL.45, NO.3
C
C        Sorts the N values stored in array X in ascending order
C
C  Based on an "adaptation by Marlene Metzner" this algorithm is referred to as
C  the Shell-Metzner sort by John P. Grillo, A Comparison of Sorts, Creative
C  Computing, 2:76-80, Nov/Dec 1976. Grillo cites Fredric Stuart, FORTRAN
C  Programming, John Wiley and Sons, New York, 1969, page 294. In crediting
C  "one of the fastest" programs for sorting, Stuart says in a footnote,
C  "Published by Marlene Metzner, Pratt & Whitney Aircraft Company. From a
C  method described by D. L. Shell."
C
      INTEGER N
      CHARACTER*12 X(N)
C
      INTEGER I, J, INCR
      CHARACTER*12 TEMP
C
      INCR = 1
C
C        Loop : calculate the increment
C
   10 INCR = 3 * INCR + 1
      IF (INCR .LE. N) GOTO 10
C
C        Loop : Shell-Metzner sort
C
   20 INCR = INCR / 3
      I = INCR + 1
   30 IF (I .GT. N) GOTO 60
      TEMP = X(I)
      J = I
   40 IF (X(J - INCR) .LT. TEMP) GOTO 50
      X(J) = X(J - INCR)
      J = J - INCR
      IF (J .GT. INCR) GOTO 40
   50 X(J) = TEMP
      I = I + 1
      GOTO 30
   60 IF (INCR .GT. 1) GOTO 20
C
      RETURN
      END
