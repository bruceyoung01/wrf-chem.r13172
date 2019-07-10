!
         program main
            implicit none
            integer,parameter                         :: ncycle=120
!            integer,parameter                         :: icycle_str=2
            integer,parameter                         :: icycle_str=4
!            integer,parameter                         :: icycle_str=97
            integer,parameter                         :: icycle_end=120
            integer,parameter                         :: mcycle=icycle_end-icycle_str+1   
            integer,parameter                         :: mopitt_nlev=19
            integer,parameter                         :: mopitt_nlevp=mopitt_nlev+1
            integer,parameter                         :: nobs_kind=1
            integer,parameter                         :: ier=6,isz=0,iwk=1,lunt=2,ityp=20 
!
! ityp = 1  for ncar metacode
! ityp = 11 for pdf
! ityp = 20 for color postscript
!
            character(len=150),dimension(ncycle)      :: cycle,sp_cycle
            character(len=150)                        :: path_acd,path_scratch,path_obs_seq
            character(len=150)                        :: path_obs_seq_loc
            character(len=150)                        :: file,file_in,file_out
            real                                      :: pi,rad2deg,re
            integer                                   :: k,kstr,icycle,dcycle,iunit_in,iunit_out
            integer                                   :: mopitt_nprp
!
! obs_seq file arrays
            integer                                   :: iunit,mobs_kind,mrec,nrec,kind_id,num_copies,num_qc
            integer                                   :: num_obs,max_num_obs,first_obs,last_obs,nid
            integer                                   :: obs_rec,rec_num,z_id,cnt_mopitt,ilv      
            integer                                   :: keep,mopitt_npr
            integer                                   :: obs_day,obs_sec,sw_plt
            integer,dimension(nobs_kind)              :: obs_kind_id
            integer,dimension(3)                      :: point
            character(len=150)                        :: time
            real*8                                    :: obs_val,err_var,x,y,z,mopitt_prior,mopitt_psfc
            real*8                                    :: prs,avg,twt
            real*8                                    :: ncep_qc,dart_qc
!
            real*8,dimension(mopitt_nlev)             :: mopitt_avgker,mopitt_pressure_mid
            real*8,dimension(mopitt_nlevp)            :: mopitt_pressure
!
            double precision                          :: co_obs,co_prior,co_post
!       
            character(len=150),dimension(nobs_kind)   :: obs_kind
            character(len=150)                        :: path,file_type,obs_kind_defn
            character(len=150)                        :: chr_num_copies,chr_num_qc,chr_num_obs,chr_max_num_obs
            character(len=150)                        :: meta_data,chr_first_obs,chr_last_obs,chr_obs,chr_obdef
            character(len=150)                        :: chr_locxd,chr_kind,kind_defn
!
! open graphics
!            call gopks(ier,isz)
!            call gopwk(iwk,lunt,ityp)
!            call gacwk(iwk)
!
! assign constants
            pi=4.*atan(1.)
            rad2deg=360./(2.*pi)
            re=6371000.
!
! assign cycle dates
            cycle(1)='2008060100'
            cycle(2)='2008060106'
            cycle(3)='2008060112'
            cycle(4)='2008060118'
            cycle(5)='2008060200'
            cycle(6)='2008060206'
            cycle(7)='2008060212'
            cycle(8)='2008060218'
            cycle(9)='2008060300'
            cycle(10)='2008060306'
            cycle(11)='2008060312'
            cycle(12)='2008060318'
            cycle(13)='2008060400'
            cycle(14)='2008060406'
            cycle(15)='2008060412'
            cycle(16)='2008060418'
            cycle(17)='2008060500'
            cycle(18)='2008060506'
            cycle(19)='2008060512'
            cycle(20)='2008060518'
            cycle(21)='2008060600'
            cycle(22)='2008060606'
            cycle(23)='2008060612'
            cycle(24)='2008060618'
            cycle(25)='2008060700'
            cycle(26)='2008060706'
            cycle(27)='2008060712'
            cycle(28)='2008060718'
            cycle(29)='2008060800'
            cycle(30)='2008060806'
            cycle(31)='2008060812'
            cycle(32)='2008060818'
            cycle(33)='2008060900'
            cycle(34)='2008060906'
            cycle(35)='2008060912'
            cycle(36)='2008060918'
            cycle(37)='2008061000'
            cycle(38)='2008061006'
            cycle(39)='2008061012'
            cycle(40)='2008061018'
            cycle(41)='2008061100'
            cycle(42)='2008061106'
            cycle(43)='2008061112'
            cycle(44)='2008061118'
            cycle(45)='2008061200'
            cycle(46)='2008061206'
            cycle(47)='2008061212'
            cycle(48)='2008061218'
            cycle(49)='2008061300'
            cycle(50)='2008061306'
            cycle(51)='2008061312'
            cycle(52)='2008061318'
            cycle(53)='2008061400'
            cycle(54)='2008061406'
            cycle(55)='2008061412'
            cycle(56)='2008061418'
            cycle(57)='2008061500'
            cycle(58)='2008061506'
            cycle(59)='2008061512'
            cycle(60)='2008061518'
            cycle(61)='2008061600'
            cycle(62)='2008061606'
            cycle(63)='2008061612'
            cycle(64)='2008061618'
            cycle(65)='2008061700'
            cycle(66)='2008061706'
            cycle(67)='2008061712'
            cycle(68)='2008061718'
            cycle(69)='2008061800'
            cycle(70)='2008061806'
            cycle(71)='2008061812'
            cycle(72)='2008061818'
            cycle(73)='2008061900'
            cycle(74)='2008061906'
            cycle(75)='2008061912'
            cycle(76)='2008061918'
            cycle(77)='2008062000'
            cycle(78)='2008062006'
            cycle(79)='2008062012'
            cycle(80)='2008062018'
            cycle(81)='2008062100'
            cycle(82)='2008062106'
            cycle(83)='2008062112'
            cycle(84)='2008062118'
            cycle(85)='2008062200'
            cycle(86)='2008062206'
            cycle(87)='2008062212'
            cycle(88)='2008062218'
            cycle(89)='2008062300'
            cycle(90)='2008062306'
            cycle(91)='2008062312'
            cycle(92)='2008062318'
            cycle(93)='2008062400'
            cycle(94)='2008062406'
            cycle(95)='2008062412'
            cycle(96)='2008062418'
            cycle(97)='2008062500'
            cycle(98)='2008062506'
            cycle(99)='2008062512'
            cycle(100)='2008062518'
            cycle(101)='2008062600'
            cycle(102)='2008062606'
            cycle(103)='2008062612'
            cycle(104)='2008062618'
            cycle(105)='2008062700'
            cycle(106)='2008062706'
            cycle(107)='2008062712'
            cycle(108)='2008062718'
            cycle(109)='2008062800'
            cycle(110)='2008062806'
            cycle(111)='2008062812'
            cycle(112)='2008062818'
            cycle(113)='2008062900'
            cycle(114)='2008062906'
            cycle(115)='2008062912'
            cycle(116)='2008062918'
            cycle(117)='2008063000'
            cycle(118)='2008063006'
            cycle(119)='2008063012'
            cycle(120)='2008063018'
            sp_cycle(1)='2008053124'
            sp_cycle(2)='2008060106'
            sp_cycle(3)='2008060112'
            sp_cycle(4)='2008060118'
            sp_cycle(5)='2008060124'
            sp_cycle(6)='2008060206'
            sp_cycle(7)='2008060212'
            sp_cycle(8)='2008060218'
            sp_cycle(9)='2008060224'
            sp_cycle(10)='2008060306'
            sp_cycle(11)='2008060312'
            sp_cycle(12)='2008060318'
            sp_cycle(13)='2008060324'
            sp_cycle(14)='2008060406'
            sp_cycle(15)='2008060412'
            sp_cycle(16)='2008060418'
            sp_cycle(17)='2008060424'
            sp_cycle(18)='2008060506'
            sp_cycle(19)='2008060512'
            sp_cycle(20)='2008060518'
            sp_cycle(21)='2008060524'
            sp_cycle(22)='2008060606'
            sp_cycle(23)='2008060612'
            sp_cycle(24)='2008060618'
            sp_cycle(25)='2008060624'
            sp_cycle(26)='2008060706'
            sp_cycle(27)='2008060712'
            sp_cycle(28)='2008060718'
            sp_cycle(29)='2008060724'
            sp_cycle(30)='2008060806'
            sp_cycle(31)='2008060812'
            sp_cycle(32)='2008060818'
            sp_cycle(33)='2008060824'
            sp_cycle(34)='2008060906'
            sp_cycle(35)='2008060912'
            sp_cycle(36)='2008060918'
            sp_cycle(37)='2008060924'
            sp_cycle(38)='2008061006'
            sp_cycle(39)='2008061012'
            sp_cycle(40)='2008061018'
            sp_cycle(41)='2008061024'
            sp_cycle(42)='2008061106'
            sp_cycle(43)='2008061112'
            sp_cycle(44)='2008061118'
            sp_cycle(45)='2008061124'
            sp_cycle(46)='2008061206'
            sp_cycle(47)='2008061212'
            sp_cycle(48)='2008061218'
            sp_cycle(49)='2008061224'
            sp_cycle(50)='2008061306'
            sp_cycle(51)='2008061312'
            sp_cycle(52)='2008061318'
            sp_cycle(53)='2008061324'
            sp_cycle(54)='2008061406'
            sp_cycle(55)='2008061412'
            sp_cycle(56)='2008061418'
            sp_cycle(57)='2008061424'
            sp_cycle(58)='2008061506'
            sp_cycle(59)='2008061512'
            sp_cycle(60)='2008061518'
            sp_cycle(61)='2008061524'
            sp_cycle(62)='2008061606'
            sp_cycle(63)='2008061612'
            sp_cycle(64)='2008061618'
            sp_cycle(65)='2008061624'
            sp_cycle(66)='2008061706'
            sp_cycle(67)='2008061712'
            sp_cycle(68)='2008061718'
            sp_cycle(69)='2008061724'
            sp_cycle(70)='2008061806'
            sp_cycle(71)='2008061812'
            sp_cycle(72)='2008061818'
            sp_cycle(73)='2008061824'
            sp_cycle(74)='2008061906'
            sp_cycle(75)='2008061912'
            sp_cycle(76)='2008061918'
            sp_cycle(77)='2008061924'
            sp_cycle(78)='2008062006'
            sp_cycle(79)='2008062012'
            sp_cycle(80)='2008062018'
            sp_cycle(81)='2008062024'
            sp_cycle(82)='2008062106'
            sp_cycle(83)='2008062112'
            sp_cycle(84)='2008062118'
            sp_cycle(85)='2008062124'
            sp_cycle(86)='2008062206'
            sp_cycle(87)='2008062212'
            sp_cycle(88)='2008062218'
            sp_cycle(89)='2008062224'
            sp_cycle(90)='2008062306'
            sp_cycle(91)='2008062312'
            sp_cycle(92)='2008062318'
            sp_cycle(93)='2008062324'
            sp_cycle(94)='2008062406'
            sp_cycle(95)='2008062412'
            sp_cycle(96)='2008062418'
            sp_cycle(97)='2008062424'
            sp_cycle(98)='2008062506'
            sp_cycle(99)='2008062512'
            sp_cycle(100)='2008062518'
            sp_cycle(101)='2008062524'
            sp_cycle(102)='2008062606'
            sp_cycle(103)='2008062612'
            sp_cycle(104)='2008062618'
            sp_cycle(105)='2008062624'
            sp_cycle(106)='2008062706'
            sp_cycle(107)='2008062712'
            sp_cycle(108)='2008062718'
            sp_cycle(109)='2008062724'
            sp_cycle(110)='2008062806'
            sp_cycle(111)='2008062812'
            sp_cycle(112)='2008062818'
            sp_cycle(113)='2008062824'
            sp_cycle(114)='2008062906'
            sp_cycle(115)='2008062912'
            sp_cycle(116)='2008062918'
            sp_cycle(117)='2008062924'
            sp_cycle(118)='2008063006'
            sp_cycle(119)='2008063012'
            sp_cycle(120)='2008063018'
!
! loop through cycles
            do icycle=icycle_str,icycle_end
               dcycle=icycle-icycle_str+1
!
! assign data paths
               path_acd='/glade/p/acd/mizzi/AVE_TEST_DATA'
               path_scratch='/glade/scratch/mizzi/AVE_TEST_DATA'

!               path_obs_seq=trim(path_acd)//'/'//trim(cycle(icycle))//'/'//'obs_MOPITT_Mig_DA'
!               path_obs_seq_loc=trim(path_acd)//'/'//trim(cycle(icycle))//'/'//'obs_MOPITT_Mig_DA_bloc'
!               path_obs_seq=trim(path_acd)//'/'//'obs_MOPITT_Mig_DA'
!               path_obs_seq_loc=trim(path_acd)//'/'//'obs_MOPITT_Mig_DA_bloc'
!
!               path_obs_seq=trim(path_acd)//'/'//'obs_MOPITT_Mig_DA_DBL'
!               path_obs_seq_loc=trim(path_scratch)//'/'//'obs_MOPITT_Mig_DA_DBL_bloc'
!
!               path_obs_seq=trim(path_acd)//'/'//'obs_MOPITT_Mig_DA_no_rot1'
!               path_obs_seq_loc=trim(path_scratch)//'/'//'obs_MOPITT_Mig_DA_no_rot1_bloc'
!
!               path_obs_seq=trim(path_acd)//'/'//'obs_MOPITT_Mig_DA_Rev'
!               path_obs_seq_loc=trim(path_scratch)//'/'//'obs_MOPITT_Mig_DA_Rev_bloc'
!
!               path_obs_seq=trim(path_acd)//'/'//'obs_IASI_CO_DnN_Mig_DA'
!               path_obs_seq_loc=trim(path_scratch)//'/'//'obs_IASI_CO_DnN_Mig_DA_bloc'
!
               path_obs_seq=trim(path_acd)//'/'//'obs_IASI_CO_DnN_Mig_DA_DBL'
               path_obs_seq_loc=trim(path_scratch)//'/'//'obs_IASI_CO_DnN_Mig_DA_DBL_bloc'
!
               file='obs_seq_iasi_'//trim(sp_cycle(icycle))
!               file='obs_seq_iasi_'//trim(cycle(icycle))
               file_in=trim(path_obs_seq)//'/'//trim(file)
               file_out=trim(path_obs_seq_loc)//'/'//trim(file)
!
! open obs_seq file for reading
               iunit_in=101
               print *, trim(file_in)
               open(unit=iunit_in,form='formatted',file=file_in,status='unknown') 
!
! open obs_seq file for writing
               iunit_out=102
               print *, trim(file_out)
               open(unit=iunit_out,form='formatted',file=file_out,status='unknown') 
!
! begin code to read and write obs_seq.out files
! assign obs_kind definitions
!               obs_kind(1) = 'RADIOSONDE_U_WIND_COMPONENT'
!               obs_kind(2) = 'RADIOSONDE_V_WIND_COMPONENT'
!               obs_kind(3) = 'RADIOSONDE_TEMPERATURE'
!               obs_kind(4) = 'RADIOSONDE_SPECIFIC_HUMIDITY'
!               obs_kind(5) = 'AIRCRAFT_U_WIND_COMPONENT'
!               obs_kind(6) = 'AIRCRAFT_V_WIND_COMPONENT'
!               obs_kind(7) = 'AIRCRAFT_TEMPERATURE'
!               obs_kind(8) = 'ACARS_U_WIND_COMPONENT'
!               obs_kind(9) = 'ACARS_V_WIND_COMPONENT'
!               obs_kind(10) = 'ACARS_TEMPERATURE'
!               obs_kind(11) = 'MARINE_SFC_U_WIND_COMPONENT'
!               obs_kind(12) = 'MARINE_SFC_V_WIND_COMPONENT'
!               obs_kind(13) = 'MARINE_SFC_TEMPERATURE'
!               obs_kind(14) = 'MARINE_SFC_SPECIFIC_HUMIDITY'
!               obs_kind(15) = 'LAND_SFC_U_WIND_COMPONENT'
!               obs_kind(16) = 'LAND_SFC_V_WIND_COMPONENT'
!               obs_kind(17) = 'LAND_SFC_TEMPERATURE'
!               obs_kind(18) = 'LAND_SFC_SPECIFIC_HUMIDITY'
!               obs_kind(19) = 'SAT_U_WIND_COMPONENT'
!               obs_kind(20) = 'SAT_V_WIND_COMPONENT'
!               obs_kind(21) = 'RADIOSONDE_SURFACE_ALTIMETER'
!               obs_kind(22) = 'MARINE_SFC_ALTIMETER'
!               obs_kind(23) = 'LAND_SFC_ALTIMETER'
!               obs_kind(24) = 'MOPITT_CO_RETRIEVAL'
               obs_kind(1) = 'IASI_CO_RETRIEVAL'
!
! assign obs_kind_ids
!               obs_kind_id(1)=1
!               obs_kind_id(2)=2
!               obs_kind_id(3)=5
!               obs_kind_id(4)=6
!               obs_kind_id(5)=12
!               obs_kind_id(6)=13
!               obs_kind_id(7)=14
!               obs_kind_id(8)=16
!               obs_kind_id(9)=17
!               obs_kind_id(10)=18
!               obs_kind_id(11)=20
!               obs_kind_id(12)=21
!               obs_kind_id(13)=22
!               obs_kind_id(14)=23
!               obs_kind_id(15)=25
!               obs_kind_id(16)=26
!               obs_kind_id(17)=27
!               obs_kind_id(18)=28
!               obs_kind_id(19)=30
!               obs_kind_id(20)=31
!               obs_kind_id(21)=70
!               obs_kind_id(22)=72
!               obs_kind_id(23)=73
!               obs_kind_id(24)=117
               obs_kind_id(1)=1
!
! read/write record 1
               read(iunit_in,*) file_type
               write(iunit_out,'(1x,a12)') trim(file_type)
!               print *, trim(file_type)
!
! read/write record 2
               read(iunit_in,*) obs_kind_defn
               write(iunit_out,'(a20)') trim(obs_kind_defn)
!               print *, trim(obs_kind_defn)
!
! read/write record 3
               read(iunit_in,*) mobs_kind
               write(iunit_out,*) mobs_kind
!               print *, mobs_kind
               if(mobs_kind .gt. nobs_kind) then
                  print *, 'ERROR: FILE HAS MORE OBS_KIND THAN PROGRAM'
                  call abort
               endif
!
! read/write type of obs_kinds in file
               do mrec=1,mobs_kind
                  read(iunit_in,*) kind_id,kind_defn
                  write(iunit_out,*) kind_id,trim(kind_defn)
!                  print *, kind_id,trim(kind_defn)
                  do nrec=1,nobs_kind
                     if((trim(obs_kind(nrec)) .eq. trim(kind_defn)) .and. &
                        (obs_kind_id(nrec) .eq. kind_id)) then
                        exit
                     else if (nrec .eq. nobs_kind) then
                        print *, 'ERROR: OBS_KIND FROM INPUT FILE NOT FOUND IN PROGRAM'
                        call abort
                     endif
                  enddo
               enddo
!
! read/write num_copies and num_qc
               read(iunit_in,*) chr_num_copies,num_copies,chr_num_qc,num_qc
               write(iunit_out,'(2x,a11,i13,2x,a7,i13)') trim(chr_num_copies),num_copies,trim(chr_num_qc),num_qc
!               print *, trim(chr_num_copies),num_copies,trim(chr_num_qc),num_qc
!
! read/write num_obs and max_num_obs
               read(iunit_in,*) chr_num_obs,num_obs,chr_max_num_obs,max_num_obs
               write(iunit_out,'(2x,a8,i13,2x,a12,i13)') trim(chr_num_obs),num_obs,trim(chr_max_num_obs),max_num_obs
!               print *, trim(chr_num_obs),num_obs,trim(chr_max_num_obs),max_num_obs
!
! read/write num_copies of meta data
               do mrec=1,num_copies
                  read(iunit_in,'(a)') meta_data
                  write(iunit_out,'(a)') trim(meta_data)
!                  print *, trim(meta_data)
               enddo
               do mrec=1,num_qc
                  read(iunit_in,'(a)') meta_data
                  write(iunit_out,'(a)') trim(meta_data)
!                  print *, trim(meta_data)
               enddo
!
! read/write first and last
               read(iunit_in,*) chr_first_obs,first_obs,chr_last_obs,last_obs
               write(iunit_out,'(2x,a,i13,2x,a,i13)') trim(chr_first_obs),first_obs,trim(chr_last_obs),last_obs
!               print *, trim(chr_first_obs),first_obs,trim(chr_last_obs),last_obs
!
!              print *, num_obs
               num_obs=last_obs
               do mrec=1,num_obs
!                  print *, 'mrec ',mrec,num_obs
                  read(iunit_in,*) chr_obs,obs_rec
                  write(iunit_out,'(1x,a,i13)') trim(chr_obs),obs_rec
!                  print *, 'APM: ',trim(chr_obs),obs_rec
!
! read data
                  read(iunit_in,*), obs_val
                  write(iunit_out,*), obs_val
!                  print *, obs_val
                  read(iunit_in,*), dart_qc  
                  write(iunit_out,*), dart_qc  
!                  print *, dart_qc
!
! skip record
                  read(iunit_in,*) point(:)
                  write(iunit_out,*) point(:)
!                  print *, point(:)
!
! read/write chr_obdef
                  read(iunit_in,*) chr_obdef
                  write(iunit_out,'(a)') trim(chr_obdef)
!                  print *, trim(chr_obdef)
!
! read/write chr_locxd
                  read(iunit_in,*) chr_locxd
                  write(iunit_out,'(a)') trim(chr_locxd)
!                  print *, trim(chr_locxd)
!           
                  select case (trim(chr_locxd))
                     case('loc2d')
                        read(iunit_in,*),x,y
!                        write(iunit_out,*),x,y
!                        print *, x,y
                     case('loc3d')
                         read(iunit_in,*),x,y,z,z_id
!                         write(iunit_out,*),x,y,z,z_id
!                         print *,x,y,z,z_id
                  end select
!
! read/write chr_kind
                  read(iunit_in,*) chr_kind
!                  write(iunit_out,*) trim(chr_kind)
!                  print *, trim(chr_kind)
                  read(iunit_in,*) kind_id
!                  write(iunit_out,*) kind_id
!                  print *, kind_id
!
! find obs_kind and store data
                  do nid=1,nobs_kind
                     if(obs_kind_id(nid) .eq. kind_id) then
!                        print *, nid,obs_kind_id(nid)
!                        print *, trim(obs_kind(nid))
                        select case (trim(obs_kind(nid)))
                           case('IASI_CO_RETRIEVAL')
!
! read/write number of MOPITT levels
                              read(iunit_in,*) mopitt_npr
                              mopitt_nprp=mopitt_npr+1
!                              write(iunit_out,*) mopitt_npr
!                              print *, mopitt_npr
!
! read/write MOPITT meta data
                              read(iunit_in,*) mopitt_prior
!                              write(iunit_out,*) mopitt_prior
!                              print *, mopitt_prior
                              read(iunit_in,*) mopitt_psfc
!                              write(iunit_out,*) mopitt_psfc
!                              print *, mopitt_psfc
                              read(iunit_in,*) mopitt_avgker(1:mopitt_npr)
!                              write(iunit_out,*) mopitt_avgker(1:mopitt_npr)
!                              print *, mopitt_avgker(1:mopitt_npr)
                              read(iunit_in,*) mopitt_pressure(1:mopitt_nprp)
!                              write(iunit_out,*) mopitt_pressure(1:mopitt_nprp)
!                              print *, mopitt_pressure(1:mopitt_nprp)
                              do k=1,mopitt_npr
                                 mopitt_pressure_mid(k)=(mopitt_pressure(k)+mopitt_pressure(k+1))/2.
                              enddo
!
!=====================================
! Calculate weighted pressure average +++
!=====================================
                              select case (trim(chr_locxd))
                              case('loc2d')
                                 write(iunit_out,*),x,y
!                                print *, x,y
                              case('loc3d')
                                 kstr=mopitt_nlev-mopitt_npr+1
                                 avg=0.
                                 twt=0.
                                 do k=kstr,mopitt_nlev
                                    prs=mopitt_pressure_mid(k)
                                    if(k.eq.kstr) prs=mopitt_psfc
                                    avg=avg+prs*abs(mopitt_avgker(k))
                                    twt=twt+abs(mopitt_avgker(k))
                                 enddo
                                 avg=avg/twt
                                 write(iunit_out,'(3(g25.15,1x),i2)'),x,y,avg,z_id
!                                 print *, 'prs, prs_loc ',z,avg                             
!                                 print *,x,y,avg,z_id
                              end select
!
! write other records
                              write(iunit_out,'(a)') trim(chr_kind)
!                              print *, trim(chr_kind)
                              write(iunit_out,*) kind_id
!                              print *, kind_id
                              write(iunit_out,*) mopitt_npr
!                              print *, mopitt_npr
                              write(iunit_out,*) mopitt_prior
!                              print *, mopitt_prior
                              write(iunit_out,*) mopitt_psfc
!                              print *, mopitt_psfc
                              write(iunit_out,*) mopitt_avgker(1:mopitt_npr)
!                              print *, mopitt_avgker(1:mopitt_npr)
                              write(iunit_out,*) mopitt_pressure(1:mopitt_nprp)
!                              print *, mopitt_pressure(1:mopitt_nprp)
!=====================================
! Calculate weighted pressure average ---
!=====================================
!
! read mopitt record number
                              read(iunit_in,*) rec_num
                              write(iunit_out,*) rec_num
! read time data
!                              read(iunit_in,*) obs_sec,obs_day
!                              write(iunit_out,) obs_sec,obs_day
                              read(iunit_in,'(a150)') time
                              write(iunit_out,'(a)') trim(time)
! read observation error variance
                              read(iunit_in,*) err_var
                              write(iunit_out,*) err_var
!                              if(err_var .ne. 1.) then
!                                 print *,'APM:ERROR VARIANCE PROBLEM ',err_var
!                                 call abort
!                              endif
                              exit
!                       
                           case('RADIOSONDE_U_WIND_COMPONENT', &
                                'RADIOSONDE_V_WIND_COMPONENT', &
                                'RADIOSONDE_TEMPERATURE', &
                                'RADIOSONDE_SPECIFIC_HUMIDITY', &
                                'AIRCRAFT_U_WIND_COMPONENT', &
                                'AIRCRAFT_V_WIND_COMPONENT', &
                                'AIRCRAFT_TEMPERATURE', &
                                'MARINE_SFC_U_WIND_COMPONENT', &
                                'MARINE_SFC_V_WIND_COMPONENT', &
                                'MARINE_SFC_TEMPERATURE', &
                                'MARINE_SFC_SPECIFIC_HUMIDITY', &
                                'LAND_SFC_U_WIND_COMPONENT', &
                                'LAND_SFC_V_WIND_COMPONENT', &
                                'LAND_SFC_TEMPERATURE', &
                                'LAND_SFC_SPECIFIC_HUMIDITY', &
                                'RADIOSONDE_SURFACE_ALTIMETER', &
                                'MARINE_SFC_ALTIMETER', &
                                'LAND_SFC_ALTIMETER', &
                                'SAT_U_WIND_COMPONENT', &
                                'SAT_V_WIND_COMPONENT', &
                                'ACARS_U_WIND_COMPONENT', &
                                'ACARS_V_WIND_COMPONENT', &
                                'ACARS_TEMPERATURE')
! read time data 
                              read(iunit_in,*) obs_sec,obs_day
                              write(iunit_out,*) obs_sec,obs_day
! read obervation error variance 
                              read(iunit_in,*) err_var
                              write(iunit_out,*) err_var
                              exit
                        end select
                     else if(nid .eq. nobs_kind) then
                        print *, 'ERROR: OBS_KIND_ID NOT FOUND FOR STORAGE ',trim(obs_kind(nid))
                        call abort
                     endif
                  enddo ! obs_kind loop
               enddo ! num_obs loop
            enddo ! mcycle loop
!
! close graphics
!            call gdawk(iwk)
!            call gclwk(iwk)
!            call gclks
         end program main
