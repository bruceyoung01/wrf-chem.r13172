#!/bin/ksh -aeux
##############q############################################################
# Purpose: Set global environment variables for real_time_wrf
#
#########################################################################
#
export INITIAL_DATE=2014071400
export FIRST_FILTER_DATE=2014071406
export FIRST_DART_INFLATE_DATE=2014071406
#
# START CYCLE DATE-TIME:
export CYCLE_STR_DATE=2014071406
#
# END CYCLE DATE-TIME:
export CYCLE_END_DATE=2014071406
#export CYCLE_END_DATE=${CYCLE_STR_DATE}
#
export CYCLE_DATE=${CYCLE_STR_DATE}
#
# Run fine scale forecast only
export RUN_FINE_SCALE=false
#
# Restart fine scale forecast only
export RUN_FINE_SCALE_RESTART=false
export RESTART_DATE=2014072312
#
if [[ ${RUN_FINE_SCALE_RESTART} = "true" ]]; then
   export RUN_FINE_SCALE=true
fi
#
# Run WRF-Chem for failed forecasts
export RUN_SPECIAL_FORECAST=false
export NUM_SPECIAL_FORECAST=1
export SPECIAL_FORECAST_FAC=1.
export SPECIAL_FORECAST_FAC=1./2.
export SPECIAL_FORECAST_FAC=2./3.

export SPECIAL_FORECAST_MEM[1]=11
export SPECIAL_FORECAST_MEM[2]=5
export SPECIAL_FORECAST_MEM[3]=9
export SPECIAL_FORECAST_MEM[4]=10
export SPECIAL_FORECAST_MEM[5]=14
export SPECIAL_FORECAST_MEM[6]=15
export SPECIAL_FORECAST_MEM[7]=16
export SPECIAL_FORECAST_MEM[8]=17
export SPECIAL_FORECAST_MEM[9]=18
export SPECIAL_FORECAST_MEM[10]=19
#
# Run temporal interpolation for missing background files
# Currently set up for 6 hr forecasts. It can handle up to 24 hr forecasts
export RUN_INTERPOLATE=false
#
# for 2014072212 and 2014072218
#export BACK_DATE=2014072206
#export FORW_DATE=2014072300
#BACK_WT=.3333
# BACK_WT=.6667
#
# for 20142900
#export BACK_DATE=2014072818
#export FORW_DATE=2014072906
# BACK_WT=.5000
#
# for 20142912
#export BACK_DATE=2014072906
#export FORW_DATE=2014072918
# BACK_WT=.5000
#
while [[ ${CYCLE_DATE} -le ${CYCLE_END_DATE} ]]; do
export DATE=${CYCLE_DATE}
export CYCLE_PERIOD=6
export HISTORY_INTERVAL_HR=1
(( HISTORY_INTERVAL_MIN = ${HISTORY_INTERVAL_HR} * 60 ))
export NL_DEBUG_LEVEL=200
#
# CODE VERSIONS:
export WPS_VER=WPS_v3.9.1.1
export WPS_GEOG_VER=GEOG_DATA
export WRFDA_VER=WRFDA_v3.9.1.1
export WRF_VER=WRF_v3.9.1.1
export WRFCHEM_VER=WRFCHEM_v3.9.1.1
export DART_VER=DART_CHEM_REPOSITORY
#
# ROOT DIRECTORIES:
export SCRATCH_DIR=/home/amizzi/DATA_OUTPUT
export WORK_DIR=/home/amizzi
export INPUT_DATA_DIR=/home/amizzi/DATA_INPUT
#
# DEPENDENT INPUT DATA DIRECTORIES:
export EXPERIMENT_DIR=${SCRATCH_DIR}
export RUN_DIR=${EXPERIMENT_DIR}/real_FRAPPE_WRF_NFRDM_500m
export TRUNK_DIR=${WORK_DIR}/TRUNK
export WPS_DIR=${TRUNK_DIR}/${WPS_VER}
export WPS_GEOG_DIR=${INPUT_DATA_DIR}/${WPS_GEOG_VER}
export WRFCHEM_DIR=${TRUNK_DIR}/${WRFCHEM_VER}
export WRFDA_DIR=${TRUNK_DIR}/${WRFDA_VER}
export DART_DIR=${TRUNK_DIR}/${DART_VER}
export BUILD_DIR=${WRFDA_DIR}/var/da
export WRF_DIR=${TRUNK_DIR}/${WRF_VER}
export HYBRID_SCRIPTS_DIR=${DART_DIR}/models/wrf_chem/hybrid_scripts
export EXPERIMENT_DATA_DIR=${INPUT_DATA_DIR}/FRAPPE_REAL_TIME_DATA
export EXPERIMENT_PREPBUFR_DIR=${EXPERIMENT_DATA_DIR}/met_obs_prep_data
export EXPERIMENT_GFS_DIR=${EXPERIMENT_DATA_DIR}/gfs_forecasts
export VTABLE_DIR=${WPS_DIR}/ungrib/Variable_Tables
export BE_DIR=${WRFDA_DIR}/var/run
#
cp ${DART_DIR}/models/wrf/work/advance_time ./.
cp ${DART_DIR}/models/wrf/work/input.nml ./.
export YYYY=$(echo $DATE | cut -c1-4)
export YY=$(echo $DATE | cut -c3-4)
export MM=$(echo $DATE | cut -c5-6)
export DD=$(echo $DATE | cut -c7-8)
export HH=$(echo $DATE | cut -c9-10)
export DATE_SHORT=${YY}${MM}${DD}${HH}
export FILE_DATE=${YYYY}-${MM}-${DD}_${HH}:00:00
export PAST_DATE=$(${BUILD_DIR}/da_advance_time.exe ${DATE} -${CYCLE_PERIOD} 2>/dev/null)
export PAST_YYYY=$(echo $PAST_DATE | cut -c1-4)
export PAST_YY=$(echo $PAST_DATE | cut -c3-4)
export PAST_MM=$(echo $PAST_DATE | cut -c5-6)
export PAST_DD=$(echo $PAST_DATE | cut -c7-8)
export PAST_HH=$(echo $PAST_DATE | cut -c9-10)
export PAST_FILE_DATE=${PAST_YYYY}-${PAST_MM}-${PAST_DD}_${PAST_HH}:00:00
export NEXT_DATE=$(${BUILD_DIR}/da_advance_time.exe ${DATE} +${CYCLE_PERIOD} 2>/dev/null)
export NEXT_YYYY=$(echo $NEXT_DATE | cut -c1-4)
export NEXT_YY=$(echo $NEXT_DATE | cut -c3-4)
export NEXT_MM=$(echo $NEXT_DATE | cut -c5-6)
export NEXT_DD=$(echo $NEXT_DATE | cut -c7-8)
export NEXT_HH=$(echo $NEXT_DATE | cut -c9-10)
export NEXT_FILE_DATE=${NEXT_YYYY}-${NEXT_MM}-${NEXT_DD}_${NEXT_HH}:00:00
#
# DART TIME DATA
export DT_YYYY=${YYYY}
export DT_YY=${YY}
export DT_MM=${MM} 
export DT_DD=${DD} 
export DT_HH=${HH} 
(( DT_MM = ${DT_MM} + 0 ))
(( DT_DD = ${DT_DD} + 0 ))
(( DT_HH = ${DT_HH} + 0 ))
if [[ ${HH} -eq 0 ]]; then
   export TMP_DATE=$(${BUILD_DIR}/da_advance_time.exe ${DATE} -1 2>/dev/null)
   export TMP_YYYY=$(echo $TMP_DATE | cut -c1-4)
   export TMP_YY=$(echo $TMP_DATE | cut -c3-4)
   export TMP_MM=$(echo $TMP_DATE | cut -c5-6)
   export TMP_DD=$(echo $TMP_DATE | cut -c7-8)
   export TMP_HH=$(echo $TMP_DATE | cut -c9-10)
   export D_YYYY=${TMP_YYYY}
   export D_YY=${TMP_YY}
   export D_MM=${TMP_MM}
   export D_DD=${TMP_DD}
   export D_HH=24
   (( DD_MM = ${D_MM} + 0 ))
   (( DD_DD = ${D_DD} + 0 ))
   (( DD_HH = ${D_HH} + 0 ))
else
   export D_YYYY=${YYYY}
   export D_YY=${YY}
   export D_MM=${MM}
   export D_DD=${DD}
   export D_HH=${HH}
   (( DD_MM = ${D_MM} + 0 ))
   (( DD_DD = ${D_DD} + 0 ))
   (( DD_HH = ${D_HH} + 0 ))
fi
export D_DATE=${D_YYYY}${D_MM}${D_DD}${D_HH}
#
# CALCULATE GREGORIAN TIMES FOR START AND END OF ASSIMILATION WINDOW
set -A GREG_DATA `echo $DATE 0 -g | ${DART_DIR}/models/wrf/work/advance_time`
export DAY_GREG=${GREG_DATA[0]}
export SEC_GREG=${GREG_DATA[1]}
set -A GREG_DATA `echo $NEXT_DATE 0 -g | ${DART_DIR}/models/wrf/work/advance_time`
export NEXT_DAY_GREG=${GREG_DATA[0]}
export NEXT_SEC_GREG=${GREG_DATA[1]}
export ASIM_WINDOW=3
export ASIM_MIN_DATE=$($BUILD_DIR/da_advance_time.exe $DATE -$ASIM_WINDOW 2>/dev/null)
export ASIM_MIN_YYYY=$(echo $ASIM_MIN_DATE | cut -c1-4)
export ASIM_MIN_YY=$(echo $ASIM_MIN_DATE | cut -c3-4)
export ASIM_MIN_MM=$(echo $ASIM_MIN_DATE | cut -c5-6)
export ASIM_MIN_DD=$(echo $ASIM_MIN_DATE | cut -c7-8)
export ASIM_MIN_HH=$(echo $ASIM_MIN_DATE | cut -c9-10)
export ASIM_MAX_DATE=$($BUILD_DIR/da_advance_time.exe $DATE +$ASIM_WINDOW 2>/dev/null)
export ASIM_MAX_YYYY=$(echo $ASIM_MAX_DATE | cut -c1-4)
export ASIM_MAX_YY=$(echo $ASIM_MAX_DATE | cut -c3-4)
export ASIM_MAX_MM=$(echo $ASIM_MAX_DATE | cut -c5-6)
export ASIM_MAX_DD=$(echo $ASIM_MAX_DATE | cut -c7-8)
export ASIM_MAX_HH=$(echo $ASIM_MAX_DATE | cut -c9-10)
set -A temp `echo $ASIM_MIN_DATE 0 -g | ${DART_DIR}/models/wrf/work/advance_time`
export ASIM_MIN_DAY_GREG=${temp[0]}
export ASIM_MIN_SEC_GREG=${temp[1]}
set -A temp `echo $ASIM_MAX_DATE 0 -g | ${DART_DIR}/models/wrf/work/advance_time` 
export ASIM_MAX_DAY_GREG=${temp[0]}
export ASIM_MAX_SEC_GREG=${temp[1]}
#
# SELECT COMPONENT RUN OPTIONS:
if [[ ${RUN_SPECIAL_FORECAST} = "false" ]]; then
   export RUN_GEOGRID=false
   export RUN_UNGRIB=true
   export RUN_METGRID=true
   export RUN_REAL=true
   export RUN_PERT_WRFCHEM_MET_IC=true
   export RUN_PERT_WRFCHEM_MET_BC=true
   export RUN_MET_OBS=true
   export RUN_COMBINE_OBS=true
   export RUN_PREPROCESS_OBS=true
#
   if [[ ${DATE} -eq ${INITIAL_DATE}  ]]; then
      export RUN_WRFCHEM_INITIAL=true
      export RUN_DART_FILTER=false
      export RUN_UPDATE_BC=false
      export RUN_WRFCHEM_CYCLE_CR=false
      export RUN_BAND_DEPTH=false
      export RUN_WRFCHEM_CYCLE_FR=false
      export RUN_ENSEMBLE_MEAN_INPUT=false
      export RUN_ENSMEAN_CYCLE_FR=false
      export RUN_ENSMEAN_CYCLE_VF=false
      export RUN_ENSEMBLE_MEAN_OUTPUT=false
   else
      export RUN_WRFCHEM_INITIAL=false
      export RUN_DART_FILTER=true
      export RUN_UPDATE_BC=true
      export RUN_WRFCHEM_CYCLE_CR=true
      export RUN_BAND_DEPTH=false
      export RUN_WRFCHEM_CYCLE_FR=false
      export RUN_ENSEMBLE_MEAN_INPUT=true
      export RUN_ENSMEAN_CYCLE_FR=false
      export RUN_ENSMEAN_CYCLE_VF=true
      export RUN_ENSEMBLE_MEAN_OUTPUT=true
   fi
else
   export RUN_GEOGRID=false
   export RUN_UNGRIB=false
   export RUN_METGRID=false
   export RUN_REAL=false
   export RUN_PERT_WRFCHEM_MET_IC=false
   export RUN_PERT_WRFCHEM_MET_BC=false
   export RUN_MET_OBS=false
   export RUN_COMBINE_OBS=false
   export RUN_PREPROCESS_OBS=false
#
   if [[ ${DATE} -eq ${INITIAL_DATE}  ]]; then
      export RUN_WRFCHEM_INITIAL=true
      export RUN_DART_FILTER=false
      export RUN_UPDATE_BC=false
      export RUN_WRFCHEM_CYCLE_CR=false
      export RUN_BAND_DEPTH=false
      export RUN_WRFCHEM_CYCLE_FR=false
      export RUN_ENSEMBLE_MEAN_INPUT=false
      export RUN_ENSMEAN_CYCLE_FR=false
      export RUN_ENSMEAN_CYCLE_VF=false
      export RUN_ENSEMBLE_MEAN_OUTPUT=false
   else
      export RUN_WRFCHEM_INITIAL=false
      export RUN_DART_FILTER=false
      export RUN_WRFCHEM_CYCLE_CR=true
      export RUN_UPDATE_BC=false
      export RUN_BAND_DEPTH=false
      export RUN_WRFCHEM_CYCLE_FR=false
      export RUN_ENSEMBLE_MEAN_INPUT=true
      export RUN_ENSMEAN_CYCLE_FR=false
      export RUN_ENSMEAN_CYCLE_VF=false
      export RUN_ENSEMBLE_MEAN_OUTPUT=true
   fi
fi
if [[ ${RUN_FINE_SCALE} = "true" ]]; then
   export RUN_GEOGRID=true
   export RUN_UNGRIB=false
   export RUN_METGRID=false
   export RUN_REAL=false
   export RUN_PERT_WRFCHEM_MET_IC=false
   export RUN_PERT_WRFCHEM_MET_BC=false
   export RUN_MET_OBS=false
   export RUN_COMBINE_OBS=false
   export RUN_PREPROCESS_OBS=false
   export RUN_WRFCHEM_INITIAL=false
   export RUN_DART_FILTER=false
   export RUN_UPDATE_BC=false
   export RUN_WRFCHEM_CYCLE_CR=false
   export RUN_BAND_DEPTH=false
   export RUN_WRFCHEM_CYCLE_FR=false
   export RUN_ENSEMBLE_MEAN_INPUT=false
   export RUN_ENSMEAN_CYCLE_FR=true
   export RUN_ENSMEAN_CYCLE_VF=true
   export RUN_ENSEMBLE_MEAN_OUTPUT=false
fi
#
# FORECAST PARAMETERS:
export USE_DART_INFL=true
export FCST_PERIOD=6
(( CYCLE_PERIOD_SEC=${CYCLE_PERIOD}*60*60 ))
export NUM_MEMBERS=10
export MAX_DOMAINS=03
export CR_DOMAIN=01
export FR_DOMAIN=02
export VF_DOMAIN=03
export NNXP_CR=180
export NNYP_CR=162
export NNZP_CR=36
export NNXP_FR=228
export NNYP_FR=174
export NNZP_FR=36
#APM these are fixed
export NNXP_VF=372
export NNYP_VF=348
export NNZP_VF=36
(( NNXP_STAG_CR=${NNXP_CR}+1 ))
(( NNYP_STAG_CR=${NNYP_CR}+1 ))
(( NNZP_STAG_CR=${NNZP_CR}+1 ))
(( NNXP_STAG_FR=${NNXP_FR}+1 ))
(( NNYP_STAG_FR=${NNYP_FR}+1 ))
(( NNZP_STAG_FR=${NNZP_FR}+1 ))
(( NNXP_STAG_VF=${NNXP_VF}+1 ))
(( NNYP_STAG_VF=${NNYP_VF}+1 ))
(( NNZP_STAG_VF=${NNZP_VF}+1 ))
export ISTR_CR=1
export JSTR_CR=1
export ISTR_FR=60
export JSTR_FR=60
# APM these are fixed
export ISTR_VF=111
export JSTR_VF=102
export DX_CR=9000
export DX_FR=3000
export DX_VF=500
(( LBC_END=2*${FCST_PERIOD} ))
export LBC_FREQ=3
(( INTERVAL_SECONDS=${LBC_FREQ}*60*60 ))
export LBC_START=0
export START_DATE=${DATE}
export END_DATE=$($BUILD_DIR/da_advance_time.exe ${START_DATE} ${FCST_PERIOD} 2>/dev/null)
export START_YEAR=$(echo $START_DATE | cut -c1-4)
export START_YEAR_SHORT=$(echo $START_DATE | cut -c3-4)
export START_MONTH=$(echo $START_DATE | cut -c5-6)
export START_DAY=$(echo $START_DATE | cut -c7-8)
export START_HOUR=$(echo $START_DATE | cut -c9-10)
export START_FILE_DATE=${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}:00:00
export END_YEAR=$(echo $END_DATE | cut -c1-4)
export END_MONTH=$(echo $END_DATE | cut -c5-6)
export END_DAY=$(echo $END_DATE | cut -c7-8)
export END_HOUR=$(echo $END_DATE | cut -c9-10)
export END_FILE_DATE=${END_YEAR}-${END_MONTH}-${END_DAY}_${END_HOUR}:00:00
#
# LARGE SCALE FORECAST PARAMETERS:
export FG_TYPE=GFS
export GRIB_PART1=gfs_4_
export GRIB_PART2=.g2.tar
#
# COMPUTER PARAMETERS:
#
# COMPUTER PARAMETERS:
export PROJ_NUMBER=P93300612
export GENERAL_JOB_CLASS=normal
export GENERAL_TIME_LIMIT=00:05:00
export GENERAL_NODES=1
export GENERAL_TASKS=1
export WRFDA_JOB_CLASS=normal
export WRFDA_TIME_LIMIT=00:05:00
export WRFDA_NODES=1
export WRFDA_TASKS=1 
export SINGLE_JOB_CLASS=normal
export SINGLE_TIME_LIMIT=00:05:00
export SINGLE_NODES=1
export SINGLE_TASKS=1
export FILTER_JOB_CLASS=normal
export FILTER_TIME_LIMIT=02:59:00
export FILTER_NODES=4
export FILTER_TASKS=48
export WRFCHEM_JOB_CLASS=normal
export WRFCHEM_TIME_LIMIT=01:00:00
export WRFCHEM_NODES=4
export WRFCHEM_TASKS=48
#
# RUN DIRECTORIES
export GEOGRID_DIR=${RUN_DIR}/geogrid
export METGRID_DIR=${RUN_DIR}/${DATE}/metgrid
export REAL_DIR=${RUN_DIR}/${DATE}/real
export WRFCHEM_MET_IC_DIR=${RUN_DIR}/${DATE}/wrfchem_met_ic
export WRFCHEM_MET_BC_DIR=${RUN_DIR}/${DATE}/wrfchem_met_bc
export WRFCHEM_INITIAL_DIR=${RUN_DIR}/${INITIAL_DATE}/wrfchem_initial
export WRFCHEM_CYCLE_CR_DIR=${RUN_DIR}/${DATE}/wrfchem_cycle_cr
export WRFCHEM_CYCLE_FR_DIR=${RUN_DIR}/${DATE}/wrfchem_cycle_fr
export WRFCHEM_LAST_CYCLE_CR_DIR=${RUN_DIR}/${PAST_DATE}/wrfchem_cycle_cr
export PREPBUFR_MET_OBS_DIR=${RUN_DIR}/${DATE}/prepbufr_met_obs
export COMBINE_OBS_DIR=${RUN_DIR}/${DATE}/combine_obs
export PREPROCESS_OBS_DIR=${RUN_DIR}/${DATE}/preprocess_obs
export DART_FILTER_DIR=${RUN_DIR}/${DATE}/dart_filter
export UPDATE_BC_DIR=${RUN_DIR}/${DATE}/update_bc
export BAND_DEPTH_DIR=${RUN_DIR}/${DATE}/band_depth
export ENSEMBLE_MEAN_INPUT_DIR=${RUN_DIR}/${DATE}/ensemble_mean_input
export ENSEMBLE_MEAN_OUTPUT_DIR=${RUN_DIR}/${DATE}/ensemble_mean_output
export REAL_TIME_DIR=${DART_DIR}/models/wrf/run_scripts/RUN_REAL_TIME
#
# WPS PARAMETERS:
export SINGLE_FILE=false
export HOR_SCALE=1500
export VTABLE_TYPE=GFS
export METGRID_TABLE_TYPE=ARW
#
# WRF PREPROCESS PARAMETERS
# TARG_LAT=31.56 (33,15) for 072600
# TARG_LON=-120.14 = 239.85 (33,15)
#export NL_MIN_LAT=27.5
#export NL_MAX_LAT=38.5
#export NL_MIN_LON=234.5
#export NL_MAX_LON=244.5
#
export NL_MIN_LAT=30
export NL_MAX_LAT=46
export NL_MIN_LON=251
export NL_MAX_LON=263
#
export NNL_MIN_LAT=${NL_MIN_LAT}
export NNL_MAX_LAT=${NL_MAX_LAT}
export NNL_MIN_LON=${NL_MIN_LON}
if [[ ${NL_MIN_LON} -gt 180 ]]; then 
   (( NNL_MIN_LON=${NL_MIN_LON}-360 ))
fi
exportNNL_MAX_LON=${NL_MAX_LON}
if [[ ${NL_MAX_LON} -gt 180 ]]; then 
   (( NNL_MAX_LON=${NL_MAX_LON}-360 ))
 fi 
export NL_OBS_PRESSURE_TOP=5000.
#
#########################################################################
#
#  NAMELIST PARAMETERS
#
#########################################################################
#
# WPS SHARE NAMELIST:
export NL_WRF_CORE=\'ARW\'
export NL_MAX_DOM=${MAX_DOMAINS}
export NL_IO_FORM_GEOGRID=2
export NL_OPT_OUTPUT_FROM_GEOGRID_PATH=\'${GEOGRID_DIR}\'
export NL_ACTIVE_GRID=".true.",".true.",".true."
#
# WPS GEOGRID NAMELIST:
export NL_S_WE=1,1
export NL_E_WE=${NNXP_STAG_CR},${NNXP_STAG_FR},${NNXP_STAG_VF}
export NL_S_SN=1,1
export NL_E_SN=${NNYP_STAG_CR},${NNYP_STAG_FR},${NNYP_STAG_VF}
export NL_S_VERT=1,1
export NL_E_VERT=${NNZP_STAG_CR},${NNZP_STAG_FR},${NNZP_STAG_VF}
export NL_PARENT_ID="0,1,2"
export TSTEP_RATIO=1,3,6
export GRID_RATIO=1,3,6
export NL_PARENT_GRID_RATIO=${GRID_RATIO}
export NL_I_PARENT_START=${ISTR_CR},${ISTR_FR},${ISTR_VF}
export NL_J_PARENT_START=${JSTR_CR},${JSTR_FR},${JSTR_VF}
export NL_GEOG_DATA_RES=\'usgs_30s+default\',\'usgs_30s+default\',\'usgs_30s+default\'
export NL_DX=${DX_CR}
export NL_DY=${DX_CR}
export NL_MAP_PROJ=\'lambert\'
export NL_REF_LAT=38.5
export NL_REF_LON=-106.25
export NL_STAND_LON=-105.0
export NL_TRUELAT1=30.0
export NL_TRUELAT2=60.0
export NL_GEOG_DATA_PATH=\'${WPS_GEOG_DIR}\'
export NL_OPT_GEOGRID_TBL_PATH=\'${WPS_DIR}/geogrid\'
#
# WPS UNGRIB NAMELIST:
export NL_OUT_FORMAT=\'WPS\'
#
# WPS METGRID NAMELIST:
export NL_IO_FORM_METGRID=2
#
# WRF NAMELIST:
# TIME CONTROL NAMELIST:
export NL_RUN_DAYS=0
export NL_RUN_HOURS=${FCST_PERIOD}
export NL_RUN_MINUTES=0
export NL_RUN_SECONDS=0
export NL_START_YEAR=${START_YEAR},${START_YEAR},${START_YEAR}
export NL_START_MONTH=${START_MONTH},${START_MONTH},${START_MONTH}
export NL_START_DAY=${START_DAY},${START_DAY},${START_DAY}
export NL_START_HOUR=${START_HOUR},${START_HOUR},${START_HOUR}
export NL_START_MINUTE=00,00,00
export NL_START_SECOND=00,00,00
export NL_END_YEAR=${END_YEAR},${END_YEAR},${END_YEAR}
export NL_END_MONTH=${END_MONTH},${END_MONTH},${END_MONTH}
export NL_END_DAY=${END_DAY},${END_DAY},${END_DAY}
export NL_END_HOUR=${END_HOUR},${END_HOUR},${END_HOUR}
export NL_END_MINUTE=00,00,00
export NL_END_SECOND=00,00,00
export NL_INTERVAL_SECONDS=${INTERVAL_SECONDS}
export NL_INPUT_FROM_FILE=".true.",".true.",".true."
export NL_HISTORY_INTERVAL=${HISTORY_INTERVAL_MIN},60,60
export NL_FRAMES_PER_OUTFILE=1,1,1
export NL_RESTART=".false."
export NL_RESTART_INTERVAL=1440
export NL_IO_FORM_HISTORY=2
export NL_IO_FORM_RESTART=2
export NL_FINE_INPUT_STREAM=0,2,2
export NL_IO_FORM_INPUT=2
export NL_IO_FORM_BOUNDARY=2
export NL_AUXINPUT2_INNAME=\'wrfinput_d\<domain\>\'
export NL_AUXINPUT5_INNAME=' '
export NL_AUXINPUT6_INNAME=' '
export NL_AUXINPUT7_INNAME=' '
export NL_AUXINPUT2_INTERVAL_M=60480,60480,60480
export NL_AUXINPUT5_INTERVAL_M=' ',' ',' '
export NL_AUXINPUT6_INTERVAL_M=' ',' ',' '
export NL_AUXINPUT7_INTERVAL_M=' ',' ',' ' 
export NL_FRAMES_PER_AUXINPUT2=1,1,1
export NL_FRAMES_PER_AUXINPUT5=1,1,1
export NL_FRAMES_PER_AUXINPUT6=1,1,1
export NL_FRAMES_PER_AUXINPUT7=1,1,1
export NL_IO_FORM_AUXINPUT2=2
export NL_IO_FORM_AUXINPUT5=2
export NL_IO_FORM_AUXINPUT6=2
export NL_IO_FORM_AUXINPUT7=2
export NL_IOFIELDS_FILENAME=' ',' ',' '
export NL_WRITE_INPUT=".true."
export NL_INPUTOUT_INTERVAL=360
export NL_INPUT_OUTNAME=\'wrfapm_d\<domain\>_\<date\>\'
#
# DOMAINS NAMELIST:
export NL_TIME_STEP=45
export NNL_TIME_STEP=${NL_TIME_STEP}
export NL_TIME_STEP_FRACT_NUM=0
export NL_TIME_STEP_FRACT_DEN=1
export NL_MAX_DOM=${MAX_DOMAINS}
export NL_S_WE=1,1,1
export NL_E_WE=${NNXP_STAG_CR},${NNXP_STAG_FR},${NNXP_STAG_VF}
export NL_S_SN=1,1,1
export NL_E_SN=${NNYP_STAG_CR},${NNYP_STAG_FR},${NNYP_STAG_VF}
export NL_S_VERT=1,1,1
export NL_E_VERT=${NNZP_STAG_CR},${NNZP_STAG_FR},${NNZP_STAG_VF}
export NL_NUM_METGRID_LEVELS=27
export NL_NUM_METGRID_SOIL_LEVELS=4
export NL_DX=${DX_CR},${DX_FR},${DX_VF}
export NL_DY=${DX_CR},${DX_FR},${DX_VF}
export NL_GRID_ID=1,2,3
export NL_PARENT_ID=0,1,2
export NL_I_PARENT_START=${ISTR_CR},${ISTR_FR},${ISTR_VF}
export NL_J_PARENT_START=${JSTR_CR},${JSTR_FR},${JSTR_VF}
export NL_PARENT_GRID_RATIO=${GRID_RATIO}
export NL_PARENT_TIME_STEP_RATIO=${TSTEP_RATIO}
export NL_FEEDBACK=0
export NL_SMOOTH_OPTION=1
export NL_LAGRANGE_ORDER=2
export NL_INTERP_TYPE=2
export NL_EXTRAP_TYPE=2
export NL_T_EXTRAP_TYPE=2
export NL_USE_SURFACE=".true."
export NL_USE_LEVELS_BELOW_GROUND=".true."
export NL_LOWEST_LEV_FROM_SFC=".false."
export NL_FORCE_SFC_IN_VINTERP=1
export NL_ZAP_CLOSE_LEVELS=500
export NL_INTERP_THETA=".false."
export NL_HYPSOMETRIC_OPT=2
export NL_P_TOP_REQUESTED=1000.
export NL_ETA_LEVELS=1.000000,0.996200,0.989737,0.982460,0.974381,0.965422,\
0.955498,0.944507,0.932347,0.918907,0.904075,0.887721,0.869715,0.849928,\
0.828211,0.804436,0.778472,0.750192,0.719474,0.686214,0.650339,0.611803,\
0.570656,0.526958,0.480854,0.432582,0.382474,0.330973,0.278674,0.226390,\
0.175086,0.132183,0.096211,0.065616,0.039773,0.018113,0.000000,
#
# PHYSICS NAMELIST:
export NL_MP_PHYSICS=8,8,8
export NL_RA_LW_PHYSICS=4,4,4
export NL_RA_SW_PHYSICS=4,4,4
export NL_RADT=15,3,3
export NL_SF_SFCLAY_PHYSICS=1,1,1
export NL_SF_SURFACE_PHYSICS=2,2,2
export NL_BL_PBL_PHYSICS=1,1,1
export NL_BLDT=0,0,0
export NL_CU_PHYSICS=1,0,0
export NL_CUDT=0,0,0
export NL_CUGD_AVEDX=1
export NL_CU_RAD_FEEDBACK=".true.",".true.",".true."
export NL_CU_DIAG=0,0,0
export NL_ISFFLX=1
export NL_IFSNOW=0
export NL_ICLOUD=1
export NL_SURFACE_INPUT_SOURCE=1
export NL_NUM_SOIL_LAYERS=4
export NL_MP_ZERO_OUT=2
export NL_NUM_LAND_CAT=24
export NL_SF_URBAN_PHYSICS=1,1,1
export NL_MAXIENS=1
export NL_MAXENS=3
export NL_MAXENS2=3
export NL_MAXENS3=16
export NL_ENSDIM=144
#
# DYNAMICS NAMELIST:
export NL_ISO_TEMP=200.
export NL_TRACER_OPT=0,0,0
export NL_W_DAMPING=1
export NL_DIFF_OPT=2
export NL_DIFF_6TH_OPT=0,0,0
export NL_DIFF_6TH_FACTOR=0.12,0.12,0.12
export NL_KM_OPT=4
export NL_DAMP_OPT=1
export NL_ZDAMP=5000,5000,5000
export NL_DAMPCOEF=0.15,0.15,0.15
export NL_NON_HYDROSTATIC=".true.",".true.",".true."
export NL_USE_BASEPARAM_FR_NML=".true."
export NL_MOIST_ADV_OPT=2,2,2
export NL_SCALAR_ADV_OPT=2,2,2
export NL_CHEM_ADV_OPT=2,2,2
export NL_TKE_ADV_OPT=2,2,2
export NL_H_MOM_ADV_ORDER=5,5,5
export NL_V_MOM_ADV_ORDER=3,3,3
export NL_H_SCA_ADV_ORDER=5,5,5
export NL_V_SCA_ADV_ORDER=3,3,3
#
# BDY_CONTROL NAMELIST:
export NL_SPEC_BDY_WIDTH=5
export NL_SPEC_ZONE=1
export NL_RELAX_ZONE=4
export NL_SPECIFIED=".true.",".false.",".false."
export NL_NESTED=".false.",".true.",".true."
#
# QUILT NAMELIST:
export NL_NIO_TASKS_PER_GROUP=0
export NL_NIO_GROUPS=1
#
# WRFDA NAMELIST PARAMETERS
# WRFVAR1 NAMELIST:
export NL_PRINT_DETAIL_GRAD=false
export NL_VAR4D=false
export NL_MULTI_INC=0
#
# WRFVAR3 NAMELIST:
export NL_OB_FORMAT=1
export NL_NUM_FGAT_TIME=1
#
# WRFVAR4 NAMELIST:
export NL_USE_SYNOPOBS=true
export NL_USE_SHIPOBS=false
export NL_USE_METAROBS=true
export NL_USE_SOUNDOBS=true
export NL_USE_MTGIRSOBS=false
export NL_USE_PILOTOBS=true
export NL_USE_AIREOBS=true
export NL_USE_GEOAMVOBS=false
export NL_USE_POLARAMVOBS=false
export NL_USE_BOGUSOBS=false
export NL_USE_BUOYOBS=false
export NL_USE_PROFILEROBS=false
export NL_USE_SATEMOBS=false
export NL_USE_GPSPWOBS=false
export NL_USE_GPSREFOBS=false
export NL_USE_SSMIRETRIEVALOBS=false
export NL_USE_QSCATOBS=false
export NL_USE_AIRSRETOBS=false
#
# WRFVAR5 NAMELIST:
export NL_CHECK_MAX_IV=true
export NL_PUT_RAND_SEED=true
#
# WRFVAR6 NAMELIST:
export NL_NTMAX=100
#
# WRFVAR7 NAMELIST:
export NL_JE_FACTOR=1.0
export NL_CV_OPTIONS=3
export NL_AS1=0.25,2.0,1.0
export NL_AS2=0.25,2.0,1.0
export NL_AS3=0.25,2.0,1.0
export NL_AS4=0.25,2.0,1.0
export NL_AS5=0.25,2.0,1.0
#
# WRFVAR11 NAMELIST:
export NL_CV_OPTIONS_HUM=1
export NL_CHECK_RH=2
export NL_SEED_ARRAY1=$(${BUILD_DIR}/da_advance_time.exe ${DATE} 0 -f hhddmmyycc)
export NL_SEED_ARRAY2=`echo ${NUM_MEMBERS} \* 100000 | bc -l `
export NL_CALCULATE_CG_COST_FN=true
export NL_LAT_STATS_OPTION=false
#
# WRFVAR15 NAMELIST:
export NL_NUM_PSEUDO=0
export NL_PSEUDO_X=0
export NL_PSEUDO_Y=0
export NL_PSEUDO_Z=0
export NL_PSEUDO_ERR=0.0
export NL_PSEUDO_VAL=0.0
#
# WRFVAR16 NAMELIST:
export NL_ALPHACV_METHOD=2
export NL_ENSDIM_ALPHA=0
export NL_ALPHA_CORR_TYPE=3
export NL_ALPHA_CORR_SCALE=${HOR_SCALE}
export NL_ALPHA_STD_DEV=1.0
export NL_ALPHA_VERTLOC=false
export NL_ALPHA_TRUNCATION=1
#
# WRFVAR17 NAMELIST:
export NL_ANALYSIS_TYPE=\'RANDOMCV\'
#
# WRFVAR18 NAMELIST:
export ANALYSIS_DATE=$(${BUILD_DIR}/da_advance_time.exe ${DATE} 0 -W 2>/dev/null)
#
# WRFVAR19 NAMELIST:
export NL_PSEUDO_VAR=\'t\'
#
# WRFVAR21 NAMELIST:
export NL_TIME_WINDOW_MIN=\'$(${BUILD_DIR}/da_advance_time.exe ${DATE} -${ASIM_WINDOW} -W 2>/dev/null)\'
#
# WRFVAR22 NAMELIST:
export NL_TIME_WINDOW_MAX=\'$(${BUILD_DIR}/da_advance_time.exe ${DATE} +${ASIM_WINDOW} -W 2>/dev/null)\'
#
# WRFVAR23 NAMELIST:
export NL_JCDFI_USE=false
export NL_JCDFI_IO=false
#
# DART input.nml parameters
# &filter.nml
export NL_OUTLIER_THRESHOLD=3.
export NL_ENABLE_SPECIAL_OUTLIER_CODE=.false.
export NL_SPECIAL_OUTLIER_THRESHOLD=3.
export NL_ENS_SIZE=${NUM_MEMBERS}
export NL_OUTPUT_RESTART=.true.
export NL_START_FROM_RESTART=.true.
export NL_OBS_SEQUENCE_IN_NAME="'obs_seq.out'"       
export NL_OBS_SEQUENCE_OUT_NAME="'obs_seq.final'"
export NL_RESTART_IN_FILE_NAME="'filter_ic_old'"       
export NL_RESTART_OUT_FILE_NAME="'filter_ic_new'"
set -A temp `echo ${ASIM_MIN_DATE} 0 -g | ${DART_DIR}/models/wrf/work/advance_time`
(( temp[1]=${temp[1]}+1 ))
export NL_FIRST_OBS_DAYS=${temp[0]}
export NL_FIRST_OBS_SECONDS=${temp[1]}
set -A temp `echo ${ASIM_MAX_DATE} 0 -g | ${DART_DIR}/models/wrf/work/advance_time`
export NL_LAST_OBS_DAYS=${temp[0]}
export NL_LAST_OBS_SECONDS=${temp[1]}
export NL_NUM_OUTPUT_STATE_MEMBERS=0
export NL_NUM_OUTPUT_OBS_MEMBERS=${NUM_MEMBERS}
if ${USE_DART_INFL}; then
   export NL_INF_FLAVOR_PRIOR=2
else 
   export NL_INF_FLAVOR_PRIOR=0
fi
export NL_INF_FLAVOR_POST=0  
if [[ ${START_DATE} -eq ${FIRST_DART_INFLATE_DATE} ]]; then
   export NL_INF_INITIAL_FROM_RESTART_PRIOR=.false.
   export NL_INF_SD_INITIAL_FROM_RESTART_PRIOR=.false.
   export NL_INF_INITIAL_FROM_RESTART_POST=.false.
   export NL_INF_SD_INITIAL_FROM_RESTART_POST=.false.
else
   export NL_INF_INITIAL_FROM_RESTART_PRIOR=.true.
   export NL_INF_SD_INITIAL_FROM_RESTART_PRIOR=.true.
   export NL_INF_INITIAL_FROM_RESTART_POST=.true.
   export NL_INF_SD_INITIAL_FROM_RESTART_POST=.true.
fi
export NL_INF_IN_FILE_NAME_PRIOR="'prior_inflate_ic_old'"
export NL_INF_IN_FILE_NAME_POST="'post_inflate_ics'"
export NL_INF_OUT_FILE_NAME_PRIOR="'prior_inflate_ic_new'"
export NL_INF_OUT_FILE_NAME_POST="'prior_inflate_restart'"
export NL_INF_DIAG_FILE_NAME_PRIOR="'prior_inflate_diag'"
export NL_INF_DIAG_FILE_NAME_POST="'post_inflate_diag'"
export NL_INF_INITIAL_PRIOR=1.0
export NL_INF_INITIAL_POST=1.0
export NL_INF_SD_INITIAL_PRIOR=0.6
export NL_INF_SD_INITIAL_POST=0.0
export NL_INF_DAMPING_PRIOR=0.9
export NL_INF_DAMPING_POST=1.0
export NL_INF_LOWER_BOUND_PRIOR=1.0
export NL_INF_LOWER_BOUND_POST=1.0
export NL_INF_UPPER_BOUND_PRIOR=100.0
export NL_INF_UPPER_BOUND_POST=100.0
export NL_INF_SD_LOWER_BOUND_PRIOR=0.6
export NL_INF_SD_LOWER_BOUND_POST=0.0
#
# &assim_tools_nml
export NL_CUTOFF=0.1
export NL_SPECIAL_LOCALIZATION_OBS_TYPES="'null'"
export NL_SAMPLING_ERROR_CORRECTION=.true.
# original cutoff
export NL_SPECIAL_LOCALIZATION_CUTOFFS=-1
export NL_ADAPTIVE_LOCALIZATION_THRESHOLD=-1
#
# &ensemble_manager_nml
export NL_SINGLE_RESTART_FILE_IN=.false.       
export NL_SINGLE_RESTART_FILE_OUT=.false.       
#
# &assim_model_nml
export NL_WRITE_BINARY_RESTART_FILE=.true.
#
# &model_nml
export NL_DEFAULT_STATE_VARIABLES=.false.
export NL_CONV_STATE_VARIABLES="'U',     'KIND_U_WIND_COMPONENT',     'TYPE_U',  'UPDATE','999',
          'V',     'KIND_V_WIND_COMPONENT',     'TYPE_V',  'UPDATE','999',
          'W',     'KIND_VERTICAL_VELOCITY',    'TYPE_W',  'UPDATE','999',
          'PH',    'KIND_GEOPOTENTIAL_HEIGHT',  'TYPE_GZ', 'UPDATE','999',
          'T',     'KIND_POTENTIAL_TEMPERATURE','TYPE_T',  'UPDATE','999',
          'MU',    'KIND_PRESSURE',             'TYPE_MU', 'UPDATE','999',
          'QVAPOR','KIND_VAPOR_MIXING_RATIO',   'TYPE_QV', 'UPDATE','999',
          'QRAIN', 'KIND_RAINWATER_MIXING_RATIO','TYPE_QRAIN', 'UPDATE','999',
          'QCLOUD','KIND_CLOUD_LIQUID_WATER',   'TYPE_QCLOUD', 'UPDATE','999',
          'QSNOW', 'KIND_SNOW_MIXING_RATIO',    'TYPE_QSNOW', 'UPDATE','999',
          'QICE',  'KIND_CLOUD_ICE',            'TYPE_QICE', 'UPDATE','999',
          'U10',   'KIND_U_WIND_COMPONENT',     'TYPE_U10','UPDATE','999',
          'V10',   'KIND_V_WIND_COMPONENT',     'TYPE_V10','UPDATE','999',
          'T2',    'KIND_TEMPERATURE',          'TYPE_T2', 'UPDATE','999',
          'TH2',   'KIND_POTENTIAL_TEMPERATURE','TYPE_TH2','UPDATE','999',
          'Q2',    'KIND_SPECIFIC_HUMIDITY',    'TYPE_Q2', 'UPDATE','999',
          'PSFC',  'KIND_PRESSURE',             'TYPE_PS', 'UPDATE','999'"
export NL_WRF_STATE_BOUNDS="'QVAPOR','0.0','NULL','CLAMP',
          'QRAIN', '0.0','NULL','CLAMP',
          'QCLOUD','0.0','NULL','CLAMP',
          'QSNOW', '0.0','NULL','CLAMP',
          'QICE',  '0.0','NULL','CLAMP'"
export NL_OUTPUT_STATE_VECTOR=.false.
export NL_NUM_DOMAINS=${CR_DOMAIN}
export NL_CALENDAR_TYPE=3
export NL_ASSIMILATION_PERIOD_SECONDS=${CYCLE_PERIOD_SEC}
# height
#export NL_VERT_LOCALIZATION_COORD=3
# scale height
export NL_VERT_LOCALIZATION_COORD=4
export NL_CENTER_SEARCH_HALF_LENGTH=500000.
export NL_CENTER_SPLINE_GRID_SCALE=10
export NL_SFC_ELEV_MAX_DIFF=100.0
export NL_CIRCULATION_PRES_LEVEL=80000.0
export NL_CIRCULATION_RADIUS=108000.0
export NL_ALLOW_OBS_BELOW_VOL=.false.
#
# &obs_diag_nml
export NL_FIRST_BIN_CENTER_YY=${DT_YYYY}
export NL_FIRST_BIN_CENTER_MM=${DT_MM}
export NL_FIRST_BIN_CENTER_DD=${DT_DD}
export NL_FIRST_BIN_CENTER_HH=${DT_HH}
export NL_LAST_BIN_CENTER_YY=${DT_YYYY}
export NL_LAST_BIN_CENTER_MM=${DT_MM}
export NL_LAST_BIN_CENTER_DD=${DT_DD}
export NL_LAST_BIN_CENTER_HH=${DT_HH}
export NL_BIN_SEPERATION_YY=0
export NL_BIN_SEPERATION_MM=0
export NL_BIN_SEPERATION_DD=0
export NL_BIN_SEPERATION_HH=0
export NL_BIN_WIDTH_YY=0
export NL_BIN_WIDTH_MM=0
export NL_BIN_WIDTH_DD=0
export NL_BIN_WIDTH_HH=0
#
# &restart_file_utility_nml
export NL_SINGLE_RESTART_FILE_IN=.false.       
export NL_SINGLE_RESTART_FILE_OUT=.false.       
#
# &dart_to_wrf_nml
export NL_MODEL_ADVANCE_FILE=.false.
export NL_ADV_MOD_COMMAND="'mpirun -np 64 ./wrf.exe'"
export NL_DART_RESTART_NAME="'dart_wrf_vector'"
#
# &wrf_to_dart_nml
#
# &restart_file_tool_nml
export NL_INPUT_FILE_NAME="'assim_model_state_tp'"
export NL_OUTPUT_FILE_NAME="'assim_model_state_ic'"
export NL_OUTPUT_IS_MODEL_ADVANCE_FILE=.true.
export NL_OVERWRITE_ADVANCE_TIME=.true.
export NL_NEW_ADVANCE_DAYS=${NEXT_DAY_GREG}
export NL_NEW_ADVANCE_SECS=${NEXT_SEC_GREG}
#
# &preprocess_nml
export NL_INPUT_OBS_KIND_MOD_FILE=\'${DART_DIR}/obs_kind/DEFAULT_obs_kind_mod.F90\'
export NL_OUTPUT_OBS_KIND_MOD_FILE=\'${DART_DIR}/obs_kind/obs_kind_mod.f90\'
export NL_INPUT_OBS_DEF_MOD_FILE=\'${DART_DIR}/obs_kind/DEFAULT_obs_def_mod.F90\'
export NL_OUTPUT_OBS_DEF_MOD_FILE=\'${DART_DIR}/obs_kind/obs_def_mod.f90\'
export NL_INPUT_FILES="'${DART_DIR}/obs_def/obs_def_reanalysis_bufr_mod.f90',
                    '${DART_DIR}/obs_def/obs_def_radar_mod.f90',
                    '${DART_DIR}/obs_def/obs_def_metar_mod.f90',
                    '${DART_DIR}/obs_def/obs_def_dew_point_mod.f90',
                    '${DART_DIR}/obs_def/obs_def_altimeter_mod.f90',
                    '${DART_DIR}/obs_def/obs_def_gps_mod.f90',
                    '${DART_DIR}/obs_def/obs_def_gts_mod.f90',
                    '${DART_DIR}/obs_def/obs_def_vortex_mod.f90'"
#
# &obs_kind_nml
export NL_ASSIMILATE_THESE_OBS_TYPES="'RADIOSONDE_TEMPERATURE',
                                   'RADIOSONDE_U_WIND_COMPONENT',
                                   'RADIOSONDE_V_WIND_COMPONENT',
                                   'RADIOSONDE_SPECIFIC_HUMIDITY',
                                   'ACARS_U_WIND_COMPONENT',
                                   'ACARS_V_WIND_COMPONENT',
                                   'ACARS_TEMPERATURE',
                                   'AIRCRAFT_U_WIND_COMPONENT',
                                   'AIRCRAFT_V_WIND_COMPONENT',
                                   'AIRCRAFT_TEMPERATURE',
                                   'SAT_U_WIND_COMPONENT',
                                   'SAT_V_WIND_COMPONENT'"
export NL_EVALUATE_THESE_OBS_TYPES="' '"
#
# &replace_wrf_fields_nml
export NL_FIELDNAMES="'SNOWC',
                   'ALBBCK',
                   'TMN',
                   'TSK',
                   'SH2O',
                   'SMOIS',
                   'SEAICE',
                   'HGT_d01',
                   'TSLB',
                   'SST',
                   'SNOWH',
                   'SNOW'"
export NL_FIELDLIST_FILE="' '"
#
# &location_nml
export NL_HORIZ_DIST_ONLY=.false.
#export NL_VERT_NORMALIZATION_HEIGHT=40000.0
#export NL_VERT_NORMALIZATION_HEIGHT=30000.0
#export NL_VERT_NORMALIZATION_HEIGHT=20000.0
export NL_VERT_NORMALIZATION_HEIGHT=10000.0
export NL_VERT_NORMALIZATION_SCALE_HEIGHT=1.5
#
# ASSIMILATION WINDOW PARAMETERS
export ASIM_DATE_MIN=$(${BUILD_DIR}/da_advance_time.exe ${DATE} -${ASIM_WINDOW} 2>/dev/null)
export ASIM_DATE_MAX=$(${BUILD_DIR}/da_advance_time.exe ${DATE} +${ASIM_WINDOW} 2>/dev/null)
export ASIM_MN_YYYY=$(echo $ASIM_DATE_MIN | cut -c1-4)
export ASIM_MN_MM=$(echo $ASIM_DATE_MIN | cut -c5-6)
export ASIM_MN_DD=$(echo $ASIM_DATE_MIN | cut -c7-8)
export ASIM_MN_HH=$(echo $ASIM_DATE_MIN | cut -c9-10)
#
export ASIM_MX_YYYY=$(echo $ASIM_DATE_MAX | cut -c1-4)
export ASIM_MX_MM=$(echo $ASIM_DATE_MAX | cut -c5-6)
export ASIM_MX_DD=$(echo $ASIM_DATE_MAX | cut -c7-8)
export ASIM_MX_HH=$(echo $ASIM_DATE_MAX | cut -c9-10)
#
#########################################################################
#
# CREATE RUN DIRECTORY
#
#########################################################################
#
if [[ ! -e ${RUN_DIR} ]]; then mkdir ${RUN_DIR}; fi
cd ${RUN_DIR}
#
#########################################################################
#
# RUN GEOGRID
#
#########################################################################
#
if [[ ${RUN_GEOGRID} = "true" ]]; then
   mkdir -p ${RUN_DIR}/geogrid
   cd ${RUN_DIR}/geogrid
#
   cp ${WPS_DIR}/geogrid.exe ./.
   export NL_DX=${DX_CR}
   export NL_DY=${DX_CR}
   export NL_START_DATE=${FILE_DATE}
   export NL_END_DATE=${NEXT_FILE_DATE}
   ${HYBRID_SCRIPTS_DIR}/da_create_wps_namelist_RT.ksh
#
#   RANDOM=$$
#   export JOBRND=${RANDOM}_geogrid
#   ${HYBRID_SCRIPTS_DIR}/job_script_summit.ksh ${JOBRND} ${GENERAL_JOB_CLASS} ${GENERAL_TIME_LIMIT} ${GENERAL_NODES} ${GENERAL_TASKS} geogrid.exe SERIAL
#   sbatch -W job.ksh
    ./geogrid.exe > index.html 2>&1
fi
#
#########################################################################
#
# RUN UNGRIB
#
#########################################################################
#
if [[ ${RUN_UNGRIB} = "true" ]]; then 
   mkdir -p ${RUN_DIR}/${DATE}/ungrib
   cd ${RUN_DIR}/${DATE}/ungrib
   rm -rf GRIBFILE.*
#
   cp ${VTABLE_DIR}/Vtable.${VTABLE_TYPE} Vtable
   cp ${WPS_DIR}/ungrib.exe ./.
#
   export L_FCST_RANGE=${LBC_END}
   export L_START_DATE=${DATE}
   export L_END_DATE=$($BUILD_DIR/da_advance_time.exe ${L_START_DATE} ${L_FCST_RANGE} 2>/dev/null)
   export L_START_YEAR=$(echo $L_START_DATE | cut -c1-4)
   export L_START_MONTH=$(echo $L_START_DATE | cut -c5-6)
   export L_START_DAY=$(echo $L_START_DATE | cut -c7-8)
   export L_START_HOUR=$(echo $L_START_DATE | cut -c9-10)
   export L_END_YEAR=$(echo $L_END_DATE | cut -c1-4)
   export L_END_MONTH=$(echo $L_END_DATE | cut -c5-6)
   export L_END_DAY=$(echo $L_END_DATE | cut -c7-8)
   export L_END_HOUR=$(echo $L_END_DATE | cut -c9-10)
   export NL_START_YEAR=$(echo $L_START_DATE | cut -c1-4),$(echo $L_START_DATE | cut -c1-4),$(echo $L_START_DATE | cut -c1-4)
   export NL_START_MONTH=$(echo $L_START_DATE | cut -c5-6),$(echo $L_START_DATE | cut -c5-6),$(echo $L_START_DATE | cut -c5-6)
   export NL_START_DAY=$(echo $L_START_DATE | cut -c7-8),$(echo $L_START_DATE | cut -c7-8),$(echo $L_START_DATE | cut -c7-8)
   export NL_START_HOUR=$(echo $L_START_DATE | cut -c9-10),$(echo $L_START_DATE | cut -c9-10),$(echo $L_START_DATE | cut -c9-10)
   export NL_END_YEAR=$(echo $L_END_DATE | cut -c1-4),$(echo $L_END_DATE | cut -c1-4),$(echo $L_END_DATE | cut -c1-4)
   export NL_END_MONTH=$(echo $L_END_DATE | cut -c5-6),$(echo $L_END_DATE | cut -c5-6),$(echo $L_END_DATE | cut -c5-6)
   export NL_END_DAY=$(echo $L_END_DATE | cut -c7-8),$(echo $L_END_DATE | cut -c7-8),$(echo $L_END_DATE | cut -c7-8)
   export NL_END_HOUR=$(echo $L_END_DATE | cut -c9-10),$(echo $L_END_DATE | cut -c9-10),$(echo $L_END_DATE | cut -c9-10)
   export NL_START_DATE=\'${L_START_YEAR}-${L_START_MONTH}-${L_START_DAY}_${L_START_HOUR}:00:00\',\'${L_START_YEAR}-${L_START_MONTH}-${L_START_DAY}_${L_START_HOUR}:00:00\',\'${L_START_YEAR}-${L_START_MONTH}-${L_START_DAY}_${L_START_HOUR}:00:00\'
   export NL_END_DATE=\'${L_END_YEAR}-${L_END_MONTH}-${L_END_DAY}_${L_END_HOUR}:00:00\',\'${L_END_YEAR}-${L_END_MONTH}-${L_END_DAY}_${L_END_HOUR}:00:00\',\'${L_END_YEAR}-${L_END_MONTH}-${L_END_DAY}_${L_END_HOUR}:00:00\'
   ${HYBRID_SCRIPTS_DIR}/da_create_wps_namelist_RT.ksh
#
# UNTAR THE PARENT FORECAST FILES
   FILES=''
   if [[ -e ${EXPERIMENT_GFS_DIR}/${DATE} ]]; then
      if [[ -e ${EXPERIMENT_GFS_DIR}/${DATE}/${GRIB_PART1}${DATE}${GRIB_PART2} ]]; then
#         cd ${EXPERIMENT_GFS_DIR}/${DATE}
         tar xvfs ${EXPERIMENT_GFS_DIR}/${DATE}/${GRIB_PART1}${DATE}${GRIB_PART2}
#         cd ${RUN_DIR}/${DATE}/ungrib
      else
         echo 'APM: ERROR - No GRIB files in directory'
         exit
      fi
      sleep 30
#  
      if [[ ${SINGLE_FILE} == false ]]; then
         export CCHH=${HH}00
         (( LBC_ITR=${LBC_START} ))
         while [[ ${LBC_ITR} -le ${LBC_END} ]]; do
            if [[ ${LBC_ITR} -lt 1000 ]]; then export CFTM=${LBC_ITR}; fi
            if [[ ${LBC_ITR} -lt 100  ]]; then export CFTM=0${LBC_ITR}; fi
            if [[ ${LBC_ITR} -lt 10   ]]; then export CFTM=00${LBC_ITR}; fi
            if [[ ${LBC_ITR} -eq 0    ]]; then export CFTM=000; fi
#            export FILE=${EXPERIMENT_GFS_DIR}/${DATE}/${GRIB_PART1}${START_YEAR}${START_MONTH}${START_DAY}_${CCHH}_${CFTM}.grb2
            export FILE=${GRIB_PART1}${START_YEAR}${START_MONTH}${START_DAY}_${CCHH}_${CFTM}.grb2
            FILES="${FILES} ${FILE}"
            (( LBC_ITR=${LBC_ITR}+${LBC_FREQ} ))
         done
      else
         export FILE=${EXPERIMENT_GFS_DIR}/${DATE}/GFS_Global_0p5deg_20080612_1800.grib2
         FILES="${FILES} ${FILE}"
      fi
   fi
#
# LINK GRIB FILES
   ${WPS_DIR}/link_grib.csh $FILES
#
#   RANDOM=$$
#   export JOBRND=${RANDOM}_ungrib
#   ${HYBRID_SCRIPTS_DIR}/job_script_summit.ksh ${JOBRND} ${GENERAL_JOB_CLASS} ${GENERAL_TIME_LIMIT} ${GENERAL_NODES} ${GENERAL_TASKS} ungrib.exe SERIAL
#   sbatch -W job.ksh
   ./ungrib.exe > index.html 2>&1
#
# TAR THE PARENT FORECAST FILES
#    rm -rf *.grb2
#   if [[ -e ${EXPERIMENT_GFS_DIR}/${DATE}/${GRIB_PART1}${DATE}${GRIB_PART2} ]]; then
#      rm -rf ${EXPERIMENT_GFS_DIR}/${DATE}/${GRIB_PART1}*.grb2
#   else
#      cd ${EXPERIMENT_GFS_DIR}
#      tar -cf ${GRIB_PART1}${DATE}${GRIB_PART2} ${DATE}
#      mv ${GRIB_PART1}${DATE}${GRIB_PART2} ${DATE}/.
#      if [[ -e ${DATE}/${GRIB_PART1}${DATE}${GRIB_PART2} ]]; then
#         rm -rf ${DATE}/${GRIB_PART1}*.grb2
#      else
#         echo 'APM: Failed to created tar file'
#         exit
#      fi
#      cd ${RUN_DIR}/${DATE}/ungrib
#   fi
fi
#
#########################################################################
#
# RUN METGRID
#
#########################################################################
#
if [[ ${RUN_METGRID} = "true" ]]; then 
   mkdir -p ${RUN_DIR}/${DATE}/metgrid
   cd ${RUN_DIR}/${DATE}/metgrid
#
   ln -fs ${GEOGRID_DIR}/geo_em.d${CR_DOMAIN}.nc ./.
   ln -fs ${GEOGRID_DIR}/geo_em.d${FR_DOMAIN}.nc ./.
   ln -fs ${GEOGRID_DIR}/geo_em.d${VF_DOMAIN}.nc ./.
   ln -fs ../ungrib/FILE:* ./.
   ln -fs ${WPS_DIR}/metgrid/METGRID.TBL.${METGRID_TABLE_TYPE} METGRID.TBL
   ln -fs ${WPS_DIR}/metgrid.exe .
#
   export L_FCST_RANGE=${LBC_END}
   export L_START_DATE=${DATE}
   export L_END_DATE=$($BUILD_DIR/da_advance_time.exe ${L_START_DATE} ${L_FCST_RANGE} 2>/dev/null)
   export L_START_YEAR=$(echo $L_START_DATE | cut -c1-4)
   export L_START_MONTH=$(echo $L_START_DATE | cut -c5-6)
   export L_START_DAY=$(echo $L_START_DATE | cut -c7-8)
   export L_START_HOUR=$(echo $L_START_DATE | cut -c9-10)
   export L_END_YEAR=$(echo $L_END_DATE | cut -c1-4)
   export L_END_MONTH=$(echo $L_END_DATE | cut -c5-6)
   export L_END_DAY=$(echo $L_END_DATE | cut -c7-8)
   export L_END_HOUR=$(echo $L_END_DATE | cut -c9-10)
   export NL_START_YEAR=$(echo $L_START_DATE | cut -c1-4),$(echo $L_START_DATE | cut -c1-4),$(echo $L_START_DATE | cut -c1-4)
   export NL_START_MONTH=$(echo $L_START_DATE | cut -c5-6),$(echo $L_START_DATE | cut -c5-6),$(echo $L_START_DATE | cut -c5-6)
   export NL_START_DAY=$(echo $L_START_DATE | cut -c7-8),$(echo $L_START_DATE | cut -c7-8),$(echo $L_START_DATE | cut -c7-8)
   export NL_START_HOUR=$(echo $L_START_DATE | cut -c9-10),$(echo $L_START_DATE | cut -c9-10),$(echo $L_START_DATE | cut -c9-10)
   export NL_END_YEAR=$(echo $L_END_DATE | cut -c1-4),$(echo $L_END_DATE | cut -c1-4),$(echo $L_END_DATE | cut -c1-4)
   export NL_END_MONTH=$(echo $L_END_DATE | cut -c5-6),$(echo $L_END_DATE | cut -c5-6),$(echo $L_END_DATE | cut -c5-6)
   export NL_END_DAY=$(echo $L_END_DATE | cut -c7-8),$(echo $L_END_DATE | cut -c7-8),$(echo $L_END_DATE | cut -c7-8)
   export NL_END_HOUR=$(echo $L_END_DATE | cut -c9-10),$(echo $L_END_DATE | cut -c9-10),$(echo $L_END_DATE | cut -c9-10)
   export NL_START_DATE=\'${L_START_YEAR}-${L_START_MONTH}-${L_START_DAY}_${L_START_HOUR}:00:00\',\'${L_START_YEAR}-${L_START_MONTH}-${L_START_DAY}_${L_START_HOUR}:00:00\',\'${L_START_YEAR}-${L_START_MONTH}-${L_START_DAY}_${L_START_HOUR}:00:00\'
   export NL_END_DATE=\'${L_END_YEAR}-${L_END_MONTH}-${L_END_DAY}_${L_END_HOUR}:00:00\',\'${L_END_YEAR}-${L_END_MONTH}-${L_END_DAY}_${L_END_HOUR}:00:00\',\'${L_END_YEAR}-${L_END_MONTH}-${L_END_DAY}_${L_END_HOUR}:00:00\'
   ${HYBRID_SCRIPTS_DIR}/da_create_wps_namelist_RT.ksh
#
#   RANDOM=$$
#   export JOBRND=${RANDOM}_metgrid
#   ${HYBRID_SCRIPTS_DIR}/job_script_summit.ksh ${JOBRND} ${GENERAL_JOB_CLASS} ${GENERAL_TIME_LIMIT} ${GENERAL_NODES} ${GENERAL_TASKS} metgrid.exe SERIAL
#   sbatch -W job.ksh
    ./metgrid.exe > index.html 2>&1
fi
#
#########################################################################
#
# RUN REAL
#
#########################################################################
#
if [[ ${RUN_REAL} = "true" ]]; then 
   mkdir -p ${RUN_DIR}/${DATE}/real
   cd ${RUN_DIR}/${DATE}/real
#
   cp ${WRF_DIR}/main/real.exe ./.
#
# LINK IN THE METGRID FILES
   export P_DATE=${DATE}
   export P_END_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} ${LBC_END} 2>/dev/null)
   while [[ ${P_DATE} -le ${P_END_DATE} ]] ; do
      export P_YYYY=$(echo $P_DATE | cut -c1-4)
      export P_MM=$(echo $P_DATE | cut -c5-6)
      export P_DD=$(echo $P_DATE | cut -c7-8)
      export P_HH=$(echo $P_DATE | cut -c9-10)
      export P_FILE_DATE=${P_YYYY}-${P_MM}-${P_DD}_${P_HH}:00:00.nc
      ln -sf ${RUN_DIR}/${DATE}/metgrid/met_em.d${CR_DOMAIN}.${P_FILE_DATE} ./.
      ln -sf ${RUN_DIR}/${DATE}/metgrid/met_em.d${FR_DOMAIN}.${P_FILE_DATE} ./.
      ln -sf ${RUN_DIR}/${DATE}/metgrid/met_em.d${VF_DOMAIN}.${P_FILE_DATE} ./.
      export P_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} ${LBC_FREQ} 2>/dev/null) 
   done
#
# LOOP THROUGH BDY TENDENCY TIMES FOR PERTURB_BC
   export P_DATE=${DATE}
   export P_END_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} ${FCST_PERIOD} 2>/dev/null)
   while [[ ${P_DATE} -le ${P_END_DATE} ]] ; do      
#
# CREATE WRF NAMELIST
      export NL_IOFIELDS_FILENAME=' ',' ',' '
      export L_FCST_RANGE=${FCST_PERIOD}
      export NL_DX=${DX_CR},${DX_FR},${DX_VF}
      export NL_DY=${DX_CR},${DX_FR},${DX_VF}
      export L_START_DATE=${P_DATE}
      export L_END_DATE=$($BUILD_DIR/da_advance_time.exe ${L_START_DATE} ${L_FCST_RANGE} 2>/dev/null)
      export L_START_YEAR=$(echo $L_START_DATE | cut -c1-4)
      export L_START_MONTH=$(echo $L_START_DATE | cut -c5-6)
      export L_START_DAY=$(echo $L_START_DATE | cut -c7-8)
      export L_START_HOUR=$(echo $L_START_DATE | cut -c9-10)
      export L_END_YEAR=$(echo $L_END_DATE | cut -c1-4)
      export L_END_MONTH=$(echo $L_END_DATE | cut -c5-6)
      export L_END_DAY=$(echo $L_END_DATE | cut -c7-8)
      export L_END_HOUR=$(echo $L_END_DATE | cut -c9-10)
      export NL_START_YEAR=$(echo $L_START_DATE | cut -c1-4),$(echo $L_START_DATE | cut -c1-4),$(echo $L_START_DATE | cut -c1-4)
      export NL_START_MONTH=$(echo $L_START_DATE | cut -c5-6),$(echo $L_START_DATE | cut -c5-6),$(echo $L_START_DATE | cut -c5-6)
      export NL_START_DAY=$(echo $L_START_DATE | cut -c7-8),$(echo $L_START_DATE | cut -c7-8),$(echo $L_START_DATE | cut -c7-8)
      export NL_START_HOUR=$(echo $L_START_DATE | cut -c9-10),$(echo $L_START_DATE | cut -c9-10),$(echo $L_START_DATE | cut -c9-10)
      export NL_END_YEAR=$(echo $L_END_DATE | cut -c1-4),$(echo $L_END_DATE | cut -c1-4),$(echo $L_END_DATE | cut -c1-4)
      export NL_END_MONTH=$(echo $L_END_DATE | cut -c5-6),$(echo $L_END_DATE | cut -c5-6),$(echo $L_END_DATE | cut -c5-6)
      export NL_END_DAY=$(echo $L_END_DATE | cut -c7-8),$(echo $L_END_DATE | cut -c7-8),$(echo $L_END_DATE | cut -c7-8)
      export NL_END_HOUR=$(echo $L_END_DATE | cut -c9-10),$(echo $L_END_DATE | cut -c9-10),$(echo $L_END_DATE | cut -c9-10)
      export NL_START_DATE=\'${L_START_YEAR}-${L_START_MONTH}-${L_START_DAY}_${L_START_HOUR}:00:00\',\'${L_START_YEAR}-${L_START_MONTH}-${L_START_DAY}_${L_START_HOUR}:00:00\',\'${L_START_YEAR}-${L_START_MONTH}-${L_START_DAY}_${L_START_HOUR}:00:00\'
      export NL_END_DATE=\'${L_END_YEAR}-${L_END_MONTH}-${L_END_DAY}_${L_END_HOUR}:00:00\',\'${L_END_YEAR}-${L_END_MONTH}-${L_END_DAY}_${L_END_HOUR}:00:00\',\'${L_END_YEAR}-${L_END_MONTH}-${L_END_DAY}_${L_END_HOUR}:00:00\'
      ${HYBRID_SCRIPTS_DIR}/da_create_wrfchem_namelist_nested_RT.ksh
#
#      RANDOM=$$
#      export JOBRND=${RANDOM}_real
#      ${HYBRID_SCRIPTS_DIR}/job_script_summit.ksh ${JOBRND} ${GENERAL_JOB_CLASS} ${GENERAL_TIME_LIMIT} ${GENERAL_NODES} ${GENERAL_TASKS} real.exe SERIAL
#      sbatch -W job.ksh
      ./real.exe > index.html 2>&1
#
      mv wrfinput_d${CR_DOMAIN} wrfinput_d${CR_DOMAIN}_$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} 0 -W 2>/dev/null)
      mv wrfinput_d${FR_DOMAIN} wrfinput_d${FR_DOMAIN}_$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} 0 -W 2>/dev/null)
      mv wrfinput_d${VF_DOMAIN} wrfinput_d${VF_DOMAIN}_$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} 0 -W 2>/dev/null)
      mv wrfbdy_d${CR_DOMAIN} wrfbdy_d${CR_DOMAIN}_$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} 0 -W 2>/dev/null)
#      mv wrfbdy_d${FR_DOMAIN} wrfbdy_d${FR_DOMAIN}_$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} 0 -W 2>/dev/null)
      export P_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} ${LBC_FREQ} 2>/dev/null) 
   done
fi
#
#########################################################################
#
# RUN INTERPOLATION TO GET MISSING BACKGROUND DATA
#
#########################################################################
#
if [[ ${RUN_INTERPOLATE} = "true" ]]; then 
   if [[ ! -d ${RUN_DIR}/${DATE}/metgrid ]]; then
      mkdir -p ${RUN_DIR}/${DATE}/metgrid
   fi
   if [[ ! -d ${RUN_DIR}/${DATE}/real ]]; then
      mkdir -p ${RUN_DIR}/${DATE}/real
   fi
#
# GET METGRID DATA
   cd ${RUN_DIR}/${DATE}/metgrid
   rm -rf met_em.d*
#
# LINK IN THE BACK AND FORW METGRID FILES
   export P_DATE=${BACK_DATE}
   export P_END_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} ${LBC_END} 2>/dev/null)
   while [[ ${P_DATE} -le ${P_END_DATE} ]] ; do
      export P_YYYY=$(echo $P_DATE | cut -c1-4)
      export P_MM=$(echo $P_DATE | cut -c5-6)
      export P_DD=$(echo $P_DATE | cut -c7-8)
      export P_HH=$(echo $P_DATE | cut -c9-10)
      export P_FILE_DATE=${P_YYYY}-${P_MM}-${P_DD}_${P_HH}:00:00.nc
      ln -sf ${RUN_DIR}/${BACK_DATE}/metgrid/met_em.d${CR_DOMAIN}.${P_FILE_DATE} ./BK_met_em.d${CR_DOMAIN}.${P_FILE_DATE}
      ln -sf ${RUN_DIR}/${BACK_DATE}/metgrid/met_em.d${FR_DOMAIN}.${P_FILE_DATE} ./BK_met_em.d${FR_DOMAIN}.${P_FILE_DATE}
      export P_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} ${LBC_FREQ} 2>/dev/null) 
   done
   export P_DATE=${FORW_DATE}
   export P_END_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} ${LBC_END} 2>/dev/null)
   while [[ ${P_DATE} -le ${P_END_DATE} ]] ; do
      export P_YYYY=$(echo $P_DATE | cut -c1-4)
      export P_MM=$(echo $P_DATE | cut -c5-6)
      export P_DD=$(echo $P_DATE | cut -c7-8)
      export P_HH=$(echo $P_DATE | cut -c9-10)
      export P_FILE_DATE=${P_YYYY}-${P_MM}-${P_DD}_${P_HH}:00:00.nc
      ln -sf ${RUN_DIR}/${FORW_DATE}/metgrid/met_em.d${CR_DOMAIN}.${P_FILE_DATE} ./FW_met_em.d${CR_DOMAIN}.${P_FILE_DATE}
      ln -sf ${RUN_DIR}/${FORW_DATE}/metgrid/met_em.d${FR_DOMAIN}.${P_FILE_DATE} ./FW_met_em.d${FR_DOMAIN}.${P_FILE_DATE}
      export P_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} ${LBC_FREQ} 2>/dev/null) 
   done
#
# DO INTERPOLATION
   export P_DATE=${DATE}
   export P_BACK_DATE=${BACK_DATE}
   export P_FORW_DATE=${FORW_DATE}
   export P_END_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} ${LBC_END} 2>/dev/null)
   while [[ ${P_DATE} -le ${P_END_DATE} ]] ; do
      export P_YYYY=$(echo $P_DATE | cut -c1-4)
      export P_MM=$(echo $P_DATE | cut -c5-6)
      export P_DD=$(echo $P_DATE | cut -c7-8)
      export P_HH=$(echo $P_DATE | cut -c9-10)
      export P_FILE_DATE=${P_YYYY}-${P_MM}-${P_DD}_${P_HH}:00:00
      export P_BK_YYYY=$(echo $P_BACK_DATE | cut -c1-4)
      export P_BK_MM=$(echo $P_BACK_DATE | cut -c5-6)
      export P_BK_DD=$(echo $P_BACK_DATE | cut -c7-8)
      export P_BK_HH=$(echo $P_BACK_DATE | cut -c9-10)
      export P_BACK_FILE_DATE=${P_BK_YYYY}-${P_BK_MM}-${P_BK_DD}_${P_BK_HH}:00:00
      export P_FW_YYYY=$(echo $P_FORW_DATE | cut -c1-4)
      export P_FW_MM=$(echo $P_FORW_DATE | cut -c5-6)
      export P_FW_DD=$(echo $P_FORW_DATE | cut -c7-8)
      export P_FW_HH=$(echo $P_FORW_DATE | cut -c9-10)
      export P_FORW_FILE_DATE=${P_FW_YYYY}-${P_FW_MM}-${P_FW_DD}_${P_FW_HH}:00:00
      export BACK_FILE_CR=BK_met_em.d${CR_DOMAIN}.${P_BACK_FILE_DATE}.nc
      export BACK_FILE_FR=BK_met_em.d${FR_DOMAIN}.${P_BACK_FILE_DATE}.nc
      export FORW_FILE_CR=FW_met_em.d${CR_DOMAIN}.${P_FORW_FILE_DATE}.nc
      export FORW_FILE_FR=FW_met_em.d${FR_DOMAIN}.${P_FORW_FILE_DATE}.nc
      export OUTFILE_CR=met_em.d${CR_DOMAIN}.${P_FILE_DATE}.nc
      export OUTFILE_FR=met_em.d${FR_DOMAIN}.${P_FILE_DATE}.nc
      export TIME_INTERP_DIR1=${DART_DIR}/models/wrf
      export TIME_INTERP_DIR2=run_scripts/RUN_TIME_INTERP
      export FIX_TIME_FILE=${TIME_INTERP_DIR1}/${TIME_INTERP_DIR2}/fix_time_stamp.exe
      export NUM_FIX_DATES=1
      cp ${FIX_TIME_FILE} ./.
#
# CREATE NAMELIST
      rm -rf time_stamp_nml.nl
      cat << EOF > time_stamp_nml.nl
&time_stamp_nml
time_str1='${P_FILE_DATE}'
file_str='${OUTFILE_CR}'
num_dates=${NUM_FIX_DATES}
file_sw=0
/
EOF
      ncflint -w ${BACK_WT} ${BACK_FILE_CR} ${FORW_FILE_CR} ${OUTFILE_CR}
      ./fix_time_stamp.exe
#
# CREATE NAMELIST
      rm -rf time_stamp_nml.nl
      cat << EOF > time_stamp_nml.nl
&time_stamp_nml
time_str1='${P_FILE_DATE}'
file_str='${OUTFILE_FR}'
num_dates=${NUM_FIX_DATES}
file_sw=0
/
EOF
      ncflint -w ${BACK_WT} ${BACK_FILE_FR} ${FORW_FILE_FR} ${OUTFILE_FR}
      ./fix_time_stamp.exe
      export P_BACK_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_BACK_DATE} ${LBC_FREQ} 2>/dev/null) 
      export P_FORW_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_FORW_DATE} ${LBC_FREQ} 2>/dev/null) 
      export P_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} ${LBC_FREQ} 2>/dev/null) 
   done
#
# GET REAL DATA
   cd ${RUN_DIR}/${DATE}/real
   rm -rf wrfbdy_d*
   rm -rf wrfinput_d*
#
# LINK IN THE BACK AND FORW WRFBDY AND WRFINPUT FILES
   export P_DATE=${BACK_DATE}
   export P_END_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} ${FCST_PERIOD} 2>/dev/null)
   while [[ ${P_DATE} -le ${P_END_DATE} ]] ; do
      export P_YYYY=$(echo $P_DATE | cut -c1-4)
      export P_MM=$(echo $P_DATE | cut -c5-6)
      export P_DD=$(echo $P_DATE | cut -c7-8)
      export P_HH=$(echo $P_DATE | cut -c9-10)
      export P_FILE_DATE=${P_YYYY}-${P_MM}-${P_DD}_${P_HH}:00:00
      ln -sf ${RUN_DIR}/${BACK_DATE}/real/wrfbdy_d${CR_DOMAIN}_${P_FILE_DATE} ./BK_wrfbdy_d${CR_DOMAIN}_${P_FILE_DATE}
      ln -sf ${RUN_DIR}/${BACK_DATE}/real/wrfinput_d${CR_DOMAIN}_${P_FILE_DATE} ./BK_wrfinput_d${CR_DOMAIN}_${P_FILE_DATE}
      ln -sf ${RUN_DIR}/${BACK_DATE}/real/wrfinput_d${FR_DOMAIN}_${P_FILE_DATE} ./BK_wrfinput_d${FR_DOMAIN}_${P_FILE_DATE}
      export P_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} ${LBC_FREQ} 2>/dev/null) 
   done
   export P_DATE=${FORW_DATE}
   export P_END_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} ${FCST_PERIOD} 2>/dev/null)
   while [[ ${P_DATE} -le ${P_END_DATE} ]] ; do
      export P_YYYY=$(echo $P_DATE | cut -c1-4)
      export P_MM=$(echo $P_DATE | cut -c5-6)
      export P_DD=$(echo $P_DATE | cut -c7-8)
      export P_HH=$(echo $P_DATE | cut -c9-10)
      export P_FILE_DATE=${P_YYYY}-${P_MM}-${P_DD}_${P_HH}:00:00
      ln -sf ${RUN_DIR}/${FORW_DATE}/real/wrfbdy_d${CR_DOMAIN}_${P_FILE_DATE} ./FW_wrfbdy_d${CR_DOMAIN}_${P_FILE_DATE}
      ln -sf ${RUN_DIR}/${FORW_DATE}/real/wrfinput_d${CR_DOMAIN}_${P_FILE_DATE} ./FW_wrfinput_d${CR_DOMAIN}_${P_FILE_DATE}
      ln -sf ${RUN_DIR}/${FORW_DATE}/real/wrfinput_d${FR_DOMAIN}_${P_FILE_DATE} ./FW_wrfinput_d${FR_DOMAIN}_${P_FILE_DATE}
      export P_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} ${LBC_FREQ} 2>/dev/null) 
   done
#
# DO INTERPOLATION
   export P_DATE=${DATE}
   export P_BACK_DATE=${BACK_DATE}
   export P_FORW_DATE=${FORW_DATE}
   export P_END_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} ${FCST_PERIOD} 2>/dev/null)
   while [[ ${P_DATE} -le ${P_END_DATE} ]] ; do
      export P_YYYY=$(echo $P_DATE | cut -c1-4)
      export P_MM=$(echo $P_DATE | cut -c5-6)
      export P_DD=$(echo $P_DATE | cut -c7-8)
      export P_HH=$(echo $P_DATE | cut -c9-10)
      export P_FILE_DATE=${P_YYYY}-${P_MM}-${P_DD}_${P_HH}:00:00
      export P_BK_YYYY=$(echo $P_BACK_DATE | cut -c1-4)
      export P_BK_MM=$(echo $P_BACK_DATE | cut -c5-6)
      export P_BK_DD=$(echo $P_BACK_DATE | cut -c7-8)
      export P_BK_HH=$(echo $P_BACK_DATE | cut -c9-10)
      export P_BACK_FILE_DATE=${P_BK_YYYY}-${P_BK_MM}-${P_BK_DD}_${P_BK_HH}:00:00
      export P_FW_YYYY=$(echo $P_FORW_DATE | cut -c1-4)
      export P_FW_MM=$(echo $P_FORW_DATE | cut -c5-6)
      export P_FW_DD=$(echo $P_FORW_DATE | cut -c7-8)
      export P_FW_HH=$(echo $P_FORW_DATE | cut -c9-10)
      export P_FORW_FILE_DATE=${P_FW_YYYY}-${P_FW_MM}-${P_FW_DD}_${P_FW_HH}:00:00
      export BACK_BDYF_CR=BK_wrfbdy_d${CR_DOMAIN}_${P_BACK_FILE_DATE}
      export BACK_FILE_CR=BK_wrfinput_d${CR_DOMAIN}_${P_BACK_FILE_DATE}
      export BACK_FILE_FR=BK_wrfinput_d${FR_DOMAIN}_${P_BACK_FILE_DATE}
      export FORW_BDYF_CR=FW_wrfbdy_d${CR_DOMAIN}_${P_FORW_FILE_DATE}
      export FORW_FILE_CR=FW_wrfinput_d${CR_DOMAIN}_${P_FORW_FILE_DATE}
      export FORW_FILE_FR=FW_wrfinput_d${FR_DOMAIN}_${P_FORW_FILE_DATE}
      export BDYFILE_CR=wrfbdy_d${CR_DOMAIN}_${P_FILE_DATE}
      export OUTFILE_CR=wrfinput_d${CR_DOMAIN}_${P_FILE_DATE}
      export OUTFILE_FR=wrfinput_d${FR_DOMAIN}_${P_FILE_DATE}
      export TIME_INTERP_DIR1=${DART_DIR}/models/wrf
      export TIME_INTERP_DIR2=run_scripts/RUN_TIME_INTERP
      export FIX_TIME_FILE=${TIME_INTERP_DIR1}/${TIME_INTERP_DIR2}/fix_time_stamp.exe
      let NUM_FIX_DATES=${FCST_PERIOD}/${LBC_FREQ}
      ((FX_IDX=0)) 
      export STR_FXDT=${P_DATE}
      export END_FXDT=$(${BUILD_DIR}/da_advance_time.exe ${STR_FXDT} ${FCST_PERIOD} 2>/dev/null)
      while [[ ${STR_FXDT} -le ${END_FXDT} ]] ; do
         export FX_YYYY=$(echo $STR_FXDT | cut -c1-4)
         export FX_MM=$(echo $STR_FXDT | cut -c5-6)
         export FX_DD=$(echo $STR_FXDT | cut -c7-8)
         export FX_HH=$(echo $STR_FXDT | cut -c9-10)
         export FX_FILE_DATE[${FX_IDX}]=${FX_YYYY}-${FX_MM}-${FX_DD}_${FX_HH}:00:00
         let FX_IDX=${FX_IDX}+1
         export STR_FXDT=$(${BUILD_DIR}/da_advance_time.exe ${STR_FXDT} ${LBC_FREQ} 2>/dev/null)
      done
      ((FX_IDX=0)) 
      export STR_FXDT=$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} ${LBC_FREQ} 2>/dev/null)
      export END_FXDT=$(${BUILD_DIR}/da_advance_time.exe ${STR_FXDT} ${FCST_PERIOD} 2>/dev/null)
      while [[ ${STR_FXDT} -le ${END_FXDT} ]] ; do
         export FX_YYYY=$(echo $STR_FXDT | cut -c1-4)
         export FX_MM=$(echo $STR_FXDT | cut -c5-6)
         export FX_DD=$(echo $STR_FXDT | cut -c7-8)
         export FX_HH=$(echo $STR_FXDT | cut -c9-10)
         export FX_FILE_NEXT_DATE[${FX_IDX}]=${FX_YYYY}-${FX_MM}-${FX_DD}_${FX_HH}:00:00
         let FX_IDX=${FX_IDX}+1
         export STR_FXDT=$(${BUILD_DIR}/da_advance_time.exe ${STR_FXDT} ${LBC_FREQ} 2>/dev/null)
      done
      cp ${FIX_TIME_FILE} ./.
#
# CREATE NAMELIST
      rm -rf time_stamp_nml.nl
      cat << EOF > time_stamp_nml.nl
&time_stamp_nml
time_str1='${FX_FILE_DATE[0]}'
time_str2='${FX_FILE_DATE[1]}'
time_this_str1='${FX_FILE_DATE[0]}'
time_this_str2='${FX_FILE_DATE[1]}'
time_next_str1='${FX_FILE_NEXT_DATE[0]}'
time_next_str2='${FX_FILE_NEXT_DATE[1]}'
file_str='${BDYFILE_CR}'
num_dates=${NUM_FIX_DATES}
file_sw=1
/
EOF
      ncflint -w ${BACK_WT} ${BACK_BDYF_CR} ${FORW_BDYF_CR} ${BDYFILE_CR}
      ./fix_time_stamp.exe
      export TIME_INTERP_DIR1=${DART_DIR}/models/wrf
      export TIME_INTERP_DIR2=run_scripts/RUN_TIME_INTERP
      export FIX_TIME_FILE=${TIME_INTERP_DIR1}/${TIME_INTERP_DIR2}/fix_time_stamp.exe
      cp ${FIX_TIME_FILE} ./.
#
# CREATE NAMELIST
      rm -rf time_stamp_nml.nl
      cat << EOF > time_stamp_nml.nl
&time_stamp_nml
time_str1='${FX_FILE_DATE[0]}'
time_str2='${FX_FILE_DATE[1]}'
time_this_str1='${FX_FILE_DATE[0]}'
time_this_str2='${FX_FILE_DATE[1]}'
time_next_str1='${FX_FILE_NEXT_DATE[0]}'
time_next_str2='${FX_FILE_NEXT_DATE[1]}'
file_str='${OUTFILE_CR}'
num_dates=${NUM_FIX_DATES}
file_sw=0
/
EOF
      ncflint -w ${BACK_WT} ${BACK_FILE_CR} ${FORW_FILE_CR} ${OUTFILE_CR}
      ./fix_time_stamp.exe
      export TIME_INTERP_DIR1=${DART_DIR}/models/wrf
      export TIME_INTERP_DIR2=run_scripts/RUN_TIME_INTERP
      export FIX_TIME_FILE=${TIME_INTERP_DIR1}/${TIME_INTERP_DIR2}/fix_time_stamp.exe
      cp ${FIX_TIME_FILE} ./.
#
# CREATE NAMELIST
      rm -rf time_stamp_nml.nl
      cat << EOF > time_stamp_nml.nl
&time_stamp_nml
time_str1='${FX_FILE_DATE[0]}'
time_str2='${FX_FILE_DATE[1]}'
time_this_str1='${FX_FILE_DATE[0]}'
time_this_str2='${FX_FILE_DATE[1]}'
time_next_str1='${FX_FILE_NEXT_DATE[0]}'
time_next_str2='${FX_FILE_NEXT_DATE[1]}'
file_str='${OUTFILE_FR}'
num_dates=${NUM_FIX_DATES}
file_sw=0
/
EOF
      ncflint -w ${BACK_WT} ${BACK_FILE_FR} ${FORW_FILE_FR} ${OUTFILE_FR}
      ./fix_time_stamp.exe
      export P_BACK_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_BACK_DATE} ${LBC_FREQ} 2>/dev/null) 
      export P_FORW_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_FORW_DATE} ${LBC_FREQ} 2>/dev/null) 
      export P_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} ${LBC_FREQ} 2>/dev/null) 
   done
exit
fi
#
#########################################################################
#
# RUN PERT_WRFCHEM_MET_IC
#
#########################################################################
#
if [[ ${RUN_PERT_WRFCHEM_MET_IC} = "true" ]]; then 
   if [[ ! -d ${RUN_DIR}/${DATE}/wrfchem_met_ic ]]; then
      mkdir -p ${RUN_DIR}/${DATE}/wrfchem_met_ic
      cd ${RUN_DIR}/${DATE}/wrfchem_met_ic
   else
      cd ${RUN_DIR}/${DATE}/wrfchem_met_ic
   fi
#
   export NL_MAX_DOM=1
   export NL_OB_FORMAT=1
   export L_FCST_RANGE=${FCST_PERIOD}
   export L_START_DATE=${DATE}
   export L_END_DATE=$($BUILD_DIR/da_advance_time.exe ${L_START_DATE} ${L_FCST_RANGE} 2>/dev/null)
   export L_START_YEAR=$(echo $L_START_DATE | cut -c1-4)
   export L_START_MONTH=$(echo $L_START_DATE | cut -c5-6)
   export L_START_DAY=$(echo $L_START_DATE | cut -c7-8)
   export L_START_HOUR=$(echo $L_START_DATE | cut -c9-10)
   export L_END_YEAR=$(echo $L_END_DATE | cut -c1-4)
   export L_END_MONTH=$(echo $L_END_DATE | cut -c5-6)
   export L_END_DAY=$(echo $L_END_DATE | cut -c7-8)
   export L_END_HOUR=$(echo $L_END_DATE | cut -c9-10)
   export NL_START_YEAR=$(echo $L_START_DATE | cut -c1-4),$(echo $L_START_DATE | cut -c1-4)
   export NL_START_MONTH=$(echo $L_START_DATE | cut -c5-6),$(echo $L_START_DATE | cut -c5-6)
   export NL_START_DAY=$(echo $L_START_DATE | cut -c7-8),$(echo $L_START_DATE | cut -c7-8)
   export NL_START_HOUR=$(echo $L_START_DATE | cut -c9-10),$(echo $L_START_DATE | cut -c9-10)
   export NL_END_YEAR=$(echo $L_END_DATE | cut -c1-4),$(echo $L_END_DATE | cut -c1-4)
   export NL_END_MONTH=$(echo $L_END_DATE | cut -c5-6),$(echo $L_END_DATE | cut -c5-6)
   export NL_END_DAY=$(echo $L_END_DATE | cut -c7-8),$(echo $L_END_DATE | cut -c7-8)
   export NL_END_HOUR=$(echo $L_END_DATE | cut -c9-10),$(echo $L_END_DATE | cut -c9-10)
   export NL_START_DATE=\'${L_START_YEAR}-${L_START_MONTH}-${L_START_DAY}_${L_START_HOUR}:00:00\',\'${L_START_YEAR}-${L_START_MONTH}-${L_START_DAY}_${L_START_HOUR}:00:00\'
   export NL_END_DATE=\'${L_END_YEAR}-${L_END_MONTH}-${L_END_DAY}_${L_END_HOUR}:00:00\',\'${L_END_YEAR}-${L_END_MONTH}-${L_END_DAY}_${L_END_HOUR}:00:00\'
#
# LOOP THROUGH ALL BDY TENDENCY TIMES
   export P_DATE=${DATE}
   export P_END_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} ${FCST_PERIOD} 2>/dev/null)
   while [[ ${P_DATE} -le ${P_END_DATE} ]] ; do
#
# SET WRFDA PARAMETERS
      export ANALYSIS_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} 0 -W 2>/dev/null)
      export NL_ANALYSIS_DATE=\'${ANALYSIS_DATE}\'
      export NL_TIME_WINDOW_MIN=\'$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} -${ASIM_WINDOW} -W 2>/dev/null)\'
      export NL_TIME_WINDOW_MAX=\'$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} +${ASIM_WINDOW} -W 2>/dev/null)\'
      export NL_ANALYSIS_TYPE=\'RANDOMCV\'
      export NL_PUT_RAND_SEED=true
#
# LOOP THROUGH ALL MEMBERS IN THE ENSEMBLE
      TRANDOM=$$
      let MEM=1
      while [[ ${MEM} -le ${NUM_MEMBERS} ]]; do
         export CMEM=e${MEM}
         if [[ ${MEM} -lt 100 ]]; then export CMEM=e0${MEM}; fi
         if [[ ${MEM} -lt 10  ]]; then export CMEM=e00${MEM}; fi
#
# COARSE RESOLUTION GRID
         cd ${RUN_DIR}/${DATE}/wrfchem_met_ic
         export LCR_DIR=wrfda_cr_${MEM}
         if [[ ! -e ${LCR_DIR} ]]; then
            mkdir ${LCR_DIR}
            cd ${LCR_DIR}
         else
            cd ${LCR_DIR}
            rm -rf *
         fi
         export NL_E_WE=${NNXP_STAG_CR}
         export NL_E_SN=${NNYP_STAG_CR}
         export NL_DX=${DX_CR}
         export NL_DY=${DX_CR}
         export NL_GRID_ID=1
         export NL_PARENT_ID=0
         export NL_PARENT_GRID_RATIO=1
         export NL_I_PARENT_START=${ISTR_CR}
         export NL_J_PARENT_START=${JSTR_CR}
         export DA_INPUT_FILE=../../real/wrfinput_d${CR_DOMAIN}_${ANALYSIS_DATE}
         export NL_SEED_ARRAY1=$(${BUILD_DIR}/da_advance_time.exe ${DATE} 0 -f hhddmmyycc)
         export NL_SEED_ARRAY2=`echo ${MEM} \* 100000 | bc -l `
         ${HYBRID_SCRIPTS_DIR}/da_create_wrfda_namelist.ksh
         cp ${EXPERIMENT_PREPBUFR_DIR}/${DATE}/prepbufr.gdas.${DATE}.wo40.be ob.bufr
         cp ${DA_INPUT_FILE} fg
         cp ${BE_DIR}/be.dat.cv3 be.dat
         cp ${WRFDA_DIR}/run/LANDUSE.TBL ./.
         cp ${WRFDA_DIR}/var/da/da_wrfvar.exe ./.
#
#         RANDOM=$$
#         export JOBRND=${TRANDOM}_wrfda_cr
#         ${HYBRID_SCRIPTS_DIR}/job_script_summit.ksh ${JOBRND} ${WRFDA_JOB_CLASS} ${WRFDA_TIME_LIMIT} ${WRFDA_NODES} ${WRFDA_TASKS} da_wrfvar.exe SERIAL
#         sbatch job.ksh
          ./da_wrfvar.exe > index.html 2>&1
#
# FINE RESOLUTION GRID
#         cd ${RUN_DIR}/${DATE}/wrfchem_met_ic
#         export LFR_DIR=wrfda_fr_${MEM}
#         if [[ ! -e ${LFR_DIR} ]]; then
#            mkdir ${LFR_DIR}
#            cd ${LFR_DIR}
#         else
#            cd ${LFR_DIR}
#            rm -rf *
#         fi
#         export NL_E_WE=${NNXP_STAG_FR}
#         export NL_E_SN=${NNYP_STAG_FR}
#         export NL_DX=${DX_FR}
#         export NL_DY=${DX_FR}
#         export NL_GRID_ID=2
#         export NL_PARENT_ID=1
#         export NL_PARENT_GRID_RATIO=5
#         export NL_I_PARENT_START=${ISTR_FR}
#         export NL_J_PARENT_START=${JSTR_FR}
#         export DA_INPUT_FILE=../../real/wrfinput_d${FR_DOMAIN}_${ANALYSIS_DATE}
#         ${HYBRID_SCRIPTS_DIR}/da_create_wrfda_namelist.ksh
#         cp ${EXPERIMENT_PREPBUFR_DIR}/${DATE}/prepbufr.gdas.${DATE}.wo40.be ob.bufr
#         cp ${DA_INPUT_FILE} fg
#         cp ${BE_DIR}/be.dat.cv3 be.dat
#         cp ${WRFDA_DIR}/run/LANDUSE.TBL ./.
#         cp ${WRFDA_DIR}/var/da/da_wrfvar.exe ./.
#
#         RANDOM=$$
#         export JOBRND=${TRANDOM}_wrfda_fr
#         ${HYBRID_SCRIPTS_DIR}/job_script_summit.ksh ${JOBRND} ${WRFDA_JOB_CLASS} ${WRFDA_TIME_LIMIT} ${WRFDA_NODES} ${WRFDA_TASKS} da_wrfvar.exe SERIAL
#         sbatch job.ksh
         let MEM=${MEM}+1
      done
#
# Wait for WRFDA to complete for all members
      cd ${RUN_DIR}/${DATE}/wrfchem_met_ic
#      ${HYBRID_SCRIPTS_DIR}/da_run_hold_cu.ksh ${TRANDOM}
#
      let MEM=1
      while [[ ${MEM} -le ${NUM_MEMBERS} ]]; do
         export CMEM=e${MEM}
         if [[ ${MEM} -lt 100 ]]; then export CMEM=e0${MEM}; fi
         if [[ ${MEM} -lt 10  ]]; then export CMEM=e00${MEM}; fi
         export LCR_DIR=wrfda_cr_${MEM}
         export LFR_DIR=wrfda_fr_${MEM}
         if [[ -e ${LCR_DIR}/wrfvar_output ]]; then
            cp ${LCR_DIR}/wrfvar_output wrfinput_d${CR_DOMAIN}_${ANALYSIS_DATE}.${CMEM}
         else
            sleep 45
            cp ${LCR_DIR}/wrfvar_output wrfinput_d${CR_DOMAIN}_${ANALYSIS_DATE}.${CMEM}
         fi 
#         if [[ -e ${LFR_DIR}/wrfvar_output ]]; then
#            cp ${LFR_DIR}/wrfvar_output wrfinput_d${FR_DOMAIN}_${ANALYSIS_DATE}.${CMEM}
#         else
#            sleep 45
#            cp ${LFR_DIR}/wrfvar_output wrfinput_d${FR_DOMAIN}_${ANALYSIS_DATE}.${CMEM}
#         fi
         let MEM=${MEM}+1
      done
      export P_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} ${LBC_FREQ} 2>/dev/null) 
   done
   export NL_E_WE=${NNXP_STAG_CR},${NNXP_STAG_FR},${NNXP_STAG_VF}
   export NL_E_SN=${NNYP_STAG_CR},${NNYP_STAG_FR},${NNYP_STAG_VF}
   export NL_DX=${DX_CR},${DX_FR},${DX_VF}
   export NL_DY=${DX_CR},${DX_FR},${DX_VF}
   export NL_GRID_ID=1,2,3
   export NL_PARENT_ID=0,1,2
   export NL_PARENT_GRID_RATIO=${GRID_RATIO}
   export NL_I_PARENT_START=${ISTR_CR},${ISTR_FR},${ISTR_VF}
   export NL_J_PARENT_START=${JSTR_CR},${JSTR_FR},${JSTR_VF}
fi
#
#########################################################################
#
# RUN PERT WRFCHEM MET BC
#
#########################################################################
#
if [[ ${RUN_PERT_WRFCHEM_MET_BC} = "true" ]]; then 
   if [[ ! -d ${RUN_DIR}/${DATE}/wrfchem_met_bc ]]; then
      mkdir -p ${RUN_DIR}/${DATE}/wrfchem_met_bc
      cd ${RUN_DIR}/${DATE}/wrfchem_met_bc
   else
      cd ${RUN_DIR}/${DATE}/wrfchem_met_bc
   fi
#
# LOOP THROUGH ALL MEMBERS IN THE ENSEMBLE
   let MEM=1
   while [[ ${MEM} -le ${NUM_MEMBERS} ]]; do
      export CMEM=e${MEM}
      if [[ ${MEM} -lt 100 ]]; then export CMEM=e0${MEM}; fi
      if [[ ${MEM} -lt 10  ]]; then export CMEM=e00${MEM}; fi
      export ANALYSIS_DATE=$(${BUILD_DIR}/da_advance_time.exe ${DATE} 0 -W 2>/dev/null)
      if [[ -f wrfbdy_this ]]; then
         rm -rf wrfbdy_this
         export DA_BDY_PATH=${RUN_DIR}/${DATE}/real
         export DA_BDY_FILE=${DA_BDY_PATH}/wrfbdy_d${CR_DOMAIN}_${ANALYSIS_DATE}
         cp ${DA_BDY_FILE} wrfbdy_this
      else
         export DA_BDY_PATH=${RUN_DIR}/${DATE}/real
         export DA_BDY_FILE=${DA_BDY_PATH}/wrfbdy_d${CR_DOMAIN}_${ANALYSIS_DATE}
         cp ${DA_BDY_FILE} wrfbdy_this
      fi
      rm -rf pert_wrf_bc
      cp ${DART_DIR}/models/wrf/work/pert_wrf_bc ./.
      rm -rf input.nml
      ${DART_DIR}/models/wrf/namelist_scripts/DART/dart_create_input.nml.ksh
#
# LOOP THROUGH ALL BDY TENDENCY TIMES FOR THIS MEMBER.
      export L_DATE=${DATE}
      export L_END_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} ${FCST_PERIOD} 2>/dev/null)
      TRANDOM=$$
      while [[ ${L_DATE} -lt ${L_END_DATE} ]]; do
         export ANALYSIS_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} 0 -W 2>/dev/null)
         export NEXT_L_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} ${LBC_FREQ} 2>/dev/null)
         export NEXT_ANALYSIS_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} ${LBC_FREQ} -W 2>/dev/null)
         rm -rf wrfinput_this
         rm -rf wrfinput_next
         export DA_INPUT_PATH=${RUN_DIR}/${DATE}/wrfchem_met_ic
         ln -fs ${DA_INPUT_PATH}/wrfinput_d${CR_DOMAIN}_${ANALYSIS_DATE}.${CMEM} wrfinput_this 
         ln -fs ${DA_INPUT_PATH}/wrfinput_d${CR_DOMAIN}_${NEXT_ANALYSIS_DATE}.${CMEM} wrfinput_next 
#
#         RANDOM=$$
#         export JOBRND=${TRANDOM}_pert_bc
#         ${HYBRID_SCRIPTS_DIR}/job_script_summit.ksh ${JOBRND} ${SINGLE_JOB_CLASS} ${SINGLE_TIME_LIMIT} ${SINGLE_NODES} ${SINGLE_TASKS} pert_wrf_bc SERIAL
#         sbatch job.ksh
         export L_DATE=${NEXT_L_DATE} 
         ./pert_wrf_bc > index.html 2>&1
      done
#      ${HYBRID_SCRIPTS_DIR}/da_run_hold_cu.ksh ${TRANDOM}
      export ANALYSIS_DATE=$(${BUILD_DIR}/da_advance_time.exe ${DATE} 0 -W 2>/dev/null)

      mv wrfbdy_this wrfbdy_d${CR_DOMAIN}_${ANALYSIS_DATE}.${CMEM}
      let MEM=${MEM}+1
   done
fi
#
#########################################################################
#
# RUN PREPBUFR MET OBSERVATIONS
#
#########################################################################
#
# APM: This block needs to be revised so we can convert a single prepbufr
#      file in real time we can use only the obs that are on the current
#      prepbufr file.
#
if ${RUN_MET_OBS}; then
   if [[ ! -d ${RUN_DIR}/${DATE}/prepbufr_met_obs ]]; then
      mkdir ${RUN_DIR}/${DATE}/prepbufr_met_obs
      cd ${RUN_DIR}/${DATE}/prepbufr_met_obs
   else
      cd ${RUN_DIR}/${DATE}/prepbufr_met_obs
   fi
#
# GET PREPBUFR FILES
#           
   export L_DATE=${D_YYYY}${D_MM}${D_DD}06
   export E_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} +24 2>/dev/null)
   while [[ ${L_DATE} -le ${E_DATE} ]]; do
      export L_YYYY=$(echo $L_DATE | cut -c1-4)
      export L_YY=$(echo $L_DATE | cut -c3-4)
      export L_MM=$(echo $L_DATE | cut -c5-6)
      export L_DD=$(echo $L_DATE | cut -c7-8)
      export L_HH=$(echo $L_DATE | cut -c9-10)
      cp ${EXPERIMENT_PREPBUFR_DIR}/${L_YYYY}${L_MM}${L_DD}${L_HH}/prepbufr.gdas.${L_YYYY}${L_MM}${L_DD}${L_HH}.wo40.be prepqm${L_YY}${L_MM}${L_DD}${L_HH}
      export L_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} +6 2>/dev/null)
   done
#
# GET DART input.nml
   rm -rf input.nml
   cp ${DART_DIR}/observations/NCEP/prep_bufr/work/input.nml ./.
#
# RUN_PREPBUFR TO ASCII CONVERTER
   ${DART_DIR}/observations/NCEP/prep_bufr/work/prepbufr_RT.csh ${D_YYYY} ${DD_MM} ${DD_DD} ${DD_DD} ${DART_DIR}/observations/NCEP/prep_bufr/exe > index.file
#
# RUN ASCII TO OBS_SEQ CONVERTER
   ${HYBRID_SCRIPTS_DIR}/da_create_dart_ncep_ascii_to_obs_input_nml_RT.ksh
   ${DART_DIR}/observations/NCEP/ascii_to_obs/work/create_real_obs > index_create 2>&1
#
   mv obs_seq${D_DATE} obs_seq_prep_${DATE}.out
fi
#
#########################################################################
#
# RUN COMBINE OBSERVATIONS
#
#########################################################################
#
if ${RUN_COMBINE_OBS}; then
   if [[ ! -d ${RUN_DIR}/${DATE}/combine_obs ]]; then
      mkdir ${RUN_DIR}/${DATE}/combine_obs
      cd ${RUN_DIR}/${DATE}/combine_obs
   else
      cd ${RUN_DIR}/${DATE}/combine_obs
   fi
#
# GET EXECUTABLES
   cp ${DART_DIR}/models/wrf/work/obs_sequence_tool ./.
   export NUM_FILES=0
#
# GET OBS_SEQ FILES TO COMBINE
# MET OBS
   if [[ -s ${PREPBUFR_MET_OBS_DIR}/obs_seq_prep_${DATE}.out && ${RUN_MET_OBS} ]]; then 
      (( NUM_FILES=${NUM_FILES}+1 ))
      cp ${PREPBUFR_MET_OBS_DIR}/obs_seq_prep_${DATE}.out ./obs_seq_MET_${DATE}.out
      export FILE_LIST[${NUM_FILES}]=obs_seq_MET_${DATE}.out
   fi
   export NL_NUM_INPUT_FILES=${NUM_FILES}
#
# All files present
   if [[ ${NL_NUM_INPUT_FILES} -eq 1 ]]; then
      export NL_FILENAME_SEQ=\'${FILE_LIST[1]}\'
   elif [[ ${NL_NUM_INPUT_FILES} -eq 0 ]]; then
      echo APM: ERROR no obs_seq files for FILTER
      exit
   fi
   export NL_FILENAME_OUT="'obs_seq.proc'"
   export NL_FIRST_OBS_DAYS=${ASIM_MIN_DAY_GREG}
   export NL_FIRST_OBS_SECONDS=${ASIM_MIN_SEC_GREG}
   export NL_LAST_OBS_DAYS=${ASIM_MAX_DAY_GREG}
   export NL_LAST_OBS_SECONDS=${ASIM_MAX_SEC_GREG}
   export NL_SYNONYMOUS_COPY_LIST="'NCEP BUFR observation'"
   export NL_SYNONYMOUS_QC_LIST="'NCEP QC index'"
   rm -rf input.nml
   ${HYBRID_SCRIPTS_DIR}/da_create_dart_input_no_chem_nml.ksh
#
   ./obs_sequence_tool
   mv obs_seq.proc obs_seq_comb_${DATE}.out
fi
#
#########################################################################
#
# RUN PREPROCESS OBSERVATIONS
#
#########################################################################
#
if ${RUN_PREPROCESS_OBS}; then
   if [[ ! -d ${RUN_DIR}/${DATE}/preprocess_obs ]]; then
      mkdir ${RUN_DIR}/${DATE}/preprocess_obs
      cd ${RUN_DIR}/${DATE}/preprocess_obs
   else
      cd ${RUN_DIR}/${DATE}/preprocess_obs
   fi
#
# GET DART UTILITIES
   cp ${DART_DIR}/models/wrf/work/wrf_dart_obs_preprocess ./.
   cp ${DART_DIR}/models/wrf/WRF_DART_utilities/wrf_dart_obs_preprocess.nml ./.
   rm -rf input.nml
#   cp ${DART_DIR}/models/wrf/work/input.nml ./.
   export NL_DEFAULT_STATE_VARIABLES=.true.
   ${DART_DIR}/models/wrf/namelist_scripts/DART/dart_create_input.nml.ksh
   export NL_DEFAULT_STATE_VARIABLES=.false.
#
# GET INPUT DATA
   rm -rf obs_seq.old
   rm -rf obs_seq.new
   cp ${COMBINE_OBS_DIR}/obs_seq_comb_${DATE}.out obs_seq.old
   cp ${RUN_DIR}/${DATE}/real/wrfinput_d01_${FILE_DATE} wrfinput_d01
#
#   rm -rf job.ksh
#   touch job.ksh
#   RANDOM=$$
#   export JOBRND=${RANDOM}_preproc
#   cat << EOFF > job.ksh
##!/bin/ksh -aeux
##SBATCH --job-name ${JOBRND}
##SBATCH --qos ${GENERAL_JOB_CLASS}
##SBATCH --time ${GENERAL_TIME_LIMIT}
##SBATCH --output ${JOBRND}.log-%j.out
##SBATCH --nodes ${GENERAL_NODES}
##SBATCH --ntasks ${GENERAL_TASKS}
##SBATCH --partition shas
##
   rm -rf temp.input
   cat << EOF > temp.input
${DAY_GREG} 
${SEC_GREG}
EOF
   ./wrf_dart_obs_preprocess < temp.input > index_html 2>&1 

   rm -rf temp.input

#export RC=\$?     
#if [[ -f SUCCESS ]]; then rm -rf SUCCESS; fi     
#if [[ -f FAILED ]]; then rm -rf FAILED; fi          
#if [[ \$RC = 0 ]]; then
#   touch SUCCESS
#else
#   touch FAILED 
#   exit
#fi
#EOFF
#   sbatch -W job.ksh 
#
   mv obs_seq.new obs_seq_comb_filtered_${DATE}.out 
fi
#
#########################################################################
#
# RUN WRF-CHEM INITAL (NO CYCLING-BASED FIRST GUESS FOR DART)
#
#########################################################################
#
if ${RUN_WRFCHEM_INITIAL}; then
   if [[ ! -d ${RUN_DIR}/${DATE}/wrfchem_initial ]]; then
      mkdir -p ${RUN_DIR}/${DATE}/wrfchem_initial
      cd ${RUN_DIR}/${DATE}/wrfchem_initial
   else
      cd ${RUN_DIR}/${DATE}/wrfchem_initial
   fi
#
# Run WRF-Chem for all ensemble members
   TRANDOM=$$
   let IMEM=1
   export L_NUM_MEMBERS=${NUM_MEMBERS}
   if ${RUN_SPECIAL_FORECAST}; then
      export L_NUM_MEMBERS=${NUM_SPECIAL_FORECAST}
   fi
   while [[ ${IMEM} -le ${L_NUM_MEMBERS} ]]; do
      export MEM=${IMEM}
      export NL_TIME_STEP=${NNL_TIME_STEP}
      if ${RUN_SPECIAL_FORECAST}; then
         export MEM=${SPECIAL_FORECAST_MEM[${IMEM}]}
         let NL_TIME_STEP=${NNL_TIME_STEP}*${SPECIAL_FORECAST_FAC}
      fi
      export CMEM=e${MEM}
      export KMEM=${MEM}
      if [[ ${MEM} -lt 1000 ]]; then export KMEM=0${MEM}; fi
      if [[ ${MEM} -lt 100 ]]; then export KMEM=00${MEM}; export CMEM=e0${MEM}; fi
      if [[ ${MEM} -lt 10 ]]; then export KMEM=000${MEM}; export CMEM=e00${MEM}; fi
      export L_RUN_DIR=run_${CMEM}
      cd ${RUN_DIR}/${DATE}/wrfchem_initial
      if ${RUN_SPECIAL_FORECAST}; then
         rm -rf ${L_RUN_DIR}
      fi
      if [[ ! -e ${L_RUN_DIR} ]]; then
         mkdir ${L_RUN_DIR}
         cd ${L_RUN_DIR}
      else
         cd ${L_RUN_DIR}
      fi
#
# Get WRF-Chem parameter files
      cp ${WRF_DIR}/test/em_real/wrf.exe ./.
      cp ${WRF_DIR}/test/em_real/aerosol.formatted ./.
      cp ${WRF_DIR}/test/em_real/aerosol_lat.formatted ./.
      cp ${WRF_DIR}/test/em_real/aerosol_lon.formatted ./.
      cp ${WRF_DIR}/test/em_real/aerosol_plev.formatted ./.
      cp ${WRF_DIR}/test/em_real/bulkdens.asc_s_0_03_0_9 ./.
      cp ${WRF_DIR}/test/em_real/bulkradii.asc_s_0_03_0_9 ./.
      cp ${WRF_DIR}/test/em_real/CAM_ABS_DATA ./.
      cp ${WRF_DIR}/test/em_real/CAM_AEROPT_DATA ./.
      cp ${WRF_DIR}/test/em_real/CAMtr_volume_mixing_ratio ./.
      cp ${WRF_DIR}/test/em_real/CAMtr_volume_mixing_ratio.A1B ./.
      cp ${WRF_DIR}/test/em_real/CAMtr_volume_mixing_ratio.A2 ./.
      cp ${WRF_DIR}/test/em_real/CAMtr_volume_mixing_ratio.RCP4.5 ./.
      cp ${WRF_DIR}/test/em_real/CAMtr_volume_mixing_ratio.RCP6 ./.
      cp ${WRF_DIR}/test/em_real/capacity.asc ./.
      cp ${WRF_DIR}/test/em_real/CCN_ACTIVATE.BIN ./.
      cp ${WRF_DIR}/test/em_real/CLM_ALB_ICE_DFS_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_ALB_ICE_DRC_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_ASM_ICE_DFS_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_ASM_ICE_DRC_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_DRDSDT0_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_EXT_ICE_DFS_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_EXT_ICE_DRC_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_KAPPA_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_TAU_DATA ./.
      cp ${WRF_DIR}/test/em_real/coeff_p.asc ./.
      cp ${WRF_DIR}/test/em_real/coeff_q.asc ./.
      cp ${WRF_DIR}/test/em_real/constants.asc ./.
      cp ${WRF_DIR}/test/em_real/ETAMPNEW_DATA ./.
      cp ${WRF_DIR}/test/em_real/ETAMPNEW_DATA.expanded_rain ./.
      cp ${WRF_DIR}/test/em_real/GENPARM.TBL ./.
      cp ${WRF_DIR}/test/em_real/grib2map.tbl ./.
      cp ${WRF_DIR}/test/em_real/gribmap.txt ./.
      cp ${WRF_DIR}/test/em_real/kernels.asc_s_0_03_0_9 ./.
      cp ${WRF_DIR}/test/em_real/kernels_z.asc ./.
      cp ${WRF_DIR}/test/em_real/LANDUSE.TBL ./.
      cp ${WRF_DIR}/test/em_real/masses.asc ./.
      cp ${WRF_DIR}/test/em_real/MPTABLE.TBL ./.
      cp ${WRF_DIR}/test/em_real/ozone.formatted ./.
      cp ${WRF_DIR}/test/em_real/ozone_lat.formatted ./.
      cp ${WRF_DIR}/test/em_real/ozone_plev.formatted ./.
      cp ${WRF_DIR}/test/em_real/RRTM_DATA ./.
      cp ${WRF_DIR}/test/em_real/RRTMG_LW_DATA ./.
      cp ${WRF_DIR}/test/em_real/RRTMG_SW_DATA ./.
      cp ${WRF_DIR}/test/em_real/SOILPARM.TBL ./.
      cp ${WRF_DIR}/test/em_real/termvels.asc ./.
      cp ${WRF_DIR}/test/em_real/tr49t67 ./.
      cp ${WRF_DIR}/test/em_real/tr49t85 ./.
      cp ${WRF_DIR}/test/em_real/tr67t85 ./.
      cp ${WRF_DIR}/test/em_real/URBPARM.TBL ./.
      cp ${WRF_DIR}/test/em_real/VEGPARM.TBL ./.
#
# Get WR-Chem input and bdy files
      cp ${RUN_DIR}/${DATE}/wrfchem_met_ic/wrfinput_d${CR_DOMAIN}_${START_FILE_DATE}.${CMEM} wrfinput_d${CR_DOMAIN}
      cp ${RUN_DIR}/${DATE}/wrfchem_met_bc/wrfbdy_d${CR_DOMAIN}_${START_FILE_DATE}.${CMEM} wrfbdy_d${CR_DOMAIN}
#
# Create WRF-Chem namelist.input
      export NL_MAX_DOM=1
      rm -rf namelist.input
      ${HYBRID_SCRIPTS_DIR}/da_create_wrf_namelist_RT.ksh
#
#      export JOBRND=${TRANDOM}_wrf
#      ${HYBRID_SCRIPTS_DIR}/job_script_summit.ksh ${JOBRND} ${WRFCHEM_JOB_CLASS} ${WRFCHEM_TIME_LIMIT} ${WRFCHEM_NODES} ${WRFCHEM_TASKS} wrf.exe PARALLEL
#      sbatch job.ksh
       mpiexec -n 72 ./wrf.exe > index_wrfchem_${KMEM} 2>&1
      let IMEM=${IMEM}+1
   done
#
# Wait for WRFCHEM to complete for each member
#   ${HYBRID_SCRIPTS_DIR}/da_run_hold_cu.ksh ${TRANDOM}
fi
#
#########################################################################
#
# RUN DART_FILTER
#
#########################################################################
#
if ${RUN_DART_FILTER}; then
   if [[ ! -d ${RUN_DIR}/${DATE}/dart_filter ]]; then
      mkdir -p ${RUN_DIR}/${DATE}/dart_filter
      cd ${RUN_DIR}/${DATE}/dart_filter
   else
      cd ${RUN_DIR}/${DATE}/dart_filter
   fi
#
# Get DART files
   cp ${DART_DIR}/models/wrf/work/filter      ./.
   cp ${DART_DIR}/system_simulation/final_full_precomputed_tables/final_full.${NUM_MEMBERS} ./.
   cp ${DART_DIR}/models/wrf/work/advance_time ./.
   cp ${DART_DIR}/models/wrf/work/input.nml ./.
#
# Get background forecasts
   if [[ ${DATE} -eq ${FIRST_FILTER_DATE} ]]; then
      export BACKGND_FCST_DIR=${WRFCHEM_INITIAL_DIR}
   else
      export BACKGND_FCST_DIR=${WRFCHEM_LAST_CYCLE_CR_DIR}
   fi
#
# Get observations
   if [[ ${PREPROCESS_OBS_DIR}/obs_seq_comb_filtered_${START_DATE}.out ]]; then      
      cp  ${PREPROCESS_OBS_DIR}/obs_seq_comb_filtered_${START_DATE}.out obs_seq.out
   else
      echo APM ERROR: NO DART OBSERVATIONS
      exit
   fi
#
# Run WRF_TO_DART
   let MEM=1
   while [[ ${MEM} -le ${NUM_MEMBERS} ]]; do
      export CMEM=e${MEM}
      export KMEM=${MEM}
      if [[ ${MEM} -lt 1000 ]]; then export KMEM=0${MEM}; fi
      if [[ ${MEM} -lt 100 ]]; then export KMEM=00${MEM}; export CMEM=e0${MEM}; fi
      if [[ ${MEM} -lt 10 ]]; then export KMEM=000${MEM}; export CMEM=e00${MEM}; fi
#
      cd ${RUN_DIR}/${DATE}/dart_filter
      rm -rf wrk_wrf_${CMEM}
      mkdir wrk_wrf_${CMEM}
      cd ${RUN_DIR}/${DATE}/dart_filter/wrk_wrf_${CMEM}
#
# &wrf_to_dart_nml
      export NL_DART_RESTART_NAME="'../filter_ic_old.${KMEM}'"
      export NL_PRINT_DATA_RANGES=.false.
      ${DART_DIR}/models/wrf/namelist_scripts/DART/dart_create_input.nml.ksh
      cp ${DART_DIR}/models/wrf/work/wrf_to_dart ./.
#
      cp ${BACKGND_FCST_DIR}/run_${CMEM}/wrfout_d${CR_DOMAIN}_${FILE_DATE} wrfinput_d${CR_DOMAIN}
      cp ${BACKGND_FCST_DIR}/run_${CMEM}/wrfout_d${CR_DOMAIN}_${FILE_DATE} ../wrfinput_d${CR_DOMAIN}_${CMEM}
#
      let MEM=${MEM}+1
   done
#
# Create job script 
   TRANDOM=$$
   let MEM=1
   while [[ ${MEM} -le ${NUM_MEMBERS} ]]; do
      export CMEM=e${MEM}
      export KMEM=${MEM}
      if [[ ${MEM} -lt 1000 ]]; then export KMEM=0${MEM}; fi
      if [[ ${MEM} -lt 100 ]]; then export KMEM=00${MEM}; export CMEM=e0${MEM}; fi
      if [[ ${MEM} -lt 10 ]]; then export KMEM=000${MEM}; export CMEM=e00${MEM}; fi
      cd ${RUN_DIR}/${DATE}/dart_filter/wrk_wrf_${CMEM}
#
#      export JOBRND=${TRANDOM}_wrf2drt
#      ${HYBRID_SCRIPTS_DIR}/job_script_summit.ksh ${JOBRND} ${GENERAL_JOB_CLASS} ${GENERAL_TIME_LIMIT} ${GENERAL_NODES} ${GENERAL_TASKS} wrf_to_dart SERIAL
#      sbatch job.ksh
      ./wrf_to_dart > index_wrf_to_dart 2>&1
      let MEM=${MEM}+1
   done
#
# Wait for wrf_to_dart to complete for each member
   cd ${RUN_DIR}/${DATE}/dart_filter
#   ${HYBRID_SCRIPTS_DIR}/da_run_hold_cu.ksh ${TRANDOM}
   ${DART_DIR}/models/wrf/namelist_scripts/DART/dart_create_input.nml.ksh
#
   cp ${BACKGND_FCST_DIR}/run_e001/wrfout_d${CR_DOMAIN}_${FILE_DATE} wrfinput_d${CR_DOMAIN}
#
# Copy "out" inflation files from prior cycle to "in" inflation files for current cycle
   if ${USE_DART_INFL}; then
      if [[ ${DATE} -eq ${FIRST_DART_INFLATE_DATE} ]]; then
         export NL_INF_INITIAL_FROM_RESTART_PRIOR=.false.
         export NL_INF_SD_INITIAL_FROM_RESTART_PRIOR=.false.
         export NL_INF_INITIAL_FROM_RESTART_POST=.false.
         export NL_INF_SD_INITIAL_FROM_RESTART_POST=.false.
      else
         export NL_INF_INITIAL_FROM_RESTART_PRIOR=.true.
         export NL_INF_SD_INITIAL_FROM_RESTART_PRIOR=.true.
         export NL_INF_INITIAL_FROM_RESTART_POST=.true.
         export NL_INF_SD_INITIAL_FROM_RESTART_POST=.true.
      fi
      if [[ ${DATE} -ne ${FIRST_DART_INFLATE_DATE} ]]; then
         if [[ ${NL_INF_FLAVOR_PRIOR} != 0 ]]; then
            export INF_OUT_FILE_NAME_PRIOR=${RUN_DIR}/${PAST_DATE}/dart_filter/prior_inflate_ic_new
            cp ${INF_OUT_FILE_NAME_PRIOR} prior_inflate_ic_old
         fi
         if [[ ${NL_INF_FLAVOR_POST} != 0 ]]; then
            export INF_OUT_FILE_NAME_POST=${RUN_DIR}/${PAST_DATE}/dart_filter/post_inflate_ic_new
            cp ${NL_INF_OUT_FILE_NAME_POST} post_infalte_ic_old
         fi 
      fi
   fi
#
# Generate input.nml
   set -A temp `echo ${ASIM_MIN_DATE} 0 -g | ${DART_DIR}/models/wrf/work/advance_time`
   (( temp[1]=${temp[1]}+1 ))
   export NL_FIRST_OBS_DAYS=${temp[0]}
   export NL_FIRST_OBS_SECONDS=${temp[1]}
   set -A temp `echo ${ASIM_MAX_DATE} 0 -g | ${DART_DIR}/models/wrf/work/advance_time`
   export NL_LAST_OBS_DAYS=${temp[0]}
   export NL_LAST_OBS_SECONDS=${temp[1]}
#
   export NL_NUM_INPUT_FILES=1
   export NL_FILENAME_SEQ="'obs_seq.out'"
   export NL_FILENAME_OUT="'obs_seq.processed'"
#
   rm -rf input.nml
   ${DART_DIR}/models/wrf/namelist_scripts/DART/dart_create_input.nml.ksh
#
# Make filter_apm_nml for special_outlier_threshold
   rm -rf filter_apm.nml
   cat << EOF > filter_apm.nml
&filter_apm_nml
special_outlier_threshold=${NL_SPECIAL_OUTLIER_THRESHOLD}
/
EOF
#
# Run DART_FILTER
# Create job script for this member and run it 
#
#   RANDOM=$$
#   export JOBRND=${RANDOM}_filter
#   ${HYBRID_SCRIPTS_DIR}/job_script_summit.ksh ${JOBRND} ${FILTER_JOB_CLASS} ${FILTER_TIME_LIMIT} ${FILTER_NODES} ${FILTER_TASKS} filter PARALLEL
#   sbatch -W job.ksh
   mpiexec -n 72 ./filter > index_filter 2>&1
#
# Run DART_TO_WRF 
   TRANDOM=$$
   let MEM=1
   while [[ ${MEM} -le ${NUM_MEMBERS} ]]; do
      export CMEM=e${MEM}
      export KMEM=${MEM}
      if [[ ${MEM} -lt 1000 ]]; then export KMEM=0${MEM}; fi
      if [[ ${MEM} -lt 100 ]]; then export KMEM=00${MEM}; export CMEM=e0${MEM}; fi
      if [[ ${MEM} -lt 10 ]]; then export KMEM=000${MEM}; export CMEM=e00${MEM}; fi
#
      cd ${RUN_DIR}/${DATE}/dart_filter
      rm -rf wrk_dart_${CMEM}
      mkdir wrk_dart_${CMEM}
      cd ${RUN_DIR}/${DATE}/dart_filter/wrk_dart_${CMEM}
#
# &dart_to_wrf_nml
      export NL_MODEL_ADVANCE_FILE=.false.
      export NL_DART_RESTART_NAME=\'../filter_ic_new.${KMEM}\'
      rm -rf input.nml
      ${DART_DIR}/models/wrf/namelist_scripts/DART/dart_create_input.nml.ksh
      cp ${DART_DIR}/models/wrf/work/dart_to_wrf ./.
      cp ${BACKGND_FCST_DIR}/run_${CMEM}/wrfout_d${CR_DOMAIN}_${FILE_DATE} wrfinput_d${CR_DOMAIN}
#      export JOBRND=${TRANDOM}_drt2wrf
#      ${HYBRID_SCRIPTS_DIR}/job_script_summit.ksh ${JOBRND} ${GENERAL_JOB_CLASS} ${GENERAL_TIME_LIMIT} ${GENERAL_NODES} ${GENERAL_TASKS} dart_to_wrf SERIAL
#      sbatch job.ksh
      ./dart_to_wrf > index_dart_to_wrf 2>&1
      let MEM=${MEM}+1
   done
#
# Wait for dart_to_wrf to complete for each member
   cd ${RUN_DIR}/${DATE}/dart_filter
#   ${HYBRID_SCRIPTS_DIR}/da_run_hold_cu.ksh ${TRANDOM}
#
# Copy converted output files
   let MEM=1
   while [[ ${MEM} -le ${NUM_MEMBERS} ]]; do
      export CMEM=e${MEM}
      export KMEM=${MEM}
      if [[ ${MEM} -lt 1000 ]]; then export KMEM=0${MEM}; fi
      if [[ ${MEM} -lt 100 ]]; then export KMEM=00${MEM}; export CMEM=e0${MEM}; fi
      if [[ ${MEM} -lt 10 ]]; then export KMEM=000${MEM}; export CMEM=e00${MEM}; fi
      cp wrk_dart_${CMEM}/wrfinput_d${CR_DOMAIN} wrfout_d${CR_DOMAIN}_${FILE_DATE}_filt.${CMEM} 
      let MEM=${MEM}+1
   done
fi
#
#########################################################################
#
# UPDATE COARSE RESOLUTION BOUNDARY CONDIIONS
#
#########################################################################
#
if ${RUN_UPDATE_BC}; then
   if [[ ! -d ${RUN_DIR}/${DATE}/update_bc ]]; then
      mkdir -p ${RUN_DIR}/${DATE}/update_bc
      cd ${RUN_DIR}/${DATE}/update_bc
   else
      cd ${RUN_DIR}/${DATE}/update_bc
   fi
#
   let MEM=1
   while [[ ${MEM} -le ${NUM_MEMBERS} ]]; do
      export CMEM=e${MEM}
      export KMEM=${MEM}
      if [[ ${MEM} -lt 1000 ]]; then export KMEM=0${MEM}; fi
      if [[ ${MEM} -lt 100 ]]; then export KMEM=00${MEM}; export CMEM=e0${MEM}; fi
      if [[ ${MEM} -lt 10 ]]; then export KMEM=000${MEM}; export CMEM=e00${MEM}; fi
#
      export CYCLING=true
      export OPS_FORC_FILE=${WRFCHEM_MET_IC_DIR}/wrfinput_d${CR_DOMAIN}_${FILE_DATE}.${CMEM}
      export BDYCDN_IN=${WRFCHEM_MET_BC_DIR}/wrfbdy_d${CR_DOMAIN}_${FILE_DATE}.${CMEM}
      cp ${BDYCDN_IN} wrfbdy_d${CR_DOMAIN}_${FILE_DATE}_prior.${CMEM}
      export DA_OUTPUT_FILE=${DART_FILTER_DIR}/wrfout_d${CR_DOMAIN}_${FILE_DATE}_filt.${CMEM} 
      export BDYCDN_OUT=wrfbdy_d${CR_DOMAIN}_${FILE_DATE}_filt.${CMEM}    
      ${HYBRID_SCRIPTS_DIR}/da_run_update_bc.ksh > index_update_bc 2>&1
#
      let MEM=$MEM+1
   done
fi
#
#########################################################################
#
# RUN WRFCHEM_CYCLE_CR
#
#########################################################################
#
if ${RUN_WRFCHEM_CYCLE_CR}; then
   if [[ ! -d ${RUN_DIR}/${DATE}/wrfchem_cycle_cr ]]; then
      mkdir -p ${RUN_DIR}/${DATE}/wrfchem_cycle_cr
      cd ${RUN_DIR}/${DATE}/wrfchem_cycle_cr
   else
      cd ${RUN_DIR}/${DATE}/wrfchem_cycle_cr
   fi
#
# Run WRF-Chem for all ensemble members
   TRANDOM=$$
   let IMEM=1
   export L_NUM_MEMBERS=${NUM_MEMBERS}
   if ${RUN_SPECIAL_FORECAST}; then
      export L_NUM_MEMBERS=${NUM_SPECIAL_FORECAST}
   fi
#
# APM: Start timing
   day1=`date +%j`
   hour=`date +%H`
   minute=`date +%M`
   second=`date +%S`
   (( time1=$hour*3600+$minute*60+$second ))
   echo 'APM day:' $day1'; seconds:' $time1 
#
   while [[ ${IMEM} -le ${L_NUM_MEMBERS} ]]; do
      export MEM=${IMEM}
      export NL_TIME_STEP=${NNL_TIME_STEP}
      if ${RUN_SPECIAL_FORECAST}; then
         export MEM=${SPECIAL_FORECAST_MEM[${IMEM}]}
         let NL_TIME_STEP=${NNL_TIME_STEP}*${SPECIAL_FORECAST_FAC}
      fi
      export CMEM=e${MEM}
      export KMEM=${MEM}
      if [[ ${MEM} -lt 1000 ]]; then export KMEM=0${MEM}; fi
      if [[ ${MEM} -lt 100 ]]; then export KMEM=00${MEM}; export CMEM=e0${MEM}; fi
      if [[ ${MEM} -lt 10 ]]; then export KMEM=000${MEM}; export CMEM=e00${MEM}; fi
      export L_RUN_DIR=run_${CMEM}
      cd ${RUN_DIR}/${DATE}/wrfchem_cycle_cr
      if ${RUN_SPECIAL_FORECAST}; then
         rm -rf ${L_RUN_DIR}
      fi
      if [[ ! -e ${L_RUN_DIR} ]]; then
         mkdir ${L_RUN_DIR}
         cd ${L_RUN_DIR}
      else
         cd ${L_RUN_DIR}
      fi
#
# Get WRF-Chem parameter files
      cp ${DART_DIR}/models/wrf/work/advance_time ./.
      cp ${DART_DIR}/models/wrf/work/input.nml ./.
      cp ${WRF_DIR}/test/em_real/wrf.exe ./.
      cp ${WRF_DIR}/test/em_real/aerosol.formatted ./.
      cp ${WRF_DIR}/test/em_real/aerosol_lat.formatted ./.
      cp ${WRF_DIR}/test/em_real/aerosol_lon.formatted ./.
      cp ${WRF_DIR}/test/em_real/aerosol_plev.formatted ./.
      cp ${WRF_DIR}/test/em_real/bulkdens.asc_s_0_03_0_9 ./.
      cp ${WRF_DIR}/test/em_real/bulkradii.asc_s_0_03_0_9 ./.
      cp ${WRF_DIR}/test/em_real/CAM_ABS_DATA ./.
      cp ${WRF_DIR}/test/em_real/CAM_AEROPT_DATA ./.
      cp ${WRF_DIR}/test/em_real/CAMtr_volume_mixing_ratio ./.
      cp ${WRF_DIR}/test/em_real/CAMtr_volume_mixing_ratio.A1B ./.
      cp ${WRF_DIR}/test/em_real/CAMtr_volume_mixing_ratio.A2 ./.
      cp ${WRF_DIR}/test/em_real/CAMtr_volume_mixing_ratio.RCP4.5 ./.
      cp ${WRF_DIR}/test/em_real/CAMtr_volume_mixing_ratio.RCP6 ./.
      cp ${WRF_DIR}/test/em_real/capacity.asc ./.
      cp ${WRF_DIR}/test/em_real/CCN_ACTIVATE.BIN ./.
      cp ${WRF_DIR}/test/em_real/CLM_ALB_ICE_DFS_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_ALB_ICE_DRC_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_ASM_ICE_DFS_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_ASM_ICE_DRC_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_DRDSDT0_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_EXT_ICE_DFS_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_EXT_ICE_DRC_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_KAPPA_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_TAU_DATA ./.
      cp ${WRF_DIR}/test/em_real/coeff_p.asc ./.
      cp ${WRF_DIR}/test/em_real/coeff_q.asc ./.
      cp ${WRF_DIR}/test/em_real/constants.asc ./.
      cp ${WRF_DIR}/test/em_real/ETAMPNEW_DATA ./.
      cp ${WRF_DIR}/test/em_real/ETAMPNEW_DATA.expanded_rain ./.
      cp ${WRF_DIR}/test/em_real/GENPARM.TBL ./.
      cp ${WRF_DIR}/test/em_real/grib2map.tbl ./.
      cp ${WRF_DIR}/test/em_real/gribmap.txt ./.
      cp ${WRF_DIR}/test/em_real/kernels.asc_s_0_03_0_9 ./.
      cp ${WRF_DIR}/test/em_real/kernels_z.asc ./.
      cp ${WRF_DIR}/test/em_real/LANDUSE.TBL ./.
      cp ${WRF_DIR}/test/em_real/masses.asc ./.
      cp ${WRF_DIR}/test/em_real/MPTABLE.TBL ./.
      cp ${WRF_DIR}/test/em_real/ozone.formatted ./.
      cp ${WRF_DIR}/test/em_real/ozone_lat.formatted ./.
      cp ${WRF_DIR}/test/em_real/ozone_plev.formatted ./.
      cp ${WRF_DIR}/test/em_real/RRTM_DATA ./.
      cp ${WRF_DIR}/test/em_real/RRTMG_LW_DATA ./.
      cp ${WRF_DIR}/test/em_real/RRTMG_SW_DATA ./.
      cp ${WRF_DIR}/test/em_real/SOILPARM.TBL ./.
      cp ${WRF_DIR}/test/em_real/termvels.asc ./.
      cp ${WRF_DIR}/test/em_real/tr49t67 ./.
      cp ${WRF_DIR}/test/em_real/tr49t85 ./.
      cp ${WRF_DIR}/test/em_real/tr67t85 ./.
      cp ${WRF_DIR}/test/em_real/URBPARM.TBL ./.
      cp ${WRF_DIR}/test/em_real/VEGPARM.TBL ./.
#
# Get WR-Chem input and bdy files
      cp ${DART_FILTER_DIR}/wrfout_d${CR_DOMAIN}_${START_FILE_DATE}_filt.${CMEM} wrfinput_d${CR_DOMAIN}
      cp ${UPDATE_BC_DIR}/wrfbdy_d${CR_DOMAIN}_${START_FILE_DATE}_filt.${CMEM} wrfbdy_d${CR_DOMAIN}
#
# Create WRF-Chem namelist.input 
      export NL_MAX_DOM=1
      export NL_IOFIELDS_FILENAME=' ',' '
      rm -rf namelist.input
      ${HYBRID_SCRIPTS_DIR}/da_create_wrf_namelist_RT.ksh
#
#      export JOBRND=${TRANDOM}_wrf
#      ${HYBRID_SCRIPTS_DIR}/job_script_summit.ksh ${JOBRND} ${WRFCHEM_JOB_CLASS} ${WRFCHEM_TIME_LIMIT} ${WRFCHEM_NODES} ${WRFCHEM_TASKS} wrf.exe PARALLEL
#      sbatch job.ksh
#
      mpiexec -n 9 ./wrf.exe > index_wrfchem_${KMEM} 2>&1 
      let IMEM=${IMEM}+1
   done
#
# APM: End timing
   day2=`date +%j`
   hour=`date +%H`
   minute=`date +%M`
   second=`date +%S`
   (( time2=$hour*3600+$minute*60+$second ))
   echo 'APM day:' $day2'; seconds:' $time1 
#
   (( time3=($day2-$day1)*24*3600+$time2-$time1 ))
   (( time4=$time3/60 ))
   echo 'APM elapsed time (secs/hrs):' $time3 / $time4
#
# Wait for WRFCHEM to complete for each member
#   ${HYBRID_SCRIPTS_DIR}/da_run_hold_cu.ksh ${TRANDOM}
fi
#
#########################################################################
#
# FIND DEEPEST MEMBER
#
#########################################################################
#
if ${RUN_BAND_DEPTH}; then
   if [[ ! -d ${RUN_DIR}/${DATE}/band_depth ]]; then
      mkdir -p ${RUN_DIR}/${DATE}/band_depth
      cd ${RUN_DIR}/${DATE}/band_depth
   else
      cd ${RUN_DIR}/${DATE}/band_depth
   fi
#
# set the forecast directory
   if [[ ${DATE} -eq ${INITIAL_DATE} ]]; then
      export OUTPUT_DIR=${WRFCHEM_INITIAL_DIR}
   else
      export OUTPUT_DIR=${WRFCHEM_CYCLE_CR_DIR}
   fi
   cp ${DART_DIR}/models/wrf/work/advance_time ./.
   export END_CYCLE_DATE=$($BUILD_DIR/da_advance_time.exe ${START_DATE} ${CYCLE_PERIOD} 2>/dev/null)
   export B_YYYY=$(echo $END_CYCLE_DATE | cut -c1-4)
   export B_MM=$(echo $END_CYCLE_DATE | cut -c5-6) 
   export B_DD=$(echo $END_CYCLE_DATE | cut -c7-8)
   export B_HH=$(echo $END_CYCLE_DATE | cut -c9-10)
   export B_FILE_DATE=${B_YYYY}-${B_MM}-${B_DD}_${B_HH}:00:00
#
# link in forecasts for deepest member determination
   let MEM=1
   while [[ ${MEM} -le ${NUM_MEMBERS} ]]; do
      export CMEM=e${MEM}
      export KMEM=${MEM}
      if [[ ${MEM} -lt 1000 ]]; then export KMEM=0${MEM}; fi
      if [[ ${MEM} -lt 100 ]]; then export KMEM=00${MEM}; export CMEM=e0${MEM}; fi
      if [[ ${MEM} -lt 10 ]]; then export KMEM=000${MEM}; export CMEM=e00${MEM}; fi
      rm -rf wrfout_d${CR_DOMAIN}.${CMEM}
      ln -sf ${OUTPUT_DIR}/run_${CMEM}/wrfout_d${CR_DOMAIN}_${B_FILE_DATE}.${CMEM} wrfout_d${CR_DOMAIN}.${CMEM}
      let MEM=${MEM}+1
   done
#
# copy band depth code
   cp ${RUN_BAND_DEPTH_DIR}/ComputeBandDepth.m ./.
   rm -rf job.ksh
   rm -rf mat_*.err
   rm -rf mat_*.out
   touch job.ksh
#
   RANDOM=$$
   export JOBRND=${RANDOM}_deepmem
   cat << EOFF > job.ksh
#!/bin/ksh -aeux
#SBATCH --job-name ${JOBRND}
#SBATCH --qos ${GENERAL_JOB_CLASS}
#SBATCH --time ${GENERAL_TIME_LIMIT}
#SBATCH --output ${JOBRND}.log-%j.out
#SBATCH --nodes ${GENERAL_NODES}
#SBATCH --ntasks ${GENERAL_TASKS}
#SBATCH --partition shas
. /etc/profile.d/lmod.sh
module load matlab
#
matlab -nosplash -nodesktop -r 'ComputeBandDepth(.09)'
export RC=\$?     
if [[ -f SUCCESS ]]; then rm -rf SUCCESS; fi     
if [[ -f FAILED ]]; then rm -rf FAILED; fi          
if [[ \$RC = 0 ]]; then
   touch SUCCESS
else
   touch FAILED 
   exit
fi
EOFF
   sbatch -W job.ksh 
#
# run band depth script
   source shell_file.ksh
   export CMEM=e${DEEP_MEMBER}
   if [[ ${DEEP_MEMBER} -lt 100 ]]; then export CMEM=e0${DEEP_MEMBER}; fi
   if [[ ${DEEP_MEMBER} -lt 10 ]]; then export CMEM=e00${DEEP_MEMBER}; fi
   export CLOSE_MEM_ID=${CMEM}
fi
#
#########################################################################
#
# CALCULATE ENSEMBLE MEAN_INPUT
#
#########################################################################
#
if ${RUN_ENSEMBLE_MEAN_INPUT}; then
   if [[ ! -d ${RUN_DIR}/${DATE}/ensemble_mean_input ]]; then
      mkdir -p ${RUN_DIR}/${DATE}/ensemble_mean_input
      cd ${RUN_DIR}/${DATE}/ensemble_mean_input
   else
      cd ${RUN_DIR}/${DATE}/ensemble_mean_input
   fi
   rm -rf wrfinput_d${CR_DOMAIN}_mean
   rm -rf wrfbdy_d${CR_DOMAIN}_mean
   rm -rf wrfinput_d${FR_DOMAIN}_mean
   rm -rf wrfinput_d${VF_DOMAIN}_mean
   let MEM=1
   while [[ ${MEM} -le ${NUM_MEMBERS} ]]; do
      export CMEM=e${MEM}
      export KMEM=${MEM}
      if [[ ${MEM} -lt 1000 ]]; then export KMEM=0${MEM}; fi
      if [[ ${MEM} -lt 100 ]]; then export KMEM=00${MEM}; export CMEM=e0${MEM}; fi
      if [[ ${MEM} -lt 10 ]]; then export KMEM=000${MEM}; export CMEM=e00${MEM}; fi
      cp ${DART_FILTER_DIR}/wrfout_d${CR_DOMAIN}_${START_FILE_DATE}_filt.${CMEM} wrfinput_d${CR_DOMAIN}_${KMEM}
      cp ${UPDATE_BC_DIR}/wrfbdy_d${CR_DOMAIN}_${START_FILE_DATE}_filt.${CMEM} wrfbdy_d${CR_DOMAIN}_${KMEM}
      let MEM=${MEM}+1
   done
   cp ${REAL_DIR}/wrfinput_d${FR_DOMAIN}_${START_FILE_DATE} wrfinput_d${FR_DOMAIN}_mean
   cp ${REAL_DIR}/wrfinput_d${VF_DOMAIN}_${START_FILE_DATE} wrfinput_d${VF_DOMAIN}_mean
#
# Calculate ensemble mean
   ncea -n ${NUM_MEMBERS},4,1 wrfinput_d${CR_DOMAIN}_0001 wrfinput_d${CR_DOMAIN}_mean
   ncea -n ${NUM_MEMBERS},4,1 wrfbdy_d${CR_DOMAIN}_0001 wrfbdy_d${CR_DOMAIN}_mean
   rm -rf wrfinput_d${CR_DOMAIN}_*0*
   rm -rf wrfbdy_d${CR_DOMAIN}_*0*
fi
#
#########################################################################
#
# RUN WRFCHEM_CYCLE_FR
#
#########################################################################
#
if ${RUN_WRFCHEM_CYCLE_FR}; then
   if [[ ! -d ${RUN_DIR}/${DATE}/wrfchem_cycle_fr ]]; then
      mkdir -p ${RUN_DIR}/${DATE}/wrfchem_cycle_fr
      cd ${RUN_DIR}/${DATE}/wrfchem_cycle_fr
   else
      cd ${RUN_DIR}/${DATE}/wrfchem_cycle_fr
   fi
#
# Get WRF-Chem parameter files
   cp ${WRF_DIR}/test/em_real/wrf.exe ./.
   cp ${WRF_DIR}/test/em_real/CAM_ABS_DATA ./.
   cp ${WRF_DIR}/test/em_real/CAM_AEROPT_DATA ./.
   cp ${WRF_DIR}/test/em_real/ETAMPNEW_DATA ./.
   cp ${WRF_DIR}/test/em_real/GENPARM.TBL ./.
   cp ${WRF_DIR}/test/em_real/LANDUSE.TBL ./.
   cp ${WRF_DIR}/test/em_real/RRTMG_LW_DATA ./.
   cp ${WRF_DIR}/test/em_real/RRTMG_SW_DATA ./.
   cp ${WRF_DIR}/test/em_real/RRTM_DATA ./.
   cp ${WRF_DIR}/test/em_real/SOILPARM.TBL ./.
   cp ${WRF_DIR}/test/em_real/URBPARM.TBL ./.
   cp ${WRF_DIR}/test/em_real/VEGPARM.TBL ./.
#
# Get WRF-Chem input and bdy files
#
#   cp ${REAL_DIR}/wrfout_d${CR_DOMAIN}_${START_FILE_DATE}_filt wrfinput_d${CR_DOMAIN}
#   cp ${REAL_DIR}/wrfbdy_d${CR_DOMAIN}_${START_FILE_DATE}_filt wrfbdy_d${CR_DOMAIN}
#   cp ${REAL_DIR}/wrfout_d${FR_DOMAIN}_${START_FILE_DATE}_filt wrfinput_d${FR_DOMAIN}
# 
##   cp ${WRFCHEM_CHEM_ICBC_DIR}/wrfinput_d${CR_DOMAIN}_${START_FILE_DATE} wrfinput_d${CR_DOMAIN}
##   cp ${WRFCHEM_CHEM_ICBC_DIR}/wrfbdy_d${CR_DOMAIN}_${START_FILE_DATE} wrfbdy_d${CR_DOMAIN}
##   cp ${WRFCHEM_CHEM_ICBC_DIR}/wrfinput_d${FR_DOMAIN}_${START_FILE_DATE} wrfinput_d${FR_DOMAIN}
#
# files for starting from closest member
   cp ${DART_FILTER_DIR}/wrfout_d${CR_DOMAIN}_${START_FILE_DATE}_filt.${CLOSE_MEM_ID} wrfinput_d${CR_DOMAIN}
   cp ${UPDATE_BC_DIR}/wrfbdy_d${CR_DOMAIN}_${START_FILE_DATE}_filt.${CLOSE_MEM_ID} wrfbdy_d${CR_DOMAIN}
   cp ${REAL_DIR}/wrfinput_d${FR_DOMAIN}_${START_FILE_DATE} wrfinput_d${FR_DOMAIN}
#
# Create WRF-Chem namelist.input 
   export NL_MAX_DOM=2
   rm -rf namelist.input
   ${HYBRID_SCRIPTS_DIR}/da_create_wrf_namelist_nested_RT.ksh
#
#   RANDOM=$$
#   export JOBRND=${RANDOM}_wrf
#   ${HYBRID_SCRIPTS_DIR}/job_script_summit.ksh ${JOBRND} ${WRFCHEM_JOB_CLASS} ${WRFCHEM_TIME_LIMIT} ${WRFCHEM_NODES} ${WRFCHEM_TASKS} wrf.exe PARALLEL
#   sbatch -W job.ksh
    mpiexec -n 72 ./wrf.exe > index_wrfchem 2>&1
#
fi
#
#########################################################################
#
# RUN ENSMEAN_CYCLE_FR
#
#########################################################################
#
if ${RUN_ENSMEAN_CYCLE_FR}; then
   if [[ ! -d ${RUN_DIR}/${DATE}/ensmean_cycle_fr ]]; then
      mkdir -p ${RUN_DIR}/${DATE}/ensmean_cycle_fr
      cd ${RUN_DIR}/${DATE}/ensmean_cycle_fr
   else
      cd ${RUN_DIR}/${DATE}/ensmean_cycle_fr
   fi
#
# Get WRF-Chem parameter files
   if [[ ${RUN_FINE_SCALE_RESTART} = "false" ]]; then
      cp ${WRF_DIR}/test/em_real/wrf.exe ./.
      cp ${WRF_DIR}/test/em_real/aerosol.formatted ./.
      cp ${WRF_DIR}/test/em_real/aerosol_lat.formatted ./.
      cp ${WRF_DIR}/test/em_real/aerosol_lon.formatted ./.
      cp ${WRF_DIR}/test/em_real/aerosol_plev.formatted ./.
      cp ${WRF_DIR}/test/em_real/bulkdens.asc_s_0_03_0_9 ./.
      cp ${WRF_DIR}/test/em_real/bulkradii.asc_s_0_03_0_9 ./.
      cp ${WRF_DIR}/test/em_real/CAM_ABS_DATA ./.
      cp ${WRF_DIR}/test/em_real/CAM_AEROPT_DATA ./.
      cp ${WRF_DIR}/test/em_real/CAMtr_volume_mixing_ratio ./.
      cp ${WRF_DIR}/test/em_real/CAMtr_volume_mixing_ratio.A1B ./.
      cp ${WRF_DIR}/test/em_real/CAMtr_volume_mixing_ratio.A2 ./.
      cp ${WRF_DIR}/test/em_real/CAMtr_volume_mixing_ratio.RCP4.5 ./.
      cp ${WRF_DIR}/test/em_real/CAMtr_volume_mixing_ratio.RCP6 ./.
      cp ${WRF_DIR}/test/em_real/capacity.asc ./.
      cp ${WRF_DIR}/test/em_real/CCN_ACTIVATE.BIN ./.
      cp ${WRF_DIR}/test/em_real/CLM_ALB_ICE_DFS_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_ALB_ICE_DRC_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_ASM_ICE_DFS_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_ASM_ICE_DRC_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_DRDSDT0_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_EXT_ICE_DFS_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_EXT_ICE_DRC_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_KAPPA_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_TAU_DATA ./.
      cp ${WRF_DIR}/test/em_real/coeff_p.asc ./.
      cp ${WRF_DIR}/test/em_real/coeff_q.asc ./.
      cp ${WRF_DIR}/test/em_real/constants.asc ./.
      cp ${WRF_DIR}/test/em_real/ETAMPNEW_DATA ./.
      cp ${WRF_DIR}/test/em_real/ETAMPNEW_DATA.expanded_rain ./.
      cp ${WRF_DIR}/test/em_real/GENPARM.TBL ./.
      cp ${WRF_DIR}/test/em_real/grib2map.tbl ./.
      cp ${WRF_DIR}/test/em_real/gribmap.txt ./.
      cp ${WRF_DIR}/test/em_real/kernels.asc_s_0_03_0_9 ./.
      cp ${WRF_DIR}/test/em_real/kernels_z.asc ./.
      cp ${WRF_DIR}/test/em_real/LANDUSE.TBL ./.
      cp ${WRF_DIR}/test/em_real/masses.asc ./.
      cp ${WRF_DIR}/test/em_real/MPTABLE.TBL ./.
      cp ${WRF_DIR}/test/em_real/ozone.formatted ./.
      cp ${WRF_DIR}/test/em_real/ozone_lat.formatted ./.
      cp ${WRF_DIR}/test/em_real/ozone_plev.formatted ./.
      cp ${WRF_DIR}/test/em_real/RRTM_DATA ./.
      cp ${WRF_DIR}/test/em_real/RRTMG_LW_DATA ./.
      cp ${WRF_DIR}/test/em_real/RRTMG_SW_DATA ./.
      cp ${WRF_DIR}/test/em_real/SOILPARM.TBL ./.
      cp ${WRF_DIR}/test/em_real/termvels.asc ./.
      cp ${WRF_DIR}/test/em_real/tr49t67 ./.
      cp ${WRF_DIR}/test/em_real/tr49t85 ./.
      cp ${WRF_DIR}/test/em_real/tr67t85 ./.
      cp ${WRF_DIR}/test/em_real/URBPARM.TBL ./.
      cp ${WRF_DIR}/test/em_real/VEGPARM.TBL ./.
#
# Get WR-Chem input and bdy files
#      cp ${REAL_DIR}/wrfout_d${CR_DOMAIN}_${START_FILE_DATE}_filt wrfinput_d${CR_DOMAIN}
#      cp ${REAL_DIR}/wrfbdy_d${CR_DOMAIN}_${START_FILE_DATE}_filt wrfbdy_d${CR_DOMAIN}
#      cp ${REAL_DIR}/wrfout_d${FR_DOMAIN}_${START_FILE_DATE}_filt wrfinput_d${FR_DOMAIN}
#      cp ${DART_FILTER_DIR}/wrfout_d${CR_DOMAIN}_${START_FILE_DATE}_filt.${CLOSE_MEM_ID} wrfinput_d${CR_DOMAIN}
#      cp ${UPDATE_BC_DIR}/wrfbdy_d${CR_DOMAIN}_${START_FILE_DATE}_filt.${CLOSE_MEM_ID} wrfbdy_d${CR_DOMAIN}
#      cp ${REAL_DIR}/wrfinput_d${FR_DOMAIN}_${START_FILE_DATE} wrfinput_d${FR_DOMAIN}
      cp ${ENSEMBLE_MEAN_INPUT_DIR}/wrfinput_d${CR_DOMAIN}_mean wrfinput_d${CR_DOMAIN}
      cp ${ENSEMBLE_MEAN_INPUT_DIR}/wrfbdy_d${CR_DOMAIN}_mean wrfbdy_d${CR_DOMAIN}
      cp ${ENSEMBLE_MEAN_INPUT_DIR}/wrfinput_d${FR_DOMAIN}_mean wrfinput_d${FR_DOMAIN}
   fi
#
# Create WRF-Chem namelist.input 
   export NL_MAX_DOM=2
   export NL_RESTART_INTERVAL=360
   export NL_TIME_STEP=10
   export L_TIME_LIMIT=${WRFCHEM_TIME_LIMIT}
   if [[ ${RUN_FINE_SCALE_RESTART} = "true" ]]; then
      export RE_YYYY=$(echo $RESTART_DATE | cut -c1-4)
      export RE_YY=$(echo $RESTART_DATE | cut -c3-4)
      export RE_MM=$(echo $RESTART_DATE | cut -c5-6)
      export RE_DD=$(echo $RESTART_DATE | cut -c7-8)
      export RE_HH=$(echo $RESTART_DATE | cut -c9-10)
      export NL_START_YEAR=${RE_YYYY},${RE_YYYY}
      export NL_START_MONTH=${RE_MM},${RE_MM}
      export NL_START_DAY=${RE_DD},${RE_DD}
      export NL_START_HOUR=${RE_HH},${RE_HH}
      export NL_START_MINUTE=00,00
      export NL_START_SECOND=00,00
      export NL_RESTART=".true."
      export L_TIME_LIMIT=${WRFCHEM_TIME_LIMIT}
   fi
   rm -rf namelist.input
   ${HYBRID_SCRIPTS_DIR}/da_create_wrf_namelist_nested_RT.ksh
#
#   RANDOM=$$
#   export JOBRND=${RANDOM}_wrf
#   ${HYBRID_SCRIPTS_DIR}/job_script_summit.ksh ${JOBRND} ${WRFCHEM_JOB_CLASS} ${WRFCHEM_TIME_LIMIT} ${WRFCHEM_NODES} ${WRFCHEM_TASKS} wrf.exe PARALLEL
#   sbatch -W job.ksh
    mpiexec -n 72 ./wrf.exe > index_wrfchem 2>&1
fi
#
#########################################################################
#
# RUN ENSMEAN_CYCLE_VF
#
#########################################################################
#
if ${RUN_ENSMEAN_CYCLE_VF}; then
   if [[ ! -d ${RUN_DIR}/${DATE}/ensmean_cycle_vf ]]; then
      mkdir -p ${RUN_DIR}/${DATE}/ensmean_cycle_vf
      cd ${RUN_DIR}/${DATE}/ensmean_cycle_vf
   else
      cd ${RUN_DIR}/${DATE}/ensmean_cycle_vf
   fi
#
# Get WRF-Chem parameter files
   if [[ ${RUN_FINE_SCALE_RESTART} = "false" ]]; then
      cp ${WRF_DIR}/test/em_real/wrf.exe ./.
      cp ${WRF_DIR}/test/em_real/aerosol.formatted ./.
      cp ${WRF_DIR}/test/em_real/aerosol_lat.formatted ./.
      cp ${WRF_DIR}/test/em_real/aerosol_lon.formatted ./.
      cp ${WRF_DIR}/test/em_real/aerosol_plev.formatted ./.
      cp ${WRF_DIR}/test/em_real/bulkdens.asc_s_0_03_0_9 ./.
      cp ${WRF_DIR}/test/em_real/bulkradii.asc_s_0_03_0_9 ./.
      cp ${WRF_DIR}/test/em_real/CAM_ABS_DATA ./.
      cp ${WRF_DIR}/test/em_real/CAM_AEROPT_DATA ./.
      cp ${WRF_DIR}/test/em_real/CAMtr_volume_mixing_ratio ./.
      cp ${WRF_DIR}/test/em_real/CAMtr_volume_mixing_ratio.A1B ./.
      cp ${WRF_DIR}/test/em_real/CAMtr_volume_mixing_ratio.A2 ./.
      cp ${WRF_DIR}/test/em_real/CAMtr_volume_mixing_ratio.RCP4.5 ./.
      cp ${WRF_DIR}/test/em_real/CAMtr_volume_mixing_ratio.RCP6 ./.
      cp ${WRF_DIR}/test/em_real/capacity.asc ./.
      cp ${WRF_DIR}/test/em_real/CCN_ACTIVATE.BIN ./.
      cp ${WRF_DIR}/test/em_real/CLM_ALB_ICE_DFS_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_ALB_ICE_DRC_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_ASM_ICE_DFS_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_ASM_ICE_DRC_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_DRDSDT0_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_EXT_ICE_DFS_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_EXT_ICE_DRC_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_KAPPA_DATA ./.
      cp ${WRF_DIR}/test/em_real/CLM_TAU_DATA ./.
      cp ${WRF_DIR}/test/em_real/coeff_p.asc ./.
      cp ${WRF_DIR}/test/em_real/coeff_q.asc ./.
      cp ${WRF_DIR}/test/em_real/constants.asc ./.
      cp ${WRF_DIR}/test/em_real/ETAMPNEW_DATA ./.
      cp ${WRF_DIR}/test/em_real/ETAMPNEW_DATA.expanded_rain ./.
      cp ${WRF_DIR}/test/em_real/GENPARM.TBL ./.
      cp ${WRF_DIR}/test/em_real/grib2map.tbl ./.
      cp ${WRF_DIR}/test/em_real/gribmap.txt ./.
      cp ${WRF_DIR}/test/em_real/kernels.asc_s_0_03_0_9 ./.
      cp ${WRF_DIR}/test/em_real/kernels_z.asc ./.
      cp ${WRF_DIR}/test/em_real/LANDUSE.TBL ./.
      cp ${WRF_DIR}/test/em_real/masses.asc ./.
      cp ${WRF_DIR}/test/em_real/MPTABLE.TBL ./.
      cp ${WRF_DIR}/test/em_real/ozone.formatted ./.
      cp ${WRF_DIR}/test/em_real/ozone_lat.formatted ./.
      cp ${WRF_DIR}/test/em_real/ozone_plev.formatted ./.
      cp ${WRF_DIR}/test/em_real/RRTM_DATA ./.
      cp ${WRF_DIR}/test/em_real/RRTMG_LW_DATA ./.
      cp ${WRF_DIR}/test/em_real/RRTMG_SW_DATA ./.
      cp ${WRF_DIR}/test/em_real/SOILPARM.TBL ./.
      cp ${WRF_DIR}/test/em_real/termvels.asc ./.
      cp ${WRF_DIR}/test/em_real/tr49t67 ./.
      cp ${WRF_DIR}/test/em_real/tr49t85 ./.
      cp ${WRF_DIR}/test/em_real/tr67t85 ./.
      cp ${WRF_DIR}/test/em_real/URBPARM.TBL ./.
      cp ${WRF_DIR}/test/em_real/VEGPARM.TBL ./.
#
# Get WR-Chem input and bdy files
#      cp ${REAL_DIR}/wrfout_d${CR_DOMAIN}_${START_FILE_DATE}_filt wrfinput_d${CR_DOMAIN}
#      cp ${REAL_DIR}/wrfbdy_d${CR_DOMAIN}_${START_FILE_DATE}_filt wrfbdy_d${CR_DOMAIN}
#      cp ${REAL_DIR}/wrfout_d${FR_DOMAIN}_${START_FILE_DATE}_filt wrfinput_d${FR_DOMAIN}
#      cp ${REAL_DIR}/wrfout_d${VF_DOMAIN}_${START_FILE_DATE}_filt wrfinput_d${VF_DOMAIN}
#      cp ${DART_FILTER_DIR}/wrfout_d${CR_DOMAIN}_${START_FILE_DATE}_filt.${CLOSE_MEM_ID} wrfinput_d${CR_DOMAIN}
#      cp ${UPDATE_BC_DIR}/wrfbdy_d${CR_DOMAIN}_${START_FILE_DATE}_filt.${CLOSE_MEM_ID} wrfbdy_d${CR_DOMAIN}
#      cp ${REAL_DIR}/wrfinput_d${FR_DOMAIN}_${START_FILE_DATE} wrfinput_d${FR_DOMAIN}
#      cp ${REAL_DIR}/wrfinput_d${VF_DOMAIN}_${START_FILE_DATE} wrfinput_d${VF_DOMAIN}
      cp ${ENSEMBLE_MEAN_INPUT_DIR}/wrfinput_d${CR_DOMAIN}_mean wrfinput_d${CR_DOMAIN}
      cp ${ENSEMBLE_MEAN_INPUT_DIR}/wrfbdy_d${CR_DOMAIN}_mean wrfbdy_d${CR_DOMAIN}
      cp ${ENSEMBLE_MEAN_INPUT_DIR}/wrfinput_d${FR_DOMAIN}_mean wrfinput_d${FR_DOMAIN}
      cp ${ENSEMBLE_MEAN_INPUT_DIR}/wrfinput_d${VF_DOMAIN}_mean wrfinput_d${VF_DOMAIN}
   fi
#
# Create WRF-Chem namelist.input
#
# Create WRF-Chem namelist.input
   export NL_MAX_DOM=3
   export NL_RESTART_INTERVAL=360
   export NL_TIME_STEP=${NNL_TIME_STEP}
   export NL_TIME_STEP=9
   export NL_START_YEAR=${START_YEAR},${START_YEAR},${START_YEAR}
   export NL_START_MONTH=${START_MONTH},${START_MONTH},${START_MONTH}
   export NL_START_DAY=${START_DAY},${START_DAY},${START_DAY}
   export NL_START_HOUR=${START_HOUR},${START_HOUR},${START_HOUR}
   export NL_START_MINUTE=00,00,00
   export NL_START_SECOND=00,00,00
   export NL_END_YEAR=${END_YEAR},${END_YEAR},${END_YEAR}
   export NL_END_MONTH=${END_MONTH},${END_MONTH},${END_MONTH}
   export NL_END_DAY=${END_DAY},${END_DAY},${END_DAY}
   export NL_END_HOUR=${END_HOUR},${END_HOUR},${END_HOUR}
   export NL_END_MINUTE=00,00,00
   export NL_END_SECOND=00,00,00
   export NL_IOFIELDS_FILENAME=' ',' ',' '
   if [[ ${RUN_FINE_SCALE_RESTART} = "true" ]]; then
      export RE_YYYY=$(echo $RESTART_DATE | cut -c1-4)
      export RE_YY=$(echo $RESTART_DATE | cut -c3-4)
      export RE_MM=$(echo $RESTART_DATE | cut -c5-6)
      export RE_DD=$(echo $RESTART_DATE | cut -c7-8)
      export RE_HH=$(echo $RESTART_DATE | cut -c9-10)
      export NL_START_YEAR=${RE_YYYY},${RE_YYYY},${RE_YYYY}
      export NL_START_MONTH=${RE_MM},${RE_MM},${RE_MM}
      export NL_START_DAY=${RE_DD},${RE_DD},${RE_DD}
      export NL_START_HOUR=${RE_HH},${RE_HH},${RE_HH}
      export NL_START_MINUTE=00,00,00
      export NL_START_SECOND=00,00,00
      export NL_RESTART=".true."
      export L_TIME_LIMIT=${WRFCHEM_TIME_LIMIT}
   fi
   rm -rf namelist.input
   ${HYBRID_SCRIPTS_DIR}/da_create_wrf_namelist_nested_RT.ksh
#
#   RANDOM=$$
#   export JOBRND=${RANDOM}_wrf
#   ${HYBRID_SCRIPTS_DIR}/job_script_summit.ksh ${JOBRND} ${WRFCHEM_JOB_CLASS} ${WRFCHEM_TIME_LIMIT} ${WRFCHEM_NODES} ${WRFCHEM_TASKS} wrf.exe PARALLEL
#   sbatch -W job.ksh
    mpiexec -n 72 ./wrf.exe > index_wrfchem 2>&1
fi
#
#########################################################################
#
# CALCULATE ENSEMBLE MEAN_OUTPUT
#
#########################################################################
#
if ${RUN_ENSEMBLE_MEAN_OUTPUT}; then
   if [[ ! -d ${RUN_DIR}/${DATE}/ensemble_mean_output ]]; then
      mkdir -p ${RUN_DIR}/${DATE}/ensemble_mean_output
      cd ${RUN_DIR}/${DATE}/ensemble_mean_output
   else
      cd ${RUN_DIR}/${DATE}/ensemble_mean_output
   fi
   if [[ ${DATE} -eq ${INITIAL_DATE} ]]; then
      export OUTPUT_DIR=${WRFCHEM_INITIAL_DIR}
   else
      export OUTPUT_DIR=${WRFCHEM_CYCLE_CR_DIR}
   fi
   rm -rf wrfout_d${CR_DOMAIN}_*
   export P_DATE=${DATE}
   export P_END_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} ${FCST_PERIOD} 2>/dev/null)
   while [[ ${P_DATE} -le ${P_END_DATE} ]] ; do
      export P_YYYY=$(echo $P_DATE | cut -c1-4)
      export P_MM=$(echo $P_DATE | cut -c5-6)
      export P_DD=$(echo $P_DATE | cut -c7-8)
      export P_HH=$(echo $P_DATE | cut -c9-10)
      export P_FILE_DATE=${P_YYYY}-${P_MM}-${P_DD}_${P_HH}:00:00
      let MEM=1
      while [[ ${MEM} -le ${NUM_MEMBERS} ]]; do
         export CMEM=e${MEM}
         export KMEM=${MEM}
         if [[ ${MEM} -lt 1000 ]]; then export KMEM=0${MEM}; fi
         if [[ ${MEM} -lt 100 ]]; then export KMEM=00${MEM}; export CMEM=e0${MEM}; fi
         if [[ ${MEM} -lt 10 ]]; then export KMEM=000${MEM}; export CMEM=e00${MEM}; fi
         rm -rf wrfout_d${CR_DOMAIN}_${KMEM}
         ln -sf ${OUTPUT_DIR}/run_${CMEM}/wrfout_d${CR_DOMAIN}_${P_FILE_DATE} wrfout_d${CR_DOMAIN}_${KMEM}
         let MEM=${MEM}+1
      done
#      cp ${OUTPUT_DIR}/run_e001/wrfout_d${CR_DOMAIN}_${P_FILE_DATE} wrfout_d${CR_DOMAIN}_${P_DATE}_mean
#
# Calculate ensemble mean
      ncea -n ${NUM_MEMBERS},4,1 wrfout_d${CR_DOMAIN}_0001 wrfout_d${CR_DOMAIN}_${P_DATE}_mean
      export P_DATE=$(${BUILD_DIR}/da_advance_time.exe ${P_DATE} ${HISTORY_INTERVAL_HR} 2>/dev/null)
   done
fi
export CYCLE_DATE=${NEXT_DATE}
done
#
