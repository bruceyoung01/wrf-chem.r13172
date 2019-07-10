#!/bin/ksh -x
#
# DART software - Copyright UCAR. This open source software is provided
# by UCAR, "as is", without charge, subject to all terms of use at
# http://www.image.ucar.edu/DAReS/DART/DART_download
#
# $Id$
#

#
# Script to hold script execution until all jobs 
# with the $1 job name have completed on bluefire
#   
qstat -u ${USER} > job_list
grep $1 job_list > test_list
while [[ -s test_list ]]; do
   sleep 30
   qstat -u ${USER} > job_list
   grep "$1" job_list > test_list
done
rm job_list test_list
#
#
# <next few lines under version control, do not edit>
# $URL$
# $Id$
# $Revision$
# $Date$
