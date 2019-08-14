#!/bin/ksh
#
# DART software - Copyright UCAR. This open source software is provided
# by UCAR, "as is", without charge, subject to all terms of use at
# http://www.image.ucar.edu/DAReS/DART/DART_download
#
# $Id$
#

#
# Script to hold script execution until all jobs 
# with the $1 job name have completed on taki.rs.umbc.edu
#   
# USE COMMAND squeue TO LIST ALL THE NEEDED INFO FROM MY ACCOUNT AND 
# INPUT IT INTO A FILE job_list
squeue --format="%.18i %.9P %.25j %.8u %.8T %.10M %.9l %.6D %R" -u vy57456 >job_list
# EXTRACT LINES CONTAINING JOB ID (TRANDOM) AND INPUT THEM INTO A FILE test_list
grep ${TRANDOM} job_list > test_list
# WITH OPTION "-s" TO CHECK WHETHER FILE test_list IS EMPOTY OR NOT
while [[ -s test_list ]]; do
# WAIT FOR 5 SECONDS
   sleep 5
# AGAIN USE COMMAND squeue TO LIST ALL THE NEEDED INFO FROM MY ACCOUNT AND 
# INPUT IT INTO A FILE job_list
   squeue --format="%.18i %.9P %.25j %.8u %.8T %.10M %.9l %.6D %R" -u vy57456 >job_list
# EXTRACT LINES CONTAINING JOB ID (TRANDOM) AND INPUT THEM INTO A FILE test_list
   grep ${TRANDOM} job_list > test_list
done
rm job_list test_list
#
#
# <next few lines under version control, do not edit>
# $URL$
# $Id$
# $Revision$
# $Date$
