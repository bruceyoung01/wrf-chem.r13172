! DART software - Copyright 2004 - 2013 UCAR. This open source software is
! provided by UCAR, "as is", without charge, subject to all terms of use at
! http://www.image.ucar.edu/DAReS/DART/DART_download
!
! DART $Id$

! BEGIN DART PREPROCESS KIND LIST
! IASI_O3_RETRIEVAL, KIND_O3
! END DART PREPROCESS KIND LIST
!
! BEGIN DART PREPROCESS USE OF SPECIAL OBS_DEF MODULE
!   use obs_def_iasi_O3_mod, only : write_iasi_o3, read_iasi_o3, &
!                                  interactive_iasi_o3, get_expected_iasi_o3, &
!                                  set_obs_def_iasi_o3
! END DART PREPROCESS USE OF SPECIAL OBS_DEF MODULE
!
! BEGIN DART PREPROCESS GET_EXPECTED_OBS_FROM_DEF
!         case(IASI_O3_RETRIEVAL)                                                           
!            call get_expected_iasi_o3(state, location, obs_def%key, obs_val, istatus)  
! END DART PREPROCESS GET_EXPECTED_OBS_FROM_DEF
!
! BEGIN DART PREPROCESS READ_OBS_DEF
!      case(IASI_O3_RETRIEVAL)
!         call read_iasi_o3(obs_def%key, ifile, fileformat)
! END DART PREPROCESS READ_OBS_DEF
!
! BEGIN DART PREPROCESS WRITE_OBS_DEF
!      case(IASI_O3_RETRIEVAL)
!         call write_iasi_o3(obs_def%key, ifile, fileformat)
! END DART PREPROCESS WRITE_OBS_DEF
!
! BEGIN DART PREPROCESS INTERACTIVE_OBS_DEF
!      case(IASI_O3_RETRIEVAL)
!         call interactive_iasi_o3(obs_def%key)
! END DART PREPROCESS INTERACTIVE_OBS_DEF
!
! BEGIN DART PREPROCESS SET_OBS_DEF_IASI_O3
!      case(IASI_O3_RETRIEVAL)
!         call set_obs_def_iasi_o3(obs_def%key)
! END DART PREPROCESS SET_OBS_DEF_IASI_O3
!
! BEGIN DART PREPROCESS MODULE CODE

module obs_def_iasi_O3_mod

use types_mod,only          : r8
use utilities_mod,only      : register_module, error_handler, E_ERR, E_MSG, &
                             nmlfileunit, check_namelist_read, &
                             find_namelist_in_file, do_nml_file, do_nml_term, &
                             ascii_file_format
use location_mod,only       : location_type, set_location, get_location, VERTISHEIGHT,&
                              VERTISPRESSURE, VERTISLEVEL, VERTISSURFACE
use assim_model_mod,only    : interpolate
use obs_kind_mod,only       : KIND_O3, KIND_SURFACE_PRESSURE, KIND_PRESSURE
use mpi_utilities_mod,only  : my_task_id  

implicit none 
private

public :: write_iasi_o3,        &
          read_iasi_o3,         &
          interactive_iasi_o3,  &
          get_expected_iasi_o3, &
          set_obs_def_iasi_o3
!
! Storage for the special information required for observations of this type
integer, parameter          :: MAX_IASI_O3_OBS = 6000000
integer, parameter          :: IASI_DIM = 41
integer                     :: num_iasi_o3_obs = 0

real(r8), allocatable, dimension(:,:)  :: avg_kernel
real(r8), allocatable, dimension(:,:)  :: pressure
real(r8), allocatable, dimension(:)    :: iasi_prior_trm
real(r8), allocatable, dimension(:)    :: iasi_psurf
real(r8), allocatable, dimension(:,:)  :: iasi_altitude
real(r8), allocatable, dimension(:,:)  :: iasi_air_column
real(r8), allocatable, dimension(:,:)  :: iasi_prior
integer, allocatable, dimension(:)     :: iasi_nlevels
!
! nominal iasi height levels in m
real(r8)                    :: iasi_altitude_ref(IASI_DIM) =(/ &
                               0.,1000.,2000.,3000.,4000., &
                               5000.,6000.,7000.,8000.,9000., &
                               10000.,11000.,12000.,13000.,14000., &
                               15000.,16000.,17000.,18000.,19000., &
                               20000.,21000.,22000.,23000.,24000., &
                               25000.,26000.,27000.,28000.,29000., &
                               30000.,31000.,32000.,33000.,34000., &
                               35000.,36000.,37000.,38000.,39000., &
                               40000. /) 
!
! version controlled file description for error handling, do not edit
character(len=*), parameter :: source   = &
   "$URL$"
character(len=*), parameter :: revision = "$Revision$"
character(len=*), parameter :: revdate  = "$Date$"

character(len=512) :: string1, string2

logical, save       :: module_initialized = .false.
integer             :: counts1 = 0

character(len=129)  :: IASI_O3_retrieval_type
logical             :: use_log_o3 =.false.
!
! IASI_O3_retrieval_type:
!     RAWR - retrievals in VMR (ppb) units
!     QOR  - quasi-optimal retrievals
!     CPSR - compact phase space retrievals
namelist /obs_def_IASI_O3_nml/ IASI_O3_retrieval_type, use_log_o3

contains

!----------------------------------------------------------------------

subroutine initialize_module

integer :: iunit, rc

! Prevent multiple calls from executing this code more than once.
if (module_initialized) return

call register_module(source, revision, revdate)
module_initialized = .true.

allocate(avg_kernel(     MAX_IASI_O3_OBS,IASI_DIM))
allocate(pressure(       MAX_IASI_O3_OBS,IASI_DIM))
allocate(iasi_prior_trm( MAX_IASI_O3_OBS))
allocate(iasi_psurf(     MAX_IASI_O3_OBS))
allocate(iasi_altitude(  MAX_IASI_O3_OBS,IASI_DIM))
allocate(iasi_air_column(MAX_IASI_O3_OBS,IASI_DIM))
allocate(iasi_prior     (MAX_IASI_O3_OBS,IASI_DIM))
allocate(iasi_nlevels(   MAX_IASI_O3_OBS))

! Read the namelist entry.
IASI_O3_retrieval_type='RAWR'
use_log_o3=.false.
call find_namelist_in_file("input.nml", "obs_def_IASI_O3_nml", iunit)
read(iunit, nml = obs_def_IASI_O3_nml, iostat = rc)
call check_namelist_read(iunit, rc, "obs_def_IASI_O3_nml")

! Record the namelist values used for the run ... 
if (do_nml_file()) write(nmlfileunit, nml=obs_def_IASI_O3_nml)
if (do_nml_term()) write(     *     , nml=obs_def_IASI_O3_nml)

end subroutine initialize_module

!----------------------------------------------------------------------
!>

subroutine read_iasi_o3(key, ifile, fform)

integer,                    intent(out) :: key
integer,                    intent(in)  :: ifile
character(len=*), optional, intent(in)  :: fform

character(len=32)               :: fileformat
integer                         :: iasi_nlevels_1
real(r8)                        :: iasi_prior_trm_1
real(r8)                        :: iasi_psurf_1
real(r8),  dimension(IASI_DIM)  :: iasi_altitude_1
real(r8),  dimension(IASI_DIM)  :: iasi_air_column_1
real(r8),  dimension(IASI_DIM)  :: iasi_prior_1
real(r8),  dimension(IASI_DIM)  :: avg_kernel_1
real(r8),  dimension(IASI_DIM)  :: pressure_1
integer                         :: keyin

if ( .not. module_initialized ) call initialize_module

fileformat = "ascii"   ! supply default
if(present(fform)) fileformat = trim(adjustl(fform))
!
! Philosophy, read ALL information about this special obs_type at once???
! For now, this means you can only read ONCE (that's all we're doing 3 June 05)
! Toggle the flag to control this reading
!
iasi_altitude_1(:) = 0.0_r8
iasi_air_column_1(:) = 0.0_r8
iasi_prior_1(:) = 0.0_r8
avg_kernel_1(:) = 0.0_r8
pressure_1(:) = 0.0_r8

SELECT CASE (fileformat)
   CASE ("unf", "UNF", "unformatted", "UNFORMATTED")
   iasi_nlevels_1 = read_iasi_nlevels(ifile, fileformat)
   iasi_prior_trm_1  = read_iasi_prior_trm(ifile, fileformat)
   iasi_psurf_1  = read_iasi_psurf(ifile, fileformat)
   iasi_altitude_1 = read_iasi_altitude(ifile, iasi_nlevels_1, fileformat)
   iasi_air_column_1  = read_iasi_air_column(ifile, iasi_nlevels_1, fileformat)
   iasi_prior_1  = read_iasi_prior(ifile, iasi_nlevels_1, fileformat)
   avg_kernel_1 = read_iasi_avg_kernel(ifile, iasi_nlevels_1, fileformat) 
   pressure_1 = read_iasi_pressure(ifile, iasi_nlevels_1, fileformat)
   read(ifile) keyin
   CASE DEFAULT
   iasi_nlevels_1 = read_iasi_nlevels(ifile, fileformat)
   iasi_prior_trm_1  = read_iasi_prior_trm(ifile, fileformat)
   iasi_psurf_1  = read_iasi_psurf(ifile, fileformat)
   iasi_altitude_1 = read_iasi_altitude(ifile, iasi_nlevels_1, fileformat)
   iasi_air_column_1  = read_iasi_air_column(ifile, iasi_nlevels_1, fileformat)
   iasi_prior_1  = read_iasi_prior(ifile, iasi_nlevels_1, fileformat)
   avg_kernel_1 = read_iasi_avg_kernel(ifile, iasi_nlevels_1, fileformat) 
   pressure_1 = read_iasi_pressure(ifile, iasi_nlevels_1, fileformat)
   read(ifile, *) keyin
END SELECT
counts1 = counts1 + 1
key = counts1
call set_obs_def_iasi_o3(key, avg_kernel_1, pressure_1, iasi_prior_trm_1, &
   iasi_psurf_1, iasi_altitude_1, iasi_air_column_1, iasi_prior_1, iasi_nlevels_1)

end subroutine read_iasi_o3

!----------------------------------------------------------------------

subroutine write_iasi_o3(key, ifile, fform)

integer,          intent(in)           :: key
integer,          intent(in)           :: ifile
character(len=*), intent(in), optional :: fform

real(r8),  dimension(IASI_DIM)  :: altitude_temp
real(r8),  dimension(IASI_DIM)  :: air_column_temp
real(r8),  dimension(IASI_DIM)  :: prior_temp
real(r8),  dimension(IASI_DIM)  :: avg_kernel_temp
real(r8),  dimension(IASI_DIM)  :: pressure_temp

character(len=32)               :: fileformat
if ( .not. module_initialized ) call initialize_module
fileformat = "ascii"   ! supply default
if(present(fform)) fileformat = trim(adjustl(fform))
!
! Philosophy, read ALL information about this special obs_type at once???
! For now, this means you can only read ONCE (that's all we're doing 3 June 05)
! Toggle the flag to control this reading
!
altitude_temp=iasi_altitude(key,:)
air_column_temp=iasi_air_column(key,:)
prior_temp=iasi_prior(key,:)
avg_kernel_temp=avg_kernel(key,:)
pressure_temp=pressure(key,:)
!
SELECT CASE (fileformat)
   CASE ("unf", "UNF", "unformatted", "UNFORMATTED")
   call write_iasi_nlevels(ifile, iasi_nlevels(key), fileformat)
   call write_iasi_prior_trm(ifile, iasi_prior_trm(key), fileformat)
   call write_iasi_psurf(ifile, iasi_psurf(key), fileformat)
   call write_iasi_altitude(ifile, altitude_temp, iasi_nlevels(key), fileformat)
   call write_iasi_air_column(ifile, air_column_temp, iasi_nlevels(key), fileformat)
   call write_iasi_prior(ifile, prior_temp, iasi_nlevels(key), fileformat)
   call write_iasi_avg_kernel(ifile, avg_kernel_temp, iasi_nlevels(key), fileformat)
   call write_iasi_pressure(ifile, pressure_temp, iasi_nlevels(key), fileformat)
   write(ifile) key
   CASE DEFAULT
   call write_iasi_nlevels(ifile, iasi_nlevels(key), fileformat)
   call write_iasi_prior_trm(ifile, iasi_prior_trm(key), fileformat)
   call write_iasi_psurf(ifile, iasi_psurf(key), fileformat)
   call write_iasi_altitude(ifile, altitude_temp, iasi_nlevels(key), fileformat)
   call write_iasi_air_column(ifile, air_column_temp, iasi_nlevels(key), fileformat)
   call write_iasi_prior(ifile, prior_temp, iasi_nlevels(key), fileformat)
   call write_iasi_avg_kernel(ifile, avg_kernel_temp, iasi_nlevels(key), fileformat)
   call write_iasi_pressure(ifile, pressure_temp, iasi_nlevels(key), fileformat)
   write(ifile, *) key
END SELECT 
end subroutine write_iasi_o3
!
subroutine interactive_iasi_o3(key)
!----------------------------------------------------------------------
! subroutine interactive_iasi_o3(key)
!
! Initializes the specialized part of a IASI observation
! Passes back up the key for this one
!
integer, intent(out) :: key
!
if ( .not. module_initialized ) call initialize_module
!
! Make sure there's enough space, if not die for now (clean later)
if(num_iasi_o3_obs >= MAX_IASI_O3_OBS) then
   write(string1, *)'Not enough space for a iasi O3 obs.'
   write(string2, *)'Can only have MAX_IASI_O3_OBS (currently ',MAX_IASI_O3_OBS,')'
   call error_handler(E_ERR,'interactive_iasi_o3',string1,source,revision,revdate,text2=string2)
endif
!
! Increment the index
num_iasi_o3_obs = num_iasi_o3_obs + 1
key = num_iasi_o3_obs
!
! Otherwise, prompt for input for the three required beasts
write(*, *) 'Creating an interactive_iasi_o3 observation'
write(*, *) 'Input the IASI nlevels '
read(*, *) iasi_nlevels
write(*, *) 'Input the IASI O3 Prior Term ' 
read(*, *) iasi_prior_trm
write(*, *) 'Input the IASI O3 Surface Pressure '
read(*, *) iasi_psurf
write(*, *) 'Input IASI O3 41 Altitudes '
read(*, *) iasi_altitude(num_iasi_o3_obs,:)
write(*, *) 'Input IASI O3 41 Air Columns '
read(*, *) iasi_air_column(num_iasi_o3_obs,:)
write(*, *) 'Input IASI O3 41 Priors '
read(*, *) iasi_prior(num_iasi_o3_obs,:)
write(*, *) 'Input IASI O3 41 Averaging Kernel '
read(*, *) avg_kernel(num_iasi_o3_obs,:)
write(*, *) 'Input IASI O3 41 Pressure '
read(*, *) pressure(num_iasi_o3_obs,:)
end subroutine interactive_iasi_o3
!
!----------------------------------------------------------------------
subroutine get_expected_iasi_o3(state, location, key, val, istatus)

   real(r8),            intent(in)  :: state(:)
   type(location_type), intent(in)  :: location
   integer,             intent(in)  :: key
   real(r8),            intent(out) :: val
   integer,             intent(out) :: istatus
!
   integer, parameter  :: wrf_nlev=32
   integer             :: i, kstr, ilev, istrat
   integer             :: apm_dom, apm_mm
   type(location_type) :: loc2
   real(r8)            :: mloc(3), prs_wrf(wrf_nlev)
   real(r8)            :: obs_val, obs_val_fnl, o3_min, o3_min_str
   real(r8)            :: o3_min_log, o3_min_str_log, level, missing
   real(r8)            :: o3_wrf_sfc, o3_wrf_1, o3_wrf_top
   real(r8)            :: prs_wrf_sfc, prs_wrf_1, prs_wrf_nlev
   real(r8)            :: prs_iasi_sfc
     
   real(r8)            :: ylon, ylat, ubv_obs_val, ubv_delt_prs
   real(r8)            :: prs_top, prs_bot, wt_dw, wt_up
   real(r8)            :: term, prior_term
   integer             :: nlevels
   integer             :: icnt=0
   character(len=130)  :: apm_spec

   real(r8)            :: vert_mode_filt
!
! Initialize DART
   if ( .not. module_initialized ) call initialize_module
! 
! Initialize variables
   prs_bot         = 150.*1.e2
   prs_top         = 50*1.e2
   o3_min          = 0.004 * 1.e-3
   o3_min_log      = log(o3_min)
   o3_min_str      = 0.00414 * 1.e-3
   o3_min_str_log  = log(o3_min_str)
   missing         = -888888.0_r8
   nlevels         = iasi_nlevels(key)    
   if ( use_log_o3 ) then
      o3_min=o3_min_log
      o3_min_str=o3_min_str_log
   endif
!
! Get location information
   mloc=get_location(location)
   if (mloc(2) .gt. 90.0_r8) then
      mloc(2)=90.0_r8
   elseif (mloc(2) .lt. -90.0_r8) then
      mloc(2)=-90.0_r8
   endif
!
! IASI surface pressure
   prs_iasi_sfc=iasi_psurf(key)
!
! WRF surface pressure
   istatus=0
   level=0.0_r8
   loc2 = set_location(mloc(1), mloc(2), level, VERTISSURFACE)
   call interpolate(state, loc2, KIND_SURFACE_PRESSURE, prs_wrf_sfc, istatus)  
   if(istatus/=0) then
      write(string1, *)'APM NOTICE: WRF surface pressure is bad ',istatus
      call error_handler(E_MSG,'set_obs_def_iasi_o3',string1,source,revision,revdate)
      stop
   endif              
!
! WRF pressure first level
   istatus=0
   level=real(1)
   loc2 = set_location(mloc(1), mloc(2), level, VERTISLEVEL)
   call interpolate(state, loc2, KIND_PRESSURE, prs_wrf_1, istatus)
   if(istatus/=0) then
      write(string1, *)'APM NOTICE: WRF first level pressure is bad ',istatus
      call error_handler(E_MSG,'set_obs_def_iasi_o3',string1,source,revision,revdate)
      stop
   endif              
!
! WRF pressure top level
   istatus=0
   level=real(wrf_nlev)
   loc2 = set_location(mloc(1), mloc(2), level, VERTISLEVEL)
   call interpolate(state, loc2, KIND_PRESSURE, prs_wrf_nlev, istatus)
   if(istatus/=0) then
      write(string1, *)'APM NOTICE: WRF top level pressure is bad ',istatus
      call error_handler(E_MSG,'set_obs_def_iasi_o3',string1,source,revision,revdate)
      stop
   endif              
!
! WRF ozone at surface
!   istatus = 0
!   loc2 = set_location(mloc(1), mloc(2), prs_wrf_sfc, VERTISSURFACE)
!   call interpolate(state, loc2, KIND_O3, o3_wrf_sfc, istatus) 
!   if(istatus/=0) then
!      write(string1, *)'APM NOTICE: WRF o3 at surface is bad ',istatus
!      call error_handler(E_MSG,'set_obs_def_iasi_o3',string1,source,revision,revdate)
!      stop
!   endif              
!
! WRF ozone at first level
   istatus = 0
   loc2 = set_location(mloc(1), mloc(2), prs_wrf_1, VERTISPRESSURE)
   call interpolate(state, loc2, KIND_O3, o3_wrf_1, istatus) 
   if(istatus/=0) then
      write(string1, *)'APM NOTICE: WRF o3 at first level is bad ',istatus
      call error_handler(E_MSG,'set_obs_def_iasi_o3',string1,source,revision,revdate)
      stop
   endif              
!
! WRF ozone at top
   istatus = 0
   loc2 = set_location(mloc(1), mloc(2), prs_wrf_nlev, VERTISPRESSURE)
   call interpolate(state, loc2, KIND_O3, o3_wrf_top, istatus) 
   if(istatus/=0) then
      write(string1, *)'APM NOTICE: WRF o3 at top is bad ',istatus
      call error_handler(E_MSG,'set_obs_def_iasi_o3',string1,source,revision,revdate)
      stop
   endif              
!
! Apply IASI Averaging kernel A and IASI Prior (I-A)xa
! x = Axm + (I-A)xa , where x is a 41-element vector !
!
! loop through IASI levels
   val = 0.0_r8
   do ilev = 1, nlevels
!
! get location of obs
      istrat=0
!
! point at model surface
!      if(pressure(key,ilev).ge.prs_wrf_sfc) then
!         obs_val=o3_wrf_sfc
!      endif
! point between surface and first level
      if(pressure(key,ilev).ge.prs_wrf_1) then
         obs_val=o3_wrf_1
      endif
!
! point in model interior      
      if(pressure(key,ilev).lt.prs_wrf_1 .and. pressure(key,ilev).ge.prs_wrf_nlev) then
         istatus = 0
         loc2 = set_location(mloc(1),mloc(2), pressure(key,ilev), VERTISPRESSURE)
         call interpolate(state, loc2, KIND_O3, obs_val, istatus) 
         if(istatus.ne.0) then
            write(string1, *),'ilev obs_val,ias_pr ',ilev,obs_val,pressure(key,ilev)/100.
            call error_handler(E_MSG,'set_obs_def_iasi_o3',string1,source,revision,revdate)
            write(string1, *), 'key, ilev ',key,ilev,pressure(key,ilev),prs_wrf_1
            call error_handler(E_MSG,'set_obs_def_iasi_o3',string1,source,revision,revdate)
            stop
         endif      
      endif
!
! point above model top
      if(pressure(key,ilev).lt.prs_wrf_nlev) then
         istrat=1
         obs_val=iasi_prior(key,ilev)
      endif
!
! scale to ppb
      if (istrat.eq.0) then
         if ( use_log_o3 ) then
            obs_val=obs_val + 2.303 * 3.0
         else
            obs_val = obs_val * 1.e3
         endif
      endif
!
! blend upper tropospnere with the prior (WRF O3 biased relative to IASI).
      obs_val_fnl=obs_val
      if(pressure(key,ilev).le.prs_bot .and. pressure(key,ilev).ge.prs_top) then
         wt_dw=pressure(key,ilev)-prs_top
         wt_up=prs_bot-pressure(key,ilev)
         obs_val_fnl=(wt_dw*obs_val + wt_up*iasi_prior(key,ilev))/(wt_dw+wt_up)
      endif
      if(pressure(key,ilev).lt.prs_top) then 
         obs_val_fnl=iasi_prior(key,ilev)
      endif
!
! apply averaging kernel
      if( use_log_o3 ) then
         val = val + avg_kernel(key,ilev) * exp(obs_val_fnl)
      else
         val = val + avg_kernel(key,ilev) * obs_val_fnl
      endif
   enddo
!
   val = val + iasi_prior_trm(key)
!
   if (trim(IASI_O3_retrieval_type).eq.'RETR') then
      val = log10(val)
   endif
   if(val.lt.0.) then
      icnt=icnt+1
      print *, 'APM: Expected O3 is negative ',mloc(3),val
   endif
end subroutine get_expected_iasi_o3

!----------------------------------------------------------------------

subroutine set_obs_def_iasi_o3(key, o3_avgker, o3_press, o3_prior_trm, o3_psurf, o3_altitude, &
   o3_air_column, o3_prior, o3_nlevels)

!> Allows passing of obs_def special information 


integer,                 intent(in) :: key
integer,                 intent(in) :: o3_nlevels
real(r8), dimension(41), intent(in) :: o3_avgker
real(r8), dimension(41), intent(in) :: o3_press
real(r8),                intent(in) :: o3_prior_trm
real(r8),                intent(in) :: o3_psurf
real(r8), dimension(41), intent(in) :: o3_altitude
real(r8), dimension(41), intent(in) :: o3_air_column
real(r8), dimension(41), intent(in) :: o3_prior

if ( .not. module_initialized ) call initialize_module

! Check for sufficient space
if(num_iasi_o3_obs >= MAX_IASI_O3_OBS) then
   write(string1, *)'Not enough space for a iasi O3 obs.'
   write(string2, *)'Can only have MAX_IASI_O3_OBS (currently ',MAX_IASI_O3_OBS,')'
   call error_handler(E_ERR,'set_obs_def_iasi_o3',string1,source,revision,revdate,text2=string2)
endif

avg_kernel(key,:)         = o3_avgker(:)
pressure(key,:)           = o3_press(:)
iasi_prior_trm(key)       = o3_prior_trm
iasi_psurf(key)           = o3_psurf
iasi_altitude(key,:)      = o3_altitude(:)
iasi_air_column(key,:)    = o3_air_column(:)
iasi_prior(key,:)         = o3_prior(:)
iasi_nlevels(key)         = o3_nlevels

end subroutine set_obs_def_iasi_o3

!=================================
! other functions and subroutines
!=================================
!
function read_iasi_prior_trm(ifile, fform)
integer,          intent(in)           :: ifile
character(len=*), intent(in), optional :: fform
real(r8)                               :: read_iasi_prior_trm
!
character(len=32)  :: fileformat
!
if ( .not. module_initialized ) call initialize_module
!
fileformat = "ascii"    ! supply default
if(present(fform)) fileformat = trim(adjustl(fform))
!
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
   read(ifile) read_iasi_prior_trm
   CASE DEFAULT
   read(ifile, *) read_iasi_prior_trm
END SELECT
end function read_iasi_prior_trm
!
subroutine write_iasi_prior_trm(ifile, iasi_prior_trm_temp, fform)
integer,          intent(in) :: ifile
real(r8),         intent(in) :: iasi_prior_trm_temp
character(len=*), intent(in) :: fform
!
character(len=32)  :: fileformat
!
if ( .not. module_initialized ) call initialize_module
!
fileformat = trim(adjustl(fform))
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
   write(ifile) iasi_prior_trm_temp
   CASE DEFAULT
   write(ifile, *) iasi_prior_trm_temp
END SELECT
end subroutine write_iasi_prior_trm
!
function read_iasi_psurf(ifile, fform)
integer,          intent(in)           :: ifile
character(len=*), intent(in), optional :: fform
real(r8)                               :: read_iasi_psurf
!
character(len=32)  :: fileformat
!
if ( .not. module_initialized ) call initialize_module
!
fileformat = "ascii"    ! supply default
if(present(fform)) fileformat = trim(adjustl(fform))
!
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
   read(ifile) read_iasi_psurf
   CASE DEFAULT
   read(ifile, *) read_iasi_psurf
END SELECT
end function read_iasi_psurf
!
subroutine write_iasi_psurf(ifile, iasi_psurf_temp, fform)
integer,          intent(in) :: ifile
real(r8),         intent(in) :: iasi_psurf_temp
character(len=*), intent(in) :: fform
!
character(len=32)  :: fileformat
!
if ( .not. module_initialized ) call initialize_module
!
fileformat = trim(adjustl(fform))
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
   write(ifile) iasi_psurf_temp
   CASE DEFAULT
   write(ifile, *) iasi_psurf_temp
END SELECT
end subroutine write_iasi_psurf
!
function read_iasi_nlevels(ifile, fform)
integer,          intent(in)           :: ifile
character(len=*), intent(in), optional :: fform
integer                                :: read_iasi_nlevels
!
character(len=32)  :: fileformat
!
if ( .not. module_initialized ) call initialize_module
!
fileformat = "ascii"    ! supply default
if(present(fform)) fileformat = trim(adjustl(fform))
!
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
   read(ifile) read_iasi_nlevels
   CASE DEFAULT
   read(ifile, *) read_iasi_nlevels
END SELECT
end function read_iasi_nlevels
!
subroutine write_iasi_nlevels(ifile, iasi_nlevels_temp, fform)
integer,          intent(in) :: ifile
integer,          intent(in) :: iasi_nlevels_temp
character(len=*), intent(in) :: fform
!
character(len=32)  :: fileformat
!
if ( .not. module_initialized ) call initialize_module
!
fileformat = trim(adjustl(fform))
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
   write(ifile) iasi_nlevels_temp
   CASE DEFAULT
   write(ifile, *) iasi_nlevels_temp
END SELECT
end subroutine write_iasi_nlevels
!
function read_iasi_avg_kernel(ifile, nlevels, fform)
integer,          intent(in)           :: ifile, nlevels
character(len=*), intent(in), optional :: fform
real(r8), dimension(41)                :: read_iasi_avg_kernel
!
character(len=32)  :: fileformat
read_iasi_avg_kernel(:) = 0.0_r8
!
if ( .not. module_initialized ) call initialize_module
!
fileformat = "ascii"    ! supply default
if(present(fform)) fileformat = trim(adjustl(fform))
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
   read(ifile) read_iasi_avg_kernel(1:nlevels)
   CASE DEFAULT
   read(ifile, *) read_iasi_avg_kernel(1:nlevels)
END SELECT
end function read_iasi_avg_kernel
!
function read_iasi_altitude(ifile, nlevels, fform)
integer,          intent(in)           :: ifile, nlevels
character(len=*), intent(in), optional :: fform
real(r8), dimension(41)                :: read_iasi_altitude
!
character(len=32)  :: fileformat
read_iasi_altitude(:) = 0.0_r8
!
if ( .not. module_initialized ) call initialize_module
!
fileformat = "ascii"    ! supply default
if(present(fform)) fileformat = trim(adjustl(fform))
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
   read(ifile) read_iasi_altitude(1:nlevels)
   CASE DEFAULT
   read(ifile, *) read_iasi_altitude(1:nlevels)
END SELECT
end function read_iasi_altitude
!
function read_iasi_pressure(ifile, nlevels, fform)
integer,          intent(in)           :: ifile, nlevels
character(len=*), intent(in), optional :: fform
real(r8), dimension(41)                :: read_iasi_pressure
!
character(len=32)  :: fileformat
read_iasi_pressure(:) = 0.0_r8
!
if ( .not. module_initialized ) call initialize_module
!
fileformat = "ascii"    ! supply default
if(present(fform)) fileformat = trim(adjustl(fform))
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
   read(ifile) read_iasi_pressure(1:nlevels)
   CASE DEFAULT
   read(ifile, *) read_iasi_pressure(1:nlevels)
END SELECT
end function read_iasi_pressure
!
function read_iasi_air_column(ifile, nlevels, fform)
integer,          intent(in)           :: ifile, nlevels
character(len=*), intent(in), optional :: fform
real(r8), dimension(41)                :: read_iasi_air_column
!
character(len=32)  :: fileformat
read_iasi_air_column(:) = 0.0_r8
!
if ( .not. module_initialized ) call initialize_module
!
fileformat = "ascii"    ! supply default
if(present(fform)) fileformat = trim(adjustl(fform))
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
   read(ifile) read_iasi_air_column(1:nlevels)
   CASE DEFAULT
   read(ifile, *) read_iasi_air_column(1:nlevels)
END SELECT 
end function read_iasi_air_column
!
function read_iasi_prior(ifile, nlevels, fform)
integer,          intent(in)           :: ifile, nlevels
character(len=*), intent(in), optional :: fform
real(r8), dimension(41)                :: read_iasi_prior
!
character(len=32)  :: fileformat
read_iasi_prior(:) = 0.0_r8
!
if ( .not. module_initialized ) call initialize_module
!
fileformat = "ascii"    ! supply default
if(present(fform)) fileformat = trim(adjustl(fform))
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
   read(ifile) read_iasi_prior(1:nlevels)
   CASE DEFAULT
   read(ifile, *) read_iasi_prior(1:nlevels)
END SELECT 
end function read_iasi_prior
!
subroutine write_iasi_avg_kernel(ifile, avg_kernel_temp, nlevels_temp, fform)
integer,                 intent(in) :: ifile, nlevels_temp
real(r8), dimension(41), intent(in) :: avg_kernel_temp
character(len=*),        intent(in) :: fform
!
character(len=32)  :: fileformat
!
if ( .not. module_initialized ) call initialize_module
!
fileformat = trim(adjustl(fform))
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
   write(ifile) avg_kernel_temp(1:nlevels_temp)
   CASE DEFAULT
   write(ifile, *) avg_kernel_temp(1:nlevels_temp)
END SELECT
end subroutine write_iasi_avg_kernel
!
subroutine write_iasi_altitude(ifile, altitude_temp, nlevels_temp, fform)
integer,                 intent(in) :: ifile, nlevels_temp
real(r8), dimension(41), intent(in) :: altitude_temp
character(len=*),        intent(in) :: fform
!
character(len=32)  :: fileformat
!
if ( .not. module_initialized ) call initialize_module
!
fileformat = trim(adjustl(fform))
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
   write(ifile) altitude_temp(1:nlevels_temp)
   CASE DEFAULT
   write(ifile, *) altitude_temp(1:nlevels_temp)
END SELECT
end subroutine write_iasi_altitude
!
subroutine write_iasi_pressure(ifile, pressure_temp, nlevels_temp, fform)
integer,                 intent(in) :: ifile, nlevels_temp
real(r8), dimension(41), intent(in) :: pressure_temp
character(len=*),        intent(in) :: fform
!
character(len=32)  :: fileformat
!
if ( .not. module_initialized ) call initialize_module
!
fileformat = trim(adjustl(fform))
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
   write(ifile) pressure_temp(1:nlevels_temp)
   CASE DEFAULT
   write(ifile, *) pressure_temp(1:nlevels_temp)
END SELECT
end subroutine write_iasi_pressure
!
subroutine write_iasi_air_column(ifile, air_column_temp, nlevels_temp, fform)
integer,                 intent(in) :: ifile, nlevels_temp
real(r8), dimension(41), intent(in) :: air_column_temp
character(len=*),        intent(in) :: fform
!
character(len=32)  :: fileformat
!
if ( .not. module_initialized ) call initialize_module
!
fileformat = trim(adjustl(fform))
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
   write(ifile) air_column_temp(1:nlevels_temp)
   CASE DEFAULT
   write(ifile, *) air_column_temp(1:nlevels_temp)
END SELECT
end subroutine write_iasi_air_column
!
subroutine write_iasi_prior(ifile, prior_temp, nlevels_temp, fform)
integer,                 intent(in) :: ifile, nlevels_temp
real(r8), dimension(41), intent(in) :: prior_temp
character(len=*),        intent(in) :: fform
!
character(len=32)  :: fileformat
!
if ( .not. module_initialized ) call initialize_module
!
fileformat = trim(adjustl(fform))
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
   write(ifile) prior_temp(1:nlevels_temp)
   CASE DEFAULT
   write(ifile, *) prior_temp(1:nlevels_temp)
END SELECT
end subroutine write_iasi_prior
!
subroutine wrf_dart_ubval_interp(obs_val,del_prs,domain,species,lon,lat,lev,im2,istatus)
   use netcdf
   implicit none
   integer,parameter                                 :: nx1=2,ny1=96,nz1=38,nm1=12,nmspc1=8,nchr1=20
   integer,parameter                                 :: nx2=100,ny2=40,nz2=66,nm2=12
   integer                                           :: fid1,fid2,domain,rc,im2
   integer                                           :: i,j,k,imn1,istatus
   character(len=20)                                 :: species
   character(len=180)                                :: file_nam,file_in1,file_in2,path
   real(r8)                                          :: lon,lat,lev,del_lon1
   real(r8)                                          :: obs_val,del_prs    
   real,dimension(nx1,ny1)                           :: xlon1,xlat1
   real,dimension(ny1)                               :: xlat_tmp1
   real,dimension(nz1)                               :: xlev1,prs_tmp1
   real,dimension(ny1,nz1)                           :: fld1,fld_tmp1
   real,dimension(nx1,ny1,nz1)                       :: fldd1
   real,dimension(nx2,ny2)                           :: xlat2,xlon2
   real,dimension(nz2)                               :: xlev2,prs_tmp2
   real,dimension(nm2)                               :: ddoyr
   real,dimension(nx2,ny2,nz2,nm2)                   :: o3_col_dens
   real,dimension(nx2,ny2,nz2)                       :: fld_tmp2
   logical                                           :: use_interp_1
!
! decide with upper boundary data to use
   use_interp_1=.true.
   del_lon1=2.
!
! assign upper boundary profile files
   path='./'
!
! this file has OX NOX HNO3 CH4 CO N2X N2O5 H20
   file_in1='ubvals_b40.20th.track1_1996-2005.nc'
!
! this file has o3 only 
   file_in2='exo_coldens_d01'
   if(domain.eq.2) then
      file_in2='exo_coldens_d02'
   endif
!
! open upper boundary profile files
   if (use_interp_1) then
      file_nam=trim(path)//trim(file_in1)
      rc = nf90_open(trim(file_nam),NF90_NOWRITE,fid1)
      if(rc.ne.0) then
         print *, 'APM: nc_open error file=',trim(file_nam)
         call abort
      endif
!      print *, 'opened ',trim(file_nam)
   else
      file_nam=trim(path)//trim(file_in2)
      rc = nf90_open(trim(file_nam),NF90_NOWRITE,fid2)
      if(rc.ne.0) then
         print *, 'APM: nc_open error file=',trim(file_nam)
         call abort
      endif
!      print *, 'opened ',trim(file_nam)
   endif
!
! select upper boundary data from ubvals_b40.20th.track1_1996-2005.nc
   if (use_interp_1) then
      imn1=6
      call apm_get_ubvals(fid1,species,imn1,fld1,xlat_tmp1,xlev1)
      rc=nf90_close(fid1)
   else
!
! select upper boundary data from exo_coldens_dxx
      call apm_get_exo_coldens(fid2,'XLAT',xlat2,nx2,ny2,1,1)
!      print *, 'XLAT',xlat2(1,1),xlat2(nx2,ny2)
      call apm_get_exo_coldens(fid2,'XLONG',xlon2,nx2,ny2,1,1)
!      print *, 'XLON',xlon2(1,1),xlon2(nx2,ny2)
      call apm_get_exo_coldens(fid2,'coldens_levs',xlev2,nz2,1,1,1)
!      print *, 'coldens_levs',xlev2(:)
      call apm_get_exo_coldens(fid2,'days_of_year',ddoyr,nm2,1,1,1)
!      print *, 'ddoyr',ddoyr(1),ddoyr(nm2)
      call apm_get_exo_coldens(fid2,'o3_column_density',o3_col_dens,nx2,ny2,nz2,nm2)
!      print *, 'o3_coldens',o3_col_dens(1,1,1,1),o3_col_dens(nx2,ny2,nz2,nm2)
      rc=nf90_close(fid2)
   endif
!   print *, 'ny1,nz1 ',ny1,nz1
!   print *, 'fld1 ',fld1
!   print *, 'xlat1 ',xlat1
!   print *, 'xlev1 ',xlev1
!
! convert longitude to 0 - 360
   if (.not.  use_interp_1) then
      do i=1,nx2
         do j=1,ny2
            if(xlon2(i,j).lt.0.) then
               xlon2(i,j)=xlon2(i,j)+360.
            endif
         enddo
      enddo
   endif
!
! invert the pressure grid and data
   if (use_interp_1) then
      do k=1,nz1
         prs_tmp1(nz1-k+1)=xlev1(k)
         do j=1,ny1
            fld_tmp1(j,nz1-k+1)=fld1(j,k)
         enddo
      enddo
      xlev1(1:nz1)=prs_tmp1(1:nz1)*100.
      fldd1(1,1:ny1,1:nz1)=fld_tmp1(1:ny1,1:nz1)
      fldd1(2,1:ny1,1:nz1)=fld_tmp1(1:ny1,1:nz1)
!
! interpolate data1 to (lat,lev) point
      do j=1,ny1
         xlon1(1,j)=lon-del_lon1
         xlon1(2,j)=lon+del_lon1
         if(lon.lt.0.) then
            xlon1(1,j)=lon+360.-del_lon1
            xlon1(2,j)=lon+360.+del_lon1
         endif
         do i=1,nx1
            xlat1(i,j)=xlat_tmp1(j)
         enddo
      enddo
!      print *, 'IN UBVAL SUB: lon,lat,lev ',lon,lat,lev
!      print *, 'IN UBVAL SUB: xlon,xlat,xlev ',xlon1(1,48),xlat1(1,48)
!      do j=1,nz1
!        print *, 'IN UBVAL SUB: fldd1 ',j,xlev1(j),fldd1(1,48,j)
!      enddo
      call apm_interpolate(obs_val,del_prs,lon,lat,lev,xlon1,xlat1,xlev1, &
      fldd1,nx1,ny1,nz1,istatus)
!      print *, 'IN UBVAL SUB: obs_val,del_prs ',obs_val,del_prs
   else
      do k=1,nz2
         prs_tmp2(nz2-k+1)=xlev2(k)
         do i=1,nx2
            do j=1,ny2
               fld_tmp2(i,j,nz2-k+1)=o3_col_dens(i,j,k,im2)
            enddo
         enddo
      enddo
      xlev2(1:nz2)=prs_tmp2(1:nz2)
      o3_col_dens(1:nx2,1:ny2,1:nz2,im2)=fld_tmp2(1:nx2,1:ny2,1:nz2)
!
! interpolate data2 to (lat,lon,lev) point
      call apm_interpolate(obs_val,del_prs,lon,lat,lev,xlon2,xlat2,xlev2, &
      o3_col_dens(1,1,1,im2),nx2,ny2,nz2,istatus)
   endif
end subroutine wrf_dart_ubval_interp
!
subroutine apm_get_exo_coldens(fid,fldname,dataf,nx,ny,nz,nm)
   use netcdf
   implicit none
   integer,parameter                      :: maxdim=4
   integer                                :: nx,ny,nz,nm
   integer                                :: i,rc,v_ndim,natts,fid
   integer                                :: v_id,typ
   integer,dimension(maxdim)              :: v_dimid,v_dim,one
   character(len=*)                       :: fldname
   character(len=180)                     :: vnam
   real,dimension(nx,ny,nz,nm)            :: dataf
!
! get variables identifiers
   rc = nf90_inq_varid(fid,trim(fldname),v_id)
   if(rc.ne.0) then
      print *, 'APM: nf_inq_varid error'
      call abort
   endif
!
! get dimension identifiers
   v_dimid=0
   rc = nf90_inquire_variable(fid,v_id,vnam,typ,v_ndim,v_dimid,natts)
   if(rc.ne.0) then
      print *, 'APM: nc_inq_var error'
      call abort
   endif
   if(maxdim.lt.v_ndim) then
      print *, 'ERROR: maxdim is too small ',maxdim,v_ndim
      call abort
   endif 
!
! get dimensions
   v_dim(:)=1
   do i=1,v_ndim
      rc = nf90_inquire_dimension(fid,v_dimid(i),len=v_dim(i))
      if(rc.ne.0) then
         print *, 'APM: nf_inq_dimlen error'
         call abort
      endif
   enddo
!
! check dimensions
   if(nx.ne.v_dim(1)) then
      print *, 'ERROR: nx dimension conflict ',nx,v_dim(1)
      call abort
   else if(ny.ne.v_dim(2)) then             
      print *, 'ERROR: ny dimension conflict ',ny,v_dim(2)
      call abort
   else if(nz.ne.v_dim(3)) then             
      print *, 'ERROR: nz dimension conflict ',nz,v_dim(3)
      call abort
   else if(nm.ne.v_dim(4)) then             
      print *, 'ERROR: nm dimension conflict ',nm,v_dim(4)
      call abort
   endif
!
! get data
   one(:)=1
   rc = nf90_get_var(fid,v_id,dataf,one,v_dim)
end subroutine apm_get_exo_coldens
!
subroutine apm_get_ubvals(fid,species,imn,dataf,lats,levs)
   use netcdf
   implicit none
   integer,parameter                                 :: maxdim=4
   integer,parameter                                 :: ny1=96,nz1=38,nm1=12,nmspc1=8,nmchr1=20
   integer                                           :: i,j,idx,fid,rc,typ,natts,imn
   integer                                           :: vid1,vid2,vid3,vid4,vid5
   integer                                           :: vndim1,vndim2,vndim3,vndim4,vndim5
   integer,dimension(maxdim)                         :: vdimid1,vdimid2,vdimid3,vdimid4,vdimid5
   integer,dimension(maxdim)                         :: one,vdim1,vdim2,vdim3,vdim4,vdim5
   integer,dimension(nm1)                            :: mths
   character(len=20)                                 :: species
   character(len=nmchr1),dimension(nmchr1,nmspc1)    :: spcs    
   character(len=180)                                :: vnam1,vnam2,vnam3,vnam4,vnam5
   real,dimension(ny1)                               :: lats
   real,dimension(nz1)                               :: levs
   real,dimension(ny1,nmspc1,nm1,nz1)                :: vmrs
   real,dimension(ny1,nz1)                           :: dataf
!
! get variables identifiers
   rc = nf90_inq_varid(fid,'lat',vid1)
   if(rc.ne.0) then
      print *, 'APM: nf_inq_varid error_1'
      call abort
   endif
   rc = nf90_inq_varid(fid,'lev',vid2)
   if(rc.ne.0) then
      print *, 'APM: nf_inq_varid error_2'
      call abort
   endif
   rc = nf90_inq_varid(fid,'month',vid3)
   if(rc.ne.0) then
      print *, 'APM: nf_inq_varid error_3'
      call abort
   endif
   rc = nf90_inq_varid(fid,'specname',vid4)
   if(rc.ne.0) then
      print *, 'APM: nf_inq_varid error_4'
      call abort
   endif
   rc = nf90_inq_varid(fid,'vmr',vid5)
   if(rc.ne.0) then
      print *, 'APM: nf_inq_varid error_5'
      call abort
   endif
!
! get dimension identifiers
   vdimid1=0
   rc = nf90_inquire_variable(fid,vid1,vnam1,typ,vndim1,vdimid1,natts)
   if(rc.ne.0) then
      print *, 'APM: nc_inq_var error_1'
      call abort
   endif
   vdimid2=0
   rc = nf90_inquire_variable(fid,vid2,vnam2,typ,vndim2,vdimid2,natts)
   if(rc.ne.0) then
      print *, 'APM: nc_inq_var error_2'
      call abort
   endif
   vdimid3=0
   rc = nf90_inquire_variable(fid,vid3,vnam3,typ,vndim3,vdimid3,natts)
   if(rc.ne.0) then
      print *, 'APM: nc_inq_var error_3'
      call abort
   endif
   vdimid4=0
   rc = nf90_inquire_variable(fid,vid4,vnam4,typ,vndim4,vdimid4,natts)
   if(rc.ne.0) then
      print *, 'APM: nc_inq_var error_4'
      call abort
   endif
   vdimid5=0
   rc = nf90_inquire_variable(fid,vid5,vnam5,typ,vndim5,vdimid5,natts)
   if(rc.ne.0) then
      print *, 'APM: nc_inq_var error_5'
      call abort
   endif
!
! test the number of dimensions
   if(1.lt.vndim1) then
      print *, 'ERROR: maxdim is too small 1 ',1,vndim1
      call abort
   endif 
   if(1.lt.vndim2) then
      print *, 'ERROR: maxdim is too small 2 ',1,vndim2
      call abort
   endif 
   if(1.lt.vndim3) then
      print *, 'ERROR: maxdim is too small 3 ',1,vndim3
      call abort
   endif 
   if(2.lt.vndim4) then
      print *, 'ERROR: maxdim is too small 4',1,vndim4
      call abort
   endif 
   if(4.lt.vndim5) then
      print *, 'ERROR: maxdim is too small 5',1,vndim5
      call abort
   endif 
!
! get dimensions
   vdim1(:)=1
   do i=1,vndim1
      rc = nf90_inquire_dimension(fid,vdimid1(i),len=vdim1(i))
      if(rc.ne.0) then
         print *, 'APM: nf_inq_dimlen error_1'
         call abort
      endif
   enddo
   vdim2(:)=1
   do i=1,vndim2
      rc = nf90_inquire_dimension(fid,vdimid2(i),len=vdim2(i))
      if(rc.ne.0) then
         print *, 'APM: nf_inq_dimlen error_2'
         call abort
      endif
   enddo
   vdim3(:)=1
   do i=1,vndim3
      rc = nf90_inquire_dimension(fid,vdimid3(i),len=vdim3(i))
      if(rc.ne.0) then
         print *, 'APM: nf_inq_dimlen error_3'
         call abort
      endif
   enddo
   vdim4(:)=1
   do i=1,vndim4
      rc = nf90_inquire_dimension(fid,vdimid4(i),len=vdim4(i))
      if(rc.ne.0) then
         print *, 'APM: nf_inq_dimlen error_4'
         call abort
      endif
   enddo
   vdim5(:)=1
   do i=1,vndim5
      rc = nf90_inquire_dimension(fid,vdimid5(i),len=vdim5(i))
      if(rc.ne.0) then
         print *, 'APM: nf_inq_dimlen error_5'
         call abort
      endif
   enddo
!
! check dimensions
   if(ny1.ne.vdim1(1)) then
      print *, 'ERROR: ny1 dimension conflict 1 ',ny1,vdim1(1)
      call abort
   else if(nz1.ne.vdim2(1)) then             
      print *, 'ERROR: nz1 dimension conflict 2 ',nz1,vdim2(1)
      call abort
   else if(nm1.ne.vdim3(1)) then             
      print *, 'ERROR: nm1 dimension conflict 3 ',nm1,vdim3(1)
      call abort
   endif
   if(nmchr1.ne.vdim4(1)) then             
      print *, 'ERROR: nmchr1 dimension conflict 4 ',nmchr1,vdim4(1)
      call abort
   else if(nmspc1.ne.vdim4(2)) then             
      print *, 'ERROR: nmspc1 dimension conflict 4 ',nmspc1,vdim4(2)
      call abort
   endif
   if(ny1.ne.vdim5(1)) then
      print *, 'ERROR: ny1 dimension conflict 5 ',ny1,vdim5(1)
      call abort
   else if(nmspc1.ne.vdim5(2)) then             
      print *, 'ERROR: nmspc1 dimension conflict 5 ',nmspc1,vdim5(2)
      call abort
   else if(nm1.ne.vdim5(3)) then             
      print *, 'ERROR: nm1 dimension conflict 5 ',nm1,vdim5(3)
      call abort
   else if(nz1.ne.vdim5(4)) then             
      print *, 'ERROR: nz1 dimension conflict 5 ',nz1,vdim5(4)
      call abort
   endif
!
! get data
   one(:)=1
   rc = nf90_get_var(fid,vid1,lats,one,vdim1)
   if(rc.ne.0) then
      print *, 'APM: get_var error_1'
      call abort
   endif
!   print *, 'lats ',lats
   one(:)=1
   rc = nf90_get_var(fid,vid2,levs,one,vdim2)
   if(rc.ne.0) then
      print *, 'APM: get_var error_2'
      call abort
   endif
!   print *, 'levs ',levs
   one(:)=1
   rc = nf90_get_var(fid,vid3,mths,one,vdim3)
   if(rc.ne.0) then
      print *, 'APM: get_var error_3'
      call abort
   endif
!   print *, 'mths ',mths
   one(:)=1
   rc = nf90_get_var(fid,vid4,spcs,one,vdim4)
   if(rc.ne.0) then
      print *, 'APM: get_var error_4'
      call abort
   endif
!   print *, 'spcs ',spcs
   one(:)=1
   rc = nf90_get_var(fid,vid5,vmrs,one,vdim5)
   if(rc.ne.0) then
      print *, 'APM: get_var error_5'
      call abort
   endif
!   print *, 'vmrs ',vmrs
!
! locate requested field
  do i=1,nmspc1
     if(trim(species).eq.trim(spcs(i,1))) then
        idx=i
        exit
     endif
  enddo
   do i=1,ny1
      do j=1,nz1
         dataf(i,j)=vmrs(i,idx,imn,j)
      enddo
   enddo
end subroutine apm_get_ubvals
!
subroutine apm_interpolate(obs_val,del_prs,lon,lat,lev,xlon,xlat,xlev,dataf,nx,ny,nz,istatus)
!
! longitude and latitude must be in degrees
! pressure grid must be in hPa and go from bottom to top
!
   implicit none
   integer                                :: nx,ny,nz,nzm,istatus
   integer                                :: i,j,k,im,ip,jm,jp,quad
   integer                                :: k_lw,k_up,i_min,j_min 
   real(r8)                               :: obs_val,del_prs
   real(r8)                               :: lon,lat,lev
   real                                   :: l_lon,l_lat,l_lev
   real                                   :: fld_lw,fld_up
   real                                   :: xlnp_lw,xlnp_up,xlnp_pt
   real                                   :: dz_lw,dz_up
   real                                   :: mop_x,mop_y
   real                                   :: re,pi,rad2deg
   real                                   :: rad,rad_crit,rad_min,mod_x,mod_y
   real                                   :: dx_dis,dy_dis
   real                                   :: w_q1,w_q2,w_q3,w_q4,wt
   real,dimension(nz)                     :: xlev
   real,dimension(nx,ny)                  :: xlon,xlat
   real,dimension(nx,ny,nz)               :: dataf
!
! set constants
   pi=4.*atan(1.)
   rad2deg=360./(2.*pi)
   re=6371000.
   rad_crit=200000.
   quad=0
!
! find the closest point            
   rad_min=1.e10
   l_lon=lon
   l_lat=lat
   l_lev=lev
   if(l_lon.lt.0.) l_lon=l_lon+360.
!   print *, 'lon,lat,lev ',l_lon,l_lat,l_lev
!
   do i=1,nx
      do j=1,ny
         mod_x=(xlon(i,j))/rad2deg
         if(xlon(i,j).lt.0.) mod_x=(360.+xlon(i,j))/rad2deg
         mod_y=xlat(i,j)/rad2deg
         mop_x=l_lon/rad2deg
         mop_y=l_lat/rad2deg
         dx_dis=abs(mop_x-mod_x)*cos((mop_y+mod_y)/2.)*re
         dy_dis=abs(mop_y-mod_y)*re
         rad=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)  
         rad_min=min(rad_min,rad)
         if(rad.eq.rad_min) then
            i_min=i
            j_min=j
         endif 
      enddo
   enddo
   if(rad_min.gt.rad_crit) then            
      print *, 'APM: ERROR in intrp - min dist exceeds threshold ',rad_min, rad_crit
      print *, 'grid ',i_min,j_min,xlon(i_min,j_min),xlat(i_min,j_min)
      print *, 'point ',l_lon,l_lat
      istatus=2
      return
!      call abort
   endif
!
! do interpolation
   im=i_min-1
   if(im.eq.0) im=1
   ip=i_min+1
   if(ip.eq.nx+1) ip=nx
   jm=j_min-1
   if(jm.eq.0) jm=1
   jp=j_min+1
   if(jp.eq.ny+1) jp=ny
!
! find quadrant and interpolation weights
   quad=0
   mod_x=xlon(i_min,j_min)
   if(xlon(i_min,j_min).lt.0.) mod_x=xlon(i_min,j_min)+360.
   mod_y=xlat(i_min,j_min)
   if(mod_x.ge.l_lon.and.mod_y.ge.l_lat) quad=1 
   if(mod_x.le.l_lon.and.mod_y.ge.l_lat) quad=2 
   if(mod_x.le.l_lon.and.mod_y.le.l_lat) quad=3 
   if(mod_x.ge.l_lon.and.mod_y.le.l_lat) quad=4
   if(quad.eq.0) then
      print *, 'APM: ERROR IN INTERPOLATE quad = 0 '
      call abort
   endif
!
! Quad 1
   if (quad.eq.1) then
      mod_x=xlon(i_min,j_min)
      if(xlon(i_min,j_min).lt.0.) mod_x=360.+xlon(i_min,j_min) 
      dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(i_min,j_min))/rad2deg/2.)*re
      dy_dis=abs(l_lat-xlat(i_min,j_min))/rad2deg*re
      w_q1=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
      mod_x=xlon(im,j_min)
      if(xlon(im,j_min).lt.0.) mod_x=360.+xlon(im,j_min) 
      dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(im,j_min))/rad2deg/2.)*re
      dy_dis=abs(l_lat-xlat(im,j_min))/rad2deg*re
      w_q2=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
      mod_x=xlon(im,jm)
      if(xlon(im,jm).lt.0.) mod_x=360.+xlon(im,jm) 
      dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(im,jm))/rad2deg/2.)*re
      dy_dis=abs(l_lat-xlat(im,jm))/rad2deg*re
      w_q3=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
      mod_x=xlon(i_min,jm)
      if(xlon(i_min,jm).lt.0.) mod_x=360.+xlon(i_min,jm) 
      dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(i_min,jm))/rad2deg/2.)*re
      dy_dis=abs(l_lat-xlat(i_min,jm))/rad2deg*re
      w_q4=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
! Quad 2
   else if (quad.eq.2) then
      mod_x=xlon(ip,j_min)
      if(xlon(ip,j_min).lt.0.) mod_x=360.+xlon(ip,j_min) 
      dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(ip,j_min))/rad2deg/2.)*re
      dy_dis=abs(l_lat-xlat(ip,j_min))/rad2deg*re
      w_q1=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
      mod_x=xlon(i_min,j_min)
      if(xlon(i_min,j_min).lt.0.) mod_x=360.+xlon(i_min,j_min) 
      dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(i_min,j_min))/rad2deg/2.)*re
      dy_dis=abs(l_lat-xlat(i_min,j_min))/rad2deg*re
      w_q2=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
      mod_x=xlon(i_min,jm)
      if(xlon(i_min,jm).lt.0.) mod_x=360.+xlon(i_min,jm) 
      dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(i_min,jm))/rad2deg/2.)*re
      dy_dis=abs(l_lat-xlat(i_min,jm))/rad2deg*re
      w_q3=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
      mod_x=xlon(ip,jm)
      if(xlon(ip,jm).lt.0.) mod_x=360.+xlon(ip,jm) 
      dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(ip,jm))/rad2deg/2.)*re
      dy_dis=abs(l_lat-xlat(ip,jm))/rad2deg*re
      w_q4=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
! Quad 3
   else if (quad.eq.3) then
      mod_x=xlon(ip,jp)
      if(xlon(ip,jp).lt.0.) mod_x=360.+xlon(ip,jp) 
      dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(ip,jp))/rad2deg/2.)*re
      dy_dis=abs(l_lat-xlat(ip,jp))/rad2deg*re
      w_q1=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
      mod_x=xlon(i_min,jp)
      if(xlon(i_min,jp).lt.0.) mod_x=360.+xlon(i_min,jp) 
      dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(i_min,jp))/rad2deg/2.)*re
      dy_dis=abs(l_lat-xlat(i_min,jp))/rad2deg*re
      w_q2=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
      mod_x=xlon(i_min,j_min)
      if(xlon(i_min,j_min).lt.0.) mod_x=360.+xlon(i_min,j_min) 
      dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(i_min,j_min))/rad2deg/2.)*re
      dy_dis=abs(l_lat-xlat(i_min,j_min))/rad2deg*re
      w_q3=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
      mod_x=xlon(ip,j_min)
      if(xlon(ip,j_min).lt.0.) mod_x=360.+xlon(ip,j_min) 
      dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(ip,j_min))/rad2deg/2.)*re
      dy_dis=abs(l_lat-xlat(ip,j_min))/rad2deg*re
      w_q4=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
! Quad 4
   else if (quad.eq.4) then
      mod_x=xlon(i_min,jp)
      if(xlon(i_min,jp).lt.0.) mod_x=360.+xlon(i_min,jp) 
      dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(i_min,jp))/rad2deg/2.)*re
      dy_dis=abs(l_lat-xlat(i_min,jp))/rad2deg*re
      w_q1=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
      mod_x=xlon(im,jp)
      if(xlon(im,jp).lt.0.) mod_x=360.+xlon(im,jp) 
      dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(im,jp))/rad2deg/2.)*re
      dy_dis=abs(l_lat-xlat(im,jp))/rad2deg*re
      w_q2=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
      mod_x=xlon(im,jm)
      if(xlon(im,jm).lt.0.) mod_x=360.+xlon(im,jm) 
      dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(im,jm))/rad2deg/2.)*re
      dy_dis=abs(l_lat-xlat(im,jm))/rad2deg*re
      w_q3=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
      mod_x=xlon(i_min,j_min)
      if(xlon(i_min,j_min).lt.0.) mod_x=360.+xlon(i_min,j_min) 
      dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(i_min,j_min))/rad2deg/2.)*re
      dy_dis=abs(l_lat-xlat(i_min,j_min))/rad2deg*re
      w_q4=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
   endif
   if(l_lon.ne.xlon(i_min,j_min).or.l_lat.ne.xlat(i_min,j_min)) then
      wt=1./w_q1+1./w_q2+1./w_q3+1./w_q4
   endif
!
! find vertical indexes
   nzm=nz-1
   k_lw=-1
   k_up=-1
   do k=1,nzm
      if(k.eq.1 .and. l_lev.gt.xlev(k)) then
         k_lw=k
         k_up=k
         exit
      endif
      if(l_lev.le.xlev(k) .and. l_lev.gt.xlev(k+1)) then
         k_lw=k
         k_up=k+1
         exit
      endif
      if(k.eq.nzm .and. l_lev.ge.xlev(k+1)) then
         k_lw=k+1
         k_up=k+1
         exit
      endif
   enddo
   if(k_lw.le.0 .or. k_up.le.0) then
      print *, 'APM: ERROR IN K_LW OR K_UP ',k_lw,k_up
      call abort
   endif
!
! horizontal interpolation             
   fld_lw=0.
   fld_up=0.   
   if(l_lon.eq.xlon(i_min,j_min).and.l_lat.eq.xlat(i_min,j_min)) then
      fld_lw=dataf(i_min,j_min,k_lw)
      fld_up=dataf(i_min,j_min,k_up)
   else if(quad.eq.1) then
      fld_lw=(1./w_q1*dataf(i_min,j_min,k_lw)+1./w_q2*dataf(im,j_min,k_lw)+ &
      1./w_q3*dataf(im,jm,k_lw)+1./w_q4*dataf(i_min,jm,k_lw))/wt
      fld_up=(1./w_q1*dataf(i_min,j_min,k_up)+1./w_q2*dataf(im,j_min,k_up)+ &
      1./w_q3*dataf(im,jm,k_up)+1./w_q4*dataf(i_min,jm,k_up))/wt
   else if(quad.eq.2) then
      fld_lw=(1./w_q1*dataf(ip,j_min,k_lw)+1./w_q2*dataf(i_min,j_min,k_lw)+ &
      1./w_q3*dataf(i_min,jm,k_lw)+1./w_q4*dataf(ip,jm,k_lw))/wt
      fld_up=(1./w_q1*dataf(ip,j_min,k_up)+1./w_q2*dataf(i_min,j_min,k_up)+ &
      1./w_q3*dataf(i_min,jm,k_up)+1./w_q4*dataf(ip,jm,k_up))/wt
   else if(quad.eq.3) then
      fld_lw=(1./w_q1*dataf(ip,jp,k_lw)+1./w_q2*dataf(i_min,jp,k_lw)+ &
      1./w_q3*dataf(i_min,j_min,k_lw)+1./w_q4*dataf(ip,j_min,k_lw))/wt
      fld_up=(1./w_q1*dataf(ip,jp,k_up)+1./w_q2*dataf(i_min,jp,k_up)+ &
      1./w_q3*dataf(i_min,j_min,k_up)+1./w_q4*dataf(ip,j_min,k_up))/wt
   else if(quad.eq.4) then
      fld_lw=(1./w_q1*dataf(i_min,jp,k_lw)+1./w_q2*dataf(im,jp,k_lw)+ &
      1./w_q3*dataf(im,j_min,k_lw)+1./w_q4*dataf(i_min,j_min,k_lw))/wt
      fld_up=(1./w_q1*dataf(i_min,jp,k_up)+1./w_q2*dataf(im,jp,k_up)+ &
      1./w_q3*dataf(im,j_min,k_up)+1./w_q4*dataf(i_min,j_min,k_up))/wt
   endif 
!   print *,'fld_lw ',fld_lw
!   print *,'fld_up ',fld_up
!
! vertical interpolation
!   print *,'p_lw,p_up,p ',xlev(k_lw),xlev(k_up),l_lev

   xlnp_lw=log(xlev(k_lw))
   xlnp_up=log(xlev(k_up))
   xlnp_pt=log(l_lev)
   dz_lw=xlnp_lw-xlnp_pt
   dz_up=xlnp_pt-xlnp_up
   if(dz_lw.eq.0.) then
      obs_val=fld_lw
   else if(dz_up.eq.0.) then
      obs_val=fld_up
   else if(dz_lw.ne.0. .and. dz_up.ne.0.) then
      obs_val=(1./dz_lw*fld_lw+1./dz_up*fld_up)/(1./dz_lw+1./dz_up)
   endif
   del_prs=xlev(k_lw)-xlev(k_up)
end subroutine apm_interpolate


end module obs_def_iasi_O3_mod

! END DART PREPROCESS MODULE CODE

! <next few lines under version control, do not edit>
! $URL$
! $Id$
! $Revision$
! $Date$
