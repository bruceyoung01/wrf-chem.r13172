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
             include 'mpif.h'
             integer,parameter                           :: nbdy_exts=8
             integer,parameter                           :: nhalo=5
             integer                                     :: unit,unita,unitb,num_procs
             integer                                     :: nx,ny,nz,nzp,nt,nchem_spcs,rank,stat
             integer                                     :: i,ii,j,jj,ij,nij,k,kk,l,ll,ibdy,bdy_idx
             integer                                     :: ierr,isp,num_mem,imem
             integer                                     :: ngrid_corr,nbff
             integer                                     :: ii_str,ii_end,ii_npt,ii_sft
             integer                                     :: jj_str,jj_end,jj_npt,jj_sft
             real                                        :: pi,grav,u_ran_1,u_ran_2,nnum_mem
             real                                        :: sprd_chem,zdist,zfac
             real                                        :: grid_length,vcov
             real                                        :: corr_lngth_hz
             real                                        :: corr_lngth_vt
             real                                        :: corr_lngth_tm
             real                                        :: corr_tm_delt
             real                                        :: wgt,wgt_bc1,wgt_summ
             real                                        :: mean,std,get_dist
             real                                        :: atime1,atime2,atime3,atime4,atime5,atime6
             real                                        :: atime1_mem,atime2_mem
             real,allocatable,dimension(:)               :: tmp_arry
             real,allocatable,dimension(:,:)             :: lat,lon
             real,allocatable,dimension(:,:,:)           :: geo_ht,wgt_sum,pert_chem
             real,allocatable,dimension(:,:,:,:)         :: dist
             real,allocatable,dimension(:,:,:,:)         :: A
             real,allocatable,dimension(:,:,:,:)         :: chem_data3d
             real,allocatable,dimension(:,:,:,:)         :: chem_databdy
             real,allocatable,dimension(:,:,:,:)         :: chem_fac_pr
             real,allocatable,dimension(:,:,:,:)         :: chem_fac_bc1
             real,allocatable,dimension(:,:,:,:)         :: chem_fac
             real,allocatable,dimension(:,:,:)           :: chem_fac_mem
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
             wrfinput_parent,wrfbdy_parent,sprd_chem,corr_lngth_hz,corr_lngth_vt, &
             corr_lngth_tm,corr_tm_delt,sw_corr_tm,sw_seed
             namelist /perturb_chem_icbc_spcs_nml/ch_chem_spc
!
! Setup mpi
             call mpi_init(ierr)
             call mpi_comm_rank(MPI_COMM_WORLD,rank,ierr)
             call mpi_comm_size(MPI_COMM_WORLD,num_procs,ierr)
!
! Assign constants
             if(rank.eq.0) then
                pi=4.*atan(1.)
                grav=9.8
                nt=2
                zfac=2.
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
                print *, 'corr_lngth_hz      ',corr_lngth_hz
                print *, 'corr_lngth_vt      ',corr_lngth_vt
                print *, 'corr_lngth_tm      ',corr_lngth_tm
                print *, 'corr_tm_delt       ',corr_tm_delt
                print *, 'sw_corr_tm         ',sw_corr_tm
                print *, 'sw_seed            ',sw_seed
                nzp=nz+1
                num_mem=nint(nnum_mem)
!
! Allocate arrays
                allocate(ch_chem_spc(nchem_spcs))
                allocate(A(nx,ny,nz,nz))
!
! Read the species namelist
                unit=20
                open( unit=unit,file='perturb_chem_icbc_spcs_nml.nl',form='formatted', &
                status='old',action='read')
                read(unit,perturb_chem_icbc_spcs_nml)
                close(unit)
!
! Get lat / lon data (-90 to 90; -180 to 180)
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
                            vcov=1.-abs(geo_ht(i,j,k)-geo_ht(i,j,l))/corr_lngth_vt
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
                grid_length=get_dist(lat(nx/2,ny),lat(nx/2+1,ny),lon(nx/2,ny),lon(nx/2+1,ny))
!
! Calculate number of horizontal grid points to be correlated 
                ngrid_corr=ceiling(zfac*corr_lngth_hz/grid_length)
                print *, 'ngrid_corr         ',ngrid_corr
!
! Calculate distances
!                allocate(dist(nx,ny,2*ngrid_corr+1,2*ngrid_corr+1))
!                dist(:,:,:,:)=-9999.
!                do i=1,nx
!                   do j=1,ny
!                      ii_str=max(1,i-ngrid_corr)
!                      ii_end=min(nx,i+ngrid_corr)
!                      ii_npt=ii_end-ii_str+1
!                      jj_str=max(1,j-ngrid_corr)
!                      jj_end=min(ny,j+ngrid_corr)
!                      jj_npt=jj_end-jj_str+1
!                      do ii_sft=1,ii_npt
!                         ii=ii_str+ii_sft-1
!                         do jj_sft=1,jj_npt
!                            jj=jj_str+jj_sft-1
!                            dist(i,j,ii_sft,jj_sft)=get_dist(lat(ii,jj),lat(i,j),lon(ii,jj),lon(i,j))
!                         enddo
!                      enddo
!                   enddo
!                enddo
!                deallocate(lat,lon)
                allocate(chem_fac(nx,ny,nz,num_mem))
                chem_fac(:,:,:,:)=0.
                do imem=1,num_mem             
                   call mpi_send(num_mem,1,MPI_INT,imem,1,MPI_COMM_WORLD,ierr)
!                   print *, imem,'send num_mem ',num_mem
                   call mpi_send(nx,1,MPI_INT,imem,2,MPI_COMM_WORLD,ierr)
!                   print *, imem,'send nx ',nx
                   call mpi_send(ny,1,MPI_INT,imem,3,MPI_COMM_WORLD,ierr)
!                   print *, imem,'send ny ',ny
                   call mpi_send(nz,1,MPI_INT,imem,4,MPI_COMM_WORLD,ierr)
!                   print *, imem,'send nz ',nz
                   call mpi_send(ngrid_corr,1,MPI_INT,imem,5,MPI_COMM_WORLD,ierr)
!                   print *, imem,'send ngrid_corr ',ngrid_corr
                   call mpi_send(corr_lngth_hz,1,MPI_FLOAT,imem,6,MPI_COMM_WORLD,ierr)
!                   print *, imem,'corr_lngth_hz ',corr_lngth_hz
!
!                   allocate(tmp_arry(nx*ny*(2*ngrid_corr+1)*(2*ngrid_corr+1)))
!                   call apm_pack(tmp_arry,dist,nx,ny,(2*ngrid_corr+1),(2*ngrid_corr+1))
!                   call mpi_send(tmp_arry,nx*ny*(2*ngrid_corr+1)*(2*ngrid_corr+1),MPI_FLOAT,imem,7,MPI_COMM_WORLD,ierr)
!                   deallocate(tmp_arry)
!
                   allocate(tmp_arry(nx*ny*nz*nz))
                   call apm_pack(tmp_arry,A,nx,ny,nz,nz)
                   call mpi_send(tmp_arry,nx*ny*nz*nz,MPI_FLOAT,imem,8,MPI_COMM_WORLD,ierr)
                   deallocate(tmp_arry)
                   call mpi_send(nchem_spcs,1,MPI_INT,imem,9,MPI_COMM_WORLD,ierr)
                   call mpi_send(sw_seed,1,MPI_LOGICAL,imem,10,MPI_COMM_WORLD,ierr)

                   allocate(tmp_arry(nx*ny))
                   call apm_pack_2d(tmp_arry,lat,nx,ny,1,1)
                   call mpi_send(tmp_arry,nx*ny,MPI_FLOAT,imem,51,MPI_COMM_WORLD,ierr)
                   deallocate(tmp_arry)
                   allocate(tmp_arry(nx*ny))
                   call apm_pack_2d(tmp_arry,lon,nx,ny,1,1)
                   call mpi_send(tmp_arry,nx*ny,MPI_FLOAT,imem,52,MPI_COMM_WORLD,ierr)
                   deallocate(tmp_arry)
                   call mpi_send(zfac,1,MPI_FLOAT,imem,53,MPI_COMM_WORLD,ierr)

                enddo
             endif
!
! Get data on each process
             if(rank.ne.0) then
                call mpi_recv(num_mem,1,MPI_INT,0,1,MPI_COMM_WORLD,stat,ierr)
!                print *,rank,'receive num_mem ',num_mem 
                call mpi_recv(nx,1,MPI_INT,0,2,MPI_COMM_WORLD,stat,ierr)
!                print *,rank,'receive nx ',nx 
                call mpi_recv(ny,1,MPI_INT,0,3,MPI_COMM_WORLD,stat,ierr)
!                print *,rank,'receive ny ',ny 
                call mpi_recv(nz,1,MPI_INT,0,4,MPI_COMM_WORLD,stat,ierr)
!                print *,rank,'receive nz ',nz 
                call mpi_recv(ngrid_corr,1,MPI_INT,0,5,MPI_COMM_WORLD,stat,ierr)
!                print *,rank,'receive ngrid_corr ',ngrid_corr 
                call mpi_recv(corr_lngth_hz,1,MPI_FLOAT,0,6,MPI_COMM_WORLD,stat,ierr)
!                print *,rank,'receive corr_lngth_hz ',corr_lngth_hz 
!
!                allocate(dist(nx,ny,2*ngrid_corr+1,2*ngrid_corr+1))
!                dist(:,:,:,:)=0.
                allocate(A(nx,ny,nz,nz))
                A(:,:,:,:)=0.
!                allocate(tmp_arry(nx*ny*(2*ngrid_corr+1)*(2*ngrid_corr+1)))
!                call mpi_recv(tmp_arry,nx*ny*(2*ngrid_corr+1)*(2*ngrid_corr+1),MPI_FLOAT,0,7,MPI_COMM_WORLD,stat,ierr)
!                call apm_unpack(tmp_arry,dist,nx,ny,(2*ngrid_corr+1),(2*ngrid_corr+1))
!                deallocate(tmp_arry)
!
                allocate(tmp_arry(nx*ny*nz*nz))
                call mpi_recv(tmp_arry,nx*ny*nz*nz,MPI_FLOAT,0,8,MPI_COMM_WORLD,stat,ierr)
                call apm_unpack(tmp_arry,A,nx,ny,nz,nz)
                deallocate(tmp_arry)
                call mpi_recv(nchem_spcs,1,MPI_INT,0,9,MPI_COMM_WORLD,stat,ierr)
                call mpi_recv(sw_seed,1,MPI_LOGICAL,0,10,MPI_COMM_WORLD,stat,ierr)

                allocate(lat(nx,ny),lon(nx,ny))
                allocate(tmp_arry(nx*ny))
                call mpi_recv(tmp_arry,nx*ny,MPI_FLOAT,0,51,MPI_COMM_WORLD,stat,ierr)
                call apm_unpack_2d(tmp_arry,lat,nx,ny,1,1)
                deallocate(tmp_arry)
                allocate(tmp_arry(nx*ny))
                call mpi_recv(tmp_arry,nx*ny,MPI_FLOAT,0,52,MPI_COMM_WORLD,stat,ierr)
                call apm_unpack_2d(tmp_arry,lon,nx,ny,1,1)
                deallocate(tmp_arry)
                call mpi_recv(zfac,1,MPI_FLOAT,0,53,MPI_COMM_WORLD,stat,ierr)

             endif
             call mpi_barrier(MPI_COMM_WORLD,ierr)
!
! Calculate new random number seed
             if(num_mem.lt.num_procs-1) then
                print *, 'APM ERROR: NOT ENOUGH PROCESSORS num_mem = ',num_mem, ' procs = ',num_procs-1
                call mpi_finalize(ierr)
                stop
             endif 
             if(sw_seed) call init_random_seed()
!
! If using different random field for each species,
! the species loop goes here
!             do isp=1,nchem_spcs
!
                if(rank.ne.0) then
                   allocate(pert_chem(nx,ny,nz))
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
                   print *,rank,'horizontal correlations'
                   allocate(chem_fac_mem(nx,ny,nz))
                   allocate(wgt_sum(nx,ny,nz))
                   chem_fac_mem(:,:,:)=0.
                   wgt_sum(:,:,:)=0.
                   do i=1,nx
                      do j=1,ny
                         ii_str=max(1,i-ngrid_corr)
                         ii_end=min(nx,i+ngrid_corr)
                         jj_str=max(1,j-ngrid_corr)
                         jj_end=min(ny,j+ngrid_corr)
                         do ii=ii_str,ii_end
                            do jj=jj_str,jj_end
                               zdist=get_dist(lat(ii,jj),lat(i,j),lon(ii,jj),lon(i,j))
                               if(zdist.le.2.0*corr_lngth_hz) then
                                  wgt=1./exp(zdist*zdist/corr_lngth_hz/corr_lngth_hz)
                                  do k=1,nz
                                     wgt_sum(i,j,k)=wgt_sum(i,j,k)+wgt
                                     chem_fac_mem(i,j,k)=chem_fac_mem(i,j,k)+wgt*pert_chem(ii,jj,k)
                                  enddo
                               endif
                            enddo
                         enddo
                         do k=1,nz
                            if(wgt_sum(i,j,k).gt.0) then
                               chem_fac_mem(i,j,k)=chem_fac_mem(i,j,k)/wgt_sum(i,j,k)
                            else
                               chem_fac_mem(i,j,k)=pert_chem(i,j,k)
                            endif                            
                         enddo
                      enddo
                   enddo
!                   deallocate(dist)
                   deallocate(wgt_sum)
                  deallocate(pert_chem)
                   deallocate(lat,lon)
!
! Impose vertical correlations
                   print *,rank,'vertical correlations'
                   allocate(pert_chem_sum(nz))
                   do i=1,nx
                      do j=1,ny
                         pert_chem_sum(:)=0.
                         do k=1,nz
                            do kk=1,nz 
                               pert_chem_sum(k)=pert_chem_sum(k)+A(i,j,k,kk)*chem_fac_mem(i,j,kk)
                            enddo
                         enddo
                         do k=1,nz
                            chem_fac_mem(i,j,k)=pert_chem_sum(k)
                         enddo 
                      enddo
                   enddo
                   deallocate(pert_chem_sum)
                   allocate(tmp_arry(nx*ny*nz))
                   call apm_pack(tmp_arry,chem_fac_mem,nx,ny,nz,1)
                   call mpi_send(tmp_arry,nx*ny*nz,MPI_FLOAT,0,11,MPI_COMM_WORLD,ierr)
                   deallocate(tmp_arry)
                   deallocate(chem_fac_mem)     
                elseif (rank.eq.0) then
                   allocate(tmp_arry(nx*ny*nz))
                   do imem=1,num_mem
                      call mpi_recv(tmp_arry,nx*ny*nz,MPI_FLOAT,imem,11,MPI_COMM_WORLD,stat,ierr)
                      call apm_unpack(tmp_arry,chem_fac(:,:,:,imem),nx,ny,nz,1)
                   enddo
                   deallocate(tmp_arry)
                endif
!
! Recenter about ensemble mean
                if(rank.eq.0) then
                   print *, rank,'recentering '
                   allocate(mems(num_mem),pers(num_mem))             
                   do i=1,nx
                      do j=1,ny
                         do k=1,nz
                            mems(:)=chem_fac(i,j,k,:)
                            mean=sum(mems)/real(num_mem)
                            pers(:)=(mems(:)-mean)*(mems(:)-mean)
                            std=sqrt(sum(pers)/real(num_mem-1))
                            do imem=1,num_mem
                               if(std.ne.0) then
                                  chem_fac(i,j,k,imem)=(chem_fac(i,j,k,imem)-mean)*sprd_chem/std
                               endif 
                            enddo
                         enddo
                      enddo
                   enddo
                   deallocate(mems,pers)
!
! Impose temporal correlations
!                   print *, rank,'temporal correlations '
                   allocate(chem_fac_pr(nx,ny,nz,num_mem))
                   allocate(chem_fac_bc1(nx,ny,nz,num_mem))
                   chem_fac_pr(:,:,:,:)=0.
                   unita=30
                   unitb=40
                   open(unit=unitb,file=trim(pert_path_po)//'/pert_chem_icbc', &
                   form='unformatted',status='unknown')
                   wgt=0.
                   wgt_bc1=0.
                   if (sw_corr_tm) then
                      open(unit=unita,file=trim(pert_path_pr)//'/pert_chem_icbc', &
                      form='unformatted',status='unknown')
                      read(unita) chem_fac_pr
                      wgt=1.-corr_tm_delt/corr_lngth_tm
                      wgt_bc1=1.-corr_tm_delt/2./corr_lngth_tm
                      close(unita)
                   endif
                   chem_fac(:,:,:,:)=wgt*chem_fac_pr(:,:,:,:)+sqrt(1.-wgt*wgt)*chem_fac(:,:,:,:)
                   chem_fac_bc1(:,:,:,:)=wgt_bc1*chem_fac_pr(:,:,:,:)+sqrt(1.-wgt_bc1*wgt_bc1)*chem_fac(:,:,:,:)
                   write(unitb) chem_fac
                   close(unitb)
                   deallocate(chem_fac_pr)
!
! Perturb the members
                   print *, rank,'perturb the IC/BCs '
!
! If using the same random field for each species,
! the species loop goes here
             do isp=1,nchem_spcs
!
                   do imem=1,num_mem
                      if(imem.ge.0.and.imem.lt.10) write(cmem,"('.e00',i1)") imem
                      if(imem.ge.10.and.imem.lt.100) write(cmem,"('.e0',i2)") imem
                      if(imem.ge.100.and.imem.lt.1000) write(cmem,"('.e',i3)") imem
! ICs
                      print *, 'Start ICs mem ',imem               
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
                      print *, 'Finish ICs mem ',imem               
! BCs              
                      allocate(chem_databdy(nx,ny,nz,2))
                      wrfchem_file=trim(wrfbdy_parent)//trim(cmem)
                      do ibdy=1,nbdy_exts
                         ch_spcs=trim(ch_chem_spc(isp))//trim(bdy_exts(ibdy))
                         print *, 'Start BCs mem, spcs ',imem,trim(ch_spcs)               
                         call get_WRFCHEM_icbc_data(wrfchem_file,ch_spcs,chem_databdy,bdy_dims(ibdy),nz,nhalo,nt)
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
                                     if (l.eq.1) then
                                        chem_databdy(ij,k,nij,l)=chem_databdy(ij,k,nij,l)*exp(chem_fac_bc1(i,j,k,imem))
                                     elseif (l.eq.2) then
                                        chem_databdy(ij,k,nij,l)=chem_databdy(ij,k,nij,l)*exp(chem_fac(i,j,k,imem))
                                     endif
                                  enddo
                               enddo
                            enddo
                         enddo
                         call put_WRFCHEM_icbc_data(wrfchem_file,ch_spcs,chem_databdy,bdy_dims(ibdy),nz,nhalo,nt)
                         print *, 'Finish BCs mem, spcs ',imem,trim(ch_spcs)               
                      enddo
                      deallocate(chem_databdy)
                   enddo
             enddo            ! end species loop: same random field for each species
                   deallocate(chem_fac)
                   deallocate(chem_fac_bc1)
                   deallocate(ch_chem_spc)
                else
                   call mpi_finalize(ierr)
                   stop
                endif
!             enddo            ! end species loop: different random field for each species
!
! Close mpi
             call mpi_finalize(ierr)
             stop
          end program main
!
          function get_dist(lat1,lat2,lon1,lon2)
! returns distance in km
             implicit none
             real:: lat1,lat2,lon1,lon2,get_dist
             real:: lon_dif,rtemp,zx,zy
             real:: pi,ang2rad,r_earth
             real:: coef_a,coef_c
             pi=4.*atan(1.0)
             ang2rad=pi/180.
             r_earth=6371.393
! Haversine Code
!             coef_a=sin((lat2-lat1)/2.*ang2rad) * sin((lat2-lat1)/2.*ang2rad) + & 
!             cos(lat1*ang2rad)*cos(lat2*ang2rad) * sin((lon2-lon1)/2.*ang2rad) * &
!             sin((lon2-lon1)/2.*ang2rad)
!             coef_c=2.*atan2(sqrt(coef_a),sqrt(1.-coef_a))
!             get_dist=abs(coef_c*r_earth)
! Equi-rectangular (Pythagorian Formula)
             zx=(lon2-lon1)*ang2rad * cos((lat1+lat2)/2.*ang2rad)
             zy=(lat2-lat1)*ang2rad
             get_dist=r_earth*sqrt(zx*zx + zy*zy)
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
                if(imem.ge.0.and.imem.lt.10) write(cmem,"('.e00',i1)") imem
                if(imem.ge.10.and.imem.lt.100) write(cmem,"('.e0',i2)") imem
                if(imem.ge.100.and.imem.lt.1000) write(cmem,"('.e',i3)") imem
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
             real,dimension(nx,ny,nz,nt)           :: data
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
             real,dimension(nx,ny,nz,nt)           :: data
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
!             print *, 'v_ndim, v_dimid ',v_ndim,v_dimid      
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
             pid = getpid() + 1099279 ! Add a prime
!            call pxfgetpid(pid,ierr) ! pxfgetpid is an Intel routine
             pid = pid + 1099279 ! Add a prime
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
!
          subroutine apm_pack(A_pck,A_unpck,nx,ny,nz,nl)
             implicit none
             integer                      :: nx,ny,nz,nl
             integer                      :: i,j,k,l,idx
             real,dimension(nx,ny,nz,nl)  :: A_unpck
             real,dimension(nx*ny*nz*nl)  :: A_pck
             idx=0
             do l=1,nl
                do k=1,nz
                   do j=1,ny
                      do i=1,nx
                         idx=idx+1
                         A_pck(idx)=A_unpck(i,j,k,l)
                      enddo
                   enddo
                enddo
             enddo
          end subroutine apm_pack
!
          subroutine apm_unpack(A_pck,A_unpck,nx,ny,nz,nl)
             implicit none
             integer                      :: nx,ny,nz,nl
             integer                      :: i,j,k,l,idx
             real,dimension(nx,ny,nz,nl)  :: A_unpck
             real,dimension(nx*ny*nz*nl)  :: A_pck
             idx=0
             do l=1,nl
                do k=1,nz
                   do j=1,ny
                      do i=1,nx
                         idx=idx+1
                         A_unpck(i,j,k,l)=A_pck(idx)
                      enddo
                   enddo
                enddo
             enddo
          end subroutine apm_unpack
!
          subroutine apm_pack_2d(A_pck,A_unpck,nx,ny,nz,nl)
             implicit none
             integer                      :: nx,ny,nz,nl
             integer                      :: i,j,k,l,idx
             real,dimension(nx,ny)        :: A_unpck
             real,dimension(nx*ny)        :: A_pck
             idx=0
             do j=1,ny
                do i=1,nx
                   idx=idx+1
                   A_pck(idx)=A_unpck(i,j)
                enddo
             enddo
          end subroutine apm_pack_2d
!
          subroutine apm_unpack_2d(A_pck,A_unpck,nx,ny,nz,nl)
             implicit none
             integer                      :: nx,ny,nz,nl
             integer                      :: i,j,k,l,idx
             real,dimension(nx,ny)        :: A_unpck
             real,dimension(nx*ny)        :: A_pck
             idx=0
             do j=1,ny
                do i=1,nx
                   idx=idx+1
                   A_unpck(i,j)=A_pck(idx)
                enddo
             enddo
          end subroutine apm_unpack_2d

    
