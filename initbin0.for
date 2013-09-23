      SUBROUTINE INITBIN0
C
C**********************************************************************C
C
C M.R. MORTON    07 JUN 1999
C
C **  LAST MODIFIED BY JOHN HAMRICK AND MIKE MORTON ON 8 AUGUST 2001
C
C **  THIS SUBROUTINE IS PART OF  EFDC-FULL VERSION 1.0a 
C
C **  LAST MODIFIED BY JOHN HAMRICK ON 1 NOVEMBER 2001
C
C----------------------------------------------------------------------C
C
C CHANGE RECORD
C DATE MODIFIED     BY                 DATE APPROVED    BY
C
C----------------------------------------------------------------------C
C
C
C**********************************************************************C
C
C INITIALIZES BINARY FILE FOR EFDC OUTPUT.  PLACES CONTROL
C PARAMETERS FOR POST-PROCESSOR IN HEADER SECTION OF BINARY
C FILE HYDTS.BIN FOR HYDRODYNAMIC VARIABLES.
C
C-------------------------------------------------------------------
C
      USE GLOBAL
C
      REAL,SAVE,ALLOCATABLE,DIMENSION(:)::XLON  
      REAL,SAVE,ALLOCATABLE,DIMENSION(:)::YLAT  
C
      PARAMETER(MXPARM=30)
      REAL TEND
C
      INTEGER NPARM, NCELLS
      LOGICAL FEXIST, IS1OPEN, IS2OPEN
      CHARACTER*20 HYNAME(MXPARM)
      CHARACTER*10 HYUNITS(MXPARM)
      CHARACTER*3  HYCODE(MXPARM)
C
      IF(.NOT.ALLOCATED(XLON))THEN
		ALLOCATE(XLON(LCM))
		ALLOCATE(YLAT(LCM))
	    XLON=0.0 
	    YLAT=0.0 
	ENDIF
C
C THE FOLLOWING PARAMETERS ARE SPECIFIED IN EFDC.INP:
C KCHYD    = NUMBER OF VERTICAL LAYERS (FORCED TO 1 HERE)
C NWTMSR   = NUMBER OF TIME STEPS PER DATA DUMP OF HYDRODYNAMIC VARIABLES
C DT       = TIME STEP OF EFDC MODEL IN SECONDS
C LA       = NUMBER OF ACTIVE CELLS + 1 IN MODEL
C TBEGAN   = BEGINNING TIME OF RUN IN DAYS
C
C THE PARAMETER NPARM MUST BE CHANGED IF THE OUTPUT DATA
C IS CHANGED IN SUBROUTINE TMSRBIN:
C NPARM   = NUMBER OF PARAMETERS WRITTEN TO BINARY FILE
C
C NREC0   = NUMBER OF RECORDS WRITTEN TO BINARY FILE (ONE RECORD
C           IS A COMPLETE DATA DUMP FOR TIME INTERVAL NWTMSR)
C
      NPARM = 8
      NCELLS = LA-1
      NREC0 = 0
      TEND = TBEGIN
      KCHYD = 1
      MAXRECL0 = 32
      IF(NPARM .GE. 8)THEN
        MAXRECL0 = NPARM*4
      ENDIF
C
C THE FOLLOWING WATER QUALITY NAMES, UNITS, AND 3-CHARACTER CODES
C SHOULD BE MODIFIED TO MATCH THE PARAMETERS WRITTEN TO THE BINARY
C FILE IN SUBROUTINE TMSRBIN.  THE CHARACTER STRINGS MUST BE
C EXACTLY THE LENGTH SPECIFIED BELOW IN ORDER FOR THE POST-PROCESSOR
C TO WORK CORRECTLY.
C
C BE SURE HYNAME STRINGS ARE EXACTLY 20-CHARACTERS LONG:
C------------------'         1         2'
C------------------'12345678901234567890'
      HYNAME( 1) = 'SURFACE_ELEVATION   '
      HYNAME( 2) = 'WATER_DEPTH         '
      HYNAME( 3) = 'VELOCITY-X          '
      HYNAME( 4) = 'VELOCITY-Y          '
      HYNAME( 5) = 'FLOW-X              '
      HYNAME( 6) = 'FLOW-Y              '
      HYNAME( 7) = 'BOTTOM_ELEVATION    '
      HYNAME( 8) = 'BOTTOM_ROUGHNESS    '
C
C BE SURE HYUNITS STRINGS ARE EXACTLY 10-CHARACTERS LONG:
C-------------------'         1'
C-------------------'1234567890'
      HYUNITS( 1) = 'METERS    '
      HYUNITS( 2) = 'METERS    '
      HYUNITS( 3) = 'CM/SEC    '
      HYUNITS( 4) = 'CM/SEC    '
      HYUNITS( 5) = 'M3/SEC    '
      HYUNITS( 6) = 'M3/SEC    '
      HYUNITS( 7) = 'METERS    '
      HYUNITS( 8) = 'METERS    '
C
C BE SURE HYCODE STRINGS ARE EXACTLY 3-CHARACTERS LONG:
C
C------------------'123'
      HYCODE( 1) = 'SEL'
      HYCODE( 2) = 'DEP'
      HYCODE( 3) = 'VXX'
      HYCODE( 4) = 'VYY'
      HYCODE( 5) = 'QXX'
      HYCODE( 6) = 'QYY'
      HYCODE( 7) = 'BEL'
      HYCODE( 8) = 'ZBR'
C
C---------------------------------------------------------
C
C IF HYDTS.BIN ALREADY EXISTS, OPEN FOR APPENDING HERE.
C
      IF(ISTMSR .EQ. 2)THEN
        IO = 1
5       IO = IO+1
        IF(IO .GT. 99)THEN
          WRITE(0,*) ' NO AVAILABLE IO UNITS ... IO > 99'
          STOP ' EFDC HALTED IN SUBROUTINE INITBIN0'
        ENDIF
        INQUIRE(UNIT=IO, OPENED=IS2OPEN)
        IF(IS2OPEN) GOTO 5
        INQUIRE(FILE='HYDTS.BIN', EXIST=FEXIST)
        IF(FEXIST)THEN
          OPEN(UNIT=IO, FILE='HYDTS.BIN', ACCESS='DIRECT',
     +     FORM='UNFORMATTED', STATUS='UNKNOWN', RECL=MAXRECL4)
          WRITE(0,*) 'OLD FILE HYDTS.BIN FOUND...OPENING FOR APPEND'
          READ(IO, REC=1) NREC0, TBEGAN, TEND, DT, NWTMSR, NPARM,
     +      NCELLS, KCHYD
          NR0 = 1 + NPARM*3 + NCELLS*4 + (NCELLS*KCHYD+1)*NREC0 + 1
          CLOSE(IO)
        ELSE
          ISTMSR=1
        ENDIF
      ENDIF
C
C-------------------------------------------------------------------
C
C IF HYDTS.BIN ALREADY EXISTS, DELETE IT HERE.
C
      IF(ISTMSR .EQ. 1)THEN
        TBEGAN = TBEGIN
        IO = 1
10      IO = IO+1
        IF(IO .GT. 99)THEN
          WRITE(0,*) ' NO AVAILABLE IO UNITS ... IO > 99'
          STOP ' EFDC HALTED IN SUBROUTINE INITBIN0'
        ENDIF
        INQUIRE(UNIT=IO, OPENED=IS2OPEN)
        IF(IS2OPEN) GOTO 10
        INQUIRE(FILE='HYDTS.BIN', EXIST=FEXIST)
        IF(FEXIST)THEN
          OPEN(UNIT=IO, FILE='HYDTS.BIN')
          CLOSE(UNIT=IO, STATUS='DELETE')
          WRITE(0,*) 'OLD FILE HYDTS.BIN DELETED...'
        ENDIF

        OPEN(UNIT=IO, FILE='HYDTS.BIN', ACCESS='DIRECT',
     +     FORM='UNFORMATTED', STATUS='UNKNOWN', RECL=MAXRECL0)
C
C--------------------------------------------------------------------
C WRITE CONTROL PARAMETERS FOR POST-PROCESSOR TO HEADER
C SECTION OF THE HYDTS.BIN BINARY FILE:
C
        WRITE(IO) NREC0, TBEGAN, TEND, DT, NWTMSR, NPARM, NCELLS, KCHYD
        DO I=1,NPARM
          WRITE(IO) HYNAME(I)
        ENDDO
        DO I=1,NPARM
          WRITE(IO) HYUNITS(I)
        ENDDO
        DO I=1,NPARM
          WRITE(IO) HYCODE(I)
        ENDDO
C
C WRITE CELL I,J MAPPING REFERENCE TO HEADER SECTION OF BINARY FILE:
C
        DO L=2,LA
          WRITE(IO) IL(L)
        ENDDO
        DO L=2,LA
          WRITE(IO) JL(L)
        ENDDO
C
C **  READ IN XLON AND YLAT OR UTME AND UTMN OF CELL CENTERS OF
C **  CURVILINEAR PORTION OF THE GRID FROM FILE LXLY.INP:
C
        IO1 = 0
20      IO1 = IO1+1
        IF(IO1 .GT. 99)THEN
          WRITE(0,*) ' NO AVAILABLE IO UNITS ... IO1 > 99'
          STOP ' EFDC HALTED IN SUBROUTINE INITBIN0'
        ENDIF
        INQUIRE(UNIT=IO1, OPENED=IS1OPEN)
        IF(IS1OPEN) GOTO 20
        OPEN(IO1,FILE='LXLY.INP',STATUS='UNKNOWN')
C
        DO NS=1,4
          READ(IO1,1111)
        ENDDO
 1111   FORMAT(80X)
C
        DO LL=2,LA
          READ(IO1,*) I,J,XUTME,YUTMN
          L=LIJ(I,J)
          XLON(L)=XUTME
          YLAT(L)=YUTMN
        ENDDO
        CLOSE(IO1)
C
C WRITE XLON AND YLAT OF CELL CENTERS TO HEADER SECTION OF
C BINARY OUTPUT FILE:
C
        DO L=2,LA
          WRITE(IO) XLON(L)
        ENDDO
        DO L=2,LA
          WRITE(IO) YLAT(L)
        ENDDO

        INQUIRE(UNIT=IO, NEXTREC=NR0)
        CLOSE(IO)
      ENDIF
C
      RETURN
      END