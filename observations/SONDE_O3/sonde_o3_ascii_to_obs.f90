! Data Assimilation Research Testbed -- DART
! Copyright 2004-2007, Data Assimilation Research Section
! University Corporation for Atmospheric Research
! Licensed under the GPL -- www.gpl.org/licenses/gpl/html
!
!  $ID: sonde_o3_ascii_to_obs.f90 V01 08/05/2019 11:13 ZHIFENG YANG EXP$
!
!******************************************************************************
!  Program sonde_o3_ascii_to_obs.f90 reads ozone sonde ascii file and
!  writes them into DART obs_seq file format.
!
!  Since file formats from different stations are different, the reading
!  subroutines are separated based on file names/stations. Thus there
!  are several different subroutines reading ozone sonde data.
!
!  flow chart:
!  ============================================================================
!  (1 )
!
!  notes:
!  ============================================================================
!  (1 ) Originally written by Zhifeng Yang by mimicking
!       airnow_o3_ascii_to_obs.f90 and tolnet_o3_ascii_to_obs.f90
!       (08/05/2019)
!******************************************************************************
!
      program create_sonde_o3_obs_sequence
!
! <next few lines under version control, do not edit>
! $URL$
! $Id$
! $Revision$
! $Date$
!
!=============================================
! SONDE O3 vertical profile obs
!=============================================
!
      use             types_mod, only : r8

      use         utilities_mod, only : timestamp,                    &
                                        register_module,              &
                                        initialize_utilities,         &
                                        file_exist,                   &
                                        open_file,                    &
                                        close_file,                   &
                                        find_namelist_in_file,        &
                                        check_namelist_read,          &
                                        error_handler,                &
                                        E_ERR,                        &
                                        E_WARN,                       &
                                        E_MSG,                        &
                                        E_DBG

      use      obs_sequence_mod, only : obs_sequence_type,            &
                                        interactive_obs,              &
                                        write_obs_seq,                &
                                        interactive_obs_sequence,     &
                                        set_obs_values,               &
                                        set_obs_def,                  &
                                        set_qc,                       &
                                        set_qc_meta_data,             &
                                        set_copy_meta_data,           &
                                        insert_obs_in_seq,            &
                                        obs_type

      use           obs_def_mod, only : set_obs_def_kind,             &
                                        set_obs_def_location,         &
                                        set_obs_def_time,             &
                                        set_obs_def_key,              &
                                        set_obs_def_error_variance,   &
                                        obs_def_type,                 &
                                        init_obs_def,                 &
                                        get_obs_kind

      use       assim_model_mod, only : static_init_assim_model

      use          location_mod, only : location_type,                &
                                        set_location

      use      time_manager_mod, only : set_date,                     &
                                        set_calendar_type,            &
                                        time_type,                    &
                                        get_time,                     &
                                        days_in_month

      use          obs_kind_mod, only : SONDE_O3,                     &
                                        get_kind_from_menu

      use        random_seq_mod, only : random_seq_type,              &
                                        init_random_seq,              &
                                        random_uniform

      use              sort_mod, only : index_sort

      implicit none

! version controlled file description for error handling, do not edit

      character (len = 128), parameter  ::                            &
      source    = "$URL$",                                            &
      revision  = "$Revision$",                                       &
      revdate   = "$Date$"

      type (obs_sequence_type)          :: seq
      type (obs_type         )          :: obs
      type (obs_type         )          :: obs_old
      type (obs_def_type     )          :: obs_def
      type (location_type    )          :: obs_location
      type (time_type        )          :: obs_time


!----------------------------------------------------------------------
! namelist variables
!----------------------------------------------------------------------

      character (len = 128)             :: file_prefix, file_postfix

      integer                           :: year0, month0, day0
      integer                           :: hour0, min0, sec0
      integer                           :: calendar_type
      integer                           :: ndays_in_month
      integer                           :: ndays_in_month_year (12) =(/&
                                           31, 28, 31, 30, 31, 30,     &
                                           31, 31, 30, 31, 30, 31  /)
      integer                           :: beg_year, beg_mon, beg_day
      integer                           :: beg_hour, beg_min, beg_sec
      integer                           :: end_year, end_mon, end_day
      integer                           :: end_hour, end_min, end_sec
      integer                           :: calc_greg_sec
      integer                           :: anal_greg_sec
      integer                           :: beg_greg_sec
      integer                           :: end_greg_sec
      real (r8)                         :: lat_mn, lat_mx
      real (r8)                         :: lon_mn, lon_mx

      logical                           :: use_log_o3




!======================================================================
! read namelist to get basic info about ozone lidar data: date, time, 
! and location.
!======================================================================

      namelist /create_tolnet_obs_nml/                                &
               year0,    month0,  day0,    hour0,    min0,            &
               beg_year, beg_mon, beg_day, beg_hour, beg_min, beg_sec,&
               end_year, end_mon, end_day, end_hour, end_min, end_sec,&
               file_prefix, file_postfix,                             &
               lat_mn,   lat_mx,  lon_mn,   lon_mx, use_log_o3

!======================================================================
! initialization
!======================================================================

! err_perc: if the o3 mixing ratio uncertainty (o3mruncert = NaN) is
!           missing, assign o3mruncert = o3mr*err_perc
! err_frac: a fraction number used to tune the o3 mixing ratio (o3mr) 
!           error if DART assimilation result is not good. OR
!           introduce error fraction for adjusting error later on
! qc_count: number of available observation values
! obs_qc  : 
      err_perc   = 0.25
      err_frac   = 1.00
      qc_count   = 0
      obs_qc     = 0.0

! Record the current time, date, etc. to the logfile.

      call initialize_utilities ('create_obs_sequence')
      call register_module (source, revision, revdate)

! Initialize the obs_sequence module
      call static_init_obs_sequence ()

! Initialize an obs_sequence structure
      call init_obs_sequence (seq, num_copies, num_qc, max_num_obs)
      calendar_type = 3
      call set_calendar_type (calendar_type)

! Initialize the obs variable
      call init_obs (obs, num_copies, num_qc)

!??????????????????????????????????????????????????????????????????????
! Double check what does this part do?
! print out meta data name. For this case, it's SONDE_O3 observation
!??????????????????????????????????????????????????????????????????????
      do icopy = 1, num_copies
         if (icopy == 1) then
            copy_meta_data = 'SONDE_O3 observation'
         else
            copy_meta_data = 'Truth'
         endif
         call set_copy_meta_data (seq, icopy, copy_meta_data)
      enddo
! grab quality control info
      call set_qc_meta_data (seq, 1, qc_meta_data)

!======================================================================
! read TOLNET text file for one profile as an example. Latter on add 
! more profiles for different time and locations.
!======================================================================

      iunit = 20
      open (unit = iunit, file = 'create_sonde_o3_obs_nml.nl', form = &
            'formatted', status = 'old', action = 'read')
      read (iunit, create_sonde_o3_obs_nml)
      close (iunit)

! Initialize min0 = 0 and sec0 = 0
! Print variables read from namelist to double check they are correct
! Actually we do not use beg_sec and end_sec, since these two values 
! are all zero through out the ozone lidar observation data.
      print *, 'year          ', year0
      print *, 'month         ', month0
      print *, 'day           ', day0
      print *, 'hour          ', hour0
      print *, 'beg_year      ', beg_year
      print *, 'beg_mon       ', beg_mon





















      end program create_sonde_o3_obs_sequence

