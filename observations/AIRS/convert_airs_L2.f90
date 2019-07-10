! DART software - Copyright 2004 - 2013 UCAR. This open source software is
! provided by UCAR, "as is", without charge, subject to all terms of use at
! http://www.image.ucar.edu/DAReS/DART/DART_download
!
! $Id$

program convert_airs_L2

! Initial version of a program to read the AIRS retrievals for temperature
! and humidity. 

use types_mod,        only : r8, deg2rad, PI
use obs_sequence_mod, only : obs_sequence_type, write_obs_seq, &
                             static_init_obs_sequence, destroy_obs_sequence
use     airs_JPL_mod, only : airs_ret_rdr, airs_granule_type
use    utilities_mod, only : initialize_utilities, register_module, &
                             error_handler, finalize_utilities, E_ERR, E_MSG, &
                             find_namelist_in_file, check_namelist_read, &
                             do_nml_file, do_nml_term, &
                             logfileunit, nmlfileunit, get_next_filename

use airs_obs_mod,     only : real_obs_sequence, create_output_filename

implicit none

! ----------------------------------------------------------------------
! Declare local parameters
! ----------------------------------------------------------------------

character(len=256)      :: datafile(1), output_name, dartfile, msgstring
type(airs_granule_type) :: granule
type(obs_sequence_type) :: seq

integer :: io, iunit, index

! version controlled file description for error handling, do not edit
character(len=256), parameter :: source   = &
   "$URL$"
character(len=32 ), parameter :: revision = "$Revision$"
character(len=128), parameter :: revdate  = "$Date$"

! ----------------------------------------------------------------------
! Declare namelist parameters
! ----------------------------------------------------------------------
        
integer, parameter :: MAXFILES = 256
character(len=128) :: nextfile

character(len=128) :: l2_files(MAXFILES) = ''
character(len=128) :: l2_file_list       = ''
character(len=128) :: datadir   = '.'
character(len=128) :: outputdir = '.'

real(r8) :: lon1 =   0.0_r8,  &   !  lower longitude bound
            lon2 = 360.0_r8,  &   !  upper longitude bound 
            lat1 = -90.0_r8,  &   !  lower latitude bound
            lat2 =  90.0_r8       !  upper latitude bound

real(r8) :: min_MMR_threshold = 1.0e-30
real(r8) :: top_pressure_level = 0.0001    ! no obs higher than this
integer  :: cross_track_thin = 0
integer  :: along_track_thin = 0

namelist /convert_airs_L2_nml/ l2_files, l2_file_list, &
                               datadir, outputdir, &
                               lon1, lon2, lat1, lat2, &
                               min_MMR_threshold, top_pressure_level, &
                               cross_track_thin, along_track_thin

! ----------------------------------------------------------------------
! start of executable program code
! ----------------------------------------------------------------------

call initialize_utilities('convert_airs_L2')
call register_module(source,revision,revdate)

! Initialize the obs_sequence module ...

call static_init_obs_sequence()

!----------------------------------------------------------------------
! Read the namelist
!----------------------------------------------------------------------

call find_namelist_in_file('input.nml', 'convert_airs_L2_nml', iunit)
read(iunit, nml = convert_airs_L2_nml, iostat = io)
call check_namelist_read(iunit, io, 'convert_airs_L2_nml')

! Record the namelist values used for the run ...
if (do_nml_file()) write(nmlfileunit, nml=convert_airs_L2_nml)
if (do_nml_term()) write(    *      , nml=convert_airs_L2_nml)

if ((l2_files(1) /= '') .and. (l2_file_list /= '')) then
   write(msgstring,*)'cannot specify both an input file and an input file list'
   call error_handler(E_ERR, 'convert_airs_L2', msgstring, &
                      source, revision, revdate)
endif


index = 0

! do loop without an index.  will loop until exit called.
do
   index = index + 1
   if (l2_files(1) /= '') then
      if (index > size(l2_files)) then
         write(msgstring,*)'cannot specify more than ', size(l2_files), ' files'
         call error_handler(E_ERR, 'convert_airs_L2', msgstring, &
                            source, revision, revdate)
      endif
      nextfile = l2_files(index)
   else
      ! this is the new routine
      ! it opens the listfile, returns the index-th one
      nextfile = get_next_filename(l2_file_list, index)
   endif

   if (nextfile == '') exit

   ! construct an appropriate output filename
   call create_output_filename(nextfile, output_name)
   datafile(1) = trim(datadir)   // '/' // trim(nextfile)
   dartfile    = trim(outputdir) // '/' // trim(output_name)
   
   ! read from HDF file into a derived type that holds all the information
   call airs_ret_rdr(datafile, granule)   

   ! convert derived type information to DART sequence
   seq = real_obs_sequence(granule, lon1, lon2, lat1, lat2, &
                           min_MMR_threshold, top_pressure_level, &
                           along_track_thin, cross_track_thin) 

   ! write the sequence to a disk file
   call write_obs_seq(seq, dartfile) 
 
   ! release the sequence memory
   call destroy_obs_sequence(seq)

enddo

call error_handler(E_MSG, 'convert_airs_L2', 'Finished successfully.',source,revision,revdate)
call finalize_utilities()


end program convert_airs_L2

! <next few lines under version control, do not edit>
! $URL$
! $Id$
! $Revision$
! $Date$
