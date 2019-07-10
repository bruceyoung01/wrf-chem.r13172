#!/bin/ksh -aeux
#
export NUM_MEMBERS=30
export WRFDA_VERSION=WRFDAv3.9.1.1_dmpar
export BUILD_DIR=/projects/mizzi/TRUNK/${WRFDA_VERSION}/var/build
#
export DATE_STR=2014071418
export DATE_END=2014071418
export CYCLE_PERIOD=6
#
#export EXP=/real_FRAPPE_CPSR_MOP_CO_NOVLOC
#export EXP=/real_FRAPPE_CPSR_MOP_CO_VLOC
export EXP=/real_FRAPPE_RETR_MOP_CO
#export EXP=/real_FRAPPE_CPSR_IAS_CO
#export EXP=/real_FRAPPE_RETR_IAS_CO
#export EXP=/real_FRAPPE_RETR_AIR_O3
#export EXP=/real_FRAPPE_RETR_AIR_CO
#export EXP=/real_FRAPPE_RETR_MOD_AOD
#export EXP=/real_FRAPPE_RETR_CONTROL
#
#export FILTER_EXP=' '
#
#export FILTER_EXP=NOVLOC_HORZ_1p5_CUT_p10
#export FILTER_EXP=VLOC_HORZ_1p5_CUT_p10
#
#export FILTER_EXP=NOVLOC_NOHORZ_0p5_CUT_p05
#export FILTER_EXP=NOVLOC_NOHORZ_0p5_CUT_p10
export FILTER_EXP=NOVLOC_NOHORZ_1p0_CUT_p05
#export FILTER_EXP=NOVLOC_NOHORZ_1p0_CUT_p10
#export FILTER_EXP=NOVLOC_NOHORZ_1p5_CUT_p05
#export FILTER_EXP=NOVLOC_NOHORZ_1p5_CUT_p10
#
#export FILTER_EXP=VLOC_NOHORZ_0p5_CUT_p05
#export FILTER_EXP=VLOC_NOHORZ_0p5_CUT_p10
#export FILTER_EXP=VLOC_NOHORZ_1p0_CUT_p05
#export FILTER_EXP=VLOC_NOHORZ_1p0_CUT_p10
#export FILTER_EXP=VLOC_NOHORZ_1p5_CUT_p05
#export FILTER_EXP=VLOC_NOHORZ_1p5_CUT_p10
#
export SOURCE_PATH=/scratch/summit/mizzi/${EXP}
#
export L_DATE=${DATE_STR}
while [[ ${L_DATE} -le ${DATE_END} ]] ; do
   cd ${SOURCE_PATH}/${L_DATE}/${FILTER_EXP}
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
   if [[ -e wrfchem_cycle_cr ]]; then
      cd wrfchem_cycle_cr
      let IMEM=1
      while [[ ${IMEM} -le ${NUM_MEMBERS} ]]; do
         export CMEM=e${IMEM}
         if [[ ${IMEM} -lt 100 ]]; then export CMEM=e0${IMEM}; fi
         if [[ ${IMEM} -lt 10 ]]; then export CMEM=e00${IMEM}; fi
         if [[ -d run_${CMEM} ]]; then
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
         fi
         let IMEM=${IMEM}+1
      done
      cd ../
   fi






   export L_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} ${CYCLE_PERIOD} 2>/dev/null)
done


