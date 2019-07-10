#!/bin/ksh -x
#
# DART software - Copyright UCAR. This open source software is provided
# by UCAR, "as is", without charge, subject to all terms of use at
# http://www.image.ucar.edu/DAReS/DART/DART_download
#
# $Id$
#

###############################################################################
#
#  Script to run obs_seq_to_netcdf for WRFCHEM in the DART framework
#
############################################################################### 
#
# Define experiment parameters
export START_DATE=2014072006
export END_DATE=2014072006
export DOMAIN=01
export NUM_MEMBERS=10
export CYCLE_PERIOD=6
export FCST_PERIOD=6
export ASIM_PERIOD=3
export LBC_FREQ=3
export DART_FILTER_NAME=dart_filter_iasi_co_rawr
export DART_FILTER_NAME=dart_filter_iasi_co_log
export DART_FILTER_NAME=dart_filter
(( INTERVAL_SEC=${LBC_FREQ}*60*60 ))
(( CYCLE_PERIOD_SEC=${CYCLE_PERIOD}*60*60 ))
#
# Define use options
export ADD_EMISS=.false.
export VARLOC=.false.
export INDEP_CHEM_ASIM=.true.
export EMISS_DAMP_CYCLE=0.5
export EMISS_DAMP_INTRA_CYCLE=0.5
export NL_MOPITT_CO_RETRIEVAL_TYPE=RETR
export NL_IASI_CO_RETRIEVAL_TYPE=RETR
export NL_IASI_O3_RETRIEVAL_TYPE=RETR
#
# Define code versions
export DART_VER=DART_CHEM_REPOSITORY
export WRFCHEM_VER=WRFCHEMv3.4_dmpar
export WRF_VER=WRFv3.4_dmpar
export WRFDA_VER=WRFDAv3.4_dmpar
#
# Define independent directory paths
#
export DIR_NAME=real_FRAPPE_RETR_AIR_CO
export TRUNK_DIR=/glade/p/work/mizzi/TRUNK
export SCRATCH_DIR=/glade/scratch/mizzi
export ACD_DIR=/glade/p/acd/mizzi
export FRAPPE_DIR=/glade/p/FRAPPE/FINAL
#
#
# Dependent path settings
export EXP_DIR=${FRAPPE_DIR}/${DIR_NAME}
export RUN_DIR=${SCRATCH_DIR}/DART_OBS_DIAG/${DIR_NAME}/${DART_FILTER_NAME}
#
export DART_DIR=${TRUNK_DIR}/${DART_VER}
export WRF_DIR=${TRUNK_DIR}/${WRF_VER}
export WRFCHEM_DIR=${TRUNK_DIR}/${WRFCHEM_VER}
export WRFDA_DIR=${TRUNK_DIR}/${WRFDA_VER}/var
#
# Copy necessary executables from DART to $RUN_DIR
if [[ ! -d ${RUN_DIR} ]]; then mkdir -p ${RUN_DIR}; fi
cd ${RUN_DIR}
cp ${DART_DIR}/models/wrf_chem/work/input.nml ./.
cp ${DART_DIR}/models/wrf_chem/work/advance_time ./.
cp ${DART_DIR}/models/wrf_chem/work/obs_seq_to_netcdf ./.
#
# Build obs_seq.final file list
cd ${RUN_DIR}
rm -rf file_list.txt
export L_DATE=${START_DATE}
while [[ ${L_DATE} -le ${END_DATE} ]]; do
#
# Set date/time information
   export L_YY=`echo $L_DATE | cut -c1-4`
   export L_MM=`echo $L_DATE | cut -c5-6`
   export L_DD=`echo $L_DATE | cut -c7-8`
   export L_HH=`echo $L_DATE | cut -c9-10`
   export L_FILE_DATE=${L_YY}-${L_MM}-${L_DD}_${L_HH}:00:00
#
   export NEXT_DATE=`echo ${L_DATE} +${FCST_PERIOD}h | ./advance_time` 
   export NEXT_YY=`echo $NEXT_DATE | cut -c1-4`
   export NEXT_MM=`echo $NEXT_DATE | cut -c5-6`
   export NEXT_DD=`echo $NEXT_DATE | cut -c7-8`
   export NEXT_HH=`echo $NEXT_DATE | cut -c9-10`
   export NEXT_FILE_DATE=${NEXT_YY}-${NEXT_MM}-${NEXT_DD}_${NEXT_HH}:00:00
#
# Create obs_seq file list
   export FILE=obs_seq.final
   if [[ -f ${EXP_DIR}/${L_DATE}/${DART_FILTER_NAME}/${FILE} ]]; then
      echo ${EXP_DIR}/${L_DATE}/${DART_FILTER_NAME}/${FILE} >> file_list.txt
   else
      echo APM: traget file ${EXP_DIR}/${L_DATE}/${DART_FILTER_NAME}/${FILE} does not exist
      exit
   fi
#
# Loop to next cycle time   
   export L_DATE=${NEXT_DATE}
done
#
###############################################################################
#
# CREATE DART NAMELIST
#
###############################################################################
export STR_YY=`echo $START_DATE | cut -c1-4`
export STR_MM=`echo $START_DATE | cut -c5-6`
export STR_DD=`echo $START_DATE | cut -c7-8`
export STR_HH=`echo $START_DATE | cut -c9-10`
#
export END_YY=`echo $END_DATE | cut -c1-4`
export END_MM=`echo $END_DATE | cut -c5-6`
export END_DD=`echo $END_DATE | cut -c7-8`
export END_HH=`echo $END_DATE | cut -c9-10`
#
export ASIM_MIN_DATE_STR=`echo ${START_DATE} -${ASIM_PERIOD}h | ./advance_time` 
export ASIM_MIN_YY_STR=`echo $ASIM_MIN_DATE_STR | cut -c1-4`
export ASIM_MIN_MM_STR=`echo $ASIM_MIN_DATE_STR | cut -c5-6`
export ASIM_MIN_DD_STR=`echo $ASIM_MIN_DATE_STR | cut -c7-8`
export ASIM_MIN_HH_STR=`echo $ASIM_MIN_DATE_STR | cut -c9-10`
export ASIM_MAX_DATE_STR=`echo ${START_DATE} +${ASIM_PERIOD}h | ./advance_time` 
export ASIM_MAX_YY_STR=`echo $ASIM_MAX_DATE_STR | cut -c1-4`
export ASIM_MAX_MM_STR=`echo $ASIM_MAX_DATE_STR | cut -c5-6`
export ASIM_MAX_DD_STR=`echo $ASIM_MAX_DATE_STR | cut -c7-8`
export ASIM_MAX_HH_STR=`echo $ASIM_MAX_DATE_STR | cut -c9-10`
#
export ASIM_MIN_DATE_END=`echo ${END_DATE} -${ASIM_PERIOD}h | ./advance_time` 
export ASIM_MIN_YY_END=`echo $ASIM_MIN_DATE_END | cut -c1-4`
export ASIM_MIN_MM_END=`echo $ASIM_MIN_DATE_END | cut -c5-6`
export ASIM_MIN_DD_END=`echo $ASIM_MIN_DATE_END | cut -c7-8`
export ASIM_MIN_HH_END=`echo $ASIM_MIN_DATE_END | cut -c9-10`
export ASIM_MAX_DATE_END=`echo ${END_DATE} +${ASIM_PERIOD}h | ./advance_time` 
export ASIM_MAX_YY_END=`echo $ASIM_MAX_DATE_END | cut -c1-4`
export ASIM_MAX_MM_END=`echo $ASIM_MAX_DATE_END | cut -c5-6`
export ASIM_MAX_DD_END=`echo $ASIM_MAX_DATE_END | cut -c7-8`
export ASIM_MAX_HH_END=`echo $ASIM_MAX_DATE_END | cut -c9-10`
(( STR_MM = ${STR_MM} + 0 ))
(( STR_DD = ${STR_DD} + 0 ))
(( STR_HH = ${STR_HH} + 0 ))     
(( END_MM = ${END_MM} + 0 ))
(( END_DD = ${END_DD} + 0 ))
(( END_HH = ${END_HH} + 0 ))     
(( ASIM_MIN_MM_STR = ${ASIM_MIN_MM_STR} + 0 ))
(( ASIM_MIN_DD_STR = ${ASIM_MIN_DD_STR} + 0 ))
(( ASIM_MIN_HH_STR = ${ASIM_MIN_HH_STR} + 0 ))
(( ASIM_MAX_MM_STR = ${ASIM_MAX_MM_STR} + 0 ))
(( ASIM_MAX_DD_STR = ${ASIM_MAX_DD_STR} + 0 ))
(( ASIM_MAX_HH_STR = ${ASIM_MAX_HH_STR} + 0 ))
(( ASIM_MIN_MM_END = ${ASIM_MIN_MM_END} + 0 ))
(( ASIM_MIN_DD_END = ${ASIM_MIN_DD_END} + 0 ))
(( ASIM_MIN_HH_END = ${ASIM_MIN_HH_END} + 0 ))
(( ASIM_MAX_MM_END = ${ASIM_MAX_MM_END} + 0 ))
(( ASIM_MAX_DD_END = ${ASIM_MAX_DD_END} + 0 ))
(( ASIM_MAX_HH_END = ${ASIM_MAX_HH_END} + 0 ))
#
# &obs_diag_nml
export NL_OBS_SEQUENCE_NAME="''"
export NL_OBS_SEQUENCE_LIST="'file_list.txt'"
export NL_FIRST_BIN_CENTER_YY=${STR_YY}
export NL_FIRST_BIN_CENTER_MM=${STR_MM}
export NL_FIRST_BIN_CENTER_DD=${STR_DD}
export NL_FIRST_BIN_CENTER_HH=${STR_HH}
export NL_FIRST_BIN_CENTER_MN=0
export NL_FIRST_BIN_CENTER_SS=0
export NL_LAST_BIN_CENTER_YY=${END_YY}
export NL_LAST_BIN_CENTER_MM=${END_MM}
export NL_LAST_BIN_CENTER_DD=${END_DD}
export NL_LAST_BIN_CENTER_HH=${END_HH}
export NL_LAST_BIN_CENTER_MN=0
export NL_LAST_BIN_CENTER_SS=0
export NL_BIN_SEPARATION_YY=0
export NL_BIN_SEPARATION_MM=0
export NL_BIN_SEPARATION_DD=0
export NL_BIN_SEPARATION_HH=6
export NL_BIN_SEPARATION_MN=0
export NL_BIN_SEPARATION_SS=0
export NL_BIN_WIDTH_YY=0
export NL_BIN_WIDTH_MM=0
export NL_BIN_WIDTH_DD=0
export NL_BIN_WIDTH_HH=6
export NL_BIN_WIDTH_MN=0
export NL_BIN_WIDTH_SS=0
export NL_TIME_TO_SKIP_YY=0
export NL_TIME_TO_SKIP_MM=0
export NL_TIME_TO_SKIP_DD=0
export NL_TIME_TO_SKIP_HH=0
export NL_TIME_TO_SKIP_MN=0
export NL_TIME_TO_SKIP_SS=0
export NL_MAX_NUM_BINS=1000
#export NL_PLEVEL_EDGES=1020,1000,950,850,750,650,550,450,350,250,150,50
export NL_NREGIONS=1
export NL_LATLIM1=-90.
export NL_LATLIM2=90.
export NL_LONLIM1=0.
export NL_LONLIM2=360.
export NL_REG_NAMES="'Entire Domain'"
export NL_PRINT_MISMATCHED_LOCS=.false.
export NL_PRINT_OBS_LOCATIONS=.false.
export NL_VERBOSE=.false.
#
# &schedule_nml
export NL_CALENDAR="'Gregorian'"
export NL_FIRST_BIN_START_YY=${ASIM_MIN_YY_STR}
export NL_FIRST_BIN_START_MM=${ASIM_MIN_MM_STR}
export NL_FIRST_BIN_START_DD=${ASIM_MIN_DD_STR}
export NL_FIRST_BIN_START_HH=${ASIM_MIN_HH_STR}
export NL_FIRST_BIN_START_MN=0
export NL_FIRST_BIN_START_SS=0
export NL_FIRST_BIN_END_YY=${ASIM_MAX_YY_STR}
export NL_FIRST_BIN_END_MM=${ASIM_MAX_MM_STR}
export NL_FIRST_BIN_END_DD=${ASIM_MAX_DD_STR}
export NL_FIRST_BIN_END_HH=${ASIM_MAX_HH_STR}
export NL_FIRST_BIN_END_MN=0
export NL_FIRST_BIN_END_SS=0
export NL_LAST_BIN_START_YY=${ASIM_MIN_YY_END}
export NL_LAST_BIN_START_MM=${ASIM_MIN_MM_END}
export NL_LAST_BIN_START_DD=${ASIM_MIN_DD_END}
export NL_LAST_BIN_START_HH=${ASIM_MIN_HH_END}
export NL_LAST_BIN_START_MN=0
export NL_LAST_BIN_START_SS=0
export NL_LAST_BIN_END_YY=${ASIM_MAX_YY_END}
export NL_LAST_BIN_END_MM=${ASIM_MAX_MM_END}
export NL_LAST_BIN_END_DD=${ASIM_MAX_DD_END}
export NL_LAST_BIN_END_HH=${ASIM_MAX_HH_END}
export NL_LAST_BIN_END_MN=0
export NL_LAST_BIN_END_SS=0
export NL_BIN_INTERVAL_DAYS=0
export NL_BIN_INTERVAL_SECONDS=21600
export NL_MAX_NUMBER_BINS=1000
export NL_PRINT_TABLE=.false.
#
# obs_seq_to_netcdf_nml
export NL_OBS_SEQUENCE_NAME="''"
export NL_OBS_SEQUENCE_LIST="'file_list.txt'"
export NL_APPEND_TO_NETCDF=.false.
export NL_LATLIM1=-90.0
export NL_LATLIM2=90.0
export NL_LONLIM1=0.
export NL_LONLIM2=360.0
export NL_VERBOSE=.false.
#
# &assim_tools_nml
   export NL_CUTOFF=0.1
   export NL_SPECIAL_LOCALIZATION_OBS_TYPES="'IASI_O3_RETRIEVAL','IASI_CO_RETRIEVAL','MOPITT_CO_RETRIEVAL'"
   export NL_SPECIAL_LOCALIZATION_CUTOFFS=0.05,0.05,0.05
#
# &ensemble_manager_nml
   export NL_SINGLE_RESTART_FILE_IN=.false.       
   export NL_SINGLE_RESTART_FILE_OUT=.false.       
#
# &assim_model_nml
#
# &model_nml
export NL_ADD_EMISS=${ADD_EMISS}
export NL_USE_VARLOC=${VARLOC}
export NL_USE_INDEP_CHEM_ASSIM=${INDEP_CHEM_ASIM}
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
          'PSFC',  'KIND_PRESSURE',             'TYPE_PS', 'UPDATE','999',
          'o3',    'KIND_O3',                   'TYPE_O3', 'UPDATE','999',
          'co',    'KIND_CO',                   'TYPE_CO', 'UPDATE','999',
          'no',    'KIND_NO',                   'TYPE_NO', 'UPDATE','999',
          'no2',   'KIND_NO2',                  'TYPE_NO2', 'UPDATE','999',
          'hno3',  'KIND_HNO3',                 'TYPE_HNO3', 'UPDATE','999',
          'hno4',  'KIND_HNO4',                 'TYPE_HNO4', 'UPDATE','999',
          'n2o5',  'KIND_N2O5',                 'TYPE_N2O5', 'UPDATE','999',
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
          'c3h8',  'KIND_C3H8',                 'TYPE_C3H8', 'UPDATE','999',
          'c10h16','KIND_C10H16',               'TYPE_C10H16', 'UPDATE','999',
          'DUST_1','KIND_DST01',                'TYPE_DST01','UPDATE','999',
          'DUST_2','KIND_DST02',                'TYPE_DST02','UPDATE','999',
          'DUST_3','KIND_DST03',                'TYPE_DST03','UPDATE','999',
          'DUST_4','KIND_DST04',                'TYPE_DST04','UPDATE','999',
          'DUST_5','KIND_DST05',                'TYPE_DST05','UPDATE','999',
          'BC1','KIND_CB1',                     'TYPE_EXTCOF','UPDATE','999',
          'BC2','KIND_CB2',                     'TYPE_EXTCOF','UPDATE','999',
          'OC1','KIND_OC1',                     'TYPE_EXTCOF','UPDATE','999',
          'OC2','KIND_OC2',                     'TYPE_EXTCOF','UPDATE','999',
          'sulf','KIND_SO4',                    'TYPE_SO4'   ,'UPDATE','999',
          'TAUAER1','KIND_TAUAER1',             'TYPE_EXTCOF','UPDATE','999',
          'TAUAER2','KIND_TAUAER2',             'TYPE_EXTCOF','UPDATE','999',
          'TAUAER3','KIND_TAUAER3',             'TYPE_EXTCOF','UPDATE','999',
          'TAUAER4','KIND_TAUAER4',             'TYPE_EXTCOF','UPDATE','999',
          'PM10','KIND_PM10',                   'TYPE_EXTCOF','UPDATE','999',
          'PM2_5_DRY','KIND_PM25' ,             'TYPE_EXTCOF','UPDATE','999',
          'P10','KIND_PM10',                    'TYPE_EXTCOF','UPDATE','999',
          'P25','KIND_PM25',                    'TYPE_EXTCOF','UPDATE','999',
          'SEAS_1','KIND_SSLT01',               'TYPE_EXTCOF','UPDATE','999',
          'SEAS_2','KIND_SSLT02',               'TYPE_EXTCOF','UPDATE','999',
          'SEAS_3','KIND_SSLT03',               'TYPE_EXTCOF','UPDATE','999',
          'SEAS_4','KIND_SSLT04',               'TYPE_EXTCOF','UPDATE','999'"
export NL_EMISS_CHEMI_VARIABLES="'E_CO',     'KIND_E_CO',     'TYPE_E_CO',     'UPDATE','999',
          'E_NO'        ,'KIND_E_NO',           'TYPE_E_NO',  'UPDATE','999'"
export NL_EMISS_FIRECHEMI_VARIABLES="'ebu_in_co'   ,'KIND_EBU_CO',         'TYPE_EBU_CO',  'UPDATE','999',
          'ebu_in_no'    ,'KIND_EBU_NO',         'TYPE_EBU_NO',   'UPDATE','999',
          'ebu_in_oc'    ,'KIND_EBU_OC',         'TYPE_EBU_OC',   'UPDATE','999',
          'ebu_in_bc'    ,'KIND_EBU_BC',         'TYPE_EBU_BC',   'UPDATE','999',
          'ebu_in_c2h4'  ,'KIND_EBU_c2h4',       'TYPE_EBU_c2h4', 'UPDATE','999',
          'ebu_in_ch2o'  ,'KIND_EBU_ch2o',       'TYPE_EBU_ch2o', 'UPDATE','999',
          'ebu_in_ch3oh' ,'KIND_EBU_ch3oh',      'TYPE_EBU_ch3oh','UPDATE','999'"
export NL_WRF_STATE_BOUNDS="'QVAPOR','0.0','NULL','CLAMP',
          'QRAIN', '0.0','NULL','CLAMP',
          'QCLOUD','0.0','NULL','CLAMP',
          'QSNOW', '0.0','NULL','CLAMP',
          'QICE',  '0.0','NULL','CLAMP',
          'o3',    '0.0','NULL','CLAMP',
          'co',    '${CO_MIN}','${CO_MAX}','CLAMP',
          'no',    '0.0','NULL','CLAMP',
          'no2',   '0.0','NULL','CLAMP',
          'hno3',  '0.0','NULL','CLAMP',
          'hno4',  '0.0','NULL','CLAMP',
          'n2o5',  '0.0','NULL','CLAMP',
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
          'c3h8'  ,'0.0','NULL','CLAMP',    
          'c10h16','0.0','NULL','CLAMP',
          'DUST_1','0.0','NULL','CLAMP',
          'DUST_2','0.0','NULL','CLAMP',
          'DUST_3','0.0','NULL','CLAMP',
          'DUST_4','0.0','NULL','CLAMP',
          'DUST_5','0.0','NULL','CLAMP',
          'BC1','0.0','NULL','CLAMP',
          'BC2','0.0','NULL','CLAMP',
          'OC1','0.0','NULL','CLAMP',
          'OC2','0.0','NULL','CLAMP',
          'sulf','0.0','NULL','CLAMP',
          'TAUAER1','0.0','NULL','CLAMP',
          'TAUAER2','0.0','NULL','CLAMP',
          'TAUAER3','0.0','NULL','CLAMP',
          'TAUAER4','0.0','NULL','CLAMP',
          'PM10','0.0','NULL','CLAMP',
          'PM2_5_DRY','0.0','NULL','CLAMP',
          'P10','0.0','NULL','CLAMP',
          'P25','0.0','NULL','CLAMP',
          'SEAS_1','0.0','NULL','CLAMP',
          'SEAS_2','0.0','NULL','CLAMP',
          'SEAS_3','0.0','NULL','CLAMP',
          'SEAS_4','0.0','NULL','CLAMP',
          'E_CO','0.0','NULL','CLAMP',
          'E_NO','0.0','NULL','CLAMP',
          'ebu_in_co','0.0','NULL','CLAMP',
          'ebu_in_no','0.0','NULL','CLAMP',
          'ebu_in_oc','0.0','NULL','CLAMP',
          'ebu_in_bc','0.0','NULL','CLAMP',
          'ebu_in_c2h4','0.0','NULL','CLAMP',
          'ebu_in_ch2o','0.0','NULL','CLAMP',
          'ebu_in_ch3oh','0.0','NULL','CLAMP'"
export NL_OUTPUT_STATE_VECTOR=.false.
export NL_NUM_DOMAINS=${DOMAIN}
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
# &restart_file_utility_nml
   export NL_SINGLE_RESTART_FILE_IN=.false.       
   export NL_SINGLE_RESTART_FILE_OUT=.false.       
#
# &dart_to_wrf_nml
   export NL_MODEL_ADVANCE_FILE=.false.
   export NL_ADV_MOD_COMMAND="'mpirun -np 64 ./wrf.exe'"
   export NL_DART_RESTART_NAME="'dart_wrf_vector'"
#
# &preprocess_nml
   export NL_INPUT_OBS_KIND_MOD_FILE="'${DART_DIR}/obs_kind/DEFAULT_obs_kind_mod.F90'"
   export NL_OUTPUT_OBS_KIND_MOD_FILE="'${DART_DIR}/obs_kind/obs_kind_mod.f90'"
   export NL_INPUT_OBS_DEF_MOD_FILE="'${DART_DIR}/obs_kind/DEFAULT_obs_def_mod.F90'"
   export NL_OUTPUT_OBS_DEF_MOD_FILE="'${DART_DIR}/obs_kind/obs_def_mod.f90'"
   export NL_INPUT_FILES="'${DART_DIR}/obs_def/obs_def_reanalysis_bufr_mod.f90',
                       '${DART_DIR}/obs_def/obs_def_radar_mod.f90',
                       '${DART_DIR}/obs_def/obs_def_metar_mod.f90',
                       '${DART_DIR}/obs_def/obs_def_dew_point_mod.f90',
                       '${DART_DIR}/obs_def/obs_def_altimeter_mod.f90',
                       '${DART_DIR}/obs_def/obs_def_gps_mod.f90',
                       '${DART_DIR}/obs_def/obs_def_gts_mod.f90',
                       '${DART_DIR}/obs_def/obs_def_vortex_mod.f90',
                       '${DART_DIR}/obs_def/obs_def_IASI_O3_mod.f90',
                       '${DART_DIR}/obs_def/obs_def_IASI_CO_mod.f90',
                       '${DART_DIR}/obs_def/obs_def_MOPITT_CO_mod.f90'"
#
# &obs_kind_nml
export NL_ASSIMILATE_THESE_OBS_TYPES="'IASI_CO_RETRIEVAL'"
#export NL_ASSIMILATE_THESE_OBS_TYPES="'MOPITT_CO_RETRIEVAL'"
#export NL_ASSIMILATE_THESE_OBS_TYPES="'IASI_O3_RETRIEVAL'"
#export NL_ASSIMILATE_THESE_OBS_TYPES="'AIRNOW_CO'"
#export NL_ASSIMILATE_THESE_OBS_TYPES="'RADIOSONDE_TEMPERATURE',
#                                   'RADIOSONDE_U_WIND_COMPONENT',
#                                   'RADIOSONDE_V_WIND_COMPONENT',
#                                   'RADIOSONDE_SPECIFIC_HUMIDITY',
#                                   'ACARS_U_WIND_COMPONENT',
#                                   'ACARS_V_WIND_COMPONENT',
#                                   'ACARS_TEMPERATURE',
#                                   'AIRCRAFT_U_WIND_COMPONENT',
#                                   'AIRCRAFT_V_WIND_COMPONENT',
#                                   'AIRCRAFT_TEMPERATURE',
#                                   'SAT_U_WIND_COMPONENT',
#                                   'SAT_V_WIND_COMPONENT',
#                                   'AIRNOW_CO'"
#                                   'MOPITT_CO_RETRIEVAL',
#                                   'IASI_CO_RETRIEVAL',
#                                   'IASI_O3_RETRIEVAL',
#                                   'MODIS_AOD_RETRIEVAL',
#                                   'AIRNOW_O3',
#                                   'OMI_NO2_COLUMN'"
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
rm -rf input.nml
${DART_DIR}/models/wrf_chem/namelist_scripts/DART/dart_create_input.nml.ksh
#
###############################################################################
#
# RUN OBS_SEQ_to_NETCDF
#
###############################################################################
#
cd ${RUN_DIR}
./obs_seq_to_netcdf
#
# 
exit


#
# <next few lines under version control, do not edit>
# $URL$
# $Id$
# $Revision$
# $Date$
