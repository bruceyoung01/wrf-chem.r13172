#!/bin/ksh -aeux
export CYCLE_DATE=2008060500
export FIX_DATE=2008060506
export BACK_FILE=10
export FIX_FILE=11
export FORW_FILE=12
export BACK_WT=.500
export EXP=/MOPnXXX_Exp_2_MgDA_20M_100km_COnXX_RETR_NO_ROT_REJ_SUPR
export SCRATCH_PATH=/glade/scratch/mizzi/DART_TEST_AVE
export CENTRALDIR=${SCRATCH_PATH}${EXP}/DART_CENTRALDIR
export NUM_MEMBERS=20
export DOMAIN=01
#
###############################################
#
# Interpolation to fix failed member
#
###############################################
#
export L_YYYY=$(echo $CYCLE_DATE | cut -c1-4)
export L_MM=$(echo $CYCLE_DATE | cut -c5-6)
export L_DD=$(echo $CYCLE_DATE | cut -c7-8)
export L_HH=$(echo $CYCLE_DATE | cut -c9-10)
export L_FILE_DATE=${L_YYYY}-${L_MM}-${L_DD}_${L_HH}:00:00
export YYYY=$(echo $FIX_DATE | cut -c1-4)
export MM=$(echo $FIX_DATE | cut -c5-6)
export DD=$(echo $FIX_DATE | cut -c7-8)
export HH=$(echo $FIX_DATE | cut -c9-10)
export FILE_DATE=${YYYY}-${MM}-${DD}_${HH}:00:00
export WRF_FILE=wrfout_d${DOMAIN}_${FILE_DATE}
export APM_FILE=wrfapm_d${DOMAIN}_${FILE_DATE}
#
export NUM_ZERO=0000
if [[ ${BACK_FILE} -lt 1000 ]]; then export NUM_ZERO=0; fi
if [[ ${BACK_FILE} -lt 100 ]]; then export NUM_ZERO=00; fi
if [[ ${BACK_FILE} -lt 10  ]]; then export NUM_ZERO=000; fi
export BACK_RUN_DIR=advance_temp_${NUM_ZERO}${BACK_FILE}
export BACK_FILE_PATH=${CENTRALDIR}/${BACK_RUN_DIR}
export BACK_WRF_FILE=${BACK_FILE_PATH}/${WRF_FILE}
export BACK_APM_FILE=${BACK_FILE_PATH}/${APM_FILE}
#
export NUM_ZERO=0000
if [[ ${FIX_FILE} -lt 1000 ]]; then export NUM_ZERO=0; fi
if [[ ${FIX_FILE} -lt 100 ]]; then export NUM_ZERO=00; fi
if [[ ${FIX_FILE} -lt 10  ]]; then export NUM_ZERO=000; fi
export FIX_RUN_DIR=advance_temp_${NUM_ZERO}${FIX_FILE}
export FIX_FILE_PATH=${CENTRALDIR}/${FIX_RUN_DIR}
export FIX_WRF_FILE=${FIX_FILE_PATH}/${WRF_FILE}
export FIX_APM_FILE=${FIX_FILE_PATH}/${APM_FILE}
#
export NUM_ZERO=0000
if [[ ${FORW_FILE} -lt 1000 ]]; then export NUM_ZERO=0; fi
if [[ ${FORW_FILE} -lt 100 ]]; then export NUM_ZERO=00; fi
if [[ ${FORW_FILE} -lt 10  ]]; then export NUM_ZERO=000; fi
export FORW_RUN_DIR=advance_temp_${NUM_ZERO}${FORW_FILE}
export FORW_FILE_PATH=${CENTRALDIR}/${FORW_RUN_DIR}
export FORW_WRF_FILE=${FORW_FILE_PATH}/${WRF_FILE}
export FORW_APM_FILE=${FORW_FILE_PATH}/${APM_FILE}
#
ncflint -w ${BACK_WT} ${BACK_WRF_FILE} ${FORW_WRF_FILE} ${FIX_WRF_FILE}
ncflint -w ${BACK_WT} ${BACK_APM_FILE} ${FORW_APM_FILE} ${FIX_APM_FILE}
#
###############################################
#
# Copy files to wrfchem_forecast for next cycle
#
###############################################
#
export FORECAST_DIR=${SCRATCH_PATH}${EXP}/${CYCLE_DATE}/wrfchem_forecast
cd ${FORECAST_DIR}
let IMEM=1
while [[ ${IMEM} -le ${NUM_MEMBERS} ]]; do
   export KMEM=${IMEM}
   if [[ ${IMEM} -lt 1000 ]]; then export KMEM=0${IMEM}; fi
   if [[ ${IMEM} -lt 100 ]]; then export KMEM=00${IMEM}; fi
   if [[ ${IMEM} -lt 10 ]]; then export KMEM=000${IMEM}; fi
   export WRFOUT_FILE_ANL=wrfout_d${DOMAIN}_${L_FILE_DATE} 
   export WRFOUT_FILE_FOR=wrfout_d${DOMAIN}_${FILE_DATE} 
   export WRFOUT_FILE_APM=wrfapm_d${DOMAIN}_${FILE_DATE} 
   cp ${CENTRALDIR}/advance_temp_${KMEM}/wrfinput_d${DOMAIN} wrfinput_d${DOMAIN}_${KMEM}
   cp ${CENTRALDIR}/advance_temp_${KMEM}/${WRFOUT_FILE_ANL} ${WRFOUT_FILE_ANL}_${KMEM}
   cp ${CENTRALDIR}/advance_temp_${KMEM}/${WRFOUT_FILE_FOR} ${WRFOUT_FILE_FOR}_${KMEM}
   cp ${CENTRALDIR}/advance_temp_${KMEM}/${WRFOUT_FILE_APM} ${WRFOUT_FILE_APM}_${KMEM}
   let IMEM=${IMEM}+1
done
cp ${CENTRALDIR}/advance_temp_0001/namelist.input ./.

