! Data Assimilation Research Testbed -- DART
! Copyright 2004-2007, Data Assimilation Research Section
! University Corporation for Atmospheric Research
! Licensed under the GPL -- www.gpl.org/licenses/gpl/html
!
! $ID: create_tolnet_o3_obs_sequence.f90 v01 11:30 07/22/2019 exp$
!
!**********************************************************************
! program create_tolnet_o3_obs_sequence reads TOLNET ozone lidar vertical 
! profile data (in text format) and rewrites the data into obs_seq file 
! which DART can read.
!
! flow chart:
! =====================================================================
! (1 ) use modules from DART;
! (2 ) define parameters, variables for local use, variables used to 
!      read variables used for observation sequence file;
! (3 ) do year, month, day loops to read lidar data day by day;
! (4 ) read info from the text file line by line, until read before the 
!      first profile data;
! (5 ) do iprofile loop to read data profile by profile;
! (6 ) first read them as character;
! (7 ) convert characters to integer, or real;
! (8 ) put data into obs_seq file;
! (9 ) end iprofile;
! (10) end day, month, and year.
!
! notes:
! =====================================================================
! (1 ) this program is based on the create_airnow_o3_sequence.f90 
!      written by Arthur Mizzi. (Zhifeng Yang, 07/22/2019)
!**********************************************************************
      program create_tolnet_o3_obs_sequence
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
      use        types_mod,     only : r8

! timestamp: record version control
      use        utilities_mod, only : timestamp,               &
! register_module: write version info into log file
                                       register_module,         &
! initialize_utilities: open log file for writing
                                       initialize_utilities,    &
                                       open_file,               &
                                       close_file,              &
! find_namelist_in_file: find out specific nml name in the 
!                        namelist file
                                       find_namelist_in_file,   &
! check_namelist_read: confirm namelist read successfully
                                       check_namelist_read,     &
! error_handler: print error messages
                                       error_handler,           &
! E_ERR: 2 (represent error message)
                                       E_ERR,                   &
! E_WARN: 1 (represent warning message)
                                       E_WARN,                  &
! E_MSG: 0 (represent other message)
                                       E_MSG,                   &
! E_DBG: -1 (represent debug message)
                                       E_DBG

      use obs_sequence_mod, only : obs_sequence_type,           &
                                   interactive_obs,             &
                                   write_obs_seq,               &
                                   interactive_obs_sequence,    &
                                   static_init_obs_sequence,    &
                                   init_obs_sequence,           &
                                   init_obs,                    &
                                   set_obs_values,              &
                                   set_obs_def,                 &
                                   set_qc,                      &
                                   set_qc_meta_data,            &
                                   set_copy_meta_data,          &
                                   insert_obs_in_seq,           &
                                   obs_type

      use obs_def_mod,     only :  set_obs_def_kind,            &
                                   set_obs_def_location,        &
                                   set_obs_def_time,            &
                                   set_obs_def_key,             &
                                   set_obs_def_error_variance,  &
                                   obs_def_type,                &
                                   init_obs_def,                &
                                   get_obs_kind

      use assim_model_mod, only :  static_init_assim_model
      use location_mod,    only :  location_type,               &
                                   set_location
      use time_manager_mod,only :  set_date,                    &
                                   set_calendar_type,           &
                                   time_type,                   &
                                   get_time,                    &
                                   days_in_month

      use obs_kind_mod,    only :  TOLNET_O3,                   &
                                   get_kind_from_menu

      use random_seq_mod,  only :  random_seq_type,             &
                                   init_random_seq,             &
                                   random_uniform

      use sort_mod,        only :  index_sort

      implicit none

! version controlled file description for error handling, do not edit

      character (len = 128), parameter  ::                      &
      source    = "$URL$",                                      &
      revision  = "$Revision$",                                 &
      revdate   = "$Date$"

      type (obs_sequence_type)          :: seq
      type (obs_type         )          :: obs
      type (obs_type         )          :: obs_old
      type (obs_def_type     )          :: obs_def
      type (location_type    )          :: obs_location
      type (time_type        )          :: obs_time
      type (time_type        )          :: itime

      integer,   parameter              :: max_num_obs = 2000000
      integer,   parameter              :: indx_max    = max_num_obs
      integer,   parameter              :: num_copies  = 1
      integer,   parameter              :: num_qc      = 1
      real (r8), parameter              :: opposite_sign = -1.0
! Set to .true. to print debug info
      logical, parameter                :: debug       = .true.
! convert iyear, imonth, and iday to character
      character (len = 64 )             :: cdate
      character (len = 128)             :: tolnet_file
      integer                           :: ierr, icopy, iunit, status
      integer                           :: iyear, imonth, iday
      integer                           :: year0, month0, day0
      integer                           :: hour0, min0, sec0
      integer                           :: calendar_type
      integer                           :: ndays_in_month
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

!----------------------------------------------------------------------
! parameter variables need to read from text file
!----------------------------------------------------------------------

! number of general header lines (after this line)
      integer                           :: nline_header

! number of profiles in this file
      integer                           :: nprofile

! number of general comments lines (after this line)
      integer                           :: nline_comment

! number of header lines in this profile's header (after this line)
      integer                           :: nline_header_profile
! number of data lines in this profile
      integer                           :: nline_profile
! integers defined for loops
      integer                           :: iline_header, iline_comment
      integer                           :: iline, iline_header_profile
      integer                           :: iprofile, iline_profile

! profile date, time (ut) mean
      character (len = 64)              :: cdate_mean, ctime_mean

      character (len = 64)              :: cyear_mean, cmonth_mean
      character (len = 64)              :: cday_mean, chour_mean
      character (len = 64)              :: cminute_mean, csecond_mean

! date, time (ut) mean converted from cdate_mean, ctime_mean
      integer                           :: year_mean, month_mean
      integer                           :: day_mean, hour_mean
      integer                           :: minute_mean, second_mean

!----------------------------------------------------------------------
! variables to be read from text file
!----------------------------------------------------------------------

! location, elevation
      real (r8)                         :: lat, lon, ele

!----------------------------------------------------------------------
! variables used to read values as character
!----------------------------------------------------------------------

      character (len = 64)              :: calt_tmp, co3nd_tmp,       &
                                           co3nduncert_tmp,           &
                                           co3ndresol_tmp,            &
                                           cqc_tmp, cchrange_tmp,     &
                                           co3mr_tmp, co3mruncert_tmp,&
                                           cpress_tmp,                &
                                           cpressuncert_tmp,          &
                                           ctemp_tmp, ctempuncert_tmp,&
                                           cairnd_tmp, cairnduncert_tmp

! altitude
      character (len = 64), allocatable :: calt (:)

! ozone number density
      character (len = 64), allocatable :: co3nd (:), co3nduncert (:)

! precision and channel range
      character (len = 64), allocatable :: cqc (:), cchange (:)

! ozone mixing ratio
      character (len = 64), allocatable :: co3mr (:), co3mruncert (:)

! pressure
      character (len = 64), allocatable :: cpress (:), cpressuncert (:)

! temperature
      character (len = 64), allocatable :: ctemp (:), ctempuncert (:)

! air number density
      character (len = 64), allocatable :: cairnd (:), cairnduncert (:)

!----------------------------------------------------------------------
! variables used to read values as real
!----------------------------------------------------------------------

      real (r8)                         :: alt_tmp, o3nd_tmp,         &
                                           o3nduncert_tmp,            &
                                           o3ndresol_tmp,             &
                                           qc_tmp, chrange_tmp,       &
                                           o3mr_tmp, o3mruncert_tmp,  &
                                           press_tmp,                 &
                                           pressuncert_tmp,           &
                                           temp_tmp, tempuncert_tmp,  &
                                           airnd_tmp, airnduncert_tmp

! altitude
      real (r8),            allocatable :: alt (:)

! ozone number density
      real (r8),            allocatable :: o3nd (:), o3nduncert (:)
      real (r8),            allocatable :: o3ndresol (:)

! precision and channel range
      real (r8),            allocatable :: qc (:), chrange (:)

! ozone mixing ratio
      real (r8),            allocatable :: o3mr (:), o3mruncert (:)

! pressure
      real (r8),            allocatable :: press (:), pressuncert (:)

! temperature
      real (r8),            allocatable :: temp (:), tempuncert (:)

! air number density
      real (r8),            allocatable :: airnd (:), airnduncert (:)

!----------------------------------------------------------------------
! variables related to obs_seq
!----------------------------------------------------------------------
      character (len = 128)             :: copy_meta_data
      character (len = 128)             :: qc_meta_data = 'TOLNET QC index'
      character (len = 128)             :: file_name_pre= 'obs_seq_tolnet_o3_'
      character (len = 128)             :: file_prefix, file_postfix
      character (len = 128)             :: file_name

      integer                           :: qc_count, qstatus
      integer                           :: seconds, days, which_vert
      integer                           :: obs_kind, obs_key

      real (r8)                         :: latitude, longitude, level
      real (r8)                         :: o3_log_max, o3_log_min
      real (r8)                         :: err_perc, err_frac
      real (r8)                         :: obs_err_var
      real (r8), dimension (num_qc    ) :: obs_qc
      real (r8), dimension (num_copies) :: obs_val_out
      
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
! print out meta data name. For this case, it's TOLNET observation
!??????????????????????????????????????????????????????????????????????
      do icopy = 1, num_copies
         if (icopy == 1) then
            copy_meta_data = 'TOLNET observation'
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
      open (unit = iunit, file = 'create_tolnet_obs_nml.nl', form =   &
            'formatted', status = 'old', action = 'read')
      read (iunit, create_tolnet_obs_nml)
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
      print *, 'beg_day       ', beg_day
      print *, 'beg_min       ', beg_min
      print *, 'beg_sec       ', beg_sec
      print *, 'end_year      ', end_year
      print *, 'end_mon       ', end_mon
      print *, 'end_day       ', end_day
      print *, 'end_hour      ', end_hour
      print *, 'end_min       ', end_min
      print *, 'end_sec       ', end_sec
      print *, 'file_prefix   ', file_prefix
      print *, 'file_postfix  ', file_postfix
      print *, 'lat_mn        ', lat_mn
      print *, 'lat_mx        ', lat_mx
      print *, 'lon_mn        ', lon_mn
      print *, 'lon_mx        ', lon_mx
      print *, ' '

!======================================================================
! Start to read ozone lidar data in the text file format.
!======================================================================

! do iyear, imonth, and iday loops
      do iyear = beg_year, end_year

         do imonth = beg_mon, end_mon
! put date into a DART time format to calculate days_in_month
            itime          = set_date (iyear, imonth, 1)
            ndays_in_month = days_in_month (itime)
            if (debug) print *, 'ndays_in_month = ', ndays_in_month,  &
                                'in ', iyear, ' ', imonth

            do iday = beg_day, end_day

! build data file name based on date
               write (cdate, 110) iyear, imonth, iday
110            format (i4.4i2.2i2.2)
               tolnet_file = trim (file_prefix) // trim(cdate) //     &
                             trim (file_postfix)
! open input text file
               iunit = open_file (tolnet_file, 'formatted', 'read')
               if (debug) print *, 'Opened ozone lidar input file ' //&
                          TRIM (tolnet_file)

! read the line 1 to get number of general header lines
! (after this line): line 1
               read (iunit, *) nline_header
! skip line 2
               read (iunit, *)
! read number of profiles in this file: line 3
               read (iunit, *) nprofile

! skip general header lines: line 2-19
               do iline_header = 1, nline_header-2
                  read (iunit, *)
               enddo !iline_header

! read line 20 to get number of general comments lines: line 20
               read (iunit, *) nline_comment
! skip parts of general comment lines: line 21-23
               do iline_comment = 1, nline_comment-2
                  read (iunit, *)
               enddo ! iline_comment

! read longitude (DegE), latitude (DegN), and elevation (m): line 24
               read (iunit, *) lon, lat, ele
! since lon is positive value in west longitude, get the opposite sign
               lon = sign (lon, opposite_sign)
               if (debug) print *, 'lon, lat, ele = ', lon, lat, ele

!----------------------------------------------------------------------
! double check whether the site is located within the study region
               if (lat_mn .le. lat .and. lat_mx .ge. lat .and.        &
                   lon_mn .le. lon .and. lon_mx .ge. lon) then 
                  continue
               endif
! skip the last line of general comment line and '#begin profile'
               read (iunit, *) !line 25

! do iprofile loop
               do iprofile = 1, nprofile

                  read (iunit, *) !line 26 + iprofile*
                                  !(nline_header_profile + nprofile)

! read number of header lines in this profile's header
! (after this line): line 27
                  read (iunit, *) nline_header_profile
                  if (debug) print *, 'nline_header_profile = ',      &
                                       nline_header_profile
! read number of data lines in this profile: line 28
                  read (iunit, *) nline_profile
                  if (debug) print *, 'nline_profile = ',             &
                                       nline_profile

! since we already know the array size (nline_profile), allocate
                  allocate(alt        (nline_profile))
                  allocate(o3nd       (nline_profile))
                  allocate(o3nduncert (nline_profile))
                  allocate(o3ndresol  (nline_profile))
                  allocate(qc         (nline_profile))
                  allocate(chrange    (nline_profile))
                  allocate(o3mr       (nline_profile))
                  allocate(o3mruncert (nline_profile))
                  allocate(press      (nline_profile))
                  allocate(pressuncert(nline_profile))
                  allocate(temp       (nline_profile))
                  allocate(tempuncert (nline_profile))
                  allocate(airnd      (nline_profile))
                  allocate(airnduncert(nline_profile))

! skip line 29-33
                  do iline = 1, 5
                     read (iunit, *)
                  enddo !iline

! read profile date, time mean: line 34
                  read (iunit, *) cdate_mean, ctime_mean
                  cyear_mean   = cdate_mean (1:4 )
                  cmonth_mean  = cdate_mean (6:7 )
                  cday_mean    = cdate_mean (9:10)
                  chour_mean   = ctime_mean (1:2 )
                  cminute_mean = ctime_mean (4:5 )
                  csecond_mean = ctime_mean (7:8 )
                  if (debug) print *, 'cdate_mean, ctime_mean = ',    &
                                      trim(cdate_mean), ' ',          &
                                      trim(ctime_mean)

!----------------------------------------------------------------------
! convert time character to integer
!----------------------------------------------------------------------

                  read (cdate_mean (1:4 ), *) year_mean
                  read (cdate_mean (6:7 ), *) month_mean
                  read (cdate_mean (9:10), *) day_mean
                  read (ctime_mean (1:2 ), *) hour_mean
                  read (ctime_mean (4:5 ), *) minute_mean
                  read (ctime_mean (7:8 ), *) second_mean
                  print '(a17, i4.4, a1, 4(i2.2, a1), i2.2)',         &
                        'Now working on = ', year_mean,        '-',   &
                                             month_mean,       '-',   &
                                             day_mean,         ' ',   &
                                             hour_mean,        ':',   &
                                             minute_mean,      ':',   &
                                             second_mean

! skip line 35-40
                  do iline = 1, 6
                     read (iunit, *)
                  enddo

! read all the measurements now
                  do iline_profile = 1, nline_profile
                     read (iunit, *, iostat = ierr)                   &
                     calt_tmp, co3nd_tmp,                             &
                     co3nduncert_tmp,                                 &
                     co3ndresol_tmp,                                  &
                     cqc_tmp, cchrange_tmp,                           &
                     co3mr_tmp, co3mruncert_tmp,                      &
                     cpress_tmp, cpressuncert_tmp,                    &
                     ctemp_tmp, ctempuncert_tmp,                      &
                     cairnd_tmp, cairnduncert_tmp

                     if (ierr /= 0) then
                        if (debug) print *, 'got bad read code '   // &
                                            'getting rest of ozone'// &
                                            'obs, ierr = ', ierr
                        exit
                     endif

                     if (trim(calt_tmp) .ne. 'NaN')                   &
                     read (calt_tmp, *) alt_tmp
                     alt          (iline_profile) = alt_tmp

                     if (trim(co3nd_tmp) .ne. 'NaN')                  &
                     read (co3nd_tmp, *) o3nd_tmp
                     o3nd         (iline_profile) = o3nd_tmp

                     if (trim(co3ndresol_tmp) .ne. 'NaN')             &
                     read (co3ndresol_tmp, *) o3ndresol_tmp
                     o3ndresol    (iline_profile) = o3ndresol_tmp

                     if (trim(cqc_tmp) .ne. 'NaN')                    &
                     read (cqc_tmp, *) qc_tmp
                     qc           (iline_profile) = qc_tmp

                     if (trim(cchrange_tmp) .ne. 'NaN')               &
                     read (cchrange_tmp, *) chrange_tmp
                     chrange      (iline_profile) = chrange_tmp

                     if (trim(co3mr_tmp) .ne. 'NaN')                  &
                     read (co3mr_tmp, *) o3mr_tmp
                     o3mr         (iline_profile) = o3mr_tmp

                     if (trim(co3mruncert_tmp) .ne. 'NaN') then
                        read (co3mruncert_tmp, *) o3mruncert_tmp
                        o3mruncert (iline_profile) = o3mruncert_tmp
                     else
                        o3mruncert (iline_profile) = o3mr_tmp*err_frac
                     endif

                     if (trim(cpress_tmp) .ne. 'NaN')                 &
                     read (cpress_tmp, *) press_tmp
                     press        (iline_profile) = press_tmp

                     if (trim(cpressuncert_tmp) .ne. 'NaN')           &
                     read (cpressuncert_tmp, *) pressuncert_tmp
                     pressuncert  (iline_profile) = pressuncert_tmp

                     if (trim(ctemp_tmp) .ne. 'NaN')                  &
                     read (ctemp_tmp, *) temp_tmp
                     temp         (iline_profile) = temp_tmp

                     if (trim(ctempuncert_tmp) .ne. 'NaN')            &
                     read (ctempuncert_tmp, *) tempuncert_tmp
                     tempuncert   (iline_profile) = tempuncert_tmp

                     if (trim(cairnd_tmp) .ne. 'NaN')                 &
                     read (cairnd_tmp, *) airnd_tmp
                     airnd        (iline_profile) = airnd_tmp

                     if (trim(cairnduncert_tmp) .ne. 'NaN')           &
                     read (cairnduncert_tmp, *) airnduncert_tmp
                     airnduncert  (iline_profile) = airnduncert_tmp

                     if (debug) print '(a4, 14(e15.6, 1x))',           &
                                      'DA = ',                        &
                                   alt        (iline_profile),        &
                                   o3nd       (iline_profile),        &
                                   o3nduncert (iline_profile),        &
                                   o3ndresol  (iline_profile),        &
                                   qc         (iline_profile),        &
                                   chrange    (iline_profile),        &
                                   o3mr       (iline_profile),        &
                                   o3mruncert (iline_profile),        &
                                   press      (iline_profile),        &
                                   pressuncert(iline_profile),        &
                                   temp       (iline_profile),        &
                                   tempuncert (iline_profile),        &
                                   airnd      (iline_profile),        &
                                   airnduncert(iline_profile)

!======================================================================
! put data in obs_seq file
!======================================================================

! increase qc_count index
                     qc_count = qc_count + 1
! location
                     obs_val_out (1: num_copies) = o3mr (iline_profile)
                     level                       = alt  (iline_profile)
                     latitude                    = lat
                     if (lon < 0.0) then
                        longitude = lon + 360.0
                     else
                        longitude = lon
                     endif

! time
                     obs_time = set_date (year_mean, month_mean,      &
                                          day_mean,  hour_mean,       &
                                          minute_mean, second_mean)
                     call get_time (obs_time, seconds, days)

!??????????????????????????????????????????????????????????????????????
! vertical is height in meter
! which_vert:long_name = "vertical coordinate system code" ;
! which_vert:VERTISUNDEF = -2 ;
! which_vert:VERTISSURFACE = -1 ;
! which_vert:VERTISLEVEL = 1 ;
! which_vert:VERTISPRESSURE = 2 ;
! which_vert:VERTISHEIGHT = 3 ; in meter
! which_vert:VERTISSCALEHEIGHT = 4 ;
! source:
! https://www.image.ucar.edu/DAReS/DART/Manhattan/assimilation_code/  &
! location/threed_sphere/location_mod.html
!??????????????????????????????????????????????????????????????????????
                     which_vert   = 3
                     obs_location = set_location (longitude, latitude,&
                                                  level, which_vert)
                     obs_err_var  = (o3mruncert(iline_profile)*err_frac)**2
                     obs_kind     = TOLNET_O3

! call subroutines to assign data info (kind, location, time, variance, 
! quality control count) to obs_def type
                     call set_obs_def_kind          (obs_def, obs_kind      )
                     call set_obs_def_location      (obs_def, obs_location  )
                     call set_obs_def_time          (obs_def, obs_time      )
                     call set_obs_def_error_variance(obs_def, obs_err_var   )
                     call set_obs_def_key           (obs_def, qc_count      )
! call subroutines to assign observation value, quality control, and 
! obs_def to obs type
                     call set_obs_values            (obs,     obs_val_out, 1)
                     call set_qc                    (obs,     obs_qc, num_qc)
                     call set_obs_def               (obs,     obs_def       )

! assign obs to seq
                     if (qc_count == 1) then
                        call insert_obs_in_seq (seq, obs)
                     else
                        call insert_obs_in_seq (seq, obs, obs_old)
                     endif
                     obs_old = obs
                     

                  enddo !iline_profile

!----------------------------------------------------------------------
! Write the sequence to a file
                  file_name = trim(file_name_pre)//trim(cyear_mean)// &
                              trim(cmonth_mean)//trim(cday_mean)//    &
                              trim(chour_mean)//trim(cminute_mean)//  &
                              trim(csecond_mean)

                  call write_obs_seq (seq, file_name)

!----------------------------------------------------------------------
! Clean up
!----------------------------------------------------------------------

                  call timestamp (string1 = source,                   &
                                  string2 = revision,                 &
                                  string3 = revdate,                  &
                                  pos = 'end')

                  deallocate(alt        )
                  deallocate(o3nd       )
                  deallocate(o3nduncert )
                  deallocate(o3ndresol  )
                  deallocate(qc         )
                  deallocate(chrange    )
                  deallocate(o3mr       )
                  deallocate(o3mruncert )
                  deallocate(press      )
                  deallocate(pressuncert)
                  deallocate(temp       )
                  deallocate(tempuncert )
                  deallocate(airnd      )
                  deallocate(airnduncert)
               enddo  !iprofile
               write(*, *) 'work hard!!!'
            enddo  !iday
         enddo  !imonth
      enddo  !iyear

      end program create_tolnet_o3_obs_sequence

      integer function calc_greg_sec(year,month,day,hour,minute,sec,days_in_month)
         implicit none
         integer                  :: i,j,k,year,month,day,hour,minute,sec
         integer, dimension(12)   :: days_in_month
!
! assume time goes from 00:00:00 to 23:59:59  
         calc_greg_sec=0
         do i=1,month-1
            calc_greg_sec=calc_greg_sec+days_in_month(i)*24*60*60
         enddo
         do i=1,day-1
            calc_greg_sec=calc_greg_sec+24*60*60
         enddo
         do i=1,hour
            calc_greg_sec=calc_greg_sec+60*60
         enddo
         do i=1,minute
            calc_greg_sec=calc_greg_sec+60
         enddo
         calc_greg_sec=calc_greg_sec+sec
      end function calc_greg_sec

