#!/bin/ksh -aeux
#
export PROJ_NUMBER=P19010000
#
# compile code
ifort -check none -CB -C localize_obs_seq_MOPITT_CO.f90 -o localize_obs_seq_MOPITT_CO.exe -lncarg -lncarg_gks -lncarg_c -lX11 -lXext -lcairo -lfontconfig -lpixman-1 -lfreetype -lexpat -lpng -lz -lpthread -lbz2 -lXrender -lgfortran -lnetcdff -lnetcdf
./localize_obs_seq_MOPITT_CO.exe
exit
#
# Create job script 
RANDOM=$$
export JOBRND=job_$RANDOM
rm -rf job_*.ksh
touch ${JOBRND}.ksh
cat << EOF >${JOBRND}.ksh
#!/bin/ksh -aeux
#BSUB -P ${PROJ_NUMBER}
#BSUB -n 1                                  # number of total (MPI) tasks
#BSUB -J ${JOBRND}                          # job name
#BSUB -o ${JOBRND}.out                      # output filename
#BSUB -e ${JOBRND}.err                      # error filename
#BSUB -W 00:10                              # wallclock time (minutes)
#BSUB -q geyser
#
rm -rf job_*.out
rm -rf job_*.err
rm -rf job_*.index
./localize_obs_seq_MOPITT_CO.exe > ${JOBRND}.index 2>&1 
#
export RC=\$?     
if [[ -f JOB_SUCCESS ]]; then rm -rf JOB_SUCCESS; fi     
if [[ -f JOB_FAILED ]]; then rm -rf JOB_FAILED; fi          
if [[ \$RC = 0 ]]; then
   touch JOB_SUCCESS
else
   touch JOB_FAILED 
   exit
fi
EOF
#
# Submit convert file script for each and wait until job completes
bsub -K < ${JOBRND}.ksh 
rm -rf ${JOBRND}.ksh
#
exit
#







