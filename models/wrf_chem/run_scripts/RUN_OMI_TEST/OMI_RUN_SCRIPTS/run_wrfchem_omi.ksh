#!/bin/ksh -aeux
#########################################################################
#
# Purpose: Set global environment variables for real_time_wrf_chem
#
#########################################################################
#
# CYCLE DATE-TIME:
export DATE=2014070215
#export DATE=2008072006
#export DATE=2008072012
#export DATE=2008072018
export INITIAL_DATE=2014070215
export FIRST_FILTER_DATE=2014070216
export CYCLE_PERIOD=1
export HOR_SCALE=1500
#
export BUILD_DIR=/glade/p/work/mizzi/TRUNK/WRFDAv3.4_dmpar/var/da
export DART_DIR=/glade/p/work/mizzi/TRUNK/DART_CHEM
cp ${DART_DIR}/models/wrf_chem/work/advance_time ./.
cp ${DART_DIR}/models/wrf_chem/work/input.nml ./.
export YYYY=$(echo $DATE | cut -c1-4)
export YY=$(echo $DATE | cut -c3-4)
export MM=$(echo $DATE | cut -c5-6)
export DD=$(echo $DATE | cut -c7-8)
export HH=$(echo $DATE | cut -c9-10)
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
   export D_YYYY=${PAST_YYYY}
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
set -A GREG_DATA `echo $DATE 0 -g | ${DART_DIR}/models/wrf_chem/work/advance_time`
export DAY_GREG=${GREG_DATA[0]}
export SEC_GREG=${GREG_DATA[1]}
set -A GREG_DATA `echo $NEXT_DATE 0 -g | ${DART_DIR}/models/wrf_chem/work/advance_time`
export NEXT_DAY_GREG=${GREG_DATA[0]}
export NEXT_SEC_GREG=${GREG_DATA[1]}
export ASIM_WINDOW=1
export ASIM_MIN_DATE=$($BUILD_DIR/da_advance_time.exe $DATE -$ASIM_WINDOW 2>/dev/null)
export ASIM_MAX_DATE=$($BUILD_DIR/da_advance_time.exe $DATE +$ASIM_WINDOW 2>/dev/null)
set -A temp `echo $ASIM_MIN_DATE 0 -g | ${DART_DIR}/models/wrf_chem/work/advance_time`
export ASIM_MIN_DAY_GREG=${temp[0]}
export ASIM_MIN_SEC_GREG=${temp[1]}
set -A temp `echo $ASIM_MAX_DATE 0 -g | ${DART_DIR}/models/wrf_chem/work/advance_time` 
export ASIM_MAX_DAY_GREG=${temp[0]}
export ASIM_MAX_SEC_GREG=${temp[1]}
#
# SELECT COMPOENT RUN OPTIONS:
#
if [[ ${DATE} -eq ${INITIAL_DATE}  ]]; then
   export RUN_WRFCHEM_INITIAL=true
   export RUN_DART_FILTER=false
   export RUN_UPDATE_BC=false
   export RUN_WRFCHEM_CYCLE_CR=false
else
   export RUN_WRFCHEM_INITIAL=false
   export RUN_DART_FILTER=true
   export RUN_UPDATE_BC=true
   export RUN_WRFCHEM_CYCLE_CR=true
fi
#
export NL_APM_SCALE=1.
export NL_APM_SCALE_SW=.FALSE.
#
# FORECAST PARAMETERS:
export USE_DART_INFL=true
export FCST_PERIOD=1
(( CYCLE_PERIOD_SEC=${CYCLE_PERIOD}*60*60 ))
export NUM_MEMBERS=20
export MAX_DOMAINS=01
export CR_DOMAIN=01
export NNXP_CR=281
export NNYP_CR=221
export NNZP_CR=30
export ISTR_CR=1
export JSTR_CR=1
export DX_CR=3000.00
(( LBC_END=2*${FCST_PERIOD} ))
export LBC_FREQ=1
(( INTERVAL_SECONDS=${LBC_FREQ}*60*60 ))
export LBC_START=0
export START_DATE=${DATE}
export END_DATE=$($BUILD_DIR/da_advance_time.exe ${START_DATE} ${FCST_PERIOD} 2>/dev/null)
export START_YEAR=$(echo $START_DATE | cut -c1-4)
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
# COMPUTER PARAMETERS:
export PROJ_NUMBER=P19010000
export PROJ_NUMBER=NACD0002
export PROJ_NUMBER=NACD0002
export WRFCHEM_TIME_LIMIT=6:00
export WRFCHEM_NUM_TASKS=256
export WRFCHEM_TASKS_PER_NODE=16
export WRFCHEM_JOB_CLASS=regular
export WRFDA_TIME_LIMIT=0:10
export WRFDA_NUM_TASKS=32
export WRFDA_TASKS_PER_NODE=8
export WRFDA_JOB_CLASS=premium
export FILTER_TIME_LIMIT=0:59
export FILTER_NUM_TASKS=32
export FILTER_TASKS_PER_NODE=8
export FILTER_JOB_CLASS=regular
#
# CODE VERSIONS:
export WPS_VER=WPSv3.6.1_dmpar
export WPS_GEOG_VER=WPSv3.6.1_GEOG_DATA
export WRFDA_VER=WRFDAv3.6.1_dmpar
export WRFDA_TOOLS_VER=WRFDA_TOOLSv3.4
export WRF_VER=WRFv3.6.1_dmpar
export WRFCHEM_VER=WRFCHEMv3.6.1_dmpar
export DART_VER=DART_CHEM
#
# ROOT DIRECTORIES:
export SCRATCH_DIR=/glade/scratch/mizzi
export WORK_DIR=/glade/p/work/mizzi
export ACD_DIR=/glade/p/acd/mizzi
#
# DEPENDENT DIRECTORIES:
export RUN_DIR=${SCRATCH_DIR}/OMI_wrfchem_dart_test
export TRUNK_DIR=${WORK_DIR}/TRUNK
export WRFCHEM_DIR=${TRUNK_DIR}/${WRFCHEM_VER}
export WRFVAR_DIR=${TRUNK_DIR}/${WRFDA_VER}
export DART_DIR=${TRUNK_DIR}/${DART_VER}
export BUILD_DIR=${WRFVAR_DIR}/var/da
export WRF_DIR=${TRUNK_DIR}/${WRF_VER}
export HYBRID_TRUNK_DIR=${WORK_DIR}/HYBRID_TRUNK
export HYBRID_SCRIPTS_DIR=${HYBRID_TRUNK_DIR}/hybrid_scripts
export SCRIPTS_DIR=${TRUNK_DIR}/${WRFDA_TOOLS_VER}/scripts
#
export INPUT_DATA_DIR=${SCRATCH_DIR}/OMI_TEST_DIR/OMI_INPUT_FILES
export OBSPROC_DIR=${WRFVAR_DIR}/var/obsproc
export BE_DIR=${WRFVAR_DIR}/var/run
export WRFCHEM_INITIAL_DIR=${RUN_DIR}/${INITIAL_DATE}/wrfchem_initial
export WRFCHEM_CYCLE_CR_DIR=${RUN_DIR}/${DATE}/wrfchem_cycle_cr
export WRFCHEM_LAST_CYCLE_CR_DIR=${RUN_DIR}/${PAST_DATE}/wrfchem_cycle_cr
export DART_FILTER_DIR=${RUN_DIR}/${DATE}/dart_filter
export UPDATE_BC_DIR=${RUN_DIR}/${DATE}/update_bc
#
#########################################################################
#
#  NAMELIST PARAMETERS
#
#########################################################################
#
# WRF NAMELIST:
# TIME CONTROL NAMELIST:
export NL_RUN_DAYS=0
export NL_RUN_HOURS=${FCST_PERIOD}
export NL_RUN_MINUTES=0
export NL_RUN_SECONDS=0
export NL_START_YEAR=${START_YEAR}
export NL_START_MONTH=${START_MONTH}
export NL_START_DAY=${START_DAY}
export NL_START_HOUR=${START_HOUR}
export NL_START_MINUTE=00
export NL_START_SECOND=00
export NL_END_YEAR=${END_YEAR}
export NL_END_MONTH=${END_MONTH}
export NL_END_DAY=${END_DAY}
export NL_END_HOUR=${END_HOUR}
export NL_END_MINUTE=00
export NL_END_SECOND=00
export NL_INTERVAL_SECONDS=${INTERVAL_SECONDS}
export NL_INPUT_FROM_FILE=".true."
export NL_HISTORY_INTERVAL=30
export NL_FRAMES_PER_OUTFILE=1
export NL_RESTART=".false."
export NL_RESTART_INTERVAL=90
export NL_IO_FORM_HISTORY=2
export NL_IO_FORM_RESTART=2
export NL_FINE_INPUT_STREAM=0,2
export NL_IO_FORM_INPUT=2
export NL_IO_FORM_BOUNDARY=2
export NL_AUXINPUT2_INNAME="'"wrfinput_d\<domain\>"'"
export NL_AUXINPUT5_INNAME="'"wrfchemi_d\<domain\>_\<date\>"'"
#export NL_AUXINPUT6_INNAME="'"wrfbiochemi_d\<domain\>_\<date\>"'"
export NL_AUXINPUT6_INNAME="'"wrfbiochemi_d\<domain\>"'"
export NL_AUXINPUT7_INNAME="'"wrffirechemi_d\<domain\>_\<date\>"'"
export NL_AUXINPUT2_INTERVAL_M=60
export NL_AUXINPUT5_INTERVAL_M=60
export NL_AUXINPUT6_INTERVAL_M=60
export NL_AUXINPUT7_INTERVAL_M=60
export NL_FRAMES_PER_AUXINPUT2=1
export NL_FRAMES_PER_AUXINPUT5=1
export NL_FRAMES_PER_AUXINPUT6=1
export NL_FRAMES_PER_AUXINPUT7=1
export NL_IO_FORM_AUXINPUT2=2
export NL_IO_FORM_AUXINPUT5=2
export NL_IO_FORM_AUXINPUT6=2
export NL_IO_FORM_AUXINPUT7=2
export NL_IOFIELDS_FILENAME="'"hist_io_flds"'"
export NL_WRITE_INPUT=".true."
export NL_INPUTOUT_INTERVAL=30
export NL_INPUT_OUTNAME="'"wrfapm_d\<domain\>_\<date\>"'"
export NL_DEBUG_LEVEL=0
#
# DOMAINS NAMELIST:
export NL_TIME_STEP=15
export NL_TIME_STEP_FRACT_NUM=0
export NL_TIME_STEP_FRACT_DEN=1
export NL_MAX_DOM=${MAX_DOMAINS}
export NL_S_WE=1
export NL_E_WE=${NNXP_CR}
export NL_S_SN=1
export NL_E_SN=${NNYP_CR}
export NL_S_VERT=1
export NL_E_VERT=${NNZP_CR}
export NL_NUM_METGRID_LEVELS=30
export NL_NUM_METGRID_SOIL_LEVELS=4
export NL_DX=${DX_CR}
export NL_DY=${DX_CR}
export NL_GRID_ID=1
export NL_PARENT_ID=0
export NL_I_PARENT_START=${ISTR_CR}
export NL_J_PARENT_START=${JSTR_CR}
export NL_PARENT_GRID_RATIO=1
export NL_PARENT_TIME_STEP_RATIO=1
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
export NL_P_TOP_REQUESTED=10000.
export NL_ETA_LEVELS=1.000,0.993,0.983,0.970,0.954,0.934,0.909,0.880,0.8341923,\
0.7883847,0.7425771,0.6967695,0.617470,7,0.5455519,0.4804399,0.4215993,0.36853,\
0.3207655,0.2778706,0.2394401,0.2050965,0.1744887,0.1472903,0.1231982,0.1019311,\
0.08322784,0.06684654,0.05256274,0.04016809,0.0294686,0.02028209,0.01243387,\
0.005746085,0.000,
#
# PHYSICS NAMELIST:
export NL_MP_PHYSICS=2
export NL_RA_LW_PHYSICS=1
export NL_RA_SW_PHYSICS=2
export NL_RADT=30
export NL_SF_SFCLAY_PHYSICS=1
export NL_SF_SURFACE_PHYSICS=2
export NL_BL_PBL_PHYSICS=1
export NL_BLDT=0
export NL_CU_PHYSICS=5
export NL_CUDT=0
export NL_CUGD_AVEDX=1
export NL_CU_RAD_FEEDBACK=".true."
export NL_CU_DIAG=1
export NL_ISFFLX=1
export NL_IFSNOW=0
export NL_ICLOUD=1
export NL_SURFACE_INPUT_SOURCE=1
export NL_NUM_SOIL_LAYERS=4
export NL_MP_ZERO_OUT=2
export NL_NUM_LAND_CAT=24
export NL_SF_URBAN_PHYSICS=0
export NL_MAXIENS=1
export NL_MAXENS=3
export NL_MAXENS2=3
export NL_MAXENS3=16
export NL_ENSDIM=144
#
# DYNAMICS NAMELIST:
export NL_ISO_TEMP=200.
export NL_TRACER_OPT=0
export NL_W_DAMPING=0
export NL_DIFF_OPT=1
export NL_DIFF_6TH_OPT=0
export NL_DIFF_6TH_FACTOR=0.12
export NL_KM_OPT=4
export NL_DAMP_OPT=0
export NL_ZDAMP=5000
export NL_DAMPCOEF=0.2
export NL_NON_HYDROSTATIC=".true."
export NL_USE_BASEPARAM_FR_NML=".true."
export NL_MOIST_ADV_OPT=1
export NL_SCALAR_ADV_OPT=1
export NL_CHEM_ADV_OPT=1
export NL_TKE_ADV_OPT=2
export NL_H_MOM_ADV_ORDER=5
export NL_V_MOM_ADV_ORDER=3
export NL_H_SCA_ADV_ORDER=5
export NL_V_SCA_ADV_ORDER=3
#
# BDY_CONTROL NAMELIST:
export NL_SPEC_BDY_WIDTH=5
export NL_SPEC_ZONE=1
export NL_RELAX_ZONE=4
export NL_SPECIFIED=".true.",".false."
export NL_NESTED=".false.",".true."
#
# QUILT NAMELIST:
export NL_NIO_TASKS_PER_GROUP=0
export NL_NIO_GROUPS=1
#
# NAMELIST CHEM
export NL_KEMIT=1
export NL_CHEM_OPT=1
export NL_BIOEMDT=30
export NL_PHOTDT=18
export NL_CHEMDT=3.0
export NL_IO_STYLE_EMISSIONS=2
export NL_EMISS_INPT_OPT=1
export NL_EMISS_OPT=3
export NL_EMISS_OPT_VOL=0
export NL_CHEM_IN_OPT=0
export NL_PHOT_OPT=3
export NL_GAS_DRYDEP_OPT=1
export NL_AER_DRYDEP_OPT=1
export NL_BIO_EMISS_OPT=3
export NL_NE_AREA=118
export NL_GAS_BC_OPT=1
export NL_GAS_IC_OPT=1
export NL_AER_BC_OPT=1
export NL_AER_IC_OPT=1
export NL_GASCHEM_ONOFF=1
export NL_AERCHEM_ONOFF=1
export NL_WETSCAV_ONOFF=0
export NL_CLDCHEM_ONOFF=0
export NL_VERTMIX_ONOFF=1
export NL_CHEM_CONV_TR=1
export NL_CONV_TR_WETSCAV=0
export NL_CONV_TR_AQCHEM=0
export NL_SEAS_OPT=0
export NL_DUST_OPT=0
export NL_DMSEMIS_OPT=0
export NL_BIOMASS_BURN_OPT=0
export NL_PLUMERISEFIRE_FRQ=30
export NL_SCALE_FIRE_EMISS=".true."
export NL_HAVE_BCS_CHEM=".true."
export NL_AER_RA_FEEDBACK=0
export NL_AER_OP_OPT=0
export NL_OPT_PARS_OUT=1
export NL_HAVE_BCS_UPPER=".false."
export NL_FIXED_UBC_PRESS=50.,50.
export NL_FIXED_UBC_INNAME="'"ubvals_b40.20th.track1_1996-2005.nc"'"
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
export NL_VAR_SCALING4=1.0
export NL_JE_FACTOR=1.0
export NL_CV_OPTIONS=3
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
export NL_ANALYSIS_TYPE="'"RANDOMCV"'"
#
# WRFVAR18 NAMELIST:
export ANALYSIS_DATE=$(${BUILD_DIR}/da_advance_time.exe ${DATE} 0 -W 2>/dev/null)
#
# WRFVAR19 NAMELIST:
export NL_PSEUDO_VAR="'"t"'"
#
# WRFVAR21 NAMELIST:
export NL_TIME_WINDOW_MIN="'"$(${BUILD_DIR}/da_advance_time.exe ${DATE} -${ASIM_WINDOW} -W 2>/dev/null)"'"
#
# WRFVAR22 NAMELIST:
export NL_TIME_WINDOW_MAX="'"$(${BUILD_DIR}/da_advance_time.exe ${DATE} +${ASIM_WINDOW} -W 2>/dev/null)"'"
#
# WRFVAR23 NAMELIST:
export NL_JCDFI_USE=false
export NL_JCDFI_IO=false
#
# DART input.nml parameters
# &apm namelist parameters
export NL_APM_SCALE=1.
export NL_APM_SCALE_SW=.FALSE.
#
# &filter.nml
export NL_OUTLIER_THRESHOLD=3.
export NL_ENABLE_SPECIAL_OUTLIER_CODE=.false.
export NL_SPECIAL_OUTLIER_THRESHOLD=4.
export NL_ENS_SIZE=${NUM_MEMBERS}
export NL_OUTPUT_RESTART=.true.
export NL_START_FROM_RESTART=.true.
export NL_OBS_SEQUENCE_IN_NAME="'obs_seq.out'"       
export NL_OBS_SEQUENCE_OUT_NAME="'obs_seq.final'"
export NL_RESTART_IN_FILE_NAME="'filter_ic_old'"       
export NL_RESTART_OUT_FILE_NAME="'filter_ic_new'"       
set -A temp `echo ${ASIM_MIN_DATE} 0 -g | ${DART_DIR}/models/wrf_chem/work/advance_time`
(( temp[1]=${temp[1]}+1 ))
export NL_FIRST_OBS_DAYS=${temp[0]}
export NL_FIRST_OBS_SECONDS=${temp[1]}
set -A temp `echo ${ASIM_MAX_DATE} 0 -g | ${DART_DIR}/models/wrf_chem/work/advance_time`
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
if [[ ${START_DATE} -eq ${FIRST_FILTER_DATE} ]]; then
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
export NL_SPECIAL_LOCALIZATION_OBS_TYPES="'IASI_CO_RETRIEVAL','MOPITT_CO_RETRIEVAL'"
export NL_SAMPLING_ERROR_CORRECTION=.true.
export NL_SPECIAL_LOCALIZATION_CUTOFFS=0.1,0.1
export NL_ADAPTIVE_LOCALIZATION_THRESHOLD=2000
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
export NL_WRF_STATE_VARIABLES="'U',     'KIND_U_WIND_COMPONENT',     'TYPE_U',  'UPDATE','999',
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
                           'PSFC',  'KIND_PRESSURE',             'TYPE_PS', 'UPDATE','999',
                           'o3',    'KIND_O3',                   'TYPE_O3', 'UPDATE','999',
                           'co',    'KIND_CO',                   'TYPE_CO', 'UPDATE','999',
                           'no',    'KIND_NO',                   'TYPE_NO', 'UPDATE','999',
                           'no2',   'KIND_NO2',                  'TYPE_NO2', 'UPDATE','999',
                           'hno3',  'KIND_HNO3',                 'TYPE_HNO3', 'UPDATE','999',
                           'hno4',  'KIND_HNO4',                 'TYPE_HNO4', 'UPDATE','999',
                           'n2o5',  'KIND_N2O5',                 'TYPE_N2O5', 'UPDATE','999',
                           'pan',   'KIND_PAN',                  'TYPE_PAN', 'UPDATE','999',
                           'mek',   'KIND_MEK',                  'TYPE_MEK', 'UPDATE','999',
                           'ald',   'KIND_ALD',                  'TYPE_ALD', 'UPDATE','999',
                           'ch3o2', 'KIND_CH3O2',                'TYPE_CH3O2', 'UPDATE','999',
                           'c3h8',  'KIND_C3H8',                 'TYPE_C3H8', 'UPDATE','999',
                           'c2h6',  'KIND_C2H6',                 'TYPE_C2H6', 'UPDATE','999',
                           'acet',  'KIND_ACET',                 'TYPE_ACET', 'UPDATE','999',
                           'hcho',  'KIND_HCHO',                 'TYPE_HCHO', 'UPDATE','999',
                           'c2h4',  'KIND_C2H4',                 'TYPE_C2H4', 'UPDATE','999',
                           'c3h6',  'KIND_C3H6',                 'TYPE_C3H6', 'UPDATE','999',
                           'tol',   'KIND_TOL',                  'TYPE_TOL', 'UPDATE','999',
                           'mvk',   'KIND_MVK',                  'TYPE_MVK', 'UPDATE','999',
                           'bigalk','KIND_BIGALK',               'TYPE_BIGALK', 'UPDATE','999',
                           'isopr', 'KIND_ISOPR',                'TYPE_ISOPR', 'UPDATE','999',
                           'macr',  'KIND_MACR',                 'TYPE_MACR', 'UPDATE','999',
                           'glyald','KIND_GLYALD',               'TYPE_GLYALD', 'UPDATE','999',
                           'c10h16','KIND_C10H16',               'TYPE_C10H16', 'UPDATE','999'"
export NL_WRF_STATE_BOUNDS="'QVAPOR','0.0','NULL','CLAMP',
                        'QRAIN', '0.0','NULL','CLAMP',
                        'QCLOUD','0.0','NULL','CLAMP',
                        'QSNOW', '0.0','NULL','CLAMP',
                        'QICE',  '0.0','NULL','CLAMP',
                        'o3',    '0.0','NULL','CLAMP',
                        'co',    '1.e-4','NULL','CLAMP',
                        'no',    '0.0','NULL','CLAMP',
                        'no2',   '0.0','NULL','CLAMP',
                        'hno3',  '0.0','NULL','CLAMP',
                        'hno4',  '0.0','NULL','CLAMP',
                        'n2o5',  '0.0','NULL','CLAMP',
                        'pan',   '0.0','NULL','CLAMP',
                        'mek',   '0.0','NULL','CLAMP',
                        'ald',   '0.0','NULL','CLAMP',
                        'ch3o2', '0.0','NULL','CLAMP',
                        'c3h8',  '0.0','NULL','CLAMP',
                        'c2h6',  '0.0','NULL','CLAMP',
                        'acet'   '0.0','NULL','CLAMP',
                        'hcho'   '0.0','NULL','CLAMP',
                        'c2h4',  '0.0','NULL','CLAMP',
                        'c3h6',  '0.0','NULL','CLAMP',
                        'tol',   '0.0','NULL','CLAMP',
                        'mvk',   '0.0','NULL','CLAMP',
                        'bigalk','0.0','NULL','CLAMP',
                        'isopr', '0.0','NULL','CLAMP',
                        'macr',  '0.0','NULL','CLAMP',
                        'glyald','0.0','NULL','CLAMP',
                        'c10h16','0.0','NULL','CLAMP'"
export NL_OUTPUT_STATE_VECTOR=.false.
export NL_NUM_DOMAINS=${CR_DOMAIN}
export NL_CALENDAR_TYPE=3
export NL_ASSIMILATION_PERIOD_SECONDS=${CYCLE_PERIOD_SEC}
export NL_VERT_LOCALIZATION_COORD=3
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
# &restart_file_tool_nml
export NL_INPUT_FILE_NAME="'assim_model_state_tp'"
export NL_OUTPUT_FILE_NAME="'assim_model_state_ic'"
export NL_OUTPUT_IS_MODEL_ADVANCE_FILE=.true.
export NL_OVERWRITE_ADVANCE_TIME=.true.
export NL_NEW_ADVANCE_DAYS=${NEXT_DAY_GREG}
export NL_NEW_ADVANCE_SECS=${NEXT_SEC_GREG}
#
# &preprocess_nml
export NL_INPUT_OBS_KIND_MOD_FILE="'"${DART_DIR}/obs_kind/DEFAULT_obs_kind_mod.F90"'"
export NL_OUTPUT_OBS_KIND_MOD_FILE="'"${DART_DIR}/obs_kind/obs_kind_mod.f90"'"
export NL_INPUT_OBS_DEF_MOD_FILE="'"${DART_DIR}/obs_kind/DEFAULT_obs_def_mod.F90"'"
export NL_OUTPUT_OBS_DEF_MOD_FILE="'"${DART_DIR}/obs_kind/obs_def_mod.f90"'"
export NL_INPUT_FILES="'${DART_DIR}/obs_def/obs_def_reanalysis_bufr_mod.f90',
                    '${DART_DIR}/obs_def/obs_def_radar_mod.f90',
                    '${DART_DIR}/obs_def/obs_def_metar_mod.f90',
                    '${DART_DIR}/obs_def/obs_def_dew_point_mod.f90',
                    '${DART_DIR}/obs_def/obs_def_altimeter_mod.f90',
                    '${DART_DIR}/obs_def/obs_def_gps_mod.f90',
                    '${DART_DIR}/obs_def/obs_def_gts_mod.f90',
                    '${DART_DIR}/obs_def/obs_def_vortex_mod.f90',
                    '${DART_DIR}/obs_def/obs_def_IASI_CO_mod.f90',
                    '${DART_DIR}/obs_def/obs_def_MOPITT_CO_mod.f90',
                    '${DART_DIR}/obs_def/obs_def_MODIS_AOD_mod.f90'"
#
# &obs_kind_nml
export NL_ASSIMILATE_THESE_OBS_TYPES="'RADIOSONDE_TEMPERATURE',
                                   'RADIOSONDE_U_WIND_COMPONENT',
                                   'RADIOSONDE_V_WIND_COMPONENT',
                                   'ACARS_U_WIND_COMPONENT',
                                   'ACARS_V_WIND_COMPONENT',
                                   'ACARS_TEMPERATURE',
                                   'AIRCRAFT_U_WIND_COMPONENT',
                                   'AIRCRAFT_V_WIND_COMPONENT',
                                   'AIRCRAFT_TEMPERATURE',
                                   'SAT_U_WIND_COMPONENT',
                                   'SAT_V_WIND_COMPONENT',
                                   'MOPITT_CO_RETRIEVAL'"
#export NL_EVALUATE_THESE_OBS_TYPES="'MOPITT_CO_RETRIEVAL'"
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
export NL_HORIZ_DIST_ONLY=.true.
export NL_VERTICAL_NORMALIZATION_HEIGHT=8000.0
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
   export RAN_APM=${RANDOM}
   let MEM=1
   while [[ ${MEM} -le ${NUM_MEMBERS} ]]; do
      export CMEM=e${MEM}
      export KMEM=${MEM}
      if [[ ${MEM} -lt 1000 ]]; then export KMEM=0${MEM}; fi
      if [[ ${MEM} -lt 100 ]]; then export KMEM=00${MEM}; export CMEM=e0${MEM}; fi
      if [[ ${MEM} -lt 10 ]]; then export KMEM=000${MEM}; export CMEM=e00${MEM}; fi
      export L_RUN_DIR=run_${CMEM}
      cd ${RUN_DIR}/${DATE}/wrfchem_initial
      if [[ ! -e ${L_RUN_DIR} ]]; then
         mkdir ${L_RUN_DIR}
         cd ${L_RUN_DIR}
      else
         cd ${L_RUN_DIR}
      fi
#
# Get WRF-Chem parameter files
      cp ${WRFCHEM_DIR}/test/em_real/wrf.exe ./.
      cp ${WRFCHEM_DIR}/test/em_real/CAM_ABS_DATA ./.
      cp ${WRFCHEM_DIR}/test/em_real/CAM_AEROPT_DATA ./.
      cp ${WRFCHEM_DIR}/test/em_real/ETAMPNEW_DATA ./.
      cp ${WRFCHEM_DIR}/test/em_real/GENPARM.TBL ./.
      cp ${WRFCHEM_DIR}/test/em_real/LANDUSE.TBL ./.
      cp ${WRFCHEM_DIR}/test/em_real/RRTMG_LW_DATA ./.
      cp ${WRFCHEM_DIR}/test/em_real/RRTMG_SW_DATA ./.
      cp ${WRFCHEM_DIR}/test/em_real/RRTM_DATA ./.
      cp ${WRFCHEM_DIR}/test/em_real/SOILPARM.TBL ./.
      cp ${WRFCHEM_DIR}/test/em_real/URBPARM.TBL ./.
      cp ${WRFCHEM_DIR}/test/em_real/VEGPARM.TBL ./.
      cp ${DART_DIR}/models/wrf_chem/run_scripts/hist_io_flds ./.
#
      cp ${INPUT_DATA_DIR}/clim_p_trop.nc ./.
      cp ${INPUT_DATA_DIR}/ubvals_b40.20th.track1_1996-2005.nc ./.
      cp ${INPUT_DATA_DIR}/exo_coldens_d${CR_DOMAIN} ./.
      cp ${INPUT_DATA_DIR}/wrf_season_wes_usgs_d${CR_DOMAIN}.nc ./.
#
# Get WRF-Chem emissions files

      cp ${INPUT_DATA_DIR}/chem_static_p30/wrfbiochemi_d${CR_DOMAIN}  wrfbiochemi_d${CR_DOMAIN}
      export L_DATE=${START_DATE}
      while [[ ${L_DATE} -le ${END_DATE} ]]; do
         export L_YY=`echo ${L_DATE} | cut -c1-4`
         export L_MM=`echo ${L_DATE} | cut -c5-6`
         export L_DD=`echo ${L_DATE} | cut -c7-8`
         export L_HH=`echo ${L_DATE} | cut -c9-10`
         export L_FILE_DATE=${L_YY}-${L_MM}-${L_DD}_${L_HH}:00:00
###         cp ${WRFCHEM_CHEM_EMISS_DIR}/wrffirechemi_d${CR_DOMAIN}_${L_FILE_DATE}.${CMEM} wrffirechemi_d${CR_DOMAIN}_${L_FILE_DATE}
         cp ${INPUT_DATA_DIR}/chem_static_p30/${L_YY}${L_MM}${L_DD}/wrfchemi_d${CR_DOMAIN}_${L_FILE_DATE}.${CMEM} wrfchemi_d${CR_DOMAIN}_${L_FILE_DATE}
         export L_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} +1 2>/dev/null)
      done
#
# Get WR-Chem input and bdy files
      cp ${INPUT_DATA_DIR}/wpb_rc_chem_p30/${YYYY}${MM}${DD}${HH}/wrfinput_d${CR_DOMAIN}_${START_FILE_DATE}.${CMEM} wrfinput_d${CR_DOMAIN}
      cp ${INPUT_DATA_DIR}/wpb_rc_chem_p30/${YYYY}${MM}${DD}${HH}/wrfbdy_d${CR_DOMAIN}_${START_FILE_DATE}.${CMEM} wrfbdy_d${CR_DOMAIN}
#
# Create WRF-Chem namelist.input
      export NL_MAX_DOM=1
      rm -rf namelist.input
      ${HYBRID_SCRIPTS_DIR}/da_create_wrfchem_namelist_RT.ksh
#
# Create job script for this member and run it 
      rm -rf job.ksh
      touch job.ksh
      export JOBRND=advm_${RAN_APM}
      cat << EOF >job.ksh
#!/bin/ksh -aeux
#BSUB -P ${PROJ_NUMBER}
#BSUB -x                                    # exclusive use of node (not_shared)
#BSUB -n ${WRFCHEM_NUM_TASKS}                       # number of total (MPI) tasks
#BSUB -R "span[ptile=${WRFCHEM_TASKS_PER_NODE}]"    # mpi tasks per node
#BSUB -J ${JOBRND}                          # job name
#BSUB -o ${JOBRND}.out                      # output filename
#BSUB -e ${JOBRND}.err                      # error filename
#BSUB -W ${WRFCHEM_TIME_LIMIT}               # wallclock time (minutes)
#BSUB -q ${WRFCHEM_JOB_CLASS}
#
mpirun.lsf ./wrf.exe > index_wrfchem_${KMEM} 2>&1 
export RC=\$?     
rm -rf WRFCHEM_SUCCESS_*; fi     
rm -rf WRFCHEM_FAILED_*; fi          
if [[ \$RC = 0 ]]; then
   touch WRFCHEM_SUCCESS_${RAN_APM}
else
   touch WRFCHEM_FAILED_${RAN_APM} 
   exit
fi
EOF
#
      bsub -K < job.ksh 
      let MEM=${MEM}+1


exit

   done
#
# Wait for WRFCHEM to complete for each member
   ${HYBRID_SCRIPTS_DIR}/da_run_hold.ksh ${RAN_APM}
fi
#
#########################################################################
#
# RUN DART_FILTER
#
#########################################################################
#
#if ${RUN_DART_FILTER}; then
#   if [[ ! -d ${RUN_DIR}/${DATE}/dart_filter ]]; then
#      mkdir -p ${RUN_DIR}/${DATE}/dart_filter
#      cd ${RUN_DIR}/${DATE}/dart_filter
#   else
#      cd ${RUN_DIR}/${DATE}/dart_filter
#   fi
##
## Get DART files
#   cp ${DART_DIR}/models/wrf_chem/work/filter      ./.
#   cp ${DART_DIR}/system_simulation/final_full_precomputed_tables/final_full.${NUM_MEMBERS} ./.
##
## Get background forecasts
#   if [[ ${DATE} -eq ${FIRST_FILTER_DATE} ]]; then
#      export BACKGND_FCST_DIR=${WRFCHEM_INITIAL_DIR}
#   else
#      export BACKGND_FCST_DIR=${WRFCHEM_LAST_CYCLE_CR_DIR}
#   fi
##
## Get observations
#   if [[ ${PREPROCESS_OBS_DIR}/obs_seq_comb_filtered_${START_DATE}.out ]]; then      
#      cp  ${PREPROCESS_OBS_DIR}/obs_seq_comb_filtered_${START_DATE}.out obs_seq.out
#   else
#      echo APM ERROR: NO DART OBSERVATIONS
#      exit
#   fi
##
## Run WRF_TO_DART
#   export RAN_APM=${RANDOM}
#   let MEM=1
#   while [[ ${MEM} -le ${NUM_MEMBERS} ]]; do
#      export CMEM=e${MEM}
#      export KMEM=${MEM}
#      if [[ ${MEM} -lt 1000 ]]; then export KMEM=0${MEM}; fi
#      if [[ ${MEM} -lt 100 ]]; then export KMEM=00${MEM}; export CMEM=e0${MEM}; fi
#      if [[ ${MEM} -lt 10 ]]; then export KMEM=000${MEM}; export CMEM=e00${MEM}; fi
##
#      cd ${RUN_DIR}/${DATE}/dart_filter
#      rm -rf dart_wrk_${CMEM}
#      mkdir dart_wrk_${CMEM}
#      cd dart_wrk_${CMEM}
##
## &wrf_to_dart_nml
#      export NL_DART_RESTART_NAME="'../filter_ic_old.${KMEM}'"
#      export NL_PRINT_DATA_RANGES=.false.
#      ${DART_DIR}/models/wrf_chem/namelist_scripts/DART/dart_create_input.nml.ksh
#      cp ${DART_DIR}/models/wrf_chem/work/wrf_to_dart ./.
#      cp ${BACKGND_FCST_DIR}/run_${CMEM}/wrfout_d${CR_DOMAIN}_${FILE_DATE} wrfinput_d${CR_DOMAIN}
##
## Create job script 
#      rm -rf job.ksh
#      touch job.ksh
#      RANDOM=$$
#      export JOBRND=wr2dt_${RAN_APM}
#      cat << EOF >job.ksh
##!/bin/ksh -aeux
##BSUB -P ${PROJ_NUMBER}
##BSUB -n 1                                  # number of total (MPI) tasks
##BSUB -J ${JOBRND}                          # job name
##BSUB -o ${JOBRND}.out                      # output filename
##BSUB -e ${JOBRND}.err                      # error filename
##BSUB -W 00:05                              # wallclock time (minutes)
##BSUB -q geyser
##
## Run wrf_to_dart
#./wrf_to_dart > index_wrf_to_dart 2>&1 
##
#export RC=\$?     
#rm -rf WRF2DART_SUCCESS_*
#rm -rf WRF2DART_FAILED_*
#if [[ \$RC = 0 ]]; then
#   touch WRF2DART_SUCCESS_${RAN_APM}
#else
#   touch WRF2DART_FAILED_${RAN_APM} 
#   exit
#fi
#EOF
##
## Submit convert file script for each and wait until job completes
#      bsub < job.ksh 
#      let MEM=${MEM}+1
#   done
##
## Wait for wrf_to_dart to complete for each member
#   ${HYBRID_SCRIPTS_DIR}/da_run_hold.ksh ${RAN_APM}
##
#   cd ${RUN_DIR}/${DATE}/dart_filter
#   ${DART_DIR}/models/wrf_chem/namelist_scripts/DART/dart_create_input.nml.ksh
#   cp ${BACKGND_FCST_DIR}/run_e001/wrfout_d${CR_DOMAIN}_${FILE_DATE} wrfinput_d${CR_DOMAIN}
##
## Copy "out" inflation files from prior cycle to "in" inflation files for current cycle
#   if ${USE_DART_INFL}; then
#      if [[ ${DATE} -eq ${FIRST_FILTER_DATE} ]]; then
#         export NL_INF_INITIAL_FROM_RESTART_PRIOR=.false.
#         export NL_INF_SD_INITIAL_FROM_RESTART_PRIOR=.false.
#         export NL_INF_INITIAL_FROM_RESTART_POST=.false.
#         export NL_INF_SD_INITIAL_FROM_RESTART_POST=.false.
#      else
#         export NL_INF_INITIAL_FROM_RESTART_PRIOR=.true.
#         export NL_INF_SD_INITIAL_FROM_RESTART_PRIOR=.true.
#         export NL_INF_INITIAL_FROM_RESTART_POST=.true.
#         export NL_INF_SD_INITIAL_FROM_RESTART_POST=.true.
#      fi
#      if [[ ${DATE} -ne ${FIRST_FILTER_DATE} ]]; then
#         if [[ ${NL_INF_FLAVOR_PRIOR} != 0 ]]; then
#            export INF_OUT_FILE_NAME_PRIOR=${RUN_DIR}/${PAST_DATE}/dart_filter/prior_inflate_ic_new
#            cp ${INF_OUT_FILE_NAME_PRIOR} prior_inflate_ic_old
#         fi
#         if [[ ${NL_INF_FLAVOR_POST} != 0 ]]; then
#            export INF_OUT_FILE_NAME_POST=${RUN_DIR}/${PAST_DATE}/dart_filter/post_inflate_ic_new
#            cp ${NL_INF_OUT_FILE_NAME_POST} post_infalte_ic_old
#         fi 
#      fi
#   fi
##
## Generate input.nml
#   set -A temp `echo ${ASIM_MIN_DATE} 0 -g | ${DART_DIR}/models/wrf_chem/work/advance_time`
#   (( temp[1]=${temp[1]}+1 ))
#   export NL_FIRST_OBS_DAYS=${temp[0]}
#   export NL_FIRST_OBS_SECONDS=${temp[1]}
#   set -A temp `echo ${ASIM_MAX_DATE} 0 -g | ${DART_DIR}/models/wrf_chem/work/advance_time`
#   export NL_LAST_OBS_DAYS=${temp[0]}
#   export NL_LAST_OBS_SECONDS=${temp[1]}
#   rm -rf input.nml
#   ${DART_DIR}/models/wrf_chem/namelist_scripts/DART/dart_create_input.nml.ksh
##
## Make filter_apm_nml for special_outlier_threshold
#   rm -rf filter_apm.nml
#   cat << EOF > filter_apm.nml
#&filter_apm_nml
#special_outlier_threshold=${NL_SPECIAL_OUTLIER_THRESHOLD}
#/
#EOF
##
## Make obs_def_apm_nml for apm_scale to adjust observation error variance
#  rm -rf obs_def_apm.nml
#  cat << EOF > obs_def_apm.nml
#&obs_def_apm_nml
#apm_scale=${NL_APM_SCALE}
#apm_scale_sw=${NL_APM_SCALE_SW}
#/
#EOF
##
## Run DART_FILTER
## Create job script for this member and run it 
#   rm -rf job.ksh
#   touch job.ksh
#   RANDOM=$$
#   export JOBRND=filter_${RANDOM}
#   cat << EOF >job.ksh
##!/bin/ksh -aeux
##BSUB -P ${PROJ_NUMBER}
##BSUB -x                                    # exclusive use of node (not_shared)
##BSUB -n ${FILTER_NUM_TASKS}                       # number of total (MPI) tasks
##BSUB -R "span[ptile=${FILTER_TASKS_PER_NODE}]"    # mpi tasks per node
##BSUB -J ${JOBRND}                          # job name
##BSUB -o ${JOBRND}.out                      # output filename
##BSUB -e ${JOBRND}.err                      # error filename
##BSUB -W ${FILTER_TIME_LIMIT}               # wallclock time (minutes)
##BSUB -q ${FILTER_JOB_CLASS}
##
#mpirun.lsf ./filter > index_filter 2>&1 
#export RC=\$?     
#rm -rf FILTER_SUCCESS     
#rm -rf FILTER_FAILED          
#if [[ \$RC = 0 ]]; then
#   touch FILTER_SUCCESS
#else
#   touch FILTER_FAILED 
#   exit
#fi
#EOF
##
#   bsub -K < job.ksh
##
## Run DART_TO_WRF 
#   export RAN_APM=${RANDOM}
#   let MEM=1
#   while [[ ${MEM} -le ${NUM_MEMBERS} ]]; do
#      export CMEM=e${MEM}
#      export KMEM=${MEM}
#      if [[ ${MEM} -lt 1000 ]]; then export KMEM=0${MEM}; fi
#      if [[ ${MEM} -lt 100 ]]; then export KMEM=00${MEM}; export CMEM=e0${MEM}; fi
#      if [[ ${MEM} -lt 10 ]]; then export KMEM=000${MEM}; export CMEM=e00${MEM}; fi
##
#      cd ${RUN_DIR}/${DATE}/dart_filter
#      rm -rf dart_wrk_${CMEM}
#      mkdir dart_wrk_${CMEM}
#      cd dart_wrk_${CMEM}
##
## &dart_to_wrf_nml
#      export NL_MODEL_ADVANCE_FILE=.false.
#      export NL_DART_RESTART_NAME="'"../filter_ic_new.${KMEM}"'"
#      rm -rf cd dinput.nml
#      ${DART_DIR}/models/wrf_chem/namelist_scripts/DART/dart_create_input.nml.ksh
#      cp ${DART_DIR}/models/wrf_chem/work/dart_to_wrf ./.
#      cp ${BACKGND_FCST_DIR}/run_${CMEM}/wrfout_d${CR_DOMAIN}_${FILE_DATE} wrfinput_d${CR_DOMAIN}
##
## Create job script 
#      rm -rf job.ksh
#      touch job.ksh
#      RANDOM=$$
#      export JOBRND=dt2wf_${RAN_APM}
#      cat << EOF >job.ksh
##!/bin/ksh -aeux
##BSUB -P ${PROJ_NUMBER}
##BSUB -n 1                                  # number of total (MPI) tasks
##BSUB -J ${JOBRND}                          # job name
##BSUB -o ${JOBRND}.out                      # output filename
##BSUB -e ${JOBRND}.err                      # error filename
##BSUB -W 00:05                              # wallclock time (minutes)
##BSUB -q geyser
##
## Run wrf_to_dart
#./dart_to_wrf > index_dart_to_wrf 2>&1 
##
#export RC=\$?     
#rm -rf DART2WRF_SUCCESS_*
#rm -rf DART2WRF_FAILED_*
#if [[ \$RC = 0 ]]; then
#   touch DART2WRF_SUCCESS_{RAN_APM}
#else
#   touch DART2WRF_FAILED_{RAN_APM}
#   exit
#fi
#EOF
##
## Submit convert file script for each and wait until job completes
#      bsub < job.ksh 
#      cp wrfinput_d${CR_DOMAIN} ../wrfout_d${CR_DOMAIN}_${FILE_DATE}_filt.${CMEM} 
#      let MEM=${MEM}+1
#   done
##
## Wait for dart_to_wrf to complete for each member
#   ${HYBRID_SCRIPTS_DIR}/da_run_hold.ksh ${RAN_APM}
#fi
##
##########################################################################
##
## UPDATE COARSE RESOLUTION BOUNDARY CONDIIONS
##
##########################################################################
#
#if ${RUN_UPDATE_BC}; then
#   if [[ ! -d ${RUN_DIR}/${DATE}/update_bc ]]; then
#      mkdir -p ${RUN_DIR}/${DATE}/update_bc
#      cd ${RUN_DIR}/${DATE}/update_bc
#   else
#      cd ${RUN_DIR}/${DATE}/update_bc
#   fi
##
#   let MEM=1
#   while [[ ${MEM} -le ${NUM_MEMBERS} ]]; do
#      export CMEM=e${MEM}
#      export KMEM=${MEM}
#      if [[ ${MEM} -lt 1000 ]]; then export KMEM=0${MEM}; fi
#      if [[ ${MEM} -lt 100 ]]; then export KMEM=00${MEM}; export CMEM=e0${MEM}; fi
#      if [[ ${MEM} -lt 10 ]]; then export KMEM=000${MEM}; export CMEM=e00${MEM}; fi
##
#      export OPS_FORC_FILE=${WRFCHEM_CHEM_ICBC_DIR}/wrfinput_d${CR_DOMAIN}_${FILE_DATE}.${CMEM}
#      export BDYCDN_IN=${WRFCHEM_CHEM_ICBC_DIR}/wrfbdy_d${CR_DOMAIN}_${FILE_DATE}.${CMEM}
#      cp ${BDYCDN_IN} wrfbdy_d${CR_DOMAIN}_${FILE_DATE}_prior.${CMEM}
#      export DA_OUTPUT_FILE=${DART_FILTER_DIR}/wrfout_d${CR_DOMAIN}_${FILE_DATE}_filt.${CMEM} 
#      export BDYCDN_OUT=wrfbdy_d${CR_DOMAIN}_${FILE_DATE}_filt.${CMEM}    
#      ${HYBRID_SCRIPTS_DIR}/da_run_update_bc.ksh > index_update_bc 2>&1
##
#      let MEM=$MEM+1
#   done
#fi
##
#########################################################################
##
## RUN WRFCHEM_CYCLE_CR
##
##########################################################################
##
#if ${RUN_WRFCHEM_CYCLE_CR}; then
#   if [[ ! -d ${RUN_DIR}/${DATE}/wrfchem_cycle_cr ]]; then
#      mkdir -p ${RUN_DIR}/${DATE}/wrfchem_cycle_cr
#      cd ${RUN_DIR}/${DATE}/wrfchem_cycle_cr
#   else
#      cd ${RUN_DIR}/${DATE}/wrfchem_cycle_cr
#   fi
##
## Run WRF-Chem for all ensemble members
#   export RAN_APM=${RANDOM}
#   let MEM=1
#   while [[ ${MEM} -le ${NUM_MEMBERS} ]]; do
#      export CMEM=e${MEM}
#      export KMEM=${MEM}
#      if [[ ${MEM} -lt 1000 ]]; then export KMEM=0${MEM}; fi
#      if [[ ${MEM} -lt 100 ]]; then export KMEM=00${MEM}; export CMEM=e0${MEM}; fi
#      if [[ ${MEM} -lt 10 ]]; then export KMEM=000${MEM}; export CMEM=e00${MEM}; fi
#      export L_RUN_DIR=run_${CMEM}
#      cd ${RUN_DIR}/${DATE}/wrfchem_cycle_cr
#      if [[ ! -e ${L_RUN_DIR} ]]; then
#         mkdir ${L_RUN_DIR}
#         cd ${L_RUN_DIR}
#      else
#         cd ${L_RUN_DIR}
#      fi
##
## Get WRF-Chem parameter files
#      cp ${WRFCHEM_DIR}/test/em_real/wrf.exe ./.
#      cp ${WRFCHEM_DIR}/test/em_real/CAM_ABS_DATA ./.
#      cp ${WRFCHEM_DIR}/test/em_real/CAM_AEROPT_DATA ./.
#      cp ${WRFCHEM_DIR}/test/em_real/ETAMPNEW_DATA ./.
#      cp ${WRFCHEM_DIR}/test/em_real/GENPARM.TBL ./.
#      cp ${WRFCHEM_DIR}/test/em_real/LANDUSE.TBL ./.
#      cp ${WRFCHEM_DIR}/test/em_real/RRTMG_LW_DATA ./.
#      cp ${WRFCHEM_DIR}/test/em_real/RRTMG_SW_DATA ./.
#      cp ${WRFCHEM_DIR}/test/em_real/RRTM_DATA ./.
#      cp ${WRFCHEM_DIR}/test/em_real/SOILPARM.TBL ./.
#      cp ${WRFCHEM_DIR}/test/em_real/URBPARM.TBL ./.
#      cp ${WRFCHEM_DIR}/test/em_real/VEGPARM.TBL ./.
#      cp ${DART_DIR}/models/wrf_chem/run_scripts/hist_io_flds ./.
##
#      cp ${REAL_TIME_DIR}/clim_p_trop.nc ./.
#      cp ${REAL_TIME_DIR}/ubvals_b40.20th.track1_1996-2005.nc ./.
#      cp ${EXO_COLDENS_DIR}/exo_coldens_d${CR_DOMAIN} ./.
#      cp ${SEASONS_WES_DIR}/wrf_season_wes_usgs_d${CR_DOMAIN}.nc ./.
##
## Get WRF-Chem emissions files
##
#      cp ${WRFCHEM_CHEM_EMISS_DIR}/wrfbiochemi_d${CR_DOMAIN}_${START_FILE_DATE}.${CMEM} wrfbiochemi_d${CR_DOMAIN}_${START_FILE_DATE}
#      export L_DATE=${START_DATE}
#      while [[ ${L_DATE} -le ${END_DATE} ]]; do
#         export L_YY=`echo ${L_DATE} | cut -c1-4`
#         export L_MM=`echo ${L_DATE} | cut -c5-6`
#         export L_DD=`echo ${L_DATE} | cut -c7-8`
#         export L_HH=`echo ${L_DATE} | cut -c9-10`
#         export L_FILE_DATE=${L_YY}-${L_MM}-${L_DD}_${L_HH}:00:00
#         cp ${WRFCHEM_CHEM_EMISS_DIR}/wrffirechemi_d${CR_DOMAIN}_${L_FILE_DATE}.${CMEM} wrffirechemi_d${CR_DOMAIN}_${L_FILE_DATE}
#         cp ${WRFCHEM_CHEM_EMISS_DIR}/wrfchemi_d${CR_DOMAIN}_${L_FILE_DATE}.${CMEM} wrfchemi_d${CR_DOMAIN}_${L_FILE_DATE}
#         export L_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} +1 2>/dev/null)
#      done
##
## Get WR-Chem input and bdy files
#      cp ${DART_FILTER_DIR}/wrfout_d${CR_DOMAIN}_${START_FILE_DATE}_filt.${CMEM} wrfinput_d${CR_DOMAIN}
#      cp ${UPDATE_BC_DIR}/wrfbdy_d${CR_DOMAIN}_${START_FILE_DATE}_filt.${CMEM} wrfbdy_d${CR_DOMAIN}
##
## Create WRF-Chem namelist.input 
#      export NL_MAX_DOM=1
#      rm -rf namelist.input
#      ${HYBRID_SCRIPTS_DIR}/da_create_wrfchem_namelist_RT.ksh
##
## Create job script for this member and run it 
#      rm -rf job.ksh
#      touch job.ksh
#      export JOBRND=advm_${RAN_APM}
#      cat << EOF >job.ksh
##!/bin/ksh -aeux
##BSUB -P ${PROJ_NUMBER}
##BSUB -x                                    # exclusive use of node (not_shared)
##BSUB -n ${WRFCHEM_NUM_TASKS}                       # number of total (MPI) tasks
##BSUB -R "span[ptile=${WRFCHEM_TASKS_PER_NODE}]"    # mpi tasks per node
##BSUB -J ${JOBRND}                          # job name
##BSUB -o ${JOBRND}.out                      # output filename
##BSUB -e ${JOBRND}.err                      # error filename
##BSUB -W ${WRFCHEM_TIME_LIMIT}               # wallclock time (minutes)
##BSUB -q ${WRFCHEM_JOB_CLASS}
##
#mpirun.lsf ./wrf.exe > index_wrfchem_${KMEM} 2>&1 
#export RC=\$?     
#rm -rf WRFCHEM_SUCCESS_*; fi     
#rm -rf WRFCHEM_FAILED_*; fi          
#if [[ \$RC = 0 ]]; then
#   touch WRFCHEM_SUCCESS_${RAN_APM}     
#else
#   touch WRFCHEM_FAILED_${RAN_APM} 
#   exit
#fi
#EOF
##
#      bsub < job.ksh 
#      let MEM=${MEM}+1
#   done
#
## Wait for WRFCHEM to complete for each member
#   ${HYBRID_SCRIPTS_DIR}/da_run_hold.ksh ${RAN_APM}
#fi
#
##########################################################################
##
## CALCULATE ENSEMBLE MEAN
##
##########################################################################
##
##
##########################################################################
##
## FIND ENSEMBLE MEMBER CLOSEST TO ENSEMBLE MEAN
##
##########################################################################
##
#   export CLOSE_MEM_ID=e001
##
##########################################################################
##
## INTERPOLATE CLOSEST MEMBER FROM COARS TO FINE GRID
##
##########################################################################
##
##
##########################################################################
##
## RUN WRFCHEM_CYCLE_FR
##
##########################################################################
##
#if ${RUN_WRFCHEM_CYCLE_FR}; then
#   if [[ ! -d ${RUN_DIR}/${DATE}/wrfchem_cycle_fr ]]; then
#      mkdir -p ${RUN_DIR}/${DATE}/wrfchem_cycle_fr
#      cd ${RUN_DIR}/${DATE}/wrfchem_cycle_fr
#   else
#      cd ${RUN_DIR}/${DATE}/wrfchem_cycle_fr
#   fi
#
# Get WRF-Chem parameter files
#   cp ${WRFCHEM_DIR}/test/em_real/wrf.exe ./.
#   cp ${WRFCHEM_DIR}/test/em_real/CAM_ABS_DATA ./.
#   cp ${WRFCHEM_DIR}/test/em_real/CAM_AEROPT_DATA ./.
#   cp ${WRFCHEM_DIR}/test/em_real/ETAMPNEW_DATA ./.
#   cp ${WRFCHEM_DIR}/test/em_real/GENPARM.TBL ./.
#   cp ${WRFCHEM_DIR}/test/em_real/LANDUSE.TBL ./.
#   cp ${WRFCHEM_DIR}/test/em_real/RRTMG_LW_DATA ./.
#   cp ${WRFCHEM_DIR}/test/em_real/RRTMG_SW_DATA ./.
#   cp ${WRFCHEM_DIR}/test/em_real/RRTM_DATA ./.
#   cp ${WRFCHEM_DIR}/test/em_real/SOILPARM.TBL ./.
#   cp ${WRFCHEM_DIR}/test/em_real/URBPARM.TBL ./.
#   cp ${WRFCHEM_DIR}/test/em_real/VEGPARM.TBL ./.
#   cp ${DART_DIR}/models/wrf_chem/run_scripts/hist_io_flds ./.
#
#   cp ${REAL_TIME_DIR}/clim_p_trop.nc ./.
#   cp ${REAL_TIME_DIR}/ubvals_b40.20th.track1_1996-2005.nc ./.
#   cp ${EXO_COLDENS_DIR}/exo_coldens_d${CR_DOMAIN} ./.
#   cp ${EXO_COLDENS_DIR}/exo_coldens_d${FR_DOMAIN} ./.
#   cp ${SEASONS_WES_DIR}/wrf_season_wes_usgs_d${CR_DOMAIN}.nc ./.
#   cp ${SEASONS_WES_DIR}/wrf_season_wes_usgs_d${FR_DOMAIN}.nc ./.
##
# Get WRF-Chem emissions files
#   cp ${WRFCHEM_BIO_DIR}/wrfbiochemi_d${CR_DOMAIN}_${START_FILE_DATE} wrfbiochemi_d${CR_DOMAIN}_${START_FILE_DATE}
#   cp ${WRFCHEM_BIO_DIR}/wrfbiochemi_d${FR_DOMAIN}_${START_FILE_DATE} wrfbiochemi_d${FR_DOMAIN}_${START_FILE_DATE}
#
#   cp ${WRFCHEM_CHEM_EMISS_DIR}/wrfbiochemi_d${CR_DOMAIN}_${START_FILE_DATE}.${CLOSE_MEM_ID} wrfbiochemi_d${CR_DOMAIN}_${START_FILE_DATE}
#   cp ${WRFCHEM_CHEM_EMISS_DIR}/wrfbiochemi_d${FR_DOMAIN}_${START_FILE_DATE}.${CLOSE_MEM_ID} wrfbiochemi_d${FR_DOMAIN}_${START_FILE_DATE}
#
#   export L_DATE=${START_DATE}
#   while [[ ${L_DATE} -le ${END_DATE} ]]; do
#      export L_YY=`echo ${L_DATE} | cut -c1-4`
#      export L_MM=`echo ${L_DATE} | cut -c5-6`
#      export L_DD=`echo ${L_DATE} | cut -c7-8`
#      export L_HH=`echo ${L_DATE} | cut -c9-10`
#      export L_FILE_DATE=${L_YY}-${L_MM}-${L_DD}_${L_HH}:00:00
##      cp ${WRFCHEM_FIRE_DIR}/wrffirechemi_d${CR_DOMAIN}_${L_FILE_DATE} wrffirechemi_d${CR_DOMAIN}_${L_FILE_DATE}
##      cp ${WRFCHEM_CHEMI_DIR}/wrfchemi_d${CR_DOMAIN}_${L_FILE_DATE} wrfchemi_d${CR_DOMAIN}_${L_FILE_DATE}
##      cp ${WRFCHEM_FIRE_DIR}/wrffirechemi_d${FR_DOMAIN}_${L_FILE_DATE} wrffirechemi_d${FR_DOMAIN}_${L_FILE_DATE}
##      cp ${WRFCHEM_CHEMI_DIR}/wrfchemi_d${FR_DOMAIN}_${L_FILE_DATE} wrfchemi_d${FR_DOMAIN}_${L_FILE_DATE}
##
#      cp ${WRFCHEM_CHEM_EMISS_DIR}/wrffirechemi_d${CR_DOMAIN}_${L_FILE_DATE}.${CLOSE_MEM_ID} wrffirechemi_d${CR_DOMAIN}_${L_FILE_DATE}
#      cp ${WRFCHEM_CHEM_EMISS_DIR}/wrfchemi_d${CR_DOMAIN}_${L_FILE_DATE}.${CLOSE_MEM_ID} wrfchemi_d${CR_DOMAIN}_${L_FILE_DATE}
#      cp ${WRFCHEM_CHEM_EMISS_DIR}/wrffirechemi_d${FR_DOMAIN}_${L_FILE_DATE}.${CLOSE_MEM_ID} wrffirechemi_d${FR_DOMAIN}_${L_FILE_DATE}
#      cp ${WRFCHEM_CHEM_EMISS_DIR}/wrfchemi_d${FR_DOMAIN}_${L_FILE_DATE}.${CLOSE_MEM_ID} wrfchemi_d${FR_DOMAIN}_${L_FILE_DATE}
###
#      export L_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} +1 2>/dev/null)
#   done
#
# Get WR-Chem input and bdy files
##   cp ${REAL_DIR}/wrfout_d${CR_DOMAIN}_${START_FILE_DATE}_filt wrfinput_d${CR_DOMAIN}
##   cp ${REAL_DIR}/wrfbdy_d${CR_DOMAIN}_${START_FILE_DATE}_filt wrfbdy_d${CR_DOMAIN}
##   cp ${REAL_DIR}/wrfout_d${FR_DOMAIN}_${START_FILE_DATE}_filt wrfinput_d${FR_DOMAIN}
##   cp ${WRFCHEM_CHEM_ICBC_DIR}/wrfinput_d${CR_DOMAIN}_${START_FILE_DATE} wrfinput_d${CR_DOMAIN}
##   cp ${WRFCHEM_CHEM_ICBC_DIR}/wrfbdy_d${CR_DOMAIN}_${START_FILE_DATE} wrfbdy_d${CR_DOMAIN}
##   cp ${WRFCHEM_CHEM_ICBC_DIR}/wrfinput_d${FR_DOMAIN}_${START_FILE_DATE} wrfinput_d${FR_DOMAIN}
#   cp ${DART_FILTER_DIR}/wrfout_d${CR_DOMAIN}_${START_FILE_DATE}_filt.${CLOSE_MEM_ID} wrfinput_d${CR_DOMAIN}
#   cp ${UPDATE_BC_DIR}/wrfbdy_d${CR_DOMAIN}_${START_FILE_DATE}_filt.${CLOSE_MEM_ID} wrfbdy_d${CR_DOMAIN}
#   cp ${REAL_DIR}/wrfinput_d${FR_DOMAIN}_${START_FILE_DATE} wrfinput_d${FR_DOMAIN}
#
#
# Create WRF-Chem namelist.input 
#   export NL_MAX_DOM=2
#   rm -rf namelist.input
#   ${HYBRID_SCRIPTS_DIR}/da_create_wrfchem_namelist_nested_RT.ksh
#
# Create job script for this member and run it 
#   rm -rf job.ksh
#   touch job.ksh
#   RANDOM=$$
#   export JOBRND=advm_${RANDOM}
#   cat << EOF >job.ksh
##!/bin/ksh -aeux
##BSUB -P ${PROJ_NUMBER}
##BSUB -x                                    # exclusive use of node (not_shared)
##BSUB -n ${WRFCHEM_NUM_TASKS}                       # number of total (MPI) tasks
##BSUB -R "span[ptile=${WRFCHEM_TASKS_PER_NODE}]"    # mpi tasks per node
##BSUB -J ${JOBRND}                          # job name
##BSUB -o ${JOBRND}.out                      # output filename
##BSUB -e ${JOBRND}.err                      # error filename
##BSUB -W ${WRFCHEM_TIME_LIMIT}               # wallclock time (minutes)
##BSUB -q ${WRFCHEM_JOB_CLASS}
##
#mpirun.lsf ./wrf.exe > index_wrfchem 2>&1 
#export RC=\$?     
#rm -rf WRFCHEM_SUCCESS; fi     
#rm -rf WRFCHEM_FAILED; fi          
#if [[ \$RC = 0 ]]; then
#   touch WRFCHEM_SUCCESS
#else
#   touch WRFCHEM_FAILED 
#   exit
#fi
#EOF
##
#   bsub < job.ksh 
##
#fi
##
