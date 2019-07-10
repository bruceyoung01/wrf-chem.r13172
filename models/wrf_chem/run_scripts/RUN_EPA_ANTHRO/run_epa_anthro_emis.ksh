#!/bin/ksh -aeux
##########################################################################
#
# Script to run epa_anthro_emis to generate wrfchem_chemi_d0x emissions
#
#########################################################################
#
# START CYCLE DATE-TIME:
export CYCLE_STR_DATE=2014071400
#
# END CYCLE DATE-TIME:
export CYCLE_END_DATE=${CYCLE_STR_DATE}
export CYCLE_END_DATE=2014071406
#
# CODE VERSIONS:
export WPS_VER=WPSv3.9.1.1_dmpar
export WPS_GEOG_VER=GEOG_DATA
export WRFDA_VER=WRFDAv3.9.1.1_dmpar
export WRF_VER=WRFv3.9.1.1_dmpar
export WRFCHEM_VER=WRFChemv3.9.1.1_dmpar
export DART_VER=DART_CHEM_REPOSITORY
export ANTHRO_VER=EPA_ANTHRO_EMIS
#
# ROOT DIRECTORIES:
export SCRATCH_DIR=/scratch/summit/mizzi
export WORK_DIR=/projects/mizzi
export INPUT_DATA_DIR=/summit/mizzi
#
# DEPENDENT INPUT DATA DIRECTORIES:
export EXP_DIR=${SCRATCH_DIR}/real_FRAPPE_RETR_CONTROL
export RUN_DIR=${SCRATCH_DIR}/run_anthro
export TRUNK_DIR=${WORK_DIR}/TRUNK
export WPS_DIR=${TRUNK_DIR}/${WPS_VER}
export WPS_GEOG_DIR=${INPUT_DATA_DIR}/${WPS_GEOG_VER}
export WRFCHEM_DIR=${TRUNK_DIR}/${WRFCHEM_VER}
export WRFDA_DIR=${TRUNK_DIR}/${WRFDA_VER}
export DART_DIR=${TRUNK_DIR}/${DART_VER}
export BUILD_DIR=${WRFDA_DIR}/var/da
export WRF_DIR=${TRUNK_DIR}/${WRF_VER}
export ANTHRO_DIR=${TRUNK_DIR}/${ANTHRO_VER}/src
export NAMELIST_SCRIPTS_DIR=${TRUNK_DIR}/${DART_VER}/models/wrf_chem/namelist_scripts
export ANTHRO_INPUT_DATA=${INPUT_DATA_DIR}/ANTHRO_2014_INPUT_DATA/cmaq_cb6
#
export DOMAINS=1
export CYCLE_PERIOD=6
#
export DATE=${CYCLE_STR_DATE}
export YYYY=$(echo $DATE | cut -c1-4)
export YY=$(echo $DATE | cut -c3-4)
export MM=$(echo $DATE | cut -c5-6)
export DD=$(echo $DATE | cut -c7-8)
export HH=$(echo $DATE | cut -c9-10)
export FILE_STR_DATE=${YYYY}-${MM}-${DD}_${HH}:00:00
#
export DATE=${CYCLE_END_DATE}
export YYYY=$(echo $DATE | cut -c1-4)
export YY=$(echo $DATE | cut -c3-4)
export MM=$(echo $DATE | cut -c5-6)
export DD=$(echo $DATE | cut -c7-8)
export HH=$(echo $DATE | cut -c9-10)
export FILE_END_DATE=${YYYY}-${MM}-${DD}_${HH}:00:00
#
#########################################################################
#
#  NAMELIST PARAMETERS
#
#########################################################################
#
# File directories
export NL_ANTHRO_DIR=\'${ANTHRO_INPUT_DATA}\'
export NL_WRF_DIR=\'${RUN_DIR}\'
#
# EPA filenames
export NL_SEC_FILE_PREFIX=\'emis_mole_\'
export NL_SEC_FILE_SUFFIX=\'_12US2_nobeis_2014fd_nata_cb6_14j_nohap.nc4\'
export NL_STK_FILE_PREFIX=\'inln_mole_\'
export NL_STK_FILE_SUFFIX=\'_12US2_cmaq_cb6_2014fd_nata_cb6_14j_nohap.nc4\'
#export NL_STK_GRP_FILE_PREFIX=' '
export NL_STK_GRP_FILE_SUFFIX=\'_12US2_2014fd_nata_cb6_14j_nohap.nc4\'
#export NL_SECTORLIST_FLNM=' '
#export NL_SMK_MERGE_FLNM=' '
#
# Timing
export NL_START_OUTPUT_TIME=${FILE_STR_DATE}
export NL_STOP_OUTPUT_TIME=${FILE_END_DATE}
export NL_OUTPUT_INTERVAL=3600
#
# Emissions mapping
export NL_EMIS_MAP="'"'CO->all(CO)+cmv_c3(CO)+othpt(CO)+ptegu(CO)+ptnonipm(CO)+pt_oilgas(CO)'"'","'"'NO->all(NO)+cmv_c3(NO)+othpt(NO)+ptegu(NO)+ptnonipm(NO)+pt_oilgas(NO)'"'","'"'NO2->all(NO2)+cmv_c3(NO2)+othpt(NO2)+ptegu(NO2)+ptnonipm(NO2)+pt_oilgas(NO2)'"'","'"'SO2->all(SO2)+cmv_c3(SO2)+othpt(SO2)+ptegu(SO2)+ptnonipm(SO2)+pt_oilgas(SO2)'"'","'"'NH3->all(NH3)+cmv_c3(NH3)+othpt(NH3)+ptegu(NH3)+ptnonipm(NH3)+pt_oilgas(NH3)'"'","'"'C2H5OH->all(ETOH)+cmv_c3(ETOH)+othpt(ETOH)+ptegu(ETOH)+ptnonipm(ETOH)+pt_oilgas(ETOH)'"'","'"'BIGALK->.2*all(PAR)+.2*cmv_c3(PAR)+.2*othpt(PAR)+.2*ptegu(PAR)+.2*ptnonipm(PAR)+.2*pt_oilgas(PAR)'"'","'"'BIGENE->all(IOLE)+cmv_c3(IOLE)+othpt(IOLE)+ptegu(IOLE)+ptnonipm(IOLE)+pt_oilgas(IOLE)'"'","'"'C2H4->all(ETH)+cmv_c3(ETH)+othpt(ETH)+ptegu(ETH)+ptnonipm(ETH)+pt_oilgas(ETH)'"'","'"'C2H6->all(ETHA)+cmv_c3(ETHA)+othpt(ETHA)+ptegu(ETHA)+ptnonipm(ETHA)+pt_oilgas(ETHA)'"'","'"'C3H6->all(OLE)+cmv_c3(OLE)+othpt(OLE)+ptegu(OLE)+ptnonipm(OLE)+pt_oilgas(OLE)'"'","'"'C3H8->all(PRPA)+cmv_c3(PRPA)+othpt(PRPA)+ptegu(PRPA)+ptnonipm(PRPA)+pt_oilgas(PRPA)'"'","'"'CH2O->all(FORM)+cmv_c3(FORM)+othpt(FORM)+ptegu(FORM)+ptnonipm(FORM)+pt_oilgas(FORM)'"'","'"'CH3CHO->all(ALD2+ALDX)+cmv_c3(ALD2+ALDX)+othpt(ALD2+ALDX)+ptegu(ALD2+ALDX)+ptnonipm(ALD2+ALDX)+pt_oilgas(ALD2+ALDX)'"'","'"'CH3COCH3->all(ACET)+cmv_c3(ACET)+othpt(ACET)+ptegu(ACET)+ptnonipm(ACET)+pt_oilgas(ACET)'"'","'"'CH3OH->all(MEOH)+cmv_c3(MEOH)+othpt(MEOH)+ptegu(MEOH)+ptnonipm(MEOH)+pt_oilgas(MEOH)'"'","'"'MEK->all(KET)+cmv_c3(KET)+othpt(KET)+ptegu(KET)+ptnonipm(KET)+pt_oilgas(KET)'"'","'"'TOLUENE->all(TOL)+cmv_c3(TOL)+othpt(TOL)+ptegu(TOL)+ptnonipm(TOL)+pt_oilgas(TOL)'"'","'"'BENZENE->all(BENZ)+cmv_c3(BENZ)+othpt(BENZ)+ptegu(BENZ)+ptnonipm(BENZ)+pt_oilgas(BENZ)'"'","'"'XYLENE->all(XYLMN)+cmv_c3(XYLMN)+othpt(XYLMN)+ptegu(XYLMN)+ptnonipm(XYLMN)+pt_oilgas(XYLMN)'"'","'"'ISOP->all(ISOP)+cmv_c3(ISOP)+othpt(ISOP)+ptegu(ISOP)+ptnonipm(ISOP)+pt_oilgas(ISOP)'"'","'"'C10H16->all(TERP)+cmv_c3(TERP)+othpt(TERP)+ptegu(TERP)+ptnonipm(TERP)+pt_oilgas(TERP)'"'","'"'sulf->all(SULF)+cmv_c3(SULF)+othpt(SULF)+ptegu(SULF)+ptnonipm(SULF)+pt_oilgas(SULF)'"'","'"'C2H2->all(ETHY)+cmv_c3(ETHY)+othpt(ETHY)+ptegu(ETHY)+ptnonipm(ETHY)+pt_oilgas(ETHY)'"'","'"'PM_25(A)->all(PMOTHR)+cmv_c3(PMOTHR)+othpt(PMOTHR)+ptegu(PMOTHR)+ptnonipm(PMOTHR)+pt_oilgas(PMOTHR)'"'","'"'BC(A)->all(PEC)+cmv_c3(PEC)+othpt(PEC)+ptegu(PEC)+ptnonipm(PEC)+pt_oilgas(PEC)'"'","'"'OC(A)->all(POC)+cmv_c3(POC)+othpt(POC)+ptegu(POC)+ptnonipm(POC)+pt_oilgas(POC)'"'","'"'PM_10(A)->all(PMC)+cmv_c3(PMC)+othpt(PMC)+ptegu(PMC)+ptnonipm(PMC)+pt_oilgas(PMC)'"'","'"'SO4I(A)->.15*all(PSO4)+.15*cmv_c3(PSO4)+.15*othpt(PSO4)+.15*ptegu(PSO4)+.15*ptnonipm(PSO4)+.15*pt_oilgas(PSO4)'"'","'"'SO4J(A)->.85*all(PSO4)+.85*cmv_c3(PSO4)+.85*othpt(PSO4)+.85*ptegu(PSO4)+.85*ptnonipm(PSO4)+.85*pt_oilgas(PSO4)'"'","'"'ECI(A)->.15*all(PEC)+.15*cmv_c3(PEC)+.15*othpt(PEC)+.15*ptegu(PEC)+.15*ptnonipm(PEC)+.15*pt_oilgas(PEC)'"'","'"'ECJ(A)->.85*all(PEC)+.85*cmv_c3(PEC)+.85*othpt(PEC)+.85*ptegu(PEC)+.85*ptnonipm(PEC)+.85*pt_oilgas(PEC)'"'","'"'ORGI(A)->.15*all(POC)+.15*cmv_c3(POC)+.15*othpt(POC)+.15*ptegu(POC)+.15*ptnonipm(POC)+.15*pt_oilgas(POC)'"'","'"'ORGJ(A)->.85*all(POC)+.85*cmv_c3(POC)+.85*othpt(POC)+.85*ptegu(POC)+.85*ptnonipm(POC)+.85*pt_oilgas(POC)'"'","'"'NO3I(A)->.15*all(PNO3)+.15*cmv_c3(PNO3)+.15*othpt(PNO3)+.15*ptegu(PNO3)+.15*ptnonipm(PNO3)+.15*pt_oilgas(PNO3)'"'","'"'NO3J(A)->.85*all(PNO3)+.85*cmv_c3(PNO3)+.85*othpt(PNO3)+.85*ptegu(PNO3)+.85*ptnonipm(PNO3)+.85*pt_oilgas(PNO3)'"'","'"'NH4I(A)->.15*all(PNH4)+.15*cmv_c3(PNH4)+.15*othpt(PNH4)+.15*ptegu(PNH4)+.15*ptnonipm(PNH4)+.15*pt_oilgas(PNH4)'"'","'"'NH4J(A)->.85*all(PNH4)+.85*cmv_c3(PNH4)+.85*othpt(PNH4)+.85*ptegu(PNH4)+.85*ptnonipm(PNH4)+.85*pt_oilgas(PNH4)'"'"
#
# EPA input filenames
export NL_SRC_NAMES=\'all:epa-sector\',\'cmv_c3:epa-stack\',\'othpt:epa-stack\',\'ptegu:epa-stack\',\'ptnonipm:epa-stack\',\'pt_oilgas:epa-stack\'
export NL_SUB_CATEGORIES=\'CO\',\'NO\',\'NO2\',\'SO2\',\'NH3\',\'ETOH\',\'PAR\',\'IOLE\',\'ETH\',\'ETHA\',\'OLE\',\'PRPA\',\'FORM\',\'ALD2\',\'ALDX\',\'ACET\',\'MEOH\',\'KET\',\'TOL\',\'BENZ\',\'XYLMN\',\'ISOP\',\'TERP\',\'SULF\',\'ETHY\',\'PMOTHR\',\'PEC\',\'POC\',\'PMC\',\'PSO4\',\'PNO3\',\'PNH4\'
#export NL_CAT_VAR_PREFIX=\' \'
#export NL_CAT_VAR_SUFFIX=\' \'
#
# EPA input NETCDF paramters
export NL_SRC_LON_DIM_NAME=\'COL\'
export NL_SRC_LAT_DIM_NAME=\'ROW\'
#
# WRF paramters
export NL_DOMAINS=${DOMAINS}
export NL_EMISSIONS_ZDIM_STAG=10
#
#########################################################################
#
#  LOOP THROUGH CYCLE TIMES
#
#########################################################################
#
export CYCLE_DATE=${CYCLE_STR_DATE}
while [[ ${CYCLE_DATE} -le ${CYCLE_END_DATE} ]]; do
   export DATE=${CYCLE_DATE}
   export YYYY=$(echo $DATE | cut -c1-4)
   export YY=$(echo $DATE | cut -c3-4)
   export MM=$(echo $DATE | cut -c5-6)
   export DD=$(echo $DATE | cut -c7-8)
   export HH=$(echo $DATE | cut -c9-10)
   export FILE_DATE=${YYYY}-${MM}-${DD}_${HH}:00:00
#
#########################################################################
#
#  RUN ANTHRO_EMISS
#
#########################################################################
#
   if [[ -d ${RUN_DIR} ]]; then
      cd ${RUN_DIR}
   else
      mkdir -p ${RUN_DIR}
      cd ${RUN_DIR}
   fi
#
# Copy the WRF input files
   rm -rf wrfinput_d*
   let IDM=1
   while [[ ${IDM} -le ${DOMAINS} ]]; do
      if [[ ${IDM} -lt 10 ]]; then DDM=0${IDM}; fi
      if [[ ${IDM} -ge 10 ]]; then DDM=${IDM}; fi
      export FILE=${EXP_DIR}/${DATE}/real/wrfinput_d${DDM}_${FILE_DATE}
      cp ${FILE} ./wrfinput_d${DDM}
      let IDM=${IDM}+1
   done
#
# Create epa_anthro_nml
   rm -rf epa_anthro_nml
   ${NAMELIST_SCRIPTS_DIR}/ANTHRO/create_epa_anthro_nml.ksh
#
# Copy the anthro_emiss executable
   rm -rf epa_anthro_emis
   cp ${ANTHRO_DIR}/anthro_emis ./epa_anthro_emis 
#
# Run epa_anthro_emis
   ./epa_anthro_emis < epa_anthro_nml > index.html 2>&1 
#
   export CYCLE_DATE=$(${BUILD_DIR}/da_advance_time.exe ${DATE} +${CYCLE_PERIOD} 2>/dev/null)
done
#
