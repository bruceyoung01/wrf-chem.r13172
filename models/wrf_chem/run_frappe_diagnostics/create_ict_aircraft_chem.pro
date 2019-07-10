
FUNCTION WRF_out, files, year

nfiles = n_elements(files)
ncid = ncdf_open(files[0])
ncdf_varget,ncid, 'XLAT', lat ;, offset=[lon0,lat0,0], count=[nlon0,nlat0,1]
ncdf_varget,ncid, 'XLONG', lon ;, offset=[lon0,lat0,0], count=[nlon0,nlat0,1]
ncdf_varget,ncid, 'co',alt    ; that's NOT altitude!!!
res = NCDF_DIMID( ncid, 'Time' ) 
ncdf_diminq, ncid,res,name,ntimes
ncdf_close,ncid
nimes = 1

ni = n_elements(lon[*,0])
nj = n_elements(lon[0,*])
nlev = n_elements(alt[0,0,*,0])

o3 = fltarr(ni,nj,nlev,ntimes*nfiles)
no = fltarr(ni,nj,nlev,ntimes*nfiles)
no2 = fltarr(ni,nj,nlev,ntimes*nfiles)
co = fltarr(ni,nj,nlev,ntimes*nfiles)
hcho = fltarr(ni,nj,nlev,ntimes*nfiles)
c2h6 = fltarr(ni,nj,nlev,ntimes*nfiles)
c3h8 = fltarr(ni,nj,nlev,ntimes*nfiles)
c2h4 = fltarr(ni,nj,nlev,ntimes*nfiles)
tol = fltarr(ni,nj,nlev,ntimes*nfiles)
pan = fltarr(ni,nj,nlev,ntimes*nfiles)
nh3 = fltarr(ni,nj,nlev,ntimes*nfiles)
hno3 = fltarr(ni,nj,nlev,ntimes*nfiles)
mek = fltarr(ni,nj,nlev,ntimes*nfiles)
c3h6 = fltarr(ni,nj,nlev,ntimes*nfiles)
benzene = fltarr(ni,nj,nlev, ntimes*nfiles)
acet= fltarr(ni,nj,nlev, ntimes*nfiles)
mvk= fltarr(ni,nj,nlev, ntimes*nfiles)
xyl= fltarr(ni,nj,nlev, ntimes*nfiles)
ch3oh= fltarr(ni,nj,nlev, ntimes*nfiles)
bigalk= fltarr(ni,nj,nlev, ntimes*nfiles)
bigene= fltarr(ni,nj,nlev, ntimes*nfiles)
macr= fltarr(ni,nj,nlev, ntimes*nfiles)
times = fltarr(ntimes*nfiles)
pblh = fltarr(ni,nj,ntimes*nfiles)
hgt = fltarr(ni,nj,ntimes*nfiles)
Prs =fltarr(ni,nj,nlev,ntimes*nfiles)

;T =fltarr(ni,nj,nlev,ntimes*nfiles)
Alt =fltarr(ni,nj,nlev,ntimes*nfiles)
;Tpot =fltarr(ni,nj,nlev,ntimes*nfiles)

for ifile=0,nfiles-1 do begin

    ncid = ncdf_open(files[ifile])
    name = file_basename(files[ifile])
    ncdf_varget,ncid,'Times',timestep & timestep=string(timestep)

   ; file2=file_dirname(files[ifile])+'/Hourly_d01_'+timestep
   ; id2=ncdf_open(file2)
;    print, files[ifile], file2
    id2=ncid
    mm =  float(strmid(timestep,5,2))
    dd = float(strmid(timestep,8,2))
    hh = float(strmid(timestep,11,2))

    dayinmonth = [31,28,31,30,31,30,31,31,30,31,30,31]
    if year eq 2008 then dayinmonth = [31,29,31,30,31,30,31,31,30,31,30,31]
    for i = 0, ntimes-1 do begin
       times[i+ifile*ntimes] = total(dayinmonth[0:mm-2]) + dd + hh/24.
    endfor
     
     ncdf_varget,ncid, 'o3', a1;, offset=[lon0,lat0,0,0], count=[nlon0,nlat0,nlev,1]  ; o3
     o3[*,*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1*1e3
    ncdf_varget,ncid, 'no', a1;, offset=[lon0,lat0,0,0], count=[nlon0,nlat0,nlev,1]   ; no
     no[*,*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1 *1e3
    ncdf_varget,ncid, 'no2', a1;, offset=[lon0,lat0,0,0], count=[nlon0,nlat0,nlev,1]  ; no2
     no2[*,*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1*1e3
    ncdf_varget,ncid, 'co', a1;, offset=[lon0,lat0,0,0], count=[nlon0,nlat0,nlev,1]  ; co
     co[*,*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1*1e3
    ncdf_varget,ncid, 'hcho', a1;, offset=[lon0,lat0,0,0], count=[nlon0,nlat0,nlev,1]  ; hcho
     hcho[*,*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1*1e3
    ncdf_varget,ncid, 'c2h6', a1;, offset=[lon0,lat0,0,0],*1e3 count=[nlon0,nlat0,nlev,1]  ; non-CO
     c2h6[*,*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1*1e3
    ncdf_varget,ncid, 'c2h4', a1;, offset=[lon0,lat0,0,0], count=[nlon0,nlat0,nlev,1]  ; c2h4
     c2h4[*,*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1*1e3
    ncdf_varget,ncid, 'c3h8', a1;, offset=[lon0,lat0,0,0], count=[nlon0,nlat0,nlev,1]  ; C3H8
     C3H8[*,*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1*1e3
    ncdf_varget,ncid, 'tol', a1;, offset=[lon0,lat0,0,0], count=[nlon0,nlat0,nlev,1]  ; toluene+benzene+xylene
     tol[*,*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1*1e3
     
      if NCDF_VARID(ncid, 'pan') gt 0 then begin
         ncdf_varget,ncid, 'pan', a1 ;, offset=[lon0,lat0,0,0], count=[nlon0,nlat0,nlev,1]  ; toluene+benzene+xylene
         pan[*,*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1*1e3
      endif
     ncdf_varget,ncid, 'nh3', a1 ;, offset=[lon0,lat0,0,0], count=[nlon0,nlat0,nlev,1]  ; toluene+benzene+xylene
     nh3[*,*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1*1e3
     ncdf_varget,ncid, 'hno3', a1 ;, offset=[lon0,lat0,0,0], count=[nlon0,nlat0,nlev,1]  ; toluene+benzene+xylene
     hno3[*,*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1*1e3
     ncdf_varget,ncid, 'c3h6', a1 ;, offset=[lon0,lat0,0,0], count=[nlon0,nlat0,nlev,1]  ; toluene+benzene+xylene
     c3h6[*,*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1*1e3

     if NCDF_VARID(ncid, 'mek') gt 0 then begin
        ncdf_varget,ncid, 'mek', a1 ;, offset=[lon0,lat0,0,0], count=[nlon0,nlat0,nlev,1]  ; toluene+benzene+xylene
        mek[*,*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1*1e3
     endif
     varid=NCDF_VARID(ncid, 'benzene')
     if varid gt 0 then begin
        ncdf_varget,ncid,'benzene',a1
        benzene[*,*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1*1e3
     endif
     if NCDF_VARID(ncid, 'mvk') gt 0 then begin
        ncdf_varget,ncid, 'mvk', a1 
        mvk[*,*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1*1e3
     endif
     if NCDF_VARID(ncid, 'acet') gt 0 then begin
        ncdf_varget,ncid, 'acet', a1 
        acet[*,*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1*1e3
     endif
    if NCDF_VARID(ncid, 'bigalk') gt 0 then begin
        ncdf_varget,ncid, 'bigalk', a1 
        bigalk[*,*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1*1e3
     endif
   if NCDF_VARID(ncid, 'bigene') gt 0 then begin
        ncdf_varget,ncid, 'bigene', a1 
        bigene[*,*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1*1e3
     endif
  if NCDF_VARID(ncid, 'macr') gt 0 then begin
        ncdf_varget,ncid, 'macr', a1 
        macr[*,*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1*1e3
     endif
  if NCDF_VARID(ncid, 'ch3oh') gt 0 then begin
        ncdf_varget,ncid, 'ch3oh', a1 
        ch3oh[*,*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1*1e3
     endif
  if NCDF_VARID(ncid, 'xyl') gt 0 then begin
        ncdf_varget,ncid, 'xyl', a1 
        xyl[*,*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1*1e3
     endif
        ncdf_varget,ncid, 'PBLH',a1
     pblh[*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1
     ncdf_varget,ncid, 'HGT',a1
     hgt[*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1


   ; calculate altitude and unstagger
    ncdf_varget,ncid, 'HGT',a1 
   ncdf_varget,id2, 'PHB',a2; , offset=[lon0,lat0,0,0], count=[nlon0,nlat0,nlev,1]
   ncdf_varget,id2, 'PH',a3; , offset=[lon0,lat0,0,0], count=[nlon0,nlat0,nlev,1]
   for i=0,nlev-1 do begin
       atemp = (a2[*,*,i]+a3[*,*,i])/9.8/1000. ;-a1[*,*]/1000.
       atemp2 = (a2[*,*,i+1]+a3[*,*,i+1])/9.8/1000.;-a1[*,*]/1000.
       alt[*,*,i,ifile*ntimes:ifile*ntimes+ntimes-1] = (atemp+atemp2)/2.
    endfor

    ncdf_varget,id2, 'PB',a1;, offset=[lon0,lat0,0,0], count=[nlon0,nlat0,nlev,1]   ; base state pressure
    ncdf_varget,id2, 'P',a2;, offset=[lon0,lat0,0,0], count=[nlon0,nlat0,nlev,1]
    Prs[*,*,*,ifile*ntimes:ifile*ntimes+ntimes-1] = a1+a2

    ncdf_attget, ncid,'WEST-EAST_GRID_DIMENSION',wrfix,/GLOBAL
    ncdf_attget, ncid,'SOUTH-NORTH_GRID_DIMENSION', wrfjx,/GLOBAL
    ncdf_attget, ncid,'DX',dx,/GLOBAL
    ncdf_attget, ncid, 'CEN_LAT',lat1,/GLOBAL
    ncdf_attget, ncid, 'CEN_LON',lon1,/GLOBAL
    ncdf_attget, ncid, 'TRUELAT1',truelat1,/GLOBAL
    ncdf_attget, ncid, 'TRUELAT2',truelat2,/GLOBAL
    ncdf_attget, ncid, 'STAND_LON',stdlon,/GLOBAL
    ncdf_attget, ncid, 'MOAD_CEN_LAT',moad_cen_lat,/GLOBAL

    ncdf_close,ncid
endfor

str = {lat:lat,lon:lon,prs:prs, times:times, $
       wrfix:wrfix, wrfjx:wrfjx,dx:dx,lat1:lat1,lon1:lon1, $
      truelat1:truelat1, truelat2:truelat2, stdlon:stdlon, alt:alt,pblh:pblh, hgt:hgt, $
      o3:o3, no:no, no2:no2, co:co, hcho:hcho, c2h6:c2h6, c2h4:c2h4, C3H8:C3H8, tol:tol, $
      benzene:benzene, pan:pan, nh3:nh3, hno3:hno3,mek:mek, c3h6:c3h6, $
      acet:acet, mvk:mvk,xyl:xyl,bigene:bigene,bigalk:bigalk,macr:macr,ch3oh:ch3oh}
return, str

end

; ========================================================
; APM: DRIVER
; ========================================================
@/glade/p/work/mizzi/TRUNK/DART_CHEM_MY_BRANCH/models/wrf_chem/run_frappe_diagnostics/ijll_lc.pro
@/glade/p/work/mizzi/TRUNK/DART_CHEM_MY_BRANCH/models/wrf_chem/run_frappe_diagnostics/llij.pro
@/glade/p/work/mizzi/TRUNK/DART_CHEM_MY_BRANCH/models/wrf_chem/run_frappe_diagnostics/read_ict.pro
@/glade/p/work/mizzi/TRUNK/DART_CHEM_MY_BRANCH/models/wrf_chem/run_frappe_diagnostics/pinterp.pro

code_path='/glade/p/work/TRUNK/DART_CHEM_MY_BRANCH/models/wrf_chem/run_frappe_diagnostics'
device,retain=2
domain = 'd01'
dtimewrf = 6.  ; in hours
;read, domain, prompt = 'Model domain: d01 or d02: '
if domain eq 'd01' then dtimewrf=6.
domaintit='_d01'
if domain eq 'd02' then domaintit=''
dayinmonth = [31,28,31,30,31,30,31,31,30,31,30,31]
aircraft = 'P3' ; P3 or C130
;read, aircraft, prompt='P3 or C130:'
case aircraft of
   'P3':acfiles_all = findfile('/glade/p/work/mizzi/TRUNK/DART_CHEM_MY_BRANCH/models/wrf_chem/run_frappe_diagnostics/merges/discoveraq-mrg60-p3b*2014*ict')
   'C130':acfiles_all = findfile('/glade/p/work/mizzi/TRUNK/DART_CHEM_MY_BRANCH/models/wrf_chem/run_frappe_diagnostics/merges/frappe-mrg60-c130_merge_20140*ict')
endcase
;;;acfiles_all = acfiles_all[3:14]
nfiles = n_elements(acfiles_all)
acdates = strarr(nfiles)
for ifile=0,nfiles-1 do $
acdates[ifile] = strmid(acfiles_all[ifile], strpos(acfiles_all[ifile], '2014'), 8)

acmm = long(strmid(acdates,4,2))
acdd =  long(strmid(acdates,6,2))

revision = 'R0'
;ModelUTCinit = '-CNTL_VARLOC'  ; adjust file path below!!!
;ModelUTCinit = '-CNTL_NVARLOC'  ; adjust file path below!!!
;ModelUTCinit = '-COnXX_VARLOC'  ; adjust file path below!!!
ModelUTCinit = '-COnXX_NVARLOC'  ; adjust file path below!!!
leg = strarr(nfiles)
k=where(strpos(acfiles_all, 'L2') ge 0)
if k[0] ne -1 then leg[k] = '_L2'
k=where(strpos(acfiles_all, 'L1') ge 0)
if k[0] ne -1 then leg[k] = '_L1'

modelfile =  strarr(nfiles)
for  ifile=0,nfiles-1 do $
   modelfile[ifile] = '/glade/p/work/mizzi/TRUNK/DART_CHEM_MY_BRANCH/models/wrf_chem/run_frappe_diagnostics/Model/discoveraq-wrfCHEMarw_model_'+$
   strmid(file_basename(acfiles_all[ifile]), 27,8)+leg[ifile]+'_'+revision+'_UTC'+ModelUTCinit+'-mrg60-p3b'+domaintit+'.ict'
if aircraft eq 'C130' then $
   for  ifile=0,nfiles-1 do $
      modelfile[ifile] = '/glade/p/work/mizzi/TRUNK/DART_CHEM_MY_BRANCH/models/wrf_chem/run_frappe_diagnostics/Model/frappe-wrfCHEMarw_model_'+$
   strmid(file_basename(acfiles_all[ifile]), 24,8)+leg[ifile]+'_'+revision+'_UTC'+ModelUTCinit+'-mrg60-c130'+domaintit+'.ict'

if ModelUTCinit eq '-CNTL_VARLOC' then  wrffile_all =  findfile('wrfout_'+domain+'_*00')
if ModelUTCinit eq '-CNTL_NVARLOC' then  wrffile_all =  findfile('wrfout_'+domain+'_*00')
if ModelUTCinit eq '-COnXX_VARLOC' then  wrffile_all =  findfile('wrfout_'+domain+'_*00')
if ModelUTCinit eq '-COnXX_NVARLOC' then  wrffile_all =  findfile('wrfout_'+domain+'_*00')

for ifile=0, nfiles-1 do begin
   date = acdates[ifile]
   print, date
   mm = strmid(date,4,2)
   dd = strmid(date,6,2)
   kfile = where(file_basename(wrffile_all) eq 'wrfout_'+domain+'_2014'+'-'+mm+'-'+dd+'_00:00:00')
   print, 'kfile ',kfile
   if kfile[0] le 0 then stop
   if domain eq 'd02' then wrffile = wrffile_all[kfile-6:kfile+30]
;   if domain eq 'd01' then wrffile = wrffile_all[kfile-6:kfile+6]
   if domain eq 'd01' then wrffile = wrffile_all[kfile:kfile+3]
;   if kfile-6 le 0 then stop    
   wrf = WRF_out(wrffile, 2014)
   print, 'Finished reading WRF data'

   file_ict = modelfile[ifile]
   print, 'Creating: ',file_ict
   ac=read_ict(acfiles_all[ifile])
 
   actime = reform(ac.data[0,*]/3600./24)+ total(dayinmonth[0:acmm[ifile]-2]) + acdd[ifile] 
   k=where(ac.data[0,*]/3600. ge 24.0)
;   if k[0] ne -1 then stop

   fileext=''
   species_add=''
   combine='n'
   scale = [1.]
   wrfpath='FRAPPE'
   if aircraft eq 'P3' then begin
      aclat = ac.data[5,*]
      aclon = ac.data[6,*]
      k=where(aclon ge 180)
      if k[0] ne -1 then aclon[k] = aclon[k] - 360
      acprs = ac.data[8,*]
      acalt = ac.data[7,*]      ;*0.0003048
   endif
   
   if aircraft eq 'C130' then begin
      aclat = ac.data[5,*]
      aclon = ac.data[6,*]
      k=where(aclon ge 180)
      if k[0] ne -1 then aclon[k] = aclon[k] - 360
      acprs = ac.data[8,*]
      acalt = ac.data[7,*]      ;*0.0003048
   endif

   truelat1 = wrf.truelat1
   truelat2 = wrf.truelat2
   stdlon = wrf.stdlon
   hemi=1
   
   wrf_ix = wrf.wrfix
   wrf_jx = wrf.wrfjx
   knowni = (wrf_ix)/2.
   knownj = (wrf_jx)/2.      
   dx = wrf.dx*1e-3
   lat1 = wrf.lat1
   lon1 = wrf.lon1
   
   in=n_elements(wrf.lon[*,0])
   jn=n_elements(wrf.lon[0,*])
   xlon = fltarr(in,jn)
   xlat = fltarr(in,jn)
   
   for i=1,in do begin
      for j=1,jn do begin
         ijll_lc, i+0,j+0, lllat, lllon, truelat1, truelat2, hemi, stdlon,lat1, lon1, knowni, knownj, dx
         xlon[i-1,j-1] = lllon
         xlat[i-1,j-1] = lllat
      endfor
   endfor
      
   nz = n_elements(wrf.o3[0,0,*,0])
   nac = n_elements(aclon)
   o3AC = fltarr(nac)-999.
   o3AC_1= fltarr(nac)-999.
   o3AC_2= fltarr(nac)-999.
   o3AC_3= fltarr(nac)-999.

   noAC = fltarr(nac)-999.
   benzeneAC = fltarr(nac)-999.
   c2h6AC = fltarr(nac)-999.
   no2AC = fltarr(nac)-999.
   coAC = fltarr(nac)-999.
   hchoAC = fltarr(nac)-999.
   C3H8AC = fltarr(nac)-999.
   c2h4AC = fltarr(nac)-999.
   tolAC = fltarr(nac)-999.
   pblAC = fltarr(nac)-999.
   panAC = fltarr(nac)-999.
   nh3AC = fltarr(nac)-999.
   hno3AC = fltarr(nac)-999.
   mekAC = fltarr(nac)-999.
   c3h6AC = fltarr(nac)-999.
   acetAC = fltarr(nac)-999.
   mvkAC = fltarr(nac)-999.
   ch3ohAC = fltarr(nac)-999.
   bigalkAC = fltarr(nac)-999.
   bigeneAC = fltarr(nac)-999.
   xylAC = fltarr(nac)-999.
   macrAC = fltarr(nac)-999.
   hgtAC = fltarr(nac)-999.
   wrfmatchtime = fltarr(nac)-999.
   nz = n_elements(wrf.o3[0,0,*,0])                     ; only go to 8km
   
   
   for i = 0L, nac-1L do begin   
      wrfprof = fltarr(22,nz)
      wrfprs = fltarr(nz)
      wrfalt = fltarr(nz)
      
; do here the matching for WRF data 
      
      if acprs[i] gt 0 and acalt[i] gt 0 and aclat[i] gt 0 then begin
         
         llij_lc,aclat[i],aclon[i],iac,jac, truelat1, truelat2, hemi, stdlon,lat1, lon1, knowni, knownj, dx
         
       ;    if iac ge 1 or iac le in or jac ge 1 or jac le jn then stop

         if iac ge 1 and iac le in and jac ge 1 and jac le jn then begin
            itimewrf = where(min(abs(wrf.times-actime[i])) eq abs(wrf.times-actime[i])) & itimewrf = itimewrf[0]
            wrfmatchtime[i] = wrf.times[itimewrf]
         
            if  abs(wrfmatchtime[i]-actime[i])*24 gt dtimewrf then stop
         
            if abs(wrfmatchtime[i]-actime[i])*24 le dtimewrf then begin
           

               proftest  = fltarr(2,n_elements(wrf.times), nz)
               proftest_2 = fltarr(2, nz)
               for iz=0,nz-1 do begin
                  for itim=0,n_elements(wrf.times)-1 do begin
                    proftest[0,itim,iz] = interpolate( wrf.o3[*,*,iz,itim], iac-1, jac-1)
                    proftest[1,itim,iz] = interpolate( wrf.prs[*,*,iz,itim], iac-1, jac-1)
                 endfor
               endfor
               for iz=0,nz-1 do begin
                  proftest_2[0,iz] = interpol(reform(proftest[0,*,iz]),wrf.times, actime[i])
                  proftest_2[1,iz] = interpol(reform(proftest[1,*,iz]),wrf.times, actime[i])
               endfor

               o3ac_1[i] =  scale[0]*interpol(reform(proftest_2[0,*]),reform(proftest_2[1,*]), acprs[i]*100)
                 
              if o3ac_1[i] gt 1000 or o3ac_1[i] lt 0 then stop ;print, o3ac_1[i] 
               for iz=0,nz-1 do begin
                  wrfprof[0,iz] = interpolate(wrf.o3[*,*,iz,itimewrf], iac-1, jac-1)
                  wrfprof[1,iz] = interpolate(wrf.no[*,*,iz,itimewrf], iac-1, jac-1)
                  wrfprof[2,iz] = interpolate(wrf.no2[*,*,iz,itimewrf], iac-1, jac-1)
                  wrfprof[3,iz] = interpolate(wrf.co[*,*,iz,itimewrf], iac-1, jac-1)
                  wrfprof[4,iz] = interpolate(wrf.hcho[*,*,iz,itimewrf], iac-1, jac-1)
                  wrfprof[5,iz] = interpolate(wrf.c2h6[*,*,iz,itimewrf], iac-1, jac-1)
                  wrfprof[6,iz] = interpolate(wrf.c2h4[*,*,iz,itimewrf], iac-1, jac-1)
                  wrfprof[7,iz] = interpolate(wrf.C3H8[*,*,iz,itimewrf], iac-1, jac-1)
                  wrfprof[8,iz] = interpolate(wrf.tol[*,*,iz,itimewrf], iac-1, jac-1)
                  wrfprof[9,iz] = interpolate(wrf.pan[*,*,iz,itimewrf], iac-1, jac-1)
                  wrfprof[10,iz] = interpolate(wrf.nh3[*,*,iz,itimewrf], iac-1, jac-1)
                  wrfprof[11,iz] = interpolate(wrf.hno3[*,*,iz,itimewrf], iac-1, jac-1)
                  wrfprof[12,iz] = interpolate(wrf.mek[*,*,iz,itimewrf], iac-1, jac-1)
                  wrfprof[13,iz] = interpolate(wrf.c3h6[*,*,iz,itimewrf], iac-1, jac-1)
                  wrfprof[14,iz] = interpolate(wrf.benzene[*,*,iz,itimewrf], iac-1, jac-1)
                  wrfprof[15,iz] = interpolate(wrf.acet[*,*,iz,itimewrf], iac-1, jac-1)
                  wrfprof[16,iz] = interpolate(wrf.mvk[*,*,iz,itimewrf], iac-1, jac-1)
                  wrfprof[17,iz] = interpolate(wrf.xyl[*,*,iz,itimewrf], iac-1, jac-1)
                  wrfprof[18,iz] = interpolate(wrf.bigene[*,*,iz,itimewrf], iac-1, jac-1)
                  wrfprof[19,iz] = interpolate(wrf.bigalk[*,*,iz,itimewrf], iac-1, jac-1)
                  wrfprof[20,iz] = interpolate(wrf.macr[*,*,iz,itimewrf], iac-1, jac-1)
                  wrfprof[21,iz] = interpolate(wrf.ch3oh[*,*,iz,itimewrf], iac-1, jac-1)
                 wrfalt[iz] = interpolate(wrf.alt[*,*,iz,itimewrf], iac-1, jac-1)
                  wrfprs[iz] = interpolate(wrf.prs[*,*,iz,itimewrf], iac-1, jac-1)
               endfor
           ;    acalt[i] = acprs[i]
           ;    wrfalt = wrfprs/100.
            
               pblac[i]= interpolate(wrf.pblh[*,*,itimewrf], iac-1, jac-1)
               hgtac[i]= interpolate(wrf.hgt[*,*,itimewrf], iac-1, jac-1)
; all give similar results                             
 tmp = pinterp(reverse(wrfprs),reverse(reform(wrfprof[0,*])),acprs[i]*100) 
                               o3AC_2[i] = tmp
                             o3AC_3[i] =  scale[0]*interpol(reform(wrfprof[0,*]), wrfprs/100., acprs[i])
               noAC[i] = scale[0]*interpol(reform(wrfprof[1,*]), wrfalt, acalt[i])
               o3AC[i] = scale[0]*interpol(reform(wrfprof[0,*]), wrfalt, acalt[i])
               no2AC[i] = scale[0]*interpol(reform(wrfprof[2,*]), wrfalt, acalt[i])
               coAC[i] = scale[0]*interpol(reform(wrfprof[3,*]), wrfalt, acalt[i])
               hchoAC[i] = scale[0]*interpol(reform(wrfprof[4,*]), wrfalt, acalt[i])
               c2h6AC[i] = scale[0]*interpol(reform(wrfprof[5,*]), wrfalt, acalt[i])
               C3H8AC[i] = scale[0]*interpol(reform(wrfprof[7,*]), wrfalt, acalt[i])
               c2h4AC[i] = scale[0]*interpol(reform(wrfprof[6,*]), wrfalt, acalt[i])
               tolAC[i] = scale[0]*interpol(reform(wrfprof[8,*]), wrfalt, acalt[i])
               panAC[i] = scale[0]*interpol(reform(wrfprof[9,*]), wrfalt, acalt[i])
               nh3AC[i] = scale[0]*interpol(reform(wrfprof[10,*]), wrfalt, acalt[i])
               hno3AC[i] = scale[0]*interpol(reform(wrfprof[11,*]), wrfalt, acalt[i])
               mekAC[i] = scale[0]*interpol(reform(wrfprof[12,*]), wrfalt, acalt[i])
               c3h6AC[i] = scale[0]*interpol(reform(wrfprof[13,*]), wrfalt, acalt[i])
               benzeneAC[i]=scale[0]*interpol(reform(wrfprof[14,*]), wrfalt, acalt[i])
               acetAC[i]=scale[0]*interpol(reform(wrfprof[15,*]), wrfalt, acalt[i])
               mvkAC[i]=scale[0]*interpol(reform(wrfprof[16,*]), wrfalt, acalt[i])
               xylAC[i]=scale[0]*interpol(reform(wrfprof[17,*]), wrfalt, acalt[i])
               bigeneAC[i]=scale[0]*interpol(reform(wrfprof[18,*]), wrfalt, acalt[i])
               bigalkAC[i]=scale[0]*interpol(reform(wrfprof[19,*]), wrfalt, acalt[i])
               macrAC[i]=scale[0]*interpol(reform(wrfprof[20,*]), wrfalt, acalt[i])
               ch3ohAC[i]=scale[0]*interpol(reform(wrfprof[21,*]), wrfalt, acalt[i])
           endif
         endif

      
; write to file
      
      endif
   
   
   endfor


   varnames_all = [ac.varnames[0],'LATITUDE','LONGITUDE','ALTP','NO','O3','NO2','CO','HCHO','C2H6','C3H8','C2H4','TOLUENE', $
                   'PAN','NH3','HNO3','MEK','C3H6','PBLH','HGT','O3_1','O3_2','O3_3','BENZENE', $
                  'ACET','MVK','XYL','BIGENE','BIGALK','MACR','CH3OH']
   units_all = ['UTC,s','degs','degs','km','ppb','ppb','ppb','ppb','ppb','ppb','ppb','ppb','ppb', $
                'ppb','ppb','ppb','ppb','ppb','m','m','ppb','ppb','ppb','ppb','ppb','ppb','ppb','ppb','ppb','ppb','ppb']
   nvar_all = n_elements(varnames_all)
   scale = strarr(nvar_all-1)+'1'
   miss=strarr(nvar_all-1)+ '-999'
   miss[0:2] = '-999999'
   ncomments = 18
   nhead = 12 + nvar_all-1 + ncomments+2
   

   data = fltarr(nvar_all, nac)
   for i = 0L, nac-1L do begin   
      data[*,i] = [ac.data[0,i],ac.data[5,i], ac.data[6,i], ac.data[7,i], noAC[i], o3AC[i],no2AC[i],coAC[i],$
                   hchoAC[i],c2h6AC[i],C3H8AC[i],c2h4AC[i],tolAC[i],panAC[i], nh3AC[i],hno3AC[i], $
                   mekAC[i], c3h6AC[i],pblac[i], hgtac[i], o3ac_1[i], o3ac_2[i], o3ac_3[i],benzeneAC[i], $
                  acetAC[i], mvkAC[i], XylAC[i],bigeneAC[i],BigalkAC[i],MACRAC[i],ch3ohAC[i]]
   endfor

   openw,ilun,file_ict,/get_lun 
   printf,ilun,format='(i0,",1001")',nhead
   printf,ilun,'Gabriele Pfister'
   printf,ilun,'NCAR/ACD'
   printf,ilun,'WRF ARW Tracer forecast interpolated to '+aircraft+' location/time '
   printf,ilun,'FRAPPE'
   printf,ilun,'1,1'
   printf,ilun,ac.header[5]
   printf,ilun,'60'
   printf,ilun,varnames_all[0]+', '+units_all[0]
   printf,ilun,Strtrim((nvar_all-1),2)
   printf,ilun,Strjoin(scale,',')
   printf,ilun,Strjoin(miss,',')
   for i=1,nvar_all-1 do printf,ilun,Strtrim(varnames_all[i],2),',',Strtrim(units_all[i],2),','
   printf,ilun,'0'
   printf,ilun,strcompress(string(ncomments),/remove_all) 
   printf,ilun,'PI_CONTACT_INFO: pfister@ucar.edu'
   printf,ilun,'PLATFORM: '+aircraft
   printf,ilun,'LOCATION:  included in file'
   printf,ilun,'ASSOCIATED_DATA: N/A'
   printf,ilun,'INSTRUMENT_INFO: N/A'
   printf,ilun,'DATA_INFO: Model Initialization Time: '+date+ModelUTCinit
   printf,ilun,'UNCERTAINTY: Please contact PI'
   printf,ilun,'ULOD_FLAG: -77777'
   printf,ilun,'ULOD_VALUE: N/A'
   printf,ilun,'LLOD_FLAG: -88888'
   printf,ilun,'LLOD_VALUE: N/A'
   printf,ilun,'DM_CONTACT_INFO: pfister@ucar.edu'
   printf,ilun,'PROJECT_INFO: https://www2.acd.ucar.edu/frappe'
   printf,ilun,'STIPULATIONS_ON_USE: Contact instrument PI before use, presentation or publication.'
   printf,ilun,'OTHER_COMMENTS: for model information see http://www.eol.ucar.edu/projects/itop/documents/ForecastDescription_FRAPPE_Models.pdf'
   printf,ilun,'REVISION: R0'
   printf,ilun,'R0: merge created from '+file_basename(acfiles_all[ifile])
   printf,ilun,Strjoin(varnames_all,',')
   fmtstr =  '(i8,",",3(f12.3,","),'+String((nvar_all-5),format='(i0)')+'(e12.4,",")'+',e12.4)'
;'(i8,",",3(f12.3,","),'+String((nvar_all-1),format='(i0)')+'(e12.4,","))'+'(i0)'+'(e12.4)'
   for i=0,nac-1 do begin
      printf,ilun, format=fmtstr,Reform(data[*,i])
   endfor
   close,ilun

endfor



 end

