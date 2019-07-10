!
! code to post-dart clamping of chemistry fields
! need:
!   wrfinput           :: get the land-ocean mask
!   wrfinput_d01_xxxx  :: the ensemble members (assumes dart_to_wrf has already been called)
!
! ifort -C post_dart_clamping.f90 -o post_dart_clamping.exe -lgfortran -lnetcdff -lnetcdf
!
         program main
            implicit none
            integer,parameter                        :: nx=100
            integer,parameter                        :: ny=40
            integer,parameter                        :: nz=33
            integer,parameter                        :: num_mem=20
            integer                                  :: i,j,k,imem,icnt,jcnt
            real                                     :: co_thresh,fac1,fac2,co_min
            real,dimension(nz)                       :: co_mean_ocn_prf,prs_mean_ocn_prf          
            real,dimension(nz)                       :: co_mean_lnd_prf,prs_mean_lnd_prf          
            real,dimension(nx,ny)                    :: xland          
            real,dimension(nx,ny,nz)                 :: co_mean,prs_mean
            real,dimension(nx,ny,nz)                 :: p_prt,p_bas
            real,dimension(nx,ny,nz,num_mem)         :: co_prior,co_post,prs_prior,prs_post
            real,dimension(nx,ny,num_mem)            :: psfc_prior,psfc_post
            character(len=80)                        :: imem_char,file,file_in
!
! CO threshold (ppmv)
            fac1=0.6
!
! Assign ocean min values (ppmv)
!            min_ocn(1:nz)= .050
!
! Assign land min values (ppmv)
!            min_lan(1:nz)=.100
!
! get wrf land mask
            call get_WRFINPUT_land_mask(xland,nx,ny)
!
! read prior data
            do imem=1,num_mem
               write(imem_char,'(i4)') imem
               if(imem.lt.1000) write(imem_char,'(a1,i3)') '0',imem
               if(imem.lt.100) write(imem_char,'(a2,i2)') '00',imem 
               if(imem.lt.10) write(imem_char,'(a3,i1)') '000',imem
               file='pr_wrfinput_d01_'//trim(imem_char)
               file_in=trim(file)
!               print *,'mem ',imem,file_in
               call get_DART_diag_data(file_in,'co',co_prior(1,1,1,imem),nx,ny,nz,1)
!                print *, imem,co_prior(1,1,1,imem),co_prior(nx,ny,nz,imem)
               call get_DART_diag_data(file_in,'P',p_prt,nx,ny,nz,1)
               call get_DART_diag_data(file_in,'PB',p_bas,nx,ny,nz,1)
               call get_DART_diag_data(file_in,'PSFC',psfc_prior(1,1,imem),nx,ny,1,1)
               prs_prior(:,:,:,imem)=p_bas(:,:,:)+p_prt(:,:,:)
            enddo
!
! read post data
            do imem=1,num_mem
               write(imem_char,'(i4)') imem
               if(imem.lt.1000) write(imem_char,'(a1,i3)') '0',imem
               if(imem.lt.100) write(imem_char,'(a2,i2)') '00',imem
               if(imem.lt.10) write(imem_char,'(a3,i1)') '000',imem
               file='po_wrfinput_d01_'//trim(imem_char)
               file_in=trim(file)
               call get_DART_diag_data(file_in,'co',co_post(1,1,1,imem),nx,ny,nz,1)
!                print *, imem,co_post(1,1,1,imem),co_post(nx,ny,nz,imem)
               call get_DART_diag_data(file_in,'P',p_prt,nx,ny,nz,1)
               call get_DART_diag_data(file_in,'PB',p_bas,nx,ny,nz,1)
               call get_DART_diag_data(file_in,'PSFC',psfc_post(1,1,imem),nx,ny,1,1)
               prs_post(:,:,:,imem)=p_bas(:,:,:)+p_prt(:,:,:)
            enddo
!            print *, ' '
!            print *, co_post(89,1,1,1),co_post(90,1,1,1),co_post(91,1,1,1)
!            print *, co_post(89,2,1,1),co_post(90,2,1,1),co_post(91,2,1,1)
!            print *, co_post(89,3,1,1),co_post(90,3,1,1),co_post(91,3,1,1)
!
! calculate the prior ensemble mean
            co_mean(:,:,:)=0.
            prs_mean(:,:,:)=0.
            do i=1,nx
               do j=1,ny
                  do k=1,nz
                     do imem=1,num_mem
                        co_mean(i,j,k)=co_mean(i,j,k)+co_post(i,j,k,imem)/real(num_mem)
                        prs_mean(i,j,k)=prs_mean(i,j,k)+prs_post(i,j,k,imem)/real(num_mem)
                     enddo
                  enddo
               enddo
            enddo
!
! calculate the prior ensemble mean profile over land and ocean
            co_mean_ocn_prf(:)=0.
            prs_mean_ocn_prf(:)=0.
            co_mean_lnd_prf(:)=0.
            prs_mean_lnd_prf(:)=0.
            do k=1,nz
               icnt=0
               jcnt=0
               do i=1,nx
                  do j=1,ny
                     if(xland(i,j).ne.1) then
                        icnt=icnt+1                
                        do imem=1,num_mem
                           co_mean_ocn_prf(k)=co_mean_ocn_prf(k)+co_prior(i,j,k,imem)/real(num_mem)
                           prs_mean_ocn_prf(k)=prs_mean_ocn_prf(k)+prs_prior(i,j,k,imem)/real(num_mem)
                        enddo
                     else
                        jcnt=jcnt+1                
                        do imem=1,num_mem
                           co_mean_lnd_prf(k)=co_mean_lnd_prf(k)+co_prior(i,j,k,imem)/real(num_mem)
                           prs_mean_lnd_prf(k)=prs_mean_lnd_prf(k)+prs_prior(i,j,k,imem)/real(num_mem)
                        enddo
                     endif
                  enddo
               enddo
               co_mean_ocn_prf(k)=co_mean_ocn_prf(k)/real(icnt)
               prs_mean_ocn_prf(k)=prs_mean_ocn_prf(k)/real(icnt)
               co_mean_lnd_prf(k)=co_mean_lnd_prf(k)/real(jcnt)
               prs_mean_lnd_prf(k)=prs_mean_lnd_prf(k)/real(jcnt)
            enddo
!
! reset the post low values over the ocean to the priors
            do i=1,nx
               do j=1,ny
                  do k=1,nz
                     co_min=(xland(i,j)-1.)*co_mean_ocn_prf(k) + (2.-xland(i,j))*co_mean_lnd_prf(k)
                     if(co_mean(i,j,k).lt.fac1*co_min) then
                        do imem=1,num_mem
                           if(co_post(i,j,k,imem).lt.fac1*co_min) then
                              co_post(i,j,k,imem)=fac1*co_min
                           endif
                        enddo
                     endif
                  enddo
               enddo
            enddo  
! 
! write the modified post field
            do imem=1,num_mem
               write(imem_char,'(i4)') imem
               if(imem.lt.1000) write(imem_char,'(a1,i3)') '0',imem
               if(imem.lt.100) write(imem_char,'(a2,i2)') '00',imem
               if(imem.lt.10) write(imem_char,'(a3,i1)') '000',imem
               file='new_po_wrfinput_d01_'//trim(imem_char)
               file_in=trim(file)
               call put_DART_diag_data(file_in,'co',co_post(1,1,1,imem),nx,ny,nz,1)
            enddo
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
!            print *, trim(file_in)
!            rc = nf_open(trim(file_in),NF_NOWRITE,fid)
            rc = nf90_open(trim(file_in),NF90_NOWRITE,fid)
            if(rc.ne.nf90_noerr) call handle_err(rc,'nf90_open')
!
! get variables identifiers
!            rc = nf_inq_varid(fid,trim(name),v_id)
            rc = nf90_inq_varid(fid,trim(name),v_id)
            if(rc.ne.nf90_noerr) call handle_err(rc,'nf90_inq_varid')
!            print *, 'v_id ',v_id
!
! get dimension identifiers
            v_dimid(:)=0
            rc = nf90_inquire_variable(fid,v_id,vnam,typ,v_ndim,v_dimid,natts)
            if(rc.ne.nf90_noerr) call handle_err(rc,'nf90_inquire_variable')
!            print *, 'v_ndim ',v_ndim
!            print *, 'v_dimid ',v_dimid 
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
!            print *, 'v_dim ',v_dim
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
!            print *, data(1,1,1,1)
            return
         end subroutine get_DART_diag_data
!
         subroutine put_DART_diag_data(file_in,name,data,nx,ny,nz,nc)
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
!            print *, trim(file_in)
!            rc = nf_open(trim(file_in),NF_NOWRITE,fid)
            rc = nf90_open(trim(file_in),NF90_WRITE,fid)
            if(rc.ne.nf90_noerr) call handle_err(rc,'nf90_open')
!
! get variables identifiers
!            rc = nf_inq_varid(fid,trim(name),v_id)
            rc = nf90_inq_varid(fid,trim(name),v_id)
            if(rc.ne.nf90_noerr) call handle_err(rc,'nf90_inq_varid')
!            print *, 'v_id ',v_id
!
! get dimension identifiers
            v_dimid(:)=0
            rc = nf90_inquire_variable(fid,v_id,vnam,typ,v_ndim,v_dimid,natts)
            if(rc.ne.nf90_noerr) call handle_err(rc,'nf90_inquire_variable')
!            print *, 'v_ndim ',v_ndim
!            print *, 'v_dimid ',v_dimid 
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
!            print *, 'v_dim ',v_dim
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
! put data
            one(:)=1
            rc = nf90_put_var(fid,v_id,data,one,v_dim)
            if(rc.ne.nf90_noerr) call handle_err(rc,'nf90_get_var')
            rc = nf90_close(fid)
            if(rc.ne.nf90_noerr) call handle_err(rc,'nf90_close')
!            print *, data(1,1,1,1)
            return
         end subroutine put_DART_diag_data
!
         subroutine handle_err(rc,text)
            implicit none
            integer         :: rc
            character*(*)   :: text
            print *, 'APM: NETCDF ERROR ',trim(text),' ',rc
            call abort
         end subroutine handle_err
!
         subroutine get_WRFINPUT_land_mask(xland,nx,ny)
            implicit none
            include 'netcdf.inc'
            integer, parameter                    :: maxdim=6
            integer                               :: nx,ny
            integer                               :: i,rc
            integer                               :: f_id
            integer                               :: v_id,v_ndim,typ,natts
            integer,dimension(maxdim)             :: one
            integer,dimension(maxdim)             :: v_dimid
            integer,dimension(maxdim)             :: v_dim
            real,dimension(nx,ny)                 :: xland
            character(len=150)                    :: v_nam
            character*(80)                         :: name
            character*(80)                         :: file
!
! open netcdf file
            file='wrfinput_d01'
            name='XLAND'
            rc = nf_open(trim(file),NF_NOWRITE,f_id)
!            print *, trim(file)
            if(rc.ne.0) then
               print *, 'nf_open error ',trim(file)
               call abort
            endif
!
! get variables identifiers
            rc = nf_inq_varid(f_id,trim(name),v_id)
!            print *, v_id
            if(rc.ne.0) then
               print *, 'nf_inq_varid error ', v_id
               call abort
            endif
!
! get dimension identifiers
            v_dimid=0
            rc = nf_inq_var(f_id,v_id,v_nam,typ,v_ndim,v_dimid,natts)
!            print *, v_dimid
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
!            print *, v_dim
            if(rc.ne.0) then
               print *, 'nf_inq_dimlen error ', v_dim
               call abort
            endif
!
! check dimensions
            if(nx.ne.v_dim(1)) then
               print *, 'ERROR: nx dimension conflict ',nx,v_dim(1)
               call abort
            else if(ny.ne.v_dim(2)) then
               print *, 'ERROR: ny dimension conflict ',ny,v_dim(2)
               call abort
            else if(1.ne.v_dim(3)) then             
               print *, 'ERROR: nz dimension conflict ','1',v_dim(3)
               call abort
!            else if(1.ne.v_dim(4)) then             
!               print *, 'ERROR: time dimension conflict ',1,v_dim(4)
!               call abort
            endif
!
! get data
            one(:)=1
            rc = nf_get_vara_real(f_id,v_id,one,v_dim,xland)
            if(rc.ne.0) then
               print *, 'nf_get_vara_real ', xland(1,1)
               call abort
            endif
            rc = nf_close(f_id)
            return
         end subroutine get_WRFINPUT_land_mask   
!
         subroutine put_WRFCHEM_emiss_data(file,name,data,nx,ny,nz_chem)
            implicit none
            include 'netcdf.inc'
            integer, parameter                    :: maxdim=6
            integer                               :: nx,ny,nz_chem
            integer                               :: i,rc
            integer                               :: f_id
            integer                               :: v_id,v_ndim,typ,natts
            integer,dimension(maxdim)             :: one
            integer,dimension(maxdim)             :: v_dimid
            integer,dimension(maxdim)             :: v_dim
            real,dimension(nx,ny,nz_chem)         :: data
            character(len=150)                    :: v_nam
            character*(*)                         :: name
            character*(*)                         :: file
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
!            print *, v_id
            if(rc.ne.0) then
               print *, 'nf_inq_varid error ', v_id
               call abort
            endif
!
! get dimension identifiers
            v_dimid=0
            rc = nf_inq_var(f_id,v_id,v_nam,typ,v_ndim,v_dimid,natts)
!            print *, v_dimid
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
!            print *, v_dim
            if(rc.ne.0) then
               print *, 'nf_inq_dimlen error ', v_dim
               call abort
            endif
!
! check dimensions
            if(nx.ne.v_dim(1)) then
               print *, 'ERROR: nx dimension conflict ',nx,v_dim(1)
               call abort
            else if(ny.ne.v_dim(2)) then
               print *, 'ERROR: ny dimension conflict ',ny,v_dim(2)
               call abort
            else if(nz_chem.ne.v_dim(3)) then             
               print *, 'ERROR: nz_chem dimension conflict ',nz_chem,v_dim(3)
               call abort
            else if(1.ne.v_dim(4)) then             
               print *, 'ERROR: time dimension conflict ',1,v_dim(4)
               call abort
            endif
!
! put data
            one(:)=1
            rc = nf_put_vara_real(f_id,v_id,one,v_dim,data)
            if(rc.ne.0) then
               print *, 'nf_put_vara_real ', data(1,1,1)
               call abort
            endif
            rc = nf_close(f_id)
            return
         end subroutine put_WRFCHEM_emiss_data   








