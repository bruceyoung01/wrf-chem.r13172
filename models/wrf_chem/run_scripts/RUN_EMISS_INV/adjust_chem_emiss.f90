!
! code to adjust emissions at subsequent times
!
! ifort -C adjust_chem_emiss.f90 -o adjust_chem_emiss.exe -I$NETCDF_DIR/include -L$NETCDF_DIR/lib -lnetcdff -lnetcdf
!
          program main
             implicit none
             integer,parameter                         :: mchemi_emiss=2
             integer,parameter                         :: mfirechemi_emiss=7

             integer                                   :: nx,ny,nz,nz_chemi,nz_firechemi
             integer                                   :: nchemi_emiss,nfirechemi_emiss
             integer                                   :: i,j,k,emiss
             integer                                   :: unit
             real                                      :: fac,facc,delt
             real,allocatable,dimension(:,:,:)         :: emiss_chemi_prior,emiss_chemi_post
             real,allocatable,dimension(:,:,:)         :: emiss_chemi_old,emiss_chemi_new
             real,allocatable,dimension(:,:,:)         :: emiss_firechemi_prior,emiss_firechemi_post
             real,allocatable,dimension(:,:,:)         :: emiss_firechemi_old,emiss_firechemi_new
             character(len=150)                        :: wrfchemi_prior,wrfchemi_post
             character(len=150)                        :: wrfchemi_old,wrfchemi_new
             character(len=150)                        :: wrffirechemi_prior,wrffirechemi_post
             character(len=150)                        :: wrffirechemi_old,wrffirechemi_new
             character(len=20),dimension(mchemi_emiss) :: chemi_emiss
             character(len=20),dimension(mfirechemi_emiss) :: firechemi_emiss
             namelist /adjust_chem_emiss/fac,facc,nx,ny,nz,nz_chemi,nz_firechemi,nchemi_emiss, &
             nfirechemi_emiss,wrfchemi_prior,wrfchemi_post,wrfchemi_old,wrfchemi_new, &
             wrffirechemi_prior,wrffirechemi_post,wrffirechemi_old,wrffirechemi_new
!
! Read namelist
             unit=20
             open(unit=unit,file='adjust_chem_emiss.nml',form='formatted', &
             status='old',action='read')
             read(unit,adjust_chem_emiss)
             close(unit)
             print *, 'fac                     ',fac
             print *, 'facc                    ',facc
             print *, 'ny                      ',ny
             print *, 'nz                      ',nz
             print *, 'nz_chemi                ',nz_chemi
             print *, 'nz_firechemi            ',nz_firechemi
             print *, 'nchemi_emiss            ',nchemi_emiss
             print *, 'nfirechemi_emiss        ',nfirechemi_emiss
             print *, 'wrfchemi_prior          ',trim(wrfchemi_prior)
             print *, 'wrfchemi_post           ',trim(wrfchemi_post)
             print *, 'wrfchemi_old            ',trim(wrfchemi_old)
             print *, 'wrfchemi_new            ',trim(wrfchemi_new)
             print *, 'wrffirechemi_prior      ',trim(wrffirechemi_prior)
             print *, 'wrffirechemi_post       ',trim(wrffirechemi_post)
             print *, 'wrffirechemi_old        ',trim(wrffirechemi_old)
             print *, 'wrffirechemi_new        ',trim(wrffirechemi_new)
             if(nchemi_emiss.ne.mchemi_emiss .or. nfirechemi_emiss.ne.mfirechemi_emiss) then
                print *,'APM: ERROR - Emissions dimension mismatch '
                stop
             endif
!
! Allocate arrays
             allocate (emiss_chemi_prior(nx,ny,nz_chemi),emiss_chemi_post(nx,ny,nz_chemi))
             allocate (emiss_chemi_old(nx,ny,nz_chemi),emiss_chemi_new(nx,ny,nz_chemi))
             allocate (emiss_firechemi_prior(nx,ny,nz_firechemi),emiss_firechemi_post(nx,ny,nz_firechemi))
             allocate (emiss_firechemi_old(nx,ny,nz_firechemi),emiss_firechemi_new(nx,ny,nz_firechemi))
!
! multiplier to damp the emissions update at the cycle time and after the cycle time 
! when based on an emissions factor
!             fac=0.
!
! multiplier to damp the emission update at forecast times after the cycle time 
! when based on the tendency (in this case the emissions factor correction does not
! work because the denominator - the prior - is zero
!             facc=0.
!
             print *, 'APM Adjust chem emissions '
             chemi_emiss(1)='E_CO'
             chemi_emiss(2)='E_NO'
             firechemi_emiss(1)='ebu_in_co'
             firechemi_emiss(2)='ebu_in_no'
             firechemi_emiss(3)='ebu_in_oc'
             firechemi_emiss(4)='ebu_in_bc'
             firechemi_emiss(5)='ebu_in_c2h4'
             firechemi_emiss(6)='ebu_in_ch2o'
             firechemi_emiss(7)='ebu_in_ch3oh'
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
! ADJUST CYCLE TIME EMISSIONS (This block damps the DART-based adjustment
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
! ( _prior and _post are the cycle-time DART-adjusted files )
! ( _old and _new are the forecast-time files that are to be adjusted)
!
! Loop through wrfchemi emissions to update
             do emiss=1,nchemi_emiss
                emiss_chemi_prior(:,:,:)=0.
                emiss_chemi_post(:,:,:)=0.
                emiss_chemi_new(:,:,:)=0.
                call get_WRFCHEM_emiss_data(wrfchemi_prior,chemi_emiss(emiss), &
                emiss_chemi_prior,nx,ny,nz_chemi)
                call get_WRFCHEM_emiss_data(wrfchemi_post,chemi_emiss(emiss), &
                emiss_chemi_post,nx,ny,nz_chemi)
                emiss_chemi_old(:,:,:)=emiss_chemi_prior(:,:,:)
                do i=1,nx
                   do j=1,ny
                      do k=1,nz_chemi
                         emiss_chemi_new(i,j,k)=emiss_chemi_old(i,j,k)+ &
                         fac*(emiss_chemi_post(i,j,k)-emiss_chemi_prior(i,j,k))
                      enddo
                   enddo  
                   call put_WRFCHEM_emiss_data(wrfchemi_post,chemi_emiss(emiss), &
                   emiss_chemi_new,nx,ny,nz_chemi)
                enddo
             enddo
!
! Loop through wrffirechemi emissions to update 
             do emiss=1,nfirechemi_emiss
                emiss_firechemi_prior(:,:,:)=0.
                emiss_firechemi_post(:,:,:)=0.
                emiss_firechemi_new(:,:,:)=0.
                call get_WRFCHEM_emiss_data(wrffirechemi_prior,firechemi_emiss(emiss), &
                emiss_firechemi_prior,nx,ny,nz_firechemi)
                call get_WRFCHEM_emiss_data(wrffirechemi_post,firechemi_emiss(emiss), &
                emiss_firechemi_post,nx,ny,nz_firechemi)
                emiss_firechemi_old(:,:,:)=emiss_firechemi_prior(:,:,:)
                do i=1,nx
                   do j=1,ny
                      do k=1,nz_firechemi
                         emiss_firechemi_new(i,j,k)=emiss_firechemi_old(i,j,k)+ &
                         fac*(emiss_firechemi_post(i,j,k)-emiss_firechemi_prior(i,j,k))
                      enddo
                   enddo  
                   call put_WRFCHEM_emiss_data(wrffirechemi_post,firechemi_emiss(emiss), &
                   emiss_firechemi_new,nx,ny,nz_firechemi)
                enddo
             enddo
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
! ADJUST INTRA-CYCLE TIME EMISSIONS (This block applies the damped 
! DART-based adjustment to the intra-cycle time emissions files
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
! ( _prior and _post are the cycle-time DART-adjusted files )
! ( _old and _new are the forecast-time files that are to be adjusted)
!
! Loop through wrfchemi emissions to update 
             do emiss=1,nchemi_emiss
                emiss_chemi_prior(:,:,:)=0.
                emiss_chemi_post(:,:,:)=0.
                emiss_chemi_old(:,:,:)=0.
                emiss_chemi_new(:,:,:)=0.
                call get_WRFCHEM_emiss_data(wrfchemi_prior,chemi_emiss(emiss), &
                emiss_chemi_prior,nx,ny,nz_chemi)
                call get_WRFCHEM_emiss_data(wrfchemi_post,chemi_emiss(emiss), &
                emiss_chemi_post,nx,ny,nz_chemi)
                call get_WRFCHEM_emiss_data(wrfchemi_old,chemi_emiss(emiss), &
                emiss_chemi_old,nx,ny,nz_chemi)
                do i=1,nx
                   do j=1,ny
                      do k=1,nz_chemi
                         if(emiss_chemi_prior(i,j,k).ne.0.) then
                            emiss_chemi_new(i,j,k)=emiss_chemi_old(i,j,k)* &
                            (1.+facc*((emiss_chemi_post(i,j,k)-emiss_chemi_prior(i,j,k))/ &
                            emiss_chemi_prior(i,j,k)))
!                            if(emiss_chemi_new(i,j,k).lt.0.) emiss_chemi_new(i,j,k)=0.
                         else
                            delt=emiss_chemi_post(i,j,k)-emiss_chemi_prior(i,j,k)
                            emiss_chemi_new(i,j,k)=emiss_chemi_old(i,j,k)+facc*delt
!                            if(emiss_chemi_new(i,j,k).lt.0.) emiss_chemi_new(i,j,k)=0.
!                            print *, 'APM: EMISS ADJUST - tendency method ',chemi_emiss(emiss)
                         endif
                      enddo
                   enddo  
                   call put_WRFCHEM_emiss_data(wrfchemi_new,chemi_emiss(emiss), &
                   emiss_chemi_new,nx,ny,nz_chemi)
                enddo
             enddo
!
! Loop through wrffirechemi emissions to update 
             do emiss=1,nfirechemi_emiss
                emiss_firechemi_prior(:,:,:)=0.
                emiss_firechemi_post(:,:,:)=0.
                emiss_firechemi_old(:,:,:)=0.
                emiss_firechemi_new(:,:,:)=0.
                call get_WRFCHEM_emiss_data(wrffirechemi_prior,firechemi_emiss(emiss), &
                emiss_firechemi_prior,nx,ny,nz_firechemi)
                call get_WRFCHEM_emiss_data(wrffirechemi_post,firechemi_emiss(emiss), &
                emiss_firechemi_post,nx,ny,nz_firechemi)
                call get_WRFCHEM_emiss_data(wrffirechemi_old,firechemi_emiss(emiss), &
                emiss_firechemi_old,nx,ny,nz_firechemi)
                do i=1,nx
                   do j=1,ny
                      do k=1,nz_firechemi
                         if(emiss_firechemi_prior(i,j,k).ne.0.) then
                            emiss_firechemi_new(i,j,k)=emiss_firechemi_old(i,j,k)* &
                            (1.+facc*((emiss_firechemi_post(i,j,k)-emiss_firechemi_prior(i,j,k))/ &
                            emiss_firechemi_prior(i,j,k)))
!                            if(emiss_firechemi_new(i,j,k).lt.0.) emiss_firechemi_new(i,j,k)=0.
                         else
                            delt=emiss_firechemi_post(i,j,k)-emiss_firechemi_prior(i,j,k)
                            emiss_firechemi_new(i,j,k)=emiss_firechemi_old(i,j,k)+facc*delt
!                            if(emiss_firechemi_new(i,j,k).lt.0.) emiss_firechemi_new(i,j,k)=0.
!                            print *, 'APM: EMISS ADJUST - tendency method ',firechemi_emiss(emiss)
                         endif
                      enddo
                   enddo  
                   call put_WRFCHEM_emiss_data(wrffirechemi_new,firechemi_emiss(emiss), &
                   emiss_firechemi_new,nx,ny,nz_firechemi)
                enddo
             enddo
!
             deallocate (emiss_chemi_prior,emiss_chemi_post)
             deallocate (emiss_chemi_old,emiss_chemi_new)
             deallocate (emiss_firechemi_prior,emiss_firechemi_post)
             deallocate (emiss_firechemi_old,emiss_firechemi_new)
!
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




