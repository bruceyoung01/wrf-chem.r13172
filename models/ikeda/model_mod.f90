! DART software - Copyright 2004 - 2013 UCAR. This open source software is
! provided by UCAR, "as is", without charge, subject to all terms of use at
! http://www.image.ucar.edu/DAReS/DART/DART_download
!
! $Id$

module model_mod

! This is a template showing the interfaces required for a model to be compliant
! with the DART data assimilation infrastructure. The public interfaces listed
! must all be supported with the argument lists as indicated. Many of the interfaces
! are not required for minimal implementation (see the discussion of each
! interface and look for NULL INTERFACE). 

! THIS IS BEING MODIFIED FROM THE TEMPLATE TO ENABLE USE OF THE IKEDA SYSTEM
! WGL, Caltech, Wednesday 14 March 2007
! I'm sure much can be cleaned-up here as far as comments -- really this is just
!   an adaptation of the lorenz_63 model_mod.f90 for a new simple system.

! Modules that are absolutely required for use are listed
use        types_mod, only : r8, MISSING_R8
use time_manager_mod, only : time_type, set_time
use     location_mod, only : location_type,      get_close_maxdist_init, &
                             get_close_obs_init, get_close_obs, set_location, &
                             get_location, &
                             LocationDims, LocationName, LocationLName
use    utilities_mod, only : register_module, error_handler, E_ERR, E_MSG, &
                             do_output, nmlfileunit, &
                             find_namelist_in_file, check_namelist_read, &
                             do_nml_file, do_nml_term


implicit none
private

public :: get_model_size,         &
          adv_1step,              &
          get_state_meta_data,    &
          model_interpolate,      &
          get_model_time_step,    &
          end_model,              &
          static_init_model,      &
          init_time,              &
          init_conditions,        &
          nc_write_model_atts,    &
          nc_write_model_vars,    &
          pert_model_state,       &
          get_close_maxdist_init, &
          get_close_obs_init,     &
          get_close_obs,          &
          ens_mean_for_model


! version controlled file description for error handling, do not edit
character(len=256), parameter :: source   = &
   "$URL$"
character(len=32 ), parameter :: revision = "$Revision$"
character(len=128), parameter :: revdate  = "$Date$"

! Model size is fixed for Ikeda
integer, parameter    :: model_size = 2
type(time_type)       :: time_step
type(location_type)   :: state_loc(model_size)

!-------------------------------------------------------------
! Namelist with default values
!
real(r8) :: a  = 0.40_r8
real(r8) :: b  = 6.00_r8
real(r8) :: mu = 0.83_r8
integer  :: time_step_days      = 0
integer  :: time_step_seconds   = 3600
logical  :: output_state_vector = .true.

namelist /model_nml/ a, b, mu, time_step_days, time_step_seconds, &
                     output_state_vector


!==================================================================

contains

!==================================================================



subroutine static_init_model()
!------------------------------------------------------------------
!
! Called to do one time initialization of the model. As examples,
! might define information about the model size or model timestep.
! In models that require pre-computed static data, for instance
! spherical harmonic weights, these would also be computed here.
! Can be a NULL INTERFACE for the simplest models.

 real(r8) :: x_loc
 integer  :: i, iunit, io

! Print module information to log file and stdout.
call register_module(source, revision, revdate)

! This is where you would read a namelist, for example.
call find_namelist_in_file("input.nml", "model_nml", iunit)
read(iunit, nml = model_nml, iostat = io)
call check_namelist_read(iunit, io, "model_nml")

! Record the namelist values used for the run ...
if (do_nml_file()) write(nmlfileunit, nml=model_nml)
if (do_nml_term()) write(     *     , nml=model_nml)

! Define the locations of the model state variables
do i = 1, model_size
   x_loc = (i - 1.0_r8) / model_size
   state_loc(i) =  set_location(x_loc)
end do

! The time_step in terms of a time type must also be initialized.
time_step = set_time(time_step_seconds, time_step_days)

end subroutine static_init_model




subroutine init_conditions(x)
!------------------------------------------------------------------
! subroutine init_conditions(x)
!
! Returns a model state vector, x, that is some sort of appropriate
! initial condition for starting up a long integration of the model.
! At present, this is only used if the namelist parameter 
! start_from_restart is set to .false. in the program perfect_model_obs.
! If this option is not to be used in perfect_model_obs, or if no 
! synthetic data experiments using perfect_model_obs are planned, 
! this can be a NULL INTERFACE.

real(r8), intent(out) :: x(:)

! Initial conditions close to the attractor
x(1) =  0.1_r8
x(2) = -0.2_r8

end subroutine init_conditions



subroutine adv_1step(x, time)
!------------------------------------------------------------------
! subroutine adv_1step(x, time)
!
! Does a single timestep advance of the model. The input value of
! the vector x is the starting condition and x is updated to reflect
! the changed state after a timestep. The time argument is intent
! in and is used for models that need to know the date/time to 
! compute a timestep, for instance for radiation computations.
! This interface is only called if the namelist parameter
! async is set to 0 in perfect_model_obs of filter or if the 
! program integrate_model is to be used to advance the model
! state as a separate executable. If one of these options
! is not going to be used (the model will only be advanced as
! a separate model-specific executable), this can be a 
! NULL INTERFACE.

! Ikeda is an autonomous system (not dependent on time)

real(r8),        intent(inout) :: x(:)
type(time_type), intent(in)    :: time

real(r8) :: t, xin(2)

xin = x

! Are there any special double-precision forms of sin and cos that
!   I should be using to complement the _r8 type? 
! TJH response - no - the generic routine interface is much preferred
! nothing worse than explicity calling a double precision routine
! with a 'kind' that has been redefined to be single precision.

t = a - b/( xin(1)*xin(1) + xin(2)*xin(2) + 1.0_r8 )
x(1) = 1.0_r8 + mu*( xin(1)*cos(t) - xin(2)*sin(t) )
x(2) = mu*( xin(1)*sin(t) + xin(2)*cos(t) )

end subroutine adv_1step



function get_model_size()
!------------------------------------------------------------------
!
! Returns the size of the model as an integer. Required for all
! applications.

integer :: get_model_size

get_model_size = model_size

end function get_model_size



subroutine init_time(time)
!------------------------------------------------------------------
!
! Companion interface to init_conditions. Returns a time that is somehow 
! appropriate for starting up a long integration of the model.
! At present, this is only used if the namelist parameter 
! start_from_restart is set to .false. in the program perfect_model_obs.
! If this option is not to be used in perfect_model_obs, or if no 
! synthetic data experiments using perfect_model_obs are planned, 
! this can be a NULL INTERFACE.

type(time_type), intent(out) :: time

! for now, just set to 0
time = set_time(0,0)

end subroutine init_time



subroutine model_interpolate(x, location, itype, obs_val, istatus)
!------------------------------------------------------------------
!
! Given a state vector, a location, and a model state variable type,
! interpolates the state variable field to that location and returns
! the value in obs_val. The istatus variable should be returned as
! 0 unless there is some problem in computing the interpolation in
! which case an alternate value should be returned. The itype variable
! is a model specific integer that specifies the type of field (for
! instance temperature, zonal wind component, etc.). In low order
! models that have no notion of types of variables, this argument can
! be ignored. For applications in which only perfect model experiments
! with identity observations (i.e. only the value of a particular
! state variable is observerd), this can be a NULL INTERFACE.

real(r8),            intent(in) :: x(:)
type(location_type), intent(in) :: location
integer,             intent(in) :: itype
real(r8),           intent(out) :: obs_val
integer,            intent(out) :: istatus

! Default for successful return
istatus = 0

obs_val = MISSING_R8 ! Just to satisfy the INTENT(OUT)

end subroutine model_interpolate



function get_model_time_step()
!------------------------------------------------------------------
!
! Returns the the time step of the model; the smallest increment
! in time that the model is capable of advancing the state in a given
! implementation. This interface is required for all applications.

type(time_type) :: get_model_time_step

get_model_time_step = time_step

end function get_model_time_step



subroutine get_state_meta_data(index_in, location, var_type)
!------------------------------------------------------------------
!
! Given an integer index into the state vector structure, returns the
! associated location. A second intent(out) optional argument kind
! can be returned if the model has more than one type of field (for
! instance temperature and zonal wind component). This interface is
! required for all filter applications as it is required for computing
! the distance between observations and state variables.

integer,             intent(in)  :: index_in
type(location_type), intent(out) :: location
integer,             intent(out), optional :: var_type

! Just copied from L63 stuff
location = state_loc(index_in)
if (present(var_type)) var_type = 1    ! default variable type

end subroutine get_state_meta_data



subroutine end_model()
!------------------------------------------------------------------
!
! Does any shutdown and clean-up needed for model. Can be a NULL
! INTERFACE if the model has no need to clean up storage, etc.

! good style ... perhaps you could deallocate stuff (from static_init_model?).
! deallocate(state_loc)

end subroutine end_model




function nc_write_model_atts( ncFileID ) result (ierr)
!------------------------------------------------------------------
! TJH 24 Oct 2006 -- Writes the model-specific attributes to a netCDF file.
!     This includes coordinate variables and some metadata, but NOT
!     the model state vector. We do have to allocate SPACE for the model
!     state vector, but that variable gets filled as the model advances.
!
! As it stands, this routine will work for ANY model, with no modification.
!
! The simplest possible netCDF file would contain a 3D field
! containing the state of 'all' the ensemble members. This requires
! three coordinate variables -- one for each of the dimensions 
! [model_size, ensemble_member, time]. A little metadata is useful, 
! so we can also create some 'global' attributes. 
! This is what is implemented here.
!
! Once the simplest case is working, this routine (and nc_write_model_vars)
! can be extended to create a more logical partitioning of the state vector,
! fundamentally creating a netCDF file with variables that are easily 
! plotted. The bgrid model_mod is perhaps a good one to view, keeping
! in mind it is complicated by the fact it has two coordinate systems. 
! There are stubs in this template, but they are only stubs.
!
! TJH 29 Jul 2003 -- for the moment, all errors are fatal, so the
! return code is always '0 == normal', since the fatal errors stop execution.
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
integer :: StateVarDimID   ! netCDF pointer to state variable dimension (model size)
integer :: MemberDimID     ! netCDF pointer to dimension of ensemble    (ens_size)
integer :: TimeDimID       ! netCDF pointer to time dimension           (unlimited)

integer :: StateVarVarID   ! netCDF pointer to state variable coordinate array
integer :: StateVarID      ! netCDF pointer to 3D [state,copy,time] array

!--------------------------------------------------------------------
! local variables
!--------------------------------------------------------------------

character(len=129)    :: errstring

! we are going to need these to record the creation date in the netCDF file.
! This is entirely optional, but nice.

character(len=8)      :: crdate      ! needed by F90 DATE_AND_TIME intrinsic
character(len=10)     :: crtime      ! needed by F90 DATE_AND_TIME intrinsic
character(len=5)      :: crzone      ! needed by F90 DATE_AND_TIME intrinsic
integer, dimension(8) :: values      ! needed by F90 DATE_AND_TIME intrinsic
character(len=NF90_MAX_NAME) :: str1

integer :: i
type(location_type) :: lctn 

!-------------------------------------------------------------------------------
! make sure ncFileID refers to an open netCDF file, 
! and then put into define mode.
!-------------------------------------------------------------------------------

!-!ierr = 0                             ! assume normal termination
ierr = -1 ! assume things go poorly

call check(nf90_Inquire(ncFileID, nDimensions, nVariables, &
                                  nAttributes, unlimitedDimID), "inquire")
call check(nf90_sync(ncFileID),"sync") ! Ensure netCDF file is current
call check(nf90_Redef(ncFileID),"redef")

!-------------------------------------------------------------------------------
! We need the dimension ID for the number of copies/ensemble members, and
! we might as well check to make sure that Time is the Unlimited dimension. 
! Our job is create the 'model size' dimension.
!-------------------------------------------------------------------------------

call check(nf90_inq_dimid(ncid=ncFileID, name="copy", dimid=MemberDimID),"copy dimid")
call check(nf90_inq_dimid(ncid=ncFileID, name="time", dimid=  TimeDimID),"time dimid")

if ( TimeDimID /= unlimitedDimId ) then
   write(errstring,*)"Time Dimension ID ",TimeDimID, &
                     " should equal Unlimited Dimension ID",unlimitedDimID
   call error_handler(E_ERR,"nc_write_model_atts", errstring, source, revision, revdate)
endif

!-------------------------------------------------------------------------------
! Write Global Attributes 
!-------------------------------------------------------------------------------

call DATE_AND_TIME(crdate,crtime,crzone,values)
write(str1,'(''YYYY MM DD HH MM SS = '',i4,5(1x,i2.2))') &
                  values(1), values(2), values(3), values(5), values(6), values(7)

call check(nf90_put_att(ncFileID, NF90_GLOBAL, "creation_date" ,str1    ),"creation put")
call check(nf90_put_att(ncFileID, NF90_GLOBAL, "model_source"  ,source  ),"source put")
call check(nf90_put_att(ncFileID, NF90_GLOBAL, "model_revision",revision),"revision put")
call check(nf90_put_att(ncFileID, NF90_GLOBAL, "model_revdate" ,revdate ),"revdate put")
call check(nf90_put_att(ncFileID, NF90_GLOBAL, "model","Ikeda"       ),"model put")
call check(nf90_put_att(ncFileID, NF90_GLOBAL, "model_a", a ),"model a put")
call check(nf90_put_att(ncFileID, NF90_GLOBAL, "model_b", b ),"model b put")
call check(nf90_put_att(ncFileID, NF90_GLOBAL, "model_mu", mu ),"model mu put")

!-------------------------------------------------------------------------------
! Define the model size / state variable dimension / whatever ...
!-------------------------------------------------------------------------------
call check(nf90_def_dim(ncid=ncFileID, name="StateVariable", &
                        len=model_size, dimid = StateVarDimID),"state def_dim")

!--------------------------------------------------------------------
! Define the Location Variable and add Attributes
! Some of the atts come from location_mod (via the USE: stmnt)
! CF standards for Locations:
! http://www.cgd.ucar.edu/cms/eaton/netcdf/CF-working.html#ctype
!--------------------------------------------------------------------

call check(NF90_def_var(ncFileID, name=trim(adjustl(LocationName)), xtype=nf90_double, &
              dimids = StateVarDimID, varid=LocationVarID),"location def" )
call check(nf90_put_att(ncFileID, LocationVarID, "long_name", trim(adjustl(LocationLName))))
call check(nf90_put_att(ncFileID, LocationVarID, "dimension", LocationDims ))
call check(nf90_put_att(ncFileID, LocationVarID, "units", "nondimensional"))
call check(nf90_put_att(ncFileID, LocationVarID, "valid_range", (/ 0.0_r8, 1.0_r8 /)))

!-------------------------------------------------------------------------------
! Here is the extensible part. The simplest scenario is to output the state vector,
! parsing the state vector into model-specific parts is complicated, and you need
! to know the geometry, the output variables (PS,U,V,T,Q,...) etc. We're skipping
! complicated part.
!-------------------------------------------------------------------------------

if ( output_state_vector ) then

   !----------------------------------------------------------------------------
   ! Create a variable for the state vector
   !----------------------------------------------------------------------------

  ! Define the state vector coordinate variable and some attributes.
   call check(nf90_def_var(ncid=ncFileID,name="StateVariable", xtype=nf90_int, &
              dimids=StateVarDimID, varid=StateVarVarID), "statevariable def_var")
   call check(nf90_put_att(ncFileID, StateVarVarID, "long_name", "State Variable ID"), &
                                    "statevariable long_name")
   call check(nf90_put_att(ncFileID, StateVarVarID, "units",     "indexical"), &
                                    "statevariable units")
   call check(nf90_put_att(ncFileID, StateVarVarID, "valid_range", (/ 1, model_size /)), &
                                    "statevariable valid_range")

   ! Define the actual (3D) state vector, which gets filled as time goes on ... 
   !-!call check(nf90_def_var(ncid=ncFileID, name="state", xtype=nf90_real, &
   call check(nf90_def_var(ncid=ncFileID, name="state", xtype=nf90_double, &
              dimids = (/ StateVarDimID, MemberDimID, unlimitedDimID /), &
              varid=StateVarID), "state def_var")
   call check(nf90_put_att(ncFileID, StateVarID, "long_name", "model state or fcopy"), &
                                           "state long_name")

   ! Leave define mode so we can fill the coordinate variable.
   call check(nf90_enddef(ncfileID),"state enddef")

   ! Fill the state variable coordinate variable
   call check(nf90_put_var(ncFileID, StateVarVarID, (/ (i,i=1,model_size) /) ), &
                                    "state put_var")

else

   !----------------------------------------------------------------------------
   ! We need to process the prognostic variables.
   !----------------------------------------------------------------------------

   ! This block is a stub for something more complicated.
   ! Usually, the control for the execution of this block is a namelist variable.
   ! Take a peek at the bgrid model_mod.f90 for a (rather complicated) example.

   call check(nf90_enddef(ncfileID), "prognostic enddef")

endif

!--------------------------------------------------------------------
! Fill the location variable
!--------------------------------------------------------------------

do i = 1,model_size
   call get_state_meta_data(i,lctn)
   call check(nf90_put_var(ncFileID, LocationVarID, get_location(lctn), (/ i /) ), &
                                    "put location variable")
enddo

!-------------------------------------------------------------------------------
! Flush the buffer and leave netCDF file open
!-------------------------------------------------------------------------------
call check(nf90_sync(ncFileID),"atts sync")

ierr = 0 ! If we got here, things went well.

contains

  ! Internal subroutine - checks error status after each netcdf, prints 
  !                       text message each time an error code is returned. 
  subroutine check(istatus, string1)
  !
  ! string1 was added to provide some sense of WHERE things were bombing.
  ! It helps to determine which particular 'nf90_put_att' was generating
  ! the error, for example.

    integer, intent ( in) :: istatus
    character(len=*), intent(in), optional :: string1

    character(len=20)  :: myname = 'nc_write_model_atts '
    character(len=129) :: mystring
    integer            :: indexN

    if( istatus /= nf90_noerr) then

       if (present(string1) ) then
          if ((len_trim(string1)+len(myname)) <= len(mystring) ) then
             mystring = myname // trim(adjustl(string1))
          else
             indexN = len(mystring) - len(myname)
             mystring = myname // string1(1:indexN)
          endif
       else
          mystring = myname
       endif

       call error_handler(E_ERR, mystring, trim(nf90_strerror(istatus)), &
                          source, revision, revdate)
    endif

  end subroutine check

end function nc_write_model_atts



function nc_write_model_vars( ncFileID, statevec, copyindex, timeindex ) result (ierr)         
!------------------------------------------------------------------
! TJH 24 Oct 2006 -- Writes the model variables to a netCDF file.
!
! TJH 29 Jul 2003 -- for the moment, all errors are fatal, so the
! return code is always '0 == normal', since the fatal errors stop execution.
!
! For the lorenz_96 model, each state variable is at a separate location.
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

integer :: nDimensions, nVariables, nAttributes, unlimitedDimID

integer :: StateVarID

!-------------------------------------------------------------------------------
! make sure ncFileID refers to an open netCDF file, 
!-------------------------------------------------------------------------------

ierr = -1 ! assume things go poorly

call check(nf90_Inquire(ncFileID, nDimensions, nVariables, &
                                  nAttributes, unlimitedDimID), "inquire")

if ( output_state_vector ) then

   call check(NF90_inq_varid(ncFileID, "state", StateVarID), "state inq_varid" )
   call check(NF90_put_var(ncFileID, StateVarID, statevec,  &
                start=(/ 1, copyindex, timeindex /)), "state put_var")                   

else

   !----------------------------------------------------------------------------
   ! We need to process the prognostic variables.
   !----------------------------------------------------------------------------

   ! This block is a stub for something more complicated.
   ! Usually, the control for the execution of this block is a namelist variable.
   ! Take a peek at the bgrid model_mod.f90 for a (rather complicated) example.
   !
   ! Generally, it is necessary to take the statevec and decompose it into 
   ! the separate prognostic variables. In this (commented out) example,
   ! global_Var is a user-defined type that has components like:
   ! global_Var%ps, global_Var%t, ... etc. Each of those can then be passed
   ! directly to the netcdf put_var routine. This may cause a huge storage
   ! hit, so large models may want to avoid the duplication if possible.

   ! call vector_to_prog_var(statevec, get_model_size(), global_Var)

   ! the 'start' array is crucial. In the following example, 'ps' is a 2D
   ! array, and the netCDF variable "ps" is a 4D array [lat,lon,copy,time]

   ! call check(NF90_inq_varid(ncFileID, "ps", psVarID), "ps inq_varid")
   ! call check(nf90_put_var( ncFileID, psVarID, global_Var%ps, &
   !                          start=(/ 1, 1, copyindex, timeindex /) ), "ps put_var")

endif

!-------------------------------------------------------------------------------
! Flush the buffer and leave netCDF file open
!-------------------------------------------------------------------------------

call check(nf90_sync(ncFileID), "sync")

ierr = 0 ! If we got here, things went well.

contains

  ! Internal subroutine - checks error status after each netcdf, prints 
  !                       text message each time an error code is returned. 
  subroutine check(istatus, string1)
    integer, intent ( in) :: istatus
    character(len=*), intent(in), optional :: string1

    character(len=20)  :: myname = 'nc_write_model_vars '
    character(len=129) :: mystring
    integer            :: indexN

    if( istatus /= nf90_noerr) then

       if (present(string1) ) then
          if ((len_trim(string1)+len(myname)) <= len(mystring) ) then
             mystring = myname // trim(adjustl(string1))
          else
             indexN = len(mystring) - len(myname)
             mystring = myname // string1(1:indexN)
          endif
       else
          mystring = myname
       endif

       call error_handler(E_ERR, mystring, trim(nf90_strerror(istatus)), &
                          source, revision, revdate)
    endif

  end subroutine check

end function nc_write_model_vars



subroutine pert_model_state(state, pert_state, interf_provided)
!------------------------------------------------------------------
!
! Perturbs a model state for generating initial ensembles.
! The perturbed state is returned in pert_state.
! A model may choose to provide a NULL INTERFACE by returning
! .false. for the interf_provided argument. This indicates to
! the filter that if it needs to generate perturbed states, it
! may do so by adding an O(0.1) magnitude perturbation to each
! model state variable independently. The interf_provided argument
! should be returned as .true. if the model wants to do its own
! perturbing of states.

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
