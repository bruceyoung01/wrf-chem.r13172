! Copyright 2019 NCAR/ACOM
! 
! Licensed under the Apache License, Version 2.0 (the "License");
! you may not use this file except in compliance with the License.
! You may obtain a copy of the License at
! 
!     http://www.apache.org/licenses/LICENSE-2.0
! 
! Unless required by applicable law or agreed to in writing, software
! distributed under the License is distributed on an "AS IS" BASIS,
! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
! See the License for the specific language governing permissions and
! limitations under the License.
!
! DART $Id: $

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! MODULE MISC_DEFINITIONS_MODULE
!
! This module defines various non-meteorological constants that are used 
!   by other modules for readability.
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

module misc_definitions_module

   integer, parameter :: MAX_FILENAME_LEN = 1024

   real, parameter :: NAN=1.E20

   real, parameter :: NOT_MASKED   = -2.,  &
                      MASKED_BOTH  = -1.,  &
                      MASKED_WATER =  0.,  &
                      MASKED_LAND  =  1.

   integer, parameter :: OUTSIDE_DOMAIN=1E8, NOT_PROCESSED=1E9, INVALID=1E9

   integer, parameter :: SIXTEEN_POINT=1, FOUR_POINT=2, N_NEIGHBOR=3, &
                         AVERAGE4=4, AVERAGE16=5, W_AVERAGE4=6, W_AVERAGE16=7, &
                         SEARCH=8

   integer, parameter :: BOTTOM_TOP=1, TOP_BOTTOM=2

   integer, parameter :: CONTINUOUS=0, CATEGORICAL=1, SP_CONTINUOUS=2

   integer, parameter :: M=1, U=2, V=3, HH=4, VV=5

   integer, parameter :: ONETWOONE=1, SMTHDESMTH=2, SMTHDESMTH_SPECIAL=3

   integer, parameter :: BINARY=1, NETCDF=2, GRIB1=3, HDF=4

   integer, parameter :: BIG_ENDIAN=0, LITTLE_ENDIAN=1

   ! Projection codes for proj_info structure:
   INTEGER, PUBLIC, PARAMETER  :: PROJ_LATLON = 0
   INTEGER, PUBLIC, PARAMETER  :: PROJ_LC = 1
   INTEGER, PUBLIC, PARAMETER  :: PROJ_PS = 2
   INTEGER, PUBLIC, PARAMETER  :: PROJ_PS_WGS84 = 102
   INTEGER, PUBLIC, PARAMETER  :: PROJ_MERC = 3
   INTEGER, PUBLIC, PARAMETER  :: PROJ_GAUSS = 4
   INTEGER, PUBLIC, PARAMETER  :: PROJ_CYL = 5
   INTEGER, PUBLIC, PARAMETER  :: PROJ_CASSINI = 6
   INTEGER, PUBLIC, PARAMETER  :: PROJ_ALBERS_NAD83 = 105 
   INTEGER, PUBLIC, PARAMETER  :: PROJ_ROTLL = 203

end module misc_definitions_module
