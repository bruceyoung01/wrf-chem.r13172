#!/bin/ksh -x
#
# DART software - Copyright UCAR. This open source software is provided
# by UCAR, "as is", without charge, subject to all terms of use at
# http://www.image.ucar.edu/DAReS/DART/DART_download
#
# $Id$
#

#########################################################################
#
# Purpose: Script to create DART/WRF Namelist 

#########################################################################
#
# CREATE DART/WRF NAMELIST FILE
rm -f input.nml
touch input.nml
cat > input.nml << EOF
&obs_sequence_tool_nml
   num_input_files           = ${NL_NUM_INPUT_FILES}
   filename_seq              = ${NL_FILENAME_SEQ},
   filename_out              = ${NL_FILENAME_OUT},
   first_obs_days            = ${NL_FIRST_OBS_DAYS},
   first_obs_seconds         = ${NL_FIRST_OBS_SECONDS},
   last_obs_days             = ${NL_LAST_OBS_DAYS},
   last_obs_seconds          = ${NL_LAST_OBS_SECONDS},
   obs_types                 = '',
   keep_types                =.false.,
   print_only                =.false.,
   synonymous_copy_list      = ${NL_SYNONYMOUS_COPY_LIST},
   synonymous_qc_list        = ${NL_SYNONYMOUS_QC_LIST},
   min_lat                   = ${NL_MIN_LAT:--90.0}, 
   max_lat                   = ${NL_MAX_LAT:-90.0}, 
   min_lon                   = ${NL_MIN_LON:-0.0}, 
   max_lon                   = ${NL_MAX_LON:-360.0},
/
&obs_kind_nml
   assimilate_these_obs_types = 'RADIOSONDE_TEMPERATURE',
                                'RADIOSONDE_U_WIND_COMPONENT',
                                'RADIOSONDE_V_WIND_COMPONENT',
                                'ACARS_U_WIND_COMPONENT',
                                'ACARS_V_WIND_COMPONENT',
                                'ACARS_TEMPERATURE',
                                'AIRCRAFT_U_WIND_COMPONENT',
                                'AIRCRAFT_V_WIND_COMPONENT',
                                'AIRCRAFT_TEMPERATURE',
                                'SAT_U_WIND_COMPONENT',
                                'SAT_V_WIND_COMPONENT',
                                'MODIS_AOD_RETRIEVAL',
                                'IASI_CO_RETRIEVAL',
                                'IASI_O3_RETRIEVAL',
                                'MOPITT_CO_RETRIEVAL',
/
 &location_nml
   horiz_dist_only                 = .true.,
   vert_normalization_pressure     = 187500.0,
   vert_normalization_height       = 5000000.0,
   vert_normalization_level        = 2666.7,
   approximate_distance            = .false.,
   nlon                            = 141,
   nlat                            = 72,
   output_box_info                 = .false.,
/
 &obs_sequence_nml
   write_binary_obs_sequence   = .false.
/
 &utilities_nml
   TERMLEVEL                   = 1,
   logfilename                 = 'dart_log.out',
   nmlfilename                 = 'dart_log.nml',
   write_nml                   = 'file',
   module_details              = .false.
/
 &obs_def_MOPITT_CO_nml
   MOPITT_CO_retrieval_type   = ${NL_MOPITT_CO_RETRIEVAL_TYPE:-'RETR'},
   use_log_co   = ${NL_USE_LOG_CO:-.false.},
/
 &obs_def_IASI_CO_nml
   IASI_CO_retrieval_type   = ${NL_IASI_CO_RETRIEVAL_TYPE:-'RAWR'},
   use_log_co   = ${NL_USE_LOG_CO:-.false.},
/
 &obs_def_IASI_O3_nml
   IASI_O3_retrieval_type   = ${NL_IASI_O3_RETRIEVAL_TYPE:-'RAWR'},
   use_log_o3   = ${NL_USE_LOG_o3:-.false.},
/
EOF


#
# <next few lines under version control, do not edit>
# $URL$
# $Id$
# $Revision$
# $Date$
