
#from numarray import *
import numpy as np
import h5py

#=======================================================================
# subroutines for mopitt_extract_svd_transform
# based on mopitt_extract_intexb.pro
#=======================================================================
# Get the Vdata information from an HDF file
def get_vd(filename, varname):
   n_params = 2
   print(filename)
   file_id = h5py.File(filename, 'r')
   vd_ref = hdf_vd_find(file_id, strtrim(varname, 2))
   vdata = hdf_vd_attach(file_id, vd_ref)
   nread = hdf_vd_read(vdata, var)
   hdf_vd_detach(vdata)
   return var

#
# Get the Scientific Data information from an HDF file
def read_mopitt(filename, varname):
   n_params = 2
   
   sd_id = hdf_sd_start(filename, read=True)
   index = hdf_sd_nametoindex(sd_id, varname)
   sds_id = hdf_sd_select(sd_id, index)
   hdf_sd_getdata(sds_id, dat)
   hdf_sd_endaccess(sds_id)
   hdf_sd_end(sd_id)
   return dat

#
#=======================================================================
# main IDL routine
# needs read_mopitt, get_vd,
# needs calc_avgker_v3, mopitt_v4_apriori.dat and read_aprior_dat_v3 for V3
# afa change output_nrows_leading to output_rows_leading
#=======================================================================
def mopitt_extract_no_transform_rt(inf, outf, bin_beg, bin_end, lon_min, lon_max, lat_min, lat_max):
#=======================================================================
# Code to read MOPITT data V3 or V4
# Outputs data to an ascii file for DART input
# Outputs station data to an ascii file for diagnostics
# written by Ave Arellano (NCAR)
#
# Notes:
# Need all the functions in the same directory.
# to run:
#   IDL> .r mopitt_extract_svd_transform.pro
#   IDL> mopitt_extract_svd_transform
#
# But now, this is called by a shell script to process DART MOPITT obs
#   inf 		--> input file
#   outf 	--> output file
#   bin_beg      --> beginning hour of the bin  (follows DART 6-hourly bins)
#   bin_end      --> end hour of the bin (follows DART 6-hourly bins)
#   num_version  --> integer for MOPITT version (3 or 4)
#   what_cov     --> covariance (3 or 5) MOPITT has two versions for v4
#   do_DART_input --> integer 1 or 0 to output ascii file for DART create_mopitt_obs_sequence
#   do_station_output --> integer 1 or 0 to output station data
#                        see code below for station locations
#   output_rows_leading --> how many leading components to assimilate?
#   sband  --> spectral band (if tir, nir or tirnir)
#   apm_no_transform --> switch to ignorescaling/scd transformation
#   when saving MOPITT data
#=======================================================================
# floating underflow in la_svd routines (compared output with matlab)
# seems to be very similar --suppress exception for now
   n_params = 8
   def _ret():  return (inf, outf, bin_beg, bin_end, lon_min, lon_max, lat_min, lat_max)
   
   _sys_except = 0
   #
   print ('file in  ', inf    ) 
   print ('file out ', outf   ) 
   print ('bin_str  ', bin_beg) 
   print ('bin end  ', bin_end) 
   print ('lon min  ', lon_min) 
   print ('lon max  ', lon_max) 
   print ('lat min  ', lat_min) 
   print ('lat max  ', lat_max) 
   #
   num_version = 5
   what_cov = 3
   do_dart_input = 1
   do_station_output = 0
   output_rows_leading = 2
   sband = 'tirnir'
   apm_no_transform = 'true'
   #
   _expr = num_version
   if _expr == 3:   
      version = 'v3'#
   elif _expr == 4:   
      version = 'v4'#
   elif _expr == 5:   
      version = 'v5'#
   else:
      raise RuntimeError('no match found for expression')
   #
   # the two versions have different number of vertical levels
   if (version == 'v3'):   
      #
      # note that mopittlev [0] is psurf (hPa)
      mopittpress = [1000., 850., 700., 500., 350., 250., 150.]
   else:   
      #
      # note that mopittlev [0] is psurf (hPa)
      mopittpress = [1000., 900., 800., 700., 600., 500., 400., 300., 200., 100.]
      #
      # note that covariance in v4 are to be calculated
      # prior error covariance is fixed --see V4 User's Guide
      # set prior covariance parameters
      if (what_cov == 3):   
         prior_error = 0.3 # in log 
      else:   
         prior_error = 0.5 # in log
      delta_pressure_lev = 100. # hPa
      log10e = np.log10(np.exp(1))
      c0 = (prior_error * log10e) ** 2
      pc2 = delta_pressure_lev ** 2
   mopitt_dim = len(mopittpress)
   #
   # debug level (debug=0 if no printouts)
   debug = 0
   #
   #=======================================================================
   # assign station locations
   # define stations here for now
   # in the future, we can read a file of lat/lon/drad
   # Saskatchewan, NE Pacific, American Samoa, Ascension Is, Seychelles,
   # Pittsburg,US, Houston, US, Baltic Sea, Indian Ocean, NW Aus 1, NW Aus 2,
   # Prague, Nigeria, Beijing, Delhi, Midway Island, Brazilia, Indonesia
   #
   # station center longitude in degrees
   lontsloc = [-105.45, -150.00, -170.57, -14.42, 55.17, -80.00, -95.00, 17.07, 123.00, 121.00, 129.00, 15.00, 10.00, 117.00, 75.00, -175.00, -45.00, 117.0]
   #
   # station center latitude in degress
   lattsloc = [50.33, 40.00, -14.24, -7.92, -4.67, 40.00, 30.00, 55.42, -12.00, -21.00, -21.00, 50.00, 10.00, 39.00, 30.00, 30.00, -45.00, -2.5]
   #
   # radius of influence in degrees
   drad = [1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 2.5]
   #
   # number of stations
   ntsloc = len(lontsloc)
   #
   #=======================================================================
   # QUALITY CONTROLS
   # set QC here -- based on MOPITT Data Quality Statement
   # these settings are very ad hoc !!! see personal comments
   # edit if necessary
   
   # dofs (i dont think dof is higher than 2 for MOPITT)
   # from the pdfs of dofs, the threshold below appears to be 'outliers'
   #
   if sband == 'tir':   
      dofs_threshold_low = 0.5
      dofs_threshold_hi = 2.0
   elif sband == 'nir':   
      dofs_threshold_low = 0.5
      dofs_threshold_hi = 1.0
   elif sband == 'tirnir':   
      dofs_threshold_low = 0.5
      dofs_threshold_hi = 3.0
   else:
      raise RuntimeError('no match found for expression')
   #
   # pick daytime or nighttime or all -- there appears to be some contention
   # whether or not there is bias in nighttime retrievals --
   sza_day = 90.0          # all day data
   sza_nit = 180.0         # all day and night data
   #
   # polar regions --there are potential for biases near the poles
   day_lat_edge_1 = -70.0  # 70S
   day_lat_edge_2 = 70.0  # 70N
   nit_lat_edge_1 = -60.0  # 60S
   nit_lat_edge_2 = 60.0  # 60N
   #
   # retrieval error as fraction of its  prior error
   # this is very ad hoc based on percent apriori (post error/prior error)
   if (version != 'v3'):   
      max_error_reduction_qc = 1.00  # it's difficult to set this in log 
      # make this 95% and let dofs be its qc
   else:   
      max_error_reduction_qc = 0.5 # in v3 this is usually our qc
   #
   # end of QC
   #=======================================================================
   #
   # convert bins into seconds
   bin_beg = bin_beg * 60.0 * 60.0
   bin_end = bin_end * 60.0 * 60.0
   #
   # dummy variable (for output purposes)
   dummy_var = [-9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999]
   #
   # Define MOPITT file name
   mopitt_input_file = inf
   mopitt_output_file = outf
   #
   # echo what we are processing here
   print ('accessing MOPITT file: ', mopitt_input_file ) 
   print ('writing to ascii file: ', mopitt_output_file) 
   #
   #=======================================================================
   # read MOPITT file
   #=======================================================================
   # Read Seconds in Day
   name = 'Seconds in Day'
   sec1 = get_vd(mopitt_input_file, name)
   nx = array(array(sec1, copy=0).nelements() - 1, copy=0).astype(Int32)
   sec = array(sec1, copy=0).astype(Float32)
   #
   # Read Latitude;
   name = 'Latitude'
   lat = get_vd(mopitt_input_file, name)
   #
   # Read Longitude;
   name = 'Longitude'
   lon = get_vd(mopitt_input_file, name)
   #
   # Read Cloud Description
   name = 'Cloud Description'
   cloud = get_vd(mopitt_input_file, name)
   #
   if (version != 'v3'):   
      # Read Surface Pressure
      name = 'Surface Pressure'
      psurf = get_vd(mopitt_input_file, name)
   else:   
      #
      # Read Retrieval Bottom Pressure
      name = 'Retrieval Bottom Pressure'
      psurf = read_mopitt(mopitt_input_file, name)
      psurf = reform(psurf[:,0])
   #
   # Read Solar Zenith Angle
   name = 'Solar Zenith Angle'
   sza = get_vd(mopitt_input_file, name)
   #
   if (version != 'v3'):   
      #
      # Read Surface Indicator
      name = 'Surface Index'
      sind = get_vd(mopitt_input_file, name)
   else:   
      #
      # Read Surface Indicator
      name = 'Surface Indicator'
      sind = get_vd(mopitt_input_file, name)
   #
   if (version != 'v3'):   
      #
      # Read CO Total Colum
      name = 'Retrieved CO Total Column'
      cocol = read_mopitt(mopitt_input_file, name)
      cocol0 = reform(cocol[:,0])
      cocol1 = reform(cocol[:,1])
   else:   
      #
      # Read CO Total Column
      name = 'CO Total Column'
      cocol = read_mopitt(mopitt_input_file, name)
      cocol0 = reform(cocol[:,0])
      cocol1 = reform(cocol[:,1])
   #
   if (version != 'v3'):   
      #
      # Read DOFS
      name = 'Degrees of Freedom for Signal'
      dofs = get_vd(mopitt_input_file, name)
   #
   if (version != 'v3'):   
      #
      # Read Retrieved Non-Surface CO Mixing Ratio
      name = 'Retrieved CO Mixing Ratio Profile'
      codata = read_mopitt(mopitt_input_file, name)
      comix = reform(codata[:,:,0])
      comixerr = reform(codata[:,:,1])
      #
      # Read Retrieved CO Surface Mixing Ratio
      name = 'Retrieved CO Surface Mixing Ratio'
      codata = read_mopitt(mopitt_input_file, name)
      scomix = reform(codata[:,0])
      scomixerr = reform(codata[:,1])
      #
      # Read Retrieval Averaging Kernel Matrix
      name = 'Retrieval Averaging Kernel Matrix'
      avgker = read_mopitt(mopitt_input_file, name)
      #
      # Read A Priori Surface CO Mixing Ratio
      name = 'A Priori CO Surface Mixing Ratio'
      codata = read_mopitt(mopitt_input_file, name)
      sperc = reform(codata[:,0])
      spercerr = reform(codata[:,1])
      #
      # Read A Priori CO Mixing Ratio Profile
      name = 'A Priori CO Mixing Ratio Profile'
      codata = read_mopitt(mopitt_input_file, name)
      perc = reform(codata[:,:,0])
      percerr = reform(codata[:,:,1])
      #
      if (version == 'v5'):   
         #
         # Read Retrieval Error Covariance Matrix
         name = 'Retrieval Error Covariance Matrix'
         covmatrix = read_mopitt(mopitt_input_file, name)
   else:   
      #
      # Read CO Mixing Ratio
      name = 'CO Mixing Ratio'
      codata = read_mopitt(mopitt_input_file, name)
      comix = reform(codata[:,:,0])
      comixerr = reform(codata[:,:,1])
      #
      # Read Retrieval Bottom CO Mixing Ratio
      name = 'Retrieval Bottom CO Mixing Ratio'
      codata = read_mopitt(mopitt_input_file, name)
      scomix = reform(codata[:,0])
      scomixerr = reform(codata[:,1])
      #
      # Read Retrieval Error Covariance Matrix
      name = 'Retrieval Error Covariance Matrix'
      covmatrix = read_mopitt(mopitt_input_file, name)
      covmatrix = covmatrix
   #
   #=======================================================================
   # Open output file
   #=======================================================================
   #
   # initialize unit numbers for station data
   if (do_station_output == 1):   
      unit_array = intarr(ntsloc)
   #
   # in cases where the file moves over to another day
   if (bin_beg == 0):   
      #
      #open previous file
      if (do_dart_input == 1):   
         openu(unit, mopitt_output_file, get_lun=True)
         dummya = ' '
         while logical_not(eof(unit)):
            readf(unit, dummya)
      #
      # file for station diagnostics
      if (do_station_output == 1):   
         for istation in arange(0, (ntsloc - 1)+(1)):
            if (istation < 10):   
               station_mopitt_output_file = strtrim(mopitt_output_file + '.station_0' + string(istation, format='(i1)'))
            else:   
               station_mopitt_output_file = strtrim(mopitt_output_file + '.station_' + string(istation, format='(i2)'))
            openu(unit_temp, station_mopitt_output_file, get_lun=True)
            unit_array[istation] = unit_temp
            dummya = ' '
            while logical_not(eof(unit_temp)):
               readf(unit_temp, dummya)
      #
      # else open a new file
   else:   
      #
      # file for DART input
      if (do_dart_input == 1):   
         openw(unit, mopitt_output_file, get_lun=True)
      #
      # file for station diagnostics
      if (do_station_output == 1):   
         for istation in arange(0, (ntsloc - 1)+(1)):
            if (istation < 10):   
               station_mopitt_output_file = strtrim(mopitt_output_file + '.station_0' + string(istation, format='(i1)'))
            else:   
               station_mopitt_output_file = strtrim(mopitt_output_file + '.station_' + string(istation, format='(i2)'))
            openw(unit_temp, station_mopitt_output_file, get_lun=True)
            unit_array[istation] = unit_temp # bin_beg
   #
   #=======================================================================
   # define/initialize other variables here
   # log10 conversion for d ln(VMR) = d(VMR)/VMR = d log10(VMR) /log10(e)
   log10e = alog10(exp(1))
   #
   # qc count (most of qc - dofs, time, sza, partial qc, high lat)
   qc_count = 0.0
   #
   # qc for apriori contribution (subset of qc_count)
   qc_count2 = 0.0
   #
   # qc for all (subset of qc_count2)
   allqc_count = 0.0
   #
   # all pixel count
   allpix_count = 0.0
   #=======================================================================
   #
   # Now, loop through each pixels
   for k in arange(0, (nx)+(1)):
      allpix_count = allpix_count + 1.0
      #
      #=====================================================
      # first get all the necessary arrays
      #
      #==============================================
      # For V3, half of the posterior error covariance is reported
      # we need to construct the full covariance and averaging kernel
      # we need the prior profile and error covariance to do this
      # A = I - Cx Ca^-1
      #==============================================
      _expr = version
      if _expr == v3:   
         cov_retr = dblarr(mopitt_dim, mopitt_dim)
         cov_retr[0,0] = (scomixerr[k] * 1e-9) ** 2 # ppb to VMR
         for ik in arange(1, (mopitt_dim - 1)+(1)):
            cov_retr[ik,ik] = (comixerr[k,ik - 1] * 1e-9) ** 2
         cov_retr[1:(mopitt_dim - 1)+1,0] = covmatrix[k,0:6,0]
         cov_retr[2:(mopitt_dim - 1)+1,1] = covmatrix[k,6:11,0]
         cov_retr[3:(mopitt_dim - 1)+1,2] = covmatrix[k,11:15,0]
         cov_retr[4:(mopitt_dim - 1)+1,3] = covmatrix[k,15:18,0]
         cov_retr[5:(mopitt_dim - 1)+1,4] = covmatrix[k,18:20,0]
         cov_retr[6:(mopitt_dim - 1)+1,5] = covmatrix[k,20:21,0]
         for j in arange(0, 6):
            for ik in arange(1, 7):
               cov_retr[j,ik] = cov_retr[ik,j]
         #
         # call subroutine to calculate averaging kernel A, given full error covariance Cx
         # based on Louisa Emmons' code
         calc_avgker_v3(cov_retr, psurf[k], a, mop_dim, mopittlev, status, cx, levind, prior, covmat_ap)
         ca = covmat_ap
         dfs = trace(a)
         #
         mopittlev = mopittpress
         #
         # initialize qc status here
         if status == 1:   
            qstatus = 1
         else:   
            qstatus = 0
         mopittlev = mopittpress
         #
         # check number of levels
         # this has been check in calc_avgker_v3 but
         # let's do it again here --mopittlev has slightly different format
         # it's still 7 levels but psurf replaces the first level
         # mop_dim --> effective number of levels
         _expr = 1
         if _expr == ((psurf[k] > 850.0)):   
            mopittlev = mopittpress
            mopittlev[0] = psurf[k]
            mop_dim = 7
         elif _expr == (bitwise_and((psurf[k] <= 850.0), (psurf[k] > 700.0))):   
            mopittlev = mopittpress
            mopittlev[1] = psurf[k]
            mop_dim = 6
         elif _expr == (bitwise_and((psurf[k] <= 700.0), (psurf[k] > 500.0))):   
            mopittlev = mopittpress
            mopittlev[2] = psurf[k]
            mop_dim = 5
         elif _expr == (bitwise_and((psurf[k] <= 500.0), (psurf[k] > 350.0))):   
            mopittlev = mopittpress
            mopittlev[3] = psurf[k]
            mop_dim = 4
         else:   
            print ('MOPITT Surface Level Too High')
            qstatus = 1 # version v3
      elif _expr == v4:   
         #
         #==============================================
         # For V4, we need to calculate Cx, given A
         # Calculate Cm (see email by Merritt 12/11/2008)
         # Cx = Cs + Cm
         # A = I - Cx Ca^-1 so Cx = (I-A) Ca
         # Cs = (A-I)Ca(A-I)^T
         # Cm = (I-A)Ca(I+(A-I)^T)
         #==============================================
         #
         qstatus = 0
         mopittlev = mopittpress
         _expr = 1
         if _expr == ((psurf[k] > 900.0)):   
            mopittlev = mopittpress
            mopittlev[0] = psurf[k]
            mop_dim = 10
         elif _expr == (bitwise_and((psurf[k] <= 900.0), (psurf[k] > 800.0))):   
            mopittlev = mopittpress
            mopittlev[1] = psurf[k]
            mop_dim = 9
         elif _expr == (bitwise_and((psurf[k] <= 800.0), (psurf[k] > 700.0))):   
            mopittlev = mopittpress
            mopittlev[2] = psurf[k]
            mop_dim = 8
         elif _expr == (bitwise_and((psurf[k] <= 700.0), (psurf[k] > 600.0))):   
            mopittlev = mopittpress
            mopittlev[3] = psurf[k]
            mop_dim = 7
         elif _expr == (bitwise_and((psurf[k] <= 600.0), (psurf[k] > 500.0))):   
            mopittlev = mopittpress
            mopittlev[4] = psurf[k]
            mop_dim = 6
         elif _expr == (bitwise_and((psurf[k] <= 500.0), (psurf[k] > 400.0))):   
            mopittlev = mopittpress
            mopittlev[5] = psurf[k]
            mop_dim = 5
         else:   
            print ('MOPITT Surface Level Too High')
            qstatus = 1
         
         #
         # Construct prior covariance matrix
         # based on MOPITT V4 User Guide
         covmat_ap = zeros([mop_dim, mop_dim], Float32)
         d_mop_dim = mopitt_dim - mop_dim
         for ii in arange(d_mop_dim, (mopitt_dim - 1)+(1)):
            for jj in arange(d_mop_dim, (mopitt_dim - 1)+(1)):
               tmp = c0 * (exp(-((mopittlev[ii] - mopittlev[jj]) ** 2) / pc2))
               covmat_ap[jj - d_mop_dim,ii - d_mop_dim] = tmp
         #
         # change notation (for my case)
         ca = covmat_ap
         #
         # Invert the a priori covariance matrix
         invca = invert(ca, status)
         #
         # status = 0: successful
         # status = 1: singular array
         # status = 2: warning that a small pivot element was used and that
         #             significant accuracy was probably lost.
         # Status is usually 2
         #
         if status == 1:   
            qstatus = 1
         else:   
            qstatus = 0
         #
         # change notation ( for clarity )
         mop_a = avgker[k,:,:]
         #
         # need to do transpose (IDL column-major)
         mop_a = transpose(mop_a)
         #
         # truncate to effective number of levels
         a = zeros([mop_dim, mop_dim], Float32)
         a = mop_a[mopitt_dim - mop_dim:(mopitt_dim - 1)+1,mopitt_dim - mop_dim:(mopitt_dim - 1)+1]
         i = identity(mop_dim)
         #
         # now calculate posterior covariance
         cx = matrixmultiply((i - a), ca)
         #
         # assign dfs
         dfs = dofs[k] # version v4
      elif _expr == v5:   
         qstatus = 0
         mopittlev = mopittpress
         #
         # check number of levels
         # mop_dim --> effective number of levels
         _expr = 1
         if _expr == ((psurf[k] > 900.0)):   
            mopittlev = mopittpress
            mopittlev[0] = psurf[k]
            mop_dim = 10
         elif _expr == (bitwise_and((psurf[k] <= 900.0), (psurf[k] > 800.0))):   
            mopittlev = mopittpress
            mopittlev[1] = psurf[k]
            mop_dim = 9
         elif _expr == (bitwise_and((psurf[k] <= 800.0), (psurf[k] > 700.0))):   
            mopittlev = mopittpress
            mopittlev[2] = psurf[k]
            mop_dim = 8
         elif _expr == (bitwise_and((psurf[k] <= 700.0), (psurf[k] > 600.0))):   
            mopittlev = mopittpress
            mopittlev[3] = psurf[k]
            mop_dim = 7
         elif _expr == (bitwise_and((psurf[k] <= 600.0), (psurf[k] > 500.0))):   
            mopittlev = mopittpress
            mopittlev[4] = psurf[k]
            mop_dim = 6
         elif _expr == (bitwise_and((psurf[k] <= 500.0), (psurf[k] > 400.0))):   
            mopittlev = mopittpress
            mopittlev[5] = psurf[k]
            mop_dim = 5
         else:   
            print ('MOPITT Surface Level Too High')
            qstatus = 1
         
         #
         # Construct prior covariance matrix
         # based on MOPITT V4 User Guide
         covmat_ap = zeros([mop_dim, mop_dim], Float32)
         d_mop_dim = mopitt_dim - mop_dim
         for ii in arange(d_mop_dim, (mopitt_dim - 1)+(1)):
            for jj in arange(d_mop_dim, (mopitt_dim - 1)+(1)):
               tmp = c0 * (exp(-((mopittlev[ii] - mopittlev[jj]) ** 2) / pc2))
               covmat_ap[jj - d_mop_dim,ii - d_mop_dim] = tmp
         #
         # change notation (for my case)
         ca = covmat_ap
         #
         # Invert the a priori covariance matrix
         invca = invert(ca, status)
         #
         # status = 0: successful
         # status = 1: singular array
         # status = 2: warning that a small pivot element was used and that
         #             significant accuracy was probably lost.
         # Status is usually 2
         #
         if status == 1:   
            qstatus = 1
         else:   
            qstatus = 0
         #
         # change notation ( for clarity )
         mop_a = avgker[k,:,:]
         #
         # need to do transpose (IDL column-major)
         mop_a = transpose(mop_a)
         #
         # truncate to effective number of levels
         a = zeros([mop_dim, mop_dim], Float32)
         a = mop_a[mopitt_dim - mop_dim:(mopitt_dim - 1)+1,mopitt_dim - mop_dim:(mopitt_dim - 1)+1]
         i = identity(mop_dim)
         #
         # change notation (for my case)
         mop_cx = covmatrix[k,:,:]
         #
         # need to do transpose (IDL column-major)
         mop_cx = transpose(mop_cx)
         #
         # truncate to effective number of levels
         cx = zeros([mop_dim, mop_dim], Float32)
         cx = mop_cx[mopitt_dim - mop_dim:(mopitt_dim - 1)+1,mopitt_dim - mop_dim:(mopitt_dim - 1)+1]
         #
         # assign dfs
         dfs = dofs[k] #version v5
      else:
         raise RuntimeError('no match found for expression')
      #
      #=====================================================
      # APM: at this point AVE has full averaging kernal
      #      and covariance matrixes
      # QC: most qc applied here
      #=====================================================
      #      print, 'IDL lon, lat ', lon[k],lat[k]
      if (bitwise_and(bitwise_and(bitwise_and(bitwise_and(bitwise_and(bitwise_and(bitwise_and(bitwise_and(bitwise_and(dfs > dofs_threshold_low, dfs < dofs_threshold_hi), (logical_or((bitwise_and(bitwise_and(sza[k] <= sza_day, lat[k] > day_lat_edge_1), lat[k] < day_lat_edge_2)), (bitwise_and(bitwise_and(sza[k] >= sza_day, lat[k] > nit_lat_edge_1), lat[k] < nit_lat_edge_2))))), sec[k] >= bin_beg), sec[k] < bin_end), lat[k] >= lat_min), lat[k] <= lat_max), lon[k] >= lon_min), lon[k] <= lon_max), qstatus == 0)):   
         #     if (lat[k] ge lat_min AND lat[k] le lat_max AND $
         #     lon[k] ge lon_min AND lon[k] le lon_max AND $
         #     qstatus eq 0) then begin
         #     if ( ( dfs gt dofs_threshold_low ) AND ( dfs lt dofs_threshold_hi ) AND $
         #     ((( sza[k] le sza_day ) AND ( lat[k] gt day_lat_edge_1 ) AND ( lat[k] lt day_lat_edge_2 ))) AND $
         #     ( sec[k] ge bin_beg ) AND (sec[k] lt bin_end ) AND $
         #     ( qstatus eq 0 ) ) then begin
         #
         print (dfs, sza[k], lat[k], lon[k], sec[k], psurf[k], qstatus)
         qc_count = qc_count + 1.0
         co = zeros([mop_dim], Float32)
         coerr = zeros([mop_dim], Float32)
         priorerr = zeros([mop_dim], Float32)
         priorerrb = zeros([mop_dim], Float32)
         if (version != 'v3'):   
            prior = zeros([mop_dim], Float32)
         #
         # assign file variables to profile quantities
         co[0] = scomix[k] * 1e-9		# in mixing ratio now
         coerr[0] = scomixerr[k] * 1e-9
         if (version != 'v3'):   
            prior[0] = sperc[k] * 1e-9
            priorerrb[0] = spercerr[k] * 1e-9 # this is from MOPITT product
         #
         ik_lev = 0
         for ik in arange(1, (mopitt_dim - 1)+(1)):
            if (perc[k,ik - 1] > 0.0):   
               ik_lev = ik_lev + 1
               prior[ik_lev] = perc[k,ik - 1] * 1e-9
               priorerrb[ik_lev] = percerr[k,ik - 1] * 1e-9 # this is from MOPITT product
               co[ik_lev] = comix[k,ik - 1] * 1e-9
               coerr[ik_lev] = comixerr[k,ik - 1] * 1e-9 # this is from MOPITT product
         #
         # here we change to co instead of prior for the normalization point
         # see notes on calculation of retrieval error
         # the reason for this is that the prior and posterior should have
         # the same normalization point for consistency
         if (version != 'v3'):   
            for ik in arange(0, (mop_dim - 1)+(1)):
               priorerr[ik] = sqrt(ca[ik,ik]) * co[ik] / log10e
         else:   
            #
            # for v3, it's not a problem since this is in VMR already
            for ik in arange(0, (mop_dim - 1)+(1)):
               priorerr[ik] = sqrt(ca[ik,ik])
         #
         # before we use 700hPa or 500 hPa level for apriori contrib
         # i think it's better to use the maximum error reduction instead
         error_reduction = zeros([mop_dim], Float32)
         for ik in arange(0, (mop_dim - 1)+(1)):
            error_reduction[ik] = (priorerr[ik] - coerr[ik]) / priorerr[ik]
         max_error_reduction = max(error_reduction, max_index)
         apriori_contrib = max_error_reduction
         #
         # QC: check error reduction qc
         if (apriori_contrib <= max_error_reduction_qc):   
            qc_count2 = qc_count2 + 1.0
            #
            # now that we have Ca, Cx, and A, we need to get xa, x and xe
            # change notation and make sure youre in log space
            # both v3 and v4 report VMR units for xa and x
            xa = transpose(alog10(prior))
            x = transpose(alog10(co))
            i = identity(mop_dim)
            #
            #======================================================================
            #
            # convert Cx (VMR) to fractional
            # convert Ca (VMR) to fractional
            # see email to Merritt (2/5/2010)
            if (version == 'v3'):   
               sigma_a = identity(mop_dim)
               for ik in arange(0, (mop_dim - 1)+(1)):
                  sigma_a[ik,ik] = log10e / co[ik]
               cx = matrixmultiply(matrixmultiply(sigma_a, cx), sigma_a)
               ca = matrixmultiply(matrixmultiply(sigma_a, ca), sigma_a)
               a = matrixmultiply(matrixmultiply(sigma_a, a), invert(sigma_a))
               #
               # recalculate xe, posterior error
               xe = zeros([mop_dim], Float32)
               for ik in arange(0, (mop_dim - 1)+(1)):
                  xe[ik] = sqrt(cx[ik,ik])
               #
               # recalculate prior error
               xe_a = zeros([mop_dim], Float32)
               for ik in arange(0, (mop_dim - 1)+(1)):
                  xe_a[ik] = sqrt(ca[ik,ik])
            else:   
               #
               # recalculate xe (same as coerr but in fractional form)
               xe = zeros([mop_dim], Float32)
               for ik in arange(0, (mop_dim - 1)+(1)):
                  xe[ik] = sqrt(cx[ik,ik])
               #
               # recalculate xe_a (same as priorerr but in fractional form)
               xe_a = zeros([mop_dim], Float32)
               for ik in arange(0, (mop_dim - 1)+(1)):
                  xe_a[ik] = sqrt(ca[ik,ik])
               #
               #==================================================================
               # this part is really for debugging
               # In v4, these are all already in fractional from
               # convert Cx to fractional VMR
               # see email to Merritt (2/5/2010)
               #==================================================================
               if (debug == 1):   
                  sigma_a = identity(mop_dim)
                  for ik in arange(0, (mop_dim - 1)+(1)):
                     sigma_a[ik,ik] = co[ik] / log10e
                  cx_vmr = matrixmultiply(matrixmultiply(sigma_a, cx), sigma_a)
                  ca_vmr = matrixmultiply(matrixmultiply(sigma_a, ca), sigma_a)
                  a_vmr = matrixmultiply(matrixmultiply(sigma_a, a), invert(sigma_a))
                  xe_a_vmr = zeros([mop_dim], Float32)
                  for ik in arange(0, (mop_dim - 1)+(1)):
                     xe_a_vmr[ik] = sqrt(ca_vmr[ik,ik])
                  #
                  # convert Cx to fractional VMR
                  # see email to Merritt (2/5/2010)
                  sigma_a = identity(mop_dim)
                  for ik in arange(0, (mop_dim - 1)+(1)):
                     sigma_a[ik,ik] = prior[ik] / log10e
                  cx_vmr_c = matrixmultiply(matrixmultiply(sigma_a, cx), sigma_a)
                  ca_vmr_c = matrixmultiply(matrixmultiply(sigma_a, ca), sigma_a)
                  a_vmr_c = matrixmultiply(matrixmultiply(sigma_a, a), invert(sigma_a))
                  xe_a_vmr_c = zeros([mop_dim], Float32)
                  for ik in arange(0, (mop_dim - 1)+(1)):
                     xe_a_vmr_c[ik] = sqrt(ca_vmr_c[ik,ik])
                  #
                  # the following print statements checks for
                  # what priorerrb is using (xa or xhat)
                  print ('prior a' ) 
                  print (xe_a_vmr  ) 
                  print ('prior b' ) 
                  print (priorerrb ) 
                  print ('prior c' ) 
                  print (xe_a_vmr_c) 
                  stop()  # debug # version 
            #
            #======================================================================
            
            # calculate prior term (I-A)xa  in x = A x_t + (I-A)xa + Gey
            # needed for obs/forward operator (prior term of expression)
            ima = (i - a)
            ami = (a - i)
            imaxa = matrixmultiply(ima, xa)
            #
            # calculate Cm --here Cx = Cm + Cs
            # where Cx is the posterior error covariance
            # Cm = < (Gey)(Gey)^T > = GSeG^T, Se is measurement noise covariance
            # Cm -> error due to measurement noise
            # Cs -> error due to smoothing (application of prior)
            # Cm = (I-A) Ca (I + (A-I)^T) = Cx (K^T Se^-1 K ) Cx
            # Cs = Cx Sa^-1 Cx
            # x = Cx K^T Se^-1 (y - Kxa)
            # A = Cx K^T Se^-1 K = G K
            #
            cm = matrixmultiply(matrixmultiply(ima, ca), (i + transpose(ami)))
            #
            # it seems that we cant get a positive definite Cm due to numerical issues
            # Cm is one order of magnitude lower than Cx --yes, it's low
            # But Cm has similar pattern with the averaging kernel A
            # while Cx resembles Ca in pattern
            # so, we can either choose to use Cx or use Cm  but with preconditioned
            # i think we should use Cm since this is how the x expression is based on
            # although i dont think it really matters a lot
            iscx = 0
            if (iscx == 1):   
               cm = cx
            #
            # Ok. Here's the SVD approach
            # ========================================================================
            # (1) We need to scale the retrieval
            #     x = xa + A(x_t-xa) + ex or x = A x_t + (I-A) xa + ex
            #     Cm  = < e_x ex^T > , < (Gey)(Gey)^T >
            #     sCm = ex^-1
            #     sCm x = ( sCm A ) x_t + ( sCm (I-A) xa )
            # ========================================================================
            
            # to do the scaling, we get the square root of Cm
            # either doing cholesky decomposition or eigenvalue/vector decomposition
            # turns out Cm is sometimes singular or not positive-definite
            # so for now, we'll use SVD
            
            #=======================================================================
            # but first, precondition Cm and make it symmetric
            # i think this is valid since most of the differences i see are
            # very small --hence errors associated with numerical linear algebra
            #
            if (iscx == 0):   
               # for some numerical reason, Cm is not symmetric
               # have problems doing eigenvalue decomposition with non-symmetric matrix
               for ik in arange(0, (mop_dim - 1)+(1)):
                  for ijk in arange(ik, (mop_dim - 1)+(1)):
                     cm[ijk,ik] = cm[ik,ijk]
               #
               # save original Cm for debugging later on
               #
               # APM: Looks like I want to save Cm_dummy
               # APM: Here are the unscaled, unrotated equivalents
               #       A   - averaging kernal
               #       Cm  - measurement error covariance
               #       xa  - prior
               #       x   - retrieval
               #
               cm_dummy = cm
               #
               # get eigenvalues and eigenvectors
               eigenvalues = la_eigenql(cm, eigenvectors=eigenvectors, status=status)
               if status != 0:   
                  print ('Cm la_eigengl did not converge')
                  print (cm, status)
                  qstatus = 1
               #
               # APM: not necessary because Cm is a covariance matrix which is
               # symmetric, positive semidefinite => all real eigenvalues >= 0
               #
               # check for complex values
               # la_eigenql readme says it outputs real eigenvectors
               # but in matlab, sometimes, eigenvalues can be complex
               # so might as well check for complex numbers
               for ik in arange(0, (mop_dim - 1)+(1)):
                  ftype = size(eigenvalues[ik], type=True)
                  if (ftype == 6):   
                     qstatus = 1
               #
               # APM: not necessary - see preceding APM comment
               #
               # precondition by removing all negative eigenvalues
               # and replace by floating point precision
               eval = identity(mop_dim)
               for ik in arange(0, (mop_dim - 1)+(1)):
                  if (eigenvalues[ik] < (machar()).eps):   
                     eval[ik,ik] = (machar()).eps
                  else:   
                     eval[ik,ik] = eigenvalues[ik]
               #
               # reconstruct covariance matrix
               cm = matrixmultiply(matrixmultiply(transpose(eigenvectors), eval), (eigenvectors)) # isCx
            #
            #=======================================================================
            # whoops, that was tough.
            # now take the inverse square-root of Cm
            # from eigenvalue decomposition
            # S = L D L^T
            # S^1/2 = L D^1/2 L^T
            # S^-1/2 = L D^-1/2 L^T
            # this is similar to SVD --we opt to use SVD here for convenience
            # S = R D L^T
            # svd(S) = sqrt(eig(S#S))
            # we can also do a cholesky decomposition which Rodgers suggested
            # spectral decomposition
            # S = T^T T
            # S^-1/2 = T^-1
            #=======================================================================
            #
            # APM: measurement covariance based scaling
            #
            # status = 0: The computation was successful
            # status =>0: The computation did not converge. The status value specifies how many superdiag did not
            #             converge to zero
            la_svd(cm, s_cm, u_cm, v_cm, status=status)
            if status != 0:   
               print ('Cm svd did not converge')
               print (cm, status)
               qstatus = 1
            #
            # get the square root of Cm
            sqrt_s_cm = zeros([mop_dim], Float32)
            for ik in arange(0, (mop_dim - 1)+(1)):
               if (s_cm[ik] <= 0.0):   
                  s_cm[ik] = (machar()).eps
               sqrt_s_cm[ik] = sqrt(s_cm[ik])
            #
            # get the inverse square root of Cm
            inv_s = identity(mop_dim)
            for ik in arange(0, (mop_dim - 1)+(1)):
               inv_s[ik,ik] = 1.0 / sqrt_s_cm[ik]
            scm = matrixmultiply(matrixmultiply(v_cm, inv_s), transpose(u_cm))
            #
            # APM: a priori covariance based scaling
            #
            # status = 0: The computation was successful
            # status =>0: The computation did not converge. The status value specifies how many superdiag did not
            #             converge to zero
            la_svd(ca, s_ca, u_ca, v_ca, status=status)
            if status != 0:   
               print ('Ca svd did not converge')
               print (ca, status)
               qstatus = 1
            #
            # get the square root of Ca
            sqrt_s_ca = zeros([mop_dim], Float32)
            for ik in arange(0, (mop_dim - 1)+(1)):
               if (s_ca[ik] < 0):   
                  s_ca[ik] = (machar()).eps
               sqrt_s_ca[ik] = sqrt(s_ca[ik])
            sqrt_ca = identity(mop_dim)
            for ik in arange(0, (mop_dim - 1)+(1)):
               sqrt_ca[ik,ik] = sqrt_s_ca[ik]
            sca = matrixmultiply(matrixmultiply(v_ca, sqrt_ca), transpose(u_ca))
            #
            # =================================================================
            # scale the whole expression
            # =================================================================
            #
            # APM this is the measurement covariance based scaling
            #
            # scale A using sCm
            sa = matrixmultiply(scm, a)
            #
            # scale Cm --> now should be identity
            # the line below is a check
            # sCms = sCm##Cm##transpose(sCm)
            # scale Ca --> this wont be use but may be useful for debugging
            scas = matrixmultiply(matrixmultiply(scm, ca), (scm))
            #
            # force sCms to be identity --this has been checked
            scms = identity(mop_dim)
            #
            # scale x
            sx = matrixmultiply(scm, x)
            #
            # scale prior term
            simaxa = matrixmultiply(scm, imaxa)
            #
            # ========================================================================
            # (2) Get SVD of scaled Ax and rotate retrieval to its maximum information
            # sA##sCa = USV^T
            # U^T ( sCm x ) = U^T ( sCm A ) x_t +  U^T (sCm (I-A) xa )
            # U^T ( sx ) = U^T ( sA ) x_t +  U^T ( sImAxa )
            # ========================================================================
            
            # from Migliorini et al 2008, they rotated the scaled covariance
            # <H'PH'^T> for EIG which is similar to getting the square root of Ca in SVD
            # see Stefano's email regarding P (2/10/2010)
            # i think it makes more sense to have the singular vectors of Ax rather than A
            # it accounts for both the variability in x and sensitivity of the retreival
            #
            # APM: Ave calculates SVD for Ax (averaging kernal time retrieval) as
            # opposed to A (averaging kernal).
            #
            # APM: NOTE TOO: sAx is the result of a RHS a priori covariance based scaling of
            # sA (the scaled averaging kernal) where the first scaling is the
            # measurement covariance based scaling
            #
            sax = matrixmultiply(sa, sca)
            #
            # take the svd of sA
            #
            # status = 0: The computation was successful
            # status =>0: The computation did not converge. The status value specifies how many superdiag did not
            #             converge to zero
            la_svd(sax, s, u, v, status=status)
            if status != 0:   
               print ('sA svd did not converge')
               print (sa, status)
               qstatus = 1
            #
            # calculate transpose(U)A
            transa = matrixmultiply(transpose(u), sa)
            #
            # need to check U if it is reflected rather than translated
            # note that transA is row major now
            # that means you need to sum the columns --
            # here we assumed that the sum of the averaging kernel rows
            # should be at least positive, if it is negative then
            # it is reflected and we should take the opposite sign
            sum_ua = total(transa, 1)
            #
            # change sign of rows of U (in matlab this is really the
            # singular vector in columns)
            for ik in arange(0, (mop_dim - 1)+(1)):
               if (sum_ua[ik] <= 0.0):   
                  for ikk in arange(0, (mop_dim - 1)+(1)):
                     u[ikk,ik] = u[ikk,ik] * (-1.0)
            #
            # recalculate transA
            transa = matrixmultiply(transpose(u), sa)
            #
            # rotate scaled Cx and Ca
            # again this is a check if it's really identity
            # Cmn = transpose(U)##sCms##U
            # rotated Ca is not really used but might be useful for debugging
            can = matrixmultiply(matrixmultiply(transpose(u), scas), u)
            #
            #force Cmn to be identity -- this has been checked
            cmn = identity(mop_dim)
            #
            # calculate new y
            yn = matrixmultiply(transpose(u), sx)
            #
            # rotate prior term
            transimaxa = matrixmultiply(transpose(u), simaxa)
            #
            # get new errors
            e2 = diag_matrix(cm)
            e2n = diag_matrix(cmn)
            e2a = diag_matrix(can)
            for ik in arange(0, (mop_dim - 1)+(1)):
               if (e2n[ik] < 0):   
                  qstatus = 1.0
               else:   
                  e2n[ik] = sqrt(e2n[ik])
                  e2a[ik] = sqrt(e2a[ik])
            #
            # ========================================================================
            # (3) Truncate to dofs level
            # now look at transA and pick n retrievals corresponding to dofs
            # ========================================================================
            nrows_leading0 = ceil(dfs)
            #
            # alternatively find the point where the variance explain is >95%
            # 95% is arbitrary
            varsa = zeros([mop_dim], Float32)
            sumsa = 0
            for ik in arange(0, (mop_dim - 1)+(1)):
               sumsa = sumsa + transa[ik,ik]
            for ik in arange(0, (mop_dim - 1)+(1)):
               varsa[ik] = transa[ik,ik] / sumsa
            cumsuma = 0
            for ik in arange(0, (mop_dim - 1)+(1)):
               cumsuma = cumsuma + varsa[ik]
            nrows_leading1 = where(ravel(cumsuma >= 0.95))[0]
            if (nrows_leading1 != nrows_leading0):   
               nrows_leading = max([nrows_leading0, nrows_leading1])
            else:   
               nrows_leading = nrows_leading1
            #
            # what needs to be assimilated
            _expr = output_rows_leading
            if _expr == 0:   
               valid_nrows = nrows_leading
               output_start_row = 0
               output_end_row = nrows_leading - 1
            elif _expr == 1:   
               valid_nrows = 1
               output_start_row = 0
               output_end_row = 0
            elif _expr == 2:   
               valid_nrows = mop_dim
               output_start_row = 0
               output_end_row = mop_dim - 1
            else:
               raise RuntimeError('no match found for expression')
            #
            # ========================================================================
            # finally output the variables in ascii
            # yes, in ascii -- this is really for my own convenience
            # it's not computationally efficient but it makes easier debugging
            # besides this is only a temp file for DART to use
            # ========================================================================
            # QC -> only output values with qstatus=0
            if (qstatus == 0):   
               allqc_count = allqc_count + 1.0
               #
               #=========================================================================
               if (do_dart_input == 1):   
                  #
                  # note that the format is for mopitt_dim levels
                  # mopittlev is also mopitt_dim levels
                  # disregard mop_dim to mopitt_dim output
                  # disregard mopitt_dim-mop_dim levels in mopittlev
                  # while i think the better approach is to just output corresponding mopittlev
                  # it is harder to implement
                  #
                  if (apm_no_transform == 'false'):   
                     if (version == 'v3'):   
                        if (valid_nrows > 0):   
                           printf(unit, valid_nrows, sec[k], mop_dim, mopittlev, lat[k], lon[k], format='(12(e14.6))')
                           for ik in arange(output_start_row, (output_end_row)+(1)):
                           # index --> which component?
                              printf(unit, ik + 1, format='(1(e14.6))')
                              # new retrieval
                              printf(unit, yn[ik], format='(1(e14.6))')
                              # new retrieval error
                              printf(unit, e2n[ik], format='(1(e14.6))')
                              # transform prior
                              printf(unit, transimaxa[ik], format='(1(e14.6))')
                              # transformed averaging kernel
                              printf(unit, (transa[ik,:]), format='(7(e14.6))')
                     else:    # version 4 or 5
                        if (valid_nrows > 0):   
                           printf(unit, valid_nrows, sec[k], mop_dim, mopittlev, lat[k], lon[k], format='(15(e14.6))')
                           for ik in arange(output_start_row, (output_end_row)+(1)):
                           # index --> which component?
                              printf(unit, ik + 1, format='(1(e14.6))')
                              # new retrieval
                              printf(unit, yn[ik], format='(1(e14.6))')
                              # new retrieval error
                              printf(unit, e2n[ik], format='(1(e14.6))')
                              # transform prior
                              printf(unit, transimaxa[ik], format='(1(e14.6))')
                              # transformed averaging kernel
                              printf(unit, (transa[ik,:]), format='(10(e14.6))') # apm_no_transform
                  # Code to write no_transform data
                  if (apm_no_transform == 'true'):   
                     if (version == 'v3'):   
                        printf(unit, 'NO_SVD_TRANS', sec[k], lat[k], lon[k], mop_dim, dfs, format='(a15,19(e14.6))')
                        # effective pressure levels
                        printf(unit, mopittlev[7 - array(mop_dim, copy=0).astype(Int32):7], format='(10(e14.6))')
                        # retrieval
                        printf(unit, x, format='(10(e14.6))')
                        # prior retrieval
                        printf(unit, xa, format='(10(e14.6))')
                        # averaging kernel
                        printf(unit, transpose(a), format='(100(e14.6))')
                        # prior error covariance
                        printf(unit, transpose(ca), format='(100(e14.6))')
                        # retrieval error covariance
                        printf(unit, transpose(cx), format='(100(e14.6))')
                        # measurment error covariance
                        printf(unit, transpose(cm), format='(100(e14.6))')
                        # total column
                        printf(unit, cocol0[k], cocol1[k], format='(2(e14.6))')
                     else:    # version 4 or 5
                        printf(unit, 'NO_SVD_TRANS', sec[k], lat[k], lon[k], mop_dim, dfs, format='(a15,16(e14.6))')
                        # effective pressure levels
                        printf(unit, mopittlev[10 - array(mop_dim, copy=0).astype(Int32):10], format='(10(e14.6))')
                        # retrieval
                        printf(unit, x + 9.0, format='(10(e14.6))')
                        # prior retrieval
                        printf(unit, xa + 9.0, format='(10(e14.6))')
                        # averaging kernel
                        printf(unit, transpose(a), format='(100(e14.6))')
                        # prior error covariance
                        printf(unit, transpose(ca), format='(100(e14.6))')
                        # retrieval error covariance
                        printf(unit, transpose(cx), format='(100(e14.6))')
                        # measurment error covariance
                        printf(unit, transpose(cm), format='(100(e14.6))')
                        # total column
                        printf(unit, cocol0[k], cocol1[k], format='(2(e14.6))') # apm_no_transform # do_DART_input
               #
               #=========================================================================
               # output station diagnostics
               if (do_station_output == 1):   
                  if (version == 'v3'):   
                     for istation in arange(0, (ntsloc - 1)+(1)):
                        unit_temp = unit_array[istation]
                        if (bitwise_and(bitwise_and(bitwise_and((lon[k] + 180 >= lontsloc[istation] + 180 - drad[istation]), (lon[k] + 180 < lontsloc[istation] + 180 + drad[istation])), (lat[k] + 90 >= lattsloc[istation] + 90 - drad[istation])), (lat[k] + 90 < lattsloc[istation] + 90 + drad[istation]))):   
                           printf(unit_temp, sec[k], lat[k], lon[k], psurf[k], mop_dim, dfs, sza[k], cloud[k], sind[k], apriori_contrib, format='(10(e14.6))')
                           printf(unit_temp, yn[:], format='(7(e14.6))')
                           printf(unit_temp, co[:], format='(7(e14.6))')
                           printf(unit_temp, e2n[:], format='(7(e14.6))')
                           printf(unit_temp, coerr[:], format='(7(e14.6))')
                           printf(unit_temp, priorerr[:], format='(7(e14.6))')
                           printf(unit_temp, transimaxa[:], format='(7(e14.6))')
                           printf(unit_temp, imaxa[:], format='(7(e14.6))')
                           printf(unit_temp, prior[:], format='(7(e14.6))')
                           printf(unit_temp, eigenvalues[:], format='(7(e14.6))')
                           for ik in arange(0, (mopitt_dim - 1)+(1)):
                              if (ik < mop_dim):   
                                 printf(unit_temp, (transa[ik,:]), format='(7(e14.6))')
                              else:   
                                 printf(unit_temp, (dummy_var[ik]), format='(7(e14.6))')
                           for ik in arange(0, (mopitt_dim - 1)+(1)):
                              if (ik < mop_dim):   
                                 printf(unit_temp, (a[ik,:]), format='(7(e14.6))')
                              else:   
                                 printf(unit_temp, (dummy_var[ik]), format='(7(e14.6))')
                           for ik in arange(0, (mopitt_dim - 1)+(1)):
                              if (ik < mop_dim):   
                                 printf(unit_temp, (cmn[ik,:]), format='(7(e14.6))')
                              else:   
                                 printf(unit_temp, (dummy_var[ik]), format='(7(e14.6))')
                           for ik in arange(0, (mopitt_dim - 1)+(1)):
                              if (ik < mop_dim):   
                                 printf(unit_temp, (cm[ik,:]), format='(7(e14.6))')
                              else:   
                                 printf(unit_temp, (dummy_var[ik]), format='(7(e14.6))')
                           for ik in arange(0, (mopitt_dim - 1)+(1)):
                              if (ik < mop_dim):   
                                 printf(unit_temp, (ca[ik,:]), format='(7(e14.6))')
                              else:   
                                 printf(unit_temp, (dummy_var[ik]), format='(7(e14.6))')
                           for ik in arange(0, (mopitt_dim - 1)+(1)):
                              if (ik < mop_dim):   
                                 printf(unit_temp, (cx[ik,:]), format='(7(e14.6))')
                              else:   
                                 printf(unit_temp, (dummy_var[ik]), format='(7(e14.6))')
                           for ik in arange(0, (mopitt_dim - 1)+(1)):
                              if (ik < mop_dim):   
                                 printf(unit_temp, (cm_dummy[ik,:]), format='(7(e14.6))')
                              else:   
                                 printf(unit_temp, (dummy_var[ik]), format='(7(e14.6))') # lat/lon station    # number of stations
                  else:    # version 4 or 5
                     for istation in arange(0, (ntsloc - 1)+(1)):
                        unit_temp = unit_array[istation]
                        if (bitwise_and(bitwise_and(bitwise_and((lon[k] + 180 >= lontsloc[istation] + 180 - drad[istation]), (lon[k] + 180 < lontsloc[istation] + 180 + drad[istation])), (lat[k] + 90 >= lattsloc[istation] + 90 - drad[istation])), (lat[k] + 90 < lattsloc[istation] + 90 + drad[istation]))):   
                           printf(unit_temp, sec[k], lat[k], lon[k], psurf[k], mop_dim, dfs, sza[k], cloud[k], sind[k], apriori_contrib, format='(10(e14.6))')
                           printf(unit_temp, yn[:], format='(10(e14.6))')
                           printf(unit_temp, co[:], format='(10(e14.6))')
                           printf(unit_temp, e2n[:], format='(10(e14.6))')
                           printf(unit_temp, coerr[:], format='(10(e14.6))')
                           printf(unit_temp, priorerr[:], format='(10(e14.6))')
                           printf(unit_temp, transimaxa[:], format='(10(e14.6))')
                           printf(unit_temp, imaxa[:], format='(10(e14.6))')
                           printf(unit_temp, prior[:], format='(10(e14.6))')
                           printf(unit_temp, eigenvalues[:], format='(10(e14.6))')
                           for ik in arange(0, (mopitt_dim - 1)+(1)):
                              if (ik < mop_dim):   
                                 printf(unit_temp, (transa[ik,:]), format='(10(e14.6))')
                              else:   
                                 printf(unit_temp, (dummy_var[ik]), format='(10(e14.6))')
                           for ik in arange(0, (mopitt_dim - 1)+(1)):
                              if (ik < mop_dim):   
                                 printf(unit_temp, (a[ik,:]), format='(10(e14.6))')
                              else:   
                                 printf(unit_temp, (dummy_var[ik]), format='(10(e14.6))')
                           for ik in arange(0, (mopitt_dim - 1)+(1)):
                              if (ik < mop_dim):   
                                 printf(unit_temp, (cmn[ik,:]), format='(10(e14.6))')
                              else:   
                                 printf(unit_temp, (dummy_var[ik]), format='(10(e14.6))')
                           for ik in arange(0, (mopitt_dim - 1)+(1)):
                              if (ik < mop_dim):   
                                 printf(unit_temp, (cm[ik,:]), format='(10(e14.6))')
                              else:   
                                 printf(unit_temp, (dummy_var[ik]), format='(10(e14.6))')
                           for ik in arange(0, (mopitt_dim - 1)+(1)):
                              if (ik < mop_dim):   
                                 printf(unit_temp, (ca[ik,:]), format='(10(e14.6))')
                              else:   
                                 printf(unit_temp, (dummy_var[ik]), format='(10(e14.6))')
                           for ik in arange(0, (mopitt_dim - 1)+(1)):
                              if (ik < mop_dim):   
                                 printf(unit_temp, (cx[ik,:]), format='(10(e14.6))')
                              else:   
                                 printf(unit_temp, (dummy_var[ik]), format='(10(e14.6))')
                           for ik in arange(0, (mopitt_dim - 1)+(1)):
                              if (ik < mop_dim):   
                                 printf(unit_temp, (cm_dummy[ik,:]), format='(10(e14.6))')
                              else:   
                                 printf(unit_temp, (dummy_var[ik]), format='(10(e14.6))')    # lat/lon of station      # number of stations        # version             # do_station_output                # QC - qstatus for numerical issues 	                 # QC - apriori contribution 	                 # QC - most quality control		         # MOPITT pixels (k data) 
   #
   # close files
   if (do_dart_input == 1):   
      close(unit)
   #
   if (do_station_output == 1):   
      for istation in arange(0, (ntsloc - 1)+(1)):
         unit_temp = unit_array[istation]
         close(unit_temp)
   #
   # print counters
   print ('BIN TIME')
   print (bin_beg, bin_end)
   print ('QC Count')
   print (allqc_count)
   print ('ALL Pixels Count')
   print (allpix_count)
   print ('Count (%)')
   print (allqc_count * 100.0 / allpix_count)
   #
   print ('================================')
   print ('IDL SVD transformation DONE for ', mopitt_input_file)
   print ('================================')
   print (' ')
   
   return _ret()
    # end of mopitt_extract_svd_transform
