#!/bin/bash
#SBATCH --job-name=dart                          # job name
#SBATCH --output=dart.out                      # output filename
#SBATCH --error=dart.err                      # error filename
#SBATCH --partition=high_mem
#SBATCH --qos=long+
#SBATCH --time=120:00:00                              # wallclock time (minutes)
##SBATCH --constraint=hpcf2013
#SBATCH --mem=max
#
./real_time_PANDA_RETR_RELEASE_TEST_taki.ksh  > index_new.html 2>&1
#
export RC=$?
if [[ -f SUCCESS ]]; then rm -rf SUCCESS; fi
if [[ -f FAILED ]]; then rm -rf FAILED; fi
if [[ $RC = 0 ]]; then
   touch SUCCESS
else
   touch FAILED
   exit
fi

