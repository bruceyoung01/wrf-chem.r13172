
; ========================================================
; ========================================================
@read_ict.pro
@pinterp.pro
@/glade/u/home/pfister/NRCM/EPA_data/quantile.pro
@/glade/u/home/pfister/IDL_routines/str_sep.pro
@ijll_lc.pro
@llij.pro
;SiteIDs- Fort Collins-West (01), Platteville (02), NREL-Golden (03),
;         BAO Tower (04), Denver-LaCasa (05), Chatfield Park (06),
;         NOAA Table Mountain (07), 
;Weld Co. Tower (08), Welch (09), Rocky Flats-N (10), Boulder (11)


!quiet=1


n=10140
aSHAPE=fltarr(2,10140)
openr,1,'../StateBorders.dat'
readf,1,aSHAPE
close,1


device,retain=2
domain = 'd01'
read, domain, prompt = 'Model domain: d01 or d02: '

domaintit='_d01'
if domain eq 'd02' then domaintit=''
dayinmonth = [31,28,31,30,31,30,31,31,30,31,30,31]

aircrafts = ['p3b','c130','c130FR','c130nonFR']   ; c130 or p3b or c130FR or c130nonFR
aircrafts = ['p3b']
modelUTC = '-'
timesel=0
read, modelUTC, prompt='Select Model Run (-) (BTX-) (BTXv2-) (BTXICBC-) (BTX_OG-) '+ $
                        '(BTXv2UBC-) (BTXv263levs-) (FxCNTL-) (BTXv263levsRAQMS-) (BTXv2ECMWF-): '
;read, aircraft, prompt='Select aircraft: c130 or c130FR or c130nonFR or p3b: '
read, timesel, prompt = 'All Times (0), 14-16LT (1) 10-13LT (2) 7-10LT(3)   17-21 LT (4) 10-17LT (5) :' ;ProfLoc (5): '
timeseltit=''
if timesel eq 1 then timeseltit='14to16LT'
if timesel eq 2 then timeseltit='10to13LT'
if timesel eq 3 then timeseltit='7to10LT'
if timesel eq 4 then timeseltit='17to21LT'
if timesel eq 5 then timeseltit='10to17LT'
;if timesel eq 5 then begin
;   idsel=''
;   read, idsel, prompt= 'Select Profie ID (01 ...11):'
;   timeseltit='Prof_'+idsel
;endif
for iaircraft=0,n_elements(aircrafts)-1 do begin
   aircraft = aircrafts[iaircraft]

;read, looptype, prompt='Loop through all files (1) or select files (2) or all files (3)'
   looptype=3
   acfiles = findfile('./merges/*'+aircraft+'*2014*ict')
   if modelUTC eq 'FxCNTL-' then acfiles = findfile('./merges/*'+aircraft+'*20140717*ict')
   if aircraft eq 'c130FR' then acfiles = findfile('./merges/*c130'+'*ict')
   if aircraft eq 'c130nonFR' then acfiles = findfile('./merges/*c130'+'*ict')

   n=n_elements(acfiles)
   for i=0,n-1 do print,i,' ',file_basename(acfiles[i]), format='(I6,A3, A35)'
   nsel = [0,0]
   read,nsel, prompt='Select Range for acfiles: '
   acfiles = acfiles[nsel[0]:nsel[1]]
   epsadd = ''
   read,epsadd, prompt  = 'Add label for psfile: '

 
   print, acfiles 
   ac=read_ict(acfiles)
   acfiletit='ALL'
   nloops=1
   acfiletitadd=aircraft+' All flight'
  
; get topography
   ncid=ncdf_open('../WRF_Chem_output/wrfout_'+domain+'_2014-07-20_12:00:00')
   ncdf_varget,ncid,'HGT',hgt     ; that's NOT altitude!!!
   ncdf_varget,ncid, 'XLAT', wrflat ;, offset=[lon0,lat0,0], count=[nlon0,nlat0,1]
   ncdf_varget,ncid, 'XLONG', wrflon ;, offset=[lon0,lat0,0], count=[nlon0,nlat0,1]
   ncdf_attget, ncid,'WEST-EAST_GRID_DIMENSION',wrfix,/GLOBAL
   ncdf_attget, ncid,'SOUTH-NORTH_GRID_DIMENSION', wrfjx,/GLOBAL
   ncdf_attget, ncid,'DX',wrfdx,/GLOBAL
   ncdf_attget, ncid, 'CEN_LAT',wrflat1,/GLOBAL
   ncdf_attget, ncid, 'CEN_LON',wrflon1,/GLOBAL
   ncdf_attget, ncid, 'TRUELAT1',truelat1,/GLOBAL
   ncdf_attget, ncid, 'TRUELAT2',truelat2,/GLOBAL
   ncdf_attget, ncid, 'STAND_LON',stdlon,/GLOBAL
   ncdf_attget, ncid, 'MOAD_CEN_LAT',moad_cen_lat,/GLOBAL
   knowni = (wrfix)/2.
   knownj = (wrfjx)/2.      
   wrfdx = wrfdx*1e-3
   ncdf_close,ncid
   
; checking lat/lon calculations for WRF
   
   in=n_elements(wrflon[*,0])
   jn=n_elements(wrflon[0,*])
   wrflllon = fltarr(in,jn)
   wrflllat = fltarr(in,jn)
   wrflrlon = fltarr(in,jn)
   wrflrlat = fltarr(in,jn)
   wrfurlon = fltarr(in,jn)
   wrfurlat = fltarr(in,jn)
   wrfullon = fltarr(in,jn)
   wrfullat = fltarr(in,jn)
   wrfclon = fltarr(in,jn)
   wrfclat = fltarr(in,jn)
   for i=1,in do begin
      for j=1,jn do begin
         ijll_lc, i-0.5,j-0.5, lllat, lllon,  truelat1, truelat2, 1, stdlon,wrflat1, wrflon1, knowni, knownj, wrfdx
         wrflllon[i-1,j-1] = lllon
         wrflllat[i-1,j-1] = lllat
         ijll_lc, i+0.5,j-0.5, lllat, lllon,  truelat1, truelat2, 1, stdlon,wrflat1, wrflon1, knowni, knownj, wrfdx
         wrflrlon[i-1,j-1] = lllon
         wrflrlat[i-1,j-1] = lllat
         ijll_lc, i+0.5,j+0.5, lllat, lllon,  truelat1, truelat2, 1, stdlon,wrflat1, wrflon1, knowni, knownj, wrfdx
         wrfurlon[i-1,j-1] = lllon
         wrfurlat[i-1,j-1] = lllat
         ijll_lc, i-0.5,j+0.5, lllat, lllon,  truelat1, truelat2, 1, stdlon,wrflat1, wrflon1, knowni, knownj, wrfdx
         wrfullon[i-1,j-1] = lllon
         wrfullat[i-1,j-1] = lllat
         
         ijll_lc, i+0.0,j+0.0, lllat, lllon, truelat1, truelat2, 1, stdlon,wrflat1, wrflon1, knowni, knownj, wrfdx
         wrfclon[i-1,j-1] = lllon
         wrfclat[i-1,j-1] = lllat
      endfor
   endfor
   

; get model files
   ending=strarr(n_elements(acfiles)) & ending[*] = '_'
   date = strarr(n_elements(acfiles))
   modelfiles = strarr(n_elements(acfiles))
   for iac=0, n_elements(acfiles)-1 do date[iac] = strmid(acfiles[iac], strpos(acfiles[iac],'2014'),8)
   kl1 = where(strpos( acfiles,'L1') ge 0)
   if kl1[0] ne -1 then ending[kl1]='_L1_'
   kl2 = where(strpos( acfiles,'L2') ge 0)
   if kl2[0] ne -1 then ending[kl2]='_L2_'
   help, modelfiles, acfiles, date, modelUTC, domaintit
   if aircraft eq 'c130' or aircraft eq 'c130FR' or aircraft eq 'c130nonFR' then begin
      print, date[0]+''+ending[0]+'R0_UTC'+modelUTC+'mrg60-p3b'+domaintit+'.ict'
      for iac=0, n_elements(acfiles)-1 do $
         modelfiles[iac] = findfile('./Model/frappe-wrfCHEMarw_model_'+date[iac]+''+ending[iac]+'R0_UTC'+modelUTC+'*mrg60-c130'+domaintit+'.ict')
   endif
   
   if aircraft eq 'p3b' then begin
      for iac=0, n_elements(acfiles)-1 do $
         modelfiles[iac] =  findfile('./Model/discoveraq-wrfCHEMarw_model_'+date[iac]+''+ending[iac]+'R0_UTC'+modelUTC+'mrg60-p3b'+domaintit+'.ict')
   endif
   
   kstop = where(modelfiles eq '')
   if kstop[0] ne -1 then stop
   
   if looptype ne 1 then model=read_ict(modelfiles)
   set_plot,'ps'
   psfile = aircraft+'_'+acfiletit+'_modelUTC'+modelUTC+'_CHEM'+domaintit+'_'+timeseltit+'_AVG'+epsadd+'.eps'
   device, xs=19, ys=21, xoff=1, yoff=1, filename=psfile,/color
   print, psfile
   !p.multi=[0,2,2]
   !p.charsize=1.
   device,set_font = 'Times',/TT_FONT
   !p.font=0
   
   
; plotting
   for iloop=0, nloops-1 do begin
 
      print, (acfiles[iloop])
      print, modelfiles[iloop]
      
      if looptype eq 1 then begin
         ac=read_ict(acfiles[iloop])
         model=read_ict(modelfiles[iloop])
      endif
      if n_elements(ac.data[0,*]) ne n_elements(model.data[0,*]) then STOP 
      
      if aircraft eq 'p3b' then begin
         aclat = ac.data[5,*]
         aclon = ac.data[6,*]
         k=where(aclon ge 180)
         if k[0] ne -1 then aclon[k] = aclon[k] - 360
         acprs = ac.data[8,*]
         acalt = ac.data[7,*]   ;*0.0003048
         acprofID = strarr(n_elements(ac.data[0,*])) & acprofid[*] = '00'
         kprof=where(strlen(strcompress(string(long(ac.data[44,*])),/remove_all)) gt 2)
         acprofID[kprof] = strmid(strcompress(string(long(ac.data[44,kprof])),/remove_all),1,2)      

      endif
      
      if aircraft eq 'c130' or aircraft eq 'c130FR'  or aircraft eq 'c130nonFR' then begin
         aclat = ac.data[5,*]
         aclon = ac.data[6,*]
         k=where(aclon ge 180)
         if k[0] ne -1 then aclon[k] = aclon[k] - 360
         acprs = ac.data[8,*]
         acalt = ac.data[7,*]   ;*0.0003048
      endif
      
      ispec0=0
      for ispec=ispec0,17 do begin
         limit = [39.2, -105.5, 40.8, -104.4]
         if aircraft eq 'c130' then limit=[37.5,-109.5,42, -101.8]
         if aircraft eq 'c130FR' then limit=[39.,-106,41.1, -104]
         if aircraft eq 'c130nonFR' then limit=[37.5,-109.5,42, -101.8]
         colortable = 23
         a=findgen(17)*(!pi*2/16.)
         usersym, .8*cos(a), .8*sin(a),/fill

         case ispec of
            0: species = ['O3,ppb,','O3_MixingRatio, ppbv','O3_MixingRatio, ppbv']  ; model, c130, p3
            1: species = ['CO,ppb,','CO_MixingRatio, ppbv','CO_DACOM, ppbv']        ; model, c130, p3
            2: species = ['NO2,ppb,','NO2_MixingRatio, pptv','NO2_MixingRatio, pptv'] ; model, c130, p3
            3: species = ['NO,ppb,','NO_MixingRatio, pptv','NO_MixingRatio, pptv'] ; model, c130, p3
            4: species = ['C2H6,ppb,','C2H6_CAMS, pptv','Ethane_TILDAS, ppbv']        ; model, c130, p3
            5: species = ['C3H8,ppb,','Propane_WAS, pptv','']                         ; model, c130, p3
            6: species = ['C3H6,ppb,','Propene_WAS, pptv','Propene-SmallHydrocarbons_MixingRatio, ppbv'] ; model, c130, p3
            7: species = ['C2H4,ppb,','Ethene_WAS, pptv','']                           ; model, c130, p3
            8: species = ['PAN,ppb,','PAN, pptv','PNs_LIF, pptv']                      ; model, c130, p3???
            9: species = ['NH3,ppb,','NH3_MixingRatio, ppbv','Ammonia_MixingRatio, ppbv']                    ; model, c130, p3
            10: species = ['BENZENE,ppb,','Benzene_MixingRatio, ppbv','Benzene_MixingRatio, ppbv']
            11: species = ['HCHO,ppb,','CH2O_CAMS, pptv','CH2O_DFGAS, pptv']           ; model, c130, p3
            12: species = ['TOLUENE,ppb,','Toluene_MixingRatio, ppbv','Toluene_MixingRatio, ppbv']
            13: species = ['HNO3,ppb,', 'HNO3_GTCIMS, pptv','HNO3_LIF, pptv']
            14: species = ['MEK,ppb,','MEK_TOGA, pptv','MEK-butanal_MixingRatio, ppbv']
            15: species = ['ACET,ppb,','Acetone_TOGA, pptv','Acetone-Propanal_MixingRatio, ppbv']
            16: species = ['MVK,ppb,','MVK_TOGA, pptv','MVK-MACR-crotonaldehyde_MixingRatio, ppbv']  ; ALSO NEED to add MACR to model
            17: species = ['CH3OH,ppb,','Methanol_MixingRatio, ppbv','Methanol_MixingRatio, ppbv']
         endcase

; NOTE!!!!!!!!!!! for some species there are more than one measurements!!
         scale = [1,1,1e3,1e3,1e3,1e3,1e3,1e3,1e3,1,1,1e3,1,1e3,1e3, 1e3,1e3,1]                       ; scaling for model to c130
         if aircraft eq 'p3b' then scale = [1,1,1e3,1e3,1,1e3,1,1e3,1e3,1,1,1e3,1,1e3,1,1,1,1] ; scaling for model to p3
         acspec=species[1]
         
;;;scale[*] = 1
         if aircraft eq 'p3b' then acspec = species[2]
         varsel = where(ac.varnames eq acspec) & varsel = varsel[0]
         vartit = strcompress(ac.varnames[varsel],/remove_all)
         if acspec eq '' then vartit='Missing'
         kmod = where(model.varnames eq species[0])
         
         if acspec ne '' then begin
            
            for ialtloop=0,1 do begin
               
               obs = reform(ac.data(varsel,*)) & obstmp = obs
               if acspec eq '' then obstmp[*] = -999.
               if acspec eq '' then obs  =  reform(model.data(kmod[0],*))*scale[ispec]
               kpos = where(obs gt 0)
                                ;      m1=reform(quantile(0.01,obs[kpos], range=[min(obs[kpos]), max(obs[kpos])], err_ex=err_ex))
                                ;      m2=reform(quantile(0.99,obs[kpos], range=[min(obs[kpos]), max(obs[kpos])], err_ex=err_ex))
                                ;      m1=m1[0]
                                ;      m2=m2[0]
            
               m1=min(obs(where(obs gt 0)))
               m2 = max(obs)
               nlev  = 41
; change scale every time
               xlog=0
               if species[0] eq 'NO,ppb,' then m2 = 10000.
               if iloop ge 0 and ialtloop eq 0 then levels = reverse(m2-alog10(findgen(nlev)+1)/alog10(nlev)*(m2-m1))
               ;;      if iloop ge 0  and ialtloop eq 0 and m2/m1 le 1000 then levels = findgen(nlev)/(nlev-1)*(m2-m1)+m1
               if species[0] eq 'CO,ppb,' then levels = findgen(nlev)/(nlev-1)*180.+60.
               if species[0] eq 'O3,ppb,' then levels = findgen(nlev)/(nlev-1)*65+25
;;         if species[0] eq 'C2H6,ppb,' then xlog=1
               if species[0] eq 'C2H6,ppb,' then levels=findgen(nlev)/(nlev-1)*2.e4
               if species[0] eq 'C2H6,ppb,' and aircraft eq 'p3b' then levels=findgen(nlev)/(nlev-1)*20
               if species[0] eq 'BENZENE,ppb,' then levels=findgen(nlev)/(nlev-1)*.25
               if species[0] eq 'NH3,ppb,' then levels=findgen(nlev)/(nlev-1)*40.
               if species[0] eq 'NO2,ppb,' or species[0] eq 'NO,ppb,'then xlog=1
               colors =  findgen(nlev)/(nlev-1)*230+23
               ;colors =  findgen(nlev)/(nlev-1)*250

; select local time range
               ktimesel = where(model.data[0,*]/3600 gt 24 or model.data[0,*]/3600. lt 0)
               if timesel eq 1 then begin
                  ktimesel = where(model.data[0,*]/3600 le 14+6 or model.data[0,*]/3600. ge 16+6)
               endif
               if timesel eq 2 then begin
                  ktimesel = where(model.data[0,*]/3600 le 10+6 or model.data[0,*]/3600. ge 13+6 )
               endif
               if timesel eq 3 then begin
                  ktimesel = where(model.data[0,*]/3600 le 7+6 or model.data[0,*]/3600. ge 10+6 )
               endif
               if timesel eq 4 then begin
                  ktimesel = where(model.data[0,*]/3600 le 17+6 or model.data[0,*]/3600. ge 21+6 )
               endif
               if timesel eq 5 then begin
                                ;     ktimesel=where(acprofid ne  idsel)
                  ktimesel = where(model.data[0,*]/3600 le 10+6 or model.data[0,*]/3600. ge 17+6 )
               endif
    
           Ytimesel  = obstmp & Ytimesel[*] = 1
           if ktimesel[0] ne -1 then Ytimesel[ktimesel] = -1

               tracertmp = reform(model.data(kmod[0],*))*scale[ispec]
               if kmod[0] eq -1 then tracertmp[*] = obstmp
               kpos=where(obstmp gt 0 and tracertmp gt 0 and reform(aclon) ge limit[1] and reform(aclon) le limit[3] and $
                          reform(aclat) ge limit[0] and reform(aclat) le limit[2] and Ytimesel eq 1)
               if kmod[0] eq -1 then tracertmp[*] = -99.
               if aircraft ne 'c130nonFR' then begin
                  obs = obstmp & obs[*] = -999.
                  obs[kpos] = obstmp[kpos]
                  tracer = tracertmp & tracer[*] = -999.
                  tracer[kpos] = tracertmp[kpos]
                  y=acalt & y[*] = -999.
                  y[kpos] = acalt[kpos]
                  xlon=aclon & xlon[*] = -999.
                  xlon[kpos] = aclon[kpos]
                  xlat=aclat & xlat[*] = -999.
                  xlat[kpos] = aclat[kpos]
               endif
               if aircraft eq 'c130nonFR' then begin
                  limit2 = [39.2, -105.5, 40.8, -104.4]
                  kpos=where(obstmp gt 0 and tracertmp gt 0 and Ytimesel eq 1)
                  obs = obstmp & obs[*] = -999.
                  obs[kpos] = obstmp[kpos]
                  tracer = tracertmp & tracer[*] = -999.
                  tracer[kpos] = tracertmp[kpos]
                  y=acalt & y[*] = -999.
                  y[kpos] = acalt[kpos]
                  xlon=aclon & xlon[*] = -999.
                  xlon[kpos] = aclon[kpos]
                  xlat=aclat & xlat[*] = -999.
                  xlat[kpos] = aclat[kpos]

                  kpos=where(reform(aclon) ge limit2[1] and reform(aclon) le limit2[3] and $
                             reform(aclat) ge limit2[0] and reform(aclat) le limit2[2]) 
                  obs[kpos] = -999.
                  tracer[kpos] = -999.
                  y[kpos] = -999.
                  xlon[kpos] = -999.
                  xlat[kpos] = -999.
               endif
               
               
               
               if ialtloop eq 0 then begin
                  k=where(y ge 3)
                  alttit='< 3 km'
               endif
               if ialtloop eq 1 then begin
                  k=where(y le 3)
                  alttit='> 3 km'
               endif
            
               obs[k] = -999.
               tracer[k] = -999.
               
               
               ni = n_elements(wrflon[*,0])
               nj = n_elements(wrflon[0,*])
               zOBS = fltarr(ni,nj)
               zWRF = fltarr(ni,nj)
               nZ = fltarr(ni,nj)
               
               for ik=0, n_elements(obs)-1 do begin
                  if obs[ik] gt 0 and tracer[ik] gt 0 and xlat[ik] gt 30 then begin      
                     llij_lc,xlat[ik],xlon[ik],iac,jac, truelat1, truelat2, 1, stdlon,wrflat1, wrflon1, knowni, knownj, wrfdx
                     zObs[iac-1, jac-1] = zObs[iac-1, jac-1]+obs[ik]
                     zWRF[iac-1, jac-1] = zWRF[iac-1, jac-1]+tracer[ik]
                     nZ[iac-1, jac-1] = nz[iac-1, jac-1]+1L
                  endif
               endfor
               knZ = where(nz gt 0)
               zobs[knz] = zobs[knz]/nz[knz]
               zWRF[knz] = zWRF[knz]/nz[knz]
               
               loadct,0
               map_set, limit=limit,/noerase, /advance, $
                        tit = vartit +' '+alttit
               contour, hgt, wrflon, wrflat,levels = findgen(31)/30*(3000.-1200.)+1200.,/overplot, $
                        c_thick=replicate(.2,31), c_linestyle=replicate(3,31),$
                        c_colors=findgen(31)/30.*204+40 ;,/fill 
;;            contour, hgt, wrflon, wrflat,levels = findgen(31)/30*(3000.-1200.)+1200.,c_colors=findgen(31)/30.*254,/overplot
               loadct,colortable
               map_continents,/us,/highres,/counties
               
               
               loadct,colortable
               count=0L
               if kpos[0] ne -1 then begin
                  for in=0,ni-2 do begin
                     for jn=0,nj-2 do begin
                        icol = where(abs( zObs[in,jn]-levels) eq min(abs( zObs[in,jn]-levels)))
                        if zobs[in,jn] gt 0 then polyfill, [wrflllon[in,jn], wrflrlon[in,jn],wrfurlon[in,jn], wrfullon[in,jn]],$
                                                           [wrflllat[in,jn], wrflrlat[in,jn], wrfurlat[in,jn], wrfullat[in,jn]],  $
                                                           color=colors[icol[0]], /fill
                     endfor
                  endfor
               endif
               loadct,0
               for iSHAPE=0,n-2 do begin
                  if aSHAPE[0,iSHAPE] gt -900. and aSHAPE[0,iSHAPE+1] gt -900 and $
                     abs(aSHAPE[0,iSHAPE]-aSHAPE[0,iSHAPE+1]) le 0.25 and abs(aSHAPE[1,iSHAPE]-aSHAPE[1,iSHAPE+1]) le 0.25 then begin
                     plots, [aSHAPE[0,iSHAPE],aSHAPE[0,iSHAPE+1]],[aSHAPE[1,iSHAPE],aSHAPE[1,iSHAPE+1]], thick=3
                  endif
               endfor
               loadct,colortable
               
; legend
               d0=limit[1]
               y0=limit[0]
               dy=(limit[2]-limit[0])/80.
               d=(limit[3]-limit[1])/nlev*0.95
               offset=y0
               for ilev=0,nlev-1 do begin
                  polyfill, d0+[ilev*d, ilev*d+d, ilev*d+d, ilev*d],offset+[0.0,0.0,2*dy,2*dy],/data,/fill, color=colors[ilev]
                  if ilev mod 5 eq  0 then xyouts, d0+ilev*d,offset+3*dy,strcompress(string(levels[ilev],format='(F8.2)'),/remove_all),/data, chars=0.7
               endfor
               
               xyouts, d0,offset+6*dy,acfiletitadd[iloop]+' '+timeseltit,/data,chars=0.8
               loadct,0
                                ;  BAO ,Chatfield, La Casa, FC, NREL, Platteville
               sitex   = [-105.0038  ,  -105.0704, -105.005, -105.1414, -105.1779, -104.726]
               sitey   = [40.05,        39.5345,     39.779,    40.5927,   39.749,   40.1827]
               for i=0,n_elements(sitex)-1 do begin
                  plots, sitex[i], sitey[i], psym=5, symsize=1, color=240
                  plots, sitex[i], sitey[i],  psym=8, syms=1.8
                  plots, sitex[i], sitey[i],  psym=8, syms=1.5,color=150
               endfor
               plots, -105.005, 39.779, psym=8, syms=1.8
               plots, -105.005, 39.779, psym=8, color=250, syms=1.5
   
   
   
; plot model               
               tracertit  = species[0]
               
               loadct,0
               map_set, limit=limit,/noerase, /advance, $
                        tit = 'Model '+tracertit +' '+alttit
               contour, hgt, wrflon, wrflat,levels = findgen(31)/30*(3000.-1200.)+1200.,/overplot, $
                        c_thick=replicate(.2,31), c_linestyle=replicate(3,31),$
                        c_colors=findgen(31)/30.*204+40 ;,/fill 
               loadct,colortable
               map_continents,/us,/highres,/counties
               loadct,colortable
               count=0L
               if kpos[0] ne -1 then begin
                  for in=0,ni-2 do begin
                     for jn=0,nj-2 do begin
                        icol = where(abs( zWRF[in,jn]-levels) eq min(abs( zWRF[in,jn]-levels)))
                        if zWRF[in,jn] gt 0 then polyfill, [wrflllon[in,jn], wrflrlon[in,jn],wrfurlon[in,jn], wrfullon[in,jn]],$
                                                           [wrflllat[in,jn], wrflrlat[in,jn], wrfurlat[in,jn], wrfullat[in,jn]],  $
                                                           color=colors[icol[0]], /fill
                     endfor
                  endfor
               endif
               
               loadct,0
               for iSHAPE=0,n-2 do begin
                  if aSHAPE[0,iSHAPE] gt -900. and aSHAPE[0,iSHAPE+1] gt -900 and $
                     abs(aSHAPE[0,iSHAPE]-aSHAPE[0,iSHAPE+1]) le 0.25 and abs(aSHAPE[1,iSHAPE]-aSHAPE[1,iSHAPE+1]) le 0.25 then begin
                     plots, [aSHAPE[0,iSHAPE],aSHAPE[0,iSHAPE+1]],[aSHAPE[1,iSHAPE],aSHAPE[1,iSHAPE+1]],thick=3
                  endif
               endfor
               loadct,colortable
               ; legend
               
               d0=limit[1]
               y0=limit[0]
               dy=(limit[2]-limit[0])/80.
               d=(limit[3]-limit[1])/nlev*0.95
               offset=y0
               for ilev=0,nlev-1 do begin
                  polyfill, d0+[ilev*d, ilev*d+d, ilev*d+d, ilev*d],offset+[0.0,0.0,2*dy,2*dy],/data,/fill, color=colors[ilev]
                  if ilev mod 5 eq  0 then xyouts, d0+ilev*d,offset+3*dy,strcompress(string(levels[ilev],format='(F8.2)'),/remove_all),/data, chars=0.7
               endfor
               
               
               
               loadct,0
                                ;  BAO ,Chatfield, La Casa, FC, NREL, Platteville
               sitex   = [-105.0038  ,  -105.0704, -105.005, -105.1414, -105.1779, -104.726]
               sitey   = [40.05,        39.5345,     39.779,    40.5927,   39.749,   40.1827]
               for i=0,n_elements(sitex)-1 do begin
                  plots, sitex[i], sitey[i], psym=5, symsize=1, color=240
                  plots, sitex[i], sitey[i],  psym=8, syms=1.8
                  plots, sitex[i], sitey[i],  psym=8, syms=1.5,color=150
                  
               endfor
               plots, -105.005, 39.779, psym=8, syms=1.8
               plots, -105.005, 39.779, psym=8, color=250, syms=1.5
               
    

; plot difference model-obs            

               zplot = (zwrf-zobs)/zobs*100
               kneg=where(zwrf le 0 or zobs le 0)
               if kneg[0] ne -1 then zplot[kneg] = -999.
               
               ;levels_diff =  findgen(nlev)/(nlev-1)*100-50
               ;if mean(abs(zplot(where(zplot ne -999.)))) gt 30 then  levels_diff =  findgen(nlev)/(nlev-1)*200-100
               nlev=21
               levs = fltarr(21)
               levs[0:9] = [-150,-100,-75,-50,-30,-20,-15,-10,-5,-1]
               levs[10]=0
               levs[11:20] = -1*reverse(levs[0:9])
               levels_diff=levs
               if median(abs(zplot(where(abs(zplot) ne 999)))) le 50 then begin
                  levs[0:9] = [-50,-40,-30,-25,-20,-15,-10,-5,-3,-1]
                  levs[10]=0
                  levs[11:20] = -1*reverse(levs[0:9])
                  levels_diff=levs
               endif

           ;  loadct,0
               map_set, limit=limit,/noerase, /advance, $
                        tit = 'Model-Obs(%)  '+tracertit +' '+alttit
               contour, hgt, wrflon, wrflat,levels = findgen(31)/30*(3000.-1200.)+1200.,/overplot, $
                        c_thick=replicate(.2,31), c_linestyle=replicate(3,31),$
                        c_colors=findgen(31)/30.*204+40 ;,/fill 
           ;    loadct,colortable
               map_continents,/us,/highres,/counties
    ;           loadct,colortable
               colors=fltarr(nlev)
               nc=128           ;-- # of colors per image
               loadct,1,ncolors=nc ;-- load red table from  0:nc-1
               loadct,3,ncolors=nc, bottom=nc 
               
               colors[0:9]=findgen(10)/9.*(120-50)+50
               colors[11:20] = 254.-(findgen(10)/19.*(100))
               colors[10] = 255.
               colors[0:9]=findgen(10)/9.*(120-0)+0
               colors[11:20] = 254.-(findgen(10)/19.*(120))
               colors[10] = 255.



               count=0L
               if kpos[0] ne -1 then begin
                  for in=0,ni-2 do begin
                     for jn=0,nj-2 do begin
                        icol = where(abs( zplot[in,jn]-levels_diff) eq min(abs( zplot[in,jn]-levels_diff)))
                        if zplot[in,jn] ne -999. then polyfill, [wrflllon[in,jn], wrflrlon[in,jn],wrfurlon[in,jn], wrfullon[in,jn]],$
                                                                [wrflllat[in,jn], wrflrlat[in,jn], wrfurlat[in,jn], wrfullat[in,jn]],  $
                                                                color=colors[icol[0]], /fill
                     endfor
                  endfor
               endif
               
          ;     loadct,0
               for iSHAPE=0,n-2 do begin
                  if aSHAPE[0,iSHAPE] gt -900. and aSHAPE[0,iSHAPE+1] gt -900 and $
                     abs(aSHAPE[0,iSHAPE]-aSHAPE[0,iSHAPE+1]) le 0.25 and abs(aSHAPE[1,iSHAPE]-aSHAPE[1,iSHAPE+1]) le 0.25 then begin
                     plots, [aSHAPE[0,iSHAPE],aSHAPE[0,iSHAPE+1]],[aSHAPE[1,iSHAPE],aSHAPE[1,iSHAPE+1]],thick=3
                  endif
               endfor
            ;   loadct,colortable

; legend
               
               d0=limit[1]
               y0=limit[0]
               dy=(limit[2]-limit[0])/80.
               d=(limit[3]-limit[1])/nlev*0.95
               offset=y0
               for ilev=0,nlev-1 do begin
                  polyfill, d0+[ilev*d, ilev*d+d, ilev*d+d, ilev*d],offset+[0.0,0.0,2*dy,2*dy],/data,/fill, color=colors[ilev]
                  if ilev mod 2 eq  0 then xyouts, d0+ilev*d,offset+3*dy,strcompress(string(levels_diff[ilev],format='(I6)'),/remove_all),/data, chars=0.7
               endfor
               
               
               
             loadct,0
                                ;  BAO ,Chatfield, La Casa, FC, NREL, Platteville
               sitex   = [-105.0038  ,  -105.0704, -105.005, -105.1414, -105.1779, -104.726]
               sitey   = [40.05,        39.5345,     39.779,    40.5927,   39.749,   40.1827]
               for i=0,n_elements(sitex)-1 do begin
                  plots, sitex[i], sitey[i], psym=5, symsize=1, color=240
                  plots, sitex[i], sitey[i],  psym=8, syms=1.8
                  plots, sitex[i], sitey[i],  psym=8, syms=1.5,color=150
                  
               endfor
               plots, -105.005, 39.779, psym=8, syms=1.8
               plots, -105.005, 39.779, psym=8, color=250, syms=1.5
               
           ;    plot, findgen(5),xs=5,ys=5,/nodata

               if ialtloop eq 0 then begin
                  kpos=where(tracer gt 0 and obs gt 0 and acalt le 3, nkpos)
                  alttit='< 3 km'
               endif
               if ialtloop eq 1 then begin
                  kpos=where(tracer gt 0 and obs gt 0 and acalt gt 3, nkpos)
                  alttit='> 3 km'
               endif
if kpos[0] eq -1 then kpos=[0,1]
               xr=[min([min(tracer[kpos]), min(obs[kpos])]), 1.05*max([max(tracer[kpos]), max(obs[kpos])])]
               plot, tracer[kpos], obs[kpos],psym=8,syms=.5, xr=xr, yr=xr,xs=1,ys=1, xtit=tracertit, ytit=vartit, tit=alttit, ymar=7
               oplot, findgen(1000)*20,  findgen(1000)*20, linestyle=1

               m=strcompress(string(mean(tracer[kpos]-obs[kpos]), format='(F8.2)'),/remove_all)
               d=strcompress(string(stddev(tracer[kpos]-obs[kpos]), format='(F8.2)'),/remove_all)
               r=strcompress(string(correlate(tracer[kpos],obs[kpos]), format='(F8.2)'),/remove_all)
               rmse = strcompress(string(sqrt(total(abs(tracer[kpos]-obs[kpos])^2)/nkpos), format='(F8.2)'),/remove_all)
               xyouts, xr[0], xr[1],'!C  !C Diff   Std     R    RMSE',/data,chars=1
               xyouts, xr[0], xr[1],    '!C '+m+' '+d+' '+r+' '+rmse,/data,chars=1


               xyouts,0.85,0.01,modelutc+' '+timeseltit, /normal,chars=.7
               
            endfor
            
            
; time series   
            colortable=13     
            colors=[0,250]      ; obs, model
            
            if aircraft eq 'c130nonFR' then limit = [39.2, -105.5, 40.8, -104.4]
            
            loadct,colortable
            kmod = where(model.varnames eq species[0])
            obstmp = reform(ac.data(varsel,*))
            obstmp[ktimesel] = -999.
        
            tracertmp = reform(model.data(kmod[0],*))*scale[ispec]
            kpos=where(obstmp gt 0 and tracertmp gt 0 and reform(aclon) ge limit[1] and reform(aclon) le limit[3] and $
                       reform(aclat) ge limit[0] and reform(aclat) le limit[2])
            if kmod[0] eq -1 then tracertmp[*] = -99.
            yr=[(min(levels)), max(levels)]
            
            if aircraft ne 'c130nonFR' then begin
               obs = obstmp & obs[*] = -999.
               obs[kpos] = obstmp[kpos]
               tracer = tracertmp & tracer[*] = -999.
               tracer[kpos] = tracertmp[kpos]
               y=acalt & y[*] = -999.
               y[kpos] = acalt[kpos]
            endif
            if aircraft eq 'c130nonFR' then begin
               kpos=where(reform(aclon) ge limit[1] and reform(aclon) le limit[3] and  $ 
                          reform(aclat) ge limit[0] and reform(aclat) le limit[2])
               obs=obstmp & obs[kpos] = -999.
               tracer = tracertmp & tracer[kpos] = -999.
               y = reform(acalt) & y[kpos] = -999.
            endif
            
            plot, obs, min_val=0, yr=yr, pos=[0.1,0.6,0.9,0.95],ytit=vartit+' (black=Obs)', tit=acfiletitadd[iloop], $
                  psym=8, syms=0.8, xs=1,/nodata,ylog=xlog
            oplot, obs,  min_val=0, color=colors[0]
            oplot, obs,  min_val=0, color=colors[0], psym=8, syms=0.8
            oplot, tracer, min_val=0, color=colors[1], psym=4, syms=0.5
            oplot, tracer, color=colors[1],min_val=0
            loadct,0
            axis,/yaxis, yr=[0,8],/save, ytit='Alt (km)',color=150,ylog=0
            oplot, y, min_val=0, color=150
            loadct,colortable
            
            
; vertical profiles
            kpos = where(obs gt 0)
if kpos[0] eq -1 then kpos=[0,1]
            plot, obs[kpos], y[kpos], yr=[0,6], ytit='Alt (km)',xr=yr, xtit=vartit, $
                  tit=acfiletitadd[iloop],psym=8, pos=[0.1,0.06,0.5,0.55],/nodata,xlog=xlog,noclip=0,xs=1,ys=1
            oplot,  obs[kpos], y[kpos],psym=3, color=colors[0], syms=0.2,noclip=0
            oplot, tracer[kpos], y[kpos], color=colors[1], psym=3,syms=0.2,noclip=0
            
            
; average profiles
            loadct,13
            zalt = findgen(5*4+1)/4.+1.25 ;findgen(6*4+1)/4.
            nalt = n_elements(zalt)-1
            dalt = (zalt[1]-zalt[0])/2.
            yOBS = fltarr(3,nalt)
            yWRF = fltarr(3,nalt)
            z =  fltarr(nalt)
            for ialt=0,nalt-1 do begin
               kalt = where(y ge zalt[ialt]-dalt and y lt zalt[ialt+1]+dalt and obs gt 0 and tracer gt 0)
               z[ialt] = zalt[ialt]
               if kalt[0] ne -1 then begin
                  a=findgen(17)*(!pi*2/16.)
                  
                  usersym, .8*cos(a), .8*sin(a),/fill
                  yOBS[*,ialt]=[mean(obs[kalt]), stddev(obs[kalt]), median(obs[kalt])]
                  yWRF[*,ialt]=[mean(tracer[kalt]), stddev(tracer[kalt]), median(tracer[kalt])]        
                  plots, yobs[0,ialt],zalt[ialt]-.01, psym=8, syms=1.35,noclip=0
                  plots, yobs[0,ialt],zalt[ialt]-.01, psym=8, color=colors[0],syms=1.2,noclip=0
                  plots, [ yobs[0,ialt]- yobs[1,ialt], yobs[0,ialt]+yobs[1,ialt]], [zalt[ialt]-.01,zalt[ialt]-.01], color=colors[0],noclip=0
                  plots, yWRF[0,ialt],zalt[ialt]+.01, psym=8,syms=1.35,noclip=0
                  plots, yWRF[0,ialt],zalt[ialt]+.01, psym=8, color=colors[1],syms=1.2,noclip=0
                  plots, [ yWRF[0,ialt]- yWRF[1,ialt], yWRF[0,ialt]+yWRF[1,ialt]], [zalt[ialt]+.01,zalt[ialt]+.01], color=colors[1],noclip=0
                  
                  usersym, [0,1,0.5,0]*2-1,[0,0,1,0]*2-1,/fill
                  plots, yobs[2,ialt],zalt[ialt]-.01, psym=8, syms=1.35,noclip=0
                  plots, yobs[2,ialt],zalt[ialt]-.01, psym=8, color=colors[0],syms=1.2,noclip=0
                  plots, yWRF[2,ialt],zalt[ialt]+.01, psym=8,syms=1.35,noclip=0
                  plots, yWRF[2,ialt],zalt[ialt]+.01, psym=8, color=colors[1],syms=1.2,noclip=0
                  
               endif
            endfor
         
            
;axis,-1,/xaxis,/save,xr=[-100,100],xlog=0,xtit='Difference (%)'
            
            xr=[-50,50]
            kpos = where(ywrf[0,*] gt 0 and yobs[0,*] gt 0)
if kpos[0] eq -1 then kpos=[0,1]
            diff = 100.*( yWRF[0,kpos]-yobs[0,kpos])/yobs[0,kpos]
            if median(abs(diff)) gt 50 then xr=[-100,100]
            plot, 100.*( yWRF[0,*]-yobs[0,*])/yobs[0,*], z,ys=1,xr=xr, pos=[0.65,0.06,0.9,0.55],$
                  xtit='(WRF-OBS)/OBS (%)', yr=[0,6], psym=8, ytit='Alt (km)',xs=1
            oplot, replicate(0,20), findgen(20), linestyle=1, thick=4
            oplot, replicate(10,20), findgen(20), linestyle=3
            oplot, replicate(-10,20), findgen(20), linestyle=3
                                ;    axis,-20,/yaxis, yr=[0,6], ys=1, ytit='Alt (km)'
            
            loadct,0
            plot,  findgen(10),/nodata,xs=5,ys=5
            
            xyouts,0.01,0.01,modelUTC+' '+timeseltit,/normal, chars=0.7


; vertical profiles per spiral location

            if aircraft eq 'p3b' then begin
               !p.multi=[0,2,2]
               ids=['01','02','04','03','05','06']
               ids_tit = ['FortCollins','Platteville','BAO','NREL_Golden','LaCasa','Chatfield']
               for iids=0,5 do begin
                  kpos = where(obs gt 0 and acprofid eq ids[iids])
                  obstmp = obs & obstmp[*] = -999.
                  obstmp[kpos] = obs[kpos]
                  plot, obstmp, y, yr=[0,6], ytit='Alt (km)',xr=yr, xtit=vartit, $
                        tit=acfiletitadd[iloop]+' '+ids_tit[iids],psym=8,/nodata,xlog=xlog,noclip=0,xs=1,ys=1
                  oplot,  obstmp, y,psym=1, color=colors[0], syms=0.2,noclip=0
                  oplot, tracer, y, color=colors[1], psym=1,syms=0.2,noclip=0
            
                  loadct,13
                  zalt = findgen(5*4+1)/4.+1.25 ;findgen(6*4+1)/4.
                  nalt = n_elements(zalt)-1
                  dalt = (zalt[1]-zalt[0])/2.
                  yOBS = fltarr(3,nalt)
                  yWRF = fltarr(3,nalt)
                  z =  fltarr(nalt)
                  for ialt=0,nalt-1 do begin
                     kalt = where(y ge zalt[ialt]-dalt and y lt zalt[ialt+1]+dalt and obstmp gt 0 and tracer gt 0)
                     z[ialt] = zalt[ialt]
                     if kalt[0] ne -1 then begin
                        a=findgen(17)*(!pi*2/16.)
                        
                        usersym, .8*cos(a), .8*sin(a),/fill
                        yOBS[*,ialt]=[mean(obstmp[kalt]), stddev(obstmp[kalt]), median(obstmp[kalt])]
                        yWRF[*,ialt]=[mean(tracer[kalt]), stddev(tracer[kalt]), median(tracer[kalt])]        
                        plots, yobs[0,ialt],zalt[ialt]-.01, psym=8, syms=1.35,noclip=0
                        plots, yobs[0,ialt],zalt[ialt]-.01, psym=8, color=colors[0],syms=1.2,noclip=0
                        plots, [ yobs[0,ialt]- yobs[1,ialt], yobs[0,ialt]+yobs[1,ialt]], [zalt[ialt]-.01,zalt[ialt]-.01], color=colors[0],noclip=0
                        plots, yWRF[0,ialt],zalt[ialt]+.01, psym=8,syms=1.35,noclip=0
                        plots, yWRF[0,ialt],zalt[ialt]+.01, psym=8, color=colors[1],syms=1.2,noclip=0
                        plots, [ yWRF[0,ialt]- yWRF[1,ialt], yWRF[0,ialt]+yWRF[1,ialt]], [zalt[ialt]+.01,zalt[ialt]+.01], color=colors[1],noclip=0
                        
                        usersym, [0,1,0.5,0]*2-1,[0,0,1,0]*2-1,/fill
                        plots, yobs[2,ialt],zalt[ialt]-.01, psym=8, syms=1.35,noclip=0
                        plots, yobs[2,ialt],zalt[ialt]-.01, psym=8, color=colors[0],syms=1.2,noclip=0
                        plots, yWRF[2,ialt],zalt[ialt]+.01, psym=8,syms=1.35,noclip=0
                        plots, yWRF[2,ialt],zalt[ialt]+.01, psym=8, color=colors[1],syms=1.2,noclip=0
                        
                     endif
                  endfor
                             
                  xr=[-50,50]
                  kpos = where(ywrf[0,*] gt 0 and yobs[0,*] gt 0)
                  if kpos[0] ne -1 then begin
                     diff = 100.*( yWRF[0,kpos]-yobs[0,kpos])/yobs[0,kpos]
                     if kpos[0] ne -1 then begin
                        if median(abs(diff)) gt 50 then xr=[-100,100]
                     endif
                     a= ( yWRF[0,1:4])/yobs[0,1:4]
                     ak=where(yWRF[0,1:4] gt 0 and yobs[0,1:4] gt 0)
                     if ak[0] ne -1 then print, tracertit,ids_tit[iids], mean(a[ak]), ':',a(ak), format='(A12, A20, F6.2,A2,6F6.2)'
                     
                     
                     plot, diff[kpos], z[kpos],ys=1,xr=xr,$
                           xtit='(WRF-OBS)/OBS (%)', yr=[0,6], psym=8, ytit='Alt (km)',xs=1
                     oplot, replicate(0,20), findgen(20), linestyle=1, thick=4
                     oplot, replicate(10,20), findgen(20), linestyle=3
                     oplot, replicate(-10,20), findgen(20), linestyle=3
                                ;    axis,-20,/yaxis, yr=[0,6], ys=1, ytit='Alt (km)'
                     
                     loadct,0                  
                     xyouts,0.01,0.01,modelUTC+' '+timeseltit+' '+epsadd,/normal, chars=0.5
                  endif
               endfor

            endif
         endif
        
      endfor         
   endfor
         
   device,/close
endfor



set_plot,'x'
!p.multi=0
   
end



