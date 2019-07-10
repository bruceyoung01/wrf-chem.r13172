! DART software - Copyright 2004 - 2013 UCAR. This open source software is
! provided by UCAR, "as is", without charge, subject to all terms of use at
! http://www.image.ucar.edu/DAReS/DART/DART_download
!
! DART $Id$

! BEGIN DART PREPROCESS KIND LIST
! IASI_CO_RETRIEVAL, KIND_CO
! END DART PREPROCESS KIND LIST
!
! BEGIN DART PREPROCESS USE OF SPECIAL OBS_DEF MODULE
!   use obs_def_iasi_co_mod, only : write_iasi_co, read_iasi_co, &
!                                  interactive_iasi_co, get_expected_iasi_co, &
!                                  set_obs_def_iasi_co
! END DART PREPROCESS USE OF SPECIAL OBS_DEF MODULE
!
! BEGIN DART PREPROCESS GET_EXPECTED_OBS_FROM_DEF
!         case(IASI_CO_RETRIEVAL)                                                           
!            call get_expected_iasi_co(state, location, obs_def%key, obs_val, istatus)  
! END DART PREPROCESS GET_EXPECTED_OBS_FROM_DEF
!
! BEGIN DART PREPROCESS READ_OBS_DEF
!      case(IASI_CO_RETRIEVAL)
!         call read_iasi_co(obs_def%key, ifile, fileformat)
! END DART PREPROCESS READ_OBS_DEF
!
! BEGIN DART PREPROCESS WRITE_OBS_DEF
!      case(IASI_CO_RETRIEVAL)
!         call write_iasi_co(obs_def%key, ifile, fileformat)
! END DART PREPROCESS WRITE_OBS_DEF
!
! BEGIN DART PREPROCESS INTERACTIVE_OBS_DEF
!      case(IASI_CO_RETRIEVAL)
!         call interactive_iasi_co(obs_def%key)
! END DART PREPROCESS INTERACTIVE_OBS_DEF
!
! BEGIN DART PREPROCESS SET_OBS_DEF_IASI_CO
!      case(IASI_CO_RETRIEVAL)
!         call set_obs_def_iasi_co(obs_def%key)
! END DART PREPROCESS SET_OBS_DEF_IASI_CO
!
! BEGIN DART PREPROCESS MODULE CODE

module obs_def_iasi_CO_mod

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

public :: write_iasi_co, &
          read_iasi_co, &
          interactive_iasi_co, &
          get_expected_iasi_co, &
          set_obs_def_iasi_co

! Storage for the special information required for observations of this type
integer, parameter               :: MAX_IASI_CO_OBS = 10000000
integer, parameter               :: IASI_DIM = 19
integer, parameter               :: IASI_DIMP = 20
integer                          :: num_iasi_co_obs = 0

real(r8), allocatable, dimension(:,:) :: avg_kernel
real(r8), allocatable, dimension(:,:) :: pressure
real(r8), allocatable, dimension(:) :: iasi_prior
real(r8), allocatable, dimension(:) :: iasi_psurf
integer,  allocatable, dimension(:) :: iasi_nlevels
integer,  allocatable, dimension(:) :: iasi_nlevelsp

! version controlled file description for error handling, do not edit
character(len=*), parameter :: source   = &
   "$URL$"
character(len=*), parameter :: revision = "$Revision$"
character(len=*), parameter :: revdate  = "$Date$"

character(len=512) :: string1, string2

logical, save :: module_initialized = .false.
integer  :: counts1 = 0

character(len=129)  :: IASI_CO_retrieval_type
logical             :: use_log_co
!
! IASI_CO_retrieval_type:
!     RAWR - retrievals in VMR (ppb) units
!     RETR - retrievals in log10(VMR ([ ])) units
!     QOR  - quasi-optimal retrievals
!     CPSR - compact phase space retrievals
    namelist /obs_def_IASI_CO_nml/ IASI_CO_retrieval_type, use_log_co

contains

!----------------------------------------------------------------------
!>

subroutine initialize_module

integer :: iunit, rc

! Prevent multiple calls from executing this code more than once.
if (module_initialized) return

call register_module(source, revision, revdate)
module_initialized = .true.

allocate(avg_kernel(   MAX_IASI_CO_OBS, IASI_DIM))
allocate(pressure(     MAX_IASI_CO_OBS, IASI_DIMP))
allocate(iasi_prior(   MAX_IASI_CO_OBS))
allocate(iasi_psurf(   MAX_IASI_CO_OBS))
allocate(iasi_nlevels( MAX_IASI_CO_OBS))
allocate(iasi_nlevelsp(MAX_IASI_CO_OBS))

! Read the namelist entry.
IASI_CO_retrieval_type='RAWR'
use_log_co=.false.
call find_namelist_in_file("input.nml", "obs_def_IASI_CO_nml", iunit)
read(iunit, nml = obs_def_IASI_CO_nml, iostat = rc)
call check_namelist_read(iunit, rc, "obs_def_IASI_CO_nml")

! Record the namelist values used for the run ... 
if (do_nml_file()) write(nmlfileunit, nml=obs_def_IASI_CO_nml)
if (do_nml_term()) write(     *     , nml=obs_def_IASI_CO_nml)

end subroutine initialize_module

subroutine read_iasi_co(key, ifile, fform)
!----------------------------------------------------------------------
!subroutine read_iasi_co(key, ifile, fform)

integer,          intent(out)          :: key
integer,          intent(in)           :: ifile
character(len=*), intent(in), optional :: fform

character(len=32)              :: fileformat

integer                        :: iasi_nlevels_1
integer                        :: iasi_nlevelsp_1
real(r8)                       :: iasi_prior_1
real(r8)                       :: iasi_psurf_1
real(r8), dimension(IASI_DIM)  :: avg_kernels_1
real(r8), dimension(IASI_DIMP) :: pressure_1
integer                        :: keyin

if ( .not. module_initialized ) call initialize_module

fileformat = "ascii"   ! supply default
if(present(fform)) fileformat = trim(adjustl(fform))

! Philosophy, read ALL information about this special obs_type at once???
! For now, this means you can only read ONCE (that's all we're doing 3 June 05)
! Toggle the flag to control this reading
avg_kernels_1(:) = 0.0_r8
pressure_1(:) = 0.0_r8
SELECT CASE (fileformat)
   CASE ("unf", "UNF", "unformatted", "UNFORMATTED")
   iasi_nlevels_1 = read_iasi_nlevels(ifile, fileformat)
   iasi_nlevelsp_1 = iasi_nlevels_1+1
   iasi_prior_1 = read_iasi_prior(ifile, fileformat)
   iasi_psurf_1 = read_iasi_psurf(ifile, fileformat)
   avg_kernels_1(:) = read_iasi_avg_kernels(ifile, iasi_nlevels_1, fileformat)
   pressure_1(:) = read_iasi_pressure(ifile, iasi_nlevelsp_1, fileformat)
   read(ifile) keyin
   CASE DEFAULT
   iasi_nlevels_1 = read_iasi_nlevels(ifile, fileformat)
   iasi_nlevelsp_1 = iasi_nlevels_1+1
   iasi_prior_1 = read_iasi_prior(ifile, fileformat)
   iasi_psurf_1 = read_iasi_psurf(ifile, fileformat)
   avg_kernels_1(:) = read_iasi_avg_kernels(ifile, iasi_nlevels_1, fileformat)
   pressure_1(:) = read_iasi_pressure(ifile, iasi_nlevelsp_1, fileformat)
   read(ifile, *) keyin
END SELECT

counts1 = counts1 + 1
key = counts1
call set_obs_def_iasi_co(key, avg_kernels_1, pressure_1, iasi_prior_1, iasi_psurf_1, &
                           iasi_nlevels_1, iasi_nlevelsp_1)
end subroutine read_iasi_co

subroutine write_iasi_co(key, ifile, fform)
!----------------------------------------------------------------------
!subroutine write_iasi_co(key, ifile, fform)

integer,          intent(in)           :: key
integer,          intent(in)           :: ifile
character(len=*), intent(in), optional :: fform

character(len=32) :: fileformat
real(r8), dimension(IASI_DIM)   :: avg_kernels_temp
real(r8), dimension(IASI_DIMP)  :: pressure_temp
if ( .not. module_initialized ) call initialize_module
fileformat = "ascii"   ! supply default
if(present(fform)) fileformat = trim(adjustl(fform))
!
! Philosophy, read ALL information about this special obs_type at once???
! For now, this means you can only read ONCE (that's all we're doing 3 June 05)
! Toggle the flag to control this reading
avg_kernels_temp=avg_kernel(key,:)
pressure_temp=pressure(key,:)
SELECT CASE (fileformat)
   CASE ("unf", "UNF", "unformatted", "UNFORMATTED")
   call write_iasi_nlevels(ifile, iasi_nlevels(key), fileformat)
   call write_iasi_prior(ifile, iasi_prior(key), fileformat)
   call write_iasi_psurf(ifile, iasi_psurf(key), fileformat)
   call write_iasi_avg_kernels(ifile, avg_kernels_temp, iasi_nlevels(key), fileformat)
   call write_iasi_pressure(ifile, pressure_temp, iasi_nlevelsp(key), fileformat)
   write(ifile) key
   CASE DEFAULT
   call write_iasi_nlevels(ifile, iasi_nlevels(key), fileformat)
   call write_iasi_prior(ifile, iasi_prior(key), fileformat)
   call write_iasi_psurf(ifile, iasi_psurf(key), fileformat)
   call write_iasi_avg_kernels(ifile, avg_kernels_temp, iasi_nlevels(key), fileformat)
   call write_iasi_pressure(ifile, pressure_temp, iasi_nlevelsp(key), fileformat)
   write(ifile, *) key
END SELECT 
end subroutine write_iasi_co
!
subroutine interactive_iasi_co(key)
!----------------------------------------------------------------------
!subroutine interactive_iasi_co(key)
!
! Initializes the specialized part of a IASI observation
! Passes back up the key for this one
integer, intent(out) :: key

if ( .not. module_initialized ) call initialize_module
!
! Make sure there's enough space, if not die for now (clean later)
if(num_iasi_co_obs >= MAX_IASI_CO_OBS) then
   write(string1, *)'Not enough space for a iasi CO obs.'
   write(string2, *)'Can only have max_iasi_co obs (currently ',MAX_IASI_CO_OBS,')'
   call error_handler(E_ERR,'interactive_iasi_co',string1,source,revision,revdate,text2=string2)
endif
!
! Increment the index
num_iasi_co_obs = num_iasi_co_obs + 1
key = num_iasi_co_obs
!
! Otherwise, prompt for input for the three required beasts
write(*, *) 'Creating an interactive_iasi_co observation'
write(*, *) 'Input the IASI Prior '
read(*, *) iasi_prior
write(*, *) 'Input IASI Surface Pressure '
read(*, *) iasi_psurf(num_iasi_co_obs)
write(*, *) 'Input the 19 Averaging Kernel Weights '
read(*, *) avg_kernel(num_iasi_co_obs,:)
write(*, *) 'Input the 20 Averaging Pressure Levels '
read(*, *) pressure(num_iasi_co_obs,:)
end subroutine interactive_iasi_co
!
subroutine get_expected_iasi_co(state, location, key, val, istatus)
!----------------------------------------------------------------------
!subroutine get_expected_iasi_co(state, location, key, val, istatus)
   real(r8),            intent(in)  :: state(:)
   type(location_type), intent(in)  :: location
   integer,             intent(in)  :: key
   real(r8),            intent(out) :: val
   integer,             intent(out) :: istatus

   integer,parameter   :: wrf_nlev=32
   integer             :: i, kstr, ilev
   type(location_type) :: loc2
   real(r8)            :: mloc(3), prs_wrf(wrf_nlev)
   real(r8)            :: obs_val, co_min, co_min_log, level, missing
   real(r8)            :: prs_wrf_sfc, co_wrf_sfc
   real(r8)            :: prs_wrf_1, prs_wrf_2, co_wrf_1, co_wrf_2, prs_wrf_nlev
   real(r8)            :: prs_iasi_sfc, prs_iasi
   integer             :: nlevels,nlevelsp

   real(r8)            :: vert_mode_filt

   character(len=*), parameter :: routine = 'get_expected_iasi_co'
!
! Initialize DART
   if ( .not. module_initialized ) call initialize_module
!
! Initialize variables (IASI is ppbv; WRF CO is ppmv)
   co_min      = 1.e-2
   co_min_log  = log(co_min)
   missing     = -888888.0_r8
   nlevels     = iasi_nlevels(key)
   nlevelsp    = iasi_nlevelsp(key)
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
! IASI surface pressure
   prs_iasi_sfc=iasi_psurf(key)
!   pressure(1)=iasi_psurf(key)
!
! WRF surface pressure
   level=0.0_r8
   loc2 = set_location(mloc(1), mloc(2), level, VERTISSURFACE)
   istatus = 0
   call interpolate(state, loc2, KIND_SURFACE_PRESSURE, prs_wrf_sfc, istatus)  
   if(istatus/=0) then
      write(string1, *)'APM NOTICE: WRF prs_wrf_sfc is bad ',istatus
      call error_handler(E_MSG,'set_obs_def_iasi_co',string1,source,revision,revdate)
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
      call error_handler(E_MSG,'set_obs_def_iasi_co',string1,source,revision,revdate)
      val=missing
      return
   endif
!
! WRF pressure second level
   level=2.0_r8
   loc2 = set_location(mloc(1), mloc(2), level, VERTISLEVEL)
   istatus=0
   call interpolate(state, loc2, KIND_PRESSURE, prs_wrf_2, istatus)
   if(istatus/=0) then
      write(string1, *)'APM NOTICE: WRF prs_wrf_2 is bad ',istatus
      call error_handler(E_MSG,'set_obs_def_iasi_co',string1,source,revision,revdate)
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
      call error_handler(E_MSG,'set_obs_def_iasi_co',string1,source,revision,revdate)
      val=missing
      return
   endif              
!
! Apply IASI Averaging kernel A and IASI Prior (I-A)xa
! x = Axm + (I-A)xa , where x is a 10 element vector 
!
! loop through IASI levels
   val = 0.0_r8
   do ilev = 1, nlevels
!
! get location of obs
      if (ilev.eq.1) then
         prs_iasi=(prs_iasi_sfc+pressure(key,ilev))/2.
         loc2 = set_location(mloc(1),mloc(2),prs_iasi, VERTISPRESSURE)
      else
         prs_iasi=(pressure(key,ilev-1)+pressure(key,ilev))/2.
         loc2 = set_location(mloc(1),mloc(2),prs_iasi, VERTISPRESSURE)
      endif
!
      if(prs_iasi.ge.prs_wrf_1) then
         istatus=0
         obs_val=co_wrf_1
      else 
         istatus=0
         call interpolate(state, loc2, KIND_CO, obs_val, istatus)        
         if(istatus/=0) then
            write(string1, *)'APM NOTICE: WRF co_wrf is bad ',prs_iasi,istatus
            call error_handler(E_MSG,'set_obs_def_iasi_co',string1,source,revision,revdate)
            val=missing
            return
         endif
      endif
!
! check for lower bound
      if (obs_val.lt.co_min) then
         write(string1, *)'APM: NOTICE resetting minimum IASI CO value ',ilev
         call error_handler(E_MSG,routine,string1,source,revision,revdate)
         obs_val = co_min 
      endif
!
! apply averaging kernel
      if ( use_log_co ) then
         val = val + avg_kernel(key,ilev) * exp(obs_val) * 1.e3  
      else
         val = val + avg_kernel(key,ilev) * obs_val * 1.e3
      endif
   enddo
   if (trim(IASI_CO_retrieval_type).eq.'RETR') then
!      val = val + iasi_prior(key)
      val = log10(val)
!         print *, 'prior term       ',iasi_prior(key)
!         print *, ' '
   elseif (trim(IASI_CO_retrieval_type).eq.'RAWR' .or. trim(IASI_CO_retrieval_type).eq.'QOR' &
   .or. trim(IASI_CO_retrieval_type).eq.'CPSR') then
!      val = val + iasi_prior(key)
   endif
!
end subroutine get_expected_iasi_co

!----------------------------------------------------------------------

subroutine set_obs_def_iasi_co(key, co_avgker, co_press, co_prior, co_psurf, co_nlevels, co_nlevelsp)

! Allows passing of obs_def special information 

integer,                 intent(in) :: key, co_nlevels, co_nlevelsp
real(r8), dimension(IASI_DIM),  intent(in) :: co_avgker
real(r8), dimension(IASI_DIMP), intent(in) :: co_press
real(r8),                intent(in) :: co_prior
real(r8),                intent(in) :: co_psurf

character(len=*), parameter :: routine = 'set_obs_def_iasi_co'

if ( .not. module_initialized ) call initialize_module

if(num_iasi_co_obs >= MAX_IASI_CO_OBS) then
   write(string1, *)'Not enough space for a iasi CO obs.'
   write(string2, *)'Can only have MAX_IASI_CO_OBS (currently ',MAX_IASI_CO_OBS,')'
   call error_handler(E_ERR,routine,string1,source,revision,revdate,text2=string2)
endif

avg_kernel(   key,1:co_nlevels)  = co_avgker(1:co_nlevels)
pressure(     key,1:co_nlevelsp) = co_press(1:co_nlevelsp)
iasi_prior(   key)   = co_prior
iasi_psurf(   key)   = co_psurf
iasi_nlevels( key)   = co_nlevels
iasi_nlevelsp(key)   = co_nlevelsp

end subroutine set_obs_def_iasi_co



function read_iasi_prior(ifile, fform)
integer,          intent(in)           :: ifile
character(len=*), intent(in), optional :: fform
real(r8)                               :: read_iasi_prior

character(len=32)  :: fileformat
if ( .not. module_initialized ) call initialize_module
fileformat = "ascii"    ! supply default
if(present(fform)) fileformat = trim(adjustl(fform))
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
      read(ifile) read_iasi_prior
   CASE DEFAULT
      read(ifile, *) read_iasi_prior
END SELECT
end function read_iasi_prior



function read_iasi_nlevels(ifile, fform)
integer,          intent(in)           :: ifile
character(len=*), intent(in), optional :: fform
integer                                :: read_iasi_nlevels

character(len=32)  :: fileformat
if ( .not. module_initialized ) call initialize_module
fileformat = "ascii"    ! supply default
if(present(fform)) fileformat = trim(adjustl(fform))
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
      read(ifile) read_iasi_nlevels
   CASE DEFAULT
      read(ifile, *) read_iasi_nlevels
END SELECT
end function read_iasi_nlevels



function read_iasi_nlevelsp(ifile, fform)
integer,          intent(in)           :: ifile
character(len=*), intent(in), optional :: fform
integer                                :: read_iasi_nlevelsp

character(len=32)  :: fileformat
if ( .not. module_initialized ) call initialize_module
fileformat = "ascii"    ! supply default
if(present(fform)) fileformat = trim(adjustl(fform))
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
      read(ifile) read_iasi_nlevelsp
   CASE DEFAULT
      read(ifile, *) read_iasi_nlevelsp
END SELECT
end function read_iasi_nlevelsp



subroutine write_iasi_prior(ifile, iasi_prior_temp, fform)
integer,          intent(in) :: ifile
real(r8),         intent(in) :: iasi_prior_temp
character(len=*), intent(in) :: fform

character(len=32)  :: fileformat
if ( .not. module_initialized ) call initialize_module
fileformat = trim(adjustl(fform))

SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
      write(ifile) iasi_prior_temp
   CASE DEFAULT
      write(ifile, *) iasi_prior_temp
END SELECT
end subroutine write_iasi_prior



subroutine write_iasi_nlevels(ifile, iasi_nlevels_temp, fform)
integer,          intent(in) :: ifile
integer,          intent(in) :: iasi_nlevels_temp
character(len=*), intent(in) :: fform

character(len=32)  :: fileformat
if ( .not. module_initialized ) call initialize_module
fileformat = trim(adjustl(fform))
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
      write(ifile) iasi_nlevels_temp
   CASE DEFAULT
      write(ifile, *) iasi_nlevels_temp
END SELECT
end subroutine write_iasi_nlevels
!

subroutine write_iasi_nlevelsp(ifile, iasi_nlevelsp_temp, fform)
integer,          intent(in) :: ifile
integer,          intent(in) :: iasi_nlevelsp_temp
character(len=*), intent(in) :: fform

character(len=32)  :: fileformat
if ( .not. module_initialized ) call initialize_module
fileformat = trim(adjustl(fform))
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
      write(ifile) iasi_nlevelsp_temp
   CASE DEFAULT
      write(ifile, *) iasi_nlevelsp_temp
END SELECT
end subroutine write_iasi_nlevelsp
!
function read_iasi_psurf(ifile, fform)
integer,          intent(in)           :: ifile
character(len=*), intent(in), optional :: fform
real(r8)                               :: read_iasi_psurf

character(len=32)  :: fileformat
if ( .not. module_initialized ) call initialize_module
fileformat = "ascii"    ! supply default
if(present(fform)) fileformat = trim(adjustl(fform))
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

character(len=32)  :: fileformat
if ( .not. module_initialized ) call initialize_module
fileformat = trim(adjustl(fform))
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
      write(ifile) iasi_psurf_temp
   CASE DEFAULT
      write(ifile, *) iasi_psurf_temp
END SELECT
end subroutine write_iasi_psurf
!
function read_iasi_avg_kernels(ifile, nlevels, fform)
integer,          intent(in)           :: ifile, nlevels
character(len=*), intent(in), optional :: fform
real(r8), dimension(IASI_DIM)           :: read_iasi_avg_kernels

character(len=32)  :: fileformat
read_iasi_avg_kernels(:) = 0.0_r8
if ( .not. module_initialized ) call initialize_module
fileformat = "ascii"    ! supply default
if(present(fform)) fileformat = trim(adjustl(fform))
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
      read(ifile) read_iasi_avg_kernels(1:nlevels)
   CASE DEFAULT
      read(ifile, *) read_iasi_avg_kernels(1:nlevels)
END SELECT
end function read_iasi_avg_kernels
!
subroutine write_iasi_avg_kernels(ifile, avg_kernels_temp, nlevels_temp, fform)
integer,                 intent(in) :: ifile, nlevels_temp
real(r8), dimension(:), intent(in) :: avg_kernels_temp
character(len=*),        intent(in) :: fform

character(len=32)  :: fileformat
if ( .not. module_initialized ) call initialize_module
fileformat = trim(adjustl(fform))
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
      write(ifile) avg_kernels_temp(1:nlevels_temp)
   CASE DEFAULT
      write(ifile, *) avg_kernels_temp(1:nlevels_temp)
END SELECT
end subroutine write_iasi_avg_kernels
!
function read_iasi_pressure(ifile, nlevelsp, fform)
integer,          intent(in)           :: ifile, nlevelsp
character(len=*), intent(in), optional :: fform
real(r8), dimension(IASI_DIMP)         :: read_iasi_pressure

character(len=32) :: fileformat
read_iasi_pressure(:) = 0.0_r8
if ( .not. module_initialized ) call initialize_module
fileformat = "ascii"    ! supply default
if(present(fform)) fileformat = trim(adjustl(fform))
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
      read(ifile) read_iasi_pressure(1:nlevelsp)
   CASE DEFAULT
      read(ifile, *) read_iasi_pressure(1:nlevelsp)
END SELECT
end function read_iasi_pressure
!
subroutine write_iasi_pressure(ifile, pressure_temp, nlevelsp_temp, fform)
integer,                 intent(in) :: ifile, nlevelsp_temp
real(r8), dimension(IASI_DIMP), intent(in)  :: pressure_temp
character(len=32),       intent(in) :: fform

character(len=32)  :: fileformat
if ( .not. module_initialized ) call initialize_module
fileformat = trim(adjustl(fform))
SELECT CASE (fileformat)
   CASE("unf", "UNF", "unformatted", "UNFORMATTED")
      write(ifile) pressure_temp(1:nlevelsp_temp)
   CASE DEFAULT
      write(ifile, *) pressure_temp(1:nlevelsp_temp)
END SELECT
end subroutine write_iasi_pressure
!
end module obs_def_iasi_CO_mod
! END DART PREPROCESS MODULE CODE

! <next few lines under version control, do not edit>
! $URL$
! $Id$
! $Revision$
! $Date$
