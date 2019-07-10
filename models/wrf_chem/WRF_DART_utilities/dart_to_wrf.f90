! DART software - Copyright UCAR. This open source software is provided
! by UCAR, "as is", without charge, subject to all terms of use at
! http://www.image.ucar.edu/DAReS/DART/DART_download
!
! $Id$
 
PROGRAM dart_to_wrf

use        types_mod, only : r8, missing_r8, PI, DEG2RAD
use time_manager_mod, only : time_type, write_time, get_date, julian_day, &
                             print_time, print_date
use    utilities_mod, only : get_unit, error_handler, E_ERR, E_MSG, &
                             initialize_utilities, register_module, &
                             logfileunit, nmlfileunit, &
                             find_namelist_in_file, check_namelist_read, &
                             nc_check, do_nml_file, do_nml_term, finalize_utilities
use  assim_model_mod, only : static_init_assim_model, open_restart_read, &
                             aread_state_restart, close_restart
use        model_mod, only : max_state_variables, num_state_table_columns, &
                             get_wrf_state_variables, get_number_domains, &
                             get_model_size, get_wrf_static_data, trans_1Dto3D, &
                             trans_1Dto2D, set_wrf_date, wrf_static_data_for_dart

use                          netcdf

implicit none

! version controlled file description for error handling, do not edit
character(len=256), parameter :: source   = &
   "$URL$"
character(len=32 ), parameter :: revision = "$Revision$"
character(len=128), parameter :: revdate  = "$Date$"

!-----------------------------------------------------------------------
! dart_to_wrf namelist parameters with default values.
!-----------------------------------------------------------------------

logical            :: model_advance_file = .TRUE.
logical            :: debug = .false.
logical            :: print_data_ranges = .false.
character(len=128) :: dart_restart_name = 'dart_wrf_vector'
character(len=72)  :: adv_mod_command   = './wrf.exe'
!
! LXL/APM +++
logical            :: add_emiss = .false., use_log_co = .false., use_log_o3 = .false.

namelist /dart_to_wrf_nml/ model_advance_file, dart_restart_name, &
                           adv_mod_command, print_data_ranges, debug, add_emiss, use_log_co, use_log_o3
! LXL/APM ---
!

!-------------------------------------------------------------

character(len=129) :: wrf_state_variables(num_state_table_columns,max_state_variables)
character(len=129) :: my_field

type(wrf_static_data_for_dart) :: wrf

real(r8), pointer :: dart(:)
real(r8), pointer :: wrf_var_3d(:,:,:), wrf_var_2d(:,:)
real(r8)          :: minl, maxl
type(time_type)   :: dart_time(2)
integer           :: number_dart_values, num_domains, ndays, &
                     year, month, day, hour, minute, second
integer           :: ind, ind_lim, dart_ind, my_index, io
! APM: +++
integer            :: ii,jj,kk
! APM: ---
character(len=19) :: timestring
character(len=2)  :: idom

integer, parameter :: max_dom = 50    ! max nested wrf domains
integer            :: ncid(max_dom), var_id, id, iunit, dart_unit
!
! LXL +++
integer            :: ncid_emiss_chemi(max_dom), ncid_emiss_firechemi(max_dom), &
                      ncid_f(max_dom), i, ivtype
character(len=80)  :: varname
integer            :: ndims, idims(5), dimids(5)
! LXL ---
!

if (debug) print*, 'DART to WRF'

call initialize_utilities('dart_to_wrf')
call register_module(source, revision, revdate)

call error_handler(E_MSG,'dart_to_wrf', &
   'Converting a DART state vector to a WRF netcdf file', &
   source, revision, revdate)

call static_init_assim_model()

! Now the one specific to this tool.
call find_namelist_in_file("input.nml", "dart_to_wrf_nml", iunit)
read(iunit, nml = dart_to_wrf_nml, iostat = io)
call check_namelist_read(iunit, io, "dart_to_wrf_nml")

! Record the namelist values used for the run ...
if (do_nml_file()) write(nmlfileunit, nml=dart_to_wrf_nml)
if (do_nml_term()) write(     *     , nml=dart_to_wrf_nml)

! debug enables all printing
if (debug) print_data_ranges = .true.

call get_wrf_state_variables(wrf_state_variables)

num_domains        = get_number_domains()
number_dart_values = get_model_size()

if ( debug ) print*,'Dart state vector length: ',number_dart_values

! allocate dart state vector
allocate(dart(number_dart_values))

write (*, *) ' '

! open dart file
dart_unit = open_restart_read(dart_restart_name)

! read dart vector - this is the line which depends on whether
! this is a dart restart file or an advance_model file.
if (model_advance_file) then

   write (*, *) 'reading dart model-advance data from file: ', trim(dart_restart_name)
   call aread_state_restart(dart_time(2), dart, dart_unit, dart_time(1))
   write (*, *) ' '

   call print_time(dart_time(1),str='Advance-to Gregorian date from restart file:')
   call print_date(dart_time(1),str='(Calendar date)                            :')

   ! record wrf.info
   write (*, *) 'writing wrf.info file'
   iunit = get_unit()
   open(unit = iunit, file = 'wrf.info')
   call write_time(iunit, dart_time(1))
   call write_time(iunit, dart_time(2))
   call get_date(dart_time(2), year, month, day, hour, minute, second)
   write (iunit,FMT='(I4,5I3.2)') year, month, day, hour, minute, second

   write (iunit,*) num_domains
   write (iunit,*) adv_mod_command
   close(iunit)

else

   write (*, *) 'reading dart restart/ic data from file: ', trim(dart_restart_name)
   call aread_state_restart(dart_time(2), dart, dart_unit)
   dart_time(1) = dart_time(2)
   call get_date(dart_time(2), year, month, day, hour, minute, second)
   write (*, *) ' '

endif

call print_time(dart_time(2),str='Current data Gregorian date from restart file:')
call print_date(dart_time(2),str='(Calendar date)                              :')

call close_restart(dart_unit)

! set new times
call set_wrf_date(timestring, year, month, day, hour, minute, second)
ndays = julian_day(year, month, day)

! loop through domains and pull each variable from the state
dart_ind = 1
WRFDomains2 : do id = 1,num_domains

   write (*, *) ' '
   wrf = get_wrf_static_data(id)
   write(idom,'(i2.2)') id
   write (*, *) 'overwriting state data in: wrfinput_d' // idom

   if (debug) then
      write (*, *) ' '
      minl = minval(wrf%latitude)
      maxl = maxval(wrf%latitude)
      write(*,"(A,2F16.6)") 'latitude: min/max vals: ', minl, maxl
      write(*,"(A,2F16.6)") '               radians: ', &
                            minl * DEG2RAD, maxl * DEG2RAD
      minl = minval(wrf%longitude)
      maxl = maxval(wrf%longitude)
      write(*,"(A,2F16.6)") 'longitude: min/max vals: ', minl, maxl
      if (minl <   0.0_r8) minl = minl + 360.0_r8
      if (maxl <   0.0_r8) maxl = maxl + 360.0_r8
      if (minl > 360.0_r8) minl = minl - 360.0_r8
      if (maxl > 360.0_r8) maxl = maxl - 360.0_r8
      write(*,"(A,2F16.6)") '               radians: ', &
                            minl * DEG2RAD, maxl * DEG2RAD
      write(*,*) 'model top: ', wrf%p_top / 100.0_r8, ' hPa'
   endif

   if (print_data_ranges) write(*,*) ' '

   call nc_check( nf90_open('wrfinput_d' // idom, NF90_WRITE, ncid(id)), &
                  'dart_to_wrf', 'open wrfinput_d' // idom )
!
! LXL/APM +++
   if ( add_emiss ) then
      call nc_check( nf90_open('wrfchemi_d' // idom, NF90_WRITE, ncid_emiss_chemi(id)), &
                     'dart_to_wrf', 'open wrfchemi_d' // idom )
      call nc_check( nf90_open('wrffirechemi_d' // idom, NF90_WRITE, ncid_emiss_firechemi(id)), &
                     'dart_to_wrf', 'open wrffirechemi_d' // idom )
   endif
! LXL/APM ---
!
! APM: +++
   if(add_emiss) then
      ind_lim = wrf%number_of_conv_variables + wrf%number_of_emiss_chemi_variables + &
      wrf%number_of_emiss_firechemi_variables 
   else  
      ind_lim = wrf%number_of_conv_variables
   endif

   do ind = 1, ind_lim
! APM: ---
!
      if (debug) print*, ' ' 

      ! actual location in state variable table
      my_index = wrf%var_index_list(ind)

      my_field = trim(wrf_state_variables(1, my_index))
      if (debug) print*, 'field: ', trim(my_field)

      if (.not. wrf%var_update_list(my_index)) then
         write(*,*) ''
         write(*,*)'skipping update of ', trim(my_field), ' because of namelist control'
         cycle
      endif
!
! LXL/APM +++
! determine where to place variable from the dart state vector (wrfinput, wrfchemi, or wrffirechemi)
      if ( ind .le. wrf%number_of_conv_variables ) then
         ncid_f = ncid
         if (debug) print*, ' read from wrfinput: ncid_f = ncid'
      else if ( add_emiss .and.  ind .gt. wrf%number_of_conv_variables .and. ind .le. &
      wrf%number_of_conv_variables + wrf%number_of_emiss_chemi_variables ) then
         ncid_f = ncid_emiss_chemi
         if (debug) print*, ' read from wrfchemi: ncid_f = ncid_emiss_chemi'
      else if ( add_emiss .and.  ind .gt. wrf%number_of_conv_variables + &
         wrf%number_of_emiss_chemi_variables ) then
         ncid_f = ncid_emiss_firechemi
         if (debug) print*, ' read from wrffirechemi: ncid_f = ncid_emiss_firechemi'
      else
         print *, 'APM: dart_to_wrf - ind index exceeds the number of wrf state variables'
         stop
      endif

      ! get stagger and variable size
      call nc_check( nf90_inq_varid(ncid_f(id),wrf_state_variables(1,my_index), &
                     var_id), 'dart_to_wrf', &
                     'inq_var_id ' // wrf_state_variables(1,my_index))
! LXL/APM ---
!
      print *, 'APM: var_size ',ind,wrf%var_size(3,ind)
      print *, 'APM: variable ',ind,wrf_state_variables(1,my_index)
      if (  wrf%var_size(3,ind) == 1 ) then
!
! 1-D or 2-D field
         if ( debug ) then
            write(*,"(A,2(A,I5))") trim(my_field), ': 2D, size: ', wrf%var_size(1,ind), &
                                    ' by ', wrf%var_size(2,ind)
         endif

         allocate(wrf_var_2d(wrf%var_size(1,ind),wrf%var_size(2,ind)))

         wrf_var_2d = 0.0_r8

         call trans_1Dto2D( dart(dart_ind:), wrf_var_2d, &
                            wrf%var_size(1,ind), wrf%var_size(2,ind))

         if ( print_data_ranges ) write(*,"(A,2F16.6)") trim(my_field)//': data min/max before bounds: ', &
                                minval(wrf_var_2d), maxval(wrf_var_2d)

         ! check bounds and fail if requested
         if ( trim(wrf%clamp_or_fail(my_index)) == 'FAIL' ) then

            if (minval(wrf_var_2d) < wrf%lower_bound(my_index) ) then
               call error_handler(E_ERR,'dart_to_wrf', &
               'Variable '//trim(my_field)// &
               ' failed lower bounds check.', source,revision,revdate)
            endif

            if (maxval(wrf_var_2d) > wrf%upper_bound(my_index) ) then
               call error_handler(E_ERR,'dart_to_wrf', &
               'Variable '//trim(my_field)// &
               ' failed upper bounds check.', source,revision,revdate)
            endif

         endif ! bounds check failure request

         !  apply lower bound test
         if ( wrf%lower_bound(my_index) /= missing_r8 ) then

            if ( debug ) then
              print*, 'Setting lower bound ',wrf%lower_bound(my_index),' on ', &
                       trim(my_field)
            endif

            wrf_var_2d = max(wrf%lower_bound(my_index),wrf_var_2d)

         endif

         !  apply upper bound test
         if ( wrf%upper_bound(my_index) /= missing_r8 ) then

            if ( debug ) then
              print*, 'Setting upper bound ',wrf%upper_bound(my_index),' on ', &
                       trim(my_field)
            endif

            wrf_var_2d = min(wrf%upper_bound(my_index),wrf_var_2d)

         endif
!
! APM: +++
! APM: code to reverse ln(x) transform of CO chemistry field
         if (use_log_co .and. trim(my_field).eq.'co') then
!            print *, 'APM: dart_to_wrf 2D CO conversion '
            do jj=1,wrf%var_size(2,ind)
               do ii=1,wrf%var_size(1,ind)
                  wrf_var_2d(ii,jj)=exp(wrf_var_2d(ii,jj))
!
!                  if(wrf_var_2d(ii,jj).gt.-3.0) then
!                     wrf_var_2d(ii,jj)=exp(wrf_var_2d(ii,jj))
!                  else
!                     wrf_var_2d(ii,jj)=1.e-3
!                     print *, 'APM 2d: dart_to_wrf reset ',ii,jj
!                  endif
               enddo
            enddo
         endif
!
! APM: code to reverse ln(x) transform of O3 chemistry field
         if (use_log_o3 .and. trim(my_field).eq.'o3') then
!            print *, 'APM: dart_to_wrf 2D O3 conversion '
            do jj=1,wrf%var_size(2,ind)
               do ii=1,wrf%var_size(1,ind)
                  wrf_var_2d(ii,jj)=exp(wrf_var_2d(ii,jj))
!
!                  if(wrf_var_2d(ii,jj).gt.-3.0) then
!                     wrf_var_2d(ii,jj)=exp(wrf_var_2d(ii,jj))
!                  else
!                     wrf_var_2d(ii,jj)=4.e-3
!                     print *, 'APM 2d: dart_to_wrf reset ',ii,jj
!                  endif
               enddo
            enddo
         endif
! APM: ---
!
         if ( print_data_ranges ) write(*,"(A,2F16.6)") trim(my_field)//': data min/max after  bounds: ', &
                                minval(wrf_var_2d), maxval(wrf_var_2d)
!
! LXL/APM +++
         call nc_check( nf90_put_var(ncid_f(id), var_id, wrf_var_2d), &
                        'dart_to_wrf','put_var ' // wrf_state_variables(1,my_index) )
! LXL/APM ---
! 

         deallocate(wrf_var_2d)

      else
!
! 3-D field
         if ( debug ) then
            write(*,"(A,3(A,I5))") trim(my_field), ': 3D, size: ', wrf%var_size(1,ind), &
                                    " by ", wrf%var_size(2, ind), " by ", wrf%var_size(3, ind)
         endif

         allocate(wrf_var_3d(wrf%var_size(1,ind),wrf%var_size(2,ind),wrf%var_size(3,ind)))

         wrf_var_3d = 0.0_r8

         call trans_1Dto3D( dart(dart_ind:), wrf_var_3d, wrf%var_size(1,ind), &
                            wrf%var_size(2,ind), wrf%var_size(3,ind))

         if ( print_data_ranges ) write(*,"(A,2F16.6)") trim(my_field)//': data min/max before bounds: ', &
                                minval(wrf_var_3d), maxval(wrf_var_3d)

         ! check bounds and fail if requested
         if ( trim(wrf%clamp_or_fail(my_index)) == 'FAIL' ) then

            if (minval(wrf_var_3d) < wrf%lower_bound(my_index) ) then
               call error_handler(E_ERR,'dart_to_wrf', &
               'Variable '//trim(my_field)// &
               ' failed lower bounds check.', source,revision,revdate)
            endif

            if (maxval(wrf_var_3d) > wrf%upper_bound(my_index) ) then
               call error_handler(E_ERR,'dart_to_wrf', &
               'Variable '//trim(my_field)// &
               ' failed upper bounds check.', source,revision,revdate)
            endif

         endif ! bounds check failure request

         !  apply lower bound test
         if ( wrf%lower_bound(my_index) /= missing_r8 ) then

            if ( debug ) then
              write(*,*) 'Setting lower bound ',wrf%lower_bound(my_index),' on ', &
                          trim(my_field)
            endif

            wrf_var_3d = max(wrf%lower_bound(my_index),wrf_var_3d)
  
         endif

         !  apply upper bound test
         if ( wrf%upper_bound(my_index) /= missing_r8 ) then

            if ( debug ) then
              write(*,*) 'Setting upper bound ',wrf%upper_bound(my_index),' on ', &
                          trim(my_field)
            endif

            wrf_var_3d = min(wrf%upper_bound(my_index),wrf_var_3d)
  
         endif
!
! APM: +++
! APM: code to reverse ln(x) transform of CO chemistry field
         if (use_log_co .and. trim(my_field).eq.'co') then
!            print *, 'APM: dart_to_wrf 3D CO conversion '
            do kk=1,wrf%var_size(3,ind)
               do jj=1,wrf%var_size(2,ind)
                  do ii=1,wrf%var_size(1,ind)
                     wrf_var_3d(ii,jj,kk)=exp(wrf_var_3d(ii,jj,kk))
!
!                     if(wrf_var_3d(ii,jj,kk).gt.-3.0) then
!                        wrf_var_3d(ii,jj,kk)=exp(wrf_var_3d(ii,jj,kk))
!                     else
!                        wrf_var_3d(ii,jj,kk)=1.e-3
!                        print *, 'APM 3d: dart_to_wrf reset ',ii,jj,kk
!                     endif
                  enddo
               enddo
            enddo
         endif
!
! APM: code to reverse ln(x) transform of O3 chemistry field
         if (use_log_o3 .and. trim(my_field).eq.'o3') then
!            print *, 'APM: dart_to_wrf 3D O3 conversion '
            do kk=1,wrf%var_size(3,ind)
               do jj=1,wrf%var_size(2,ind)
                  do ii=1,wrf%var_size(1,ind)
                     wrf_var_3d(ii,jj,kk)=exp(wrf_var_3d(ii,jj,kk))
!
!                     if(wrf_var_3d(ii,jj,kk).gt.-3.0) then
!                        wrf_var_3d(ii,jj,kk)=exp(wrf_var_3d(ii,jj,kk))
!                     else
!                        wrf_var_3d(ii,jj,kk)=4.e-3
!                        print *, 'APM 3d: dart_to_wrf reset ',ii,jj,kk
!                     endif
                  enddo
               enddo
            enddo
         endif
! APM: ---
!
!
! LXL/APM +++
         call nc_check( nf90_put_var(ncid_f(id), var_id, wrf_var_3d), &
                        'dart_to_wrf', 'put_var ' // wrf_state_variables(1,my_index) )
! LXL/APM ---
!

         if ( print_data_ranges ) write(*,"(A,2F16.6)") trim(my_field)//': data min/max after  bounds: ', &
                                minval(wrf_var_3d), maxval(wrf_var_3d)

         deallocate(wrf_var_3d)

      endif 

      write(*,"(A,I9)") trim(my_field)//': starts at offset into state vector: ', dart_ind
      dart_ind = dart_ind + wrf%var_size(1,ind) * wrf%var_size(2,ind) * wrf%var_size(3,ind)
      write(*,"(A,I9)") trim(my_field)//': ends at offset into state vector:   ', dart_ind-1
 
   enddo

   ! output times too
   call nc_check( nf90_inq_varid(ncid(id), "Times", var_id), &
                  'dart_to_wrf', 'inq_varid Times' )
   call nc_check( nf90_put_var(ncid(id), var_id, timestring), &
                  'dart_to_wrf', 'put_var Times' )

   call nc_check( nf90_redef(ncid(id)), 'dart_to_wrf', 'redef' )
   call nc_check( nf90_put_att(ncid(id), nf90_global, "START_DATE", timestring), &
                'dart_to_wrf','put_att START_DATE' )
   call nc_check( nf90_put_att(ncid(id), nf90_global, "SIMULATION_START_DATE", timestring), &
                'dart_to_wrf','put_att SIMULATION_START_DATE' )
   call nc_check( nf90_put_att(ncid(id), nf90_global, "JULYR", year), &
                'dart_to_wrf','put_att JULYR' )
   call nc_check( nf90_put_att(ncid(id), nf90_global, "JULDAY", ndays), &
                'dart_to_wrf','put_att JULDY' ) 
   call nc_check( nf90_enddef(ncid(id)), 'dart_to_wrf', 'enddef' )

   ! at this point we are done with this domain
   call nc_check ( nf90_sync(ncid(id)), 'dart_to_wrf','sync wrfinput' )
   call nc_check ( nf90_close(ncid(id)),'dart_to_wrf','close wrfinput' )
!
! LXL/APM +++
   if ( add_emiss ) then
      call nc_check ( nf90_sync(ncid_emiss_chemi(id)), 'dart_to_wrf','sync wrfchemi' )
      call nc_check ( nf90_close(ncid_emiss_chemi(id)),'dart_to_wrf','close wrfchemi' )
      call nc_check ( nf90_sync(ncid_emiss_firechemi(id)), 'dart_to_wrf','sync wrffirechemi' )
      call nc_check ( nf90_close(ncid_emiss_firechemi(id)),'dart_to_wrf','close wrffirechemi' )
   endif
! LXL/APM ---
!

enddo WRFDomains2

deallocate(dart)

write(logfileunit,*)'FINISHED dart_to_wrf.'
write(logfileunit,*)

call finalize_utilities('dart_to_wrf')   ! closes log file.

end PROGRAM dart_to_wrf

! <next few lines under version control, do not edit>
! $URL$
! $Id$
! $Revision$
! $Date$
