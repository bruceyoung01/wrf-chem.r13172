#!/bin/ksh -aeux
#
# DART software - Copyright UCAR. This open source software is provided
# by UCAR, "as is", without charge, subject to all terms of use at
# http://www.image.ucar.edu/DAReS/DART/DART_download
#
# $Id$
#

#
# Set experiment parameters
#
# 2008 case dates
#export DATE_START=2008061006
#export DATE_END=2008062000
export DATE_START=2008060112
export DATE_END=2008060706
#export DATE_END=2008063018
#export DATE_END=2008062806
#
# FRAPPE case dates
#export DATE_START=2014071406
#export DATE_END=2014071906
#
export TIME_INC=6
export DELETE_FLG=false
#
# Script to get files from HSI:
export WRFDA_VERSION=WRFDAv3.4_dmpar
export BUILD_DIR=/glade/p/work/mizzi/TRUNK/${WRFDA_VERSION}/var/build
#
# Experiment directories
#export EXP_DIR=MOPnXXX_Exp_2_MgDA_20M_100km_COnXX_CPSR_p40p40_f1p0
#export EXP_DIR=MOPnXXX_Exp_2_MgDA_20M_100km_COnXX_QOR_p40p40_f1p0
#export EXP_DIR=MOPnXXX_Exp_2_MgDA_20M_100km_COnXX_NO_SCALE_p40p40_f1p0
#export EXP_DIR=MOPnXXX_Exp_2_MgDA_20M_100km_COnXX_NO_ROT_p40p40_f1p0
#export EXP_DIR=MOPnXXX_Exp_2_MgDA_20M_100km_COnXX_RETR_p40p40_f1p0
##export EXP_DIR=MOPnXXX_Exp_2_MgDA_20M_100km_COnXX_RAWR_UNCOR_n95p40p40_f1p0
##export EXP_DIR=MOPnXXX_Exp_2_MgDA_20M_100km_COnXX_RAWR_UNCOR_n95p10p40_f1p0
##export EXP_DIR=MOPnXXX_Exp_2_MgDA_20M_100km_COnXX_RAWR_CORR_n95p20p40_f1p0
##export EXP_DIR=MOPnXXX_Exp_2_MgDA_20M_100km_COnXX_RAWR_CORR_n95p10p40_f1p0
##export EXP_DIR=MOPnXXX_Exp_2_MgDA_20M_100km_COnXX_RAWR_CORR_n80p10p30_f1p0
export EXP_DIR=MOPnXXX_Exp_2_MgDA_20M_100km_COnXX_RAWR_CORR_EINV_n80p10p30_f1p0
##export EXP_DIR=MOPnXXX_Exp_2_MgDA_20M_100km_COnXX_RAWR_CORR_n40p10p30_f1p0
#
#export EXP_DIR=XXXnIAS_Exp_2_MgDA_20M_100km_COnXX_NO_ROT_p40p40_f1p0_
#export EXP_DIR=XXXnIAS_Exp_2_MgDA_20M_100km_COnXX_NO_ROT_p10p30_f1p0_lp025
#export EXP_DIR=XXXnIAS_Exp_2_MgDA_20M_100km_XXnO3_NO_ROT_p40p40_f1p0
#export EXP_DIR=MOPnXXX_Exp_2_MgDA_20M_100km_COnXX_NO_ROT_p40p40_f1p0
#export EXP_DIR=real_FRAPPE_CNTL_VARLOC
#export EXP_DIR=real_FRAPPE_CNTL_NVARLOC
#export EXP_DIR=real_FRAPPE_COnXX_VARLOC
#export EXP_DIR=real_FRAPPE_COnXX_NVARLOC
#
export SCRATCH_DIR=/glade/scratch/mizzi/DART_TEST_AVE/${EXP_DIR}
export ACD_DIR=/glade/p/acd/mizzi/DART_TEST_AVE/${EXP_DIR}
export FRAPPE_DIR=/glade/p/FRAPPE/${EXP_DIR}
export DATA_DIR=${FRAPPE_DIR}
export DATA_DIR=${SCRATCH_DIR}
#
# for 2008 case DATA_DIR=SCRATCH_DIR
# for FRAPPE case DATA_DIR=FRAPPE_DIR
#
if [[ ! -d ${ACD_DIR} ]]; then
   mkdir -p ${ACD_DIR}
fi
cd ${ACD_DIR}
export L_DATE=${DATE_START}
#
# Copy file into ${L_DATE} subdirectory
while [[ ${L_DATE} -le ${DATE_END} ]] ; do
   echo 'copy '${L_DATE}
   if [[ ! -d ${ACD_DIR}/${L_DATE}/dart_filter ]]; then
      mkdir -p ${ACD_DIR}/${L_DATE}/dart_filter
   fi
   cd ${ACD_DIR}/${L_DATE}/dart_filter
   if [[ -f Prior_Diag.nc && ${DELETE_FLG} == true ]]; then rm -rf Prior_Diag.nc; fi
   if [[ -f Posterior_Diag.nc && ${DELETE_FLG} == true ]]; then rm -rf Posterior_Diag.nc; fi
   if [[ ! -f Prior_Diag.nc ]]; then
      if [[ -e ${DATA_DIR}/${L_DATE}/dart_filter/Prior_Diag.nc ]]; then
         cp ${DATA_DIR}/${L_DATE}/dart_filter/Prior_Diag.nc ./.
      fi
   fi
   if [[ ! -f Posterior_Diag.nc ]]; then 
      if [[ -e ${DATA_DIR}/${L_DATE}/dart_filter/Posterior_Diag.nc ]]; then
         cp ${DATA_DIR}/${L_DATE}/dart_filter/Posterior_Diag.nc ./.
      fi
   fi
   export L_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} ${TIME_INC} 2>/dev/null)
done
#
# Concatenate files
cd ${ACD_DIR}
export PRIOR_CAT_FILE=${ACD_DIR}/Cat_Prior_Diag.nc
export POST_CAT_FILE=${ACD_DIR}/Cat_Posterior_Diag.nc
if [[ -f ${PRIOR_CAT_FILE} ]]; then
  rm ${PRIOR_CAT_FILE}
fi
if [[ -f ${POST_CAT_FILE} ]]; then
  rm ${POST_CAT_FILE}
fi
#
# Copy first date
export L_DATE=${DATE_START}
cp ${ACD_DIR}/${L_DATE}/dart_filter/Prior_Diag.nc old_prior_file.nc 
cp ${ACD_DIR}/${L_DATE}/dart_filter/Posterior_Diag.nc old_post_file.nc 
#
# Advance date
export L_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} ${TIME_INC} 2>/dev/null)
#
# Concatenate remaining dates
while [[ ${L_DATE} -le ${DATE_END} ]] ; do
   echo 'copy '${L_DATE}
   export NEW_PRIOR_FILE=${ACD_DIR}/${L_DATE}/dart_filter/Prior_Diag.nc
   export NEW_POST_FILE=${ACD_DIR}/${L_DATE}/dart_filter/Posterior_Diag.nc
   ncrcat old_prior_file.nc ${NEW_PRIOR_FILE} new_prior_file.nc
   ncrcat old_post_file.nc ${NEW_POST_FILE} new_post_file.nc
   rm old_prior_file.nc
   rm old_post_file.nc
   mv new_prior_file.nc old_prior_file.nc 
   mv new_post_file.nc old_post_file.nc 
   export L_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} ${TIME_INC} 2>/dev/null)
done
#
# Save archive files
mv old_prior_file.nc ${PRIOR_CAT_FILE}
mv old_post_file.nc ${POST_CAT_FILE}
exit
#
# <next few lines under version control, do not edit>
# $URL$
# $Id$
# $Revision$
# $Date$
