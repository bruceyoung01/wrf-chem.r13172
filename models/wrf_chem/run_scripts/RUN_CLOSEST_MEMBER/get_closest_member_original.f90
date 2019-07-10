!
! Code to find closest ensemble member base on RMSE or "Deepest Member"
!
      program main
         implicit none
         integer,parameter                               :: nx=100,ny=40,nz=33
         integer,parameter                               :: num_mem=20
         integer                                         :: imem,close_mem_ind
         integer,dimension(num_mem)                      :: index_sort
         character(len=30)                               :: imem_char
         character(len=180)                              :: path_acd, path_scratch, path_data, path_exp
         character(len=180)                              :: file, file_in, file_name, path_ens_prior
         character(len=180)                              :: path_time_dir
         real,dimension(num_mem)                         :: rmse_vec, rmse_sort
         real,dimension(nx,ny,nz)                        :: ens_mn_co, ens_vr_co
         real,dimension(nx,ny,nz,num_mem)                :: co_post
!
         path_acd='/glade/p/acd/mizzi'
         path_scratch='/glade/scratch/mizzi'
         path_data=trim(path_scratch)
         path_exp='/XXXnIAS_Exp_2_MgDA_20M_100km_COnXX_RAWR_F50_CPSR_SCALE_SUPR'
         path_time_dir='/2014071406/wrfchem_cycle'
         path_ens_prior=trim(path_scratch)//trim(path_exp)//trim(path_time_dir)
!
         ens_mn_co(:,:,:)=0.
         ens_vr_co(:,:,:)=0.
!
! read analyses 
         do imem=1,num_mem
            write(imem_char,'(i4)') imem
            if(imem.lt.1000) write(imem_char,'(a1,i3)') '0',imem
            if(imem.lt.100) write(imem_char,'(a2,i2)') '00',imem
            if(imem.lt.10) write(imem_char,'(a3,i1)') '000',imem
            file='/convert_file_'//trim(imem_char)//'/wrfinput_d01'
            file_in=trim(path_ens_prior)//trim(file)
            call get_DART_diag_data(file_in,'co',co_post(1,1,1,imem),nx,ny,nz,1)
         enddo
!
! get ensemble mean
         call get_ens_stats(co_post,nx,ny,nz,num_mem,ens_mn_co,ens_vr_co)
!
! get spatial RMSE about ensemble mean
         call get_rmse(co_post,ens_mn_co,nx,ny,nz,num_mem,rmse_vec)
!
! rank RNSE vector
         call get_rank(rmse_vec,num_mem,rmse_sort,index_sort)
         close_mem_ind=index_sort(1)
!
! write closest member file
         do imem=1,num_mem
            if(close_mem_ind.eq.imem) then
               write(imem_char,'(i4)') imem
               if(imem.lt.1000) write(imem_char,'(a1,i3)') '0',imem
               if(imem.lt.100) write(imem_char,'(a2,i2)') '00',imem
               if(imem.lt.10) write(imem_char,'(a3,i1)') '000',imem
               file_name='/CLOSEST_MEMBER_'//trim(imem_char)
               open(unit=120,file=trim(file_name),form='FORMATTED',status='UNKNOWN')
               write(120,('(i4)')),imem
               close(120)
               exit
            endif
         enddo
         print *, 'APM ERROR: Closest member not found'
         call abort
      end program main 
!
      subroutine get_DART_diag_data(file_in,name,data,nx,ny,nz,nc)
         use netcdf
         implicit none
         integer, parameter                    :: maxdim=6
         integer                               :: i,icycle,rc,fid,typ,natts
         integer                               :: v_id
         integer                               :: v_ndim
         integer                               :: nx,ny,nz,nc
         integer,dimension(maxdim)             :: one
         integer,dimension(maxdim)             :: v_dimid
         integer,dimension(maxdim)             :: v_dim
         character(len=180)                    :: vnam
         character*(*)                         :: name
         character*(*)                         :: file_in
!
         real,dimension(nx,ny,nz,nc)           :: data
!
! open netcdf file
         rc = nf90_open(trim(file_in),NF90_NOWRITE,fid)
         if(rc.ne.nf90_noerr) call handle_err(rc,'nf90_open')
!
! get variables identifiers
         rc = nf90_inq_varid(fid,trim(name),v_id)
         if(rc.ne.nf90_noerr) call handle_err(rc,'nf90_inq_varid')
!
! get dimension identifiers
         v_dimid(:)=0
         rc = nf90_inquire_variable(fid,v_id,vnam,typ,v_ndim,v_dimid,natts)
         if(rc.ne.nf90_noerr) call handle_err(rc,'nf90_inquire_variable')
         if(maxdim.lt.v_ndim) then
            print *, 'ERROR: maxdim is too small ',maxdim,v_ndim
            call abort
         endif            
!
! get dimensions
         v_dim(:)=1
         do i=1,v_ndim
            rc = nf90_inquire_dimension(fid,v_dimid(i),len = v_dim(i))
         if(rc.ne.nf90_noerr) call handle_err(rc,'nf90_inquire_dimension')
         enddo
!
! check dimensions
         if(nx.ne.v_dim(1)) then
            print *, 'ERROR: nx dimension conflict ',nx,v_dim(1)
            call abort
         else if(ny.ne.v_dim(2)) then             
            print *, 'ERROR: ny dimension conflict ',ny,v_dim(2)
            call abort
         else if(nz.ne.v_dim(3)) then             
            print *, 'ERROR: nz dimension conflict ',nz,v_dim(3)
            call abort
         else if(nc.ne.v_dim(4)) then             
            print *, 'ERROR: nc dimension conflict ',nc,v_dim(4)
            call abort
         endif
!
! get data
         one(:)=1
         rc = nf90_get_var(fid,v_id,data,one,v_dim)
         if(rc.ne.nf90_noerr) call handle_err(rc,'nf90_get_var')
         rc = nf90_close(fid)
         if(rc.ne.nf90_noerr) call handle_err(rc,'nf90_close')
         return
      end subroutine get_DART_diag_data
!
      subroutine handle_err(rc,text)
         implicit none
         integer         :: rc
         character*(*)   :: text
         print *, 'APM: NETCDF ERROR ',trim(text),' ',rc
         call abort
      end subroutine handle_err
!
      subroutine get_ens_stats(fld,nx,ny,nz,nm,ens_mn,ens_vr)
         implicit none
         integer       :: nx,ny,nz,nm
         integer       :: i,j,k,m
         real          :: fld(nx,ny,nz,nm)
         real          :: ens_mn(nx,ny,nz),ens_vr(nx,ny,nz)
!
! set variables
         ens_mn(:,:,:)=0.0
         ens_vr(:,:,:)=0.0
!
! calculate ensemble mean
         do i=1,nx
            do j=1,ny
               do k=1,nz
                  do m=1,nm
                     ens_mn(i,j,k)=ens_mn(i,j,k)+fld(i,j,k,m)/real(nm)
                  enddo
               enddo
            enddo
         enddo
!
! calculate ensemble variance    
         do i=1,nx
            do j=1,ny
               do k=1,nz
                  do m=1,nm
                     ens_vr(i,j,k)=ens_vr(i,j,k)+(fld(i,j,k,m)-ens_mn(i,j,k))* &
                     (fld(i,j,k,m)-ens_mn(i,j,k))/real(nm-1)
                  enddo
               enddo
            enddo
         enddo
         return
      end subroutine get_ens_stats
!
      subroutine get_rmse(fld,fld_mn,nx,ny,nz,nm,rmse)
         implicit none
         integer       :: nx,ny,nz,nm
         integer       :: i,j,k,m
         real          :: fld_mn(nx,ny,nz)
         real          :: fld(nx,ny,nz,nm)
         real          :: rmse(nm)
!
! set variables
         rmse(:)=0.
!
! calculate spatial RMSE for each member
         do m=1,nm
            do i=1,nx
               do j=1,ny
                  do k=1,nz
                     rmse(m)=rmse(m)+(fld(i,j,k,m)-fld_mn(i,j,k))**2
                  enddo
               enddo
            enddo
            rmse(m)=sqrt(rmse(m)/real(nx*ny*nz))
         enddo 
      end subroutine get_rmse
!
      subroutine get_rank(fld,nm,fld_sort,idx_sort)
         implicit none
         integer       :: nm
         integer       :: i,ii,j
         integer       :: idx(nm),idx_tmp(nm),idx_sort(nm)
         real          :: fld(nm),fld_tmp(nm),fld_sort(nm)
!
         fld_sort(1)=fld(1)
         idx_sort(1)=1
         do i=2,nm
            do ii=1,nm-1
               if(fld(i).ge.fld_sort(1) .and. ii.eq.1) then
                  do j=1,i-1
                     fld_tmp(j)=fld_sort(j)
                     idx_tmp(j)=idx_sort(j)
                  enddo
                  fld_sort(1)=fld(i)
                  idx_sort(1)=i
                  do j=2,i
                     fld_sort(j)=fld_tmp(j-1)
                     idx_sort(j)=idx_tmp(j-1)
                  enddo
                  exit
               else if(fld(i).lt.fld_sort(i) .and. ii.eq.nm-1) then
                  fld_sort(nm)=fld(i)
                  idx_sort(nm)=i
                  exit
               else if(fld(i).lt.fld_sort(ii) .and. fld(i).ge.fld_sort(ii+1)) then
                  do j=ii+1,i-1
                     fld_tmp(j)=fld_sort(j)
                     idx_tmp(j)=idx_sort(j)
                  enddo
                  fld_sort(ii+1)=fld(i)
                  idx_sort(ii+1)=i
                  do j=ii+2,i   
                     fld_sort(j)=fld_tmp(j-1)
                     idx_sort(j)=idx_tmp(j-1)
                  enddo
                  exit
               endif
            enddo
         enddo
      end subroutine get_rank
            
