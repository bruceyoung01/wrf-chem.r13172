#!/bin/ksh -x
#########################################################################
#
# Purpose: Create anthro_nml 
#
#########################################################################
#
# Generate namelist section
echo off
rm -f epa_anthro_nml.tmp
touch epa_anthro_nml.tmp
cat > epa_anthro_nml.tmp << EOF
#
# File directories
&CONTROL
   anthro_dir                       = ${NL_ANTHRO_DIR:-' '},
   wrf_dir                          = ${NL_WRF_DIR:-' '},
   sec_file_prefix                  = ${NL_SEC_FILE_PREFIX:-' '},
   sec_file_suffix                  = ${NL_SEC_FILE_SUFFIX:-' '},
   stk_file_prefix                  = ${NL_STK_FILE_PREFIX:-' '},
   stk_file_suffix                  = ${NL_STK_FILE_SUFFIX:-.' '},
   stk_grp_file_prefix              = ${NL_STK_GRP_FILE_PREFIX:-'stack_groups_'},
   stk_grp_file_suffix              = ${NL_STK_GRP_FILE_SUFFIX:-' '},
   sectorlist_flnm                  = ${NL_SECTORLIST_FLNM:-' '},
   smk_merge_flnm                   = ${NL_SMK_MERGE_FLNM:-' '},
   start_output_time                = ${NL_START_OUTPUT_TIME:-' '},
   stop_output_time                 = ${NL_STOP_OUTPUT_TIME:-' '},
   output_interval                  = ${NL_OUTPUT_INTERVAL:-3600},
   emis_map                         = ${NL_EMIS_MAP:-' '},
   src_names                        = ${NL_SRC_NAMES:-' '},
   sub_categories                   = ${NL_SUB_CATEGORIES:-' '},
   cat_var_prefix                   = ${NL_CAT_VAR_PREFIX:-' '},
   cat_var_suffix                   = ${NL_CAT_VAR_SUFFIX:-' '},
   src_lon_dim_name                 = ${NL_SRC_LON_DIM_NAME:-'COL'},
   src_lat_dim_name                 = ${NL_SRC_LAT_DIM_NAME:-'ROW'},
   domains                          = ${NL_DOMAINS:-1},
   emissions_zdim_stag              = ${NL_EMISSIONS_ZDIM_STAG:-10},
/
EOF
#
# Append namelist section to anthro_nml
if [[ -f epa_anthro_nml ]]; then
   cat epa_anthro_nml.temp >> epa_anthro_nml
   rm epa_anthro_nml.tmp
else
   mv epa_anthro_nml.tmp epa_anthro_nml
fi
echo on
