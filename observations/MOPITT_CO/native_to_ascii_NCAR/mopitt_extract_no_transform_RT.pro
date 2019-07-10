;=======================================================================
; subroutines for mopitt_extract_svd_transform
; based on mopitt_extract_intexb.pro
;=======================================================================
; Get the Vdata information from an HDF file
function get_vd, filename, varname
   file_id = hdf_open(filename, /read)
   vd_ref = hdf_vd_find(file_id, strtrim(varname,2))
   vdata=hdf_vd_attach(file_id,vd_ref)
   nread=hdf_vd_read(vdata,var)
   hdf_vd_detach, vdata
   return,var
end
;
; Get the Scientific Data information from an HDF file
function read_mopitt, filename, varname
   sd_id = hdf_sd_start(filename,/read)
   index = hdf_sd_nametoindex(sd_id, varname)
   sds_id = hdf_sd_select(sd_id,index)
   hdf_sd_getdata, sds_id, dat
   hdf_sd_endaccess, sds_id
   hdf_sd_end, sd_id
   return, dat
end
;
;=======================================================================
; main IDL routine
; needs read_mopitt, get_vd, 
; needs calc_avgker_v3, mopitt_v4_apriori.dat and read_aprior_dat_v3 for V3
; afa change output_nrows_leading to output_rows_leading
;=======================================================================
pro mopitt_extract_no_transform_RT, inf, outf, bin_beg, bin_end, lon_min, lon_max, lat_min, lat_max 
;=======================================================================
; Code to read MOPITT data V3 or V4
; Outputs data to an ascii file for DART input
; Outputs station data to an ascii file for diagnostics
; written by Ave Arellano (NCAR) 
; Notes: 
; Need all the functions in the same directory.
; to run:
;   IDL> .r mopitt_extract_svd_transform.pro
;   IDL> mopitt_extract_svd_transform
;       
; But now, this is called by a shell script to process DART MOPITT obs
;
; inf 		--> input file
; outf 	--> output file
; bin_beg      --> beginning hour of the bin  (follows DART 6-hourly bins)
; bin_end      --> end hour of the bin (follows DART 6-hourly bins)
; num_version  --> integer for MOPITT version (3 or 4)
; what_cov     --> covariance (3 or 5) MOPITT has two versions for v4 
; do_DART_input --> integer 1 or 0 to output ascii file for DART create_mopitt_obs_sequence
; do_station_output --> integer 1 or 0 to output station data
;                       see code below for station locations
; output_rows_leading --> how many leading components to assimilate?
; sband  --> spectral band (if tir, nir or tirnir)
; apm_no_transform --> switch to ignorescaling/scd transformation
; when saving MOPITT data
;=======================================================================
; floating underflow in la_svd routines (compared output with matlab)
; seems to be very similar --suppress exception for now
!EXCEPT = 0
;
   print, 'IDL file in  ', inf 
   print, 'IDL file out ', outf
   print, 'IDL bin_str  ', bin_beg
   print, 'IDL bin end  ', bin_end
   print, 'IDL lon min  ', lon_min
   print, 'IDL lon max  ', lon_max
   print, 'IDL lat min  ', lat_min
   print, 'IDL lat max  ', lat_max
;
   num_version=5
   what_cov=3
   do_DART_input=1
   do_station_output=0
   output_rows_leading=2
   sband='tirnir'
   apm_no_transform='true'
;
   case num_version of
      3: version = 'v3';
      4: version = 'v4';
      5: version = 'v5';
   endcase
;
; the two versions have different number of vertical levels
   if ( version eq 'v3' ) then begin
      mopittpress = [1000., 850., 700., 500., 350., 250., 150.]
   endif else begin
      mopittpress=[1000., 900., 800., 700., 600., 500., 400., 300., 200., 100.]
      if ( what_cov eq 3 ) then begin
         prior_error = 0.3 ; in log 
      endif else begin
         prior_error = 0.5 ; in log
      endelse
      delta_pressure_lev = 100. ; hPa
      log10e = alog10(exp(1))
      C0     = (prior_error*log10e)^2
      Pc2    = delta_pressure_lev^2
   endelse
   mopitt_dim = n_elements(mopittpress)
;
; debug level (debug=0 if no printouts)
   debug = 0
;
;=======================================================================
; assign station locations
; define stations here for now
; in the future, we can read a file of lat/lon/drad
; Saskatchewan, NE Pacific, American Samoa, Ascension Is, Seychelles, 
; Pittsburg,US, Houston, US, Baltic Sea, Indian Ocean, NW Aus 1, NW Aus 2,
; Prague, Nigeria, Beijing, Delhi, Midway Island, Brazilia, Indonesia
;
; station center longitude in degrees
   lontsloc = [-105.45, -150.00, -170.57, -14.42, 55.17, -80.00, -95.00, 17.07, 123.00, 121.00, 129.00, 15.00, 10.00, 117.00, 75.00, -175.00, -45.00, 117.0]
; station center latitude in degress
   lattsloc = [  50.33,   40.00,  -14.24,  -7.92, -4.67,  40.00,  30.00, 55.42, -12.00, -21.00, -21.00, 50.00, 10.00,  39.00, 30.00,   30.00, -45.00, -2.5]
; radius of influence in degrees
   drad     = [   1.00,    1.00,    1.00,   1.00,  1.00,   1.00,   1.00,  1.00,   1.00,   1.00,   1.00,  1.00,  1.00,   1.00,  1.00,    1.00,   1.00, 2.5]
; number of stations
   ntsloc   = n_elements(lontsloc)
;
;=======================================================================
; QUALITY CONTROLS
; set QC here -- based on MOPITT Data Quality Statement
; these settings are very ad hoc !!! see personal comments
; edit if necessary
; dofs (i dont think dof is higher than 2 for MOPITT)
; from the pdfs of dofs, the threshold below appears to be 'outliers'
   case sband of
      'tir':     begin
                   dofs_threshold_low = 0.5
                   dofs_threshold_hi  = 2.0
      end
      'nir':     begin
                   dofs_threshold_low = 0.5
                   dofs_threshold_hi  = 1.0
      end
      'tirnir': begin
                   dofs_threshold_low = 0.5
                   dofs_threshold_hi  = 3.0
      end
   endcase
;
; pick daytime or nighttime or all -- there appears to be some contention
; whether or not there is bias in nighttime retrievals --
   sza_day = 90.0 ;all day data
   sza_nit = 180.0 ;all day and night data
;
; polar regions --there are potential for biases near the poles
   day_lat_edge_1 = -70.0  ; 70S
   day_lat_edge_2 =  70.0  ; 70N
   nit_lat_edge_1 = -60.0  ; 60S
   nit_lat_edge_2 =  60.0  ; 60N
;
; retrieval error as fraction of its  prior error
; this is very ad hoc based on percent apriori (post error/prior error)
   if ( version ne 'v3' ) then begin
      max_error_reduction_qc = 1.00
   endif else begin
      max_error_reduction_qc = 0.5 
   endelse
;
; end of QC
;=======================================================================
; convert bins into seconds
   bin_beg = bin_beg*60.0*60.0
   bin_end = bin_end*60.0*60.0
;
; dummy variable (for output purposes)
   dummy_var = [-9999, -9999, -9999,  -9999,  -9999,  -9999,  -9999,  -9999,  -9999,  -9999]
;
; Define MOPITT file name
   mopitt_input_file   = inf
   mopitt_output_file  = outf
;
; echo what we are processing here 
   print, 'IDL accessing MOPITT file: ', mopitt_input_file
   print, 'IDL writing to ascii file: ', mopitt_output_file
;
;=======================================================================
; read MOPITT file
;=======================================================================
; Read Seconds in Day
   name = 'Seconds in Day'
   sec1 = get_vd(mopitt_input_file, name)
   nx   = long(n_elements(sec1)-1)
   sec  = float(sec1)
;
; Read Latitude;
   name = 'Latitude'
   lat  = get_vd(mopitt_input_file, name)
;
; Read Longitude;
   name = 'Longitude'
   lon  = get_vd(mopitt_input_file, name)
;
; Read Cloud Description
   name  = 'Cloud Description'
   cloud = get_vd(mopitt_input_file, name)
;
   if (version ne 'v3') then begin
;
; Read Surface Pressure
      name  = 'Surface Pressure'
      psurf = get_vd(mopitt_input_file, name)
   endif else begin
;
; Read Retrieval Bottom Pressure
      name  = 'Retrieval Bottom Pressure'
      psurf = read_mopitt(mopitt_input_file, name)
      psurf = reform(psurf[0,*])
   endelse
;
; Read Solar Zenith Angle
   name = 'Solar Zenith Angle'
   sza  = get_vd(mopitt_input_file, name)
;
   if (version ne 'v3') then begin
;
; Read Surface Indicator
      name = 'Surface Index'
      sind = get_vd(mopitt_input_file, name)
   endif else begin
;
; Read Surface Indicator
      name = 'Surface Indicator'
      sind = get_vd(mopitt_input_file, name)
   endelse
;
   if (version ne 'v3') then begin
;
; Read CO Total Colum
      name  = 'Retrieved CO Total Column'
      cocol = read_mopitt(mopitt_input_file, name)
      cocol0 = reform(cocol[0,*])
      cocol1 = reform(cocol[1,*])
      endif else begin
;
; Read CO Total Column
      name  = 'CO Total Column'
      cocol = read_mopitt(mopitt_input_file, name)
      cocol0 = reform(cocol[0,*])
      cocol1 = reform(cocol[1,*])
   endelse
;
   if (version ne 'v3') then begin
;
; Read DOFS
      name = 'Degrees of Freedom for Signal'
      dofs = get_vd(mopitt_input_file, name)
   endif
;
   if (version ne 'v3') then begin
;
; Read Retrieved Non-Surface CO Mixing Ratio
      name     = 'Retrieved CO Mixing Ratio Profile'
      codata   = read_mopitt(mopitt_input_file, name)
      comix    = reform(codata[0,*,*])
      comixerr = reform(codata[1,*,*])
;
; Read Retrieved CO Surface Mixing Ratio 
      name      = 'Retrieved CO Surface Mixing Ratio'
      codata    = read_mopitt(mopitt_input_file, name)
      scomix    = reform(codata[0,*])
      scomixerr = reform(codata[1,*])
;
; Read Retrieval Averaging Kernel Matrix
      name   = 'Retrieval Averaging Kernel Matrix'
      avgker = read_mopitt(mopitt_input_file, name)
;
; Read A Priori Surface CO Mixing Ratio 
      name     = 'A Priori CO Surface Mixing Ratio'
      codata   = read_mopitt(mopitt_input_file, name)
      sperc    = reform(codata[0,*])
      spercerr = reform(codata[1,*])
;
; Read A Priori CO Mixing Ratio Profile
      name    = 'A Priori CO Mixing Ratio Profile'
      codata  = read_mopitt(mopitt_input_file, name)
      perc    = reform(codata[0,*,*])
      percerr = reform(codata[1,*,*])
;
      if (version eq 'v5') then begin
;
; Read Retrieval Error Covariance Matrix
         name = 'Retrieval Error Covariance Matrix'
         covmatrix = read_mopitt(mopitt_input_file, name)
      endif
   endif else begin
;
; Read CO Mixing Ratio
      name     = 'CO Mixing Ratio'
      codata   = read_mopitt(mopitt_input_file, name)
      comix    = reform(codata[0,*,*])
      comixerr = reform(codata[1,*,*])
;
; Read Retrieval Bottom CO Mixing Ratio
      name      = 'Retrieval Bottom CO Mixing Ratio'
      codata    = read_mopitt(mopitt_input_file, name)
      scomix    = reform(codata[0,*])
      scomixerr = reform(codata[1,*])
;
; Read Retrieval Error Covariance Matrix
      name      = 'Retrieval Error Covariance Matrix'
      covmatrix = read_mopitt(mopitt_input_file, name)
      covmatrix = covmatrix
   endelse
;
;=======================================================================
; Open output file
;=======================================================================
; initialize unit numbers for station data
   if ( do_station_output eq 1 ) then begin 
      unit_array = intarr(ntsloc)
   endif
;
; in cases where the file moves over to another day
   if (bin_beg eq 0) then begin
;
;open previous file
      if ( do_DART_input eq 1 ) then begin
         openu, unit, mopitt_output_file, /get_lun
         dummyA= ' '
         while ~ eof(unit) do begin
            readf, unit, dummyA
         endwhile
      endif
;
; file for station diagnostics
      if ( do_station_output eq 1 ) then begin
         for istation = 0L, ntsloc-1 do begin
            if ( istation lt 10 ) then begin
               station_mopitt_output_file = strtrim(mopitt_output_file+'.station_0'+string(istation,format='(i1)'))
            endif else begin
               station_mopitt_output_file = strtrim(mopitt_output_file+'.station_'+string(istation,format='(i2)'))
            endelse
            openu, unit_temp, station_mopitt_output_file, /get_lun
            unit_array[istation] = unit_temp
            dummyA = ' '
            while ~ eof(unit_temp) do begin
               readf, unit_temp, dummyA
            endwhile
         endfor
      endif
   endif else begin
;
; file for DART input
      if ( do_DART_input eq 1 ) then begin
         openw, unit, mopitt_output_file, /get_lun
      endif
;
; file for station diagnostics
      if ( do_station_output eq 1 ) then begin
         for istation = 0L, ntsloc-1 do begin
            if ( istation lt 10 ) then begin
               station_mopitt_output_file = strtrim(mopitt_output_file+'.station_0'+string(istation,format='(i1)'))
            endif else begin
               station_mopitt_output_file = strtrim(mopitt_output_file+'.station_'+string(istation,format='(i2)'))
            endelse
            openw, unit_temp, station_mopitt_output_file, /get_lun
            unit_array[istation] = unit_temp
         endfor
      endif
   endelse ; bin_beg
;
;=======================================================================
; define/initialize other variables here
; log10 conversion for d ln(VMR) = d(VMR)/VMR = d log10(VMR) /log10(e)
   log10e = alog10(exp(1)) 
;
; qc count (most of qc - dofs, time, sza, partial qc, high lat)
   qc_count = 0.0
;
; qc for apriori contribution (subset of qc_count)
   qc_count2 = 0.0
;
; qc for all (subset of qc_count2)
   allqc_count = 0.0
;
; all pixel count
   allpix_count = 0.0
;=======================================================================
;
; Now, loop through each pixels
   for k = 0L, nx do begin 
      allpix_count = allpix_count + 1.0
;
;=====================================================
; first get all the necessary arrays
      case version of 
         'v3' : begin
;
;==============================================
; For V3, half of the posterior error covariance is reported
; we need to construct the full covariance and averaging kernel
; we need the prior profile and error covariance to do this
; A = I - Cx Ca^-1
;==============================================
;
; construct full retrieved covariance matrix
            cov_retr = dblarr(mopitt_dim,mopitt_dim)
            cov_retr[0,0] = (scomixerr[k]*1e-9)^2 ; ppb to VMR
            for ik=1,mopitt_dim-1 do cov_retr[ik,ik] = (comixerr[ik-1,k]*1e-9)^2
            cov_retr[0,1:mopitt_dim-1] = covmatrix[0,0:5,k]
            cov_retr[1,2:mopitt_dim-1] = covmatrix[0,6:10,k]
            cov_retr[2,3:mopitt_dim-1] = covmatrix[0,11:14,k]
            cov_retr[3,4:mopitt_dim-1] = covmatrix[0,15:17,k]
            cov_retr[4,5:mopitt_dim-1] = covmatrix[0,18:19,k]
            cov_retr[5,6:mopitt_dim-1] = covmatrix[0,20:20,k]
            for j=0,5 do begin
               for ik=1,6 do begin
                  cov_retr[ik,j]=cov_retr[j,ik]
               endfor
            endfor
;
; call subroutine to calculate averaging kernel A, given full error covariance Cx
; based on Louisa Emmons' code
            calc_avgker_v3, cov_retr, psurf[k], A, mop_dim, mopittlev, status, Cx, levind, prior, covmat_ap
            Ca = covmat_ap
            dfs = trace(A)
;    
            mopittlev = mopittpress
;  
; initialize qc status here
            if status eq 1 then begin
               qstatus = 1 
            endif else begin
               qstatus = 0
            endelse   
            mopittlev = mopittpress
;
; check number of levels
; this has been check in calc_avgker_v3 but
; let's do it again here --mopittlev has slightly different format
; it's still 7 levels but psurf replaces the first level
; mop_dim --> effective number of levels
;
            case 1 of
               (psurf[k] gt 850.0): begin
                  mopittlev = mopittpress
                  mopittlev[0]=psurf[k]
                  mop_dim = 7
               end
               (psurf[k] le 850.0) and  (psurf[k] gt 700.0):  begin
                  mopittlev = mopittpress
                  mopittlev[1] = psurf[k]
                  mop_dim = 6
               end
               (psurf[k] le 700.0) and  (psurf[k] gt 500.0):  begin
                  mopittlev = mopittpress
                  mopittlev[2] = psurf[k]
                  mop_dim = 5
               end
               (psurf[k] le 500.0) and  (psurf[k] gt 350.0):  begin
                  mopittlev = mopittpress
                  mopittlev[3] = psurf[k]
                  mop_dim = 4
               end
               else: begin
                  print, 'MOPITT Surface Level Too High'
                  qstatus = 1
               end
            endcase
         end ; version v3
         'v4' : begin
;
;==============================================
; For V4, we need to calculate Cx, given A
; Calculate Cm (see email by Merritt 12/11/2008)
; Cx = Cs + Cm
; A = I - Cx Ca^-1 so Cx = (I-A) Ca
; Cs = (A-I)Ca(A-I)^T 
; Cm = (I-A)Ca(I+(A-I)^T)
;==============================================
;
            qstatus = 0
            mopittlev = mopittpress
            case 1 of    
               (psurf[k] gt 900.0): begin
                  mopittlev = mopittpress
                  mopittlev[0]=psurf[k]
                  mop_dim = 10
               end
               (psurf[k] le 900.0) and  (psurf[k] gt 800.0):  begin
                  mopittlev = mopittpress
                  mopittlev[1] = psurf[k]
                  mop_dim = 9
               end
               (psurf[k] le 800.0) and  (psurf[k] gt 700.0):  begin
                  mopittlev = mopittpress
                  mopittlev[2] = psurf[k]
                  mop_dim = 8
               end
               (psurf[k] le 700.0) and  (psurf[k] gt 600.0):  begin
                  mopittlev = mopittpress
                  mopittlev[3] = psurf[k]
                  mop_dim = 7
               end
               (psurf[k] le 600.0) and  (psurf[k] gt 500.0):  begin
                  mopittlev = mopittpress
                  mopittlev[4] = psurf[k]
                  mop_dim = 6
               end
               (psurf[k] le 500.0) and  (psurf[k] gt 400.0):  begin
                  mopittlev = mopittpress
                  mopittlev [5] = psurf[k]
                  mop_dim = 5
               end
               else: begin
                  print, 'MOPITT Surface Level Too High'
                  qstatus = 1
               end
            endcase
;
; Construct prior covariance matrix
; based on MOPITT V4 User Guide
            covmat_ap = fltarr(mop_dim,mop_dim, /nozero)
            d_mop_dim = mopitt_dim-mop_dim
            for ii=d_mop_dim,mopitt_dim-1 do begin
               for jj=d_mop_dim,mopitt_dim-1 do begin
                  tmp=C0*( exp( -((mopittlev[ii]-mopittlev[jj])^2)/Pc2) )
                  covmat_ap[ii-d_mop_dim,jj-d_mop_dim]=tmp
               endfor
            endfor
;
; change notation (for my case)
            Ca = covmat_ap
;
; Invert the a priori covariance matrix 
            invCa = invert(Ca, status)
;
; status = 0: successful
; status = 1: singular array
; status = 2: warning that a small pivot element was used and that
;             significant accuracy was probably lost.
; Status is usually 2
;
            if status eq 1 then begin
               qstatus = 1
            endif else begin
               qstatus = 0
            endelse
;
; change notation ( for clarity )
            mop_A = avgker[*,*,k]
;
; need to do transpose (IDL column-major)
            mop_A = transpose(mop_A)
;
; truncate to effective number of levels
            A = fltarr(mop_dim,mop_dim, /nozero)
            A = mop_A[mopitt_dim-mop_dim:mopitt_dim-1,mopitt_dim-mop_dim:mopitt_dim-1]
;
; identity matrix
            I = Identity(mop_dim)
;
; now calculate posterior covariance
            Cx = (I-A)##Ca
;
; assign dfs
            dfs = dofs[k]
         end ; version v4
         'v5' : begin
            qstatus = 0
            mopittlev = mopittpress
            case 1 of
               (psurf[k] gt 900.0): begin
                  mopittlev = mopittpress
                  mopittlev[0]=psurf[k]
                  mop_dim = 10
               end
               (psurf[k] le 900.0) and  (psurf[k] gt 800.0):  begin
                  mopittlev = mopittpress
                  mopittlev[1] = psurf[k]
                  mop_dim = 9
               end
               (psurf[k] le 800.0) and  (psurf[k] gt 700.0):  begin
                  mopittlev = mopittpress
                  mopittlev[2] = psurf[k]
                  mop_dim = 8
               end
               (psurf[k] le 700.0) and  (psurf[k] gt 600.0):  begin
                  mopittlev = mopittpress
                  mopittlev[3] = psurf[k]
                  mop_dim = 7
               end
               (psurf[k] le 600.0) and  (psurf[k] gt 500.0):  begin
                  mopittlev = mopittpress
                  mopittlev[4] = psurf[k]
                  mop_dim = 6
               end
               (psurf[k] le 500.0) and  (psurf[k] gt 400.0):  begin
                  mopittlev = mopittpress
                  mopittlev [5] = psurf[k]
                  mop_dim = 5
               end
               else: begin
                  print, 'MOPITT Surface Level Too High'
                  qstatus = 1
               end
            endcase
;
; Construct prior covariance matrix
; based on MOPITT V4 User Guide
            covmat_ap = fltarr(mop_dim,mop_dim, /nozero)
            d_mop_dim = mopitt_dim-mop_dim
            for ii=d_mop_dim,mopitt_dim-1 do begin
               for jj=d_mop_dim,mopitt_dim-1 do begin
                  tmp=C0*( exp( -((mopittlev[ii]-mopittlev[jj])^2)/Pc2) )
                  covmat_ap[ii-d_mop_dim,jj-d_mop_dim]=tmp
               endfor
            endfor
;
; change notation (for my case)
            Ca = covmat_ap
;
; Invert the a priori covariance matrix
            invCa = invert(Ca, status)
;
; status = 0: successful
; status = 1: singular array
; status = 2: warning that a small pivot element was used and that
;             significant accuracy was probably lost.
; Status is usually 2
;
            if status eq 1 then begin
               qstatus = 1
            endif else begin
               qstatus = 0
            endelse
;
; change notation ( for clarity )
            mop_A = avgker[*,*,k]
;
; need to do transpose (IDL column-major)
            mop_A = transpose(mop_A)
;
; truncate to effective number of levels
            A     = fltarr(mop_dim,mop_dim, /nozero)
            A     = mop_A[mopitt_dim-mop_dim:mopitt_dim-1,mopitt_dim-mop_dim:mopitt_dim-1]
            I     = Identity(mop_dim)
;
; change notation (for my case)
            mop_Cx = covmatrix[*,*,k]
;
; need to do transpose (IDL column-major)
            mop_Cx = transpose(mop_Cx)
;
; truncate to effective number of levels
            Cx     = fltarr(mop_dim,mop_dim, /nozero)
            Cx     = mop_Cx[mopitt_dim-mop_dim:mopitt_dim-1,mopitt_dim-mop_dim:mopitt_dim-1]
;
; assign dfs
            dfs = dofs[k]]
         end ;version v5
      endcase
;
;=====================================================
; APM: at this point AVE has full averaging kernal
;      and covariance matrixes
; QC: most qc applied here 
;=====================================================
;     print, 'IDL lon, lat ', lon[k],lat[k]
      if (dfs gt dofs_threshold_low && dfs lt dofs_threshold_hi && $
      ((sza[k] le sza_day && lat[k] gt day_lat_edge_1 && lat[k] lt day_lat_edge_2) || $
      (sza[k] ge sza_day && lat[k] gt nit_lat_edge_1 && lat[k] lt nit_lat_edge_2)) && $
      sec[k] ge bin_beg && sec[k] lt bin_end && $
      lat[k] ge lat_min && lat[k] le lat_max && $
      lon[k] ge lon_min && lon[k] le lon_max && $
      qstatus eq 0) then begin 
;     if (lat[k] ge lat_min && lat[k] le lat_max && $
;     lon[k] ge lon_min && lon[k] le lon_max && $
;     qstatus eq 0) then begin 
;     if ( ( dfs gt dofs_threshold_low ) && ( dfs lt dofs_threshold_hi ) && $
;     ((( sza[k] le sza_day ) && ( lat[k] gt day_lat_edge_1 ) && ( lat[k] lt day_lat_edge_2 ))) && $
;     ( sec[k] ge bin_beg ) && (sec[k] lt bin_end ) && $
;     ( qstatus eq 0 ) ) then begin 
;
         print, dfs, sza[k], lat[k], lon[k], sec[k], psurf[k], qstatus
         qc_count = qc_count + 1.0
;
; make mop_dim-element profiles
         co = fltarr(mop_dim,/nozero)
         coerr = fltarr(mop_dim,/nozero)
         priorerr = fltarr(mop_dim,/nozero)
         priorerrb = fltarr(mop_dim,/nozero)
         if (version ne 'v3') then begin
            prior = fltarr(mop_dim,/nozero)
         endif else begin
         endelse
;
; assign file variables to profile quantities
         co[0] = scomix[k]*1e-9		; in mixing ratio now
         coerr[0] = scomixerr[k]*1e-9 
         if (version ne 'v3') then begin
            prior[0] = sperc[k]*1e-9
            priorerrb[0] = spercerr[k]*1e-9 ; this is from MOPITT product
         endif
;
         ik_lev = 0
         for ik = 1,mopitt_dim-1 do begin
            if (perc[ik-1,k] gt 0.0 ) then begin
               ik_lev = ik_lev + 1
               prior[ik_lev]=perc[ik-1,k]*1e-9
               priorerrb[ik_lev]=percerr[ik-1,k]*1e-9 ; this is from MOPITT product
               co[ik_lev]=comix[ik-1,k]*1e-9
               coerr[ik_lev]=comixerr[ik-1,k]*1e-9 ; this is from MOPITT product
            endif
         endfor
;
         if ( version ne 'v3' ) then begin
;
; here we change to co instead of prior for the normalization point
; see notes on calculation of retrieval error
; the reason for this is that the prior and posterior should have
; the same normalization point for consistency
; coerr is based on retrieved co not prior co
            for ik = 0,mop_dim-1 do begin
               priorerr[ik] =sqrt(Ca[ik,ik])*co[ik]/log10e 
            endfor
         endif else begin
            for ik = 0,mop_dim-1 do begin
               priorerr[ik] = sqrt(Ca[ik,ik]) 
            endfor
         endelse
;
; before we use 700hPa or 500 hPa level for apriori contrib
; i think it's better to use the maximum error reduction instead
         error_reduction = fltarr(mop_dim,/nozero) 
         for ik = 0, mop_dim-1 do begin
            error_reduction[ik] = (priorerr[ik]-coerr[ik])/priorerr[ik]
         endfor
         max_error_reduction = max(error_reduction, max_index)
         apriori_contrib = max_error_reduction
; 
; QC: check error reduction qc
         if (apriori_contrib le max_error_reduction_qc)  then begin
            qc_count2 = qc_count2 + 1.0
;
; now that we have Ca, Cx, and A, we need to get xa, x and xe
; change notation and make sure youre in log space
; both v3 and v4 report VMR units for xa and x
            xa = transpose(alog10(prior))
            x = transpose(alog10(co))
            I = Identity(mop_dim)
;
;======================================================================
            if (version eq 'v3') then begin
;
; convert Cx (VMR) to fractional
; convert Ca (VMR) to fractional
; see email to Merritt (2/5/2010)
               sigma_a   = Identity(mop_dim)
               for ik=0,mop_dim-1 do begin 
                  sigma_a[ik,ik] = log10e/co[ik] 
               endfor         
               Cx = sigma_a##Cx##sigma_a
               Ca = sigma_a##Ca##sigma_a
;
; recalculate A
               A = sigma_a##A##invert(sigma_a)
;          
; recalculate xe, posterior error
               xe = fltarr(mop_dim, /nozero)
               for ik=0,mop_dim-1 do begin 
                  xe[ik] = sqrt(Cx[ik,ik])
               endfor
;
; recalculate prior error
               xe_a = fltarr(mop_dim, /nozero)
               for ik=0,mop_dim-1 do begin
                  xe_a[ik] = sqrt(Ca[ik,ik])
               endfor 
            endif else begin
;          
; recalculate xe (same as coerr but in fractional form)
               xe = fltarr(mop_dim, /nozero)
               for ik=0,mop_dim-1 do begin
                  xe[ik] = sqrt(Cx[ik,ik])
               endfor
;
; recalculate xe_a (same as priorerr but in fractional form)
               xe_a =  fltarr(mop_dim, /nozero)
               for ik=0,mop_dim-1 do begin
                  xe_a[ik] = sqrt(Ca[ik,ik])
               endfor
;
;==================================================================
; this part is really for debugging 
; In v4, these are all already in fractional from
; convert Cx to fractional VMR
; see email to Merritt (2/5/2010)
;==================================================================
               if ( debug eq 1 ) then begin
                  sigma_a   = Identity(mop_dim)
                  for ik=0,mop_dim-1 do begin
                     sigma_a[ik,ik] = co[ik]/log10e
                  endfor
                  Cx_vmr = sigma_a##Cx##sigma_a
                  Ca_vmr = sigma_a##Ca##sigma_a
                  A_vmr = sigma_a##A##invert(sigma_a)
                  xe_a_vmr =  fltarr(mop_dim, /nozero)
                  for ik=0,mop_dim-1 do begin
                     xe_a_vmr[ik] = sqrt(Ca_vmr[ik,ik])
                  endfor
;
; convert Cx to fractional VMR
; see email to Merritt (2/5/2010)
                  sigma_a   = Identity(mop_dim)
                  for ik=0,mop_dim-1 do begin
                     sigma_a[ik,ik] = prior[ik]/log10e
                  endfor
;
                  Cx_vmr_c = sigma_a##Cx##sigma_a
                  Ca_vmr_c = sigma_a##Ca##sigma_a
                  A_vmr_c = sigma_a##A##invert(sigma_a)
                  xe_a_vmr_c =  fltarr(mop_dim, /nozero)
                  for ik=0,mop_dim-1 do begin
                     xe_a_vmr_c[ik] = sqrt(Ca_vmr_c[ik,ik])
                  endfor
;
;the following print statements checks for 
;what priorerrb is using (xa or xhat)
                  print, 'prior a'
                  print, xe_a_vmr 
                  print, 'prior b'
                  print, priorerrb
                  print, 'prior c'
                  print, xe_a_vmr_c
                  stop
               endif  ; debug
            endelse ; version 
;         
;======================================================================
;
; calculate prior term (I-A)xa  in x = A x_t + (I-A)xa + Gey
; needed for obs/forward operator (prior term of expression)
            ImA   = (I-A)
            AmI   = (A-I)
            ImAxa = ImA##xa
;
; calculate Cm --here Cx = Cm + Cs
; where Cx is the posterior error covariance
; Cm = < (Gey)(Gey)^T > = GSeG^T, Se is measurement noise covariance
; Cm -> error due to measurement noise
; Cs -> error due to smoothing (application of prior)
; Cm = (I-A) Ca (I + (A-I)^T) = Cx (K^T Se^-1 K ) Cx
; Cs = Cx Sa^-1 Cx 
; x = Cx K^T Se^-1 (y - Kxa)
; A = Cx K^T Se^-1 K = G K
;
            Cm    = ImA##Ca##( I + transpose(AmI) ) 
;
; it seems that we cant get a positive definite Cm due to numerical issues
; Cm is one order of magnitude lower than Cx --yes, it's low
; But Cm has similar pattern with the averaging kernel A
; while Cx resembles Ca in pattern 
; so, we can either choose to use Cx or use Cm  but with preconditioned
; i think we should use Cm since this is how the x expression is based on
; although i dont think it really matters a lot
;
            isCx = 0
            if (isCx eq 1) then begin
               Cm = Cx 
            endif
;
; Ok. Here's the SVD approach
; ========================================================================
; (1) We need to scale the retrieval 
;     x = xa + A(x_t-xa) + ex or x = A x_t + (I-A) xa + ex
;     Cm  = < e_x ex^T > , < (Gey)(Gey)^T > 
;     sCm = ex^-1 
;     sCm x = ( sCm A ) x_t + ( sCm (I-A) xa )
; ========================================================================
;
; to do the scaling, we get the square root of Cm
; either doing cholesky decomposition or eigenvalue/vector decomposition
; turns out Cm is sometimes singular or not positive-definite
; so for now, we'll use SVD
;
;=======================================================================
; but first, precondition Cm and make it symmetric
; i think this is valid since most of the differences i see are
; very small --hence errors associated with numerical linear algebra
;
            if (isCx eq 0) then begin
;
; for some numerical reason, Cm is not symmetric
; have problems doing eigenvalue decomposition with non-symmetric matrix
               for ik = 0,mop_dim-1 do begin
                  for ijk = ik,mop_dim-1 do begin
                     Cm[ik,ijk]=Cm[ijk,ik]
                  endfor
               endfor
;
; save original Cm for debugging later on
;
; APM: Looks like I want to save Cm_dummy
; APM: Here are the unscaled, unrotated equivalents
;       A   - averaging kernal
;       Cm  - measurement error covariance
;       xa  - prior
;       x   - retrieval
;
               Cm_dummy = Cm
               eigenvalues = la_eigenql(Cm, EIGENVECTORS = eigenvectors, status=status)
               if status ne 0 then begin
                  print, 'Cm la_eigengl did not converge'
                  print, Cm, status
                  qstatus = 1
               endif
;
; APM: not necessary because Cm is a covariance matrix which is 
; symmetric, positive semidefinite => all real eigenvalues >= 0
;
; check for complex values
; la_eigenql readme says it outputs real eigenvectors
; but in matlab, sometimes, eigenvalues can be complex 
; so might as well check for complex numbers
;
               for ik=0,mop_dim-1 do begin
                  ftype = size(eigenvalues[ik], /type)
                  if (ftype eq 6  ) then begin
                     qstatus = 1
                  endif
               endfor
;
; APM: not necessary - see preceding APM comment
;
; precondition by removing all negative eigenvalues
; and replace by floating point precision
;
               eval   = Identity(mop_dim) 
               for ik=0,mop_dim-1 do begin
                  if (eigenvalues[ik] lt (Machar()).eps  ) then begin
                     eval[ik,ik]=(Machar()).eps
                  endif else begin
                     eval[ik,ik]=eigenvalues[ik]
                  endelse
               endfor
;
; reconstruct covariance matrix
               Cm = transpose(eigenvectors)##eval##(eigenvectors)
            endif ; isCx
;
;=======================================================================
; whoops, that was tough.
; now take the inverse square-root of Cm
; from eigenvalue decomposition 
; S = L D L^T
; S^1/2 = L D^1/2 L^T
; S^-1/2 = L D^-1/2 L^T
; this is similar to SVD --we opt to use SVD here for convenience
; S = R D L^T 
; svd(S) = sqrt(eig(S#S))
; we can also do a cholesky decomposition which Rodgers suggested
; spectral decomposition
; S = T^T T
; S^-1/2 = T^-1
;=======================================================================
;
; APM: measurement covariance based scaling
; 
; status = 0: The computation was successful
; status =>0: The computation did not converge. The status value specifies how many superdiag did not
; converge to zero
            la_svd, Cm, s_Cm, u_Cm, v_Cm, status=status
            if status ne 0 then begin
               print, 'Cm svd did not converge'
               print, Cm, status
               qstatus = 1
            endif
;
; get the square root of Cm
            sqrt_s_Cm = fltarr(mop_dim, /nozero)
            for ik = 0,mop_dim-1 do begin
               if ( s_Cm[ik] le 0.0 )  then begin 
                  s_Cm[ik] = (Machar()).eps
               endif
               sqrt_s_Cm[ik] = sqrt(s_Cm[ik])
            endfor
;
; get the inverse square root of Cm
            inv_s  = Identity(mop_dim)
            for ik = 0,mop_dim-1 do begin 
               inv_s[ik,ik] = 1.0/sqrt_s_Cm[ik]
            endfor
            sCm    = v_Cm##inv_s##transpose(u_Cm)
;
; APM: a priori covariance based scaling
; 
; status = 0: The computation was successful
; status =>0: The computation did not converge. The status value specifies how many superdiag did not
;             converge to zero
            la_svd, Ca, s_Ca, u_Ca, v_Ca, status=status
            if status ne 0 then begin
               print, 'Ca svd did not converge'
               print, Ca, status
               qstatus = 1
            endif
;
; get the square root of Ca
            sqrt_s_Ca = fltarr(mop_dim, /nozero)
            for ik = 0,mop_dim-1 do begin
               if (s_Ca[ik] lt 0)  then begin 
                  s_Ca[ik] = (Machar()).eps
               endif 
               sqrt_s_Ca[ik] = sqrt(s_Ca[ik])
            endfor
            sqrt_Ca  = Identity(mop_dim)
            for ik = 0,mop_dim-1 do begin 
               sqrt_Ca[ik,ik] = sqrt_s_Ca[ik]
            endfor
            sCa    = v_Ca##sqrt_Ca##transpose(u_Ca) 
;
; =================================================================
; scale the whole expression
; =================================================================
;
; APM this is the measurement covariance based scaling
;
; scale A using sCm
            sA = sCm##A
;
; scale Cm --> now should be identity 
; the line below is a check 
; sCms = sCm##Cm##transpose(sCm)
; scale Ca --> this wont be use but may be useful for debugging
            sCas = sCm##Ca##(sCm)
;
; force sCms to be identity --this has been checked
            sCms = Identity(mop_dim)
;
; scale x
            sx = sCm##x
;
; scale prior term
            sImAxa = sCm##ImAxa
;
; ========================================================================
; (2) Get SVD of scaled Ax and rotate retrieval to its maximum information
; sA##sCa = USV^T
; U^T ( sCm x ) = U^T ( sCm A ) x_t +  U^T (sCm (I-A) xa ) 
; U^T ( sx ) = U^T ( sA ) x_t +  U^T ( sImAxa ) 
; ========================================================================
;
; from Migliorini et al 2008, they rotated the scaled covariance
; <H'PH'^T> for EIG which is similar to getting the square root of Ca in SVD
; see Stefano's email regarding P (2/10/2010)
; i think it makes more sense to have the singular vectors of Ax rather than A
; it accounts for both the variability in x and sensitivity of the retreival
;
; APM: Ave calculates SVD for Ax (averaging kernal time retrieval) as
; opposed to A (averaging kernal).
;
; APM: NOTE TOO: sAx is the result of a RHS a priori covariance based scaling of
; sA (the scaled averaging kernal) where the first scaling is the
; measurement covariance based scaling
; 
            sAx = sA##sCa
;
; take the svd of sA
; status = 0: The computation was successful
; status =>0: The computation did not converge. The status value specifies how many superdiag did not
; converge to zero
            la_svd, sAx, S, U, V, status=status
            if status ne 0 then begin
               print, 'sA svd did not converge'
               print, sA, status
               qstatus = 1
            endif
;
; calculate transpose(U)A
            transA = transpose(U)##sA 
;
; need to check U if it is reflected rather than translated
; note that transA is row major now
; that means you need to sum the columns --
; here we assumed that the sum of the averaging kernel rows
; should be at least positive, if it is negative then
; it is reflected and we should take the opposite sign
            sum_uA = total(transA,1)
;
; change sign of rows of U (in matlab this is really the 
; singular vector in columns)
            for ik=0,mop_dim-1 do begin
               if (sum_uA[ik] le 0.0) then begin
                  for ikk=0,mop_dim-1 do begin
                     U[ik,ikk] = U[ik,ikk]*(-1.0)
                  endfor
               endif
            endfor
;
; recalculate transA
            transA = transpose(U)##sA
;        
; rotate scaled Cx and Ca
; again this is a check if it's really identity
; Cmn = transpose(U)##sCms##U
; rotated Ca is not really used but might be useful for debugging
            Can = transpose(U)##sCas##U
;
;force Cmn to be identity -- this has been checked 
            Cmn = Identity(mop_dim)
;
; calculate new y 
            yn = transpose(U)##sx
;  
; rotate prior term
            transImAxa = transpose(U)##sImAxa
; 
; get new errors
            e2 = diag_matrix(Cm)
            e2n = diag_matrix(Cmn)
            e2a = diag_matrix(Can)
            for ik=0, mop_dim-1 do begin
               if (e2n[ik] lt 0) then begin
                  qstatus = 1.0
               endif else begin
                  e2n[ik] = sqrt(e2n[ik])
                  e2a[ik] = sqrt(e2a[ik])
               endelse
            endfor
;
; ========================================================================
; (3) Truncate to dofs level
; now look at transA and pick n retrievals corresponding to dofs
; ========================================================================
            nrows_leading0 = ceil(dfs)
;
; alternatively find the point where the variance explain is >95%
; 95% is arbitrary
            varsA = fltarr(mop_dim, /nozero)
            sumsA = 0
            for ik=0,mop_dim-1  do begin
               sumsA = sumsA + transA[ik,ik]
            endfor
            for ik=0,mop_dim-1 do begin 
               varsA[ik] = transA[ik,ik]/sumsA
            endfor
            cumsumA = 0
            for ik=0,mop_dim-1 do begin 
               cumsumA = cumsumA + varsA[ik]
            endfor
            nrows_leading1 = where(cumsumA ge 0.95)
            if ( nrows_leading1 ne nrows_leading0 ) then begin
               nrows_leading = max([nrows_leading0,nrows_leading1])
            endif else begin
               nrows_leading = nrows_leading1
            endelse
;
; what needs to be assimilated
; output only the leading components --using the truncation above
            case output_rows_leading of
               0: begin
                  valid_nrows = nrows_leading
                  output_start_row = 0
                  output_end_row   = nrows_leading-1
               end
               1: begin
                  valid_nrows = 1
                  output_start_row = 0
                  output_end_row   = 0
               end
               2: begin
                  valid_nrows = mop_dim
                  output_start_row = 0
                  output_end_row   = mop_dim-1
               end
            endcase
;
; ========================================================================
; finally output the variables in ascii
; yes, in ascii -- this is really for my own convenience
; it's not computationally efficient but it makes easier debugging
; besides this is only a temp file for DART to use
; ========================================================================
;
; QC -> only output values with qstatus=0
            if (qstatus eq 0) then  begin
               allqc_count = allqc_count + 1.0
;
;=========================================================================
               if (do_DART_input eq 1) then begin
;
; note that the format is for mopitt_dim levels
; mopittlev is also mopitt_dim levels
; disregard mop_dim to mopitt_dim output
; disregard mopitt_dim-mop_dim levels in mopittlev
; while i think the better approach is to just output corresponding mopittlev
; it is harder to implement
;
                  if (apm_no_transform eq 'false') then begin
                     if (version eq 'v3') then begin
                        if ( valid_nrows gt 0 ) then begin
                           printf, unit, valid_nrows, sec[k], mop_dim, mopittlev, lat[k], lon[k], format='(12(e14.6))'
                           for ik = output_start_row, output_end_row do begin
; index --> which component?
                              printf, unit, ik+1, format='(1(e14.6))'
; new retrieval
                              printf, unit, yn[ik], format='(1(e14.6))'
; new retrieval error
                              printf, unit, e2n[ik], format='(1(e14.6))'
; transform prior 
                              printf, unit, transImAxa[ik], format='(1(e14.6))'
; transformed averaging kernel
                              printf, unit, (transA[*,ik]), format='(7(e14.6))'
                           endfor
                        endif
                     endif else begin ; version 4 or 5
                        if ( valid_nrows gt 0 ) then begin
                           printf, unit, valid_nrows, sec[k], mop_dim, mopittlev, lat[k], lon[k], format='(15(e14.6))'
                           for ik = output_start_row, output_end_row do begin
; index --> which component?
                              printf, unit, ik+1, format='(1(e14.6))'
; new retrieval
                              printf, unit, yn[ik], format='(1(e14.6))'
; new retrieval error
                              printf, unit, e2n[ik], format='(1(e14.6))'
; transform prior 
                              printf, unit, transImAxa[ik], format='(1(e14.6))'
; transformed averaging kernel
                              printf, unit, (transA[*,ik]), format='(10(e14.6))'
                           endfor
                        endif
                     endelse
                  endif ; apm_no_transform
;
; Code to write no_transform data
                  if (apm_no_transform eq 'true') then begin
                     if (version eq 'v3') then begin
                        printf, unit, 'NO_SVD_TRANS', sec[k], lat[k], lon[k], $
                        mop_dim, dfs, format='(a15,19(e14.6))'
; effective pressure levels
                        printf, unit, mopittlev(7-fix(mop_dim):6), format='(10(e14.6))'
; retrieval
                        printf, unit, x, format='(10(e14.6))'
; prior retrieval
                        printf, unit, xa, format='(10(e14.6))'
; averaging kernel
                        printf, unit, transpose(A), format='(100(e14.6))'
; prior error covariance
                        printf, unit, transpose(Ca), format='(100(e14.6))'
; retrieval error covariance
                        printf, unit, transpose(Cx), format='(100(e14.6))'
; measurment error covariance
                        printf, unit, transpose(Cm), format='(100(e14.6))'
; total column
                        printf, unit, cocol0[k],cocol1[k], format='(2(e14.6))'
                     endif else begin ; version 4 or 5
                        printf, unit, 'NO_SVD_TRANS', sec[k], lat[k], lon[k], $
                        mop_dim, dfs, format='(a15,16(e14.6))'
; effective pressure levels
                        printf, unit, mopittlev(10-fix(mop_dim):9), format='(10(e14.6))'
; retrieval
                        printf, unit, x, format='(10(e14.6))'
; prior retrieval
                        printf, unit, xa, format='(10(e14.6))'
; averaging kernel
                        printf, unit, transpose(A), format='(100(e14.6))'
; prior error covariance
                        printf, unit, transpose(Ca), format='(100(e14.6))'
; retrieval error covariance
                        printf, unit, transpose(Cx), format='(100(e14.6))'
; measurment error covariance
                        printf, unit, transpose(Cm), format='(100(e14.6))'
; total column
                        printf, unit, cocol0[k],cocol1[k], format='(2(e14.6))'
                     endelse
                  endif ; apm_no_transform
               endif ; do_DART_input
;
;=========================================================================
; output station diagnostics 
               if ( do_station_output eq 1 ) then begin
                  if (version eq 'v3') then begin
                     for istation = 0L, ntsloc-1 do begin
                        unit_temp = unit_array[istation]
                        if ( ( lon[k]+180 ge lontsloc[istation]+180 - drad[istation] ) and $
                        ( lon[k]+180 lt lontsloc[istation]+180 + drad[istation] ) and $
                        ( lat[k]+90  ge lattsloc[istation]+90  - drad[istation] ) and $
                        ( lat[k]+90  lt lattsloc[istation]+90  + drad[istation] ) ) then begin 
                           printf, unit_temp, sec[k], lat[k], lon[k], psurf[k], mop_dim, dfs, sza[k], cloud[k], sind[k], apriori_contrib, format='(10(e14.6))'
                           printf, unit_temp, yn[*], format='(7(e14.6))'
                           printf, unit_temp, co[*], format='(7(e14.6))'
                           printf, unit_temp, e2n[*], format='(7(e14.6))'
                           printf, unit_temp, coerr[*], format='(7(e14.6))'
                           printf, unit_temp, priorerr[*], format='(7(e14.6))'
                           printf, unit_temp, transImAxa[*], format='(7(e14.6))'
                           printf, unit_temp, ImAxa[*], format='(7(e14.6))'
                           printf, unit_temp, prior[*], format='(7(e14.6))'
                           printf, unit_temp, eigenvalues[*], format='(7(e14.6))'
                           for ik = 0, mopitt_dim-1 do begin
                              if (ik lt mop_dim ) then begin
                                 printf, unit_temp, (transA[*,ik]), format='(7(e14.6))'
                              endif else begin
                                 printf, unit_temp, (dummy_var[ik]), format='(7(e14.6))'
                              endelse
                           endfor
                           for ik = 0, mopitt_dim-1 do begin
                              if (ik lt mop_dim ) then begin
                                 printf, unit_temp, (A[*,ik]), format='(7(e14.6))'
                              endif else begin
                                 printf, unit_temp, (dummy_var[ik]), format='(7(e14.6))'
                              endelse
                           endfor
                           for ik = 0, mopitt_dim-1 do begin
                              if (ik lt mop_dim ) then begin
                                 printf, unit_temp, (Cmn[*,ik]), format='(7(e14.6))'
                              endif else begin
                                 printf, unit_temp, (dummy_var[ik]), format='(7(e14.6))'
                              endelse
                           endfor
                           for ik = 0, mopitt_dim-1 do begin
                              if (ik lt mop_dim ) then begin
                                 printf, unit_temp, (Cm[*,ik]), format='(7(e14.6))'
                              endif else begin
                                 printf, unit_temp, (dummy_var[ik]), format='(7(e14.6))'
                              endelse
                           endfor
                           for ik = 0, mopitt_dim-1 do begin
                              if (ik lt mop_dim ) then begin
                                 printf, unit_temp, (Ca[*,ik]), format='(7(e14.6))'
                              endif else begin
                                 printf, unit_temp, (dummy_var[ik]), format='(7(e14.6))'
                              endelse
                           endfor
                           for ik = 0, mopitt_dim-1 do begin
                              if (ik lt mop_dim ) then begin
                                 printf, unit_temp, (Cx[*,ik]), format='(7(e14.6))'
                              endif else begin
                                 printf, unit_temp, (dummy_var[ik]), format='(7(e14.6))'
                              endelse
                           endfor
                           for ik = 0, mopitt_dim-1 do begin
                              if (ik lt mop_dim ) then begin
                                 printf, unit_temp, (Cm_dummy[*,ik]), format='(7(e14.6))'
                              endif else begin
                                 printf, unit_temp, (dummy_var[ik]), format='(7(e14.6))'
                              endelse
                           endfor
                        endif ; lat/lon station 
                     endfor   ; number of stations
                  endif else begin ; version 4 or 5
                     for istation = 0L, ntsloc-1 do begin
                        unit_temp = unit_array[istation]
                        if ( ( lon[k]+180 ge lontsloc[istation]+180 - drad[istation] ) and $
                        ( lon[k]+180 lt lontsloc[istation]+180 + drad[istation] ) and $
                        ( lat[k]+90  ge lattsloc[istation]+90  - drad[istation] ) and $
                        ( lat[k]+90  lt lattsloc[istation]+90  + drad[istation] ) ) then begin  
                           printf, unit_temp, sec[k], lat[k], lon[k], psurf[k], mop_dim, dfs, sza[k], cloud[k], sind[k], apriori_contrib, format='(10(e14.6))'
                           printf, unit_temp, yn[*], format='(10(e14.6))'
                           printf, unit_temp, co[*], format='(10(e14.6))'
                           printf, unit_temp, e2n[*], format='(10(e14.6))'
                           printf, unit_temp, coerr[*], format='(10(e14.6))'
                           printf, unit_temp, priorerr[*], format='(10(e14.6))'
                           printf, unit_temp, transImAxa[*], format='(10(e14.6))'
                           printf, unit_temp, ImAxa[*], format='(10(e14.6))'
                           printf, unit_temp, prior[*], format='(10(e14.6))'
                           printf, unit_temp, eigenvalues[*], format='(10(e14.6))'
                           for ik = 0, mopitt_dim-1 do begin
                              if (ik lt mop_dim ) then begin
                                 printf, unit_temp, (transA[*,ik]), format='(10(e14.6))'
                              endif else begin
                                 printf, unit_temp, (dummy_var[ik]), format='(10(e14.6))'
                              endelse 
                           endfor
                           for ik = 0, mopitt_dim-1 do begin
                              if (ik lt mop_dim ) then begin
                                 printf, unit_temp, (A[*,ik]), format='(10(e14.6))'
                              endif else begin
                                 printf, unit_temp, (dummy_var[ik]), format='(10(e14.6))'
                              endelse 
                           endfor
                           for ik = 0, mopitt_dim-1 do begin
                              if (ik lt mop_dim ) then begin
                                 printf, unit_temp, (Cmn[*,ik]), format='(10(e14.6))'
                              endif else begin
                                 printf, unit_temp, (dummy_var[ik]), format='(10(e14.6))'
                              endelse 
                           endfor
                           for ik = 0, mopitt_dim-1 do begin
                              if (ik lt mop_dim ) then begin
                                 printf, unit_temp, (Cm[*,ik]), format='(10(e14.6))'
                              endif else begin
                                 printf, unit_temp, (dummy_var[ik]), format='(10(e14.6))'
                              endelse 
                           endfor
                           for ik = 0, mopitt_dim-1 do begin
                              if (ik lt mop_dim ) then begin
                                 printf, unit_temp, (Ca[*,ik]), format='(10(e14.6))'
                              endif else begin
                                 printf, unit_temp, (dummy_var[ik]), format='(10(e14.6))'
                              endelse
                           endfor
                           for ik = 0, mopitt_dim-1 do begin
                              if (ik lt mop_dim ) then begin
                                 printf, unit_temp, (Cx[*,ik]), format='(10(e14.6))'
                              endif else begin
                                 printf, unit_temp, (dummy_var[ik]), format='(10(e14.6))'
                              endelse
                           endfor
                           for ik = 0, mopitt_dim-1 do begin
                              if (ik lt mop_dim ) then begin
                                 printf, unit_temp, (Cm_dummy[*,ik]), format='(10(e14.6))'
                              endif else begin
                                 printf, unit_temp, (dummy_var[ik]), format='(10(e14.6))'
                              endelse
                           endfor
                        endif ; lat/lon of station
                     endfor   ; number of stations
                  endelse ; version
               endif   ; do_station_output
            endif   ; QC --qstatus for numerical issues
         endif 	; QC --apriori contribution 
      endif	; QC -- most quality control
   endfor		; MOPITT pixels (k data) 
;    
; close files
   if ( do_DART_input eq 1 ) then begin
      close, unit
   endif
;
   if ( do_station_output eq 1 ) then begin
      for istation = 0L, ntsloc-1 do begin
         unit_temp = unit_array[istation]
         close,unit_temp 
      endfor
   endif
;
; print counters
   print, 'BIN TIME'
   print, bin_beg, bin_end
   print, 'QC Count'
   print, allqc_count 
   print, 'ALL Pixels Count'
   print, allpix_count
   print, 'Count (%)'
   print, allqc_count*100.0/allpix_count
;
   print, '================================' 
   print, 'IDL SVD transformation DONE for ', mopitt_input_file
   print, '================================'
   print, ' '
end    ; end of mopitt_extract_svd_transform
