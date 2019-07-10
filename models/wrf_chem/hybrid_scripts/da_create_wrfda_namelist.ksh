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
# Purpose: Script to create WRFDA Namelist 

#########################################################################
#
# CREATE WRFDA NAMELIST FILE
rm -f namelist.input
touch namelist.input
cat > namelist.input << EOF
&wrfvar1
print_detail_grad                   = ${NL_PRINT_DETAIL_GRAD},
var4d                               = ${NL_VAR4D},
multi_inc                           = ${NL_MULTI_INC},
/
&wrfvar2
/
&wrfvar3
ob_format                           = ${NL_OB_FORMAT},
/
&wrfvar4
use_synopobs                        = ${NL_USE_SYNOPOBS},
use_shipsobs                        = ${NL_USE_SHIPOBS},
use_metarobs                        = ${NL_USE_METAROBS},
use_soundobs                        = ${NL_USE_SOUNDOBS},
use_pilotobs                        = ${NL_USE_PILOTOBS},
use_airepobs                        = ${NL_USE_AIREOBS},
use_geoamvobs                       = ${NL_USE_GEOAMVOBS},
use_polaramvobs                     = ${NL_USE_POLARAMVOBS},
use_bogusobs                        = ${NL_USE_BOGUSOBS},
use_buoyobs                         = ${NL_USE_BUOYOBS},
use_profilerobs                     = ${NL_USE_PROFILEROBS},
use_satemobs                        = ${NL_USE_SATEMOBS},
use_gpspwobs                        = ${NL_USE_GPSPWOBS},
use_gpsrefobs                       = ${NL_USE_GPSREFOBS},
use_ssmisobs                        = ${NL_USE_SSMIRETRIEVALOBS},
use_qscatobs                        = ${NL_USE_QSCATOBS},
use_airsretobs                      = ${NL_USE_AIRSRETOBS},
/
&wrfvar5
check_max_iv                        = ${NL_CHECK_MAX_IV},
put_rand_seed                       = ${NL_PUT_RAND_SEED},
/
&wrfvar6
ntmax                               = ${NL_NTMAX},
/
&wrfvar7
je_factor                           = ${NL_JE_FACTOR},
cv_options                          = ${NL_CV_OPTIONS},
as1                                 = ${NL_AS1},
as2                                 = ${NL_AS2},
as3                                 = ${NL_AS3},
as4                                 = ${NL_AS4},
as5                                 = ${NL_AS5},
/
&wrfvar8
/
&wrfvar9
/
trace_use                           = ${NL_TRACE_USE:-true},
/
&wrfvar10
/
&wrfvar11
cv_options_hum                      = ${NL_CV_OPTIONS_HUM},
check_rh                            = ${NL_CHECK_RH},
seed_array1                         = ${NL_SEED_ARRAY1},
seed_array2                         = ${NL_SEED_ARRAY2},
calculate_cg_cost_fn                = ${NL_CALCULATE_CG_COST_FN},
lat_stats_option                    = ${NL_LAT_STATS_OPTION},
/
&wrfvar12
/
&wrfvar13
/
&wrfvar14
/
&wrfvar15
num_pseudo                          = ${NL_NUM_PSEUDO},
pseudo_x                            = ${NL_PSEUDO_X},
pseudo_y                            = ${NL_PSEUDO_Y},
pseudo_z                            = ${NL_PSEUDO_Z},
pseudo_err                          = ${NL_PSEUDO_ERR},
pseudo_val                          = ${NL_PSEUDO_VAL}
/
&wrfvar16
ensdim_alpha                        = ${NL_ENSDIM_ALPHA},
alphacv_method                      = ${NL_ALPHACV_METHOD},
alpha_corr_type                     = ${NL_ALPHA_CORR_TYPE},
alpha_corr_scale                    = ${NL_ALPHA_CORR_SCALE},
alpha_std_dev                       = ${NL_ALPHA_STD_DEV},
alpha_vertloc                       = ${NL_ALPHA_VERTLOC},
alpha_truncation                    = ${NL_ALPHA_TRUNCATION},
/
&wrfvar17
analysis_type                       = ${NL_ANALYSIS_TYPE},
/
&wrfvar18
analysis_date                       = ${NL_ANALYSIS_DATE},
/
&wrfvar19
pseudo_var                          = ${NL_PSEUDO_VAR},
/
&wrfvar20
/
&wrfvar21
time_window_min                     = ${NL_TIME_WINDOW_MIN},
/
&wrfvar22
time_window_max                     = ${NL_TIME_WINDOW_MAX},
/
&wrfvar23
jcdfi_use                           = ${NL_JCDFI_USE},
jcdfi_io                            = ${NL_JCDFI_IO},
/
&time_control
run_days                            = ${NL_RUN_DAYS},
run_hours                           = ${NL_RUN_HOURS},
run_minutes                         = ${NL_RUN_MINUTES},
run_seconds                         = ${NL_RUN_SECONDS},
start_year                          = ${NL_START_YEAR},
start_month                         = ${NL_START_MONTH},
start_day                           = ${NL_START_DAY},
start_hour                          = ${NL_START_HOUR},
start_minute                        = ${NL_START_MINUTE},
start_second                        = ${NL_START_SECOND},
end_year                            = ${NL_END_YEAR},
end_month                           = ${NL_END_MONTH},
end_day                             = ${NL_END_DAY},
end_hour                            = ${NL_END_HOUR},
end_minute                          = ${NL_END_MINUTE},
end_second                          = ${NL_END_SECOND},
interval_seconds                    = ${NL_INTERVAL_SECONDS},
input_from_file                     = ${NL_INPUT_FROM_FILE},
history_interval                    = ${NL_HISTORY_INTERVAL},
frames_per_outfile                  = ${NL_FRAMES_PER_OUTFILE},
restart                             = ${NL_RESTART},
restart_interval                    = ${NL_RESTART_INTERVAL},
io_form_history                     = ${NL_IO_FORM_HISTORY},
io_form_restart                     = ${NL_IO_FORM_RESTART},
io_form_input                       = ${NL_IO_FORM_INPUT},
io_form_boundary                    = ${NL_IO_FORM_BOUNDARY},
write_input                         = ${NL_WRITE_INPUT},
inputout_interval                   = ${NL_INPUTOUT_INTERVAL},
debug_level                         = ${NL_DEBUG_LEVEL},
/
&domains
time_step                           = ${NL_TIME_STEP},
time_step_fract_num                 = ${NL_TIME_STEP_FRACT_NUM},
time_step_fract_den                 = ${NL_TIME_STEP_FRACT_DEN},
max_dom                             = ${NL_MAX_DOM},
e_we                                = ${NL_E_WE},
e_sn                                = ${NL_E_SN},
e_vert                              = ${NL_E_VERT},
p_top_requested                     = ${NL_P_TOP_REQUESTED},
interp_type                         = ${NL_INTERP_TYPE}, 
t_extrap_type                       = ${NL_T_EXTRAP_TYPE},
num_metgrid_levels                  = ${NL_NUM_METGRID_LEVELS},
num_metgrid_soil_levels             = ${NL_NUM_METGRID_SOIL_LEVELS},
dx                                  = ${NL_DX},
dy                                  = ${NL_DY},
grid_id                             = ${NL_GRID_ID},
parent_id                           = ${NL_PARENT_ID},
i_parent_start                      = ${NL_I_PARENT_START},
j_parent_start                      = ${NL_J_PARENT_START},
parent_grid_ratio                   = ${NL_PARENT_GRID_RATIO},
parent_time_step_ratio              = ${NL_PARENT_TIME_STEP_RATIO},
feedback                            = ${NL_FEEDBACK},
smooth_option                       = ${NL_SMOOTH_OPTION},
eta_levels                          = ${NL_ETA_LEVELS},
/
&physics
mp_physics                          = ${NL_MP_PHYSICS},
ra_lw_physics                       = ${NL_RA_LW_PHYSICS},
ra_sw_physics                       = ${NL_RA_SW_PHYSICS},
radt                                = ${NL_RADT},
sf_sfclay_physics                   = ${NL_SF_SFCLAY_PHYSICS},
sf_surface_physics                  = ${NL_SF_SURFACE_PHYSICS},
bl_pbl_physics                      = ${NL_BL_PBL_PHYSICS},
bldt                                = ${NL_BLDT},
cu_physics                          = ${NL_CU_PHYSICS},
cudt                                = ${NL_CUDT},
isfflx                              = ${NL_ISFFLX},
ifsnow                              = ${NL_IFSNOW},
icloud                              = ${NL_ICLOUD},
surface_input_source                = ${NL_SURFACE_INPUT_SOURCE},
num_soil_layers                     = ${NL_NUM_SOIL_LAYERS},
num_land_cat                        = ${NL_NUM_LAND_CAT},
sf_urban_physics                    = ${NL_SF_URBAN_PHYSICS},
maxiens                             = ${NL_MAXIENS},
maxens                              = ${NL_MAXENS},
maxens2                             = ${NL_MAXENS2},
maxens3                             = ${NL_MAXENS3},
ensdim                              = ${NL_ENSDIM},
mp_zero_out                         = ${NL_MP_ZERO_OUT},
cu_rad_feedback                     = ${NL_CU_RAD_FEEDBACK},
progn                               = ${NL_PROGN},
cugd_avedx                          = ${NL_CUGD_AVEDX},       
/
&fdda
/
&dfi_control
/
&tc
/
&scm
/
&dynamics
use_baseparam_fr_nml                = ${NL_USE_BASEPARAM_FR_NML},
w_damping                           = ${NL_W_DAMPING},
diff_opt                            = ${NL_DIFF_OPT},
km_opt                              = ${NL_KM_OPT},
diff_6th_opt                        = ${NL_DIFF_6TH_OPT},
diff_6th_factor                     = ${NL_DIFF_6TH_FACTOR},
base_temp                           = ${NL_BASE_TEMP},
damp_opt                            = ${NL_DAMP_OPT},
zdamp                               = ${NL_ZDAMP},
dampcoef                            = ${NL_DAMPCOEF},
iso_temp                            = ${NL_ISO_TEMP},
khdif                               = ${NL_KHDIF},
kvdif                               = ${NL_KVDIF},
non_hydrostatic                     = ${NL_NON_HYDROSTATIC},
moist_adv_opt                       = ${NL_MOIST_ADV_OPT},
scalar_adv_opt                      = ${NL_SCALAR_ADV_OPT},
time_step_sound                     = ${NL_TIME_STEP_SOUND:-0},
rk_ord                              = ${NL_RK_ORD},
moist_adv_opt                       = ${NL_MOIST_ADV_OPT},
scalar_adv_opt                      = ${NL_SCALAR_ADV_OPT},
chem_adv_opt                        = ${NL_CHEM_ADV_OPT},
tke_adv_opt                         = ${NL_TKE_ADV_OPT},
/
&bdy_control
spec_bdy_width                      = ${NL_SPEC_BDY_WIDTH},
spec_zone                           = ${NL_SPEC_ZONE},
relax_zone                          = ${NL_RELAX_ZONE},
specified                           = ${NL_SPECIFIED},
nested                              = ${NL_NESTED},
real_data_init_type                 = ${NL_REAL_DATA_INIT_TYPE},
/
&grib2
/
&namelist_quilt
nio_tasks_per_group                 = ${NL_NIO_TASKS_PER_GROUP},
nio_groups                          = ${NL_NIO_GROUPS},
/
EOF

#
# <next few lines under version control, do not edit>
# $URL$
# $Id$
# $Revision$
# $Date$
