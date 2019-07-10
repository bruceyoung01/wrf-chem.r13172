! Data Assimilation Research Testbed -- DART
! Copyright 2004-2007, Data Assimilation Research Section
! University Corporation for Atmospheric Research
! Licensed under the GPL -- www.gpl.org/licenses/gpl.html
!
   program create_airnow_co_obs_sequence
!
! <next few lines under version control, do not edit>
! $URL$
! $Id$
! $Revision$
! $Date$
!
!=============================================
! AIRNOW SURFACE AQ obs
! Based from create_obs_sequence.f90
!=============================================
!
      use    utilities_mod, only :    timestamp, 		&
                                      register_module, 		&
                                      open_file, 		&
                                      close_file, 		&
                                      initialize_utilities, 	&
                                      open_file, 		&
                                      close_file, 		&
                                      find_namelist_in_file,  	&
                                      check_namelist_read,    	&
                                      error_handler, 		&
                                      E_ERR,			& 
                                      E_WARN,			& 
                                      E_MSG, 			&
                                      E_DBG
!
      use obs_sequence_mod, only :    obs_sequence_type, 	&
                                      interactive_obs, 		&
                                      write_obs_seq, 		&
                                      interactive_obs_sequence,  &
                                      static_init_obs_sequence,  &
                                      init_obs_sequence,         &
                                      init_obs,                  &
                                      set_obs_values,            &
                                      set_obs_def,               &
                                      set_qc,                    &
                                      set_qc_meta_data,          &
                                      set_copy_meta_data,        &
                                      insert_obs_in_seq,         &
                                      obs_type
!                    
      use obs_def_mod, only :         set_obs_def_kind,          &
                                      set_obs_def_location,      &
                                      set_obs_def_time,          &
                                      set_obs_def_key,           &
                                      set_obs_def_error_variance,&
                                      obs_def_type,              &
                                      init_obs_def,              &
                                      get_obs_kind
!
      use assim_model_mod, only :     static_init_assim_model
      use location_mod, only :        location_type, 		&
                                      set_location
      use time_manager_mod, only :    set_date, 			&
                                      set_calendar_type, 	&
                                      time_type, 		&
                                      get_time
! 
      use obs_kind_mod, only :        AIRNOW_CO, 		&
                                      get_kind_from_menu
!
      use random_seq_mod, only :      random_seq_type, 	&
                                      init_random_seq, 	&
                                      random_uniform
!
      use sort_mod, only :            index_sort
!
      implicit none
!
! version controlled file description for error handling, do not edit                          
      character(len=128), parameter :: &
      source   = "$URL$", &
      revision = "$Revision$", &
      revdate  = "$Date$"
!
      type(obs_sequence_type)      :: seq
      type(obs_type)               :: obs
      type(obs_type)               :: obs_old
      type(obs_def_type)           :: obs_def
      type(location_type)          :: obs_location
      type(time_type)              :: obs_time
      integer,parameter            :: max_num_obs=2000000
      integer,parameter            :: indx_max=2000000
      integer,parameter            :: num_copies=1
      integer,parameter            :: num_qc=1
      integer,parameter            :: fileid=88
      integer                      :: icopy,iunit,status,indx,ierr,nndx
      integer                      :: year0, month0, day0, hour0, min0, sec0
      integer                      :: year1, month1, day1, hour1, min1, sec1
      integer                      :: calendar_type
      integer                      :: qc_count,qstatus
      integer                      :: seconds, days, which_vert
      integer                      :: obs_kind, obs_key
      integer                      :: days_in_month(12) =(/ &
                                      31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31  /)
      integer                      :: beg_year,beg_mon,beg_day,beg_hour,beg_min,beg_sec 
      integer                      :: end_year,end_mon,end_day,end_hour,end_min,end_sec
      integer                      :: anal_greg_sec,beg_greg_sec,end_greg_sec
      integer                      :: save_greg_sec,calc_greg_sec
      integer                      :: year_temp,month_temp,day_temp,hour_temp,minute_temp, &
                                      data_greg_sec_temp
      integer,dimension(indx_max)  :: year,month,day,hour,minute,data_greg_sec
      real                         :: fac,lat_mn,lat_mx,lon_mn,lon_mx
      real*8                       :: latitude,longitude,level
      real*8                       :: ob_err_var
      real                         :: lat_temp,lon_temp,obs_val_temp
      real,dimension(indx_max)     :: lat,lon,obs_val,obs_err
      real*8,dimension(num_qc)     :: obs_qc
      real*8,dimension(num_copies) :: obs_val_out
      real                         :: co_log_max, co_log_min
      character(len=2)             :: chr_month, chr_day
      character(len=4)             :: chr_year
      character(len=20)            :: dmy
      character(len=20)            :: var1,var2,var3,var4,var5
      character(len=20)            :: var6,var7,var8,var9,var10
      character(len=20)            :: var11,var12,var13,var14
      character(len=129)           :: copy_meta_data
      character(len=129)           :: qc_meta_data='AIRNOW QC index'
      character(len=129)           :: file_name='airnow_obs_seq'
      character(len=180)           :: file_in
      logical                      :: use_log_co, use_log_o3

      real                         :: pi,err_frac,ran1,ran2,zfac

      namelist /create_airnow_obs_nml/year0,month0,day0,hour0,beg_year,beg_mon,beg_day, &
      beg_hour,beg_min,beg_sec,end_year,end_mon,end_day,end_hour,end_min,end_sec, &
      file_in,lat_mn,lat_mx,lon_mn,lon_mx,use_log_co,use_log_o3 

!============================================================
!obs sequence extra variables
!============================================================

      pi=4.*atan(1.0)
      fac=1.0
      err_frac=0.4
      obs_qc(1)=0.

      save_greg_sec=-9999                                                 
! Record the current time, date, etc. to the logfile                                       
      call initialize_utilities('create_obs_sequence')
      call register_module(source,revision,revdate)
!
! Initialize the obs_sequence module
      call static_init_obs_sequence()
!
! Initialize an obs_sequence structure
      call init_obs_sequence(seq, num_copies, num_qc, max_num_obs)
      calendar_type=3
      call set_calendar_type(calendar_type)
!
! Initialize the obs variable
      call init_obs(obs, num_copies, num_qc)
!
      do icopy =1, num_copies
         if (icopy == 1) then
             copy_meta_data='AIRNOW observation'
         else
             copy_meta_data='Truth'
         endif
         call set_copy_meta_data(seq, icopy, copy_meta_data)
      enddo
      call set_qc_meta_data(seq, 1, qc_meta_data)
!
! READ AIRNOW OBSERVATIONS
      iunit=20
      open(unit=iunit,file='create_airnow_obs_nml.nl',form='formatted', &
      status='old',action='read')
      read(iunit,create_airnow_obs_nml)
      close(iunit)
      min0=0
      sec0=0
      print *, 'year            ',year0
      print *, 'month           ',month0
      print *, 'day             ',day0
      print *, 'hour            ',hour0
      print *, 'beg_year        ',beg_year
      print *, 'beg_mon         ',beg_mon
      print *, 'beg_day         ',beg_day
      print *, 'beg_hour        ',beg_hour
      print *, 'beg_min         ',beg_min
      print *, 'beg_sec         ',beg_sec
      print *, 'end_year        ',end_year
      print *, 'end_mon         ',end_mon
      print *, 'end_day         ',end_day
      print *, 'end_min         ',end_min
      print *, 'end_sec         ',end_sec
      print *, 'file_in         ',trim(file_in)
      print *, 'lat_mn          ',lat_mn
      print *, 'lat_mx          ',lat_mx
      print *, 'lon_mn          ',lon_mn
      print *, 'lon_mx          ',lon_mx
      print *, ' '
!
! Fix leap year number of days
      days_in_month(2)=28
      if(year0/4*4.eq.0) days_in_month(2)=29
      anal_greg_sec=calc_greg_sec(year0,month0,day0,hour0,min0,sec0,days_in_month)
      beg_greg_sec=calc_greg_sec(beg_year,beg_mon,beg_day,beg_hour,beg_min,beg_sec,days_in_month)
      end_greg_sec=calc_greg_sec(end_year,end_mon,end_day,end_hour,end_min,end_sec,days_in_month)
!
! Skip header
      iunit=101
      indx=0
      open(unit=iunit,file=trim(file_in))
      read(iunit,*) dmy
!
! Read data records
      do
         read(iunit,*,iostat=ierr) var1,var2,var3,var4,var5,var6,var7,var8, &
         var9,var10,var11,var12,var13,var14
         if(ierr.lt.0) exit
         read(var6,*) lat_temp
         read(var7,*) lon_temp
         read(var12(1:4),*) year_temp
         read(var12(6:7),*) month_temp
         read(var12(9:10),*) day_temp
         read(var13(1:2),*) hour_temp
         read(var13(4:5),*) minute_temp
         read(var14,*) obs_val_temp
         data_greg_sec_temp=calc_greg_sec(year_temp,month_temp,day_temp, &
         hour_temp,minute_temp,0,days_in_month)
!
         if (obs_val_temp .le. 0.) cycle
         if(lat_mn .le. lat_temp .and. lat_mx .ge. lat_temp .and. &
            lon_mn .le. lon_temp .and. lon_mx .ge. lon_temp .and. &
            beg_greg_sec .le. data_greg_sec_temp .and. end_greg_sec .ge. data_greg_sec_temp) then
            indx=indx+1
!            call random_number(ran1)
!            if(ran1.eq.0.) call random_number(ran1)
!            call random_number(ran2)
!            if(ran2.eq.0.) call random_number(ran2)
!            zfac=sqrt(-2.*log(ran1))*cos(2.*pi*ran2)
            lat(indx)=lat_temp
            lon(indx)=lon_temp
            year(indx)=year_temp
            month(indx)=month_temp
            day(indx)=day_temp
            hour(indx)=hour_temp
            minute(indx)=minute_temp
            obs_val(indx)=obs_val_temp*fac
! physical space error
!            obs_err(indx)=obs_val_temp*fac*err_frac
            obs_err(indx)=(exp(err_frac)-1.)*obs_val_temp*fac
            if (use_log_co) then
!               co_log_max=log(obs_val(indx)+obs_err(indx))
!               co_log_min=log(obs_val(indx)-obs_err(indx))
!               obs_err(indx)=co_log_max-log(obs_val(indx))
! log space error
               obs_err(indx)=err_frac
               obs_val(indx)=log(obs_val(indx))
            endif
            data_greg_sec(indx)=data_greg_sec_temp
         endif
      enddo
!      print *, 'APM - At end of input file read ',nndx
!      print *, 'APM - Error ',ierr
      if(ierr.gt.0) then
         print *,'APM: Read error '
         stop
      endif
      if(ierr.le.0) then
         print *,'APM: EOF reached '
      endif
      close(iunit)
      nndx=indx
!
! sort data by greg_sec

!
! put data in obs_seq_file
      qc_count=0
      do indx=1,nndx
         qstatus=0
         qc_count=qc_count+1
         if(data_greg_sec(indx).gt.save_greg_sec) save_greg_sec=data_greg_sec(indx)
!
! location
         obs_val_out(1:num_copies)=obs_val(indx)
!         level=0.0
         level=1
         latitude=lat(indx) 
         if (lon(indx)<0) then
            longitude=lon(indx)+360
         else
            longitude=lon(indx)
         endif
!
! time 
         year1=year(indx)
         month1=month(indx)
         day1=day(indx)
         hour1=hour(indx)
         min1=minute(indx)
         sec1=0
!
!         print *, year1,month1,day1,hour1,min1
         obs_time=set_date(year1,month1,day1,hour1,min1,sec1)
         call get_time(obs_time, seconds, days)
!        
!         which_vert           = -1       ! vert is surface
         which_vert           = 1       ! vert is level
         obs_location         = set_location(longitude, latitude, level, which_vert)
         ob_err_var           = obs_err(indx)*obs_err(indx)
         obs_kind             = AIRNOW_CO
!        
         call set_obs_def_kind(obs_def, obs_kind)
         call set_obs_def_location(obs_def, obs_location)
         call set_obs_def_time(obs_def, obs_time)
         call set_obs_def_error_variance(obs_def, ob_err_var)
         call set_obs_def_key(obs_def, qc_count)
         call set_obs_values(obs, obs_val_out, 1)
         call set_qc(obs, obs_qc, num_qc)
         call set_obs_def(obs, obs_def)
         if ( qc_count == 1 .or. data_greg_sec(indx).lt.save_greg_sec) then
            call insert_obs_in_seq(seq, obs)
         else
            call insert_obs_in_seq(seq, obs, obs_old )
         endif
         obs_old=obs
      enddo
!
!----------------------------------------------------------------------
! Write the sequence to a file
!----------------------------------------------------------------------
      if  (beg_hour == 3) then
         file_name=trim(file_name)//chr_year//chr_month//chr_day//'06'
      elseif (beg_hour == 9) then
         file_name=trim(file_name)//chr_year//chr_month//chr_day//'12'
      elseif (beg_hour == 15) then
         file_name=trim(file_name)//chr_year//chr_month//chr_day//'18'
      elseif (beg_hour == 21) then
         file_name=trim(file_name)//chr_year//chr_month//chr_day//'24'
      endif !bin
!
      call write_obs_seq(seq, file_name)
      close(fileid)

!-----------------------------------------------------------------------------
! Clean up
!-----------------------------------------------------------------------------
      call timestamp(string1=source,string2=revision,string3=revdate,pos='end')
   end program create_airnow_co_obs_sequence
!
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

      
  
