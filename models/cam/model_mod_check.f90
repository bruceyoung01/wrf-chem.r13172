! DART software - Copyright 2004 - 2013 UCAR. This open source software is
! provided by UCAR, "as is", without charge, subject to all terms of use at
! http://www.image.ucar.edu/DAReS/DART/DART_download
!
! $Id$




! Things which need to be defined in order to check get_close_obs:
! subroutine get_close_obs(filt_gc, base_obs_loc, base_obs_type, locs, kinds, &
!                             num_close, close_indices, distances)
! type(get_close_type), intent(in)    :: filt_gc
! type(location_type),  intent(in)    :: base_obs_loc
! integer,              intent(in)    :: base_obs_type
! type(location_type),  intent(inout) :: locs(:)
! integer,              intent(in)    :: kinds(:)
! integer,              intent(out)   :: num_close
! integer,              intent(out)   :: close_indices(:)
! real(r8),             intent(out)   :: distances(:)




program model_mod_check

!----------------------------------------------------------------------
! purpose: test routines
!----------------------------------------------------------------------

use        types_mod, only : r8, metadatalength, MISSING_R8
use    utilities_mod, only : initialize_utilities, finalize_utilities, nc_check, &
                             open_file, close_file, find_namelist_in_file, &
                             check_namelist_read, nmlfileunit, do_nml_file, &
                             do_nml_term, E_MSG, E_ERR, error_handler, file_exist
use     location_mod, only : location_type, set_location, write_location, get_dist, &
                             query_location, LocationDims, get_location, &
                             VERTISUNDEF, VERTISSURFACE, VERTISLEVEL, VERTISPRESSURE, &
                             VERTISHEIGHT, VERTISSCALEHEIGHT
use     obs_kind_mod, only : get_raw_obs_kind_name, get_raw_obs_kind_index
use  assim_model_mod, only : open_restart_read, open_restart_write, close_restart, &
                             aread_state_restart, awrite_state_restart, &
                             netcdf_file_type, aoutput_diagnostics, &
                             init_diag_output, finalize_diag_output
use time_manager_mod, only : time_type, set_calendar_type, GREGORIAN, set_time,  &
                             print_date, print_time, operator(-)
use        model_mod, only : static_init_model, get_model_size, get_state_meta_data, &
                             model_interpolate

use netcdf
use typesizes

implicit none

! version controlled file description for error handling, do not edit
character(len=256), parameter :: source   = &
   "$URL$"
character(len=32 ), parameter :: revision = "$Revision$"
character(len=128), parameter :: revdate  = "$Date$"

! standard output string
character(len=256) :: string1, string2

!------------------------------------------------------------------
! The namelist variables
!------------------------------------------------------------------

character(len=256)     :: dart_input_file      = 'dart_ics'
character(len=256)     :: output_file          = 'check_me'
logical                :: advance_time_present = .FALSE.
logical                :: verbose              = .FALSE.
integer                :: test1thru            = -1
real(r8)               :: interp_test_dlon     = 1.0
real(r8)               :: interp_test_dlat     = 1.0
real(r8)               :: interp_test_dvert    = 1000.0
real(r8), dimension(2) :: interp_test_latrange = (/ -90.0,  90.0 /)
real(r8), dimension(2) :: interp_test_lonrange = (/   0.0, 360.0 /)
real(r8), dimension(2) :: interp_test_vertrange = (/  1000.0, 5000.0 /)
real(r8), dimension(100) :: verts_of_interest     = -1.0
real(r8)               :: lon_of_interest    = -1.0
real(r8)               :: lat_of_interest    = -1.0
character(len=metadatalength) :: kind_of_interest = 'ANY'
character(len=metadatalength) :: interp_test_vertcoord = 'VERTISHEIGHT'


namelist /model_mod_check_nml/ dart_input_file, output_file, &
                        advance_time_present, test1thru, &
                        lon_of_interest,lat_of_interest,verts_of_interest, &
                        kind_of_interest, verbose, &
                        interp_test_dlon, interp_test_lonrange, &
                        interp_test_dlat, interp_test_latrange, &
                        interp_test_dvert, interp_test_vertrange, &
                        interp_test_vertcoord

!----------------------------------------------------------------------

integer :: ios_out, iunit, io, i, kvert
integer :: x_size, skip
integer :: mykindindex, vertcoord

type(time_type)       :: model_time, adv_to_time
real(r8), allocatable :: statevector(:)

character(len=metadatalength) :: state_meta(1)
type(netcdf_file_type) :: ncFileID
type(location_type) :: loc

real(r8) :: interp_val

!----------------------------------------------------------------------
! This portion checks the geometry information.
!----------------------------------------------------------------------

call initialize_utilities(progname='model_mod_check')
call set_calendar_type(GREGORIAN)

write(*,*)
write(*,*)'Reading the namelist to get the input filename.'

call find_namelist_in_file("input.nml", "model_mod_check_nml", iunit)
read(iunit, nml = model_mod_check_nml, iostat = io)
call check_namelist_read(iunit, io, "model_mod_check_nml")

! Record the namelist values used for the run
if (do_nml_file()) write(nmlfileunit, nml=model_mod_check_nml)
if (do_nml_term()) write(     *     , nml=model_mod_check_nml)

loc = set_location(lon_of_interest, lat_of_interest, verts_of_interest(1), &
                   VERTISHEIGHT)

mykindindex = get_raw_obs_kind_index(kind_of_interest)

!----------------------------------------------------------------------
! This harvests all kinds of initialization information
!----------------------------------------------------------------------
if (test1thru > 0) then

   write(*,*)
   write(*,*)
   write(*,*)'------------------ Test #1 - static_init_model ---------------------'

   call static_init_model()

   write(*,*)'------------------ Test #1 complete --------------------------------'

endif

if (test1thru > 1) then

   write(*,*)
   write(*,*)
   write(*,*)'------------------ Test #2 - get_model_size ------------------------'

   x_size = get_model_size()

   write(*,'(''state vector has length'',i10)') x_size
   ! KDR originally this was in Test #3 section, which was a problem when that section
   !     was commented out.
   allocate(statevector(x_size))

   write(*,*)'------------------ Test #2 complete --------------------------------'

endif

!----------------------------------------------------------------------
! Write a supremely simple restart file. Most of the time, I just use
! this as a starting point for a Matlab function that replaces the
! values with something more complicated.
!----------------------------------------------------------------------

if (test1thru > 2) then

   write(*,*)
   write(*,*)
   write(*,*)'------------------ Test #3 - awrite_state_restart ------------------'


   write(*,*)'Reading file '//trim(dart_input_file)
   write(*,*)'Writing data into '//trim(output_file)

   iunit = open_restart_write(output_file,'unformatted')
   call awrite_state_restart(model_time, statevector, iunit)
   call close_restart(iunit)

   call print_date( model_time,'model_mod_check:model date')
   call print_time( model_time,'model_mod_check:model time')

   write(*,*)'------------------ Test #3 complete --------------------------------'

endif

!---------------------------------------------------------------------
! Open a test DART initial conditions file.
! Reads the valid time, the state, and (possibly) a target time.
!----------------------------------------------------------------------

if (test1thru > 3) then

   write(*,*)
   write(*,*)
   write(*,*)'------------------ Test #4 - open_restart_read ---------------------'

   if ( .not. file_exist(dart_input_file) ) then
      write(string1,*) 'cannot open file [', trim(dart_input_file),'] for reading.'
      write(string2,*) "Run 'cam_to_dart' to generate ",trim(dart_input_file)
      call error_handler(E_ERR,'model_mod_check',string1, &
               source,revision,revdate,text2=string2)
   endif

   write(*,*)'Reading ['//trim(dart_input_file)//'] advance_time_present is ', &
             advance_time_present

   iunit = open_restart_read(dart_input_file)
   if ( advance_time_present ) then
      call aread_state_restart(model_time, statevector, iunit, adv_to_time)
   else
      call aread_state_restart(model_time, statevector, iunit)
   endif
   call close_restart(iunit)

   call print_date( model_time,'model_mod_check:model date')
   call print_time( model_time,'model_mod_check:model time')

   write(*,*)'------------------ Test #4 complete --------------------------------'

endif

!----------------------------------------------------------------------
! Output the state vector to a netCDF file ...
! This is the same procedure used by 'perfect_model_obs' & 'filter'
! init_diag_output()
! aoutput_diagnostics()
! finalize_diag_output()
!----------------------------------------------------------------------

if (test1thru > 4) then

   write(*,*)
   write(*,*)
   write(*,*)'------------------ Test #5 - Exercising the netCDF routines --------'

   write(*,*)'Creating '//trim(output_file)//'.nc'

   state_meta(1) = 'restart test'
   ncFileID = init_diag_output(trim(output_file),'just testing a restart', 1, state_meta)

   call aoutput_diagnostics(ncFileID, model_time, statevector, 1)

   call nc_check( finalize_diag_output(ncFileID), 'model_mod_check:main', 'finalize')

   write(*,*)'------------------ Test #5 complete --------------------------------'
endif

!----------------------------------------------------------------------
! Checking get_state_meta_data (and get_state_indices, get_state_kind)
!----------------------------------------------------------------------

if (test1thru > 5) then

   write(*,*)
   write(*,*)
   write(*,*)'------------------ Test #6 check_meta_data() -----------------------'

   skip = 6000000

   do i = 1, x_size, skip
      if ( i > 0 .and. i <= x_size ) call check_meta_data( i )
   enddo

   write(*,*)'------------------ Test #6 complete --------------------------------'

endif

!----------------------------------------------------------------------
! Trying to find the state vector index closest to a given location.
! Checking for valid input is tricky ... we don't know much.
!----------------------------------------------------------------------

if (test1thru > 6) then

   write(*,*)
   write(*,*)
   write(*,*)'------------------ Test #7 - find_closest_gridpoint() --------------'

! KDR orig:    if ( loc_of_interest(1) > 0.0_r8 ) then
   if ( lon_of_interest < 0.0_r8 ) then
      write(*,*)'Skipping test because loc_of_interest not fully specified.'
   else
      call find_closest_gridpoint( lon_of_interest, lat_of_interest, verts_of_interest(1) )
   endif

   write(*,*)'------------------ Test #7 complete --------------------------------'

endif

!----------------------------------------------------------------------
! Check the interpolation - print initially to STDOUT
!----------------------------------------------------------------------

if (test1thru > 7) then

   write(*,*)
   write(*,*)
   write(*,*)'------------------ Test #8 - single model_interpolate --------------'

   write(*,'('' KIND : '',A)') trim(kind_of_interest)
   write(*,'('' lon/lat '',3(1x,f14.5))')lon_of_interest,lat_of_interest

   ! KDR: original:   vertcoord = VERTISHEIGHT
   select case  (interp_test_vertcoord)
      case ('VERTISUNDEF')
         vertcoord = VERTISUNDEF
      case ('VERTISSURFACE')
         vertcoord = VERTISSURFACE
      case ('VERTISLEVEL')
         vertcoord = VERTISLEVEL
      case ('VERTISPRESSURE')
         vertcoord = VERTISPRESSURE
      case ('VERTISHEIGHT')
         vertcoord = VERTISHEIGHT
      case ('VERTISSCALEHEIGHT')
         vertcoord = VERTISSCALEHEIGHT
      case default
         write(*, *) 'unrecognized key for vertical type: ', interp_test_vertcoord
         STOP
   end select

   mykindindex = get_raw_obs_kind_index(kind_of_interest)

   do kvert=1,100
      if (verts_of_interest(kvert) > 0.0) exit

      loc = set_location(lon_of_interest, lat_of_interest, verts_of_interest(kvert), &
                         vertcoord)

      call model_interpolate(statevector, loc, mykindindex, interp_val, ios_out)

      if ( ios_out == 0 ) then
         write(*,*)'model_interpolate SUCCESS.'
         write(*,*)'location, value = ',lon_of_interest, lat_of_interest, &
                   verts_of_interest(kvert), interp_val
      else
         write(*,*)'model_interpolate WARNING: model_interpolate returned error code ',ios_out
      endif

   enddo

   write(*,*)'------------------ Test #8 complete --------------------------------'

endif

if (test1thru > 8) then

   write(*,*)
   write(*,*)
   write(*,*)'------------------ Test #9 - Rigorous test of model_interpolate ----'

   ios_out = test_interpolate()

   if ( ios_out == 0 ) then
      write(*,*)'Rigorous model_interpolate SUCCESS.'
   else
      write(*,*)'Rigorous model_interpolate WARNING: model_interpolate had ', ios_out, ' failures.'
   endif

   write(*,*)'------------------ Test #9 complete --------------------------------'

endif

!----------------------------------------------------------------------
! This must be the last few lines of the main program.
!----------------------------------------------------------------------

call finalize_utilities()

!----------------------------------------------------------------------
!----------------------------------------------------------------------

contains


subroutine check_meta_data( iloc )

integer, intent(in) :: iloc
type(location_type) :: loc
integer             :: var_type

! write(*,*)'Checking metadata routines.'

call get_state_meta_data( iloc, loc, var_type)

call write_location(0, loc, fform='formatted', charstring=string1)
write(*,*)' indx ',iloc,' is type ',var_type,' ', &
         trim(get_raw_obs_kind_name(var_type))
write(*,*)' and is at ',trim(string1)
write(*,*)

end subroutine check_meta_data



subroutine find_closest_gridpoint( rlon, rlat, rlev )
! Simple exhaustive search to find the indices into the
! state vector of a particular lon/lat/level. They will
! occur multiple times - once for each state variable.

real(r8), intent(in)  :: rlon, rlat, rlev

type(location_type) :: loc0, loc1
integer  :: i, var_type, which_vert
real(r8) :: loc_of_interest(3)
real(r8) :: closest, vals(3)
real(r8), allocatable, dimension(:) :: thisdist
character(len=32) :: kind_name
logical :: matched

! Check user input ... if there is no 'vertical' ...
loc_of_interest = (/rlon, rlat, rlev/)
if ( (count(loc_of_interest >= 0.0_r8) < 3) .or. &
     (LocationDims < 3 ) ) then
   write(*,*)
   write(*,*)'Interface not fully implemented.'
   return
endif

write(*,'(''Checking for the indices into the state vector that are at'')')
write(*,'(''lon/lat/lev'',3(1x,f14.5))')loc_of_interest(1:LocationDims)

allocate( thisdist(get_model_size()) )
thisdist  = 9999999999.9_r8         ! really far away
matched   = .false.

! Trying to support the ability to specify matching a particular KIND.
! With staggered grids, the closest gridpoint might not be of the kind
! you are interested in. mykindindex = -1 means anything will do.

! Since there can be/will be multiple variables with
! identical distances, we will just cruise once through
! the array and come back to find all the 'identical' values.
do i = 1,get_model_size()

   ! Really inefficient, but grab the 'which_vert' from the
   ! grid and set our target location to have the same.
   ! Then, compute the distance and compare.

   call get_state_meta_data(i, loc1, var_type)

   if ( (var_type == mykindindex) .or. (mykindindex < 0) ) then
      which_vert  = nint( query_location(loc1) )
      loc0        = set_location(rlon, rlat, rlev, which_vert)
      thisdist(i) = get_dist( loc1, loc0, no_vert= .false. )
      matched     = .true.
   endif

enddo

if (.not. matched) then
   write(*,*)'No state vector elements of type '//trim(kind_of_interest)
   return
endif

! Now that we know the distances ... report

closest = minval(thisdist)
if (closest == 9999999999.9_r8) then
   write(*,*)'No closest gridpoint found'
   return
endif


matched = .false.
do i = 1,get_model_size()

   if ( thisdist(i) == closest ) then
      call get_state_meta_data(i, loc1, var_type)
      kind_name = get_raw_obs_kind_name(var_type)
      vals = get_location(loc1)
      write(*,'(''lon/lat/lev'',3(1x,f14.5),'' is index '',i10,'' for '',a)') &
             vals, i, trim(kind_name)
      matched = .true.
   endif

enddo

if ( .not. matched ) then
   write(*,*)'Nothing matched the closest gridpoint'
endif

deallocate( thisdist )

end subroutine find_closest_gridpoint



function test_interpolate()
! function to exercise the model_mod:model_interpolate() function
! This will result in a netCDF file with all salient metadata
integer :: test_interpolate

! Local variables

real(r8), allocatable :: lon(:), lat(:), vert(:)
real(r8), allocatable :: field(:,:,:)
integer :: nlon, nlat, nvert
integer :: ilon, jlat, kvert, nfailed
character(len=128) :: ncfilename,txtfilename

character(len=8)      :: crdate      ! needed by F90 DATE_AND_TIME intrinsic
character(len=10)     :: crtime      ! needed by F90 DATE_AND_TIME intrinsic
character(len=5)      :: crzone      ! needed by F90 DATE_AND_TIME intrinsic
integer, dimension(8) :: values      ! needed by F90 DATE_AND_TIME intrinsic

integer :: ncid, nlonDimID, nlatDimID, nvertDimID
integer :: VarID, lonVarID, latVarID, vertVarID

test_interpolate = 0   ! normal termination

if ((interp_test_dlon < 0.0_r8) .or. (interp_test_dlat < 0.0_r8)) then
   write(*,*)'Skipping the rigorous interpolation test because one of'
   write(*,*)'interp_test_dlon,interp_test_dlat are < 0.0'
   write(*,*)'interp_test_dlon  = ',interp_test_dlon
   write(*,*)'interp_test_dlat  = ',interp_test_dlat
! KDR   write(*,*)'interp_test_dvert = ',interp_test_dvert
   return
endif

write( ncfilename,'(a,a)')trim(output_file),'_interptest.nc'
write(txtfilename,'(a,a)')trim(output_file),'_interptest.m'

! round down to avoid exceeding the specified range
nlat  = aint(( interp_test_latrange(2) -  interp_test_latrange(1))/interp_test_dlat) + 1
nlon  = aint(( interp_test_lonrange(2) -  interp_test_lonrange(1))/interp_test_dlon) + 1
nvert = aint(( interp_test_vertrange(2) - interp_test_vertrange(1))/interp_test_dvert) + 1
allocate(lon(nlon), lat(nlat), vert(nvert), field(nlon,nlat,nvert))

iunit = open_file(trim(txtfilename), action='write')
write(iunit,'(''missingvals = '',f12.4,'';'')')MISSING_R8
write(iunit,'(''nlon = '',i8,'';'')')nlon
write(iunit,'(''nlat = '',i8,'';'')')nlat
write(iunit,'(''nvert = '',i8,'';'')')nvert
write(iunit,'(''interptest = [ ... '')')

nfailed = 0

do ilon = 1, nlon
   lon(ilon) = interp_test_lonrange(1) + real(ilon-1,r8) * interp_test_dlon
   do jlat = 1, nlat
      lat(jlat) = interp_test_latrange(1) + real(jlat-1,r8) * interp_test_dlat
      do kvert = 1, nvert
         vert(kvert) = interp_test_vertrange(1) + real(kvert-1,r8) * interp_test_dvert

         loc = set_location(lon(ilon), lat(jlat), vert(kvert), vertcoord)

         call model_interpolate(statevector, loc, mykindindex, field(ilon,jlat,kvert), ios_out)
         write(iunit,*) field(ilon,jlat,kvert)

         if (ios_out /= 0) then
           if (verbose) then
              write(string2,'(''ilon,jlat,kvert,lon,lat,vert'',3(1x,i6),3(1x,f14.6))') &
                          ilon,jlat,kvert,lon(ilon),lat(jlat),vert(kvert)
              write(string1,*) 'interpolation return code was', ios_out
              call error_handler(E_MSG,'test_interpolate',string1,source,revision,revdate,text2=string2)
           endif
           nfailed = nfailed + 1
         endif

      enddo
   end do
end do

write(iunit,'(''];'')')
write(iunit,'(''datmat = reshape(interptest,nvert,nlat,nlon);'')')
write(iunit,'(''datmat(datmat == missingvals) = NaN;'')')
call close_file(iunit)

! Write out the netCDF file for easy exploration.

call DATE_AND_TIME(crdate,crtime,crzone,values)
write(string1,'(''YYYY MM DD HH MM SS = '',i4,5(1x,i2.2))') &
                  values(1), values(2), values(3), values(5), values(6), values(7)

call nc_check( nf90_create(path=trim(ncfilename), cmode=NF90_clobber, ncid=ncid), &
                  'test_interpolate', 'open '//trim(ncfilename))
call nc_check( nf90_put_att(ncid, NF90_GLOBAL, 'creation_date' ,trim(string1) ), &
                  'test_interpolate', 'creation put '//trim(ncfilename))
call nc_check( nf90_put_att(ncid, NF90_GLOBAL, 'parent_file', dart_input_file ), &
                  'test_interpolate', 'put_att filename '//trim(ncfilename))

! Define dimensions

call nc_check(nf90_def_dim(ncid=ncid, name='lon', len=nlon, &
        dimid = nlonDimID),'test_interpolate', 'nlon def_dim '//trim(ncfilename))

call nc_check(nf90_def_dim(ncid=ncid, name='lat', len=nlat, &
        dimid = nlatDimID),'test_interpolate', 'nlat def_dim '//trim(ncfilename))

call nc_check(nf90_def_dim(ncid=ncid, name='vert', len=nvert, &
        dimid = nvertDimID),'test_interpolate', 'nvert def_dim '//trim(ncfilename))

! Define variables

call nc_check(nf90_def_var(ncid=ncid, name='lon', xtype=nf90_double, &
        dimids=nlonDimID, varid=lonVarID), 'test_interpolate', &
                 'lon def_var '//trim(ncfilename))
call nc_check(nf90_put_att(ncid, lonVarID, 'range', interp_test_lonrange), &
           'test_interpolate', 'put_att lonrange '//trim(ncfilename))
call nc_check(nf90_put_att(ncid, lonVarID, 'cartesian_axis', 'X'),   &
           'test_interpolate', 'lon cartesian_axis '//trim(ncfilename))


call nc_check(nf90_def_var(ncid=ncid, name='lat', xtype=nf90_double, &
        dimids=nlatDimID, varid=latVarID), 'test_interpolate', &
                 'lat def_var '//trim(ncfilename))
call nc_check(nf90_put_att(ncid, latVarID, 'range', interp_test_latrange), &
           'test_interpolate', 'put_att latrange '//trim(ncfilename))
call nc_check(nf90_put_att(ncid, latVarID, 'cartesian_axis', 'Y'),   &
           'test_interpolate', 'lat cartesian_axis '//trim(ncfilename))

call nc_check(nf90_def_var(ncid=ncid, name='vert', xtype=nf90_double, &
        dimids=nvertDimID, varid=vertVarID), 'test_interpolate', &
                 'vert def_var '//trim(ncfilename))
call nc_check(nf90_put_att(ncid, vertVarID, 'range', interp_test_vertrange), &
           'test_interpolate', 'put_att vertrange '//trim(ncfilename))
call nc_check(nf90_put_att(ncid, vertVarID, 'cartesian_axis', 'Z'),   &
           'test_interpolate', 'vert cartesian_axis '//trim(ncfilename))

call nc_check(nf90_def_var(ncid=ncid, name='field', xtype=nf90_double, &
        dimids=(/ nlonDimID, nlatDimID, nvertDimID /), varid=VarID), 'test_interpolate', &
                 'field def_var '//trim(ncfilename))
call nc_check(nf90_put_att(ncid, VarID, 'long_name', kind_of_interest), &
           'test_interpolate', 'put_att field long_name '//trim(ncfilename))
call nc_check(nf90_put_att(ncid, VarID, '_FillValue', MISSING_R8), &
           'test_interpolate', 'put_att field FillValue '//trim(ncfilename))
call nc_check(nf90_put_att(ncid, VarID, 'missing_value', MISSING_R8), &
           'test_interpolate', 'put_att field missing_value '//trim(ncfilename))
call nc_check(nf90_put_att(ncid, VarID, 'vertcoord_string', interp_test_vertcoord ), &
           'test_interpolate', 'put_att field vertcoord_string '//trim(ncfilename))
call nc_check(nf90_put_att(ncid, VarID, 'vertcoord', vertcoord ), &
           'test_interpolate', 'put_att field vertcoord '//trim(ncfilename))

! Leave define mode so we can fill the variables.
call nc_check(nf90_enddef(ncid), &
              'test_interpolate','field enddef '//trim(ncfilename))

! Fill the variables
call nc_check(nf90_put_var(ncid, lonVarID, lon), &
              'test_interpolate','lon put_var '//trim(ncfilename))
call nc_check(nf90_put_var(ncid, latVarID, lat), &
              'test_interpolate','lat put_var '//trim(ncfilename))
call nc_check(nf90_put_var(ncid, vertVarID, vert), &
              'test_interpolate','vert put_var '//trim(ncfilename))
call nc_check(nf90_put_var(ncid, VarID, field), &
              'test_interpolate','field put_var '//trim(ncfilename))

! tidy up
call nc_check(nf90_close(ncid), &
             'test_interpolate','close '//trim(ncfilename))

deallocate(lon, lat, vert, field)

test_interpolate = nfailed

end function test_interpolate


end program model_mod_check

! <next few lines under version control, do not edit>
! $URL$
! $Id$
! $Revision$
! $Date$
