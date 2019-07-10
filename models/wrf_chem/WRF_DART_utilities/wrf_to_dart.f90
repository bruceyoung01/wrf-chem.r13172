! DART software - Copyright UCAR. This open source software is provided
! by UCAR, "as is", without charge, subject to all terms of use at
! http://www.image.ucar.edu/DAReS/DART/DART_download
!
! $Id$
 
PROGRAM wrf_to_dart

use        types_mod, only : r8, DEG2RAD
use time_manager_mod, only : time_type, read_time, set_date, print_time, print_date
use    utilities_mod, only : get_unit, file_exist, open_file, close_file, &
                             error_handler, E_ERR, E_MSG, initialize_utilities, &
                             register_module, logfileunit, nmlfileunit, &
                             nc_check, finalize_utilities, do_nml_file, do_nml_term, &
                             find_namelist_in_file, check_namelist_read
use  assim_model_mod, only : static_init_assim_model, open_restart_write, &
                             awrite_state_restart, close_restart
use        model_mod, only : max_state_variables, num_state_table_columns, &
                             get_wrf_state_variables, get_number_domains, &
                             get_model_size, get_wrf_static_data, trans_3Dto1D, &
                             trans_2Dto1D, get_wrf_date, wrf_static_data_for_dart

use                          netcdf

implicit none

! version controlled file description for error handling, do not edit
character(len=256), parameter :: source   = &
   "$URL$"
character(len=32 ), parameter :: revision = "$Revision$"
character(len=128), parameter :: revdate  = "$Date$"

character(len=129) :: wrf_state_variables(num_state_table_columns,max_state_variables)
character(len=129) :: my_field

type(wrf_static_data_for_dart) :: wrf

real(r8), allocatable :: wrf_var_3d(:,:,:), wrf_var_2d(:,:)
real(r8), pointer  :: dart(:)
real(r8)           :: minl, maxl
type(time_type)    :: dart_time(2)
integer            :: number_dart_values, num_domains, &
                      year, month, day, hour, minute, second
!
! LXL/APM +++
integer            :: ndims, idims(5), dimids(5)
! LXL/APM ---
!
! APM: +++
integer            :: ii,jj,kk
! APM: ---
integer            :: i, ivtype, ind, ind_lim, dart_ind, my_index, io
character(len=80)  :: varname
character(len=19)  :: timestring
character(len=2)   :: idom
integer, parameter :: max_dom = 10    ! max nested wrf domains
!
! LXL/APM +++
integer            :: ncid(max_dom), var_id, id, iunit, dart_unit, ncid_f(max_dom), &
                      ncid_emiss_chemi(max_dom), ncid_emiss_firechemi(max_dom)
! LXL/APM ---
!

! namelist section:

! set this to .true. to print out debug information while running.
! verbose - not normally useful to have on.
logical :: debug = .true.

! this can be useful to have on.  it prints a oneliner for each field
! with the data min/max.  out of range values are a clue things are bad.
logical :: print_data_ranges = .true.

! the dart vector data
character(len=129) :: dart_restart_name = "dart_wrf_vector"

!
! LXL/APM +++
logical :: add_emiss = .false., use_log_co = .false., use_log_o3 = .false.

namelist /wrf_to_dart_nml/  &
    dart_restart_name, print_data_ranges, debug, add_emiss, use_log_co, use_log_o3
! LXL/APM ---
!

! program start

if (debug) print*, 'WRF to DART'

call initialize_utilities('wrf_to_dart')
call register_module(source, revision, revdate)

call error_handler(E_MSG,'wrf_to_dart:', &
   'Converting a WRF netcdf file to a DART state vector file', &
   source, revision, revdate)
call static_init_assim_model()

! Now the one specific to this tool.
call find_namelist_in_file("input.nml", "wrf_to_dart_nml", iunit)
read(iunit, nml = wrf_to_dart_nml, iostat = io)
call check_namelist_read(iunit, io, "wrf_to_dart_nml")
      
! Record the namelist values used for the run ...
if (do_nml_file()) write(nmlfileunit, nml=wrf_to_dart_nml)
if (do_nml_term()) write(     *     , nml=wrf_to_dart_nml)
      
! debug enables all printing
if (debug) print_data_ranges = .true.

call get_wrf_state_variables(wrf_state_variables)

num_domains        = get_number_domains()
number_dart_values = get_model_size()

if ( debug ) print*,'Dart state vector length: ',number_dart_values
if ( debug ) print*,'Number of domains: ',num_domains

! allocate dart state vector
allocate(dart(number_dart_values))

! loop through domains again and append each variable to the state
dart_ind = 1
WRFDomains2 : do id = 1,num_domains

   wrf = get_wrf_static_data(id)
   write(idom,'(i2.2)') id

   print*, ' '
   print*, 'reading state data from: wrfinput_d' // idom
   if (print_data_ranges) print*, ' '

   if (debug) then
      print*, ' '
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
!
! LXL/APM +++
   call nc_check( nf90_open('wrfinput_d' // idom, NF90_NOWRITE, ncid(id)), &
                  'wrf_to_dart', 'open wrfinput_d' // idom )

   if(add_emiss) then
      call nc_check( nf90_open('wrfchemi_d' // idom, NF90_NOWRITE, ncid_emiss_chemi(id)), &
                     'wrf_to_dart', 'open wrfchemi_d' // idom )
      call nc_check( nf90_open('wrffirechemi_d' // idom, NF90_NOWRITE, ncid_emiss_firechemi(id)), &
                     'wrf_to_dart', 'open wrffirechemi_d' // idom )
   endif
!
   if(add_emiss) then
      ind_lim = wrf%number_of_conv_variables + wrf%number_of_emiss_chemi_variables + &
      wrf%number_of_emiss_firechemi_variables 
   else  
      ind_lim = wrf%number_of_conv_variables
   endif
!   
   do ind = 1, ind_lim
! LXL/APM ---
!
      if (debug) print*, ' '

      ! actual location in state variable table
      my_index = wrf%var_index_list(ind)

      my_field = wrf_state_variables(1, my_index) 
      if (debug) print*, 'field: ', trim(my_field)
!
! LXL/APM +++
      ! read wrfinput or wrfchemi
      if ( ind .le. wrf%number_of_conv_variables ) then 
         ncid_f = ncid
         if (debug) print*, ' read from wrfinput: ncid_f = ncid'
      else if (add_emiss .and. ind .gt. wrf%number_of_conv_variables .and. &
      ind .le. wrf%number_of_conv_variables + wrf%number_of_emiss_chemi_variables ) then
         ncid_f = ncid_emiss_chemi
         if (debug) print*, ' read from wrfchemi: ncid_f = ncid_emiss_chemi'
      else if (add_emiss .and. ind .gt. wrf%number_of_conv_variables + &
      wrf%number_of_emiss_chemi_variables ) then
         ncid_f = ncid_emiss_firechemi
         if (debug) print*, ' read from wrffirechemi: ncid_f = ncid_emiss_firechemi'
      endif
! LXL/APM ---
!
      ! get stagger and variable size
!
! LXL/APM +++
      call nc_check( nf90_inq_varid(ncid_f(id),wrf_state_variables(1,my_index), &
                     var_id), 'wrf_to_dart', 'inq_var_id '//trim(my_field) )
! LXL/APM ---
!
      if (  wrf%var_size(3,ind) == 1 ) then

         if (debug) then
            write(*,"(A,2(A,I5))") trim(my_field), ': 2D, size: ', wrf%var_size(1,ind), &
                                   ' by ', wrf%var_size(2,ind)
         endif

         allocate(wrf_var_2d(wrf%var_size(1,ind),wrf%var_size(2,ind)))
!
! LXL/APM +++
         call nc_check( nf90_get_var(ncid_f(id), var_id, wrf_var_2d), &
                     'wrf_to_dart','get_var '//trim(my_field) )
! LXL/APM ---
!
! APM: +++
! APM: code to take ln(x) transform of CO chemistry field
         if (use_log_co .and. trim(my_field).eq.'co') then
!            print *, 'APM: wrf_to_dart 3D CO conversion '
            do jj=1,wrf%var_size(2,ind)
               do ii=1,wrf%var_size(1,ind)
                  if(wrf_var_2d(ii,jj).gt.0.) then
                     wrf_var_2d(ii,jj)=log(wrf_var_2d(ii,jj))
                  else
                     wrf_var_2d(ii,jj)=-3.
                     print *, 'APM 2d: wrf_to_dart reset ',ii,jj,kk
                 endif
               enddo
            enddo
         endif
!
! APM: code to take ln(x) transform of O3 chemistry field
         if (use_log_o3 .and. trim(my_field).eq.'o3') then
!            print *, 'APM: wrf_to_dart 3D O3 conversion '
            do jj=1,wrf%var_size(2,ind)
               do ii=1,wrf%var_size(1,ind)
                  if(wrf_var_2d(ii,jj).gt.0.) then
                     wrf_var_2d(ii,jj)=log(wrf_var_2d(ii,jj))
                  else
                     wrf_var_2d(ii,jj)=-3.
                     print *, 'APM 2d: wrf_to_dart reset ',ii,jj,kk
                 endif
               enddo
            enddo
         endif
! APM: ---
!
         if (print_data_ranges) write(*,"(A,2F16.6)") trim(my_field)//': data min/max vals: ', &
                              minval(wrf_var_2d), maxval(wrf_var_2d)

         call trans_2Dto1D( dart(dart_ind:),wrf_var_2d, &
                            wrf%var_size(1,ind),wrf%var_size(2,ind))

         deallocate(wrf_var_2d)

      else

         if (debug) then
            write(*,"(A,3(A,I5))") trim(my_field), ': 3D, size: ', wrf%var_size(1,ind), &
                                   ' by ', wrf%var_size(2,ind), ' by ', wrf%var_size(3,ind)
                     
         endif

         allocate(wrf_var_3d(wrf%var_size(1,ind),wrf%var_size(2,ind),wrf%var_size(3,ind)))
!
! LXL/APM +++
         call nc_check( nf90_get_var(ncid_f(id), var_id, wrf_var_3d), &
                     'wrf_to_dart','get_var '//trim(my_field) )
! LXL/APM ---
!
!
! APM: +++
! APM: code to take ln(x) transform of CO chemistry field
         if (use_log_co .and. trim(my_field).eq.'co') then
!            print *, 'APM: wrf_to_dart 2D CO conversion '
            do kk=1,wrf%var_size(3,ind)
               do jj=1,wrf%var_size(2,ind)
                  do ii=1,wrf%var_size(1,ind)
                     if(wrf_var_3d(ii,jj,kk).gt.0.) then
                        wrf_var_3d(ii,jj,kk)=log(wrf_var_3d(ii,jj,kk))
                     else
                        wrf_var_3d(ii,jj,kk)=-3.
                        print *, 'APM 3d: wrf_to_dart reset ',ii,jj,kk
                    endif
                  enddo
               enddo
            enddo
         endif
!
! APM: code to take ln(x) transform of O3 chemistry field
         if (use_log_o3 .and. trim(my_field).eq.'o3') then
!            print *, 'APM: wrf_to_dart 2D O3 conversion '
            do kk=1,wrf%var_size(3,ind)
               do jj=1,wrf%var_size(2,ind)
                  do ii=1,wrf%var_size(1,ind)
                     if(wrf_var_3d(ii,jj,kk).gt.0.) then
                        wrf_var_3d(ii,jj,kk)=log(wrf_var_3d(ii,jj,kk))
                     else
                        wrf_var_3d(ii,jj,kk)=-3.
                        print *, 'APM 3d: wrf_to_dart reset ',ii,jj,kk
                    endif
                  enddo
               enddo
            enddo
         endif
! APM: ---
!
         if (print_data_ranges) write(*,"(A,2F16.6)") trim(my_field)//': data min/max vals: ', &
                              minval(wrf_var_3d), maxval(wrf_var_3d) 

         call trans_3Dto1D( dart(dart_ind:),wrf_var_3d, wrf%var_size(1,ind), & 
                            wrf%var_size(2,ind),wrf%var_size(3,ind))

         deallocate(wrf_var_3d)

      endif 

      if (debug) write(*,"(A,I9)") trim(my_field)//': starts at offset into state vector: ', dart_ind
      dart_ind = dart_ind + wrf%var_size(1,ind) * wrf%var_size(2,ind) * wrf%var_size(3,ind)
      if (debug) write(*,"(A,I9)") trim(my_field)//': ends   at offset into state vector: ', dart_ind-1
 
   enddo

enddo WRFDomains2

!---
!  output

if(debug) print*, ' '
if(debug) print*, 'WRF Times variable '
call nc_check( nf90_inq_varid(ncid(1), "Times", var_id), 'wrf_to_dart', &
               'inq_varid Times' )
call nc_check( nf90_inquire_variable(ncid(1), var_id, varname, xtype=ivtype, &
               ndims=ndims, dimids=dimids), 'wrf_to_dart', &
               'inquire_variable Times' )
do i=1,ndims
   call nc_check( nf90_inquire_dimension(ncid(1), dimids(i), &
                   len=idims(i)),'wrf_to_dart','inquire_dimensions Times' )
   if(debug) print*, ' dimension ',i,idims(i)
enddo

call nc_check( nf90_get_var(ncid(1), var_id, timestring, &
               start = (/ 1, idims(2) /)), 'wrf_to_dart','get_var Times' )

call get_wrf_date(timestring, year, month, day, hour, minute, second)
dart_time(1) = set_date(year, month, day, hour, minute, second)

print *, ' '
call print_time(dart_time(1),str='Gregorian date from wrfinput_d'//idom//':')
call print_date(dart_time(1),str='(Calendar date)                 :')

! this seems like a bad idea.  we should get the time from the wrfinput
! file, not from the time we original wrote in the wrf.info file.
!if (debug) print*, 'reading time from "wrf.info" file'
!iunit = get_unit()
!if(file_exist('wrf.info')) then
!   open(unit = iunit, file = 'wrf.info')
!   dart_time(1) = read_time(iunit)
!   close(iunit)
!endif

if (debug) print*, ' '
if (debug) call print_time(dart_time(1),str='Time written to dart vector file:')

!  open DART data file

print*, ' '
print*, 'writing data to file: '//trim(dart_restart_name)
dart_unit = open_restart_write(dart_restart_name)

call awrite_state_restart(dart_time(1), dart, dart_unit)

if(debug) print*, 'returned from state output '

call close_restart(dart_unit)

do id=1,num_domains
   call nc_check ( nf90_sync(ncid(id)),'wrf_to_dart','sync wrfinput' )
   call nc_check ( nf90_close(ncid(id)),'wrf_to_dart','close wrfinput' )
!
! LXL/APM +++
   if(add_emiss) then
      call nc_check ( nf90_sync(ncid_emiss_chemi(id)),'wrf_to_dart','sync wrfchemi' )
      call nc_check ( nf90_close(ncid_emiss_chemi(id)),'wrf_to_dart','close wrfchemi' )
      call nc_check ( nf90_sync(ncid_emiss_firechemi(id)),'wrf_to_dart','sync wrffirechemi' )
      call nc_check ( nf90_close(ncid_emiss_firechemi(id)),'wrf_to_dart','close wrffirechemi' )
   endif
! LXL/APM ---
!
enddo

deallocate(dart)

write(logfileunit,*)'FINISHED wrf_to_dart.'
write(logfileunit,*)

call finalize_utilities('wrf_to_dart')  ! closes log file.
 
end PROGRAM wrf_to_dart

! <next few lines under version control, do not edit>
! $URL$
! $Id$
! $Revision$
! $Date$
