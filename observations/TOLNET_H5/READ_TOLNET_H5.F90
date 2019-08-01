! $ID: READ_TOLNET_H5.F90 V01 07/19/2019 09:53 ZHIFENG YANG EXP$
!
!******************************************************************************
!  PROGRAM READ_TOLNET_H5.F90 READS TOLNET UNIFIED H5 FILE. CURRENYLY, IT IS 
!  DESIGNED TO READ TROPOZ AND LARC LMOL OZONE LIDAR.
!
!  FLOW CHART:
!  ============================================================================
!  (1 )
!
!  NOTES:
!  ============================================================================
!  (1 ) ORIGINALLY WRITTEN BY ZHIFENG YANG. (07/19/2019)
!  (2 ) NOTE ON OPENING H5 FILE ACCESS MODES
!       Table 1. Access flags and modes
!       Access Flag     Resulting Access Mode
!       H5F_ACC_EXCL    If the file already exists, H5Fcreate fails. 
!                       If the file does not exist, it is created and opened 
!                       with read-write access. (Default)
!       H5F_ACC_TRUNC   If the file already exists, the file is opened with
!                       read-write access, and new data will overwrite any 
!                       existing data. If the file does not exist, it is 
!                       created and opened with read-write access.
!       H5F_ACC_RDONLY  An existing file is opened with read-only access. 
!                       If the file does not exist, H5Fopen fails. (Default)
!       H5F_ACC_RDWR    An existing file is opened with read-write access. If
!                       the file does not exist, H5Fopen fails.
!       REFERENCE: 
!                 https://support.hdfgroup.org/HDF5/doc/UG/FmSource/          &
!                 08_TheFile_favicon_test.html#FileAccessModes
!
!******************************************************************************

      PROGRAM READ_TOLNET_H5

      ! USE OTHER MODULES
      USE HDF5

      ! FORCE ALL VARIABLES TO BE DECLARED EXPLICITLY
      IMPLICIT NONE

      !================================================================
      ! PARAMETER
      !================================================================

      ! YEAR, MONTH, AND DAY
      INTEGER, PARAMETER                 :: START_YEAR  = 2018 
      INTEGER, PARAMETER                 :: END_YEAR    = 2018
      INTEGER, PARAMETER                 :: START_MONTH = 6
      INTEGER, PARAMETER                 :: END_MONTH   = 6
      INTEGER, PARAMETER                 :: START_DAY   = 29
      INTEGER, PARAMETER                 :: END_DAY     = 29

      !================================================================
      ! CHARACTER
      !================================================================

      CHARACTER (LEN = 256)              :: TOLNET_DIR
      CHARACTER (LEN = 256)              :: TOLNET_FILENAME
      CHARACTER (LEN = 50 )              :: CYYYYMMDD

      !================================================================
      ! INTEGER
      !================================================================

      ! LOCAL VARIABLES
      INTEGER                            :: IYEAR, IMONTH, IDAY
      ! H5 FILE RELATED VARIABLES
      INTEGER*8                          :: FILE_ID
      INTEGER*4                          :: ERROR



      ! SPECIFY TOLNET DATA FILE DIRECTORY
      TOLNET_DIR = '/home/vy57456/zzbatmos_user/data/owlets2/'//       &
                   'OWLETS2-Data/UMBC/'//                              &
                   'NASA_GSFC_TROPospheric_Ozone_TROPOZ_DIAL/'
      PRINT *, TOLNET_DIR

      ! DO YEAR LOOP
      DO IYEAR = START_YEAR, END_YEAR
         ! DO MONTH LOOP
         DO IMONTH = START_MONTH, END_MONTH
            ! DO DAY LOOP
            DO IDAY = START_DAY, END_DAY
               ! BUILD TOLNET FILE NAME
               WRITE(CYYYYMMDD, 100) IYEAR, IMONTH, IDAY
100            FORMAT(I4.4, I2.2, I2.2)
               TOLNET_FILENAME =TOLNET_DIR(1:LEN_TRIM(TOLNET_DIR))//   &
                                'owlets2-UMBC-TROPOZ-GSFC_Ozone-Lidar_'&
                                 //CYYYYMMDD(1: LEN_TRIM(CYYYYMMDD))// &
                                 '_R0.h5'
      PRINT *, TOLNET_FILENAME
               ! OPEN TOLNET H5 FILE
               CALL H5FOPEN_F (TOLNET_FILENAME, H5F_ACC_RDWR_F,        &
                               FILE_ID, ERROR)
            ENDDO !IYEAR
         ENDDO !IMONTH
      ENDDO !IDAY

      END PROGRAM READ_TOLNET_H5
