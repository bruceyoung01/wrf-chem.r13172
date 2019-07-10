! DART software - Copyright 2004 - 2013 UCAR. This open source software is
! provided by UCAR, "as is", without charge, subject to all terms of use at
! http://www.image.ucar.edu/DAReS/DART/DART_download
!
! $Id$

program trans_statevec_to_coamps

! This program disassembles the DART state vector (without the time) then
! inserts the fields into a pre-existing COAMPS restart file.  Since 
! contained in the DART file is a target time for the integration,
! write out a file that can be read by the COAMPS run scripts so
! they can modify their namelist accordingly.

  use coamps_translate_mod, only : initialize_translator,          &
                                   open_dart_file, dart_read,      &
                                   fix_negative_values,            &
                                   convert_dart_state_to_coamps,   &
                                   generate_coamps_filenames,     &
                                   open_coamps_files,              &
                                   coamps_write_all_fields,&
                                   finalize_translator

  implicit none

! version controlled file description for error handling, do not edit
character(len=256), parameter :: source   = &
   "$URL$"
character(len=32 ), parameter :: revision = "$Revision$"
character(len=128), parameter :: revdate  = "$Date$"

  ! The translation module uses internal flags for whether it's
  ! reading or writing - these are just aliases so it's clearer
  ! what the calls are saying
  logical, parameter :: READING_DART   = .false.
  logical, parameter :: WRITING_COAMPS = .true.
  logical, parameter :: DONT_READ_TIME         = .true.

  call initialize_translator()

  call open_dart_file(READING_DART)

  call dart_read(DONT_READ_TIME)

  call fix_negative_values()

  call convert_dart_state_to_coamps()

  call generate_coamps_filenames(WRITING_COAMPS)

  call open_coamps_files(WRITING_COAMPS)

  call coamps_write_all_fields()

  call finalize_translator()
end program trans_statevec_to_coamps

! <next few lines under version control, do not edit>
! $URL$
! $Id$
! $Revision$
! $Date$
