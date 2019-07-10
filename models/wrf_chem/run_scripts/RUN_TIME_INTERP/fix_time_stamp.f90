!
! code to fix time stamp on netcdf file
!
! ifort -C fix_time_stamp.f90 -o fix_time_stamp.exe -I$NETCDF_DIR/include -L$NETCDF_DIR/lib -lnetcdff -lnetcdf
!
          program main
             implicit none
             integer,parameter                        :: strdim=19
             integer                                  :: i,unit,num_dates,file_sw
             character(len=19),dimension(strdim)      :: time_str,time_this_str,time_next_str
             character(len=19),dimension(strdim)      :: time_wrf
             character(len=120)                       :: file_str
             character(len=19)                        :: time_str1,time_str2,time_str3,time_str4, &
             time_str5,time_str6,time_str7,time_str8
             character(len=19)                        :: time_this_str1,time_this_str2,time_this_str3, &
             time_this_str4,time_this_str5,time_this_str6,time_this_str7,time_this_str8
             character(len=19)                        :: time_next_str1,time_next_str2,time_next_str3, &
             time_next_str4,time_next_str5,time_next_str6,time_next_str7,time_next_str8
             character(len=120)                       :: v_nam
             namelist /time_stamp_nml/time_str1,time_str2,time_str3,time_str4, &
             time_str5,time_str6,time_str7,time_str8, &
             time_this_str1,time_this_str2,time_this_str3,time_this_str4, &
             time_this_str5,time_this_str6,time_this_str7,time_this_str8, &
             time_next_str1,time_next_str2,time_next_str3,time_next_str4, &
             time_next_str5,time_next_str6,time_next_str7,time_next_str8, &
             file_str,file_sw,num_dates
!
! Read namelist
             time_str1=' '
             time_str2=' '
             time_str3=' '
             time_str4=' '
             time_str5=' '
             time_str6=' '
             time_str7=' '
             time_str8=' '
             time_this_str1=' '
             time_this_str2=' '
             time_this_str3=' '
             time_this_str4=' '
             time_this_str5=' '
             time_this_str6=' '
             time_this_str7=' '
             time_this_str8=' '
             time_next_str1=' '
             time_next_str2=' '
             time_next_str3=' '
             time_next_str4=' '
             time_next_str5=' '
             time_next_str6=' '
             time_next_str7=' '
             time_next_str8=' '
             unit=20
             open(unit=unit,file='time_stamp_nml.nl',form='formatted', &
             status='old',action='read')
             read(unit,time_stamp_nml)
             close(unit)
             time_str(1)=trim(time_str1)
             time_str(2)=trim(time_str2)
             time_str(3)=trim(time_str3)
             time_str(4)=trim(time_str4)
             time_str(5)=trim(time_str5)
             time_str(6)=trim(time_str6)
             time_str(7)=trim(time_str7)
             time_str(8)=trim(time_str8)
             time_this_str(1)=trim(time_this_str1)
             time_this_str(2)=trim(time_this_str2)
             time_this_str(3)=trim(time_this_str3)
             time_this_str(4)=trim(time_this_str4)
             time_this_str(5)=trim(time_this_str5)
             time_this_str(6)=trim(time_this_str6)
             time_this_str(7)=trim(time_this_str7)
             time_this_str(8)=trim(time_this_str8)
             time_next_str(1)=trim(time_next_str1)
             time_next_str(2)=trim(time_next_str2)
             time_next_str(3)=trim(time_next_str3)
             time_next_str(4)=trim(time_next_str4)
             time_next_str(5)=trim(time_next_str5)
             time_next_str(6)=trim(time_next_str6)
             time_next_str(7)=trim(time_next_str7)
             time_next_str(8)=trim(time_next_str8)
!
!             print *, 'Times ',(trim(time_str(i)),' ',i=1,num_dates)
!             print *, 'Time_this ',(trim(time_this_str(i)),' ',i=1,num_dates)
!             print *, 'Time_next ',(trim(time_next_str(i)),' ',i=1,num_dates)
!             print *, 'file ',trim(file_str)
!             print *, 'file_sw ',file_sw
!             print *, 'num_dates ',num_dates
             if(file_sw.ne.0.and.file_sw.ne.1) then
                print *, 'APM: ERROR - file_sw != 1 or 0 '
                stop
             endif
!
             if(file_sw.eq.0) then
                call get_WRFCHEM_data(trim(file_str),'Times',time_wrf)
                time_wrf(1)=trim(time_str(1))
                call put_WRFCHEM_data(trim(file_str),'Times',time_wrf)
             elseif(file_sw.eq.1) then
                call get_WRFCHEM_data(trim(file_str),'Times',time_wrf)
                do i=1,num_dates
                   time_wrf(i)=trim(time_str(i))
                enddo 
                call put_WRFCHEM_data(trim(file_str),'Times',time_wrf)
!                print *, 'Completed first fix '
!
                call get_WRFCHEM_data(trim(file_str),'md___thisbdytimee_x_t_d_o_m_a_i_n_m_e_t_a_data_',time_wrf)
                do i=1,num_dates
                   time_wrf(i)=trim(time_this_str(i))
                enddo
                call put_WRFCHEM_data(trim(file_str),'md___thisbdytimee_x_t_d_o_m_a_i_n_m_e_t_a_data_',time_wrf)
!                print *, 'Completed second fix '
!
                call get_WRFCHEM_data(trim(file_str),'md___nextbdytimee_x_t_d_o_m_a_i_n_m_e_t_a_data_',time_wrf)
                do i=1,num_dates
                   time_wrf(i)=trim(time_next_str(i))
                enddo
                call put_WRFCHEM_data(trim(file_str),'md___nextbdytimee_x_t_d_o_m_a_i_n_m_e_t_a_data_',time_wrf)
!                print *, 'Completed third fix '
            endif  
          end program main
!
          subroutine get_WRFCHEM_data(file,name,data)
             implicit none
             include 'netcdf.inc'
             integer, parameter                    :: maxdim=6,strdim=19
             integer                               :: i,rc
             integer                               :: f_id
             integer                               :: v_id,v_ndim,typ,natts
             integer,dimension(maxdim)             :: one
             integer,dimension(maxdim)             :: v_dimid
             integer,dimension(maxdim)             :: v_dim
             character*(*)                         :: name
             character*(*)                         :: file
             character*(*),dimension(strdim)       :: data
             character(len=150)                    :: v_nam
!
! open netcdf file
             rc = nf_open(trim(file),NF_NOWRITE,f_id)
!             print *, trim(file)
             if(rc.ne.0) then
                print *, 'nf_open error ',trim(file)
                call abort
             endif
!
! get variables identifiers
             rc = nf_inq_varid(f_id,trim(name),v_id)
!             print *, v_id
             if(rc.ne.0) then
                print *, 'nf_inq_varid error ', v_id
                call abort
             endif
!
! get dimension identifiers
             v_dimid=0
             rc = nf_inq_var(f_id,v_id,v_nam,typ,v_ndim,v_dimid,natts)
!             print *, v_dimid
             if(rc.ne.0) then
                print *, 'nf_inq_var error ', v_dimid
                call abort
             endif
!
! get dimensions
             v_dim(:)=1
             do i=1,v_ndim
                rc = nf_inq_dimlen(f_id,v_dimid(i),v_dim(i))
             enddo
!             print *, v_dim
             if(rc.ne.0) then
                print *, 'nf_inq_dimlen error ', v_dim
                call abort
             endif
!
! check dimensions
             if(strdim.ne.v_dim(1)) then
                print *, 'ERROR: dimension conflict ',v_dim(1)
                call abort
             endif
!
! get data
             one(:)=1
             rc = nf_get_vara_text(f_id,v_id,one,v_dim,data)
             if(rc.ne.0) then
!                print *, 'nf_get_vara_real ', data(1,1,1)
                call abort
             endif
             rc = nf_close(f_id)
             return
          end subroutine get_WRFCHEM_data   
!
          subroutine put_WRFCHEM_data(file,name,data)
             implicit none
             include 'netcdf.inc'
             integer, parameter                    :: maxdim=6,strdim=19
             integer                               :: i,rc
             integer                               :: f_id
             integer                               :: v_id,v_ndim,typ,natts
             integer,dimension(maxdim)             :: one
             integer,dimension(maxdim)             :: v_dimid
             integer,dimension(maxdim)             :: v_dim
             character*(*)                         :: name
             character*(*)                         :: file
             character*(*),dimension(strdim)       :: data
             character(len=150)                    :: v_nam
!
! open netcdf file
             rc = nf_open(trim(file),NF_WRITE,f_id)
             if(rc.ne.0) then
                print *, 'nf_open error ',trim(file)
                call abort
             endif
!
! get variables identifiers
             rc = nf_inq_varid(f_id,trim(name),v_id)
!             print *, v_id
             if(rc.ne.0) then
                print *, 'nf_inq_varid error ', v_id
                call abort
             endif
!
! get dimension identifiers
             v_dimid=0
             rc = nf_inq_var(f_id,v_id,v_nam,typ,v_ndim,v_dimid,natts)
!             print *, v_dimid
             if(rc.ne.0) then
                print *, 'nf_inq_var error ', v_dimid
                call abort
             endif
!
! get dimensions
             v_dim(:)=1
             do i=1,v_ndim
                rc = nf_inq_dimlen(f_id,v_dimid(i),v_dim(i))
             enddo
!             print *, v_dim
             if(rc.ne.0) then
                print *, 'nf_inq_dimlen error ', v_dim
                call abort
             endif
!
! check dimensions
             if(strdim.ne.v_dim(1)) then
                print *, 'ERROR: dimension conflict ',v_dim(1)
                call abort
             endif
!
! put data
             one(:)=1
             rc = nf_put_vara_text(f_id,v_id,one,v_dim,data)
             if(rc.ne.0) then
!                print *, 'nf_put_vara_real ', data(1,1,1)
                call abort
             endif
             rc = nf_close(f_id)
             return
          end subroutine put_WRFCHEM_data   
