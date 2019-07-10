!  $ID: TEXT_TO_OBS_TROPOZ.f90 V01 06/17/2019 15:17 ZHIFENG YANG EXP$
!
!******************************************************************************
!  PROGRAM TEXT_TO_OBS_TROPOZ.f90 READS OBSERVATION DATA IN TEXT FILE FORMAT 
!  TO GET SITE INFO AND OBSERVATION, WHICH ARE THE REQUIREMENT OF DART. 
!  THE INFO INCLUDES 
!  (1 ) LATITUDE;
!  (2 ) LONGITUDE;
!  (3 ) ELEVATION;
!  (4 ) DATE ADN TIME: YEAR, MONTH, DAY, HOUR, MINUTE, SECOND;
!  (5 ) ACTUAL OBSERVATION VALUES;
!  (6 ) ERROR ESTIMATE (OPTIONAL)
!
!  THEN CONVERTS OBSERVATION DATA INTO THE DART READABLE FORMAT.
!
!  FLOW CHART:
!  ============================================================================
!  (1 )
!
!  NOTES:
!  ============================================================================
!  (1 ) MODIFIED FROM DART /observations/text/text_to_obs.f90 
!       BY ZHIFENG YANG. (06/17/2019)
!******************************************************************************


      PROGRAM TEXT_TO_OBS_TROPOZ

      USE    types_mod,        ONLY : r8,                       &
                                      PI,                       &
                                      DEG2RAD
      USE    utilities_mod,    ONLY : initialize_utilities,     &
                                      finalize_utilities,       &
                                      open_file,                &
                                      close_file
      USE    time_manager_mod, ONLY : time_type,                &
                                      set_calendar_type,        &
                                      set_date,                 &
                                      operator(>=),             &
                                      operator(-),              &
                                      operator(+),              &
                                      increment_time,           &
                                      get_time,                 &
                                      GREGORIAN,                &
                                      print_date,               &
                                      DAYS_IN_MONTH
      USE    location_mod,     ONLY : VERTISHEIGHT,             &
                                      VERTISPRESSURE
      USE    obs_sequence_mod, ONLY : obs_sequence_type,        &
                                      obs_type,                 &
                                      read_obs_seq,             &
                                      static_init_obs_sequence, &
                                      init_obs,                 &
                                      write_obs_seq,            &
                                      init_obs_sequence,        &
                                      get_num_obs,              &
                                      set_copy_meta_data,       &
                                      set_qc_meta_data
      USE    obs_kind_mod,     ONLY : EVAL_U_WIND_COMPONENT,    &
                                      EVAL_V_WIND_COMPONENT,    &
                                      EVAL_TEMPERATURE

      ! FORCE ALL VARIABLES TO BE DECLARED EXPLICITLY
      IMPLICIT NONE

      CHARACTER (LEN = 256), PARAMETER :: DATA_DIR        =     &
      '/home/vy57456/zzbatmos_user/data/beltsville/tropoz/'
      CHARACTER (LEN = 64 )            :: TEXT_INPUT_FILE
      CHARACTER (LEN = 64 ), PARAMETER :: OBS_OUT_FILE    =     &
                                          'obs_seq.out'

      ! SET TO .TRUE. TO PRINT DEBUG INFO
      LOGICAL,              PARAMETER :: DEBUG = .TRUE.

      CHARACTER (LEN = 64)            :: INPUT_LINE

      INTEGER     :: ODAY, OSEC, RCIO, IUNIT, OTYPE
      INTEGER     :: NUM_COPIES, NUM_QC, MAX_OBS

      LOGICAL     :: FILE_EXIST, FIRST_OBS

      ! DATE AND TIME SPECIFIED FOR BUILDING TEXT FILE NAME AND READING 
      ! TEXT FILE
      INTEGER     :: IYEAR, IMONTH, IDAY
      INTEGER     :: NDAYS_IN_MONTH

      ! CONVERT IYEAR, IMONTH, IDAY INTO CHARACTER
      CHARACTER (LEN = 64)   :: CDATE

      ! ---------------------------------------------------------------
      ! PARAMETER VARIABLES NEED TO READ FROM TEXT FILE
      ! ---------------------------------------------------------------

      ! NUMBER OF GENERAL HEADER LINES (AFTER THIS LINE)
      INTEGER     :: NLINE_HEADER

      ! NUMBER OF PROFILES IN THIS FILE
      INTEGER     :: NPROFILE

      ! NUMBER OF GENERAL COMMENTS LINES (AFTER THIS LINE)
      INTEGER     :: NLINE_COMMENT

      ! NUMBER OF HEADER LINES IN THIS PROFILE"S HEADER 
      ! (AFTER THIS LINE)
      INTEGER     :: NLINE_HEADER_PROFILE

      ! NUMBER OF DATA LINES IN THIS PROFILE
      INTEGER     :: NLINE_PROFILE

      ! INTEGERS DEFINED FOR LOOPS
      INTEGER     :: ILINE_HEADER, ILINE_COMMENT, ILINE
      INTEGER     :: ILINE_HEADER_PROFILE, IPROFILE, ILINE_PROFILE

      ! PROFILE DATE, TIME (UT) MEAN
      CHARACTER (LEN = 64)   :: CDATE_MEAN, CTIME_MEAN
      ! DATE, TIME (UT) MEAN CONVERTED FROM CDATE_MEAN, CTIME_MEAN
      INTEGER     :: YEAR_MEAN, MONTH_MEAN, DAY_MEAN, &
                     HOUR_MEAN, MINUTE_MEAN, SECOND_MEAN

      ! ---------------------------------------------------------------
      ! VARIABLES TO BE READ FROM TEXT FILE
      ! ---------------------------------------------------------------

      ! LOCATION, ELEVATION
      REAL (R8)   :: LAT, LON, ELE

      ! ----------------------------------
      ! VARIABLES USED TO READ VALUES AS CHARACTER
      ! ----------------------------------

      CHARACTER (LEN = 64)  :: CALT_TMP, CO3ND_TMP,          &
                               CO3NDUNCERT_TMP,              &
                               CO3NDRESOL_TMP,               &
                               CQC_TMP, CCHRANGE_TMP,        &
                               CO3MR_TMP, CO3MRUNCERT_TMP,   &
                               CPRESS_TMP, CPRESSUNCERT_TMP, &
                               CTEMP_TMP, CTEMPUNCERT_TMP,   &
                               CAIRND_TMP, CAIRNDUNCERT_TMP
      ! ALTITUDE
      CHARACTER (LEN = 64)                :: AALT
      CHARACTER (LEN = 64), ALLOCATABLE   :: CALT(:)

      ! OZONE NUMBER DENSITY
      CHARACTER (LEN = 64), ALLOCATABLE   :: CO3ND(:),  CO3NDUNCERT(:)

      ! PRECISION AND CHANNEL RANGE
      CHARACTER (LEN = 64), ALLOCATABLE   :: CQC(:),    CCHRANGE(:)
      ! OZONE MIXING RATIO
      CHARACTER (LEN = 64), ALLOCATABLE   :: CO3MR(:),  CO3MRUNCERT(:)

      ! PRESSURE
      CHARACTER (LEN = 64), ALLOCATABLE   :: CPRESS(:), CPRESSUNCERT(:)

      ! TMPERATURE
      CHARACTER (LEN = 64), ALLOCATABLE   :: CTEMP(:),  CTEMPUNCERT(:)

      ! AIR NUMBER DENSITY
      CHARACTER (LEN = 64), ALLOCATABLE   :: CAIRND(:), CAIRNDUNCERT(:)

      ! ALTITUDE
      REAL (R8)                :: ALT_TMP, O3ND_TMP,             &
                                  O3NDUNCERT_TMP,                &
                                  O3NDRESOL_TMP,                 &
                                  QC_TMP, CHRANGE_TMP,           &
                                  O3MR_TMP, O3MRUNCERT_TMP,      &
                                  PRESS_TMP, PRESSUNCERT_TMP,    &
                                  TEMP_TMP, TEMPUNCERT_TMP,      &
                                  AIRND_TMP, AIRNDUNCERT_TMP
      REAL (R8), ALLOCATABLE   :: ALT(:)
      !REAL (R8), DIMENSION(121)   :: ALT


      ! OZONE NUMBER DENSITY
      REAL (R8), ALLOCATABLE   :: O3ND(:),  O3NDUNCERT(:), O3NDRESOL(:)

      ! PRECISION AND CHANNEL RANGE
      REAL (R8), ALLOCATABLE   :: QC(:),    CHRANGE(:)
      ! OZONE MIXING RATIO
      REAL (R8), ALLOCATABLE   :: O3MR(:),  O3MRUNCERT(:)

      ! PRESSURE
      REAL (R8), ALLOCATABLE   :: PRESS(:), PRESSUNCERT(:)

      ! TMPERATURE
      REAL (R8), ALLOCATABLE   :: TEMP(:),  TEMPUNCERT(:)

      ! AIR NUMBER DENSITY
      REAL (R8), ALLOCATABLE   :: AIRND(:), AIRNDUNCERT(:)

      TYPE (OBS_SEQUENCE_TYPE)        :: OBS_SEQ
      TYPE (OBS_TYPE         )        :: OBS, PREV_OBS
      TYPE (TIME_TYPE        )        :: REF_DAY0, TIME_OBS, PREV_TIME

      ! DEFINE TIME_TYPE VARIABLE TO HELP CALCULATE DAYS IN MONTH
      TYPE (TIME_TYPE        )        :: ITIME

      ! ---------------------------------------------------------------
      ! VARIABLES RELATED TO CREATING obs_seq FILE
      ! ---------------------------------------------------------------

      INTEGER     :: ILEVEL


      ! ---------------------------------------------------------------
      ! READ NAMELIST TO GET START DATE AND END TIME
      ! ---------------------------------------------------------------

      INTEGER     :: START_YEAR, START_MONTH, START_DAY
      INTEGER     :: END_YEAR,   END_MONTH,   END_DAY
      !NAMELIST /time_control/ START_YEAR, START_MONTH, START_DAY, &
      !                        END_YEAR,   END_MONTH,   END_DAY
      START_YEAR  = 2015
      START_MONTH = 06
      START_DAY   = 10
      END_YEAR    = 2015
      END_MONTH   = 06
      END_DAY     = 12
      
      ! START OF EXECUTABLE CODE

      CALL INITIALIZE_UTILITIES ('TEXT_TO_OBS_TROPOZ')

      ! TIME SETUP
      CALL SET_CALENDAR_TYPE (GREGORIAN)

      ! SOME TIMES ARE SUPPLIED AS NUMBER OF SECONDS SINCE SOME 
      ! REFERENCE DATE. TO SUPPORT THAT, SET A BASE/REFERENCE TIME AND
      ! THEN ADD THE NUMBER OF SECONDS TO IT. (TIME_TYPES SUPPORT ADDING
      ! TWO TIME TYPES TOGETHER, OR ADDING A SCALAR TO A TIME_TYPE)
      ! HERE IS AN EXAMPLE OF SETTING A REFERENCE DATE, GIVING THE CALL:
      ! YEAR, MONTH, DAY, HOURS, MINS, SECS
      ! REF_DAY0 = SET_DATE(1970, 1, 1, 0, 0, 0)

      ! EACH OBSERVATION IN THIS SERIES WILL HAVE A SINGLE OBSERVATION
      ! VALUE AND A QUALITY CONTROL FLAG. THE MAX POSSIBLE NUMBER OF 
      ! OBS NEEDS TO BE SPECIFIED BUT IT WILL ONLY WRITE OUT THE ACTUAL
      ! NUMBER CREATED.

      MAX_OBS    = 100000
      NUM_COPIES = 1
      NUM_QC     = 1

      ! CALL THE INITIALIZATION CODE, AND INITIALIZE TWO EMPTY
      ! OBSERVATION TYPES
      CALL STATIC_INIT_OBS_SEQUENCE()
      CALL INIT_OBS(OBS,      NUM_COPIES, NUM_QC)
      CALL INIT_OBS(PREV_OBS, NUM_COPIES, NUM_QC)

      FIRST_OBS = .TRUE.

      ! CREATE A NEW, EMPTY OBS_SEQ FILE, YOU MUST GIVE A MAX LIMIT 
      ! ON NUMBER OF OBS. INCREASE THE SIZE IF TOO SMALL
      CALL INIT_OBS_SEQUENCE(OBS_SEQ, NUM_COPIES, NUM_QC, MAX_OBS)

      ! THE FIRST ONE NEEDS TO CONTAIN THE STRING 'observation' AND 
      ! THE SECOND NEEDS THE STRING 'QC'.
      CALL SET_COPY_META_DATA(OBS_SEQ, 1, 'observation')
      CALL SET_QC_META_DATA  (OBS_SEQ, 1, 'Data QC'    )

      ! IF YOU WANT TO APPEND TO EXISTING FILES (e.g. YOU HAVE A LOT 
      ! OF SMALL TEXT FILES YOU WANT TO COMBINE), YOU CAN DO IT THIS 
      ! WAY, OR YOU CAN USE THE OBS_SEQUENCE TOOL TO MERGE A LIST OF 
      ! FILES ONCE THEY ARE IN DART OBS_SEQ FORMAT.

      ! EXISTING FILE FOUND, APPEND TO IT
      !INQUIRE(FILE = OBS_OUT_FILE, EXIST = FILE_EXIST)
      !IF (FILE_EXIST) THEN
      !   CALL READ_OBS_SEQ(OBS_OUT_FILE, 0, 0, MAX_OBS, OBS_SEQ)
      !ENDIF

      ! SET THE DART DATA QUALITY CONTROL. 0 IS GOOD DATA.
      ! INCREASINGLY LARGER QC VALUES ARE MORE QUESTIONABLE QUALITY 
      ! DATA.

      ! DO IYEAR, IMONTH, AND IDAY LOOP
      DO IYEAR = START_YEAR, END_YEAR

         DO IMONTH = START_MONTH, END_MONTH

      ! PUT DATE INTO A DART TIME FORMAT TO CALCULATE days_in_month
            ITIME          = SET_DATE(IYEAR, IMONTH, 1)
            NDAYS_IN_MONTH = DAYS_IN_MONTH(ITIME)
            IF (DEBUG) PRINT *, 'NDAYS_IN_MONTH = ', NDAYS_IN_MONTH,   &
                                'IN ', IYEAR, ' ', IMONTH
            DO IDAY = 10, 12!START_DAY, NDAYS_IN_MONTH

      ! BUILD DATA FILE NAME BASED ON DATE
               WRITE(CDATE, 110) IYEAR, IMONTH, IDAY
110            FORMAT(I4.4I2.2I2.2)
               TEXT_INPUT_FILE = 'TOLNet-O3Lidar_HUBV_' // TRIM(CDATE) &
                                 // '_R0.dat'
      ! OPEN INPUT TEXT FILE

               IUNIT = OPEN_FILE(TRIM(DATA_DIR)//TEXT_INPUT_FILE,      &
                       'FORMATTED', 'READ')
               IF (DEBUG) PRINT *, 'OPENED INPUT FILE ' //             &
                                   TRIM(TEXT_INPUT_FILE)

      ! READ THE LINE 1 TO GET NUMBER OF GENERAL HEADER LINES 
      ! (AFTER THIS LINE):LINE 1
               READ(IUNIT, *) NLINE_HEADER
      ! SKIP LINE 2
               READ(IUNIT, *)
      ! READ NUMBER OF PROFILES IN THIS FILE: LINE 3
               READ(IUNIT, *) NPROFILE

      ! SKIP GENERAL HEADER LINES:LINE 2-19
               DO ILINE_HEADER = 1, NLINE_HEADER-2
                  READ(IUNIT, *)
               END DO !ILINE_HEADER

      ! READ LINE 20 TO GET NUMBER OF GENERAL COMMENTS LINES: LINE 20
               READ(IUNIT, *) NLINE_COMMENT
      ! SKIP PARTS OF GENERAL COMMENT LINES: LINE 21-23
               DO ILINE_COMMENT = 1, NLINE_COMMENT-2
                  READ(IUNIT, *)
               END DO !ILINE_COMMENT
      ! READ LONGITUDE(DegE), LATITUDE(DegN), AND ELEVATION(m): LINE 24
               READ(IUNIT, *) LON, LAT, ELE
               IF (DEBUG) PRINT *, 'LON, LAT, ELE = ', LON, LAT, ELE

      ! SKIP THE LAST LINE OF GENERAL COMMENT LINE AND '#BEGIN PROFILE'
               READ(IUNIT, *) !LINE 25

      ! DO IPROFILE LOOP
               DO IPROFILE = 1, NPROFILE
                  READ(IUNIT, *) !LINE 26 + IPROFILE*
                                 !(NLINE_HEADER_PROFILE+NPROFILE)

      ! READ NUMBER OF HEADER LINES IN THIS PROFILE'S HEADER 
      !(AFTER THIS LINE): LINE 27
                  READ(IUNIT, *) NLINE_HEADER_PROFILE
                  IF (DEBUG) PRINT *, 'NLINE_HEADER_PROFILE = ', &
                                       NLINE_HEADER_PROFILE
      ! READ NUMBER OF DATA LINES IN THIS PROFILE: LINE 28
                  READ(IUNIT, *) NLINE_PROFILE
                  IF (DEBUG) PRINT *, 'NLINE_PROFILE = ',        &
                                       NLINE_PROFILE

      ! SINCE WE ALREADY KNOW THE ARRAY SIZE (NLINE_PROFILE), ALLOCATE
                  ALLOCATE(ALT        (NLINE_PROFILE))
                  ALLOCATE(O3ND       (NLINE_PROFILE))
                  ALLOCATE(O3NDUNCERT (NLINE_PROFILE))
                  ALLOCATE(O3NDRESOL  (NLINE_PROFILE))
                  ALLOCATE(QC         (NLINE_PROFILE))
                  ALLOCATE(CHRANGE    (NLINE_PROFILE))
                  ALLOCATE(O3MR       (NLINE_PROFILE))
                  ALLOCATE(O3MRUNCERT (NLINE_PROFILE))
                  ALLOCATE(PRESS      (NLINE_PROFILE))
                  ALLOCATE(PRESSUNCERT(NLINE_PROFILE))
                  ALLOCATE(TEMP       (NLINE_PROFILE))
                  ALLOCATE(TEMPUNCERT (NLINE_PROFILE))
                  ALLOCATE(AIRND      (NLINE_PROFILE))
                  ALLOCATE(AIRNDUNCERT(NLINE_PROFILE))
      ! SKIP LINE 29-33
                  DO ILINE = 1, 5
                     READ(IUNIT, *)
                  END DO !ILINE
      ! READ PROFILE DATE, TIME MEAN: LINE 34
                  READ(IUNIT, *) CDATE_MEAN, CTIME_MEAN
                  IF (DEBUG) PRINT *, 'CDATE_MEAN, CTIME_MEAN = ', &
                                  TRIM(CDATE_MEAN),' ', TRIM(CTIME_MEAN)

      ! ---------------------------------------------------------------
      ! CONVERT TIME CHARACTER TO INTEGER
      ! ---------------------------------------------------------------

                  READ (CDATE_MEAN(1:4 ), *) YEAR_MEAN
                  READ (CDATE_MEAN(6:7 ), *) MONTH_MEAN
                  READ (CDATE_MEAN(9:10), *) DAY_MEAN
                  READ (CTIME_MEAN(1:2 ), *) HOUR_MEAN
                  READ (CTIME_MEAN(4:5 ), *) MINUTE_MEAN
                  READ (CTIME_MEAN(7:8 ), *) SECOND_MEAN
                  PRINT '(A17, I4.4, A1, 4(I2.2, A1), I2.2)',  &
                        'NOW WORKING ON = ', YEAR_MEAN,   '-', &
                                             MONTH_MEAN,  '-', &
                                             DAY_MEAN,    ' ', &
                                             HOUR_MEAN,   ':', &
                                             MINUTE_MEAN, ':', &
                                             SECOND_MEAN
                  
      ! PUT DATE INTO A DART TIME FORMAT
                  TIME_OBS = SET_DATE(YEAR_MEAN, MONTH_MEAN,   &
                                      DAY_MEAN,  HOUR_MEAN,    &
                                      MINUTE_MEAN, SECOND_MEAN)
                  IF (DEBUG) CALL PRINT_DATE(TIME_OBS,         &
                                             'next obs time is ')

      ! IF TIME IS GIVEN IN SECONDS SINCE SOME DATE, HERE'S HOW TO 
      ! ADD IT.
                  !TIME_OBS = REF_DAY0 + TIME_OBS

      ! EXTRACT TIME OF OBSERVATION INTO GREGORIAN DAY, SEC.
                  CALL GET_TIME(TIME_OBS, OSEC, ODAY)

      ! SKIP LINE 35-40
                  DO ILINE = 1, 6
                     READ(IUNIT, *)
                  END DO
      ! READ ALL THE MEASUREMENTS NOW
                  DO ILINE_PROFILE = 1, NLINE_PROFILE
                     READ(IUNIT, *, IOSTAT = RCIO) &
                     CALT_TMP, CO3ND_TMP,          &
                     CO3NDUNCERT_TMP,              &
                     CO3NDRESOL_TMP,               &
                     CQC_TMP, CCHRANGE_TMP,        &
                     CO3MR_TMP, CO3MRUNCERT_TMP,   &
                     CPRESS_TMP, CPRESSUNCERT_TMP, &
                     CTEMP_TMP, CTEMPUNCERT_TMP,   &
                     CAIRND_TMP, CAIRNDUNCERT_TMP

                     IF (RCIO /= 0) THEN
                        IF (DEBUG) PRINT *, 'got bad read code '    // &
                                            'getting rest of ozone '// &
                                            'obs, rcio = ', RCIO
                        EXIT
                     ENDIF

                     IF (TRIM(CALT_TMP) .NE. 'NaN') &
                     READ (CALT_TMP, *)ALT_TMP
                     ALT        (ILINE_PROFILE) = ALT_TMP

                     IF (TRIM(CO3ND_TMP) .NE. 'NaN') &
                     READ (CO3ND_TMP, *)O3ND_TMP
                     O3ND       (ILINE_PROFILE) = O3ND_TMP

                     IF (TRIM(CO3NDUNCERT_TMP) .NE. 'NaN') &
                     READ (CO3NDUNCERT_TMP, *)O3NDUNCERT_TMP
                     O3NDUNCERT (ILINE_PROFILE) = O3NDUNCERT_TMP

                     PRINT *, CO3NDRESOL_TMP
                     IF (TRIM(CO3NDRESOL_TMP) .NE. 'NaN') &
                     READ (CO3NDRESOL_TMP, *)O3NDRESOL_TMP
                     O3NDRESOL  (ILINE_PROFILE) = O3NDRESOL_TMP

                     IF (TRIM(CQC_TMP) .NE. 'NaN') &
                     READ (CQC_TMP, *)QC_TMP
                     QC         (ILINE_PROFILE) = QC_TMP

                     IF (TRIM(CCHRANGE_TMP) .NE. 'NaN') &
                     READ (CCHRANGE_TMP, *)CHRANGE_TMP
                     CHRANGE    (ILINE_PROFILE) = CHRANGE_TMP

                     IF (TRIM(CO3MR_TMP) .NE. 'NaN') &
                     READ (CO3MR_TMP, *)O3MR_TMP
                     O3MR       (ILINE_PROFILE) = O3MR_TMP

                     IF (TRIM(CO3MRUNCERT_TMP) .NE. 'NaN') &
                     READ (CO3MRUNCERT_TMP, *)O3MRUNCERT_TMP
                     O3MRUNCERT (ILINE_PROFILE) = O3MRUNCERT_TMP

                     IF (TRIM(CPRESS_TMP) .NE. 'NaN') &
                     READ (CPRESS_TMP, *)PRESS_TMP
                     PRESS      (ILINE_PROFILE) = PRESS_TMP

                     IF (TRIM(CPRESSUNCERT_TMP) .NE. 'NaN') &
                     READ (CPRESSUNCERT_TMP, *)PRESSUNCERT_TMP
                     PRESSUNCERT(ILINE_PROFILE) = PRESSUNCERT_TMP

                     IF (TRIM(CTEMP_TMP) .NE. 'NaN') &
                     READ (CTEMP_TMP, *)TEMP_TMP
                     TEMP       (ILINE_PROFILE) = TEMP_TMP

                     IF (TRIM(CTEMPUNCERT_TMP) .NE. 'NaN') &
                     READ (CTEMPUNCERT_TMP, *)TEMPUNCERT_TMP
                     TEMPUNCERT (ILINE_PROFILE) = TEMPUNCERT_TMP

                     IF (TRIM(CAIRND_TMP) .NE. 'NaN') &
                     READ (CAIRND_TMP, *)AIRND_TMP
                     AIRND      (ILINE_PROFILE) = AIRND_TMP

                     IF (TRIM(CAIRNDUNCERT_TMP) .NE. 'NaN') &
                     READ (CAIRNDUNCERT_TMP, *)AIRNDUNCERT_TMP
                     AIRNDUNCERT(ILINE_PROFILE) = AIRNDUNCERT_TMP
                     IF (DEBUG) PRINT '(A4, 14(E15.6, 1X))',&
                                'DA= ',                     &
                                ALT        (ILINE_PROFILE), &
                                O3ND       (ILINE_PROFILE), &
                                O3NDUNCERT (ILINE_PROFILE), &
                                O3NDRESOL  (ILINE_PROFILE), &
                                QC         (ILINE_PROFILE), &
                                CHRANGE    (ILINE_PROFILE), &
                                O3MR       (ILINE_PROFILE), &
                                O3MRUNCERT (ILINE_PROFILE), &
                                PRESS      (ILINE_PROFILE), &
                                PRESSUNCERT(ILINE_PROFILE), &
                                TEMP       (ILINE_PROFILE), &
                                TEMPUNCERT (ILINE_PROFILE), &
                                AIRND      (ILINE_PROFILE), &
                                AIRNDUNCERT(ILINE_PROFILE)

                  ! HEIGHT IS IN METERS ()
                  ! MAKE AN OBS DERIVED TYPE, AND THEN ADD IT TO THE
                  ! SEQUENCE
!                 CALL CREATE_3D_OBS (LAT, LON, ALT_TMP, VERTISHEIGHT, &
!                                     O3MR, )
                  END DO !ILINE_PROFILE
!                 IF (DEBUG) PRINT *, 'ALT         = ', AALT!,         &
!                                      'PRESSUNCERT = ', CPRESSUNCERT
      ! NO END LIMIT - HAVE THE LOOP BREAK THEN INPUT ENDS

      ! ---------------------------------------------------------------
      ! START TO WRITE OZONE LIDAR DATA INTO DART obs_seq FORMAT
      ! THIS IS ONLY FOR ONE PROFILE THAT JUST READ ABOVE.
      ! ---------------------------------------------------------------

      ! NOW DO LEVEL LOOP FOR OBSERVATIONS IN THIS PROFILE
                  LEVEL_LOOP: DO ILEVEL = 1, NLINE_PROFILE
                     ! CALL SUBROUTINE CREATE_3D_OBS TO CREATE 
                     ! OBSERVATION TYPE FROM OZONE LIDAR DATA
                     CALL CREATE_3D_OBS (LAT, LON, ALT(ILEVEL), &
                                         VERTISHEIGHT, )







                  END DO LELVE_LOOP
      !
                  DEALLOCATE(ALT        )
                  DEALLOCATE(O3ND       )
                  DEALLOCATE(O3NDUNCERT )
                  DEALLOCATE(O3NDRESOL  )
                  DEALLOCATE(QC         )
                  DEALLOCATE(CHRANGE    )
                  DEALLOCATE(O3MR       )
                  DEALLOCATE(O3MRUNCERT )
                  DEALLOCATE(PRESS      )
                  DEALLOCATE(PRESSUNCERT)
                  DEALLOCATE(TEMP       )
                  DEALLOCATE(TEMPUNCERT )
                  DEALLOCATE(AIRND      )
                  DEALLOCATE(AIRNDUNCERT)
               END DO !IPROFILE
               WRITE(*, *) 'WORK HARD!!!'
            END DO !IDAY
         END DO !IMONTH
      END DO !IYEAR

!----------------------------------------------------------------------
!
!  $ID: CREATE_3D_OBS V01 09/08/2017 12:58 EXP$
!
!**********************************************************************
!  SUBROUTINE CREATE_3D_OBS CREATES AN OBSERVATION TYPE FROM 
!  OBSERVATION DATA.
!
!  VARIABLES:
!  ====================================================================
!  (1 ) LAT     (REAL, SCALAR): LATITUDE OF OBSERVATION          [DEG]
!  (2 ) LON     (REAL, SCALAR): LONGITUDE OF OBSERVATION         [DEG]
!  (3 ) VVAL    (REAL, SCALAR): VERTICAL CORRDINATE              [   ]
!  (4 ) VKIND   (INTEGER, SCALAR): KIND OF VERTICAL COORDINATE
!                                  (PRESSURE, LEVEL, ETC)
!  (5 ) OBSV    (REAL, SCALAR): OBSERVATION VALUE                [   ]
!  (6 ) OKIND   (INTEGER, SCALAR): OBSERVATION KIND              [   ]
!  (7 ) OERR    (REAL, SCALAR): OBSERVATION ERROR                [   ]
!  (8 ) DAY     (INTEGER, SCALAR): GREGORIAN DAY                 [   ]
!  (9 ) SEC     (INTEGER, SCALAR): GREGORIAN SECOND              [   ]
!  (10) QC      (REAL, SCALAR): QUALITY CONTROL VALUE            [   ]
!  (11) OBS     (TYPE, SCALAR): OBSERVATION TYPE                 [   ]
!
!  NOTES:
!  ====================================================================
!  (1 ) ASSUMES THE CODE IS USING THE 3-D SPHERE LOCATIONS MODULE, THAT
!       THE OBSERVATION HAS A SINGLE DATA VALUE AND A SINGLE QC VALUE, 
!       AND THAT THIS OBS TYPE HAS NO ADDITIONAL REQUIRED DATA.
!       (E.G. GPS AND RADAR NEED ADDITIONAL DATA PER OBS)
!**********************************************************************
!
      SUBROUTINE CREATE_3D_OBS (LAT, LON, VVAL, VKIND, OBSV, OKIND, &
                                OERR, DAY, SEC, QC, OBS)

      ! REFERENCES TO F90 MODULES
      USE TYPES_MOD,        ONLY : R8
      USE OBS_DEF_MOD,      ONLY : OBS_DEF_TYPE, SET_OBS_DEF_TIME,   &
                                   SET_OBS_DEF_KIND,                 &
                                   SET_OBS_DEF_ERROR_VARIANCE,       &
                                   SET_OBS_DEF_LOCATION
      USE OBS_SEQUENCE_MOD, ONLY : OBS_TYPE, SET_OBS_VALUES, SET_QC, &
                                   SET_OBS_DEF
      USE TIME_MANAGER_MOD, ONLY : TIME_TYPE, SET_TIME
      USE LOCATION_MOD,     ONLY : SET_LOCATION

      ! ARGUMENTS
      INTEGER,        INTENT(IN)    :: OKIND, VKIND, DAY, SEC
      REAL(R8),       INTENT(IN)    :: LAT, LON, VVAL, OBSV, OERR, QC
      TYPE(OBS_TYPE), INTENT(INOUT) :: OBS

      ! LOCAL VARIABLES
      REAL(R8)                      :: OBS_VAL(1), QC_VAL(1)
      TYPE(OBS_DEF_TYPE)            :: OBS_DEF

      ! CALL SUBROUTINE SET_OBS_DEF_LOCATION TO SET THE LOCATION OF AN 
      ! OBS_DEF
      ! INPUT:
      !      OBS_DEF                               --- INTENT(INOUT)
      !      SET_LOCATION (LON, LAT, VVAL, CVKIND) --- INTENT(IN   )
      ! OUTPUT:
      !      OBS_DEF                               --- INTENT(INOUT)
      CALL SET_OBS_DEF_LOCATION (OBS_DEF, SET_LOCATION &
                                (LON, LAT, VVAL, CVKIND))

      ! CALL SUBROUTINE SET_OBS_DEF_KIND TO SET THE KIND OF AN OBS_DEF
      ! INPUT:
      !      OBS_DEF --- INTENT(INOUT)
      !      OKIND   --- INTENT(IN   )
      ! OUTPUT:
      !      OBS_DEF --- INTENT(INOUT)
      CALL SET_OBS_DEF_KIND (OBS_DEF, OKIND)

      ! CALL SUBROUTINE SET_OBS_DEF_TIME TO SET THE TIME OF AN OBS_DEF
      ! INPUT:
      !      OBS_DEF               --- INTENT(INOUT)
      !      SET_TIME (SEC, DAY)   --- INTENT(IN   )
      ! OUTPUT:
      !      OBS_DEF --- INTENT(INOUT)
      CALL SET_OBS_DEF_TIME (OBS_DEF, SET_TIME (SEC, DAY))

      ! CALL SUBROUTINE SET_OBS_DEF_ERROR_VARIANCE TO SET THE ERROR 
      ! VARIANCE OF AN OBS_DEF
      ! INPUT:
      !      OBS_DEF   --- INTENT(INOUT)
      !      OERR*OERR --- INTENT(IN   )
      ! OUTPUT:
      !      OBS_DEF   --- INTENT(INOUT)
      CALL SET_OBS_DEF_ERROR_VARIANCE (OBS_DEF, OERR*OERR)

      ! CALL SUBROUTINE SET_OBS_DEF TO COPY FUNCTION TO BE OVERLOADED
      ! WITH '='. THIS SUBROUTINE ONLY CALLS SUBROUTINE COPY_OBS_DEF.
      ! SO IT HAS THE SAME FUNCTION AS COPY_OBS_DEF.
      ! INPUT:
      !      OBS     --- INTENT(IN )
      ! OUTPUT:
      !      OBS_DEF --- INTENT(OUT)
      CALL SET_OBS_DEF (OBS, OBS_DEF)

      OBS_VAL (1) = OBSV

      ! CALL SUBROUTINE SET_OBS_VALUES TO ASSIGN DATA VALUES TO DERIVED 
      ! TYPE OBS.
      ! INPUT:
      !     VALUES    --- INTENT(IN   )
      !     COPY_INDX --- INTENT(IN   )
      ! OUTPUT
      !     OBS       --- INTENT(INOUT)
      CALL SET_OBS_VALUES (OBS, OBS_VAL)

      QC_VAL (1) = QC

      ! CALL SUBROUTINE SET_QC TO ASSIGN QUALITY CONTROL VARIABLES TO
      ! DERIVED TYPE OBS.
      ! INPUT:
      !      QC_VAL --- INTENT(IN   )
      ! OUTPUT:
      !      OBS    --- INTENT(INOUT)
      CALL SET_QC (OBS, QC_VAL)

      END SUBROUTINE CREATE_3D_OBS

!----------------------------------------------------------------------
!
!  $ID: ADD_OBS_TO_SEQ V01 04/29/2019 13:39 EXP$
!
!**********************************************************************
!  SUBROUTINE ADD_OBS_TO_SEQ ADDS AN OBSERVATION TO A SEQUENCE. INSERTS 
!  IF FIRST OBS, INSERTS WITH A PREV OBS TO SAVE SEARCHING IF THAT'S 
!  POSSIBLE.
!
!  VARIABLES:
!  ====================================================================
!  (1 ) SEQ       (DERIVED     ): OBSERVATION SEQUENCE TO ADD OBS TO 
!                                                                 [   ]
!  (2 ) OBS       (DERIVED     ): OBSERVATION, ALREADY FILLED IN, READY 
!                                 TO ADD                          [   ]
!  (3 ) OBS_TIME  (DERIVED     ): TIME OF THIS OBSERVATION, IN DART 
!                                 TIME_TYPE FORMAT                [   ]
!  (4 ) PREV_OBS  (DERIVED     ): THE PREVIOUS OBSERVATION THAT WAS
!                                 ADDED TO THIS SEQUENCE (WILL BE
!                                 UPDATED BY THIS ROUTINE)        [   ]
!  (5 ) PREV_TIME (DERIVED     ): THE TIME OF THE PREVIOUSLY ADDED
!                                 OBSERVATION (WILL BE UPDATED BY THIS
!                                 ROUTINE)                        [   ]
!  (6 ) FIRST_OBS (LOGICAL     ): SHOULD BE INITIALIZED TO BE .TRUE., 
!                                 AND THEN WILL BE UPDATED BY THIS
!                                 ROUTINE TO BE .FALSE. AFTER THE FIRST 
!                                 OBS HAS BEEN ADDED TO THIS SEQUENCE.
!                                                                 [   ]
!
!  NOTES:
!  ====================================================================
!  (1 ) THIS SUBROUTINE IS ORIGINALLY WRITTEN BY DART TEAM. 
!       CREATED MARCH 8, 2010 NANCY COLLINS, NCAR/IMAGE;
!       (ZHIFENG, 04/29/2019)
!  (2 ) INSERT (SEQ, OBS) ALWAYS WORKS (i.e., IT INSERTS THE OBS IN 
!       PROPER TIME FORMAT) BUT IT CAN BE SLOW WITH A LONG FILE. 
!       SUPPLYING A PREVIOUS OBSERVATION THAT IS OLDER (OR THE SAME 
!       TIME) AS THE NEW ONE SPEEDS UP THE SEARCHING A LOT.
!       (ZHIFENG, 04/29/2019)
!  ====================================================================
      SUBROUTINE ADD_OBS_TO_SEQ (SEQ, OBS, OBS_TIME, PREV_OBS, &
                                 PREV_TIME, FIRST_OBS)

      USE TYPES_MOD,        ONLY : R8
      USE OBS_SEQUENCE_MOD, ONLY : OBS_SEQUENCE_TYPE, OBS_TYPE,
                                   INSERT_OBS_IN_SEQ
      USE TIME_MANAGER_MOD, ONLY : TIME_TYPE, OPERATION (>=)

      TYPE(OBS_SEQUENCE_TYPE), INTENT(INOUT) :: SEQ
      TYPE(OBS_TYPE         ), INTENT(INOUT) :: OBS, PREV_OBS
      TYPE(TIME_TYPE        ), INTENT(IN   ) :: OBS_TIME
      TYPE(TIME_TYPE        ), INTENT(INOUT) :: PREV_TIME
      LOGICAL,                 INTENT(INOUT) :: FIRST_OBS

      ! FOR THE FIRST OBSERVATION, NO PREV_OBS
      IF (FIRST_OBS) THEN
         ! CALL SUBROUTINE INSERT_OBS_IN_SEQ TO INSERT AN OBSERVATION 
         ! INTO A SEQUENCE, OPTIONAL ARGUMENT PREV_OBS SAYS THIS WAS
         ! PREDECESSOR IN TIME. THIS AVOIDS TIME SEARCH IN CASES WHERE
         ! ONE IS BUILDING A SEQUENCE FROM SCRATCH.
         CALL INSERT_OBS_IN_SEQ (SEQ, OBS, PREV_OBS)
         FIRST_OBS = .FALSE.
      ELSE
      ! SAME TIME OR LATER THAN PREVIOUS OBS
         IF (OBS_TIME >= PREV_TIME) THEN
            CALL INSERT_OBS_IN_SEQ (SEQ, OBS, PREV_OBS)
         ELSE
         ! EARLIER, SEARCH FROM START OF SEQ
            CALL INSERT_OBS_IN_SEQ (SEQ, OBS)
         ENDIF
      ENDIF

      ! UPDATE FOR THE NEXT TIME
      PREV_OBS  = OBS
      PREV_TIME = OBS_TIME

      END SUBROUTINE ADD_OBS_TO_SEQ

      END PROGRAM TEXT_TO_OBS_TROPOZ
