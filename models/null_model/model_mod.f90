! DART software - Copyright 2004 - 2013 UCAR. This open source software is
! provided by UCAR, "as is", without charge, subject to all terms of use at
! http://www.image.ucar.edu/DAReS/DART/DART_download
!
! $Id$

module model_mod

! This module provides very simple models for evaluating filtering algorithms.
! It can provide simple linear growth around a fixed point, a random draw from
! a Gaussian, or combinations of the two. At present, these combinations are
! controlled by modifying the code comments in adv_1step and comp_dt in your
! sandbox. 

use        types_mod, only : r8, MISSING_R8
use time_manager_mod, only : time_type, set_time
use     location_mod, only : location_type, get_dist, set_location, get_location, &
                             LocationDims, LocationName, LocationLName, &
                             get_close_maxdist_init, get_close_obs_init, get_close_obs

use    utilities_mod, only : register_module, error_handler, E_ERR, E_MSG, nmlfileunit, &
                             do_output, find_namelist_in_file, check_namelist_read,     &
                             do_nml_file, do_nml_term
use random_seq_mod, only : random_seq_type, init_random_seq, random_gaussian

implicit none
private

! Following is for repeatable random numbers
logical :: first_ens_seq = .true.
type (random_seq_type) :: ens_seq

public :: get_model_size, &
          adv_1step, &
          get_state_meta_data, &
          model_interpolate, &
          get_model_time_step, &
          end_model, &
          static_init_model, &
          init_time, &
          init_conditions, &
          nc_write_model_atts, &
          nc_write_model_vars, &
          pert_model_state, &
          get_close_maxdist_init, get_close_obs_init, get_close_obs, ens_mean_for_model


! version controlled file description for error handling, do not edit
character(len=256), parameter :: source   = &
   "$URL$"
character(len=32 ), parameter :: revision = "$Revision$"
character(len=128), parameter :: revdate  = "$Date$"

! Basic model parameters controlled by nameslist; have defaults

!---------------------------------------------------------------
! Namelist with default values
! Model size can be as small as 1 here.
integer  :: model_size = 2
real(r8) :: delta_t    = 0.05_r8
integer  :: time_step_days = 0
integer  :: time_step_seconds = 3600

namelist /model_nml/ model_size, delta_t, time_step_days, time_step_seconds
!----------------------------------------------------------------

! Define the location of the state variables in module storage
type(location_type), allocatable :: state_loc(:)
type(time_type) :: time_step


contains

!==================================================================



subroutine static_init_model()
!------------------------------------------------------------------
! Initializes class data for this model. For now, simply outputs the
! identity info, sets the location of the state variables, and initializes
! the time type for the time stepping.

real(r8) :: x_loc
integer  :: i, iunit, io
character(len=129) :: nml_string

! Print module information to log file and stdout.
call register_module(source, revision, revdate)

! Read the namelist entry
call find_namelist_in_file("input.nml", "model_nml", iunit)
read(iunit, nml = model_nml, iostat = io)
call check_namelist_read(iunit, io, "model_nml")

! Record the namelist values used for the run ...
if (do_nml_file()) write(nmlfileunit, nml=model_nml)
if (do_nml_term()) write(     *     , nml=model_nml)

! Create storage for locations
allocate(state_loc(model_size))

! Define the locations of the model state variables
do i = 1, model_size
   x_loc = (i - 1.0_r8) / model_size
   state_loc(i) =  set_location(x_loc)
end do

! The time_step in terms of a time type must also be initialized. 
time_step = set_time(time_step_seconds, time_step_days)

end subroutine static_init_model



subroutine comp_dt(x, dt)
!------------------------------------------------------------------
! subroutine comp_dt(x, dt)
! 
! Computes the time tendency of a model with just exponential divergence from 0.

real(r8), intent( in) ::  x(:)
real(r8), intent(out) :: dt(:)

integer :: j

if(first_ens_seq) then
   call init_random_seq(ens_seq)
   first_ens_seq = .false.
end if

do j = 1, model_size
   dt(j) =  x(j)


! ADDITION OF SOME NOISE
   dt(j) = 1.0 * random_gaussian(ens_seq, 0.0_r8, 1.0_r8)
end do

end subroutine comp_dt



subroutine init_conditions(x)
!------------------------------------------------------------------
! subroutine init_conditions(x)
!
! Initial conditions for null model.
! It is assumed that this is called before any other routines in this
! module. Should probably make that more formal and perhaps enforce for
! more comprehensive models.


real(r8), intent(out) :: x(:)

x    = 0.0_r8

end subroutine init_conditions



subroutine adv_1step(x, time)
!------------------------------------------------------------------
! subroutine adv_1step(x, time)
!
! Does single time step advance for null model
! using four-step rk time step
! The Time argument is needed for compatibility with more complex models
! that need to know the time to compute their time tendency and is not
! used in null_model.


real(r8), intent(inout) :: x(:)
type(time_type), intent(in) :: time

real(r8), dimension(size(x)) :: x1, x2, x3, x4, dx, inter

call comp_dt(x, dx)        !  Compute the first intermediate step
x1    = delta_t * dx
inter = x + x1 / 2.0_r8

call comp_dt(inter, dx)    !  Compute the second intermediate step
x2    = delta_t * dx
inter = x + x2 / 2.0_r8

call comp_dt(inter, dx)    !  Compute the third intermediate step
x3    = delta_t * dx
inter = x + x3

call comp_dt(inter, dx)    !  Compute fourth intermediate step
x4 = delta_t * dx

!  Compute new value for x
x = x + x1/6.0_r8 + x2/3.0_r8 + x3/3.0_r8 + x4/6.0_r8



! Can change to simple timestepping
!!!call comp_dt(x, dx)
!!!x = x + delta_t * dx


! IDEALIZED DISTRIBUTION TEST: Just draw from a random distribution
!!!x = dx


end subroutine adv_1step



function get_model_size()
!------------------------------------------------------------------
! function get_model_size()
!
! Returns size of model

integer :: get_model_size

get_model_size = model_size

end function get_model_size



subroutine init_time(time)
!------------------------------------------------------------------
!
! Gets the initial time for a state from the model. Where should this info
! come from in the most general case?

type(time_type), intent(out) :: time

! For now, just set to 0
time = set_time(0, 0)

end subroutine init_time



subroutine model_interpolate(x, location, itype, obs_val, istatus)
!------------------------------------------------------------------
!
! Interpolates from state vector x to the location. It's not particularly
! happy dumping all of this straight into the model. Eventually some
! concept of a grid underlying models but above locations is going to
! be more general. May want to wait on external infrastructure projects
! for this?

! Argument itype is not used here because there is only one type of variable.
! Type is needed to allow swap consistency with more complex models.


real(r8),            intent(in) :: x(:)
type(location_type), intent(in) :: location
integer,             intent(in) :: itype
real(r8),           intent(out) :: obs_val
integer,            intent(out) :: istatus

integer :: lower_index, upper_index, i
real(r8) :: lctn, lctnfrac

! All forward operators supported
istatus = 0

! Convert location to real
lctn = get_location(location)
! Multiply by model size assuming domain is [0, 1] cyclic
lctn = model_size * lctn

lower_index = int(lctn) + 1
upper_index = lower_index + 1
if(lower_index > model_size) lower_index = lower_index - model_size
if(upper_index > model_size) upper_index = upper_index - model_size

lctnfrac = lctn - int(lctn)
obs_val = (1.0_r8 - lctnfrac) * x(lower_index) + lctnfrac * x(upper_index)

if(1 == 1) return

!!!obs_val = obs_val ** 2
!!!if(1 == 1) return

! Temporarily add on an observation from the other side of the domain, too
lower_index = lower_index + model_size / 2
if(lower_index > model_size) lower_index = lower_index - model_size
upper_index = upper_index + model_size / 2
if(upper_index > model_size) upper_index = upper_index - model_size
obs_val = obs_val + &
   lctnfrac * x(lower_index) + (1.0_r8 - lctnfrac) * x(upper_index)
if(1 == 1) return


! Next one does an average over a range of points
obs_val = 0.0_r8
lower_index = lower_index - 7
upper_index = upper_index - 7
if(lower_index < 1) lower_index = lower_index + model_size
if(upper_index < 1) upper_index = upper_index + model_size

do i = 1, 15
   if(lower_index > model_size) lower_index = lower_index - model_size
   if(upper_index > model_size) upper_index = upper_index - model_size
   obs_val = obs_val + &
      (1.0_r8 - lctnfrac) * x(lower_index) + lctnfrac * x(upper_index)
   lower_index = lower_index + 1
   upper_index = upper_index + 1
end do

end subroutine model_interpolate



function get_model_time_step()
!------------------------------------------------------------------
! function get_model_time_step()
!
! Returns the the time step of the model. In the long run should be repalced
! by a more general routine that returns details of a general time-stepping
! capability.

type(time_type) :: get_model_time_step

get_model_time_step = time_step

end function get_model_time_step



subroutine get_state_meta_data(index_in, location, var_type)
!------------------------------------------------------------------
!
! Given an integer index into the state vector structure, returns the
! associated location. This is not a function because the more general
! form of the call has a second intent(out) optional argument kind.
! Maybe a functional form should be added?


integer,             intent(in)  :: index_in
type(location_type), intent(out) :: location
integer,             intent(out), optional :: var_type

location = state_loc(index_in)
if (present(var_type)) var_type = 1    ! default variable type

end subroutine get_state_meta_data



subroutine end_model()
!------------------------------------------------------------------
!
! Does any shutdown and clean-up needed for model. Nothing for null_model.


end subroutine end_model



function nc_write_model_atts( ncFileID ) result (ierr)
!------------------------------------------------------------------
! Writes the model-specific attributes to a netCDF file
! TJH Jan 24 2003
!
! TJH 29 July 2003 -- for the moment, all errors are fatal, so the
! return code is always '0 == normal', since the fatal errors stop execution.
!
! For the null model, each state variable is at a separate location.
! that's all the model-specific attributes I can think of ...
!
! assim_model_mod:init_diag_output uses information from the location_mod
!     to define the location dimension and variable ID. All we need to do
!     is query, verify, and fill ...
!
! Typical sequence for adding new dimensions,variables,attributes:
! NF90_OPEN             ! open existing netCDF dataset
!    NF90_redef         ! put into define mode 
!    NF90_def_dim       ! define additional dimensions (if any)
!    NF90_def_var       ! define variables: from name, type, and dims
!    NF90_put_att       ! assign attribute values
! NF90_ENDDEF           ! end definitions: leave define mode
!    NF90_put_var       ! provide values for variable
! NF90_CLOSE            ! close: save updated netCDF dataset

use typeSizes
use netcdf

integer, intent(in)  :: ncFileID      ! netCDF file identifier
integer              :: ierr          ! return value of function

!--------------------------------------------------------------------
! General netCDF variables
!--------------------------------------------------------------------

integer :: nDimensions, nVariables, nAttributes, unlimitedDimID

!--------------------------------------------------------------------
! netCDF variables for Location
!--------------------------------------------------------------------

integer :: LocationVarID
integer :: StateVarDimID, StateVarVarID
integer :: StateVarID, MemberDimID, TimeDimID

!--------------------------------------------------------------------
! local variables
!--------------------------------------------------------------------

character(len=8)      :: crdate      ! needed by F90 DATE_AND_TIME intrinsic
character(len=10)     :: crtime      ! needed by F90 DATE_AND_TIME intrinsic
character(len=5)      :: crzone      ! needed by F90 DATE_AND_TIME intrinsic
integer, dimension(8) :: values      ! needed by F90 DATE_AND_TIME intrinsic
character(len=NF90_MAX_NAME) :: str1

integer             :: i
type(location_type) :: lctn 
ierr = 0                      ! assume normal termination

!--------------------------------------------------------------------
! make sure ncFileID refers to an open netCDF file 
!--------------------------------------------------------------------

call check(nf90_Inquire(ncFileID, nDimensions, nVariables, nAttributes, unlimitedDimID))
call check(nf90_sync(ncFileID)) ! Ensure netCDF file is current
call check(nf90_Redef(ncFileID))

!--------------------------------------------------------------------
! Determine ID's from stuff already in the netCDF file
!--------------------------------------------------------------------

! make sure time is unlimited dimid

call check(nf90_inq_dimid(ncFileID,"copy",dimid=MemberDimID))
call check(nf90_inq_dimid(ncFileID,"time",dimid=TimeDimID))

!--------------------------------------------------------------------
! Write Global Attributes 
!--------------------------------------------------------------------
call DATE_AND_TIME(crdate,crtime,crzone,values)
write(str1,'(''YYYY MM DD HH MM SS = '',i4,5(1x,i2.2))') &
                  values(1), values(2), values(3), values(5), values(6), values(7)

call check(nf90_put_att(ncFileID, NF90_GLOBAL, "creation_date",str1))
call check(nf90_put_att(ncFileID, NF90_GLOBAL, "model_source", source ))
call check(nf90_put_att(ncFileID, NF90_GLOBAL, "model_revision", revision ))
call check(nf90_put_att(ncFileID, NF90_GLOBAL, "model_revdate", revdate ))
call check(nf90_put_att(ncFileID, NF90_GLOBAL, "model", "null"))
call check(nf90_put_att(ncFileID, NF90_GLOBAL, "model_delta_t", delta_t ))

!--------------------------------------------------------------------
! Define the model size, state variable dimension ... whatever ...
!--------------------------------------------------------------------

call check(nf90_def_dim(ncid=ncFileID, name="StateVariable", &
                        len=model_size, dimid = StateVarDimID)) 

!--------------------------------------------------------------------
! Define the Location Variable and add Attributes
! Some of the atts come from location_mod (via the USE: stmnt)
! CF standards for Locations:
! http://www.cgd.ucar.edu/cms/eaton/netcdf/CF-working.html#ctype
!--------------------------------------------------------------------

call check(NF90_def_var(ncFileID, name=trim(adjustl(LocationName)), xtype=nf90_double, &
              dimids = StateVarDimID, varid=LocationVarID) )
call check(nf90_put_att(ncFileID, LocationVarID, "long_name", trim(adjustl(LocationLName))))
call check(nf90_put_att(ncFileID, LocationVarID, "dimension", LocationDims ))
call check(nf90_put_att(ncFileID, LocationVarID, "units", "nondimensional"))
call check(nf90_put_att(ncFileID, LocationVarID, "valid_range", (/ 0.0_r8, 1.0_r8 /)))

!--------------------------------------------------------------------
! Define either the "state vector" variables -OR- the "prognostic" variables.
!--------------------------------------------------------------------

! Define the state vector coordinate variable
call check(nf90_def_var(ncid=ncFileID,name="StateVariable", xtype=nf90_int, &
           dimids=StateVarDimID, varid=StateVarVarID))
call check(nf90_put_att(ncFileID, StateVarVarID, "long_name", "State Variable ID"))
call check(nf90_put_att(ncFileID, StateVarVarID, "units",     "indexical") )
call check(nf90_put_att(ncFileID, StateVarVarID, "valid_range", (/ 1, model_size /)))

! Define the actual state vector
call check(nf90_def_var(ncid=ncFileID, name="state", xtype=nf90_double, &
           dimids = (/ StateVarDimID, MemberDimID, TimeDimID /), varid=StateVarID))
call check(nf90_put_att(ncFileID, StateVarID, "long_name", "model state or fcopy"))

! Leave define mode so we can fill
call check(nf90_enddef(ncfileID))

! Fill the state variable coordinate variable
call check(nf90_put_var(ncFileID, StateVarVarID, (/ (i,i=1,model_size) /) ))

!--------------------------------------------------------------------
! Fill the location variable
!--------------------------------------------------------------------

do i = 1,model_size
   call get_state_meta_data(i,lctn)
   call check(nf90_put_var(ncFileID, LocationVarID, get_location(lctn), (/ i /) ))
enddo

!--------------------------------------------------------------------
! Flush the buffer and leave netCDF file open
!--------------------------------------------------------------------
call check(nf90_sync(ncFileID))

write (*,*)'Model attributes written, netCDF file synched ...'

contains
   ! Internal subroutine - checks error status after each netcdf, prints 
   !                       text message each time an error code is returned. 
   subroutine check(istatus)
      integer, intent ( in) :: istatus
      if(istatus /= nf90_noerr) call error_handler(E_ERR,'nc_write_model_atts',&
         trim(nf90_strerror(istatus)), source, revision, revdate)
   end subroutine check
end function nc_write_model_atts



function nc_write_model_vars( ncFileID, statevec, copyindex, timeindex ) result (ierr)         
!------------------------------------------------------------------
! Writes the model-specific attributes to a netCDF file
! TJH 23 May 2003
!
! TJH 29 July 2003 -- for the moment, all errors are fatal, so the
! return code is always '0 == normal', since the fatal errors stop execution.
!
! For the null model, each state variable is at a separate location.
! that's all the model-specific attributes I can think of ...
!
! assim_model_mod:init_diag_output uses information from the location_mod
!     to define the location dimension and variable ID. All we need to do
!     is query, verify, and fill ...
!
! Typical sequence for adding new dimensions,variables,attributes:
! NF90_OPEN             ! open existing netCDF dataset
!    NF90_redef         ! put into define mode
!    NF90_def_dim       ! define additional dimensions (if any)
!    NF90_def_var       ! define variables: from name, type, and dims
!    NF90_put_att       ! assign attribute values
! NF90_ENDDEF           ! end definitions: leave define mode
!    NF90_put_var       ! provide values for variable
! NF90_CLOSE            ! close: save updated netCDF dataset

use typeSizes
use netcdf

integer,                intent(in) :: ncFileID      ! netCDF file identifier
real(r8), dimension(:), intent(in) :: statevec
integer,                intent(in) :: copyindex
integer,                intent(in) :: timeindex
integer                            :: ierr          ! return value of function

!--------------------------------------------------------------------
! General netCDF variables
!--------------------------------------------------------------------

integer :: nDimensions, nVariables, nAttributes, unlimitedDimID
integer :: StateVarID

!--------------------------------------------------------------------
! local variables
!--------------------------------------------------------------------

ierr = 0                      ! assume normal termination

!--------------------------------------------------------------------
! make sure ncFileID refers to an open netCDF file
!--------------------------------------------------------------------

call check(nf90_Inquire(ncFileID, nDimensions, nVariables, nAttributes, unlimitedDimID))

! no matter the value of "output_state_vector", we only do one thing.

call check(NF90_inq_varid(ncFileID, "state", StateVarID) )
call check(NF90_put_var(ncFileID, StateVarID, statevec,  &
             start=(/ 1, copyindex, timeindex /)))

! write (*,*)'Finished filling variables ...'
call check(nf90_sync(ncFileID))
! write (*,*)'netCDF file is synched ...'

contains
   ! Internal subroutine - checks error status after each netcdf, prints
   !                       text message each time an error code is returned.
   subroutine check(istatus)
   integer, intent ( in) :: istatus
      if(istatus /= nf90_noerr) call error_handler(E_ERR,'nc_write_model_vars',&
         trim(nf90_strerror(istatus)), source, revision, revdate)
   end subroutine check
end function nc_write_model_vars



subroutine pert_model_state(state, pert_state, interf_provided)
!------------------------------------------------------------------
! subroutine pert_model_state(state, pert_state, interf_provided)
!
! Perturbs a model state for generating initial ensembles
! Returning interf_provided means go ahead and do this with uniform
! small independent perturbations.

real(r8), intent(in)  :: state(:)
real(r8), intent(out) :: pert_state(:)
logical,  intent(out) :: interf_provided

interf_provided = .false.

pert_state = state ! Just to satisfy the INTENT(OUT)

end subroutine pert_model_state






subroutine ens_mean_for_model(ens_mean)
!------------------------------------------------------------------
! Not used in low-order models

real(r8), intent(in) :: ens_mean(:)

end subroutine ens_mean_for_model


!===================================================================
! End of model_mod
!===================================================================
end module model_mod

! <next few lines under version control, do not edit>
! $URL$
! $Id$
! $Revision$
! $Date$
