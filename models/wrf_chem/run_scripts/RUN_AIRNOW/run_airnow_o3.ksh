#!/bin/ksh -aeux 
#
# TO SETUP AN ENVIRONMENT TO CONVERT OBSERVATIONS TO obs_seq.
#
# SET TIME INFORMATION
  export START_DATE=2014071400
  export END_DATE=2014072100
  export CYCLE_PERIOD=6
  export ASIM_WINDOW=3
#
# VERSIONS
  export WRFDA_VER=WRFDAv3.4_dmpar
  export WRF_VER=WRFv3.4_dmpar
  export DART_VER=DART_CHEM_MY_BRANCH
#
# INDEPENDENT DIRECTORIES
  export WORK_DIR=/glade/p/work/mizzi
  export SCRATCH_DIR=/glade/scratch/mizzi
  export ACD_DIR=/glade/p/acd/mizzi
  export FRAPPE_DIR=/glade/p/FRAPPE
#
# OUTPUT DIR
  export OBS_AIRNOW_OUT_DIR=/glade/p/acd/mizzi/AVE_TEST_DATA/obs_AIRNOW_O3
  if [[ ! -d ${OBS_AIRNOW_OUT_DIR} ]]; then 
     mkdir -p ${OBS_AIRNOW_OUT_DIR}; 
  fi
#
# DEPENDENT DIRECTORIES
  export TRUNK_DIR=${WORK_DIR}/TRUNK
  export WRF_DIR=${TRUNK_DIR}/${WRF_VER}
  export VAR_DIR=${TRUNK_DIR}/${WRFDA_VER}
  export BUILD_DIR=${VAR_DIR}/var/build
  export DART_DIR=${TRUNK_DIR}/${DART_VER}
  export RUN_DIR=${SCRATCH_DIR}/create_airnow_o3_obseq
#
# MAKE RUN DIRECTORY
  if [[ ! -d ${RUN_DIR} ]]; then 
     mkdir -p ${RUN_DIR}; 
  fi
  cd ${RUN_DIR}
#
# GET AIRNOW DATA
  if [[ ! -e hourly_44201_2014.csv ]]; then
     cp ${FRAPPE_DIR}/REAL_TIME_DATA/airnow_obs/hourly_44201_2014.csv ./.
  fi
#
# BEGIN DAY AND TIME LOOP
  export L_DATE=${START_DATE}
  while [[ ${L_DATE} -le ${END_DATE} ]]; do
     export YYYY=$(echo $L_DATE | cut -c1-4)
     export YY=$(echo $L_DATE | cut -c3-4)
     export MM=$(echo $L_DATE | cut -c5-6)
     export DD=$(echo $L_DATE | cut -c7-8)
     export HH=$(echo $L_DATE | cut -c9-10)
     export ASIM_MIN_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} -${ASIM_WINDOW} 2>/dev/null)  
     export ASIM_MAX_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} +${ASIM_WINDOW} 2>/dev/null)  
     export ASIM_MIN_YYYY=$(echo $ASIM_MIN_DATE | cut -c1-4)
     export ASIM_MIN_YY=$(echo $ASIM_MIN_DATE | cut -c3-4)
     export ASIM_MIN_MM=$(echo $ASIM_MIN_DATE | cut -c5-6)
     export ASIM_MIN_DD=$(echo $ASIM_MIN_DATE | cut -c7-8)
     export ASIM_MIN_HH=$(echo $ASIM_MIN_DATE | cut -c9-10)
     export ASIM_MIN_MN=0
     export ASIM_MIN_SS=1
     export ASIM_MAX_YYYY=$(echo $ASIM_MAX_DATE | cut -c1-4)
     export ASIM_MAX_YY=$(echo $ASIM_MAX_DATE | cut -c3-4)
     export ASIM_MAX_MM=$(echo $ASIM_MAX_DATE | cut -c5-6)
     export ASIM_MAX_DD=$(echo $ASIM_MAX_DATE | cut -c7-8)
     export ASIM_MAX_HH=$(echo $ASIM_MAX_DATE | cut -c9-10)
     export ASIM_MAX_MN=0
     export ASIM_MAX_SS=0
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
# RUN_AIRNOW_O3_ASCII_TO_DART
        cd ${RUN_DIR}
        if [[ ${HH} -eq 0 ]] then
           export L_YYYY=${ASIM_MIN_YYYY}
           export L_MM=${ASIM_MIN_MM}
           export L_DD=${ASIM_MIN_DD}
           export L_HH=24
           export D_DATE=${L_YYYY}${L_MM}${L_DD}${L_HH}
        else
           export L_YYYY=${YYYY}
           export L_MM=${MM}
           export L_DD=${DD}
           export L_HH=${HH}
           export D_DATE=${L_YYYY}${L_MM}${L_DD}${L_HH}
        fi
        export NL_YEAR=${L_YYYY}
        export NL_MONTH=${L_MM}
        export NL_DAY=${L_DD}
        export NL_HOUR=${L_HH}
#
        export NL_FILENAME="'"${FRAPPE_DIR}/REAL_TIME_DATA/airnow_obs/hourly_44201_2014.csv"'"
        export NL_LAT_MN=28.6
        export NL_LAT_MX=50.0
        export NL_LON_MN=-131.0
        export NL_LON_MX=-94.0
#
# CREATE INPUT NAMELIST
        rm -rf airnow_o3_obs.nml
        touch airnow_o3_obs.nml
        cat << EOF > airnow_o3_obs.nml
&airnow_o3_obs
year0=${NL_YEAR}
month0=${NL_MONTH}
day0=${NL_DAY}
hour0=${NL_HOUR}
beg_year=${ASIM_MIN_YYYY}
beg_mon=${ASIM_MIN_MM}
beg_day=${ASIM_MIN_DD}
beg_hour=${ASIM_MIN_HH}
beg_min=${ASIM_MIN_MN}
beg_sec=${ASIM_MIN_SS}
end_year=${ASIM_MAX_YYYY}
end_mon=${ASIM_MAX_MM}
end_day=${ASIM_MAX_DD}
end_hour=${ASIM_MAX_HH}
end_min=${ASIM_MAX_MN}
end_sec=${ASIM_MAX_SS}
file_in=${NL_FILENAME}
lat_mn=${NL_LAT_MN}
lat_mx=${NL_LAT_MX}
lon_mn=${NL_LON_MN}
lon_mx=${NL_LON_MX}
/
EOF
#
# GET EXECUTABLE
        cp ${DART_DIR}/observations/AIRNOW/work/airnow_o3_ascii_to_obs ./.
        cp ${DART_DIR}/observations/AIRNOW/work/input.nml ./.
        ./airnow_o3_ascii_to_obs
#
# COPY OUTPUT TO ARCHIVE LOCATION
        export AIRNOW_OUT_FILE=airnow_obs_seq
        export AIRNOW_ARCH_FILE=obseq_airnow_o3_${D_DATE}
        if [[ -e ${AIRNOW_OUT_FILE} ]]; then
           cp ${AIRNOW_OUT_FILE} ${OBS_AIRNOW_OUT_DIR}/${AIRNOW_ARCH_FILE}
        else
           touch ${OBS_AIRNOW_OUT_DIR}/NO_DATA_${D_DATE}
        fi
#
# LOOP TO NEXT DAY AND TIME 
     export L_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} ${CYCLE_PERIOD} 2>/dev/null)  
  done 
exit
