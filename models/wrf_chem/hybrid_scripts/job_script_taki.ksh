#!/bin/ksh -aeux
#
# DART software - Copyright UCAR. This open source software is provided
# by UCAR, "as is", without charge, subject to all terms of use at
# http://www.image.ucar.edu/DAReS/DART/DART_download
#
# $Id$
#

export JOBID=$1
export CLASS=$2
export TIME_LIMIT=$3
export NODES=$4
export TASKS=$5
export EXECUTE=$6
export TYPE=$7
RANDOM=$$
#
if [[ -f job.ksh ]]; then rm -rf job.ksh; fi
touch job.ksh
#
if [[ ${TYPE} == PARALLEL ]]; then
#
# for parallel job
   cat << EOF > job.ksh
#!/bin/bash
#SBATCH --job-name ${JOBID}
#SBATCH --qos ${CLASS}
#SBATCH --time ${TIME_LIMIT}
#SBATCH --output ${JOBID}.log
#SBATCH --nodes ${NODES}
#SBATCH --ntasks ${TASKS}
#SBATCH --partition high_mem
#SBATCH --mem=max
module load mpich/ge/gcc/64/3.2.1
/usr/ebuild/software/OpenMPI/3.1.1-GCC-7.3.0-2.30/bin/mpirun -np \${SLURM_NTASKS} ./${EXECUTE} > index_${RANDOM}.html 2>&1
export RC=\$?     
if [[ -f SUCCESS ]]; then rm -rf SUCCESS; fi     
if [[ -f FAILED ]]; then rm -rf FAILED; fi          
if [[ \$RC = 0 ]]; then
   touch SUCCESS
else
   touch FAILED 
   exit
fi
EOF
#
elif [[ ${TYPE} == SERIAL ]]; then
#
# for serial job
   cat << EOF > job.ksh
#!/bin/bash
#SBATCH --job-name ${JOBID}
#SBATCH --qos ${CLASS}
#SBATCH --time ${TIME_LIMIT}
#SBATCH --output ${JOBID}.log-%j.out
#SBATCH --nodes ${NODES}
#SBATCH --ntasks ${TASKS}
#SBATCH --partition high_mem
#SBATCH --mem=max
./${EXECUTE} > index_${RANDOM}.html 2>&1
export RC=\$?     
if [[ -f SUCCESS ]]; then rm -rf SUCCESS; fi     
if [[ -f FAILED ]]; then rm -rf FAILED; fi          
if [[ \$RC = 0 ]]; then
   touch SUCCESS
else
   touch FAILED 
   exit
fi
EOF
#
else
   echo 'APM: Error is job script - Not SERIAL or PARALLEL '
   exit
fi

#
# <next few lines under version control, do not edit>
# $URL$
# $Id$
# $Revision$
# $Date$
