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
# Purpose: Script to create WRF Namelist 

#########################################################################
#
# CREATE WRF NAMELIST FILE
rm -f namelist.input
touch namelist.input
cat > namelist.input << EOF
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
fine_input_stream                   = ${NL_FINE_INPUT_STREAM},
io_form_input                       = ${NL_IO_FORM_INPUT},
io_form_boundary                    = ${NL_IO_FORM_BOUNDARY},
auxinput2_inname                    = ${NL_AUXINPUT2_INNAME},
auxinput5_inname                    = ${NL_AUXINPUT5_INNAME},
auxinput6_inname                    = ${NL_AUXINPUT6_INNAME},
auxinput7_inname                    = ${NL_AUXINPUT7_INNAME},
auxinput2_interval_m                = ${NL_AUXINPUT2_INTERVAL_M},
auxinput5_interval_m                = ${NL_AUXINPUT5_INTERVAL_M},
auxinput6_interval_m                = ${NL_AUXINPUT6_INTERVAL_M},
auxinput7_interval_m                = ${NL_AUXINPUT7_INTERVAL_M},
frames_per_auxinput2                = ${NL_FRAMES_PER_AUXINPUT2},
frames_per_auxinput5                = ${NL_FRAMES_PER_AUXINPUT5},
frames_per_auxinput6                = ${NL_FRAMES_PER_AUXINPUT6},
frames_per_auxinput7                = ${NL_FRAMES_PER_AUXINPUT7},
io_form_auxinput2                   = ${NL_IO_FORM_AUXINPUT2},
io_form_auxinput5                   = ${NL_IO_FORM_AUXINPUT5},
io_form_auxinput6                   = ${NL_IO_FORM_AUXINPUT6},
io_form_auxinput7                   = ${NL_IO_FORM_AUXINPUT7},
iofields_filename                   = ${NL_IOFIELDS_FILENAME},
write_input                         = ${NL_WRITE_INPUT},
inputout_interval                   = ${NL_INPUTOUT_INTERVAL},
input_outname                       = ${NL_INPUT_OUTNAME},
debug_level                         = ${NL_DEBUG_LEVEL},
/
&domains
time_step                           = ${NL_TIME_STEP},
time_step_fract_num                 = ${NL_TIME_STEP_FRACT_NUM},
time_step_fract_den                 = ${NL_TIME_STEP_FRACT_DEN},
max_dom                             = ${NL_MAX_DOM},
s_we                                = ${NL_S_WE},
e_we                                = ${NL_E_WE},
s_sn                                = ${NL_S_SN},
e_sn                                = ${NL_E_SN},
s_vert                              = ${NL_S_VERT},
e_vert                              = ${NL_E_VERT},
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
lagrange_order                      = ${NL_LAGRANGE_ORDER},
interp_type                         = ${NL_INTERP_TYPE}, 
extrap_type                         = ${NL_EXTRAP_TYPE},
t_extrap_type                       = ${NL_T_EXTRAP_TYPE},
use_surface                         = ${NL_USE_SURFACE}, 
use_levels_below_ground             = ${NL_USE_LEVELS_BELOW_GROUND},
lowest_lev_from_sfc                 = ${NL_LOWEST_LEV_FROM_SFC},
force_sfc_in_vinterp                = ${NL_FORCE_SFC_IN_VINTERP:-1},
zap_close_levels                    = ${NL_ZAP_CLOSE_LEVELS},
interp_theta                        = ${NL_INTERP_THETA},
hypsometric_opt                     = ${NL_HYPSOMETRIC_OPT},
p_top_requested                     = ${NL_P_TOP_REQUESTED},
eta_levels                          = ${NL_ETA_LEVELS:--1},
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
cugd_avedx                          = ${NL_CUGD_AVEDX},       
cu_rad_feedback                     = ${NL_CU_RAD_FEEDBACK},
cu_diag                             = ${NL_CU_DIAG},
isfflx                              = ${NL_ISFFLX},
ifsnow                              = ${NL_IFSNOW},
icloud                              = ${NL_ICLOUD},
surface_input_source                = ${NL_SURFACE_INPUT_SOURCE},
num_soil_layers                     = ${NL_NUM_SOIL_LAYERS},
num_land_cat                        = ${NL_NUM_LAND_CAT},
mp_zero_out                         = ${NL_MP_ZERO_OUT},
num_land_cat                        = ${NL_NUM_LAND_CAT},
sf_urban_physics                    = ${NL_SF_URBAN_PHYSICS},
maxiens                             = ${NL_MAXIENS},
maxens                              = ${NL_MAXENS},
maxens2                             = ${NL_MAXENS2},
maxens3                             = ${NL_MAXENS3},
ensdim                              = ${NL_ENSDIM},
/
&dfi_control
/
&tc
/
&scm
/
&dynamics
iso_temp                            = ${NL_ISO_TEMP},
tracer_opt                          = ${NL_TRACER_OPT},
w_damping                           = ${NL_W_DAMPING},
diff_opt                            = ${NL_DIFF_OPT},
diff_6th_opt                        = ${NL_DIFF_6TH_OPT},
diff_6th_factor                     = ${NL_DIFF_6TH_FACTOR},
km_opt                              = ${NL_KM_OPT},
damp_opt                            = ${NL_DAMP_OPT},
zdamp                               = ${NL_ZDAMP},
dampcoef                            = ${NL_DAMPCOEF},
non_hydrostatic                     = ${NL_NON_HYDROSTATIC},
use_baseparam_fr_nml                = ${NL_USE_BASEPARAM_FR_NML},
moist_adv_opt                       = ${NL_MOIST_ADV_OPT},
scalar_adv_opt                      = ${NL_SCALAR_ADV_OPT},
chem_adv_opt                        = ${NL_CHEM_ADV_OPT},
tke_adv_opt                         = ${NL_TKE_ADV_OPT},
h_mom_adv_order                     = ${NL_H_MOM_ADV_ORDER},
v_mom_adv_order                     = ${NL_V_MOM_ADV_ORDER},
h_sca_adv_order                     = ${NL_H_SCA_ADV_ORDER},
v_sca_adv_order                     = ${NL_V_SCA_ADV_ORDER},
/
&bdy_control
spec_bdy_width                      = ${NL_SPEC_BDY_WIDTH},
spec_zone                           = ${NL_SPEC_ZONE},
relax_zone                          = ${NL_RELAX_ZONE},
specified                           = ${NL_SPECIFIED},
nested                              = ${NL_NESTED},
/
&grib2
/
&namelist_quilt
nio_tasks_per_group                 = ${NL_NIO_TASKS_PER_GROUP},
nio_groups                          = ${NL_NIO_GROUPS},
/
&chem
kemit                              = ${NL_KEMIT},
chem_opt                           = ${NL_CHEM_OPT},
bioemdt                            = ${NL_BIOEMDT},
photdt                             = ${NL_PHOTDT},
chemdt                             = ${NL_CHEMDT},
io_style_emissions                 = ${NL_IO_STYLE_EMISSIONS},
emiss_inpt_opt                     = ${NL_EMISS_INPT_OPT},
emiss_opt                          = ${NL_EMISS_OPT},
emiss_opt_vol                      = ${NL_EMISS_OPT_VOL},
chem_in_opt                        = ${NL_CHEM_IN_OPT},
phot_opt                           = ${NL_PHOT_OPT},
gas_drydep_opt                     = ${NL_GAS_DRYDEP_OPT},
aer_drydep_opt                     = ${NL_AER_DRYDEP_OPT},
bio_emiss_opt                      = ${NL_BIO_EMISS_OPT},
ne_area                            = ${NL_NE_AREA}, 
gas_bc_opt                         = ${NL_GAS_BC_OPT},
gas_ic_opt                         = ${NL_GAS_IC_OPT},
aer_bc_opt                         = ${NL_AER_BC_OPT},
aer_ic_opt                         = ${NL_AER_IC_OPT},
gaschem_onoff                      = ${NL_GASCHEM_ONOFF},
aerchem_onoff                      = ${NL_AERCHEM_ONOFF},
wetscav_onoff                      = ${NL_WETSCAV_ONOFF},
cldchem_onoff                      = ${NL_CLDCHEM_ONOFF},
vertmix_onoff                      = ${NL_VERTMIX_ONOFF},
chem_conv_tr                       = ${NL_CHEM_CONV_TR},
conv_tr_wetscav                    = ${NL_CONV_TR_WETSCAV},
conv_tr_aqchem                     = ${NL_CONV_TR_AQCHEM},
seas_opt                           = ${NL_SEAS_OPT}, 
dust_opt                           = ${NL_DUST_OPT}, 
dmsemis_opt                        = ${NL_DMSEMIS_OPT}, 
biomass_burn_opt                   = ${NL_BIOMASS_BURN_OPT},
plumerisefire_frq                  = ${NL_PLUMERISEFIRE_FRQ},
scale_fire_emiss                   = ${NL_SCALE_FIRE_EMISS},
have_bcs_chem                      = ${NL_HAVE_BCS_CHEM},
aer_ra_feedback                    = ${NL_AER_RA_FEEDBACK},
chemdiag                           = ${NL_CHEMDIAG},
aer_op_opt                         = ${NL_AER_OP_OPT},
opt_pars_out                       = ${NL_OPT_PARS_OUT}, 
have_bcs_upper                     = ${NL_HAVE_BCS_UPPER},
fixed_ubc_press                    = ${NL_FIXED_UBC_PRESS},
fixed_ubc_inname                   = ${NL_FIXED_UBC_INNAME},
/
EOF
#
# <next few lines under version control, do not edit>
# $URL$
# $Id$
# $Revision$
# $Date$
