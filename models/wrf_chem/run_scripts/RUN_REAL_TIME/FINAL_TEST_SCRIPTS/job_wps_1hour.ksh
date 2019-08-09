#!/bin/bash
#SBATCH --job-name=CAFIRE_radm2_1hour                          # job name
#SBATCH --output=CAFIRE_radm2_1hour.out                      # output filename
#SBATCH --error=CAFIRE_radm2_1hour.err                      # error filename
#SBATCH --partition=high_mem
#SBATCH --qos=long+
#SBATCH --time=120:00:00                              # wallclock time (minutes)
##SBATCH --constraint=hpcf2013
#SBATCH --mem=max
#
./real_time_CAFIRE_RETR_taki_tolnet_radm2_wps_1hour.ksh  > index_CAFIRE_radm2_1hour.html 2>&1
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

