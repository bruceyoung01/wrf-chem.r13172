#!/bin/ksh -x 
#
  set echo
#
# MODIFIED VERSION OF /DART/models/WRF/regression/CONUS-V3/icbc_real.ksh
# TO SETUP AN ENVIRONMENT TO CONVERT OBSERVATIONS TO obs_seq.
#
# SET SWITCHES FOR SCRIT OPTIONS
  export RUN_PREP_TO_ASCII=false
  export RUN_PREP_ASCII_TO_DART=false
  export RUN_IASI_ASCII_TO_DART=true
  export RUN_MDART_TO_SDART=true
  export OBS_SEQ_OUTDIR=obs_IASI_O3_CPSR_f1p0
#  export OBS_SEQ_OUTDIR=obs_IASI_O3_QOR_f1p0
#  export OBS_SEQ_OUTDIR=obs_IASI_O3_QOR_NO_SCALE_f1p0
#  export OBS_SEQ_OUTDIR=obs_IASI_O3_NO_ROT_f1p0
#  export OBS_SEQ_OUTDIR=obs_IASI_O3_RETR_f1p0
#
# SET TIME INFORMATION
  export START_DATE=2008060100
  export END_DATE=2008063018
  export TIME_INC=6
  export ASIM_WINDOW=3
  export START_DATE_DATA=20080601
  export END_DATE_DATA=20080630
#
# SYSTEM SPECIFIC SETTINGS
  export PROCS=8
#  export OB_TYPE=ob_reanal
  export OB_TYPE=obs
#
# INITIAL CONDITION FILES
# Set to '1' if you want a single IC file, any other # if you want separate files (the 
# latter is suggested if you have large grids and lots of members)
  export single_file=1
#
# PATHS
  export WRFDA_VER=WRFDAv3.4_dmpar
  export WRF_VER=WRFv3.4_dmpar
  export DART_VER=DART_CHEM_MY_BRANCH
#
# INDEPENDENT DIRECTORIES
  export CODE_DIR=/glade/p/work/mizzi
  export ACD_DIR=/glade/p/acd/mizzi
  export SCRATCH_DIR=/glade/scratch/mizzi
#
# DEPENDENT DIRECTORIES
  export ASIM_DIR=${SCRATCH_DIR}/IASI_O3_to_OBSSEQ
  export TRUNK_DIR=${CODE_DIR}/TRUNK
  export HYBRID_DIR=${CODE_DIR}/HYBRID_TRUNK
  export WRF_DIR=${TRUNK_DIR}/${WRF_VER}
  export VAR_DIR=${TRUNK_DIR}/${WRFDA_VER}
  export BUILD_DIR=${VAR_DIR}/var/build
  export DART_DIR=${TRUNK_DIR}/${DART_VER}
  export TOOL_DIR=${VAR_DIR}/var/da
  export ICBC_DIR=${ASIM_DIR}
  export HYBRID_SCRIPTS_DIR=${HYBRID_DIR}/hybrid_scripts
  export DATA_IN_DIR=${ACD_DIR}/AVE_TEST_DATA
  export DATA_OUT_DIR=${ACD_DIR}/AVE_TEST_DATA
  export OBS_IASI_DIR=${DATA_IN_DIR}/obs_IASI_O3_DnN_dat_No_SVD
#
# MAKE ASSIMILATION DIRECTORY AND GO TO IT
  if [[ ! -d ${ASIM_DIR} ]]; then mkdir -p ${ASIM_DIR}; fi
  mkdir -p ${ASIM_DIR}
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
     export YEAR_INIT=${DT_YYYY}
     export MONTH_INIT=${DT_MM}
     export DAY_INIT=${DT_DD}
     export HOUR_INIT=${DT_HH}
     export YEAR_END=${DT_YYYY}
     export MONTH_END=${DT_MM}
     export DAY_END=${DT_DD}
     export HOUR_END=${DT_HH}
     export DA_TIME_WINDOW=0
#
# RUN_IASI_ASCII_TO_DART
     if ${RUN_IASI_ASCII_TO_DART}; then 
        cd ${ASIM_DIR}
        if [[ ! -d ${ASIM_DIR}/IASI_ascii_to_dart/${YYYY}${MM} ]]; then mkdir -p ${ASIM_DIR}/IASI_ascii_to_dart/${YYYY}${MM}; fi
        cd ${ASIM_DIR}/IASI_ascii_to_dart/${YYYY}${MM}
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
#
# USE IASI DATA FROM PAST, PRESENT, AND NEXT DATES TO ENSURE FULL COVERAGE OF $ASIM_WINDOW 
#
# RUN FOR PAST
        if [[ ${YYYY}${MM}${DD} -ne ${START_DATE_DATA} ]]; then
           rm -rf input.nml
           rm -rf iasi_asciidata.input
           rm -rf iasi_obs_seq.out
           cp ${OBS_IASI_DIR}/IASIO3PROF_OBSSEQ_method2_${IASI_PAST_YYYY}${IASI_PAST_MM}${IASI_PAST_DD}.dat iasi_asciidata.input
#           cp ${OBS_IASI_DIR}/${IASI_PAST_YYYY}${IASI_PAST_MM}${IASI_PAST_DD}.dat iasi_asciidata.input
           cp ${DART_DIR}/observations/IASI_O3/work/input.nml ./.
           ${DART_DIR}/observations/IASI_O3/work/iasi_ascii_to_obs > index_past
           export IASI_PAST_FILE=iasi_obs_seq_${IASI_PAST_YYYY}${IASI_PAST_MM}${IASI_PAST_DD}
           mv iasi_obs_seq.out ${IASI_PAST_FILE}
        fi
#
# RUN FOR PRESENT
#        rm -rf input.nml
        rm -rf iasi_asciidata.input
        cp ${OBS_IASI_DIR}/IASIO3PROF_OBSSEQ_method2_${YYYY}${MM}${DD}.dat iasi_asciidata.input
        cp ${DART_DIR}/observations/IASI_O3/work/input.nml .
        ${DART_DIR}/observations/IASI_O3/work/iasi_ascii_to_obs > index_present
        export IASI_PRES_FILE=iasi_obs_seq_${YYYY}${MM}${DD}
        mv iasi_obs_seq.out ${IASI_PRES_FILE}
#
# RUN FOR NEXT
        if [[ ${YYYY}${MM}${DD} -ne ${END_DATE_DATA} ]]; then
           rm -rf input.nml
           rm -rf iasi_asciidata.input
           cp ${OBS_IASI_DIR}/IASIO3PROF_OBSSEQ_method2_${IASI_NEXT_YYYY}${IASI_NEXT_MM}${IASI_NEXT_DD}.dat iasi_asciidata.input
           cp ${DART_DIR}/observations/IASI_O3/work/input.nml .
           ${DART_DIR}/observations/IASI_O3/work/iasi_ascii_to_obs > index_next
           export IASI_NEXT_FILE=iasi_obs_seq_${IASI_NEXT_YYYY}${IASI_NEXT_MM}${IASI_NEXT_DD}
           mv iasi_obs_seq.out ${IASI_NEXT_FILE}
        fi   
#
        cd ${ASIM_DIR}
     fi
#
# RUN_MDART_TO_SDART (CONVERT MANY OBS_SEQ FILES TO A SINGLE OBS_SEQ FILE AND FILTER)
     if ${RUN_MDART_TO_SDART}; then
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

        export IASI_PAST_FILE=iasi_obs_seq_${IASI_PAST_YYYY}${IASI_PAST_MM}${IASI_PAST_DD}
        export IASI_PRES_FILE=iasi_obs_seq_${YYYY}${MM}${DD}
        export IASI_NEXT_FILE=iasi_obs_seq_${IASI_NEXT_YYYY}${IASI_NEXT_MM}${IASI_NEXT_DD}
        if ${RUN_PREP_ASCII_TO_DART}; then 
           cp ${ASIM_DIR}/prep_ascii_to_dart/${YYYY}${MM}/obs_seq${D_DATE} ./.
        fi
        if ${RUN_IASI_ASCII_TO_DART}; then
           if [[ ${YYYY}${MM}${DD} -ne ${START_DATE_DATA} ]]; then 
              cp ${ASIM_DIR}/IASI_ascii_to_dart/${YYYY}${MM}/${IASI_PAST_FILE} ./.
           fi
           cp ${ASIM_DIR}/IASI_ascii_to_dart/${YYYY}${MM}/${IASI_PRES_FILE} ./.
           if [[ ${YYYY}${MM}${DD} -ne ${END_DATE_DATA} ]]; then 
              cp ${ASIM_DIR}/IASI_ascii_to_dart/${YYYY}${MM}/${IASI_NEXT_FILE} ./.
           fi
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
        if ${RUN_PREP_ASCII_TO_DART}; then 
           export NL_NUM_INPUT_FILES=4
           export NL_FILENAME_SEQ="'obs_seq${D_DATE}','${IASI_PAST_FILE}','${IASI_PRES_FILE}','${IASI_NEXT_FILE}'"
        elif [[ ${YYYY}${MM}${DD} -eq ${START_DATE_DATA} ]]; then
           export NL_NUM_INPUT_FILES=2
           export NL_FILENAME_SEQ="'${IASI_PRES_FILE}','${IASI_NEXT_FILE}'"
        elif [[ ${YYYY}${MM}${DD} -ne ${START_DATE_DATA} && ${YYYY}${MM}${DD} -ne ${END_DATE_DATA} ]]; then
           export NL_NUM_INPUT_FILES=3
           export NL_FILENAME_SEQ="'${IASI_PAST_FILE}','${IASI_PRES_FILE}','${IASI_NEXT_FILE}'"
        elif [[ ${YYYY}${MM}${DD} -eq ${END_DATE_DATA} ]]; then
           export NL_NUM_INPUT_FILES=2
           export NL_FILENAME_SEQ="'${IASI_PAST_FILE}','${IASI_PRES_FILE}'"
        fi
        export NL_FILENAME_OUT="'obs_seq_${L_DATE}.out'"
        export NL_FIRST_OBS_DAYS=${ASIM_MIN_DAY_GREG}
        export NL_FIRST_OBS_SECONDS=${ASIM_MIN_SEC_GREG}
        export NL_LAST_OBS_DAYS=${ASIM_MAX_DAY_GREG}
        export NL_LAST_OBS_SECONDS=${ASIM_MAX_SEC_GREG}
        export NL_SYNONYMOUS_COPY_LIST="'IASI O3 observation'"
        export NL_SYNONYMOUS_QC_LIST="'IASI O3 QC index'"
        ${HYBRID_SCRIPTS_DIR}/da_create_dart_input_nml.ksh       
#
        ./obs_sequence_tool
        if [[ ! -e ${DATA_OUT_DIR}/${OBS_SEQ_OUTDIR} ]]; then
           mkdir -p ${DATA_OUT_DIR}/${OBS_SEQ_OUTDIR}
        fi
        if [[ -e obs_seq_${L_DATE}.out ]]; then
           cp obs_seq_${L_DATE}.out ${DATA_OUT_DIR}/${OBS_SEQ_OUTDIR}/.
        else
           touch ${DATA_OUT_DIR}/${OBS_SEQ_OUTDIR}/NO_OBS_SEQ.OUT_DATA_${L_DATE}
        fi
        cd ${ASIM_DIR}
     fi 
#
# LOOP TO NEXT DAY AND TIME 
     export L_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} ${TIME_INC} 2>/dev/null)  
  done 
exit
