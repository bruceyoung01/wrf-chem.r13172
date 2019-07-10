#!/bin/ksh -aeux 
#
# DART software - Copyright UCAR. This open source software is provided
# by UCAR, "as is", without charge, subject to all terms of use at
# http://www.image.ucar.edu/DAReS/DART/DART_download
#
# $Id$
#

   export NUM_MEMBERS=20
   export DOMAIN=01
   export PROJ_NUMBER_ACD=P19010000
   export PROJ_NUMBER_NSC=NACD0006
   export DART_VER=DART_CHEM_MY_BRANCH
#
   export WORK_DIR=/glade/p/work/mizzi
   export ACD_DIR=/glade/p/acd/mizzi
   export SCRATCH_DIR=/glade/scratch/mizzi 
#
   export TRUNK_DIR=${WORK_DIR}/TRUNK
   export DART_DIR=${TRUNK_DIR}/${DART_VER}
   export HYBRID_TRUNK_DIR=${WORK_DIR}/HYBRID_TRUNK
   export HYBRID_SCRIPTS_DIR=${HYBRID_TRUNK_DIR}/hybrid_scripts
   export POST_DART_CLAMPING_DIR=${DART_DIR}/models/wrf_chem/dart_clamping
#
   export DATE=2008060306
   export EXP_DIR=MOPnXXX_Exp_2_MgDA_20M_100km_COnXX_RAWR_p40p40_f1p0
   export RUN_DIR=${SCRATCH_DIR}/DART_TEST_AVE/${EXP_DIR}/${DATE}/dart_filter
#
# Run the post-dart clamping code
   cd ${RUN_DIR}
   if [[ ! -d post_dart_clamping ]]; then
      mkdir -p post_dart_clamping
      cd post_dart_clamping
   else
      cd post_dart_clamping
   fi
#
#########################################################################
#
# RUN DART_TO_WRF 
#
#########################################################################
#
   export RAN_APM=${RANDOM}
   let MEM=1
   while [[ ${MEM} -le ${NUM_MEMBERS} ]]; do
      export CMEM=e${MEM}
      export KMEM=${MEM}
      if [[ ${MEM} -lt 1000 ]]; then export KMEM=0${MEM}; fi
      if [[ ${MEM} -lt 100 ]]; then export KMEM=00${MEM}; export CMEM=e0${MEM}; fi
      if [[ ${MEM} -lt 10 ]]; then export KMEM=000${MEM}; export CMEM=e00${MEM}; fi
#
      cd ${RUN_DIR}/post_dart_clamping
      rm -rf dart_wrk_${CMEM}
      mkdir dart_wrk_${CMEM}
      cd dart_wrk_${CMEM}
#
# &dart_to_wrf_nml
      cp ${DART_DIR}/models/wrf_chem/work/dart_to_wrf ./.
      cp ../../input.nml ./.
      cp ../../filter_ic_new.${KMEM} dart_wrf_vector
      cp ../../wrfinput_d${DOMAIN} ./.
#
# Create job script 
      rm -rf job.ksh
      touch job.ksh
      RANDOM=$$
      export JOBRND=dt2wf_${RAN_APM}
      cat << EOF >job.ksh
#!/bin/ksh -aeux
#BSUB -P ${PROJ_NUMBER_ACD}
#BSUB -n 1                                  # number of total (MPI) tasks
#BSUB -J ${JOBRND}                          # job name
#BSUB -o ${JOBRND}.out                      # output filename
#BSUB -e ${JOBRND}.err                      # error filename
#BSUB -W 00:05                              # wallclock time (minutes)
#BSUB -q geyser
#
# Run wrf_to_dart
./dart_to_wrf > index_dart_to_wrf 2>&1 
#
export RC=\$?     
rm -rf DART2WRF_SUCCESS_*
rm -rf DART2WRF_FAILED_*
if [[ \$RC = 0 ]]; then
   touch DART2WRF_SUCCESS_{RAN_APM}
else
   touch DART2WRF_FAILED_{RAN_APM}
   exit
fi
EOF
#
# Submit convert file script for each and wait until job completes
      bsub < job.ksh 
      let MEM=${MEM}+1
   done
#
# Wait for dart_to_wrf to complete for each member
   ${HYBRID_SCRIPTS_DIR}/da_run_hold.ksh ${RAN_APM}
#
#########################################################################
#
# RUN POST-DART CLAMPING
#
#########################################################################
#
   cd ${RUN_DIR}/post_dart_clamping
   cp ../wrfinput_d${DOMAIN} wrfinput_d${DOMAIN}
   let MEM=1
   while [[ ${MEM} -le ${NUM_MEMBERS} ]]; do
      export CMEM=e${MEM}
      export KMEM=${MEM}
      if [[ ${MEM} -lt 1000 ]]; then export KMEM=0${MEM}; fi
      if [[ ${MEM} -lt 100 ]]; then export KMEM=00${MEM}; export CMEM=e0${MEM}; fi
      if [[ ${MEM} -lt 10 ]]; then export KMEM=000${MEM}; export CMEM=e00${MEM}; fi
      cp ../wrfinput_d${DOMAIN}_${KMEM} pr_wrfinput_d${DOMAIN}_${KMEM}
      cp dart_wrk_${CMEM}/wrfinput_d${DOMAIN} po_wrfinput_d${DOMAIN}_${KMEM}
      cp dart_wrk_${CMEM}/wrfinput_d${DOMAIN} new_po_wrfinput_d${DOMAIN}_${KMEM}
      let MEM=${MEM}+1
   done
   cp ${POST_DART_CLAMPING_DIR}/post_dart_clamping.exe ./.
   ./post_dart_clamping.exe > index_post_dart_clamping
exit
#
#########################################################################
#
# RUN WRF_TO_DART
#
#########################################################################
#
   export RAN_APM=${RANDOM}
   let MEM=1
   while [[ ${MEM} -le ${NUM_MEMBERS} ]]; do
      export CMEM=e${MEM}
      export KMEM=${MEM}
      if [[ ${MEM} -lt 1000 ]]; then export KMEM=0${MEM}; fi
      if [[ ${MEM} -lt 100 ]]; then export KMEM=00${MEM}; export CMEM=e0${MEM}; fi
      if [[ ${MEM} -lt 10 ]]; then export KMEM=000${MEM}; export CMEM=e00${MEM}; fi
#
      cd ${RUN_DIR}/post_dart_clamping
      rm -rf dart_wrk_${CMEM}
      mkdir dart_wrk_${CMEM}
      cd dart_wrk_${CMEM}
#
# &wrf_to_dart_nml
      export NL_DART_RESTART_NAME="'../../filter_ic_new.${KMEM}'"
      export NL_PRINT_DATA_RANGES=.false.
      ${DART_DIR}/models/wrf_chem/namelist_scripts/DART/dart_create_input.nml.ksh
      cp ${DART_DIR}/models/wrf_chem/work/wrf_to_dart ./.
      cp ../new_po_wrfinput_d${DOMAIN}_${KMEM} wrfinput_d${DOMAIN}
#
# Create job script 
      rm -rf job.ksh
      touch job.ksh
      RANDOM=$$
      export JOBRND=wr2dt_${RAN_APM}
      cat << EOF >job.ksh
#!/bin/ksh -aeux
#BSUB -P ${PROJ_NUMBER_ACD}
#BSUB -n 1                                  # number of total (MPI) tasks
#BSUB -J ${JOBRND}                          # job name
#BSUB -o ${JOBRND}.out                      # output filename
#BSUB -e ${JOBRND}.err                      # error filename
#BSUB -W 00:05                              # wallclock time (minutes)
#BSUB -q geyser
#
# Run wrf_to_dart
./wrf_to_dart > index_wrf_to_dart 2>&1 
#
export RC=\$?     
rm -rf WRF2DART_SUCCESS_*
rm -rf WRF2DART_FAILED_*
if [[ \$RC = 0 ]]; then
   touch WRF2DART_SUCCESS_${RAN_APM}
else
   touch WRF2DART_FAILED_${RAN_APM} 
   exit
fi
EOF
#
# Submit convert file script for each and wait until job completes
      bsub < job.ksh 
      let MEM=${MEM}+1
   done
#
# Wait for wrf_to_dart to complete for each member
   ${HYBRID_SCRIPTS_DIR}/da_run_hold.ksh ${RAN_APM}
#
# <next few lines under version control, do not edit>
# $URL$
# $Id$
# $Revision$
# $Date$
