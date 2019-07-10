#!/bin/ksh -aeux 
   export PROJ_NUMBER_ACD=P19010000
   export PROJ_NUMBER_NSC=NACD0006
   export PROJ_NUMBER_NSC=${PROJ_NUMBER_ACD}
   export DART_VER=DART_CHEM_MY_BRANCH_ALL
#
   export WORK_DIR=/glade/p/work/mizzi
   export ACD_DIR=/glade/p/acd/mizzi
   export SCRATCH_DIR=/glade/scratch/mizzi 
   export BUILD_DIR=/glade/p/work/mizzi/TRUNK/WRFDAv3.4_dmpar/var/da
#
   export TRUNK_DIR=${WORK_DIR}/TRUNK
   export DART_DIR=${TRUNK_DIR}/${DART_VER}
   export ADJUST_EMISS_DIR=${DART_DIR}/models/wrf_chem/run_scripts/RUN_EMISS_INV
#
   export EXP_DIR=MOPnXXX_Exp_2_MgDA_20M_100km_COnXX_RAWR_CORR_EINV_n80p10p30_f1p0
   export EXP_DIR=MOPnIASnMOD_Exp_2_MgDA_20M_100km_COnXXnAOD_CPSR_Indep_All
   export RUN_DIR=${SCRATCH_DIR}/DART_TEST_AVE/${EXP_DIR}/DART_CENTRALDIR/advance_temp_0001
#
   export DOMAIN=01
   export FCST_PERIOD=6
   export DATE=2008060112
# 
   cd ${RUN_DIR}
   export L_DATE=$(${BUILD_DIR}/da_advance_time.exe ${DATE} 1 2>/dev/null)
   export L_END_DATE=$(${BUILD_DIR}/da_advance_time.exe ${DATE} ${FCST_PERIOD} 2>/dev/null)
   cp ${ADJUST_WRFCHEMI_DIR}/adjust_chem_emiss.exe ./.
#
#########################################################################
#
# RUN ADJUST_CHEM_EMISS
#
#########################################################################
#
   while [[ ${L_DATE} -le ${L_END_DATE} ]]; do
      export L_YY=$(echo $L_DATE | cut -c1-4)
      export L_MM=$(echo $L_DATE | cut -c5-6)
      export L_DD=$(echo $L_DATE | cut -c7-8)
      export L_HH=$(echo $L_DATE | cut -c9-10)
      export L_FILE_DATE=${L_YY}-${L_MM}-${L_DD}_${L_HH}:00:00
#
      export NL_WRFCHEMI_PRIOR=wrfchemi_d${DOMAIN}_prior
      export NL_WRFCHEMI_POST=wrfchemi_d${DOMAIN}
      export NL_WRFCHEMI_OLD=wrfchemi_d${DOMAIN}_${L_FILE_DATE}
      export NL_WRFCHEMI_NEW=wrfchemi_d${DOMAIN}_new
      cp ${NL_WRFCHEMI_OLD} ${NL_WRFCHEMI_NEW}
#
# Make adjust_chem_nml for special_outlier_threshold                                                                       
      rm -rf adjust_chem_emiss.nml                                                                                            
      cat << EOF > adjust_chem_emiss.nml                                                                                       
&adjust_chem_emiss                                                                                                           
wrfchemi_prior=${NL_WRFCHEMI_PRIOR}
wrfchemi_post=${NL_WRFCHEMI_POST}
wrfchemi_old=${NL_WRFCHEMI_OLD}
wrfchemi_new=${NL_WRFCHEMI_NEW}
/
EOF
     ./adjust_chem_emiss.exe > index_adjust_chem_emiss
#
      cp ${NL_WRFCHEMI_NEW} ${NL_WRFCHEMI_OLD}
      export L_DATE=$(${BUILD_DIR}/da_advance_time.exe ${L_DATE} 1 2>/dev/null)
   done
exit
