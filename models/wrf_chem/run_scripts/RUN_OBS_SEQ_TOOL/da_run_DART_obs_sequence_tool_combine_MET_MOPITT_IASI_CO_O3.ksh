#!/bin/ksh -aeux 
#
set echo
# 
# Script to combine multiple obs_seq files into a single obs_seq file
#
# SET TIME INFORMATION
  export START_DATE=2008060106
#  export END_DATE=2008063018
  export END_DATE=2008060918
  export TIME_INC=6
  export ASIM_WINDOW=3
#
# SYSTEM SPECIFIC SETTINGS
  export PROCS=8
#
# PATHS
  export WRFDA_VER=WRFDAv3.4_dmpar
  export WRF_VER=WRFv3.4_dmpar
  export DART_VER=DART_CHEM_MY_BRANCH
#
# INDEPENDENT DIRECTORIES
  export ROOT_DIR=/glade/p/work/mizzi
  export CODE_DIR=/glade/p/work/mizzi/TRUNK
  export DATA_DIR=/glade/p/acd/mizzi/AVE_TEST_DATA
  export ASIM_DIR=/glade/scratch/mizzi/MET_MOP_IAS_COMB
#
##  export RET_MOPITT_OBS_DIR=${DATA_DIR}/obs_MOPITT_CO_RAWR_NO_ROT_SUPR
##  export RET_IASI_CO_OBS_DIR=${DATA_DIR}/obs_IASI_CO_RAWR_NO_ROT_SUPR
##  export RET_IASI_O3_OBS_DIR=${DATA_DIR}/obs_IASI_O3_RETR_f1p0
##  export WRITE_OUT_NAME=obs_MOPnIAS_CO_O3_RAWR_NO_ROT_SUPR
#
##  export RET_MOPITT_OBS_DIR=${DATA_DIR}/obs_MOPITT_CO_RAWR_F50_NO_ROT_SUPR
##  export RET_IASI_CO_OBS_DIR=${DATA_DIR}/obs_IASI_CO_RAWR_F50_NO_ROT_SUPR
##  export RET_IASI_O3_OBS_DIR=${DATA_DIR}/obs_IASI_O3_RETR_f1p0
##  export WRITE_OUT_NAME=obs_MOPnIAS_CO_O3_RAWR_F50_NO_ROT_SUPR
#
##  export RET_MOPITT_OBS_DIR=${DATA_DIR}/obs_MOPITT_CO_RETR_NO_ROT_SUPR
##  export RET_IASI_CO_OBS_DIR=${DATA_DIR}/obs_IASI_CO_RAWR_NO_ROT_SUPR
##  export RET_IASI_O3_OBS_DIR=${DATA_DIR}/obs_IASI_O3_RETR_f1p0
##  export WRITE_OUT_NAME=obs_MOPnIAS_CO_O3_RETR_NO_ROT_SUPR
#
##  export RET_MOPITT_OBS_DIR=${DATA_DIR}/obs_MOPITT_CO_RETR_NO_ROT_SUPR
##  export RET_IASI_CO_OBS_DIR=${DATA_DIR}/obs_IASI_CO_RAWR_F10_NO_ROT_SUPR
##  export RET_IASI_O3_OBS_DIR=${DATA_DIR}/obs_IASI_O3_RETR_f1p0
##  export WRITE_OUT_NAME=obs_MOPnIAS_CO_O3_RETR_F10_NO_ROT_SUPR
#
##  export RET_MOPITT_OBS_DIR=${DATA_DIR}/obs_MOPITT_CO_RETR_NO_ROT_SUPR
##  export RET_IASI_CO_OBS_DIR=${DATA_DIR}/obs_IASI_CO_RAWR_F05_NO_ROT_SUPR
##  export RET_IASI_O3_OBS_DIR=${DATA_DIR}/obs_IASI_O3_RETR_f1p0
##  export WRITE_OUT_NAME=obs_MOPnIAS_CO_O3_RETR_F05_NO_ROT_SUPR
#
##  export RET_MOPITT_OBS_DIR=${DATA_DIR}/obs_MOPITT_CO_RETR_NO_ROT_SUPR
##  export RET_IASI_CO_OBS_DIR=${DATA_DIR}/obs_IASI_CO_RAWR_F25_NO_ROT_SUPR
##  export RET_IASI_O3_OBS_DIR=${DATA_DIR}/obs_IASI_O3_RETR_f1p0
##  export WRITE_OUT_NAME=obs_MOPnIAS_CO_O3_RETR_F25_NO_ROT_SUPR
#
##  export RET_MOPITT_OBS_DIR=${DATA_DIR}/obs_MOPITT_CO_RETR_QOR_NO_ROT_SUPR
##  export RET_IASI_CO_OBS_DIR=${DATA_DIR}/obs_IASI_CO_RAWR_QOR_NO_ROT_SUPR
##  export RET_IASI_O3_OBS_DIR=${DATA_DIR}/obs_IASI_O3_RETR_f1p0
##  export WRITE_OUT_NAME=obs_MOPnIAS_CO_O3_RETR_QOR_NO_ROT_SUPR
#
##  export RET_MOPITT_OBS_DIR=${DATA_DIR}/obs_MOPITT_CO_RETR_QOR_NO_SCALE_SUPR
##  export RET_IASI_CO_OBS_DIR=${DATA_DIR}/obs_IASI_CO_RAWR_QOR_NO_SCALE_SUPR
##  export RET_IASI_O3_OBS_DIR=${DATA_DIR}/obs_IASI_O3_RETR_f1p0
##  export WRITE_OUT_NAME=obs_MOPnIAS_CO_O3_RETR_QOR_NO_SCALE_SUPR
#
##  export RET_MOPITT_OBS_DIR=${DATA_DIR}/obs_MOPITT_CO_RETR_QOR_SCALE_SUPR
##  export RET_IASI_CO_OBS_DIR=${DATA_DIR}/obs_IASI_CO_RAWR_QOR_SCALE_SUPR
##  export RET_IASI_O3_OBS_DIR=${DATA_DIR}/obs_IASI_O3_RETR_f1p0
##  export WRITE_OUT_NAME=obs_MOPnIAS_CO_O3_RETR_QOR_SCALE_SUPR
#
##  export RET_MOPITT_OBS_DIR=${DATA_DIR}/obs_MOPITT_CO_RETR_CPSR_NO_SCALE_SUPR
##  export RET_IASI_CO_OBS_DIR=${DATA_DIR}/obs_IASI_CO_RAWR_CPSR_NO_SCALE_SUPR
##  export RET_IASI_O3_OBS_DIR=${DATA_DIR}/obs_IASI_O3_RETR_f1p0
##  export WRITE_OUT_NAME=obs_MOPnIAS_CO_O3_RETR_CPSR_NO_SCALE_SUPR
#
##  export RET_MOPITT_OBS_DIR=${DATA_DIR}/obs_MOPITT_CO_RETR_CPSR_SCALE_SUPR
##  export RET_IASI_CO_OBS_DIR=${DATA_DIR}/obs_IASI_CO_RAWR_CPSR_SCALE_SUPR
##  export RET_IASI_O3_OBS_DIR=${DATA_DIR}/obs_IASI_O3_RETR_f1p0
##  export WRITE_OUT_NAME=obs_MOPnIAS_CO_O3_RETR_CPSR_SCALE_SUPR
#
##  export RET_MOPITT_OBS_DIR=${DATA_DIR}/obs_MOPITT_CO_RETR_CPSR_SCALE_SUPR
##  export RET_IASI_CO_OBS_DIR=${DATA_DIR}/obs_IASI_CO_RAWR_F25_CPSR_SCALE_SUPR
##  export RET_IASI_O3_OBS_DIR=${DATA_DIR}/obs_IASI_O3_RETR_f1p0
##  export WRITE_OUT_NAME=obs_MOPnIAS_CO_O3_RETR_F25_CPSR_SCALE_SUPR
#
##  export RET_MOPITT_OBS_DIR=${DATA_DIR}/obs_MOPITT_CO_RETR_CPSR_SCALE_SUPR
##  export RET_IASI_CO_OBS_DIR=${DATA_DIR}/obs_IASI_CO_RAWR_F10_CPSR_SCALE_SUPR
##  export RET_IASI_O3_OBS_DIR=${DATA_DIR}/obs_IASI_O3_RETR_f1p0
##  export WRITE_OUT_NAME=obs_MOPnIAS_CO_O3_RETR_F10_CPSR_SCALE_SUPR
#
##  export RET_MOPITT_OBS_DIR=${DATA_DIR}/obs_MOPITT_CO_RETR_CPSR_SCALE_SUPR
##  export RET_IASI_CO_OBS_DIR=${DATA_DIR}/obs_IASI_CO_RAWR_F05_CPSR_SCALE_SUPR
##  export RET_IASI_O3_OBS_DIR=${DATA_DIR}/obs_IASI_O3_RETR_f1p0
##  export WRITE_OUT_NAME=obs_MOPnIAS_CO_O3_RETR_F05_CPSR_SCALE_SUPR
#
##  export RET_MOPITT_OBS_DIR=${DATA_DIR}/obs_MOPITT_CO_RETR_CPSR_SCALE_BLOC_SUPR
##  export RET_IASI_CO_OBS_DIR=${DATA_DIR}/obs_IASI_CO_RAWR_CPSR_SCALE_SUPR
##  export RET_IASI_O3_OBS_DIR=${DATA_DIR}/obs_IASI_O3_RETR_f1p0
##  export WRITE_OUT_NAME=obs_MOPnIAS_CO_O3_RETR_CPSR_SCALE_BLOC_SUPR
#
##  export RET_MOPITT_OBS_DIR=${DATA_DIR}/obs_MOPITT_CO_RETR_NO_ROT_RJ3_SUPR
##  export RET_IASI_CO_OBS_DIR=${DATA_DIR}/obs_IASI_CO_RAWR_NO_ROT_RJ3_SUPR
##  export RET_IASI_O3_OBS_DIR=${DATA_DIR}/obs_IASI_O3_RETR_f1p0
##  export WRITE_OUT_NAME=obs_MOPnIAS_CO_O3_RETR_NO_ROT_RJ3_SUPR
#
##  export RET_MOPITT_OBS_DIR=${DATA_DIR}/obs_MOPITT_CO_RETR_CPSR_SCALE_RJ3_SUPR
##  export RET_IASI_CO_OBS_DIR=${DATA_DIR}/obs_IASI_CO_RAWR_CPSR_SCALE_RJ3_SUPR
##  export RET_IASI_O3_OBS_DIR=${DATA_DIR}/obs_IASI_O3_RETR_f1p0
##  export WRITE_OUT_NAME=obs_MOPnIAS_CO_O3_RETR_CPSR_SCALE_RJ3_SUPR
#
  export RET_MOPITT_OBS_DIR=${DATA_DIR}/obs_MOPITT_CO_RETR_CPSR_SCALE_RJ0_SUPR
  export RET_IASI_CO_OBS_DIR=${DATA_DIR}/obs_IASI_CO_RAWR_CPSR_SCALE_RJ0_SUPR
  export RET_IASI_O3_OBS_DIR=${DATA_DIR}/obs_IASI_O3_RETR_f1p0
  export WRITE_OUT_NAME=obs_MOPnIAS_CO_O3_RETR_CPSR_SCALE_RJ0_SUPR
#
# DEPENDENT DIRECTORIES
  export HYBRID_DIR=${ROOT_DIR}/HYBRID_TRUNK
  export WRF_DIR=${CODE_DIR}/${WRF_VER}
  export VAR_DIR=${CODE_DIR}/${WRFDA_VER}
  export BUILD_DIR=${VAR_DIR}/var/build
  export DART_DIR=${CODE_DIR}/${DART_VER}
  export TOOL_DIR=${VAR_DIR}/var/da
  export ICBC_DIR=${ASIM_DIR}
  export HYBRID_SCRIPTS_DIR=${HYBRID_DIR}/hybrid_scripts
#
# MAKE ASSIMILATION DIRECTORY AND GO TO IT
  if [[ ! -d ${ASIM_DIR} ]]; then mkdir -p ${ASIM_DIR}; fi
  cd ${ASIM_DIR}
#
# BEGIN DAY AND TIME LOOP
  export L_DATE=${START_DATE}
  while [[ ${L_DATE} -le ${END_DATE} ]]; do
     export YYYY=$(echo $L_DATE | cut -c1-4)
     export YY=$(echo $L_DATE | cut -c3-4)
     export MM=$(echo $L_DATE | cut -c5-6)
     export DD=$(echo $L_DATE | cut -c7-8)
     export HH=$(echo $L_DATE | cut -c9-10)
     export PAST_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} -${ASIM_WINDOW} 2>/dev/null)  
     export PAST_YYYY=$(echo $PAST_DATE | cut -c1-4)
     export PAST_MM=$(echo $PAST_DATE | cut -c5-6)
     export PAST_DD=$(echo $PAST_DATE | cut -c7-8)
     export PAST_HH=$(echo $PAST_DATE | cut -c9-10)
#
     export IASI_PAST_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} -24 2>/dev/null)  
     export IASI_PAST_YYYY=$(echo $IASI_PAST_DATE | cut -c1-4)
     export IASI_PAST_MM=$(echo $IASI_PAST_DATE | cut -c5-6)
     export IASI_PAST_DD=$(echo $IASI_PAST_DATE | cut -c7-8)
     export IASI_PAST_HH=$(echo $IASI_PAST_DATE | cut -c9-10)
     export IASI_NEXT_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} +24 2>/dev/null)  
     export IASI_NEXT_YYYY=$(echo $IASI_NEXT_DATE | cut -c1-4)
     export IASI_NEXT_MM=$(echo $IASI_NEXT_DATE | cut -c5-6)
     export IASI_NEXT_DD=$(echo $IASI_NEXT_DATE | cut -c7-8)
     export IASI_NEXT_HH=$(echo $IASI_NEXT_DATE | cut -c9-10)
#
# DART TIME INFO (NO LEADING ZEROS)
     export DT_YYYY=${YYYY}
     export DT_YY=$(echo $L_DATE | cut -c3-4)
     export DT_MM=${MM} 
     export DT_DD=${DD} 
     export DT_HH=${HH} 
     (( DT_MM = ${DT_MM} + 0 ))
     (( DT_DD = ${DT_DD} + 0 ))
     (( DT_HH = ${DT_HH} + 0 ))
#    
# Use obs_sequence_tool to combine multiple obs_seq files
     cd ${ASIM_DIR}
     if [[ ! -d ${ASIM_DIR}/mdart_to_sdart/${YYYY}${MM} ]]; then mkdir -p ${ASIM_DIR}/mdart_to_sdart/${YYYY}${MM}; fi
        cd ${ASIM_DIR}/mdart_to_sdart/${YYYY}${MM}
        if [[ ${HH} -eq 0 ]] then
           export L_YYYY=${PAST_YYYY}
           export L_MM=${PAST_MM}
           export L_DD=${PAST_DD}
           export L_HH=24
           export D_DATE=${L_YYYY}${L_MM}${L_DD}${L_HH}
        else
           export L_YYYY=${YYYY}
           export L_MM=${MM}
           export L_DD=${DD}
           export L_HH=${HH}
           export D_DATE=${L_YYYY}${L_MM}${L_DD}${L_HH}
        fi
        cp ${DART_DIR}/models/wrf_chem/work/advance_time ./.
        cp ${DART_DIR}/models/wrf_chem/work/obs_sequence_tool ./.
        cp ${DART_DIR}/models/wrf_chem/work/input.nml ./.
        export MET_FLG=0
        export MOP_FLG=0
        export IAS_CO_FLG=0
        export IAS_O3_FLG=0
        if [[ -e ${DATA_DIR}/obs_MET/${L_DATE}/obs_seq_${L_DATE}.out ]]; then 
           export MET_FLG=1
           cp ${DATA_DIR}/obs_MET/${L_DATE}/obs_seq_${L_DATE}.out ./obs_seq_MET_${L_DATE}.out
        fi
        if [[ -e ${RET_MOPITT_OBS_DIR}/obs_seq_mopitt_${D_DATE} ]];  then
           export MOP_FLG=1
           cp ${RET_MOPITT_OBS_DIR}/obs_seq_mopitt_${D_DATE} ./obs_seq_MOP_${L_DATE}.out
        fi
        if [[ -e ${RET_IASI_CO_OBS_DIR}/obs_seq_iasi_${D_DATE} ]]; then
           export IAS_CO_FLG=1
           cp ${RET_IASI_CO_OBS_DIR}/obs_seq_iasi_${D_DATE} ./obs_seq_IAS_CO_${L_DATE}.out
        fi
        if [[ -e ${RET_IASI_O3_OBS_DIR}/obs_seq_${L_DATE}.out ]]; then
           export IAS_O3_FLG=1
           cp ${RET_IASI_O3_OBS_DIR}/obs_seq_${L_DATE}.out ./obs_seq_IAS_O3_${L_DATE}.out
        fi
#
# No missing files
        if [[ ${MET_FLG} -eq 1 && ${MOP_FLG} -eq 1 && ${IAS_CO_FLG} -eq 1 && ${IAS_O3_FLG} -eq 1 ]]; then
           export NL_NUM_INPUT_FILES=4
           export NL_FILENAME_SEQ="'obs_seq_MET_${L_DATE}.out','obs_seq_MOP_${L_DATE}.out','obs_seq_IAS_CO_${L_DATE}.out','obs_seq_IAS_O3_${L_DATE}.out'"
        fi
#
# One missing file
        if [[ ${MET_FLG} -eq 0 && ${MOP_FLG} -eq 1 && ${IAS_CO_FLG} -eq 1 && ${IAS_O3_FLG} -eq 1 ]]; then
           export NL_NUM_INPUT_FILES=3
           export NL_FILENAME_SEQ="'obs_seq_MOP_${L_DATE}.out','obs_seq_IAS_CO_${L_DATE}.out','obs_seq_IAS_O3_${L_DATE}.out'"
        fi
        if [[ ${MET_FLG} -eq 1 && ${MOP_FLG} -eq 0 && ${IAS_CO_FLG} -eq 1 && ${IAS_O3_FLG} -eq 1 ]]; then
           export NL_NUM_INPUT_FILES=
           export NL_FILENAME_SEQ="'obs_seq_MET_${L_DATE}.out','obs_seq_IAS_CO_${L_DATE}.out','obs_seq_IAS_O3_${L_DATE}.out'"
        fi
        if [[ ${MET_FLG} -eq 1 && ${MOP_FLG} -eq 1 && ${IAS_CO_FLG} -eq 0 && ${IAS_O3_FLG} -eq 1 ]]; then
           export NL_NUM_INPUT_FILES=3
           export NL_FILENAME_SEQ="'obs_seq_MET_${L_DATE}.out','obs_seq_MOP_${L_DATE}.out','obs_seq_IAS_O3_${L_DATE}.out'"
        fi
        if [[ ${MET_FLG} -eq 1 && ${MOP_FLG} -eq 1 && ${IAS_CO_FLG} -eq 1 && ${IAS_O3_FLG} -eq 0 ]]; then
           export NL_NUM_INPUT_FILES=3
           export NL_FILENAME_SEQ="'obs_seq_MET_${L_DATE}.out','obs_seq_MOP_${L_DATE}.out','obs_seq_IAS_CO_${L_DATE}.out'"
        fi
#
# Two missing files
        if [[ ${MET_FLG} -eq 0 && ${MOP_FLG} -eq 0 && ${IAS_CO_FLG} -eq 1 && ${IAS_O3_FLG} -eq 1 ]]; then
           export NL_NUM_INPUT_FILES=2
           export NL_FILENAME_SEQ="'obs_seq_IAS_CO_${L_DATE}.out','obs_seq_IAS_O3_${L_DATE}.out'"
        fi
        if [[ ${MET_FLG} -eq 0 && ${MOP_FLG} -eq 1 && ${IAS_CO_FLG} -eq 0 && ${IAS_O3_FLG} -eq 1 ]]; then
           export NL_NUM_INPUT_FILES=2
           export NL_FILENAME_SEQ="'obs_seq_MOP_${L_DATE}.out','obs_seq_IAS_O3_${L_DATE}.out'"
        fi
        if [[ ${MET_FLG} -eq 0 && ${MOP_FLG} -eq 1 && ${IAS_CO_FLG} -eq 1 && ${IAS_O3_FLG} -eq 0 ]]; then
           export NL_NUM_INPUT_FILES=2
           export NL_FILENAME_SEQ="'obs_seq_MOP_${L_DATE}.out','obs_seq_IAS_CO_${L_DATE}.out'"
        fi
        if [[ ${MET_FLG} -eq 1 && ${MOP_FLG} -eq 0 && ${IAS_CO_FLG} -eq 0 && ${IAS_O3_FLG} -eq 1 ]]; then
           export NL_NUM_INPUT_FILES=2
           export NL_FILENAME_SEQ="'obs_seq_MET_${L_DATE}.out','obs_seq_IAS_O3_${L_DATE}.out'"
        fi
        if [[ ${MET_FLG} -eq 1 && ${MOP_FLG} -eq 0 && ${IAS_CO_FLG} -eq 1 && ${IAS_O3_FLG} -eq 0 ]]; then
           export NL_NUM_INPUT_FILES=2
           export NL_FILENAME_SEQ="'obs_seq_MET_${L_DATE}.out','obs_seq_IAS_CO_${L_DATE}.out'"
        fi
        if [[ ${MET_FLG} -eq 1 && ${MOP_FLG} -eq 1 && ${IAS_CO_FLG} -eq 0 && ${IAS_O3_FLG} -eq 0 ]]; then
           export NL_NUM_INPUT_FILES=2
           export NL_FILENAME_SEQ="'obs_seq_MET_${L_DATE}.out','obs_seq_MOP_${L_DATE}.out'"
        fi
#
# Three missing files
        if [[ ${MET_FLG} -eq 1 && ${MOP_FLG} -eq 0 && ${IAS_CO_FLG} -eq 0 && ${IAS_O3_FLG} -eq 0 ]]; then
           export NL_NUM_INPUT_FILES=1
           export NL_FILENAME_SEQ="'obs_seq_MET_${L_DATE}.out'"
        fi
        if [[ ${MET_FLG} -eq 0 && ${MOP_FLG} -eq 1 && ${IAS_CO_FLG} -eq 0 && ${IAS_O3_FLG} -eq 0 ]]; then
           export NL_NUM_INPUT_FILES=1
           export NL_FILENAME_SEQ="'obs_seq_MOP_${L_DATE}.out'"
        fi
        if [[ ${MET_FLG} -eq 0 && ${MOP_FLG} -eq 0 && ${IAS_CO_FLG} -eq 1 && ${IAS_O3_FLG} -eq 0 ]]; then
           export NL_NUM_INPUT_FILES=1
           export NL_FILENAME_SEQ="'obs_seq_IAS_CO_${L_DATE}.out'"
        fi
        if [[ ${MET_FLG} -eq 0 && ${MOP_FLG} -eq 0 && ${IAS_CO_FLG} -eq 0 && ${IAS_O3_FLG} -eq 1 ]]; then
           export NL_NUM_INPUT_FILES=1
           export NL_FILENAME_SEQ="'obs_seq_IAS_O3_${L_DATE}.out'"
        fi
#
# CALCULATE GREGORIAN TIMES FOR START AND END OF ASSIMILAtION WINDOW
        export ASIM_MIN_DATE=$($BUILD_DIR/da_advance_time.exe $L_DATE -$ASIM_WINDOW 2>/dev/null)
        export ASIM_MAX_DATE=$($BUILD_DIR/da_advance_time.exe $L_DATE +$ASIM_WINDOW 2>/dev/null)
        set -A temp `echo $ASIM_MIN_DATE 0 -g | ./advance_time`
        export ASIM_MIN_DAY_GREG=${temp[0]}
        export ASIM_MIN_SEC_GREG=${temp[1]}
        set -A temp `echo $ASIM_MAX_DATE 0 -g | ./advance_time` 
        export ASIM_MAX_DAY_GREG=${temp[0]}
        export ASIM_MAX_SEC_GREG=${temp[1]}
#
# SETUP OBS_SEQUENCE_TOOL INPUT.NML
        export NL_FILENAME_OUT="'obs_seq.proc'"
        export NL_FIRST_OBS_DAYS=${ASIM_MIN_DAY_GREG}
        export NL_FIRST_OBS_SECONDS=${ASIM_MIN_SEC_GREG}
        export NL_LAST_OBS_DAYS=${ASIM_MAX_DAY_GREG}
        export NL_LAST_OBS_SECONDS=${ASIM_MAX_SEC_GREG}
        export NL_SYNONYMOUS_COPY_LIST="'NCEP BUFR observation','MOPITT CO observation','IASI CO observation','IASI O3 observation'"
        export NL_SYNONYMOUS_QC_LIST="'NCEP QC index','MOPITT CO QC index','IASI CO QC index','IASI O3 QC index'"
        export NL_MIN_LAT=7.
        export NL_MAX_LAT=54.
        export NL_MIN_LON=184.
        export NL_MAX_LON=310.
        rm input.nml
        ${HYBRID_SCRIPTS_DIR}/da_create_dart_input_nml.ksh       
#
        ./obs_sequence_tool
#        if [[ ! -d ${DATA_DIR}/obs_MOPITT/${L_DATE} ]]; then mkdir -p ${DATA_DIR}/obs_MOPITT/${L_DATE}; fi
        mkdir -p ${DATA_DIR}/${WRITE_OUT_NAME}/${L_DATE}
        cp obs_seq.proc ${DATA_DIR}/${WRITE_OUT_NAME}/${L_DATE}/obs_seq_comb_${L_DATE}.out
        cd ${ASIM_DIR}
#
# LOOP TO NEXT DAY AND TIME 
     export L_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} ${TIME_INC} 2>/dev/null)  
  done 
exit
