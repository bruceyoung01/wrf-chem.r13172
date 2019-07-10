!
! Code to read ubvals_b40.20th.track1_1996-2005.nc or exo_coldens_dXX 
! for forward operators with averaging kernel vertical profiles that 
! go above the WRF-Chem model top
!
! ifort -C wrf_dart_ubval_interp.f90 -o wrf_dart_ubval_interp.exe -lncarg -lncarg_gks -lncarg_c -lX11 -lXext -lcairo -lfontconfig -lpixman-1 -lfreetype -lexpat -lpng -lz -lpthread -lbz2 -lXrender -lgfortran -lnetcdff -lnetcdf
!
program main
   implicit none
   integer               :: domain
   character*(180)       :: species
   real                  :: lat,lon,lev
   real                  :: obs_val
!
   domain=01
   species='O3'
   species='CO'
   lat=40.
   lon=-110.
   lev=750.
!
   call wrf_dart_ubval_interp(obs_val,domain,species,lon,lat,lev)
!
   print *, 'obs_val ',obs_val

!
end program main
!
subroutine wrf_dart_ubval_interp(obs_val,domain,species,lon,lat,lev)
   use netcdf
   implicit none
   integer,parameter                              :: ny1=96,nz1=38,nm1=12,nmspc1=8,nchr1=20
   integer,parameter                              :: nx2=179,ny2=139,nz2=66,nm2=12
   integer                                        :: fid1,fid2,domain,rc,im2
   integer                                        :: i,j,k,ichr
   integer,dimension(nm1)                         :: month
   character*(180)                                :: species,file,file_in1,file_in2,path
   character*(180),dimension(nchr1,nmspc1)        :: spec_nam    
   character*(180),dimension(ny1,nmspc1,nm1,nz1)  :: dmy_chr1
   character*(180),dimension(nx2,ny2,nz2,nm2)     :: dmy_chr2
   real                                           :: lon,lat,lev
   real                                           :: obs_val    
   real,dimension(ny1)                            :: xlat1
   real,dimension(nz1)                            :: xlev1,prs_tmp1
   real,dimension(ny1,nmspc1,nm1,nz1)             :: vmr_xx
   real,dimension(ny1,nmspc1,nm1,nz1)             :: dmy_real1
   real,dimension(nx2,ny2)                        :: xlat2,xlon2
   real,dimension(nz2)                            :: xlev2,prs_tmp2
   real,dimension(nm2)                            :: ddoyr
   real,dimension(nx2,ny2,nz2,nm2)                :: o3_col_dens
!
! assign upper boundary profile files
   path='/glade/scratch/mizzi/real_FRAPPE_v3.6.1_gabi_histo/2014071400/wrfchem_initial/run_e001/'
!
! this file has O3 NOX HNO3 CH4 CO N2) N2O5 H20
   file_in1='ubvals_b40.20th.track1_1996-2005.nc'
!
! this file has o3 only 
   file_in2='exo_coldens_d01'
   if(domain.eq.2) then
      file_in2='exo_coldens_d02'
   endif
!
! open upper boundary profile files
   file=trim(path)//trim(file_in1)
   rc = nf90_open(trim(file),NF90_NOWRITE,fid1)
   if(rc.ne.0) then
      print *, 'APM: nc_open error file=',trim(file)
      call abort
   endif
!
   file=trim(path)//trim(file_in2)
   rc = nf90_open(trim(file),NF90_NOWRITE,fid2)
   if(rc.ne.0) then
      print *, 'APM: nc_open error file=',trim(file)
      call abort
   endif
!
! set character flag
   ichr=0
!
! select upper boundary data from ubvals_b40.20th.track1_1996-2005.nc
   if(trim(species).eq.'CO') then
      call get_netcdf_data(fid1,'lat',xlat1,dmy_chr1,ny1,1,1,1,ichr)
      print *, 'XLAT',xlat1(1),xlat1(ny1)
      call get_netcdf_data(fid1,'lev',xlev1,dmy_chr1,nz1,1,1,1,ichr)
      print *, 'XLEV',xlev1(1),xlev1(nz1)
      call get_netcdf_data(fid1,'month',month,dmy_chr1,nm1,1,1,1,ichr)
      ichr=1
      print *, 'MONTH',month(1),month(nm1)
      call get_netcdf_data(fid1,'specname',dmy_real1,spec_nam,nchr1,nmspc1,1,1,ichr)
      ichr=0
      print *, 'SPEC_NAM',trim(spec_nam(1,1)),trim(spec_nam(nchr1,nmspc1))
      call get_netcdf_data(fid1,'vmr',vmr_xx,ny1,nmspc1,dmy_chr1,nm1,nz1,ichr)
      print *, 'VMR_XX',vmr_xx(1,1,1,1),vmr_xx(ny1,nmspc1,nm1,nz1)
      rc=nf90_close(fid1)
   endif
!
! select upper boundary data from exo_coldens_dxx
   if(trim(species).eq.'O3') then
!
! read data exo_coldens
      call get_netcdf_data(fid2,'XLAT',xlat2,dmy_chr2,nx2,ny2,1,1,ichr)
!      print *, 'XLAT',xlat2(1,1),xlat2(nx2,ny2)
      call get_netcdf_data(fid2,'XLONG',xlon2,dmy_chr2,nx2,ny2,1,1,ichr)
!      print *, 'XLON',xlon2(1,1),xlon2(nx2,ny2)
      call get_netcdf_data(fid2,'coldens_levs',xlev2,dmy_chr2,nz2,1,1,1,ichr)
!      print *, 'coldens_levs',xlev2(:)
      call get_netcdf_data(fid2,'days_of_year',ddoyr,dmy_chr2,nm2,1,1,1,ichr)
!      print *, 'ddoyr',ddoyr(1),ddoyr(nm2)
      call get_netcdf_data(fid2,'o3_column_density',o3_col_dens,dmy_chr2,nx2,ny2,nz2,nm2,ichr)
!      print *, 'o3_coldens',o3_col_dens(1,1,1,1),o3_col_dens(nx2,ny2,nz2,nm2)
      rc=nf90_close(fid2)
!
! convert longitude to 0 - 360
      do i=1,nx2
         do j=1,ny2
            if(xlon2(i,j).lt.0.) then
            xlon2(i,j)=xlon2(i,j)+360.
            endif
         enddo
      enddo
!
! invert the pressure grid
      do k=1,nz2
         prs_tmp2(nz2-k+1)=xlev2(k)
      enddo
      xlev2(1:nz2)=prs_tmp2(1:nz2)
!
! find the day of the year
      im2=6
!
! interpolate data2 to (lat,lon,lev) point
      call interpolate(obs_val,lon,lat,lev,xlon2,xlat2,xlev2,o3_col_dens(1,1,1,im2),nx2,ny2,nz2)
   endif
end subroutine wrf_dart_ubval_interp
!
subroutine get_netcdf_data(fid,fldname,data,data_chr,nx,ny,nz,nm,ichr)
   use netcdf
   implicit none
   integer,parameter                      :: maxdim=4
   integer                                :: nx,ny,nz,nm,ichr
   integer                                :: i,rc,v_ndim,natts,domain,fid
   integer                                :: v_id,typ
   integer,dimension(maxdim)              :: v_dimid,v_dim,one
   character*(*)                          :: fldname
   character*(180)                        :: vnam
   character*(180)                        :: data_chr(nx,ny,nz,nm)
   real,dimension(nx,ny,nz,nm)            :: data
!
! get variables identifiers
         rc = nf90_inq_varid(fid,trim(fldname),v_id)
         if(rc.ne.0) then
            print *, 'APM: nf_inq_varid error'
            call abort
         endif
!
! get dimension identifiers
         v_dimid=0
         rc = nf90_inquire_variable(fid,v_id,vnam,typ,v_ndim,v_dimid,natts)
         if(rc.ne.0) then
            print *, 'APM: nc_inq_var error'
            call abort
         endif
         if(maxdim.lt.v_ndim) then
            print *, 'ERROR: maxdim is too small ',maxdim,v_ndim
            call abort
         endif 
!
! get dimensions
         v_dim(:)=1
         do i=1,v_ndim
            rc = nf90_inquire_dimension(fid,v_dimid(i),len=v_dim(i))
            if(rc.ne.0) then
               print *, 'APM: nf_inq_dimlen error'
               call abort
            endif
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
         else if(nm.ne.v_dim(4)) then             
            print *, 'ERROR: nm dimension conflict ',nm,v_dim(4)
            call abort
         endif
!
! get data
         one(:)=1
         if(ichr.eq.0) then
            rc = nf90_get_var(fid,v_id,data,one,v_dim)
         else if(ichr.eq.1) then
            rc = nf90_get_var(fid,v_id,data_chr,one,v_dim)
         endif
         if(rc.ne.0) then
            print *, 'APM: fr_get_vara_real error'
            call abort
         endif
end subroutine get_netcdf_data
!
         subroutine interpolate(obs_val,lon,lat,lev,xlon,xlat,xlev,data,nx,ny,nz)
!
! longitude and latitude must be in degrees
! pressure grid must be in hPa and go from bottom to top
!
            implicit none
            integer                                :: nx,ny,nz,nzm
            integer                                :: i,j,k,im,ip,jm,jp,quad
            integer                                :: k_lw,k_up,i_min,j_min 
            real                                   :: obs_val,lon,lat,lev
            real                                   :: L_lon,l_lat,l_lev
            real                                   :: fld_lw,fld_up
            real                                   :: xlnp_lw,xlnp_up,xlnp_pt
            real                                   :: dz_lw,dz_up
            real                                   :: mop_x,mop_y
            real                                   :: re,pi,rad2deg
            real                                   :: rad,rad_crit,rad_min,mod_x,mod_y
            real                                   :: dx_dis,dy_dis
            real                                   :: w_q1,w_q2,w_q3,w_q4,wt
            real,dimension(nz)                     :: xlev
            real,dimension(nx,ny)                  :: xlon,xlat
            real,dimension(nx,ny,nz)               :: data
!
! set constants
            pi=4.*atan(1.)
            rad2deg=360./(2.*pi)
            re=6371000.
            rad_crit=100000.
            quad=0
!
! find the closest point            
            rad_min=1.e10
            l_lon=lon
            l_lat=lat
            l_lev=lev
            if(l_lon.lt.0.) l_lon=l_lon+360.
!
            do i=1,nx
               do j=1,ny
                  mod_x=(xlon(i,j))/rad2deg
                  if(xlon(i,j).lt.0.) mod_x=(360.+xlon(i,j))/rad2deg
                  mod_y=xlat(i,j)/rad2deg
                  mop_x=l_lon/rad2deg
                  mop_y=l_lat/rad2deg
                  dx_dis=abs(mop_x-mod_x)*cos((mop_y+mod_y)/2.)*re
                  dy_dis=abs(mop_y-mod_y)*re
                  rad=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)  
                  rad_min=min(rad_min,rad)
                  if(rad.eq.rad_min) then
                     i_min=i
                     j_min=j
                  endif 
               enddo
            enddo
            if(rad_min.gt.rad_crit) then            
               print *, 'APM: ERROR in intrp - min dist exceeds threshold ',rad_min, rad_crit
               print *, 'grid ',i_min,j_min,xlon(i_min,j_min),xlat(i_min,j_min)
               print *, 'point ',l_lon,l_lat
               call abort
            endif
!
! do interpolation
            im=i_min-1
            if(im.eq.0) im=1
            ip=i_min+1
            if(ip.eq.nx+1) ip=nx
            jm=j_min-1
            if(jm.eq.0) jm=1
            jp=j_min+1
            if(jp.eq.ny+1) jp=ny
!
! find quadrant and interpolation weights
            quad=0
            mod_x=xlon(i_min,j_min)
            if(xlon(i_min,j_min).lt.0.) mod_x=xlon(i_min,j_min)+360.
            mod_y=xlat(i_min,j_min)
            if(mod_x.ge.l_lon.and.mod_y.ge.l_lat) quad=1 
            if(mod_x.le.l_lon.and.mod_y.ge.l_lat) quad=2 
            if(mod_x.le.l_lon.and.mod_y.le.l_lat) quad=3 
            if(mod_x.ge.l_lon.and.mod_y.le.l_lat) quad=4
            if(quad.eq.0) then
               print *, 'APM: ERROR IN INTERPOLATE quad = 0 '
               call abort
            endif
!
! Quad 1
            if (quad.eq.1) then
               mod_x=xlon(i_min,j_min)
               if(xlon(i_min,j_min).lt.0.) mod_x=360.+xlon(i_min,j_min) 
               dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(i_min,j_min))/rad2deg/2.)*re
               dy_dis=abs(l_lat-xlat(i_min,j_min))/rad2deg*re
               w_q1=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
               mod_x=xlon(im,j_min)
               if(xlon(im,j_min).lt.0.) mod_x=360.+xlon(im,j_min) 
               dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(im,j_min))/rad2deg/2.)*re
               dy_dis=abs(l_lat-xlat(im,j_min))/rad2deg*re
               w_q2=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
               mod_x=xlon(im,jm)
               if(xlon(im,jm).lt.0.) mod_x=360.+xlon(im,jm) 
               dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(im,jm))/rad2deg/2.)*re
               dy_dis=abs(l_lat-xlat(im,jm))/rad2deg*re
               w_q3=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
               mod_x=xlon(i_min,jm)
               if(xlon(i_min,jm).lt.0.) mod_x=360.+xlon(i_min,jm) 
               dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(i_min,jm))/rad2deg/2.)*re
               dy_dis=abs(l_lat-xlat(i_min,jm))/rad2deg*re
               w_q4=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
! Quad 2
            else if (quad.eq.2) then
               mod_x=xlon(ip,j_min)
               if(xlon(ip,j_min).lt.0.) mod_x=360.+xlon(ip,j_min) 
               dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(ip,j_min))/rad2deg/2.)*re
               dy_dis=abs(l_lat-xlat(ip,j_min))/rad2deg*re
               w_q1=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
               mod_x=xlon(i_min,j_min)
               if(xlon(i_min,j_min).lt.0.) mod_x=360.+xlon(i_min,j_min) 
               dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(i_min,j_min))/rad2deg/2.)*re
               dy_dis=abs(l_lat-xlat(i_min,j_min))/rad2deg*re
               w_q2=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
               mod_x=xlon(i_min,jm)
               if(xlon(i_min,jm).lt.0.) mod_x=360.+xlon(i_min,jm) 
               dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(i_min,jm))/rad2deg/2.)*re
               dy_dis=abs(l_lat-xlat(i_min,jm))/rad2deg*re
               w_q3=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
               mod_x=xlon(ip,jm)
               if(xlon(ip,jm).lt.0.) mod_x=360.+xlon(ip,jm) 
               dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(ip,jm))/rad2deg/2.)*re
               dy_dis=abs(l_lat-xlat(ip,jm))/rad2deg*re
               w_q4=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
! Quad 3
            else if (quad.eq.3) then
               mod_x=xlon(ip,jp)
               if(xlon(ip,jp).lt.0.) mod_x=360.+xlon(ip,jp) 
               dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(ip,jp))/rad2deg/2.)*re
               dy_dis=abs(l_lat-xlat(ip,jp))/rad2deg*re
               w_q1=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
               mod_x=xlon(i_min,jp)
               if(xlon(i_min,jp).lt.0.) mod_x=360.+xlon(i_min,jp) 
               dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(i_min,jp))/rad2deg/2.)*re
               dy_dis=abs(l_lat-xlat(i_min,jp))/rad2deg*re
               w_q2=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
               mod_x=xlon(i_min,j_min)
               if(xlon(i_min,j_min).lt.0.) mod_x=360.+xlon(i_min,j_min) 
               dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(i_min,j_min))/rad2deg/2.)*re
               dy_dis=abs(l_lat-xlat(i_min,j_min))/rad2deg*re
               w_q3=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
               mod_x=xlon(ip,j_min)
               if(xlon(ip,j_min).lt.0.) mod_x=360.+xlon(ip,j_min) 
               dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(ip,j_min))/rad2deg/2.)*re
               dy_dis=abs(l_lat-xlat(ip,j_min))/rad2deg*re
               w_q4=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
! Quad 4
            else if (quad.eq.4) then
               mod_x=xlon(i_min,jp)
               if(xlon(i_min,jp).lt.0.) mod_x=360.+xlon(i_min,jp) 
               dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(i_min,jp))/rad2deg/2.)*re
               dy_dis=abs(l_lat-xlat(i_min,jp))/rad2deg*re
               w_q1=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
               mod_x=xlon(im,jp)
               if(xlon(im,jp).lt.0.) mod_x=360.+xlon(im,jp) 
               dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(im,jp))/rad2deg/2.)*re
               dy_dis=abs(l_lat-xlat(im,jp))/rad2deg*re
               w_q2=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
               mod_x=xlon(im,jm)
               if(xlon(im,jm).lt.0.) mod_x=360.+xlon(im,jm) 
               dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(im,jm))/rad2deg/2.)*re
               dy_dis=abs(l_lat-xlat(im,jm))/rad2deg*re
               w_q3=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
               mod_x=xlon(i_min,j_min)
               if(xlon(i_min,j_min).lt.0.) mod_x=360.+xlon(i_min,j_min) 
               dx_dis=abs(l_lon-mod_x)/rad2deg*cos((l_lat+xlat(i_min,j_min))/rad2deg/2.)*re
               dy_dis=abs(l_lat-xlat(i_min,j_min))/rad2deg*re
               w_q4=sqrt(dx_dis*dx_dis + dy_dis*dy_dis)
            endif
            if(l_lon.ne.xlon(i_min,j_min).or.l_lat.ne.xlat(i_min,j_min)) then
               wt=1./w_q1+1./w_q2+1./w_q3+1./w_q4
            endif
!
! find vertical indexes
            nzm=nz-1
            k_lw=-1
            k_up=-1
            do k=1,nzm
               if(k.eq.1 .and. l_lev.gt.xlev(k)) then
                  k_lw=k
                  k_up=k
                  exit
               endif
               if(l_lev.le.xlev(k) .and. l_lev.gt.xlev(k+1)) then
                  k_lw=k
                  k_up=k+1
                  exit
               endif
               if(k.eq.nzm .and. l_lev.ge.xlev(k+1)) then
                  k_lw=k+1
                  k_up=k+1
                  exit
               endif
            enddo
            if(k_lw.le.0 .or. k_up.le.0) then
               print *, 'APM: ERROR IN K_LW OR K_UP ',k_lw,k_up
               call abort
            endif

!
! horizontal interpolation             
            fld_lw=0.
            fld_up=0.   
            if(l_lon.eq.xlon(i_min,j_min).and.l_lat.eq.xlat(i_min,j_min)) then
               fld_lw=data(i_min,j_min,k_lw)
               fld_up=data(i_min,j_min,k_up)
            else if(quad.eq.1) then
               fld_lw=(1./w_q1*data(i_min,j_min,k_lw)+1./w_q2*data(im,j_min,k_lw)+ &
               1./w_q3*data(im,jm,k_lw)+1./w_q4*data(i_min,jm,k_lw))/wt
               fld_up=(1./w_q1*data(i_min,j_min,k_up)+1./w_q2*data(im,j_min,k_up)+ &
               1./w_q3*data(im,jm,k_up)+1./w_q4*data(i_min,jm,k_up))/wt
            else if(quad.eq.2) then
               fld_lw=(1./w_q1*data(ip,j_min,k_lw)+1./w_q2*data(i_min,j_min,k_lw)+ &
               1./w_q3*data(i_min,jm,k_lw)+1./w_q4*data(ip,jm,k_lw))/wt
               fld_up=(1./w_q1*data(ip,j_min,k_up)+1./w_q2*data(i_min,j_min,k_up)+ &
               1./w_q3*data(i_min,jm,k_up)+1./w_q4*data(ip,jm,k_up))/wt
            else if(quad.eq.3) then
               fld_lw=(1./w_q1*data(ip,jp,k_lw)+1./w_q2*data(i_min,jp,k_lw)+ &
               1./w_q3*data(i_min,j_min,k_lw)+1./w_q4*data(ip,j_min,k_lw))/wt
               fld_up=(1./w_q1*data(ip,jp,k_up)+1./w_q2*data(i_min,jp,k_up)+ &
               1./w_q3*data(i_min,j_min,k_up)+1./w_q4*data(ip,j_min,k_up))/wt
            else if(quad.eq.4) then
               fld_lw=(1./w_q1*data(i_min,jp,k_lw)+1./w_q2*data(im,jp,k_lw)+ &
               1./w_q3*data(im,j_min,k_lw)+1./w_q4*data(i_min,j_min,k_lw))/wt
               fld_up=(1./w_q1*data(i_min,jp,k_up)+1./w_q2*data(im,jp,k_up)+ &
               1./w_q3*data(im,j_min,k_up)+1./w_q4*data(i_min,j_min,k_up))/wt
            endif 
!
! vertical interpolation
            xlnp_lw=log(xlev(k_lw))
            xlnp_up=log(xlev(k_up))
            xlnp_pt=log(l_lev)
            dz_lw=xlnp_lw-xlnp_pt
            dz_up=xlnp_pt-xlnp_up
            if(dz_lw.eq.0.) then
               obs_val=fld_lw
            else if(dz_up.eq.0.) then
               obs_val=fld_up
            else if(dz_lw.ne.0. .and. dz_up.ne.0.) then
               obs_val=(1./dz_lw*fld_lw+1.*dz_up*fld_up)/(1./dz_lw+1./dz_up)
            endif
         end subroutine interpolate
