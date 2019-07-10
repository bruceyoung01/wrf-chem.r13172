subroutine write_one_obs(fileid,value,sp,lat,lon,time,sitenum)
    implicit none
    integer::fileid,sp,sitenum
    real(kind=4)::value,lat,lon
    character(len=25) time
    real,parameter::space=100.
    integer,parameter::sp2type(6)=(/150,151,152,153,154,155/)
    real,parameter::speobsvar(6)=(/1.,1.,1.,0.1,1.,1./)
    real,parameter::splife(6)=(/1.,2.,0.5,0.5,0.5,0.5/)
    !real,parameter::spevar(6)=(/36.,121.,12.25,0.0506,12.25,12.25/)
    write(fileid,*) 1
    write(fileid,*) sp2type(sp)
    write(fileid,*) -1
    write(fileid,*) 1
    write(fileid,*) lon
    write(fileid,*) lat
    write(fileid,"(a4,1x,a2,1x,a2,1x,a2,1x,a2,1x,a2)") &
    trim(time(1:4)),trim(time(5:6)),trim(time(7:8)),trim(time(9:10)),&
    trim(time(11:12)),trim(time(13:14))
    !write(fileid,*) (speobsvar(sp)*sqrt(space/4.0)*splife(sp)/sqrt(real(sitenum))+speobsvar(sp))**2
    write(fileid,*) ((speobsvar(sp)*sqrt(space/4.0)*splife(sp)/sqrt(real(sitenum))+speobsvar(sp)))**2
    !write(fileid,*) (value*0.1)**2
    !write(fileid,*) (value*0.1)**2
    write(fileid,*) value
    write(fileid,*) 1
end subroutine
    
    
    
    
    
program ascii_to_sream
    implicit none
    integer(kind=4),parameter::sp=6
    real(kind=4),parameter::intervalx=1.,intervaly=1.
    integer(kind=4)::h,si,sis,sites,spc,imax,tempsitenumber
    integer(kind=4),allocatable::sitenumber(:)
    real(kind=4),allocatable::obsout(:,:),sitelat(:),sitelon(:)
    real(kind=4),allocatable::tobsout(:,:),tsitelat(:),tsitelon(:)
    integer(kind=4),allocatable::tsitecount(:,:)
    real(kind=8)::temp(6)
    real::minlat,minlon,maxlat,maxlon
    integer(kind=8)::max_obs
    character(len=20)::filein,fileinfo,tempf
    character(len=25)::time
    integer(kind=4)::nx,ny,i,j
    logical::alive
    logical,parameter::needthin=.true.
    integer::io
    call getarg(1,filein)
    call getarg(2,time)
    call getarg(3,fileinfo)
    open(56,file=trim(fileinfo),status="OLD")
	imax=0
	do while (.true.)
		imax=imax+1
		read(56,"(a1)",end=500) tempf
	end do
	500 continue
	close(56)
	imax=imax-2
	sites=imax
	allocate(sitenumber(sites),sitelat(sites),sitelon(sites),obsout(sp,sites))
    open(56,file=trim(fileinfo),status="OLD")
    read(56,"(a1)") tempf
    do sis=1,sites
        read(56,*) sitenumber(sis),sitelat(sis),sitelon(sis),tempf
    end do
    close(56)
    inquire(file=trim(filein),exist=alive)
    if(alive) then
        open(56,file=filein,status="OLD")
        io=0;
        si=1
        do while(io==0)
            read(56,fmt="(i4,4x,f8.0,f8.3,4f8.0)",iostat=io) tempsitenumber,temp(:)
            do sis=si,sites
                if(tempsitenumber==sitenumber(sis)) then 
                    if(temp(1)<0.0001.or.temp(1)>1000) then !pm2.5
                        obsout(6,sis)=-9999.
                    else
                        obsout(6,sis)=temp(1)
                    end if
                    if(temp(2)<0.0001.or.temp(2)>100) then !co
                        obsout(4,sis)=-9999.
                    else
                        obsout(4,sis)=temp(2)
                    end if
                    if(temp(3)<0.0001.or.temp(3)>1000) then !no2
                        obsout(2,sis)=-9999.
                    else
                        obsout(2,sis)=temp(3)
                    end if
                    if(temp(4)<0.0001.or.temp(4)>1000) then   !o3
                        obsout(5,sis)=-9999.
                    else
                        obsout(5,sis)=temp(4)
                    end if
                    if(temp(5)<0.0001.or.temp(5)>1000) then !so2
                        obsout(1,sis)=-9999.
                    else
                        obsout(1,sis)=temp(5)
                    end if
                    if(temp(6)<0.0001.or.temp(6)>1000.or.temp(6)<obsout(6,sis)) then !pm10
                        obsout(3,sis)=-9999.
                    else
                        obsout(3,sis)=temp(6)
                    end if
                    exit
                end if
            end do  
        end do
        close(56)
    else
        obsout(:,:)=-9999.
    end if
    if(needthin) then
        minlat=minval(sitelat)
        minlon=minval(sitelon)
        maxlat=maxval(sitelat)
        maxlon=maxval(sitelon)
        nx=int((maxlon-minlon)/(intervalx))
        minlon=(((maxlon-minlon)-nx*intervalx)/2.)+minlon
        maxlon=minlon+nx*intervalx
        nx=nx+1
        ny=int((maxlat-minlat)/(intervaly))
        minlat=(((maxlat-minlat)-ny*intervaly)/2.)+minlat
        maxlat=minlat+ny*intervaly
        ny=ny+1
        allocate(tsitelat(nx*ny),tsitelon(nx*ny),tobsout(sp,nx*ny),tsitecount(sp,nx*ny))
        tobsout=0.
        tsitecount=0
        do sis=1,sites
            i=int((sitelon(sis)-minlon+0.5*intervalx)/intervalx)+1
            j=int((sitelat(sis)-minlat+0.5*intervaly)/intervaly)+1
            do spc=1,sp
                if(obsout(spc,sis)>0.) then
                    tsitecount(spc,(j-1)*nx+i)=tsitecount(spc,(j-1)*nx+i)+1
                    tobsout(spc,(j-1)*nx+i)=(tobsout(spc,(j-1)*nx+i)*(tsitecount(spc,(j-1)*nx+i)-1)+obsout(spc,sis))/real(tsitecount(spc,(j-1)*nx+i))
                end if
            end do
            
        end do
        do i=1,nx
            do j=1,ny
               tsitelat((j-1)*nx+i)=minlat+(j-1)*intervaly 
               tsitelon((j-1)*nx+i)=minlon+(i-1)*intervalx 
            end do
        end do
        
    end if
    if(.not.needthin) then
        max_obs=0
        do sis=1,sites
            do spc=1,sp
                if(obsout(spc,sis)>0) then
                    max_obs=max_obs+1
                end if
            end do
        end do
        open(56,file="stream_monitor.out",status="REPLACE")
        write(56,*) max_obs
        write(56,*) 1
        write(56,*) 1
        write(56,"(a11)") "observation"
        write(56,"(a2)") "QC"
        do sis=1,sites
            do spc=1,sp
                if(obsout(spc,sis)>0) then
                    call write_one_obs(56,obsout(spc,sis),spc,sitelat(sis),sitelon(sis),time,1)
                end if
            end do
        end do 
        write(56,"(a19,/)") "obs_seq_monitor.out"
    else
        max_obs=0
        do i=1,nx
        do j=1,ny
            do spc=1,sp
                if(tsitecount(spc,(j-1)*nx+i)>0) then
                    max_obs=max_obs+1
                end if
            end do
        end do 
        end do
        open(56,file="stream_monitor.out",status="REPLACE")
        write(56,*) max_obs
        write(56,*) 1
        write(56,*) 1
        write(56,"(a11)") "observation"
        write(56,"(a2)") "QC"
        do i=1,nx
        do j=1,ny
            do spc=1,sp
                if(tsitecount(spc,(j-1)*nx+i)>0) then
                    call write_one_obs(56,tobsout(spc,(j-1)*nx+i),spc,tsitelat((j-1)*nx+i),tsitelon((j-1)*nx+i),time,tsitecount(spc,(j-1)*nx+i))
                end if
            end do
        end do
        end do
        write(56,"(a19,/)") "obs_seq_monitor.out"
    end if
    
end
    
