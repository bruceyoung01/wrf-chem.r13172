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

! code to perturb the wrfchem emission files

          program main
             implicit none
             integer                                  :: i,j,k,num_mem,imem,iimem
             integer                                  :: unit,unita,isp
             integer                                  :: nx,ny,nz,nz_chem,nchem_spc,nfire_spc,nbio_spc
             real                                     :: pi,u_ran_1,u_ran_2,nnum_mem
             real                                     :: sprd_chem,sprd_fire,sprd_biog
             real                                     :: pert_land_chem,pert_watr_chem
             real                                     :: pert_land_fire,pert_watr_fire
             real                                     :: pert_land_biog,pert_watr_biog
             real                                     :: pert_land_chem_d,pert_watr_chem_d
             real                                     :: pert_land_fire_d,pert_watr_fire_d
             real                                     :: pert_land_biog_d,pert_watr_biog_d
             real                                     :: pert_land_chem_m,pert_watr_chem_m
             real                                     :: pert_land_fire_m,pert_watr_fire_m
             real                                     :: pert_land_biog_m,pert_watr_biog_m
             real,allocatable,dimension(:,:)           :: xland
             real,allocatable,dimension(:,:)          :: chem_data2d
             real,allocatable,dimension(:,:,:)        :: chem_data3d
             character(len=20)                        :: cmem
             character(len=150)                       :: pert_path
             character(len=150)                       :: wrfchemi,wrffirechemi,wrfbiochemi
             character(len=150)                       :: wrfchem_file,wrffire_file,wrfbio_file
             character(len=150),allocatable,dimension(:) :: ch_chem_spc 
             character(len=150),allocatable,dimension(:) :: ch_fire_spc 
             character(len=150),allocatable,dimension(:) :: ch_bio_spc 
             logical                                  :: sw_gen,sw_chem,sw_fire,sw_biog
             namelist /perturb_chem_emiss_CORR_nml/nx,ny,nz,nz_chem,nchem_spc,nfire_spc,nbio_spc, &
             pert_path,nnum_mem,wrfchemi,wrffirechemi,wrfbiochemi,sprd_chem,sprd_fire,sprd_biog, &
             sw_gen,sw_chem,sw_fire,sw_biog
             namelist /perturb_chem_emiss_spec_nml/ch_chem_spc,ch_fire_spc,ch_bio_spc
!
! Assign constants
             pi=4.*atan(1.)
             pert_land_chem=-9999
             pert_watr_chem=-9999
             pert_land_fire=-9999
             pert_watr_fire=-9999
             pert_land_biog=-9999
             pert_watr_biog=-9999
!
! Read namelist
             unit=20
             open(unit=unit,file='perturb_chem_emiss_CORR_nml.nl',form='formatted', &
             status='old',action='read')
             read(unit,perturb_chem_emiss_CORR_nml)
             close(unit)
!
             print *, 'nx                ',nx
             print *, 'ny                ',ny
             print *, 'nz                ',nz
             print *, 'nz_chem           ',nz_chem
             print *, 'nchem_spc         ',nchem_spc
             print *, 'nfire_spc         ',nfire_spc
             print *, 'nbio_spc          ',nbio_spc
             print *, 'pert_path         ',trim(pert_path)
             print *, 'num_mem           ',nnum_mem
             print *, 'wrfchemi          ',trim(wrfchemi)
             print *, 'wrffirechemi      ',trim(wrffirechemi)
             print *, 'wrfbiochemi       ',trim(wrfbiochemi)
             print *, 'sprd_chem         ',sprd_chem
             print *, 'sprd_fire         ',sprd_fire
             print *, 'sprd_biog         ',sprd_biog
             print *, 'sw_gen            ',sw_gen
             print *, 'sw_chem           ',sw_chem
             print *, 'sw_fire           ',sw_fire
             print *, 'sw_biog           ',sw_biog
             num_mem=nint(nnum_mem)
             allocate(ch_chem_spc(nchem_spc),ch_fire_spc(nfire_spc),ch_bio_spc(nbio_spc))
!
             unit=20
             open(unit=unit,file='perturb_emiss_chem_spec_nml.nl',form='formatted', &
             status='old',action='read')
             read(unit,perturb_chem_emiss_spec_nml)
             close(unit)
!             print *, 'ch_chem_spc       ',ch_chem_spc
!             print *, 'ch_fire_spc       ',ch_fire_spc
!             print *, 'ch_bio_spc        ',ch_bio_spc
!
             unita=30
             open(unit=unita,file=trim(pert_path)//'/pert_file_emiss',form='unformatted', &
             status='unknown')
!
! Get the land mask data
             print *, 'At read for xland'
             allocate(xland(nx,ny))
             call get_WRFINPUT_land_mask(xland,nx,ny)
!
! Allocate arrays
             allocate(chem_data3d(nx,ny,nz_chem),chem_data2d(nx,ny))
!
             do iimem=1,num_mem,2
                if(sw_gen) then
                   do while (pert_land_chem.le.-1 .or. pert_land_chem.ge.1)
                      call random_number(u_ran_1)
                      if(u_ran_1.eq.0.) call random_number(u_ran_1)
                      call random_number(u_ran_2)
                      if(u_ran_2.eq.0.) call random_number(u_ran_2)
                      pert_land_chem=sqrt(-2.*log(u_ran_1))*cos(2.*pi*u_ran_2)*sprd_chem
                   end do
                   do while (pert_watr_chem.le.-1 .or. pert_watr_chem.ge.1)
                      call random_number(u_ran_1)
                      if(u_ran_1.eq.0.) call random_number(u_ran_1)
                      call random_number(u_ran_2)
                      if(u_ran_2.eq.0.) call random_number(u_ran_2)
                      pert_watr_chem=sqrt(-2.*log(u_ran_1))*cos(2.*pi*u_ran_2)*sprd_chem
                   end do
                   do while (pert_land_fire.le.-1 .or. pert_land_fire.ge.1)
                      call random_number(u_ran_1)
                      if(u_ran_1.eq.0.) call random_number(u_ran_1)
                      call random_number(u_ran_2)
                      if(u_ran_2.eq.0.) call random_number(u_ran_2)
                      pert_land_fire=sqrt(-2.*log(u_ran_1))*cos(2.*pi*u_ran_2)*sprd_fire
                   end do
                   do while (pert_watr_fire.le.-1 .or. pert_watr_fire.ge.1)
                      call random_number(u_ran_1)
                      if(u_ran_1.eq.0.) call random_number(u_ran_1)
                      call random_number(u_ran_2)
                      if(u_ran_2.eq.0.) call random_number(u_ran_2)
                      pert_watr_fire=sqrt(-2.*log(u_ran_1))*cos(2.*pi*u_ran_2)*sprd_fire
                   end do
                   do while (pert_land_biog.le.-1 .or. pert_land_biog.ge.1)
                      call random_number(u_ran_1)
                      if(u_ran_1.eq.0.) call random_number(u_ran_1)
                      call random_number(u_ran_2)
                      if(u_ran_2.eq.0.) call random_number(u_ran_2)
                      pert_land_biog=sqrt(-2.*log(u_ran_1))*cos(2.*pi*u_ran_2)*sprd_biog
                   end do
                   do while (pert_watr_biog.le.-1 .or. pert_watr_biog.ge.1)
                      call random_number(u_ran_1)
                      if(u_ran_1.eq.0.) call random_number(u_ran_1)
                      call random_number(u_ran_2)
                      if(u_ran_2.eq.0.) call random_number(u_ran_2)
                      pert_watr_biog=sqrt(-2.*log(u_ran_1))*cos(2.*pi*u_ran_2)*sprd_biog
                   end do
                   print *, 'At emiss pert write ',iimem
                   pert_land_chem_d=pert_land_chem
                   pert_watr_chem_d=pert_watr_chem
                   pert_land_fire_d=pert_land_fire
                   pert_watr_fire_d=pert_watr_fire
                   pert_land_biog_d=pert_land_biog
                   pert_watr_biog_d=pert_watr_biog
                   pert_land_chem_m=-1.*pert_land_chem
                   pert_watr_chem_m=-1.*pert_watr_chem
                   pert_land_fire_m=-1.*pert_land_fire
                   pert_watr_fire_m=-1.*pert_watr_fire
                   pert_land_biog_m=-1.*pert_land_biog
                   pert_watr_biog_m=-1.*pert_watr_biog
                   write(unita) pert_land_chem_d,pert_watr_chem_d,pert_land_fire_d,pert_watr_fire_d, &
                   pert_land_biog_d,pert_watr_biog_d
                   write(unita) pert_land_chem_m,pert_watr_chem_m,pert_land_fire_m, &
                   pert_watr_fire_m,pert_land_biog_m,pert_watr_biog_m
                else
                   print *, 'At emiss pert read ',iimem
                   read(unita) pert_land_chem_d,pert_watr_chem_d,pert_land_fire_d,pert_watr_fire_d, &
                   pert_land_biog_d,pert_watr_biog_d
                   read(unita) pert_land_chem_m,pert_watr_chem_m,pert_land_fire_m, &
                   pert_watr_fire_m,pert_land_biog_m,pert_watr_biog_m
                endif 
                print *, pert_land_chem_d,pert_watr_chem_d
                print *, pert_land_chem_m,pert_watr_chem_m
                print *, pert_land_fire_d,pert_watr_fire_d
                print *, pert_land_fire_m,pert_watr_fire_m
                print *, pert_land_biog_d,pert_watr_biog_d
                print *, pert_land_biog_m,pert_watr_biog_m
!
                if(sw_chem) then
!
! draw member
                   imem=iimem
                   if(imem.ge.0.and.imem.lt.10) write(cmem,"('.e00',i1)") imem
                   if(imem.ge.10.and.imem.lt.100) write(cmem,"('.e0',i2)") imem
                   if(imem.ge.100.and.imem.lt.1000) write(cmem,"('.e',i3)") imem
                   wrfchem_file=trim(wrfchemi)//trim(cmem)
                   do isp=1,nchem_spc
!                      print *, 'pert_land ',pert_land_chem_d
!                      print *, 'pert_watr ',pert_watr_chem_d
!                      print *, 'isp ',isp,trim(ch_chem_spc(isp))
                      print *, 'file ',trim(wrfchem_file)
                      call get_WRFCHEM_emiss_data(wrfchem_file,ch_chem_spc(isp),chem_data3d,nx,ny,nz_chem)
                      do i=1,nx
                         do j=1,ny
                            if(xland(i,j).eq.1) then
                               chem_data3d(i,j,1:nz_chem)=(1.+pert_land_chem_d)*chem_data3d(i,j,1:nz_chem)
                            else
                               chem_data3d(i,j,1:nz_chem)=(1.+pert_watr_chem_d)*chem_data3d(i,j,1:nz_chem)
                            endif
                         enddo
                      enddo  
                      call put_WRFCHEM_emiss_data(wrfchem_file,ch_chem_spc(isp),chem_data3d,nx,ny,nz_chem)
                   enddo
!
! mirror member
                   imem=iimem+1
                   if(sw_gen) then
                      pert_land_chem=-1.*pert_land_chem
                      pert_watr_chem=-1.*pert_watr_chem
                   endif
                   if(imem.ge.0.and.imem.lt.10) write(cmem,"('.e00',i1)") imem
                   if(imem.ge.10.and.imem.lt.100) write(cmem,"('.e0',i2)") imem
                   if(imem.ge.100.and.imem.lt.1000) write(cmem,"('.e',i3)") imem
                   wrfchem_file=trim(wrfchemi)//trim(cmem)
                   do isp=1,nchem_spc
                      call get_WRFCHEM_emiss_data(wrfchem_file,ch_chem_spc(isp),chem_data3d,nx,ny,nz_chem)
                      do i=1,nx
                         do j=1,ny
                            if(xland(i,j).eq.1) then
                               chem_data3d(i,j,1:nz_chem)=(1.+pert_land_chem_m)*chem_data3d(i,j,1:nz_chem)
                            else
                               chem_data3d(i,j,1:nz_chem)=(1.+pert_watr_chem_m)*chem_data3d(i,j,1:nz_chem)
                            endif
                         enddo
                      enddo  
                      call put_WRFCHEM_emiss_data(wrfchem_file,ch_chem_spc(isp),chem_data3d,nx,ny,nz_chem)
                   enddo
                endif
!
                if(sw_fire) then
!
! draw member
                   imem=iimem
                   if(imem.ge.0.and.imem.lt.10) write(cmem,"('.e00',i1)") imem
                   if(imem.ge.10.and.imem.lt.100) write(cmem,"('.e0',i2)") imem
                   if(imem.ge.100.and.imem.lt.1000) write(cmem,"('.e',i3)") imem
                   wrffire_file=trim(wrffirechemi)//trim(cmem)
                   do isp=1,nfire_spc
                      call get_WRFCHEM_emiss_data(wrffire_file,ch_fire_spc(isp),chem_data2d,nx,ny,1)
                      do i=1,nx
                         do j=1,ny
                            if(xland(i,j).eq.1) then
                               chem_data2d(i,j)=(1.+pert_land_fire_d)*chem_data2d(i,j)
                            else
                               chem_data2d(i,j)=(1.+pert_watr_fire_d)*chem_data2d(i,j)
                            endif
                         enddo
                      enddo  
                      call put_WRFCHEM_emiss_data(wrffire_file,ch_fire_spc(isp),chem_data2d,nx,ny,1)
                   enddo
!
! mirror member
                   imem=iimem+1
                   if(sw_gen) then
                      pert_land_fire=-1.*pert_land_fire
                      pert_watr_fire=-1.*pert_watr_fire
                   endif
                   if(imem.ge.0.and.imem.lt.10) write(cmem,"('.e00',i1)") imem
                   if(imem.ge.10.and.imem.lt.100) write(cmem,"('.e0',i2)") imem
                   if(imem.ge.100.and.imem.lt.1000) write(cmem,"('.e',i3)") imem
                   wrffire_file=trim(wrffirechemi)//trim(cmem)
                   do isp=1,nfire_spc
                      call get_WRFCHEM_emiss_data(wrffire_file,ch_fire_spc(isp),chem_data2d,nx,ny,1)
                      do i=1,nx
                         do j=1,ny
                            if(xland(i,j).eq.1) then
                               chem_data2d(i,j)=(1.+pert_land_fire_m)*chem_data2d(i,j)
                            else
                               chem_data2d(i,j)=(1.+pert_watr_fire_m)*chem_data2d(i,j)
                            endif
                         enddo
                      enddo  
                      call put_WRFCHEM_emiss_data(wrffire_file,ch_fire_spc(isp),chem_data2d,nx,ny,1)
                   enddo
                endif
!
                if(sw_biog) then
!
! draw member
                   imem=iimem
                   if(imem.ge.0.and.imem.lt.10) write(cmem,"('.e00',i1)") imem
                   if(imem.ge.10.and.imem.lt.100) write(cmem,"('.e0',i2)") imem
                   if(imem.ge.100.and.imem.lt.1000) write(cmem,"('.e',i3)") imem
                   wrfbio_file=trim(wrfbiochemi)//trim(cmem)
                   do isp=1,nbio_spc
                      call get_WRFCHEM_emiss_data(wrfbio_file,ch_bio_spc(isp),chem_data2d,nx,ny,1)
                      do i=1,nx
                         do j=1,ny
                            if(xland(i,j).eq.1) then
                               chem_data2d(i,j)=(1.+pert_land_biog_d)*chem_data2d(i,j)
                            else
                               chem_data2d(i,j)=(1.+pert_watr_biog_d)*chem_data2d(i,j)
                            endif
                         enddo
                      enddo  
                      call put_WRFCHEM_emiss_data(wrfbio_file,ch_bio_spc(isp),chem_data2d,nx,ny,1)
                   enddo
!
! mirror member
                   imem=iimem+1
                   if(sw_gen) then
                      pert_land_biog=-1.*pert_land_biog
                      pert_watr_biog=-1.*pert_watr_biog
                   endif
                   if(imem.ge.0.and.imem.lt.10) write(cmem,"('.e00',i1)") imem
                   if(imem.ge.10.and.imem.lt.100) write(cmem,"('.e0',i2)") imem
                   if(imem.ge.100.and.imem.lt.1000) write(cmem,"('.e',i3)") imem
                   wrfbio_file=trim(wrfbiochemi)//trim(cmem)
                   do isp=1,nbio_spc
                      call get_WRFCHEM_emiss_data(wrfbio_file,ch_bio_spc(isp),chem_data2d,nx,ny,1)
                      do i=1,nx
                         do j=1,ny
                            if(xland(i,j).eq.1) then
                               chem_data2d(i,j)=(1.+pert_land_biog_m)*chem_data2d(i,j)
                            else
                               chem_data2d(i,j)=(1.+pert_watr_biog_m)*chem_data2d(i,j)
                            endif
                         enddo
                      enddo  
                      call put_WRFCHEM_emiss_data(wrfbio_file,ch_bio_spc(isp),chem_data2d,nx,ny,1)
                   enddo
                endif
                pert_land_chem=-9999
                pert_watr_chem=-9999
                pert_land_fire=-9999
                pert_watr_fire=-9999
                pert_land_biog=-9999
                pert_watr_biog=-9999
             enddo
!
! Deallocate arrays
             deallocate(ch_chem_spc,ch_fire_spc,ch_bio_spc)
             deallocate(chem_data3d,chem_data2d,xland)
             close(unita)
          end program main
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
             if(nx.ne.v_dim(1)) then
                print *, 'ERROR: nx dimension conflict ',nx,v_dim(1)
                call abort
             else if(ny.ne.v_dim(2)) then
                print *, 'ERROR: ny dimension conflict ',ny,v_dim(2)
                call abort
             else if(1.ne.v_dim(3)) then             
                print *, 'ERROR: nz dimension conflict ','1',v_dim(3)
                call abort
!             else if(1.ne.v_dim(4)) then             
!                print *, 'ERROR: time dimension conflict ',1,v_dim(4)
!                call abort
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
          subroutine get_WRFCHEM_emiss_data(file,name,data,nx,ny,nz_chem)
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
             rc = nf_open(trim(file),NF_SHARE,f_id)
!             print *, trim(file)
             if(rc.ne.0) then
                print *, 'nf_open error in get ',rc, trim(file)
                call abort
             endif
!
! get variables identifiers
             rc = nf_inq_varid(f_id,trim(name),v_id)
!             print *, v_id
             print *, trim(name)
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
! get data
             one(:)=1
             rc = nf_get_vara_real(f_id,v_id,one,v_dim,data)
             if(rc.ne.0) then
                print *, 'nf_get_vara_real ', data(1,1,1)
                call abort
             endif
             rc = nf_close(f_id)
             return
          end subroutine get_WRFCHEM_emiss_data   
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
                print *, 'nf_open error in put ',rc, trim(file)
                call abort
             endif
!             print *, 'f_id ',f_id
!
! get variables identifiers
             rc = nf_inq_varid(f_id,trim(name),v_id)
!             print *, v_id
             if(rc.ne.0) then
                print *, 'nf_inq_varid error ', v_id
                call abort
             endif
!             print *, 'v_id ',v_id
!
! get dimension identifiers
             v_dimid=0
             rc = nf_inq_var(f_id,v_id,v_nam,typ,v_ndim,v_dimid,natts)
!             print *, v_dimid
             if(rc.ne.0) then
                print *, 'nf_inq_var error ', v_dimid
                call abort
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
!             rc = nf_close(f_id)
!             rc = nf_open(trim(file),NF_WRITE,f_id)
             rc = nf_put_vara_real(f_id,v_id,one(1:v_ndim),v_dim(1:v_ndim),data)
             if(rc.ne.0) then
                print *, 'nf_put_vara_real return code ',rc
                print *, 'f_id,v_id ',f_id,v_id
                print *, 'one ',one(1:v_ndim)
                print *, 'v_dim ',v_dim(1:v_ndim)
                call abort
             endif
             rc = nf_close(f_id)
             return
          end subroutine put_WRFCHEM_emiss_data   
