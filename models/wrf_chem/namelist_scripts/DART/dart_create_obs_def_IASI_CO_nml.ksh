#!/bin/ksh -x
#########################################################################
#
# Purpose: Create DART &obs_def_IASI_CO_nml 
#
#########################################################################
#
# Generate namelist section
rm -f input.nml_temp
touch input.nml_temp
cat > input.nml_temp << EOF
 &obs_def_IASI_CO_nml
   IASI_CO_retrieval_type   = ${NL_IASI_CO_RETRIEVAL_TYPE:-'RAWR'},
   use_log_co   = ${NL_USE_LOG_CO:-.false.},
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


