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
#  Script to run advance wrf_chem within the DART framework
#
############################################################################### 
#
# Unalias UNIX commands
unalias cd
unalias ls
#
# Define experiment parameters
export PROCESS=$1
export NUM_STATES=$2
export CONTROL_FILE=$3
export SAVE_ENSEMBLE_MEMBER=0
export DELETE_TEMP_DIR=false
export INDIVIDUAL_MEMBERS=true
#
# Check for logical consistency
if [[ ${INDIVIDUAL_MEMBERS} == true ]]; then export DELETE_TEMP_DIR=false; fi
#
# Define experiment parameters
export MYNAME=$0
export WRFOUTDIR=${CENTRALDIR}/WRFOUT
#
# If $PROCESS=0, check for dependencies
if [[ ${PROCESS} == 0 ]]; then
   if [[ ! -f ${CENTRALDIR}/advance_time ]]; then
      echo ERROR: ${CENTRALDIR}/advance_time.exe does not exist
      exit
   fi
   if [[ ! -d WRF_RUN ]]; then
      echo ERROR: ${CENTRALDIR}/WRF_RUN does not exist
      exit
   fi
   if [[ ! -d WRFCHEM_RUN ]]; then
      echo ERROR: ${CENTRALDIR}/WRFCHEM_RUN does not exist
      exit
   fi
   if [[ ! -f ${CENTRALDIR}/WRF_RUN/da_wrfvar.exe ]]; then
      echo WARNING: ${CENTRALDIR}/WRF_RUN/da_wrfvar.exe does not exist
      if [[ ! -f update_wrf_bc ]]; then
         export SPEC_BC=true 
         export SPEC_TMP=`grep specified ${CENTRALDIR}/namelist.input | grep true | wc -l`
         if [[ ${SPEC_TMP} -le 0 ]]; then export SPEC_BC=false; fi
         if ${SPEC_BC}; then
            echo ERROR: ${CENTRALDIR}/update_wrf_bc.exe does not exist
            exit 
         else
            echo ERROR: ${CENTRALDIR}/WRF_RUN/da_wrfvar.exe does not exist and neede to update wrfbdy files
            exit
         fi
      fi
   else
      if [[ ! -f ${CENTRALDIR}/pert_wrf_bc ]]; then
       echo ERROR: ${CENTRALDIR}/pert_wrf_bc.exe does not exist
       exit 
      fi
      if [[ ! -f ${CENTRALDIR}/WRF_RUN/be.dat ]]; then
        echo ERROR: ${CENTRALDIR}/WRF_RUN/be.dat does not exist
        exit
      fi
      if [[ ! -f ${CENTRALDIR}/bc_pert_scale ]]; then
        echo WARNING: Use default VAR covariance scaleing
      fi
   fi
   if [[ ! -f  ${CENTRALDIR}/add_noise.ksh ]]; then
      echo WARNING: ${CENTRALDIR}/add_noise.ksh does not exist
   fi
fi
#
# Set $USE_WRFVAR for all processes
if [[ -f ${CENTRALDIR}/WRF_RUN/da_wrfvar.exe ]]; then
   export USE_WRFVAR=true
else
   export USE_WRFVAR=false
fi
#
# Set $USE_NOISE for all processes
if [[ -f ${CENTRALDIR}/add_noise.csh ]]; then
   export USE_NOISE=true
else
   export USE_NOISE=false
fi
#
# Each parallel task may need to advance more than one ensemble member.
# This control file has the actual ensemble number, the input filename,
# and the output filename for each advance.  Be prepared to loop and
# do the rest of the script more than once.
export ENSEMBLE_MEMBER_LINE=1
export INPUT_FILE_LINE=2
export OUTPUT_FILE_LINE=3
#
let STATE_COPY=1
while [[ ${STATE_COPY} -le ${NUM_STATES} ]]; do
   export C_STATE_COPY=${STATE_COPY}
   if [[ ${STATE_COPY} -lt 1000 ]]; then export C_STATE_COPY=0${STATE_COPY}; fi
   if [[ ${STATE_COPY} -lt 100 ]]; then export C_STATE_COPY=00${STATE_COPY}; fi
   if [[ ${STATE_COPY} -lt 10 ]]; then export C_STATE_COPY=000${STATE_COPY}; fi
   export ENSEMBLE_MEMBER=`head -${ENSEMBLE_MEMBER_LINE} ${CENTRALDIR}/${CONTROL_FILE} | tail -1`
   export INPUT_FILE=`head -${INPUT_FILE_LINE} ${CENTRALDIR}/${CONTROL_FILE} | tail -1`
   export OUTPUT_FILE=`head -${OUTPUT_FILE_LINE} ${CENTRALDIR}/${CONTROL_FILE} | tail -1`
   let INFL=0.0
#
# Create $TEMP_DIR for each member and run WRF there
   export TEMP_DIR=advance_temp_${ENSEMBLE_MEMBER}
   if [[ -d ${TEMP_DIR} && ${INDIVIDUAL_MEMBERS} = "true" ]]; then
      rm -rf ${TEMP_DIR}
      mkdir -p ${TEMP_DIR}
      cd ${TEMP_DIR}
   else
      mkdir -p ${TEMP_DIR}
      cd ${TEMP_DIR}
   fi
#
# Copy wrfinput file
   cp ${CENTRALDIR}/WRF/wrfinput*_${ENSEMBLE_MEMBER} wrfinput_d${DOMAIN}
# 
# Link in WRF-runtime files
   cp ${CENTRALDIR}/WRF_RUN/* ./.
#
# Link in WRFCHEM-runtime files
   cp ${CENTRALDIR}/WRFCHEM_RUN/* ./.
#
   if [[ ! -d ${CENTRALDIR}/WRFCHEM_RUN/MEMBER_${ENSEMBLE_MEMBER} ]]; then
      echo ERROR: ${CENTRALDIR}/WRFCHEM_RUN/MEMBER_${ENSEMBLE_MEMBER} does not exist
      exit
   fi
# Link in WRFCHEM/MEMBER_${ENSEMBLE_MEMBER}-runtime files
   cp ${CENTRALDIR}/WRFCHEM_RUN/MEMBER_${ENSEMBLE_MEMBER}/* ./.
#
# Link in DART namelist
   cp ${CENTRALDIR}/input.nml ./.
#
# Link in WRFCHEM executable
   cp ${CENTRALDIR}/wrf.exe ./.
#
# ICs for this wrf run; Convert DART file to wrfinput netcdf file
   if [[ -f ${CENTRALDIR}/${INPUT_FILE} ]]; then 
## APM +++
      cp wrfinput_d${DOMAIN}_${L_FILE_DATE} ./wrfinput_d${DOMAIN}
      cp wrfchemi_d${DOMAIN}_${L_FILE_DATE} ./wrfchemi_d${DOMAIN}_prior
      cp wrfchemi_d${DOMAIN}_${L_FILE_DATE} ./wrfchemi_d${DOMAIN}
      cp wrffirechemi_d${DOMAIN}_${L_FILE_DATE} ./wrffirechemi_d${DOMAIN}_prior
      cp wrffirechemi_d${DOMAIN}_${L_FILE_DATE} ./wrffirechemi_d${DOMAIN}
## APM ---
      cp ${CENTRALDIR}/dart_to_wrf ./.
      cp ${CENTRALDIR}/${INPUT_FILE} dart_wrf_vector 
#
# &dart_to_wrf_nml
      export NL_MODEL_ADVANCE_FILE=.true.
      export NL_DART_RESTART_NAME="'dart_wrf_vector'"
      export NL_ADV_MOD_COMMAND="'mpirun -np 64 ./wrf.exe'"
      rm input.nml
      ${DART_DIR}/models/wrf_chem/namelist_scripts/DART/dart_create_input.nml.ksh
#
      ./dart_to_wrf > index_dart_to_wrf 2>&1 
#      rm -rf dart_wrf_vector
   else
      echo ERROR: WRFINPUT file ${CENTRALDIR}/${INPUT_FILE} not there 
      exit
   fi
##
## APM +++
# copy the new wrfchemi and wrffirechemi files to the archive file names
   cp wrfchemi_d${DOMAIN} wrfchemi_d${DOMAIN}_${L_FILE_DATE}
   cp wrffirechemi_d${DOMAIN} wrffirechemi_d${DOMAIN}_${L_FILE_DATE}
#
# APM: adjust emission for other forecast time here
   if [[ ${ADD_EMISS} ]]; then
      export ADJUST_EMISS_DIR=${DART_DIR}/models/wrf_chem/run_scripts/RUN_EMISS_INV
#      export LM_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} 1 2>/dev/null)
#      export LM_END_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} ${FCST_PERIOD} 2>/dev/null)
      export LM_DATE=`echo ${L_DATE} +1h | ./advance_time`
      export LM_END_DATE=`echo ${L_DATE} +${FCST_PERIOD}h | ./advance_time`
      echo ${LM_DATE}
      echo ${LM_END_DATE}
      cp ${ADJUST_EMISS_DIR}/adjust_chem_emiss.exe ./.
#
#########################################################################
#
# RUN ADJUST_CHEM_EMISS
#
#########################################################################
#
      while [[ ${LM_DATE} -le ${LM_END_DATE} ]]; do
         export LM_YY=$(echo $LM_DATE | cut -c1-4)
         export LM_MM=$(echo $LM_DATE | cut -c5-6)
         export LM_DD=$(echo $LM_DATE | cut -c7-8)
         export LM_HH=$(echo $LM_DATE | cut -c9-10)
         export LM_FILE_DATE=${LM_YY}-${LM_MM}-${LM_DD}_${LM_HH}:00:00
#     
         export NL_WRFCHEMI_PRIOR=wrfchemi_d${DOMAIN}_prior
         export NL_WRFCHEMI_POST=wrfchemi_d${DOMAIN}
         export NL_WRFCHEMI_OLD=wrfchemi_d${DOMAIN}_${LM_FILE_DATE}
         export NL_WRFCHEMI_NEW=wrfchemi_d${DOMAIN}_new
         cp ${NL_WRFCHEMI_OLD} ${NL_WRFCHEMI_NEW}
#     
         export NL_WRFFIRECHEMI_PRIOR=wrffirechemi_d${DOMAIN}_prior
         export NL_WRFFIRECHEMI_POST=wrffirechemi_d${DOMAIN}
         export NL_WRFFIRECHEMI_OLD=wrffirechemi_d${DOMAIN}_${LM_FILE_DATE}
         export NL_WRFFIRECHEMI_NEW=wrffirechemi_d${DOMAIN}_new
         cp ${NL_WRFFIRECHEMI_OLD} ${NL_WRFFIRECHEMI_NEW}
#
# Make adjust_chem_nml for special_outlier_threshold
         rm -rf adjust_chem_emiss.nml
         cat <<  EOF > adjust_chem_emiss.nml
&adjust_chem_emiss
wrfchemi_prior=${NL_WRFCHEMI_PRIOR}
wrfchemi_post=${NL_WRFCHEMI_POST}
wrfchemi_old=${NL_WRFCHEMI_OLD}
wrfchemi_new=${NL_WRFCHEMI_NEW}
wrffirechemi_prior=${NL_WRFFIRECHEMI_PRIOR}
wrffirechemi_post=${NL_WRFFIRECHEMI_POST}
wrffirechemi_old=${NL_WRFFIRECHEMI_OLD}
wrffirechemi_new=${NL_WRFFIRECHEMI_NEW}
/
EOF
         ./adjust_chem_emiss.exe > index_adjust_chem_emiss
#
         cp ${NL_WRFCHEMI_NEW} ${NL_WRFCHEMI_OLD}
         cp ${NL_WRFFIRECHEMI_NEW} ${NL_WRFFIRECHEMI_OLD}
         export LM_DATE=`echo ${LM_DATE} +1h | ./advance_time`
      done
   fi
##
## APM ---
#
# dart_to_wrf has created the wrf.info.
   set -A SECDAY `head -1 wrf.info`
   export TARGSECS=${SECDAY[0]}
   export TARGDAYS=${SECDAY[1]}
   (( TARGKEY=${TARGDAYS}*86400+${TARGSECS} ))
#
   set -A SECDAY `head -2 wrf.info | tail -1`
   export WRFSECS=${SECDAY[0]}
   export WRFDAYS=${SECDAY[1]}
   (( WRFKEY=${WRFDAYS}*86400+${WRFSECS} ))
#
# Find all available wrfbdy files sort them with "keys".
#
# Check if LBCs are "specified" (in which case wrfbdy files are req'd)
# and we need to set up a key list to manage target times
   export SPEC_BC=true 
   export SPEC_TMP=`grep specified ${CENTRALDIR}/namelist.input | grep true | wc -l`
   if [[ ${SPEC_TMP} -le 0 ]]; then export SPEC_BC=false; fi
   if ${SPEC_BC}; then
      if ${USE_WRFVAR}; then
         set -A BDYFILES `echo ${CENTRALDIR}/WRF/wrfbdy_d01_*_mean`
      else
         set -A BDYFILES `echo ${CENTRALDIR}/WRF/wrfbdy_d01*_${ENSEMBLE_MEMBER}`
#         echo ${BDYFILES[0]}
#         echo ${BDYFILES[1]}
#         echo ${BDYFILES[2]}
      fi
      set KEYLIST=''
#
      for FILE in ${BDYFILES[*]} 
         do echo ${FILE}
	 let DAY=`echo ${FILE} | awk -F_ '{print $(NF-2)}'`
	 let SEC=`echo ${FILE} | awk -F_ '{print $(NF-1)}'`
         (( KEY=${DAY}*86400+${SEC} ))
         set -A KEYLIST ${KEYLIST[*]} ${KEY}
      done
      set -A KEYS `echo ${KEYLIST[*]} | sort`
   else
      let KEYS=${TARGKEY}
   fi 
#
   set -A CAL_DATE `head -3 wrf.info | tail -1`
   export START_YEAR=${CAL_DATE[0]}
   export START_MONTH=${CAL_DATE[1]}
   export START_DAY=${CAL_DATE[2]}
   export START_HOUR=${CAL_DATE[3]}
   export START_MIN=${CAL_DATE[4]}
   export START_SEC=${CAL_DATE[5]}
   export START_STRING=${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}:${START_MIN}:${START_SEC}
   export MY_NUM_DOMAINS=`head -4 wrf.info | tail -1`
   export ADV_MOD_COMMAND=`head -5 wrf.info | tail -1`
#
# Find the next available WRFBDY file
   let FILE=0
   while [[ ${KEYS[${FILE}]} -le ${WRFKEY} ]]; do
      if [[ ${FILE} -lt ${#BDYFILES[@]} ]]; then
         (( FILE=${FILE}+1 ))
      else
         echo No WRFBDY file times that exceed the forecast time
         echo ${START_STRING}
         exit
      fi
   done
#
# Add radar additive noise 
   if ${USE_NOISE}; then
      ${CENTRALDIR}/add_noise.ksh ${WRFSECS} ${WRFDAYS} ${STATE_COPY} ${ENSEMBLE_MEMBER} ${TEMP_DIR} ${CENTRALDIR}
   fi
#
# Loop over available WRFBDY files to advance model
   while [[ ${WRFKEY} -lt ${TARGKEY} ]]; do
      (( IDAY=${KEYS[${FILE}]}/86400 ))
      (( ISEC=${KEYS[${FILE}]}-${IDAY}*86400 ))
#
# Copy WRFBDY file to the temp directory
      if ${SPEC_BC}; then
         if ${USE_WRFVAR}; then
            cp ${CENTRALDIR}/WRF/wrfbdy_d01_${IDAY}_${ISEC}_mean ./wrfbdy_d01
         else
            cp ${CENTRALDIR}/WRF/wrfbdy_d01_${IDAY}_${ISEC}_${ENSEMBLE_MEMBER} wrfbdy_d01
         fi
      else
         echo ERROR: WRF namelist.input does not have specified boundary conditions
         exit   
      fi
#
# Calculate forecast interval in seconds and convert
      if [[ ${TARGKEY} -gt ${KEYS[${FILE}]} ]]; then
         (( INTERVAL_SS=${KEYS[${FILE}]}-${WRFKEY} ))
      else
         (( INTERVAL_SS=${TARGKEY}-${WRFKEY} ))
      fi
      (( INTERVAL_MIN=${INTERVAL_SS}/60 ))
      export END_STRING=`echo ${START_STRING} ${INTERVAL_SS}s -w | ./advance_time`
      export END_YEAR=`echo ${END_STRING} | cut -c1-4`
      export END_MONTH=`echo $END_STRING | cut -c6-7`
      export END_DAY=`echo $END_STRING | cut -c9-10`
      export END_HOUR=`echo $END_STRING | cut -c12-13`
      export END_MIN=`echo $END_STRING | cut -c15-16`
      export END_SEC=`echo $END_STRING | cut -c18-19`
#
# Update boundary conditions.
      if ${USE_WRFVAR}; then
#
# Set the covariance perturbation scales
         if [[ -f ${CENTRALDIR}/bc_pert_scale ]]; then
            export PSCALE=`head -1 ${CENTRALDIR}/bc_pert_scale | tail -1`
            export HSCALE=`head -2 ${CENTRALDIR}/bc_pert_scale | tail -1`
            export VSCALE=`head -3 ${CENTRALDIR}/bc_pert_scale | tail -1`
         else
            let PSCALE=0.25
            let HSCALE=1.0
            let VSCALE=1.5
         fi
         (( ISEED2=${ENSEMBLE_MEMBER}*10000 ))
#
# Set WRFDA namelist parameters and create namelist
         export NL_ANALYSIS_DATE=${ENS_STRING}
         export NL_AS1_1=${PSCALE}
         export NL_AS1_2=${HSCALE}
         export NL_AS1_3=${VSCALE}
         export NL_AS2_1=${PSCALE}
         export NL_AS2_2=${HSCALE}
         export NL_AS2_3=${VSCALE}
         export NL_AS3_1=${PSCALE}
         export NL_AS3_2=${HSCALE}
         export NL_AS3_3=${VSCALE}
         export NL_AS4_1=${PSCALE}
         export NL_AS4_2=${HSCALE}
         export NL_AS4_3=${VSCALE}
         export NL_AS5_1=${PSCALE}
         export NL_AS5_2=${HSCALE}
         export NL_AS5_3=${VSCALE}
         export NL_SEED_ARRAY1=${END_YEAR}${END_MONTH}${END_DAY}${END_HOUR}
         export NL_SEED_ARRAY2=${ISEED2}
         export NL_START_YEAR=${END_YEAR}
         export NL_START_MONTH=${END_MONTH}
         export NL_START_DAY=${END_DAY}
         export NL_START_HOUR=${END_HOUR}
         export NL_START_MINUTE=${END_MIN}
         export NL_START_SECOND=${END_SEC}
         export NL_END_YEAR=${END_YEAR}
         export NL_END_MONTH=${END_MONTH}
         export NL_END_DAY=${END_DAY}
         export NL_END_HOUR=${END_HOUR}
         export NL_END_MINUTE=${END_MIN}
         export NL_END_SECOND=${END_SEC}
         export NL_MAX_DOM=${DOMAIN}
         rm namelist.input
         ${DART_DIR}/models/wrf_chem/namelist_scripts/WRFCHEM/wrfchem_create_namelist.input.ksh
#
# Run WRFDA on the ensemble mean field
         ln -sf ${CENTRALDIR}/WRF/wrfinput_d01_${targdays}_${targsecs}_mean ./fg
         ${CENTRALDIR}/WRF_RUN/da_wrfvar.exe
#
# Run pert_wrf_bc
         mv wrfvar_output wrfinput_next
         ln -sf wrfinput_d01 wrfinput_this
         ln -sf wrfbdy_d01 wrfbdy_this
         if [[ -f wrfinput_mean ]]; then
            mv wrfinput_mean wrfinput_this_mean
            mv fg wrfinput_next_mean
         fi
         ${CENTRALDIR}/pert_wrf_bc >&! out.pert_wrf_bc
         rm -rf wrfinput_this wrfinput_next wrfbdy_this
         if [[ -f wrfinput_this_mean ]]; then rm -rf wrfinput_this_mean wrfinput_next_mean; fi
      else
         ${CENTRALDIR}/update_wrf_bc
      fi
#
# Set WRF namelist.input parameters and create namelist
      export NL_RUN_HOURS=0
      export NL_RUN_MINUTES=0
      export NL_RUN_SECONDS=${INTERVAL_SS}
      export NL_START_YEAR=${START_YEAR}
      export NL_START_MONTH=${START_MONTH}
      export NL_START_DAY=${START_DAY}
      export NL_START_HOUR=${START_HOUR}
      export NL_START_MINUTE=${START_MIN}
      export NL_START_SECOND=${START_SEC}
      export NL_END_YEAR=${END_YEAR}
      export NL_END_MONTH=${END_MONTH}
      export NL_END_DAY=${END_DAY}
      export NL_END_HOUR=${END_HOUR}
      export NL_END_MINUTE=${END_MIN}
      export NL_END_SECOND=${END_SEC}
      export NL_MAX_DOM=${DOMAIN}
      rm namelist.input
      ${DART_DIR}/models/wrf_chem/namelist_scripts/WRFCHEM/wrfchem_create_namelist.input.ksh
#
# Run wrfchem
      mpirun.lsf ./wrf.exe > index_wrf 2>&1 
      export RC=$?
      if [[ -f WRFCHEM_SUCCESS ]]; then rm -rf SUCCESS; fi     
      if [[ -f WRFCHEM_FAILED ]]; then rm -rf FAILED; fi     
      if [[ $RC = 0 ]]; then
         touch WRFCHEM_SUCCESS
      else
         touch WRFCHEM_FAILED 
         echo WRFCHEM FAILURE FOR ${END_STRING} FORECAST
         exit
      fi
      export START_YEAR=${END_YEAR}
      export START_MONTH=${END_MONTH}
      export START_DAY=${END_DAY}
      export START_HOUR=${END_HOUR}
      export START_MIN=${END_MIN}
      export START_SEC=${END_SEC}
      export WRFKEY=${KEYS[${FILE}]}
      (( FILE=${FILE}+1 ))
   done
   (( STATE_COPY=${STATE_COPY}+1 ))
done
exit



#
# <next few lines under version control, do not edit>
# $URL$
# $Id$
# $Revision$
# $Date$
