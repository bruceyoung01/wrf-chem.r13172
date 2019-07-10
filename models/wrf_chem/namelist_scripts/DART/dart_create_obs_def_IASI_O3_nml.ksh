#!/bin/ksh -x
#########################################################################
#
# Purpose: Create DART &obs_def_IASI_O3_nml 
#
#########################################################################
#
# Generate namelist section
rm -f input.nml_temp
touch input.nml_temp
cat > input.nml_temp << EOF
 &obs_def_IASI_O3_nml
   IASI_O3_retrieval_type   = ${NL_IASI_O3_RETRIEVAL_TYPE:-'RAWR'},
   use_log_o3   = ${NL_USE_LOG_O3:-.false.},
/ 
EOF
#
# Append namelist section to input.nml
if [[ -f input.nml ]]; then
   cat input.nml_temp >> input.nml
   rm input.nml_temp
else
   mv input.nml_temp input.nml
fi


