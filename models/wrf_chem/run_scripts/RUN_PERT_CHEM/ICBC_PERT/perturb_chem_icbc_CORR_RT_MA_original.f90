! Copyright 2019 NCAR/ACOM
! 
! Licensed under the Apache License, Version 2.0 (the "License");
! you may not use this file except in compliance with the License.
! You may obtain a copy of the License at
! 
!     http://www.apache.org/licenses/LICENSE-2.0
! 
! Unless required by applicable law or agreed to in writing, software
! distributed under the License is distributed on an "AS IS" BASIS,
! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
! See the License for the specific language governing permissions and
! limitations under the License.
!
! DART $Id$

! code to perturb the wrfchem icbc files

          program main
             implicit none
             integer,parameter                           :: nbdy_exts=8
             integer,parameter                           :: nhalo=5
             integer                                     :: unit,unita,unitb
             integer                                     :: nx,ny,nz,nzp,nt,nchem_spcs
             integer                                     :: i,ii,j,jj,ij,nij,k,kk,l,ll,ibdy,bdy_idx,isp,num_mem,imem
             integer                                     :: ngrid_corr
             integer                                     :: ii_str,ii_end,ii_npt,ii_sft
             integer                                     :: jj_str,jj_end,jj_npt,jj_sft
             real                                        :: pi,grav,u_ran_1,u_ran_2,nnum_mem
             real                                        :: sprd_chem
             real                                        :: grid_length,vcov
             real                                        :: corr_half_width_hz
             real                                        :: corr_half_width_vt
             real                                        :: corr_half_width_tm
             real                                        :: wgt,wgt_summ
             real                                        :: mean,std,get_dist
             real                                        :: atime1,atime2,atime3,atime4,atime5,atime6
             real                                        :: atime1_mem,atime2_mem
                                                         
             real,allocatable,dimension(:,:)             :: lat,lon
             real,allocatable,dimension(:,:,:)           :: geo_ht,wgt_sum,pert_chem
             real,allocatable,dimension(:,:,:,:)         :: dist
             real,allocatable,dimension(:,:,:,:)         :: A
             real,allocatable,dimension(:,:,:,:)         :: chem_data3d
             real,allocatable,dimension(:,:,:,:)         :: chem_databdy
             real,allocatable,dimension(:,:,:,:)         :: chem_fac_pr
             real,allocatable,dimension(:,:,:,:)         :: chem_fac
             real,allocatable,dimension(:)               :: mems,pers,pert_chem_sum
             character(len=150)                          :: pert_path_pr,pert_path_po,ch_spcs
             character(len=150)                          :: wrfchem_file,wrfinput_parent,wrfbdy_parent
             character(len=20)                           :: cmem
             character(len=5),dimension(nbdy_exts)       :: bdy_exts=(/'_BXS ','_BXE ','_BYS ','_BYE ','_BTXS', &
             '_BTXE','_BTYS','_BTYE'/)
             integer,dimension(nbdy_exts)                :: bdy_dims=(/139,139,179,179,139,139,179,179/)
             character(len=150),allocatable,dimension(:) :: ch_chem_spc
             logical                                     :: sw_corr_tm,sw_seed
             namelist /perturb_chem_icbc_corr_nml/nx,ny,nz,nchem_spcs,pert_path_pr,pert_path_po,nnum_mem, &
             wrfinput_parent,wrfbdy_parent,sprd_chem,corr_half_width_hz,corr_half_width_vt, &
             corr_half_width_tm,sw_corr_tm,sw_seed
             namelist /perturb_chem_icbc_spcs_nml/ch_chem_spc
!
! Assign constants
             pi=4.*atan(1.)
             grav=9.8
             nt=2
!
! Read control namelist
             unit=20
             open(unit=unit,file='perturb_chem_icbc_corr_nml.nl',form='formatted', &
             status='old',action='read') 
             read(unit,perturb_chem_icbc_corr_nml)
             close(unit)
             print *, 'nx                 ',nx
             print *, 'ny                 ',ny
             print *, 'nz                 ',nz
             print *, 'nchem_spcs         ',nchem_spcs
             print *, 'pert_path_pr       ',trim(pert_path_pr)
             print *, 'pert_path_po       ',trim(pert_path_po)
             print *, 'num_mem            ',nnum_mem
             print *, 'wrfinput_parent    ',trim(wrfinput_parent)
             print *, 'wrfbdy_parent      ',trim(wrfbdy_parent)
             print *, 'sprd_chem          ',sprd_chem
             print *, 'corr_half_width_hz ',corr_half_width_hz
             print *, 'corr_half_width_vt ',corr_half_width_vt
             print *, 'corr_half_width_tm ',corr_half_width_tm
             print *, 'sw_corr_tm         ',sw_corr_tm
             print *, 'sw_seed            ',sw_seed
             nzp=nz+1
             num_mem=nint(nnum_mem)
!
! Allocate arrays
             allocate(ch_chem_spc(nchem_spcs))
             allocate(A(nx,ny,nz,nz))
             A(:,:,:,:)=0.
!
! Read the species namelist
             unit=20
             open(unit=unit,file='perturb_chem_icbc_spcs_nml.nl',form='formatted', &
             status='old',action='read')
             read(unit,perturb_chem_icbc_spcs_nml)
             close(unit)
!
! Get lat / lon data
             allocate(lat(nx,ny),lon(nx,ny))
             call get_WRFINPUT_lat_lon(lat,lon,nx,ny)
!
! Get mean geopotential height data
             allocate(geo_ht(nx,ny,nz))
             call get_WRFINPUT_geo_ht(geo_ht,nx,ny,nz,nzp,num_mem)
             geo_ht(:,:,:)=geo_ht(:,:,:)/grav
!
! Construct the vertical correlations transformation matrix
             do k=1,nz
                do l=1,nz
                   do i=1,nx
                      do j=1,ny
                         vcov=1.-abs(geo_ht(i,j,k)-geo_ht(i,j,l))/corr_half_width_vt
                         if(vcov.lt.0.) vcov=0.
! row 1
                         if(k.eq.1 .and. l.eq.1) then
                            A(i,j,k,l)=1.
                         elseif(k.eq.1 .and. l.gt.1) then
                            A(i,j,k,l)=0.
                         endif
! row 2
                         if(k.eq.2 .and. l.eq.1) then
                            A(i,j,k,l)=vcov
                         elseif(k.eq.2 .and. l.eq.2) then
                            A(i,j,k,l)=sqrt(1.-A(i,j,k,l-1)*A(i,j,k,l-1))
                         elseif (k.eq.2 .and. l.gt.2) then
                            A(i,j,k,l)=0.
                         endif
! row 3 and greater
                         if(k.ge.3) then
                            if(l.eq.1) then
                               A(i,j,k,l)=vcov
                            elseif(l.lt.k .and. l.ne.1) then
                               do ll=1,l-1
                                  A(i,j,k,l)=A(i,j,k,l)+A(i,j,l,ll)*A(i,j,k,ll)
                               enddo
                               if(A(i,j,l,l).ne.0) A(i,j,k,l)=(vcov-A(i,j,k,l))/A(i,j,l,l)
                            elseif(l.eq.k) then
                               do ll=1,l-1
                                  A(i,j,k,l)=A(i,j,k,l)+A(i,j,k,ll)*A(i,j,k,ll)
                               enddo
                               A(i,j,k,l)=sqrt(1.-A(i,j,k,l))
                            endif
                         endif
                      enddo
                   enddo
                enddo
             enddo
             deallocate(geo_ht)
!
! Get horiztonal grid length
             grid_length=get_dist(lat(nx/2,ny/2),lat(nx/2+1,ny/2),lon(nx/2,ny/2),lon(nx/2+1,ny/2))
!
! Calculate number of horizontal grid points to be correlated 
             ngrid_corr=ceiling(corr_half_width_hz/grid_length)+1
!
! Calculate distances
             allocate(dist(nx,ny,2*ngrid_corr+1,2*ngrid_corr+1))
             dist(:,:,:,:)=-9999.
             do i=1,nx
                do j=1,ny
                   ii_str=max(1,i-ngrid_corr)
                   ii_end=min(nx,i+ngrid_corr)
                   ii_npt=ii_end-ii_str+1
                   jj_str=max(1,j-ngrid_corr)
                   jj_end=min(ny,j+ngrid_corr)
                   jj_npt=jj_end-jj_str+1
                   do ii_sft=1,ii_npt
                      ii=ii_str+ii_sft-1
                      do jj_sft=1,jj_npt
                         jj=jj_str+jj_sft-1
                         dist(i,j,ii_sft,jj_sft)=get_dist(lat(ii,jj),lat(i,j),lon(ii,jj),lon(i,j))
                      enddo
                   enddo
                enddo
             enddo
             deallocate(lat,lon)
!
! Calcualte new random number seed
             if(sw_seed) call init_random_seed()
!
! Generate random field
             do isp=1,nchem_spcs
                call cpu_time(atime1)
                allocate(chem_fac(nx,ny,nz,num_mem))
                chem_fac(:,:,:,:)=0.
                do imem=1,num_mem
                   call cpu_time(atime1_mem)
                   allocate(pert_chem(nx,ny,nz))
                   pert_chem(:,:,:)=0.
                   do i=1,nx
                      do j=1,ny
                         do k=1,nz
                            call random_number(u_ran_1)
                            if(u_ran_1.eq.0.) call random_number(u_ran_1)
                            call random_number(u_ran_2)
                            if(u_ran_2.eq.0.) call random_number(u_ran_2)
                            pert_chem(i,j,k)=sqrt(-2.*log(u_ran_1))*cos(2.*pi*u_ran_2)
                         enddo 
                      enddo
                   enddo
! Impose horizontal correlations
                   print *,'horizontal correlations'
                   allocate(wgt_sum(nx,ny,nz))
                   wgt_sum(:,:,:)=0.
                   do i=1,nx
                      do j=1,ny
                         ii_str=max(1,i-ngrid_corr)
                         ii_end=min(nx,i+ngrid_corr)
                         ii_npt=ii_end-ii_str+1
                         jj_str=max(1,j-ngrid_corr)
                         jj_end=min(ny,j+ngrid_corr)
                         jj_npt=jj_end-jj_str+1
                         do ii_sft=1,ii_npt
                            ii=ii_str+ii_sft-1
                            do jj_sft=1,jj_npt
                               jj=jj_str+jj_sft-1
                               if(dist(i,j,ii_sft,jj_sft).le.corr_half_width_hz) then
                                  do k=1,nz
                                     wgt=1./exp(dist(i,j,ii_sft,jj_sft)*dist(i,j,ii_sft,jj_sft)/ &
                                     corr_half_width_hz/corr_half_width_hz)
                                     wgt_sum(i,j,k)=wgt_sum(i,j,k)+wgt
                                     chem_fac(i,j,k,imem)=chem_fac(i,j,k,imem)+wgt*pert_chem(ii,jj,k)
                                  enddo
                               endif
                            enddo
                         enddo
                         do k=1,nz
                            if(wgt_sum(i,j,k).ne.0) then
                               chem_fac(i,j,k,imem)=chem_fac(i,j,k,imem)/wgt_sum(i,j,k)
                            endif
                         enddo
                      enddo
                   enddo
                   deallocate(wgt_sum)
                   deallocate(pert_chem)
! Impose vertical correlations
                   print *,'vertical correlations'
                   allocate(pert_chem_sum(nz))
                   do i=1,nx
                      do j=1,ny
                         pert_chem_sum(:)=0.
                         do k=1,nz
                            do kk=1,nz 
                               pert_chem_sum(k)=pert_chem_sum(k)+A(i,j,k,kk)*chem_fac(i,j,kk,imem)
                            enddo
                         enddo
                         do k=1,nz
                            chem_fac(i,j,k,imem)=pert_chem_sum(k)
                         enddo 
                      enddo
                   enddo
                   deallocate(pert_chem_sum)
                   call cpu_time(atime2_mem)
                   print *, 'mem ',imem,'elapsed time (min) ',(atime2_mem-atime1_mem)/60.
                enddo
                call cpu_time(atime2)
                print *, 'elapsed time (min) ',(atime2-atime1)/60.
! Recenter about ensemble mean
                print *,'recentering'
                allocate(mems(num_mem),pers(num_mem))             
                do i=1,nx
                   do j=1,ny
                      do k=1,nz
                         mems(:)=chem_fac(i,j,k,:)
                         mean=sum(mems)/real(num_mem)
                         pers=(mems-mean)*(mems-mean)
                         std=sqrt(sum(pers)/real(num_mem-1))
                         do imem=1,num_mem
                            chem_fac(i,j,k,imem)=(chem_fac(i,j,k,imem)-mean)*sprd_chem/std
                         enddo
                      enddo
                   enddo
                enddo
                deallocate(mems,pers)
                call cpu_time(atime3)
                print *, 'elapsed time (min) ',(atime3-atime2)/60.
! Impose temporal correlations
                print *,'temporal correlations'
                allocate(chem_fac_pr(nx,ny,nz,num_mem))
                chem_fac_pr(:,:,:,:)=0.
                unita=30
                unitb=40
                open(unit=unitb,file=trim(pert_path_po)//'/pert_chem_icbc', &
                form='unformatted',status='unknown')
                wgt=0.
                if (sw_corr_tm) then
                   open(unit=unita,file=trim(pert_path_pr)//'/pert_chem_icbc', &
                   form='unformatted',status='unknown')
                   read(unita) chem_fac_pr
                   wgt=1.-1./corr_half_width_tm
                   close(unita)
                endif
                chem_fac(:,:,:,:)=wgt*chem_fac_pr(:,:,:,:)+sqrt(1.-wgt*wgt)*chem_fac(:,:,:,:)
                write(unitb) chem_fac
                close(unitb)
                deallocate(chem_fac_pr)
                call cpu_time(atime4)
                print *, 'elapsed time (min) ',(atime4-atime3)/60.
! Perturb the members
                print *,'Perturb the IC members'
                do imem=1,num_mem
                   if(imem.ge.0.and.imem.lt.10) write(cmem,"('.e00',i1)"),imem
                   if(imem.ge.10.and.imem.lt.100) write(cmem,"('.e0',i2)"),imem
                   if(imem.ge.100.and.imem.lt.1000) write(cmem,"('.e',i3)"),imem
! ICs
                   wrfchem_file=trim(wrfinput_parent)//trim(cmem)
                   allocate(chem_data3d(nx,ny,nz,1))
                   call get_WRFCHEM_icbc_data(wrfchem_file,ch_chem_spc(isp),chem_data3d,nx,ny,nz,1)
                   do i=1,nx
                      do j=1,ny
                         do k=1,nz
                            chem_data3d(i,j,k,1)=chem_data3d(i,j,k,1)*exp(chem_fac(i,j,k,imem))
                         enddo
                      enddo
                   enddo 
                   call put_WRFCHEM_icbc_data(wrfchem_file,ch_chem_spc(isp),chem_data3d,nx,ny,nz,1)
                   deallocate(chem_data3d)
! BCs
                   print *,'Perturb the BC members'
                   wrfchem_file=trim(wrfbdy_parent)//trim(cmem)
                   do ibdy=1,nbdy_exts                      
                      ch_spcs=trim(ch_chem_spc(isp))//trim(bdy_exts(ibdy))
                      allocate(chem_databdy(bdy_dims(ibdy),nz,nhalo,nt))
                      call get_WRFCHEM_icbc_data(wrfchem_file,trim(ch_spcs),chem_databdy,bdy_dims(ibdy),nz,nhalo,nt)
                      do ij=1,bdy_dims(ibdy)
                         do nij=1,nhalo
                            bdy_idx=1
                            if(ibdy.eq.1.or.ibdy.eq.2.or.ibdy.eq.5.or.ibdy.eq.6) then 
                               if(ibdy/2*2.eq.ibdy) bdy_idx=nx
                               i=bdy_idx
                               j=ij
                            else if(ibdy.eq.3.or.ibdy.eq.4.or.ibdy.eq.7.or.ibdy.eq.8) then
                               if(ibdy/2*2.eq.ibdy) bdy_idx=ny
                               i=ij
                               j=bdy_idx
                            endif
                            do k=1,nz
                               do l=1,nt
                                  chem_databdy(ij,k,nij,l)=chem_databdy(ij,k,nij,l)*exp(chem_fac(i,j,k,imem))
                               enddo
                            enddo
                         enddo
                      enddo 
                      call put_WRFCHEM_icbc_data(wrfchem_file,trim(ch_spcs),chem_databdy,bdy_dims(ibdy),nz,nhalo,nt)
                      deallocate(chem_databdy)
                   enddo
                enddo
                call cpu_time(atime5)
                print *, 'elapsed time (min) ',(atime5-atime4)/60.
                stop
             enddo
!
             deallocate(chem_fac)
             deallocate(ch_chem_spc)
          end program main
!
          function get_dist(lat1,lat2,lon1,lon2)
! returns distance in km
             implicit none
             real:: lat1,lat2,lon1,lon2,get_dist
             real:: lon_dif,rtemp
             real:: pi,ang2rad,r_earth
             real:: coef_a,coef_c
             pi=4.*atan(1.0)
             ang2rad=pi/180.
             r_earth=6371.393
! Haversine Code
             coef_a=sin((lat2-lat1)/2.*ang2rad) * sin((lat2-lat1)/2.*ang2rad) + & 
             cos(lat1*ang2rad)*cos(lat2*ang2rad) * sin((lon2-lon1)/2.*ang2rad) * &
             sin((lon2-lon1)/2.*ang2rad)
             coef_c=2.*atan2(sqrt(coef_a),sqrt(1.-coef_a))
             get_dist=coef_c*r_earth
          end function get_dist
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
             file='wrfinput_d01.e001'
             name='XLAND'
             rc = nf_open(trim(file),NF_NOWRITE,f_id)
!             print *, trim(file)
             if(rc.ne.0) then
                print *, 'nf_open error ',trim(file)
                stop
             endif
!
! get variables identifiers
             rc = nf_inq_varid(f_id,trim(name),v_id)
!             print *, v_id
             if(rc.ne.0) then
                print *, 'nf_inq_varid error ', v_id
                stop
             endif
!
! get dimension identifiers
             v_dimid=0
             rc = nf_inq_var(f_id,v_id,v_nam,typ,v_ndim,v_dimid,natts)
!             print *, v_dimid
             if(rc.ne.0) then
                print *, 'nf_inq_var error ', v_dimid
                stop
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
                stop
             endif
!
! check dimensions
             if(nx.ne.v_dim(1)) then
                print *, 'ERROR: nx dimension conflict ',nx,v_dim(1)
                stop
             else if(ny.ne.v_dim(2)) then
                print *, 'ERROR: ny dimension conflict ',ny,v_dim(2)
                stop
             else if(1.ne.v_dim(3)) then             
                print *, 'ERROR: nz dimension conflict ','1',v_dim(3)
                stop
!             else if(1.ne.v_dim(4)) then             
!                print *, 'ERROR: time dimension conflict ',1,v_dim(4)
!                stop
             endif
!
! get data
             one(:)=1
             rc = nf_get_vara_real(f_id,v_id,one,v_dim,xland)
             if(rc.ne.0) then
                print *, 'nf_get_vara_real ', xland(1,1)
                stop
             endif
             rc = nf_close(f_id)
             return
          end subroutine get_WRFINPUT_land_mask   
!
          subroutine get_WRFINPUT_lat_lon(lat,lon,nx,ny)
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
             real,dimension(nx,ny)                 :: lat,lon
             character(len=150)                    :: v_nam
             character*(80)                         :: name
             character*(80)                         :: file
!
! open netcdf file
             file='wrfinput_d01.e001'
             name='XLAT'
             rc = nf_open(trim(file),NF_NOWRITE,f_id)
!             print *, trim(file)
             if(rc.ne.0) then
                print *, 'nf_open error ',trim(file)
                stop
             endif
!
! get variables identifiers
             rc = nf_inq_varid(f_id,trim(name),v_id)
!             print *, v_id
             if(rc.ne.0) then
                print *, 'nf_inq_varid error ', v_id
                stop
             endif
!
! get dimension identifiers
             v_dimid=0
             rc = nf_inq_var(f_id,v_id,v_nam,typ,v_ndim,v_dimid,natts)
!             print *, v_dimid
             if(rc.ne.0) then
                print *, 'nf_inq_var error ', v_dimid
                stop
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
                stop
             endif
!
! check dimensions
             if(nx.ne.v_dim(1)) then
                print *, 'ERROR: nx dimension conflict ',nx,v_dim(1)
                stop
             else if(ny.ne.v_dim(2)) then
                print *, 'ERROR: ny dimension conflict ',ny,v_dim(2)
                stop
             else if(1.ne.v_dim(3)) then             
                print *, 'ERROR: nz dimension conflict ','1',v_dim(3)
                stop
!             else if(1.ne.v_dim(4)) then             
!                print *, 'ERROR: time dimension conflict ',1,v_dim(4)
!                stop
             endif
!
! get data
             one(:)=1
             rc = nf_get_vara_real(f_id,v_id,one,v_dim,lat)
             if(rc.ne.0) then
                print *, 'nf_get_vara_real ', lat(1,1)
                stop
             endif
             
             name='XLONG'
             rc = nf_inq_varid(f_id,trim(name),v_id)
             if(rc.ne.0) then
                print *, 'nf_inq_varid error ', v_id
                stop
             endif
             rc = nf_get_vara_real(f_id,v_id,one,v_dim,lon)
             if(rc.ne.0) then
                print *, 'nf_get_vara_real ', lon(1,1)
                stop
             endif
             rc = nf_close(f_id)
             return
          end subroutine get_WRFINPUT_lat_lon
!
          subroutine get_WRFINPUT_geo_ht(geo_ht,nx,ny,nz,nzp,nmem)
             implicit none
             include 'netcdf.inc'
             integer, parameter                    :: maxdim=6
             integer                               :: k,nx,ny,nz,nzp,nmem
             integer                               :: i,imem,rc
             integer                               :: f_id
             integer                               :: v_id_ph,v_id_phb,v_ndim,typ,natts
             integer,dimension(maxdim)             :: one
             integer,dimension(maxdim)             :: v_dimid
             integer,dimension(maxdim)             :: v_dim
             real,dimension(nx,ny,nzp)             :: ph,phb
             real,dimension(nx,ny,nz)              :: geo_ht
             character(len=150)                    :: v_nam
             character*(80)                        :: name,cmem
             character*(80)                        :: file
!
! Loop through members to find ensemble mean geo_ht
             geo_ht(:,:,:)=0.
             do imem=1,nmem
                if(imem.ge.0.and.imem.lt.10) write(cmem,"('.e00',i1)"),imem
                if(imem.ge.10.and.imem.lt.100) write(cmem,"('.e0',i2)"),imem
                if(imem.ge.100.and.imem.lt.1000) write(cmem,"('.e',i3)"),imem
!
! open netcdf file

                file='wrfinput_d01'//trim(cmem)
                rc = nf_open(trim(file),NF_NOWRITE,f_id)
                if(rc.ne.0) then
                   print *, 'nf_open error ',trim(file)
                   stop
                endif
!
! get variables identifiers
                name='PH'
                rc = nf_inq_varid(f_id,trim(name),v_id_ph)
                if(rc.ne.0) then
                   print *, 'nf_inq_varid error ', v_id_ph
                   stop
                endif
                name='PHB'
                rc = nf_inq_varid(f_id,trim(name),v_id_phb)
                if(rc.ne.0) then
                   print *, 'nf_inq_varid error ', v_id_phb
                   stop
                endif
!
! get dimension identifiers
                v_dimid=0
                rc = nf_inq_var(f_id,v_id_ph,v_nam,typ,v_ndim,v_dimid,natts)
                if(rc.ne.0) then
                   print *, 'nf_inq_var error ', v_dimid
                   stop
                endif
!
! get dimensions
                v_dim(:)=1
                do i=1,v_ndim
                   rc = nf_inq_dimlen(f_id,v_dimid(i),v_dim(i))
                enddo
                if(rc.ne.0) then
                   print *, 'nf_inq_dimlen error ', v_dim
                   stop
                endif
!
! check dimensions
                if(nx.ne.v_dim(1)) then
                   print *, 'ERROR: nx dimension conflict ',nx,v_dim(1)
                   stop
                else if(ny.ne.v_dim(2)) then
                   print *, 'ERROR: ny dimension conflict ',ny,v_dim(2)
                   stop
                else if(nzp.ne.v_dim(3)) then             
                   print *, 'ERROR: nzp dimension conflict ','nzp',v_dim(3)
                   stop
                endif
!
! get data
                one(:)=1
                rc = nf_get_vara_real(f_id,v_id_ph,one,v_dim,ph)
                if(rc.ne.0) then
                   print *, 'nf_get_vara_real ', ph(1,1,1)
                   stop
                endif
                rc = nf_get_vara_real(f_id,v_id_phb,one,v_dim,phb)
                if(rc.ne.0) then
                   print *, 'nf_get_vara_real ', phb(1,1,1)
                   stop
                endif
!
! get mean geo_ht
                do k=1,nz
                   geo_ht(:,:,k)=geo_ht(:,:,k)+(ph(:,:,k)+phb(:,:,k)+ph(:,:,k+1)+ &
                   phb(:,:,k+1))/2./float(nmem)
                enddo
                rc = nf_close(f_id)
             enddo
          end subroutine get_WRFINPUT_geo_ht
!
          subroutine get_WRFCHEM_icbc_data(file,name,data,nx,ny,nz,nt)
             implicit none
             include 'netcdf.inc'
             integer, parameter                    :: maxdim=6
             integer                               :: nx,ny,nz,nt
             integer                               :: i,rc
             integer                               :: f_id
             integer                               :: v_id,v_ndim,typ,natts
             integer,dimension(maxdim)             :: one
             integer,dimension(maxdim)             :: v_dimid
             integer,dimension(maxdim)             :: v_dim
             real,dimension(nx,ny,nz)              :: data
             character(len=150)                    :: v_nam
             character*(*)                         :: name
             character*(*)                         :: file
!
! open netcdf file
             rc = nf_open(trim(file),NF_SHARE,f_id)
!             print *, trim(file)
             if(rc.ne.0) then
                print *, 'nf_open error in get ',rc, trim(file)
                stop
             endif
!
! get variables identifiers
             rc = nf_inq_varid(f_id,trim(name),v_id)
!             print *, v_id
             if(rc.ne.0) then
                print *, 'nf_inq_varid error ', v_id
                stop
             endif
!
! get dimension identifiers
             v_dimid=0
             rc = nf_inq_var(f_id,v_id,v_nam,typ,v_ndim,v_dimid,natts)
!             print *, v_dimid
             if(rc.ne.0) then
                print *, 'nf_inq_var error ', v_dimid
                stop
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
                stop
             endif
!
! check dimensions
             if(nx.ne.v_dim(1)) then
                print *, 'ERROR: nx dimension conflict ',nx,v_dim(1)
                stop
             else if(ny.ne.v_dim(2)) then
                print *, 'ERROR: ny dimension conflict ',ny,v_dim(2)
                stop
             else if(nz.ne.v_dim(3)) then             
                print *, 'ERROR: nz dimension conflict ',nz,v_dim(3)
                stop
             else if(nt.ne.v_dim(4)) then             
                print *, 'ERROR: time dimension conflict ',1,v_dim(4)
                stop
             endif
!
! get data
             one(:)=1
             rc = nf_get_vara_real(f_id,v_id,one,v_dim,data)
             if(rc.ne.0) then
                print *, 'nf_get_vara_real ', data(1,1,1)
                stop
             endif
             rc = nf_close(f_id)
             return
          end subroutine get_WRFCHEM_icbc_data
!
          subroutine put_WRFCHEM_icbc_data(file,name,data,nx,ny,nz,nt)
             implicit none
             include 'netcdf.inc'
             integer, parameter                    :: maxdim=6
             integer                               :: nx,ny,nz,nt
             integer                               :: i,rc
             integer                               :: f_id
             integer                               :: v_id,v_ndim,typ,natts
             integer,dimension(maxdim)             :: one
             integer,dimension(maxdim)             :: v_dimid
             integer,dimension(maxdim)             :: v_dim
             real,dimension(nx,ny,nz)              :: data
             character(len=150)                    :: v_nam
             character*(*)                         :: name
             character*(*)                         :: file
!
! open netcdf file
             rc = nf_open(trim(file),NF_WRITE,f_id)
             if(rc.ne.0) then
                print *, 'nf_open error in put ',rc, trim(file)
                stop
             endif
!             print *, 'f_id ',f_id
!
! get variables identifiers
             rc = nf_inq_varid(f_id,trim(name),v_id)
!             print *, v_id
             if(rc.ne.0) then
                print *, 'nf_inq_varid error ', v_id
                stop
             endif
!             print *, 'v_id ',v_id
!
! get dimension identifiers
             v_dimid=0
             rc = nf_inq_var(f_id,v_id,v_nam,typ,v_ndim,v_dimid,natts)
!             print *, v_dimid
             if(rc.ne.0) then
                print *, 'nf_inq_var error ', v_dimid
                stop
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
                stop
             endif
!
! check dimensions
             if(nx.ne.v_dim(1)) then
                print *, 'ERROR: nx dimension conflict ',nx,v_dim(1)
                stop
             else if(ny.ne.v_dim(2)) then
                print *, 'ERROR: ny dimension conflict ',ny,v_dim(2)
                stop
             else if(nz.ne.v_dim(3)) then             
                print *, 'ERROR: nz dimension conflict ',nz,v_dim(3)
                stop
             else if(nt.ne.v_dim(4)) then             
                print *, 'ERROR: time dimension conflict ',1,v_dim(4)
                stop
             endif
!
! put data
             one(:)=1
             rc = nf_put_vara_real(f_id,v_id,one(1:v_ndim),v_dim(1:v_ndim),data)
             rc = nf_close(f_id)
             return
          end subroutine put_WRFCHEM_icbc_data
!
          subroutine init_random_seed()
!!             use ifport
             implicit none
             integer, allocatable :: aseed(:)
             integer :: i, n, un, istat, dt(8), pid, t(2), s, ierr
             integer(8) :: count, tms
!
             call random_seed(size = n)
             allocate(aseed(n))
!
! Fallback to XOR:ing the current time and pid. The PID is
! useful in case one launches multiple instances of the same
! program in parallel.                                                  
             call system_clock(count)
             if (count /= 0) then
                t = transfer(count, t)
             else
                call date_and_time(values=dt)
                tms = (dt(1) - 1970) * 365_8 * 24 * 60 * 60 * 1000 &
                     + dt(2) * 31_8 * 24 * 60 * 60 * 1000 &
                     + dt(3) * 24 * 60 * 60 * 60 * 1000 &
                     + dt(5) * 60 * 60 * 1000 &
                     + dt(6) * 60 * 1000 + dt(7) * 1000 &
                     + dt(8)
                t = transfer(tms, t)
             end if
             s = ieor(t(1), t(2))
!             pid = getpid() + 1099279 ! Add a prime
             call pxfgetpid(pid,ierr)
             s = ieor(s, pid)
             if (n >= 3) then
                aseed(1) = t(1) + 36269
                aseed(2) = t(2) + 72551
                aseed(3) = pid
                if (n > 3) then
                   aseed(4:) = s + 37 * (/ (i, i = 0, n - 4) /)
                end if
             else
                aseed = s + 37 * (/ (i, i = 0, n - 1 ) /)
             end if
             call random_seed(put=aseed)
          end subroutine init_random_seed

