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
# Purpose: Script to create DART/WRF input.nmlfor Ave's 
# mopitt_ascii_to_obs_seq fortran format conversion 
#
#########################################################################
#
# CREATE DART/WRF NAMELIST FILE
rm -f input.nml
touch input.nml
cat > input.nml << EOF
&create_mopitt_obs_nml
   year                        = ${NL_YEAR}
   month                       = ${NL_MONTH}
   day                         = ${NL_DAY}
   hour                        = ${NL_HOUR}
   bin_beg                     = ${NL_BIN_BEG}
   bin_end                     = ${NL_BIN_END}
   filedir                     = ${NL_FILEDIR}
   filename                    = ${NL_FILENAME}
   MOPITT_CO_retrieval_type    = ${NL_MOPITT_CO_RETRIEVAL_TYPE}
   fac_obs_error               = ${NL_FAC_OBS_ERROR}
   use_log_co                  = ${NL_USE_LOG_CO}
   use_cpsr_co_trunc           = ${NL_USE_CPSR_CO_TRUNC}
   cpsr_co_trunc_lim           = ${NL_CPSR_CO_TRUNC_LIM}
   mopitt_co_vloc              = ${NL_MOPITT_CO_VLOC}
/
&obs_sequence_nml
   write_binary_obs_sequence   = .false.
/
&obs_kind_nml
/
&assim_model_nml
   write_binary_restart_files  =.true.
/
&model_nml
/
&location_nml
/
&utilities_nml
   TERMLEVEL                   = 1,
   logfilename                 = 'dart_log.out',
/
&preprocess_nml
   input_obs_kind_mod_file     = '../../obs_kind/DEFAULT_obs_kind_mod.F90',
   output_obs_kind_mod_file    = '../../obs_kind/obs_kind_mod.f90',
   input_obs_def_mod_file      = '../../obs_def/DEFAULT_obs_def_mod.F90',
   output_obs_def_mod_file     = '../../obs_def/obs_def_mod.f90',
   input_files                 = '../../obs_def/obs_def_reanalysis_bufr_mod.f90',
                                 '../../obs_def/obs_def_gps_mod.f90',
                                 '../../obs_def/obs_def_eval_mod.f90'
/
&merge_obs_seq_nml
   num_input_files             = 2,
   filename_seq                = 'obs_seq2008022206',obs_seq2008022212',
   filename_out                = 'obs_seq_ncep_2008022212'
/
&obs_def_MOPITT_CO_nml
   MOPITT_CO_retrieval_type    = ${NL_MOPITT_CO_RETRIEVAL_TYPE:-'RETR'},
   use_log_co                  = ${NL_USE_LOG_CO:-.false.},
/ 
&obs_def_IASI_CO_nml
   IASI_CO_retrieval_type      = ${NL_IASI_CO_RETRIEVAL_TYPE:-'RETR'},
   use_log_co                  = ${NL_USE_LOG_CO:-.false.},
/ 
EOF


#
# <next few lines under version control, do not edit>
# $URL$
# $Id$
# $Revision$
# $Date$
