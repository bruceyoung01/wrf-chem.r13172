!  $ID: READ_TEXT_MOD.F90 V01 07/27/2017 23:33 ZHIFENG YANG EXP$
!
!******************************************************************************
!  MODULE READ_TEXT_MOD.F90 INCLUDES SUBROUTINES READING VARIOUS
!  OBSERVATIONS WITH TEXT FILE FORMAT (ASCII FILE). HERE IS THE LIST
!  OF OBSERVATIONS IT CAN READ.
!
!  SUBROUTINES:
!  ============================================================================
!  (1 ) READ_TOLNET : READS OBSERVATIONS FROM TROPOSPHERIC OZONE LIDAR NETWORK
!                     FILE NAME SAMPLE: TOLNet-O3Lidar_HUBV_20150610_R0.dat
!
!  NOTES:
!  ============================================================================
!  (1 ) ORIGINALLY WRITTEN BY ZHIFENG YANG. (07/27/2017)
!******************************************************************************

      MODULE READ_TEXT_MOD

      ! USE OTHER MODULES


      ! FORCE ALL VARIABLES TO BE DECLARED EXPLICITLY
      IMPLICIT NONE


      !=================================================================
      ! MODULE PRIVATE DECLARATIONS -- KEEP CERTAIN INTERNAL VARIABLES
      ! AND ROUTINES FROM BEING SEEN OUTSIDE 'READ_OBS_'

!@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
!  SUBROUTINE READ_TOLNET READS TEXT FILE OBSERVATIONS FROM 
!  TROPOSPHERIC OZONE LIDAR NETWORK, GETS THE ESSENTIAL INFO FOR DART 
!  TO WRITE AS DART FORMAT.
!@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
      SUBROUTINE OBS_TO_SEQ_TOLNET

      
      LOGICAL        :: FILE_EXIST, FILE_OPEN
      INQUIRE (UNIT = 10, EXIST = FILE_EXIST, OPENED = FILE_OPEN)





      END MODULE READ_TEXT_MOD
