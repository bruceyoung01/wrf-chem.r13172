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
! MODULE CONSTANTS_MODULE
!
! This module defines constants that are used by other modules 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

module constants_module

   real, parameter :: PI = 3.141592653589793
   real, parameter :: OMEGA_E = 7.292e-5 ! Angular rotation rate of the earth

   real, parameter :: DEG_PER_RAD = 180./PI
   real, parameter :: RAD_PER_DEG = PI/180.
 
   ! Mean Earth Radius in m.  The value below is consistent
   ! with NCEP's routines and grids.
   real, parameter :: A_WGS84  = 6378137.
   real, parameter :: B_WGS84  = 6356752.314
   real, parameter :: RE_WGS84 = A_WGS84
   real, parameter :: E_WGS84  = 0.081819192

   real, parameter :: A_NAD83  = 6378137.
   real, parameter :: RE_NAD83 = A_NAD83
   real, parameter :: E_NAD83  = 0.0818187034

   real, parameter :: EARTH_RADIUS_M = 6370000.   ! same as MM5 system
   real, parameter :: EARTH_CIRC_M = 2.*PI*EARTH_RADIUS_M

end module constants_module
