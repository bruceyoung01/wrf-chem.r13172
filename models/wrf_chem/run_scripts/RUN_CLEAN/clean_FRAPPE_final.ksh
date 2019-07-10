#!/bin/ksh -aeux
#
export NUM_MEMBERS=30
export WRFDA_VERSION=WRFDAv3.9.1.1_dmpar
export BUILD_DIR=/projects/mizzi/TRUNK/${WRFDA_VERSION}/var/build
#
export EXP=/real_FRAPPE_CONTROL
export EXP=/real_FRAPPE_RETR_MOP_CO
export EXP=/real_FRAPPE_CPSR_MOP_CO
#
export SOURCE_PATH=/scratch/summit/mizzi${EXP}
#
export DATE_STR=2014071406
export DATE_END=2014071406

export CYCLE_PERIOD=6
#
# Copy file into ${L_DATE} subdirectory
export L_DATE=${DATE_STR}
#
# KEEP PARTS OF THE FOLLOWING
# wrfchem_chem_icbc
# wrfchem_chem_emiss
# dart_filter
# ensemble_mean_input
# ensemble_mean_output
# ensmean_cycle_fr
# wrfchem_cycle_cr
#
while [[ ${L_DATE} -le ${DATE_END} ]] ; do
   cd ${SOURCE_PATH}/geogrid
      rm -rf *geogrid.log*
      rm -rf geogrid.*
      rm -rf index.html
      rm -rf job.ksh
      rm -rf SUCCESS
   cd ${SOURCE_PATH}/${L_DATE}
   rm -rf ungrib
   rm -rf metgrid
#   cd ${SOURCE_PATH}/${L_DATE}/metgrid
#      rm -rf *metgrid.log*
#      rm -rf FILE:*
#      rm -rf geo_em.d*
#      rm -rf index*
#      rm -rf job*
#      rm -rf metgrid.exe*
#      rm -rf METGRID.TBL*
#      rm -rf namelist.wps*
#      rm -rf SUCCESS
#   cd ${SOURCE_PATH}/${L_DATE}
   rm -rf real
#   cd ${SOURCE_PATH}/${L_DATE}/real
#      rm -rf *real.log*
#      rm -rf hist_io*
#      rm -rf index*
#      rm -rf job*
#      rm -rf met_em.d*
#      rm -rf namelist*
#      rm -rf real*
#      rm -rf rsl.*
#      rm -rf SUCCESS
#   cd ${SOURCE_PATH}/${L_DATE}
   rm -rf wrfchem_met_ic
   rm -rf wrfchem_met_bc
   rm -rf exo_coldens
   rm -rf seasons_wes
   rm -rf wrfchem_bio
   rm -rf wrfchem_fire
   rm -rf wrfchem_chemi
   cd ${SOURCE_PATH}/${L_DATE}/wrfchem_chem_icbc
      rm -rf *_cr_icbc_pert.log
      rm -rf job*
      rm -rf met_em*
      rm -rf mozbc*
      rm -rf perturb_chem*
      rm -rf run*
      rm -rf set*
      rm -rf SUCCESS
      rm -rf wrfbdy*
      rm -rf wrfinput*
   cd ${SOURCE_PATH}/${L_DATE}/wrfchem_chem_emiss
      rm -rf *_cr_emiss_pert.log
      rm -rf job*
      rm -rf perturb_chem*
      rm -rf perturb_emiss*
      rm -rf SUCCESS
      rm -rf wrfbiochemi*
      rm -rf wrfchemi*
      rm -rf wrffirechemi*
      rm -rf wrfinput*
   cd ${SOURCE_PATH}/${L_DATE}
   rm -rf mopitt_co_obs
   rm -rf iasi_co_obs
   rm -rf iasi_o3_obs
   rm -rf airnow_co_obs
   rm -rf airnow_o3_obs
   rm -rf airnow_co_obs
   rm -rf modis_aod_obs
   rm -rf airnow_co_obs
   rm -rf prepbufr_met_obs
   rm -rf combine_obs
   rm -rf preprocess_obs
   if [[ -e dart_filter ]]; then
      cd dart_filter
      rm -rf *filter.log*
      rm -rf advance_time
      rm -rf dart_log*
      rm -rf filter
      rm -rf filter_apm.nml
      rm -rf filter_ic_new.*
      rm -rf filter_ic_old.*
      rm -rf final_full*
      rm -rf index.html
      rm -rf input.nml
      rm -rf job.ksh
      rm -rf SUCCESS
      rm -rf ubvals_*
      rm -rf wrfchemi_d*
      rm -rf wrffirechemi_d*
      rm -rf wrfinput_d*
      rm -rf wrfout_d*   
      rm -rf wrk_dart_e*
      rm -rf wrk_wrf_e*
      cd ../
   fi
   rm -rf update_bc
   if [[ -e wrfchem_initial ]]; then
      cd wrfchem_initial
      let IMEM=1
      while [[ ${IMEM} -le ${NUM_MEMBERS} ]]; do
         export CMEM=e${IMEM}
         if [[ ${IMEM} -lt 100 ]]; then export CMEM=e0${IMEM}; fi
         if [[ ${IMEM} -lt 10 ]]; then export CMEM=e00${IMEM}; fi
         cd run_${CMEM}
         rm -rf *wrf.log*
         rm -rf advance_time
         rm -rf aerosol*
         rm -rf bulkdens*
         rm -rf bulkradii*
         rm -rf CAM*
         rm -rf capacity*
         rm -rf CCN*
         rm -rf clim_p_trop* 
         rm -rf CLM*
         rm -rf coeff*
         rm -rf constants*
         rm -rf ETAMPNEW*
         rm -rf exo_coldens*
         rm -rf freeze*
         rm -rf GENPARM*
         rm -rf grib*
         rm -rf hist_io_flds*
         rm -rf index.html
         rm -rf input.nml
         rm -rf job.ksh
         rm -rf kernels*
         rm -rf LANDUSE*
         rm -rf masses*
         rm -rf MPTABLE*
         rm -rf namelist*
         rm -rf ozone*
         rm -rf qr_acr*
         rm -rf RRTM*
         rm -rf rsl.error*
         rm -rf rsl.out*
         rm -rf SOILPARM*
         rm -rf SUCCESS
         rm -rf termvels*
         rm -rf tr*
         rm -rf URBPARM*
         rm -rf VEGPARM*
         rm -rf wrfapm_d*
         rm -rf wrf.exe
         rm -rf wrf_season*
         rm -rf job_list
         rm -rf test_list
         rm -rf ubvals*
         rm -rf wrfchemi_d*
         rm -rf wrffirechemi_d*
         rm -rf wrfbiochemi_d*
         cd ../
         let IMEM=${IMEM}+1
      done
      cd ../
   fi
   if [[ -e wrfchem_cycle_cr ]]; then
      cd wrfchem_cycle_cr
      let IMEM=1
      while [[ ${IMEM} -le ${NUM_MEMBERS} ]]; do
         export CMEM=e${IMEM}
         if [[ ${IMEM} -lt 100 ]]; then export CMEM=e0${IMEM}; fi
         if [[ ${IMEM} -lt 10 ]]; then export CMEM=e00${IMEM}; fi
         cd run_${CMEM}
         rm -rf *wrf.log*
         rm -rf advance_time
         rm -rf aerosol*
         rm -rf bulkdens*
         rm -rf bulkradii*
         rm -rf CAM*
         rm -rf capacity*
         rm -rf CCN*
         rm -rf clim_p_trop* 
         rm -rf CLM*
         rm -rf coeff*
         rm -rf constants*
         rm -rf ETAMPNEW*
         rm -rf exo_coldens*
         rm -rf freeze*
         rm -rf GENPARM*
         rm -rf grib*
         rm -rf hist_io_flds*
         rm -rf index.html
         rm -rf input.nml
         rm -rf job.ksh
         rm -rf kernels*
         rm -rf LANDUSE*
         rm -rf masses*
         rm -rf MPTABLE*
         rm -rf namelist*
         rm -rf ozone*
         rm -rf qr_acr*
         rm -rf RRTM*
         rm -rf rsl.error*
         rm -rf rsl.out*
         rm -rf SOILPARM*
         rm -rf SUCCESS
         rm -rf termvels*
         rm -rf tr*
         rm -rf URBPARM*
         rm -rf VEGPARM*
         rm -rf wrfapm_d*
         rm -rf wrf.exe
         rm -rf wrf_season*
         rm -rf job_list
         rm -rf test_list
         rm -rf wrfchemi_d*
         rm -rf wrffirechemi_d*
         rm -rf wrfbiochemi_d*
         cd ../
         let IMEM=${IMEM}+1
      done
      cd ../
   fi
   rm -rf ensemble_mean_output/wrfout_d01_0*
   export L_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} ${CYCLE_PERIOD} 2>/dev/null)
done


