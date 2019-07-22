! Data Assimilation Research Testbed -- DART
! Copyright 2004-2007, Data Assimilation Research Section
! University Corporation for Atmospheric Research
! Licensed under the GPL -- www.gpl.org/licenses/gpl/html
!
   program create_tolnet_o3_sequence
!
! <next few lines under version control, do not edit>
! $URL$
! $Id$
! $Revision$
! $Date$
!
!=============================================
! TOLNET O3 vertical profile obs
! Based from create_airnow_o3_sequence.f90
!=============================================
!
      use        utilities_mod, only : timestamp,               &
                                       register_module,         &
                                       open_file,               &
                                       close_file,              &
                                       initialize_utilities,    &
                                       open_file,               &
                                       close_file,              &
                                       find_namelist_in_file,   &
                                       check_namelist_read,     &
                                       error_handler,           &
                                       E_ERR,                   &
                                       E_WARN,                  &
                                       E_MSG,                   &
                                       E_DBG


