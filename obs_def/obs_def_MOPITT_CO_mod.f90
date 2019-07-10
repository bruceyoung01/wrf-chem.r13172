! DART software - Copyright 2004 - 2013 UCAR. This open source software is
! provided by UCAR, "as is", without charge, subject to all terms of use at
! http://www.image.ucar.edu/DAReS/DART/DART_download
!
! DART $Id$

! BEGIN DART PREPROCESS KIND LIST
! MOPITT_CO_RETRIEVAL, KIND_CO
! END DART PREPROCESS KIND LIST

! BEGIN DART PREPROCESS USE OF SPECIAL OBS_DEF MODULE
!   use obs_def_mopitt_mod, only : write_mopitt_co, read_mopitt_co, &
!                                  interactive_mopitt_co, get_expected_mopitt_co, &
!                                  set_obs_def_mopitt_co
! END DART PREPROCESS USE OF SPECIAL OBS_DEF MODULE

! BEGIN DART PREPROCESS GET_EXPECTED_OBS_FROM_DEF
!         case(MOPITT_CO_RETRIEVAL)                                                           
!            call get_expected_mopitt_co(state, location, obs_def%key, obs_val, istatus)  
! END DART PREPROCESS GET_EXPECTED_OBS_FROM_DEF

! BEGIN DART PREPROCESS READ_OBS_DEF
!      case(MOPITT_CO_RETRIEVAL)
!         call read_mopitt_co(obs_def%key, ifile, fileformat)
! END DART PREPROCESS READ_OBS_DEF

! BEGIN DART PREPROCESS WRITE_OBS_DEF
!      case(MOPITT_CO_RETRIEVAL)
!         call write_mopitt_co(obs_def%key, ifile, fileformat)
! END DART PREPROCESS WRITE_OBS_DEF

! BEGIN DART PREPROCESS INTERACTIVE_OBS_DEF
!      case(MOPITT_CO_RETRIEVAL)
!         call interactive_mopitt_co(obs_def%key)
! END DART PREPROCESS INTERACTIVE_OBS_DEF

! BEGIN DART PREPROCESS SET_OBS_DEF_MOPITT_CO
!      case(MOPITT_CO_RETRIEVAL)
!         call set_obs_def_mopitt_co(obs_def%key)
! END DART PREPROCESS SET_OBS_DEF_MOPITT_CO


! BEGIN DART PREPROCESS MODULE CODE
module obs_def_mopitt_mod

use        types_mod, only : r8, missing_r8
use    utilities_mod, only : register_module, error_handler, E_ERR, E_MSG, &
                             nmlfileunit, check_namelist_read, &
                             find_namelist_in_file, do_nml_file, do_nml_term, &
                             ascii_file_format
use     location_mod, only : location_type, set_location, get_location, VERTISPRESSURE, VERTISLEVEL, VERTISSURFACE, VERTISUNDEF

use  assim_model_mod, only : interpolate
use    obs_kind_mod, only  : KIND_CO, KIND_SURFACE_PRESSURE, KIND_PRESSURE, KIND_LANDMASK

implicit none
private

public :: write_mopitt_co, &
          read_mopitt_co, &
          interactive_mopitt_co, &
          get_expected_mopitt_co, &
          set_obs_def_mopitt_co

! Storage for the special information required for observations of this type
integer, parameter               :: MAX_MOPITT_CO_OBS = 10000000
integer, parameter               :: MOPITT_DIM = 10
integer                          :: num_mopitt_co_obs = 0
!
! MOPITT pressures (level 1 is place holder for surface pressure)
real(r8)   :: mopitt_pressure(MOPITT_DIM) =(/ &
                              100000.,90000.,80000.,70000.,60000.,50000.,40000.,30000.,20000.,1000. /)
real(r8)   :: mopitt_pressure_mid(MOPITT_DIM) =(/ &
                              100000.,85000.,75000.,65000.,55000.,45000.,35000.,25000.,15000.,7500. /)

real(r8), allocatable, dimension(:,:) :: avg_kernel
real(r8), allocatable, dimension(:) :: mopitt_prior
real(r8), allocatable, dimension(:) :: mopitt_psurf
integer,  allocatable, dimension(:) :: mopitt_nlevels

! version controlled file description for error handling, do not edit
character(len=*), parameter :: source   = &
   "$URL$"
character(len=*), parameter :: revision = "$Revision$"
character(len=*), parameter :: revdate  = "$Date$"

character(len=512) :: string1, string2

logical, save :: module_initialized = .false.
integer  :: counts1 = 0

character(len=129)  :: MOPITT_CO_retrieval_type
logical             :: use_log_co
!
! MOPITT_CO_retrieval_type:
!     RAWR - retrievals in VMR (ppb) units
!     RETR - retrievals in log10(VMR ([ ])) units
!     QOR  - quasi-optimal retrievals
!     CPSR - compact phase space retrievals
    namelist /obs_def_MOPITT_CO_nml/ MOPITT_CO_retrieval_type, use_log_co

contains

!----------------------------------------------------------------------

subroutine initialize_module

integer :: iunit, rc

! Prevent multiple calls from executing this code more than once.
if (module_initialized) return

call register_module(source, revision, revdate)
module_initialized = .true.

allocate (avg_kernel(    MAX_MOPITT_CO_OBS,MOPITT_DIM))
allocate (mopitt_prior(  MAX_MOPITT_CO_OBS))
allocate (mopitt_psurf(  MAX_MOPITT_CO_OBS))
allocate (mopitt_nlevels(MAX_MOPITT_CO_OBS))

! Read the namelist entry.
MOPITT_CO_retrieval_type='RETR'
use_log_co=.false.
call find_namelist_in_file("input.nml", "obs_def_MOPITT_CO_nml", iunit)
read(iunit, nml = obs_def_MOPITT_CO_nml, iostat = rc)
call check_namelist_read(iunit, rc, "obs_def_MOPITT_CO_nml")

! Record the namelist values used for the run ... 
if (do_nml_file()) write(nmlfileunit, nml=obs_def_MOPITT_CO_nml)
if (do_nml_term()) write(     *     , nml=obs_def_MOPITT_CO_nml)

end subroutine initialize_module

subroutine read_mopitt_co(key, ifile, fform)
!----------------------------------------------------------------------
!subroutine read_mopitt_co(key, ifile, fform)

integer,          intent(out)          :: key
integer,          intent(in)           :: ifile
character(len=*), intent(in), optional :: fform

character(len=32)               :: fileformat

integer                         :: mopitt_nlevels_1
real(r8)                        :: mopitt_prior_1
real(r8)                        :: mopitt_psurf_1
real(r8), dimension(MOPITT_DIM) :: avg_kernels_1
integer                         :: keyin

if ( .not. module_initialized ) call initialize_module

fileformat = "ascii"   ! supply default
if(present(fform)) fileformat = trim(adjustl(fform))

! Philosophy, read ALL information about this special obs_type at once???
! For now, this means you can only read ONCE (that's all we're doing 3 June 05)
! Toggle the flag to control this reading
avg_kernels_1(:) = 0.0_r8
SELECT CASE (fileformat)
   CASE ("unf", "UNF", "unformatted", "UNFORMATTED")
   mopitt_nlevels_1 = read_mopitt_nlevels(ifile, fileformat)
   mopitt_prior_1 = read_mopitt_prior(ifile, fileformat)
   mopitt_psurf_1 = read_mopitt_psurf(ifile, fileformat)
   avg_kernels_1(1:mopitt_nlevels_1)  = read_mopitt_avg_kernels(ifile, mopitt_nlevels_1, fileformat)
   read(ifile) keyin
   CASE DEFAULT
   mopitt_nlevels_1 = read_mopitt_nlevels(ifile, fileformat)
   mopitt_prior_1 = read_mopitt_prior(ifile, fileformat)
   mopitt_psurf_1 = read_mopitt_psurf(ifile, fileformat)
   avg_kernels_1(1:mopitt_nlevels_1)  = read_mopitt_avg_kernels(ifile, mopitt_nlevels_1, fileformat)
   read(ifile, *) keyin
END SELECT

counts1 = counts1 + 1
key = counts1
call set_obs_def_mopitt_co(key, avg_kernels_1, mopitt_prior_1, mopitt_psurf_1, &
                           mopitt_nlevels_1)
end subroutine read_mopitt_co

 subroutine write_mopitt_co(key, ifile, fform)
!----------------------------------------------------------------------
!subroutine write_mopitt_co(key, ifile, fform)

integer,          intent(in)           :: key
integer,          intent(in)           :: ifile
character(len=*), intent(in), optional :: fform

character(len=32) :: fileformat
real(r8), dimension(MOPITT_DIM) :: avg_kernels_temp

if ( .not. module_initialized ) call initialize_module

fileformat = "ascii"   ! supply default
if(present(fform)) fileformat = trim(adjustl(fform))

! Philosophy, read ALL information about this special obs_type at once???
! For now, this means you can only read ONCE (that's all we're doing 3 June 05)
! Toggle the flag to control this reading
   
avg_kernels_temp=avg_kernel(key,:)

SELECT CASE (fileformat)
   
   CASE ("unf", "UNF", "unformatted", "UNFORMATTED")
   call write_mopitt_nlevels(ifile, mopitt_nlevels(key), fileformat)
   call write_mopitt_prior(ifile, mopitt_prior(key), fileformat)
   call write_mopitt_psurf(ifile, mopitt_psurf(key), fileformat)
   call write_mopitt_avg_kernels(ifile, avg_kernels_temp, mopitt_nlevels(key), fileformat)
   write(ifile) key

   CASE DEFAULT
   call write_mopitt_nlevels(ifile, mopitt_nlevels(key), fileformat)
   call write_mopitt_prior(ifile, mopitt_prior(key), fileformat)
   call write_mopitt_psurf(ifile, mopitt_psurf(key), fileformat)
   call write_mopitt_avg_kernels(ifile, avg_kernels_temp, mopitt_nlevels(key), fileformat)
   write(ifile, *) key
END SELECT 
end subroutine write_mopitt_co
!
subroutine interactive_mopitt_co(key)
!----------------------------------------------------------------------
!subroutine interactive_mopitt_co(key)
!
! Initializes the specialized part of a MOPITT observation
! Passes back up the key for this one

integer, intent(out) :: key

if ( .not. module_initialized ) call initialize_module

! Make sure there's enough space, if not die for now (clean later)
if(num_mopitt_co_obs >= MAX_MOPITT_CO_OBS) then
   write(string1, *)'Not enough space for a mopitt CO obs.'
   write(string2, *)'Can only have MAX_MOPITT_CO_OBS (currently ',MAX_MOPITT_CO_OBS,')'
   call error_handler(E_ERR,'interactive_mopitt_co',string1,source,revision,revdate, text2=string2)
endif

! Increment the index
num_mopitt_co_obs = num_mopitt_co_obs + 1
key = num_mopitt_co_obs

! Otherwise, prompt for input for the three required beasts
write(*, *) 'Creating an interactive_mopitt_co observation'
write(*, *) 'Input the MOPITT Prior '
read(*, *) mopitt_prior
write(*, *) 'Input MOPITT Surface Pressure '
read(*, *) mopitt_psurf(num_mopitt_co_obs)
write(*, *) 'Input the 10 Averaging Kernel Weights '
read(*, *) avg_kernel(num_mopitt_co_obs,:)
end subroutine interactive_mopitt_co
!
subroutine get_expected_mopitt_co(state, location, key, val, istatus)
!----------------------------------------------------------------------
!subroutine get_expected_mopitt_co(state, location, key, val, istatus)
   real(r8),            intent(in)  :: state(:)
   type(location_type), intent(in)  :: location
   integer,             intent(in)  :: key
   real(r8),            intent(out) :: val
   integer,             intent(out) :: istatus
!
   integer,parameter   :: wrf_nlev=33
   integer             :: i, kstr, ilev
   type(location_type) :: loc2
   real(r8)            :: mloc(3), prs_wrf(wrf_nlev)
   real(r8)            :: obs_val, co_min, co_min_log, level, missing
   real(r8)            :: prs_wrf_sfc, co_wrf_sfc
   real(r8)            :: prs_wrf_1, prs_wrf_2, co_wrf_1, co_wrf_2, prs_wrf_nlev
   real(r8)            :: prs_mopitt_sfc, prs_mopitt
   integer             :: nlevels,nlevelsp

   real(r8)            :: vert_mode_filt

   character(len=*), parameter :: routine = 'get_expected_mopitt_co'
!
! Initialize DART
   if ( .not. module_initialized ) call initialize_module
!
! Initialize variables (MOPITT is ppbv; WRF CO is ppmv)
   co_min      = 1.e-2
   co_min_log  = log(co_min)
   missing     = -888888.0_r8
   nlevels     = mopitt_nlevels(key)
   if ( use_log_co ) then
      co_min=co_min_log
   endif
!
! Get location infomation
   mloc = get_location(location)
   if (mloc(2)>90.0_r8) then
      mloc(2)=90.0_r8
   elseif (mloc(2)<-90.0_r8) then
      mloc(2)=-90.0_r8
   endif
!
! MOPITT surface pressure
   prs_mopitt_sfc = mopitt_psurf(key)
   mopitt_pressure(1)=mopitt_psurf(key)
!
! WRF surface pressure
   level=0.0_r8
   loc2 = set_location(mloc(1), mloc(2), level, VERTISSURFACE)
   istatus=0
   call interpolate(state, loc2, KIND_SURFACE_PRESSURE, prs_wrf_sfc, istatus)  
   if(istatus/=0) then
      write(string1, *)'APM NOTICE: WRF prs_wrf_sfc is bad ',istatus
      call error_handler(E_MSG,'set_obs_def_mopitt_co',string1,source,revision,revdate)
      val=missing
      return
   endif
!
! WRF pressure first level
   level=1.0_r8
   loc2 = set_location(mloc(1), mloc(2), level, VERTISLEVEL)
   istatus = 0
   call interpolate(state, loc2, KIND_PRESSURE, prs_wrf_1, istatus)
   if(istatus/=0) then
      write(string1, *)'APM NOTICE: WRF prs_wrf_1 is bad ',istatus
      call error_handler(E_MSG,'set_obs_def_mopitt_co',string1,source,revision,revdate)
      val=missing
      return
   endif
!
! WRF pressure second level
   level=2.0_r8
   loc2 = set_location(mloc(1), mloc(2), level, VERTISLEVEL)
   istatus = 0
   call interpolate(state, loc2, KIND_PRESSURE, prs_wrf_2, istatus)
   if(istatus/=0) then
      write(string1, *)'APM NOTICE: WRF prs_wrf_2 is bad ',istatus,prs_wrf_2
      call error_handler(E_MSG,'set_obs_def_mopitt_co',string1,source,revision,revdate)
      val=missing
      return
   endif
!
! WRF carbon monoxide at first level
   level=1.0_r8
   loc2 = set_location(mloc(1), mloc(2), level, VERTISLEVEL)
   istatus=0
   call interpolate(state, loc2, KIND_co, co_wrf_1, istatus) 
   co_wrf_sfc=co_wrf_1
   if(istatus/=0) then
      write(string1, *)'APM NOTICE: WRF co_wrf_1 is bad ',istatus,prs_wrf_1,co_wrf_1
      call error_handler(E_MSG,'set_obs_def_mopitt_co',string1,source,revision,revdate)
      val=missing
      return
   endif              
!
! Apply MOPITT Averaging kernel A and MOPITT Prior (I-A)xa
! x = Axm + (I-A)xa , where x is a 10 element vector 
!
! loop through MOPITT levels
   val = 0.0_r8
   do ilev = 1, nlevels
!
! get location of obs
      if (ilev.eq.1) then
         prs_mopitt=(prs_mopitt_sfc+mopitt_pressure(ilev))/2.
         loc2 = set_location(mloc(1),mloc(2),prs_mopitt, VERTISPRESSURE)
      else
         prs_mopitt=(mopitt_pressure(ilev-1)+mopitt_pressure(ilev))/2.
         loc2 = set_location(mloc(1),mloc(2),prs_mopitt, VERTISPRESSURE)
      endif
!
      if(prs_mopitt .ge. prs_wrf_1) then
         istatus=0
         obs_val=co_wrf_1
      else
         istatus=0
         call interpolate(state, loc2, KIND_CO, obs_val, istatus)
         if(istatus/=0) then
            write(string1, *)'APM NOTICE: WRF co_wrf is bad ',prs_mopitt,istatus
            call error_handler(E_MSG,'set_obs_def_mopitt_co',string1,source,revision,revdate)
            val=missing
            return
         endif            
      endif
!
! check for lower bound
      if (obs_val.lt.co_min) then
         write(string1, *)'APM: NOTICE resetting minimum MOPITT CO value ',ilev
         call error_handler(E_MSG,'set_obs_def_mopitt_co',string1,source,revision,revdate)
         obs_val = co_min 
      endif
!
! apply averaging kernel
      if( use_log_co ) then
         val = val + avg_kernel(key,ilev) * log10(exp(obs_val) * 1.e3)  
!         print *, 'ilev,value, incr ', ilev, val, avg_kernel(key,ilev)*log10(exp(obs_val)/1.e6)
!         print *, 'ilev,obs_val,exp ', ilev, obs_val, exp(obs_val)/1.e6
!         print *, 'ilev,avg_ker,obs ', ilev, avg_kernel(key,ilev), log10(exp(obs_val)/1.e6)
!         print *, ' '
      else
         val = val + avg_kernel(key,ilev) * log10(obs_val * 1.e3)  
      endif
   enddo
   if (trim(MOPITT_CO_retrieval_type).eq.'RETR' .or. trim(MOPITT_CO_retrieval_type).eq.'QOR' &
   .or. trim(MOPITT_CO_retrieval_type).eq.'CPSR') then
!      val = val + mopitt_prior(key)
!         print *, 'prior term       ',mopitt_prior(key)
!         print *, ' '
   elseif (trim(MOPITT_CO_retrieval_type).eq.'RAWR') then
!      val = val + mopitt_prior(key)
      val = (10.**val) * 1.e-3
   endif
!
end subroutine get_expected_mopitt_co
!
!----------------------------------------------------------------------

 subroutine set_obs_def_mopitt_co(key, co_avgker, co_prior, co_psurf, co_nlevels)
!----------------------------------------------------------------------
! Allows passing of obs_def special information 

integer,                 intent(in) :: key, co_nlevels
real(r8), dimension(10), intent(in) :: co_avgker
real(r8),                intent(in) :: co_prior
real(r8),                intent(in) :: co_psurf

if ( .not. module_initialized ) call initialize_module

if(num_mopitt_co_obs >= MAX_MOPITT_CO_OBS) then
   
   write(string1, *)'Not enough space for a mopitt CO obs.'
   call error_handler(E_MSG,'set_obs_def_mopitt_co',string1,source,revision,revdate)
   write(string1, *)'Can only have MAX_MOPITT_CO_OBS (currently ',MAX_MOPITT_CO_OBS,')'
   call error_handler(E_ERR,'set_obs_def_mopitt_co',string1,source,revision,revdate)
endif

avg_kernel(key,:)   = co_avgker(:)
mopitt_prior(key)   = co_prior
mopitt_psurf(key)   = co_psurf
mopitt_nlevels(key) = co_nlevels

end subroutine set_obs_def_mopitt_co


function read_mopitt_prior(ifile, fform)

integer,                    intent(in) :: ifile
real(r8)                               :: read_mopitt_prior
character(len=*), intent(in), optional :: fform

character(len=32)  :: fileformat

if ( .not. module_initialized ) call initialize_module

fileformat = "ascii"    ! supply default
if(present(fform)) fileformat = trim(adjustl(fform))

SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
      read(ifile) read_mopitt_prior
   CASE DEFAULT
      read(ifile, *) read_mopitt_prior
END SELECT

end function read_mopitt_prior

function read_mopitt_nlevels(ifile, fform)

integer,                    intent(in) :: ifile
integer                               :: read_mopitt_nlevels
character(len=*), intent(in), optional :: fform

character(len=32)  :: fileformat

if ( .not. module_initialized ) call initialize_module

fileformat = "ascii"    ! supply default
if(present(fform)) fileformat = trim(adjustl(fform))

SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
      read(ifile) read_mopitt_nlevels
   CASE DEFAULT
      read(ifile, *) read_mopitt_nlevels
END SELECT

end function read_mopitt_nlevels



subroutine write_mopitt_prior(ifile, mopitt_prior_temp, fform)

integer,           intent(in) :: ifile
real(r8),          intent(in) :: mopitt_prior_temp
character(len=32), intent(in) :: fform

character(len=32)  :: fileformat

if ( .not. module_initialized ) call initialize_module

fileformat = trim(adjustl(fform))

SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
      write(ifile) mopitt_prior_temp
   CASE DEFAULT
      write(ifile, *) mopitt_prior_temp
END SELECT

end subroutine write_mopitt_prior

subroutine write_mopitt_nlevels(ifile, mopitt_nlevels_temp, fform)

integer,                    intent(in) :: ifile
integer,                    intent(in) :: mopitt_nlevels_temp
character(len=32),          intent(in) :: fform

character(len=32)  :: fileformat

if ( .not. module_initialized ) call initialize_module

fileformat = trim(adjustl(fform))

SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
      write(ifile) mopitt_nlevels_temp
   CASE DEFAULT
      write(ifile, *) mopitt_nlevels_temp
END SELECT

end subroutine write_mopitt_nlevels



function read_mopitt_psurf(ifile, fform)

integer,                    intent(in) :: ifile
real(r8)                               :: read_mopitt_psurf
character(len=*), intent(in), optional :: fform

character(len=32)  :: fileformat

if ( .not. module_initialized ) call initialize_module

fileformat = "ascii"    ! supply default
if(present(fform)) fileformat = trim(adjustl(fform))

SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
      read(ifile) read_mopitt_psurf
   CASE DEFAULT
      read(ifile, *) read_mopitt_psurf
END SELECT

end function read_mopitt_psurf

subroutine write_mopitt_psurf(ifile, mopitt_psurf_temp, fform)

integer,           intent(in) :: ifile
real(r8),          intent(in) :: mopitt_psurf_temp
character(len=32), intent(in) :: fform

character(len=32)  :: fileformat

if ( .not. module_initialized ) call initialize_module

fileformat = trim(adjustl(fform))

SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
      write(ifile) mopitt_psurf_temp
   CASE DEFAULT
      write(ifile, *) mopitt_psurf_temp
END SELECT

end subroutine write_mopitt_psurf

function read_mopitt_avg_kernels(ifile, nlevels, fform)

integer,                    intent(in) :: ifile, nlevels
real(r8), dimension(10)        :: read_mopitt_avg_kernels
character(len=*), intent(in), optional :: fform

character(len=32)  :: fileformat

read_mopitt_avg_kernels(:) = 0.0_r8

if ( .not. module_initialized ) call initialize_module

fileformat = "ascii"    ! supply default
if(present(fform)) fileformat = trim(adjustl(fform))

SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
      read(ifile) read_mopitt_avg_kernels(1:nlevels)
   CASE DEFAULT
      read(ifile, *) read_mopitt_avg_kernels(1:nlevels)
END SELECT

end function read_mopitt_avg_kernels

subroutine write_mopitt_avg_kernels(ifile, avg_kernels_temp, nlevels_temp, fform)

integer,                    intent(in) :: ifile, nlevels_temp
real(r8), dimension(10), intent(in)  :: avg_kernels_temp
character(len=32),          intent(in) :: fform

character(len=32)  :: fileformat

if ( .not. module_initialized ) call initialize_module

fileformat = trim(adjustl(fform))

SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
      write(ifile) avg_kernels_temp(1:nlevels_temp)
   CASE DEFAULT
      write(ifile, *) avg_kernels_temp(1:nlevels_temp)
END SELECT

end subroutine write_mopitt_avg_kernels



end module obs_def_mopitt_mod
! END DART PREPROCESS MODULE CODE

! <next few lines under version control, do not edit>
! $URL$
! $Id$
! $Revision$
! $Date$
