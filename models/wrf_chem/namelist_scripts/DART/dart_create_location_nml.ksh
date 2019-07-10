#!/bin/ksh -x
#########################################################################
#
# Purpose: Create DART &location_nml 
#
#########################################################################
#
# Generate namelist section
rm -f input.nml_temp
touch input.nml_temp
cat > input.nml_temp << EOF
 &location_nml
   horiz_dist_only                          = ${NL_HORIZ_DIST_ONLY:-.false.},
   vert_normalization_pressure              = ${NL_VERT_NORMALIZATION_PRESSURE:-100000.0},
   vert_normalization_height                = ${NL_VERT_NORMALIZATION_HEIGHT:-10000.0},
   vert_normalization_level                 = ${NL_VERT_NORMALIZATION_LEVEL:-20.0},
   vert_normalization_scale_height          = ${NL_VERT_NORMALIZATION_SCALE_HEIGHT:-1.5},
   special_vert_normalization_obs_types     = ${NL_SPECIAL_VERT_NORMALIZATION_OBS_TYPES:-''},
   special_vert_normalization_pressures     = ${NL_SPECIAL_VERT_NORMALIZATION_PRESSURES:-100000.0},
   special_vert_normalization_heights       = ${NL_SPECIAL_VERT_NORMALIZATION_HEIGHTS:-10000.0},
   special_vert_normalization_levels        = ${NL_SPECIAL_VERT_NORMALIZATION_LEVELS:-20.0},
   special_vert_normalization_scale_heights = ${NL_SPECIAL_VERT_NORMALIZATION_SCALE_HEIGHTS:-1.5},
   approximate_distance                     = ${NL_APPROXIMATE_DISTANCE:-.false.},
   nlon                                     = ${NL_NLON:-141},
   nlat                                     = ${NL_NLAT:-72},
   output_box_info                          = ${NL_OUTPUT_BOX_INFO:-.false.},
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

