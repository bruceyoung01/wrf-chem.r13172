#!/bin/ksh
#
# DART software - Copyright UCAR. This open source software is provided
# by UCAR, "as is", without charge, subject to all terms of use at
# http://www.image.ucar.edu/DAReS/DART/DART_download
#
# $Id$
#

#########################################################################
#
# Purpose: Script to create WPS Namelist.Input 

#########################################################################
#
# CREATE WPS NAMELIST FILE
rm -f namelist.wps
touch namelist.wps
cat << EOF > namelist.wps
&share
 wrf_core                         = ${NL_WRF_CORE},
 max_dom                          = ${NL_MAX_DOM},
 start_year                       = ${NL_START_YEAR},
 start_month                      = ${NL_START_MONTH},
 start_day                        = ${NL_START_DAY},
 start_hour                       = ${NL_START_HOUR},
 end_year                         = ${NL_END_YEAR},
 end_month                        = ${NL_END_MONTH},
 end_day                          = ${NL_END_DAY},
 end_hour                         = ${NL_END_HOUR},
 start_date                       = ${NL_START_DATE},
 end_date                         = ${NL_END_DATE},
 interval_seconds                 = ${NL_INTERVAL_SECONDS},
 io_form_geogrid                  = ${NL_IO_FORM_GEOGRID},
 debug_level                      = ${NL_DEBUG_LEVEL},
 active_grid                      = ${NL_ACTIVE_GRID},
/
&geogrid
 s_we                             = ${NL_S_WE},
 e_we                             = ${NL_E_WE},
 s_sn                             = ${NL_S_SN},
 e_sn                             = ${NL_E_SN},
 parent_id                        = ${NL_PARENT_ID},
 parent_grid_ratio                = ${NL_PARENT_GRID_RATIO},
 i_parent_start                   = ${NL_I_PARENT_START},
 j_parent_start                   = ${NL_J_PARENT_START},
 geog_data_res                    = ${NL_GEOG_DATA_RES},
 dx                               = ${NL_DX},
 dy                               = ${NL_DY},
 map_proj                         = ${NL_MAP_PROJ},
 ref_lat                          = ${NL_REF_LAT},
 ref_lon                          = ${NL_REF_LON},
 stand_lon                        = ${NL_STAND_LON},
 truelat1                         = ${NL_TRUELAT1},
 truelat2                         = ${NL_TRUELAT2},
 geog_data_path                   = ${NL_GEOG_DATA_PATH},
 opt_geogrid_tbl_path             = ${NL_OPT_GEOGRID_TBL_PATH},
/
&ungrib
 out_format                       = ${NL_OUT_FORMAT},
/
&metgrid
 fg_name                          = './FILE',
 io_form_metgrid                  = ${NL_IO_FORM_METGRID}
 opt_metgrid_tbl_path             = './',
/
&mod_levs
 press_pa =  201300 , 200100, 100000 , 
             95000 ,  90000 , 
             85000 ,  80000 , 
             75000 ,  70000 , 
             65000 ,  60000 , 
             55000 ,  50000 , 
             45000 ,  40000 , 
             35000 ,  30000 , 
             25000 ,  20000 , 
             15000 ,  10000 , 
              5000 ,  1000
/
EOF

#
# <next few lines under version control, do not edit>
# $URL$
# $Id$
# $Revision$
# $Date$
