! DART software - Copyright 2004 - 2013 UCAR. This open source software is
! provided by UCAR, "as is", without charge, subject to all terms of use at
! http://www.image.ucar.edu/DAReS/DART/DART_download
!
! DART $Id$

! BEGIN DART PREPROCESS KIND LIST
! MONITOR_SO2, KIND_SO2
! MONITOR_NO2, KIND_NO2
! MONITOR_PM10, KIND_PM10
! MONITOR_CO, KIND_CO
! MONITOR_O3, KIND_O3
! MONITOR_PM25, KIND_PM25
! END DART PREPROCESS KIND LIST

! BEGIN DART PREPROCESS USE OF SPECIAL OBS_DEF MODULE
!   use obs_def_monitor_mod, only : write_monitor_so2, read_monitor_so2, &
!                                  interactive_monitor_so2, get_expected_monitor_so2
!                                  
!   use obs_def_monitor_mod, only : write_monitor_no2, read_monitor_no2, &
!                                  interactive_monitor_no2, get_expected_monitor_no2
!                                  
!   use obs_def_monitor_mod, only : write_monitor_pm10, read_monitor_pm10, &
!                                  interactive_monitor_pm10, get_expected_monitor_pm10
!                                  
!   use obs_def_monitor_mod, only : write_monitor_co, read_monitor_co, &
!                                  interactive_monitor_co, get_expected_monitor_co
!                                  
!   use obs_def_monitor_mod, only : write_monitor_o3, read_monitor_o3, &
!                                  interactive_monitor_o3, get_expected_monitor_o3
!                                  
!   use obs_def_monitor_mod, only : write_monitor_pm25, read_monitor_pm25, &
!                                  interactive_monitor_pm25, get_expected_monitor_pm25
!                                  
! END DART PREPROCESS USE OF SPECIAL OBS_DEF MODULE

! BEGIN DART PREPROCESS GET_EXPECTED_OBS_FROM_DEF
!         case(MONITOR_SO2)                                                           
!            call get_expected_monitor_so2(state, location, obs_def%key, obs_val, istatus)
!         case(MONITOR_NO2)                                                           
!            call get_expected_monitor_no2(state, location, obs_def%key, obs_val, istatus)
!         case(MONITOR_PM10)                                                           
!            call get_expected_monitor_pm10(state, location, obs_def%key, obs_val, istatus)
!         case(MONITOR_CO)                                                           
!            call get_expected_monitor_co(state, location, obs_def%key, obs_val, istatus)
!         case(MONITOR_O3)                                                           
!            call get_expected_monitor_o3(state, location, obs_def%key, obs_val, istatus)
!         case(MONITOR_PM25)                                                           
!            call get_expected_monitor_pm25(state, location, obs_def%key, obs_val, istatus)
! END DART PREPROCESS GET_EXPECTED_OBS_FROM_DEF

! BEGIN DART PREPROCESS READ_OBS_DEF
!      case(MONITOR_SO2)
!         call read_monitor_so2(obs_def%key, ifile, fileformat)
!      case(MONITOR_NO2)
!         call read_monitor_no2(obs_def%key, ifile, fileformat)
!      case(MONITOR_PM10)
!         call read_monitor_pm10(obs_def%key, ifile, fileformat)
!      case(MONITOR_CO)
!         call read_monitor_co(obs_def%key, ifile, fileformat)
!      case(MONITOR_O3)
!         call read_monitor_o3(obs_def%key, ifile, fileformat)
!      case(MONITOR_PM25)
!         call read_monitor_pm25(obs_def%key, ifile, fileformat)
! END DART PREPROCESS READ_OBS_DEF

! BEGIN DART PREPROCESS WRITE_OBS_DEF
!      case(MONITOR_SO2)
!         call write_monitor_so2(obs_def%key, ifile, fileformat)
!      case(MONITOR_NO2)
!         call write_monitor_no2(obs_def%key, ifile, fileformat)
!      case(MONITOR_PM10)
!         call write_monitor_pm10(obs_def%key, ifile, fileformat)
!      case(MONITOR_CO)
!         call write_monitor_co(obs_def%key, ifile, fileformat)
!      case(MONITOR_O3)
!         call write_monitor_o3(obs_def%key, ifile, fileformat)
!      case(MONITOR_PM25)
!         call write_monitor_pm25(obs_def%key, ifile, fileformat)
! END DART PREPROCESS WRITE_OBS_DEF

! BEGIN DART PREPROCESS INTERACTIVE_OBS_DEF
!      case(MONITOR_SO2)
!         call interactive_monitor_so2(obs_def%key)
!      case(MONITOR_NO2)
!         call interactive_monitor_no2(obs_def%key)
!      case(MONITOR_PM10)
!         call interactive_monitor_pm10(obs_def%key)
!      case(MONITOR_CO)
!         call interactive_monitor_co(obs_def%key)
!      case(MONITOR_O3)
!         call interactive_monitor_o3(obs_def%key)
!      case(MONITOR_PM25)
!         call interactive_monitor_pm25(obs_def%key)
! END DART PREPROCESS INTERACTIVE_OBS_DEF

! BEGIN DART PREPROCESS MODULE CODE
module obs_def_monitor_mod

use        types_mod, only : r8, missing_r8
use    utilities_mod, only : register_module, error_handler, E_ERR, E_MSG, &
                             nmlfileunit, check_namelist_read, &
                             find_namelist_in_file, do_nml_file, do_nml_term, &
                             ascii_file_format
use     location_mod, only : location_type, set_location, get_location , write_location, &
                             read_location

use  assim_model_mod, only : interpolate
use    obs_kind_mod,  only : KIND_SO2, KIND_NO2, KIND_CO, KIND_O3, KIND_BC1, KIND_BC2, KIND_OC1, KIND_OC2, &
                             KIND_DST01, KIND_DST02, KIND_DST03, KIND_DST04, &
                             KIND_DST05, KIND_SO4, KIND_SSLT01, KIND_SSLT02, KIND_SSLT03, &
                             KIND_SSLT04, KIND_PM25, KIND_PM10,KIND_PRESSURE, KIND_TEMPERATURE 

implicit none
private

public :: write_monitor_so2,  read_monitor_so2, &
          write_monitor_no2,  read_monitor_no2, &
          write_monitor_co,   read_monitor_co, &
          write_monitor_o3,   read_monitor_o3, &
          write_monitor_pm10, read_monitor_pm10, &
          write_monitor_pm25, read_monitor_pm25, &
          interactive_monitor_so2,  get_expected_monitor_so2, &
          interactive_monitor_no2,  get_expected_monitor_no2, &
          interactive_monitor_co,   get_expected_monitor_co, &
          interactive_monitor_o3,   get_expected_monitor_o3, &
          interactive_monitor_pm10, get_expected_monitor_pm10, &
          interactive_monitor_pm25, get_expected_monitor_pm25

logical, parameter :: use_diag = .false.

! version controlled file description for error handling, do not edit
character(len=*), parameter :: source   = &
   "$URL$"
character(len=*), parameter :: revision = "$Revision$"
character(len=*), parameter :: revdate  = "$Date$"

logical, save :: module_initialized = .false.

contains

!----------------------------------------------------------------------
!>

subroutine initialize_module

! Prevent multiple calls from executing this code more than once.
if (module_initialized) return

call register_module(source, revision, revdate)
module_initialized = .true.

end subroutine initialize_module


!----------------------------------------------------------------------
!>


subroutine read_monitor_so2(key, ifile, fform)

integer, intent(out)            :: key
integer, intent(in)             :: ifile
character(len=*), intent(in), optional    :: fform

continue

end subroutine read_monitor_so2


!----------------------------------------------------------------------
!>


subroutine write_monitor_so2(key, ifile, fform)

integer, intent(in)             :: key
integer, intent(in)             :: ifile
character(len=*), intent(in), optional :: fform

continue

end subroutine write_monitor_so2


!----------------------------------------------------------------------
!>


subroutine interactive_monitor_so2(key)

integer, intent(out) :: key

continue

end subroutine interactive_monitor_so2


!----------------------------------------------------------------------
!>


subroutine get_expected_monitor_so2(state_vector, location, key, so2, istatus)

real(r8),            intent(in)  :: state_vector(:)
type(location_type), intent(in)  :: location
integer,             intent(in)  :: key
real(r8),            intent(out) :: so2               ! so2 concentration(ug/m3)
integer,             intent(out) :: istatus

real(r8), PARAMETER :: mso2=64   ! molecular weight
                                 !   to avoid problems near zero in Bolton's equation
real(r8) :: p_Pa                 ! pressure (Pa)
real(r8) :: T_k                  ! temperature(K)

if ( .not. module_initialized ) call initialize_module

call interpolate(state_vector, location, KIND_PRESSURE, p_Pa, istatus)
if (istatus /= 0) then
   so2 = missing_r8
   write(*,*) " KIND_PRESSURE very error, ",istatus
   return
endif
call interpolate(state_vector, location, KIND_TEMPERATURE, T_k, istatus)
if (istatus /= 0) then
   write(*,*) " KIND_TEMPERATURE very error, ",istatus
   so2 = missing_r8
   return
endif
call interpolate(state_vector, location, KIND_SO2, so2, istatus)! so2(ppmv)
if (istatus /= 0) then
   so2 = missing_r8
   write(*,*) " interpolation so2 very error, ",istatus
   return
endif
so2=so2*(mso2*p_pa)/(8.314*T_k) ! so2(ug/m3)


end subroutine get_expected_monitor_so2
 

!----------------------------------------------------------------------
!>


subroutine read_monitor_no2(key, ifile, fform)

integer, intent(out)            :: key
integer, intent(in)             :: ifile
character(len=*), intent(in), optional    :: fform

continue

end subroutine read_monitor_no2


!----------------------------------------------------------------------
!>


subroutine write_monitor_no2(key, ifile, fform)


integer, intent(in)             :: key
integer, intent(in)             :: ifile
character(len=*), intent(in), optional :: fform

continue

end subroutine write_monitor_no2


!----------------------------------------------------------------------
!>


subroutine interactive_monitor_no2(key)

integer, intent(out) :: key

continue

end subroutine interactive_monitor_no2


!----------------------------------------------------------------------
!>


subroutine get_expected_monitor_no2(state_vector, location, key, no2, istatus)

real(r8),            intent(in)  :: state_vector(:)
type(location_type), intent(in)  :: location
integer,             intent(in)  :: key
real(r8),            intent(out) :: no2               ! no2 concentration(ug/m3)
integer,             intent(out) :: istatus

real(r8), PARAMETER :: mno2=46   ! molecular weight
                                          !   to avoid problems near zero in Bolton's equation
real(r8) :: p_Pa                          ! pressure (Pa)
real(r8) :: T_k                            ! tempreture(K)

if ( .not. module_initialized ) call initialize_module

call interpolate(state_vector, location, KIND_PRESSURE, p_Pa, istatus)
if (istatus /= 0) then
   no2 = missing_r8
   return
endif
call interpolate(state_vector, location, KIND_TEMPERATURE, T_k, istatus)
if (istatus /= 0) then
   no2 = missing_r8
   return
endif
call interpolate(state_vector, location, KIND_NO2, no2, istatus)! no2(ppmv)
if (istatus /= 0) then
   no2 = missing_r8
   return
endif
no2=no2*(mno2*p_pa)/(8.314*T_k) ! no2(ug/m3)

end subroutine get_expected_monitor_no2 


!----------------------------------------------------------------------
!>


subroutine read_monitor_o3(key, ifile, fform)

integer, intent(out)            :: key
integer, intent(in)             :: ifile
character(len=*), intent(in), optional    :: fform

continue

end subroutine read_monitor_o3


!----------------------------------------------------------------------
!>


subroutine write_monitor_o3(key, ifile, fform)

integer, intent(in)             :: key
integer, intent(in)             :: ifile
character(len=*), intent(in), optional :: fform

continue

end subroutine write_monitor_o3


!----------------------------------------------------------------------
!>


subroutine interactive_monitor_o3(key)

integer, intent(out) :: key

continue

end subroutine interactive_monitor_o3


!----------------------------------------------------------------------
!>


subroutine get_expected_monitor_o3(state_vector, location, key, o3, istatus)

real(r8),            intent(in)  :: state_vector(:)
type(location_type), intent(in)  :: location
integer,             intent(in)  :: key
real(r8),            intent(out) :: o3               ! o3 concentration(ug/m3)
integer,             intent(out) :: istatus

real(r8), PARAMETER :: mo3=48   ! molecular weight
                                          !   to avoid problems near zero in Bolton's equation
real(r8) :: p_Pa                          ! pressure (Pa)
real(r8) :: T_k                            ! tempreture(K)

if ( .not. module_initialized ) call initialize_module

call interpolate(state_vector, location, KIND_PRESSURE, p_Pa, istatus)
if (istatus /= 0) then
   o3 = missing_r8
   return
endif
call interpolate(state_vector, location, KIND_TEMPERATURE, T_k, istatus)
if (istatus /= 0) then
   o3 = missing_r8
   return
endif
call interpolate(state_vector, location, KIND_O3, o3, istatus)! o3(ppmv)
if (istatus /= 0) then
   o3 = missing_r8
   return
endif
o3=o3*(mo3*p_pa)/(8.314*T_k) ! o3(ug/m3)


end subroutine get_expected_monitor_o3


!----------------------------------------------------------------------
!>


subroutine read_monitor_co(key, ifile, fform)

integer, intent(out)            :: key
integer, intent(in)             :: ifile
character(len=*), intent(in), optional    :: fform

continue

end subroutine read_monitor_co


!----------------------------------------------------------------------
!>


subroutine write_monitor_co(key, ifile, fform)

integer, intent(in)             :: key
integer, intent(in)             :: ifile
character(len=*), intent(in), optional :: fform

continue

end subroutine write_monitor_co


!----------------------------------------------------------------------
!>


subroutine interactive_monitor_co(key)

integer, intent(out) :: key

continue

end subroutine interactive_monitor_co


!----------------------------------------------------------------------
!>


subroutine get_expected_monitor_co(state_vector, location, key, co, istatus)

real(r8),            intent(in)  :: state_vector(:)
type(location_type), intent(in)  :: location
integer,             intent(in)  :: key
real(r8),            intent(out) :: co               ! co concentration(mg/m3)
integer,             intent(out) :: istatus

real(r8), PARAMETER :: mco=28   ! molecular weight
                                          !   to avoid problems near zero in Bolton's equation
real(r8) :: p_Pa                          ! pressure (Pa)
real(r8) :: T_k                            ! tempreture(K)

if ( .not. module_initialized ) call initialize_module

call interpolate(state_vector, location, KIND_PRESSURE, p_Pa, istatus)
if (istatus /= 0) then
   co = missing_r8
   return
endif
call interpolate(state_vector, location, KIND_TEMPERATURE, T_k, istatus)
if (istatus /= 0) then
   co = missing_r8
   return
endif
call interpolate(state_vector, location, KIND_CO, co, istatus)! co(ppmv)
if (istatus /= 0) then
   co = missing_r8
   return
endif
co=co*(mco*p_pa)/(1000*8.314*T_k) ! co(mg/m3)

end subroutine get_expected_monitor_co


!----------------------------------------------------------------------
!>


subroutine read_monitor_pm25(key, ifile, fform)

integer, intent(out)            :: key
integer, intent(in)             :: ifile
character(len=*), intent(in), optional    :: fform

continue

end subroutine read_monitor_pm25


!----------------------------------------------------------------------
!>


subroutine write_monitor_pm25(key, ifile, fform)

integer, intent(in)             :: key
integer, intent(in)             :: ifile
character(len=*), intent(in), optional :: fform

continue

end subroutine write_monitor_pm25


!----------------------------------------------------------------------
!>


subroutine interactive_monitor_pm25(key)

integer, intent(out) :: key

continue

end subroutine interactive_monitor_pm25


!----------------------------------------------------------------------
!>


subroutine get_expected_monitor_pm25(state_vector, location, key, ppm25, istatus)

real(r8),            intent(in)  :: state_vector(:)
type(location_type), intent(in)  :: location
integer,             intent(in)  :: key
real(r8),            intent(out) :: ppm25               ! pm2.5 concentration(ug/3)
integer,             intent(out) :: istatus

real(r8), PARAMETER :: m_dry_air=29   ! molecular weight
real(r8), PARAMETER :: mso4=96   ! molecular weight
                                          !   to avoid problems near zero in Bolton's equation
real(r8) :: p_Pa                          ! pressure (Pa)
real(r8) :: T_k                            ! tempreture(K)
real(r8) :: PM25,BC1,BC2,DST01,DST02,SSLT01,SSLT02,SO4,OC1,OC2 !components
real(r8) :: alt_temp 

if ( .not. module_initialized ) call initialize_module

ppm25=0.
call interpolate(state_vector, location, KIND_PRESSURE, p_Pa, istatus)
if (istatus /= 0) then
   ppm25 = missing_r8
   return
endif
call interpolate(state_vector, location, KIND_TEMPERATURE, T_k, istatus)
if (istatus /= 0) then
   ppm25 = missing_r8
   return
endif
call interpolate(state_vector, location, KIND_PM25, PM25, istatus)
if (istatus /= 0) then
   ppm25 = missing_r8
   return
else
   ppm25=ppm25+PM25
end if
call interpolate(state_vector, location, KIND_BC1, BC1, istatus)
if (istatus /= 0) then
   ppm25 = missing_r8
   return
else
   ppm25=ppm25+BC1
end if
call interpolate(state_vector, location, KIND_BC2, BC2, istatus)
if (istatus /= 0) then
   ppm25 = missing_r8
   return
else
   ppm25=ppm25+BC2
end if
call interpolate(state_vector, location, KIND_DST01, DST01, istatus)
if (istatus /= 0) then
   ppm25 = missing_r8
   return
else
   ppm25=ppm25+DST01
end if
call interpolate(state_vector, location, KIND_DST02, DST02, istatus)
if (istatus /= 0) then
   ppm25 = missing_r8
   return
else
   ppm25=ppm25+DST02*0.286
end if
call interpolate(state_vector, location, KIND_SSLT01, SSLT01, istatus)
if (istatus /= 0) then
   ppm25 = missing_r8
   return
else
   ppm25=ppm25+SSLT01
end if
call interpolate(state_vector, location, KIND_SSLT02, SSLT02, istatus)
if (istatus /= 0) then
   ppm25 = missing_r8
   return
else
   ppm25=ppm25+SSLT02*0.942
end if
call interpolate(state_vector, location, KIND_SO4, SO4, istatus)
if (istatus /= 0) then
   ppm25 = missing_r8
   return
else
   ppm25=ppm25+SO4*(mso4/m_dry_air)*1000.0*1.375
end if
call interpolate(state_vector, location, KIND_OC1, OC1, istatus)
if (istatus /= 0) then
   ppm25 = missing_r8
   return
else
   ppm25=ppm25+OC1*1.8
end if
call interpolate(state_vector, location, KIND_OC2, OC2, istatus)
if (istatus /= 0) then
   ppm25 = missing_r8
   return
else
   ppm25=ppm25+OC2*1.8 ! ug/kg
end if
alt_temp=1.0/(m_dry_air*p_Pa/(1000.0*8.314*T_k))
ppm25=ppm25/alt_temp ! pm25(ug/m3)


end subroutine get_expected_monitor_pm25


!----------------------------------------------------------------------
!>


subroutine read_monitor_pm10(key, ifile, fform)

integer, intent(out)            :: key
integer, intent(in)             :: ifile
character(len=*), intent(in), optional    :: fform

continue

end subroutine read_monitor_pm10


!----------------------------------------------------------------------
!>


subroutine write_monitor_pm10(key, ifile, fform)

integer, intent(in)             :: key
integer, intent(in)             :: ifile
character(len=*), intent(in), optional :: fform

continue

end subroutine write_monitor_pm10


!----------------------------------------------------------------------
!>


subroutine interactive_monitor_pm10(key)

integer, intent(out) :: key

continue

end subroutine interactive_monitor_pm10


!----------------------------------------------------------------------
!>


subroutine get_expected_monitor_pm10(state_vector, location, key, ppm10, istatus)

real(r8),            intent(in)  :: state_vector(:)
type(location_type), intent(in)  :: location
integer,             intent(in)  :: key
real(r8),            intent(out) :: ppm10               ! pm10 concentration(ug/3)
integer,             intent(out) :: istatus

real(r8), PARAMETER :: m_dry_air=29   ! molecular weight
real(r8), PARAMETER :: mso4=96   ! molecular weight
                                          !   to avoid problems near zero in Bolton's equation
real(r8) :: p_Pa                          ! pressure (Pa)
real(r8) :: T_k                            ! tempreture(K)
real(r8) :: PM25,BC1,BC2,DST01,DST02,DST03,DST04,SSLT01,SSLT02,SSLT03,SO4,OC1,OC2,PM10 !components
real(r8) :: alt_temp 

if ( .not. module_initialized ) call initialize_module

ppm10=0.
call interpolate(state_vector, location, KIND_PRESSURE, p_Pa, istatus)
if (istatus /= 0) then
   ppm10 = missing_r8
   return
endif
call interpolate(state_vector, location, KIND_TEMPERATURE, T_k, istatus)
if (istatus /= 0) then
   ppm10 = missing_r8
   return
endif
call interpolate(state_vector, location, KIND_PM25, PM25, istatus)
if (istatus /= 0) then
   ppm10 = missing_r8
   return
else
   ppm10=ppm10+PM25
end if
call interpolate(state_vector, location, KIND_BC1, BC1, istatus)
if (istatus /= 0) then
   ppm10 = missing_r8
   return
else
   ppm10=ppm10+BC1
end if
call interpolate(state_vector, location, KIND_BC2, BC2, istatus)
if (istatus /= 0) then
   ppm10 = missing_r8
   return
else
   ppm10=ppm10+BC2
end if
call interpolate(state_vector, location, KIND_DST01, DST01, istatus)
if (istatus /= 0) then
   ppm10 = missing_r8
   return
else
   ppm10=ppm10+DST01
end if
call interpolate(state_vector, location, KIND_DST02, DST02, istatus)
if (istatus /= 0) then
   ppm10 = missing_r8
   return
else
   ppm10=ppm10+DST02
end if
call interpolate(state_vector, location, KIND_DST03, DST03, istatus)
if (istatus /= 0) then
   ppm10 = missing_r8
   return
else
   ppm10=ppm10+DST03
end if
call interpolate(state_vector, location, KIND_DST04, DST04, istatus)
if (istatus /= 0) then
   ppm10 = missing_r8
   return
else
   ppm10=ppm10+DST04*0.87
end if
call interpolate(state_vector, location, KIND_SSLT01, SSLT01, istatus)
if (istatus /= 0) then
   ppm10 = missing_r8
   return
else
   ppm10=ppm10+SSLT01
end if
call interpolate(state_vector, location, KIND_SSLT02, SSLT02, istatus)
if (istatus /= 0) then
   ppm10 = missing_r8
   return
else
   ppm10=ppm10+SSLT02
end if
call interpolate(state_vector, location, KIND_SSLT03, SSLT03, istatus)
if (istatus /= 0) then
   ppm10 = missing_r8
   return
else
   ppm10=ppm10+SSLT03
end if
call interpolate(state_vector, location, KIND_SO4, SO4, istatus)
if (istatus /= 0) then
   ppm10 = missing_r8
   return
else
   ppm10=ppm10+SO4*(mso4/m_dry_air)*1000.0*1.375
end if
call interpolate(state_vector, location, KIND_OC1, OC1, istatus)
if (istatus /= 0) then
   ppm10 = missing_r8
   return
else
   ppm10=ppm10+OC1*1.8
end if
call interpolate(state_vector, location, KIND_OC2, OC2, istatus)
if (istatus /= 0) then
   ppm10 = missing_r8
   return
else
   ppm10=ppm10+OC2*1.8 
end if
call interpolate(state_vector, location, KIND_PM10, PM10, istatus)
if (istatus /= 0) then
   ppm10 = missing_r8
   return
else
   ppm10=ppm10+PM10 ! ug/kg
end if
alt_temp=1.0/(m_dry_air*p_Pa/(1000.0*8.314*T_k))
ppm10=ppm10/alt_temp ! pm10(ug/m3)


end subroutine get_expected_monitor_pm10


end module obs_def_monitor_mod
! END DART PREPROCESS MODULE CODE

! <next few lines under version control, do not edit>
! $URL$
! $Id$
! $Revision$
! $Date$
