#!/bin/ksh -x
#
# DART software - Copyright UCAR. This open source software is provided
# by UCAR, "as is", without charge, subject to all terms of use at
# http://www.image.ucar.edu/DAReS/DART/DART_download
#
# $Id$
#

#-----------------------------------------------------------------------
# Script da_run_update_bc.ksh
#
# Purpose: Update WRF lateral boundary conditions to be consistent with 
# WRFVAR analysis.
#
#-----------------------------------------------------------------------
export NL_LOW_BDY_ONLY=false
export NL_UPDATE_LSM=false

cp -f $OPS_FORC_FILE real_output 
cp -f $DA_OUTPUT_FILE wrfvar_output
cp -f $BDYCDN_IN wrfbdy_d01_input
cp -f $BDYCDN_IN wrfbdy_d01

cat > parame.in << EOF
&control_param
  wrfvar_output_file = 'wrfvar_output'
  wrf_bdy_file       = 'wrfbdy_d01'
  wrf_input          = 'real_output'
  cycling = .${CYCLING}.
  debug   = .true.
  low_bdy_only = .${NL_LOW_BDY_ONLY}. 
  update_lsm = .${NL_UPDATE_LSM}. /
EOF

cp $BUILD_DIR/da_update_bc.exe .
./da_update_bc.exe

export RC=$?
if [[ $RC != 0 ]]; then
   echo "Update_bc failed with error $RC"
   exit $RC
else
   cp wrfbdy_d01 wrfbdy_d01_output
   cp wrfbdy_d01 $BDYCDN_OUT
fi
exit $?
#
# <next few lines under version control, do not edit>
# $URL$
# $Id$
# $Revision$
# $Date$
