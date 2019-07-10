#!/bin/csh
#
# DART software - Copyright 2004 - 2013 UCAR. This open source software is
# provided by UCAR, "as is", without charge, subject to all terms of use at
# http://www.image.ucar.edu/DAReS/DART/DART_download
#
# DART $Id$
#
# This script builds only perfect_model_obs and filter.  To build the rest
# of the executables, run './quickbuild.csh'.
#
# Executes a known "perfect model" experiment using an existing
# observation sequence file (obs_seq.in) and initial conditions appropriate
# for both 'perfect_model_obs' (perfect_ics) and 'filter' (filter_ics).
# The 'input.nml' file controls all facets of this execution.
#
# 'create_obs_sequence' and 'create_fixed_network_sequence' were used to
# create the observation sequence file 'obs_seq.in' - this defines
# what/where/when we want observations. This script does not run these
# programs - intentionally.
#
# 'perfect_model_obs' results in a True_State.nc file that contains
# the true state, and obs_seq.out - a file that contains the "observations"
# that will be assimilated by 'filter'.
#
# 'filter' results in three files (at least): Prior_Diag.nc - the state
# of all ensemble members prior to the assimilation (i.e. the forecast),
# Posterior_Diag.nc - the state of all ensemble members after the
# assimilation (i.e. the analysis), and obs_seq.final - the ensemble
# members' estimate of what the observations should have been.
#
# Once 'perfect_model_obs' has advanced the model and harvested the
# observations for the assimilation experiment, 'filter' may be run
# over and over by simply changing the namelist parameters in input.nml.
#
# The result of each assimilation can be explored in model-space with
# matlab scripts that directly read the netCDF output, or in observation-space.
# 'obs_diag' is a program that will create observation-space diagnostics
# for any result of 'filter' and results in a couple data files that can
# be explored with yet more matlab scripts.

echo 'copying the workshop version of the input.nml into place'
cp -f input.workshop.nml input.nml

#----------------------------------------------------------------------
# 'preprocess' is a program that culls the appropriate sections of the
# observation module for the observations types in 'input.nml'; the
# resulting source file is used by all the remaining programs,
# so it MUST be run first.
#----------------------------------------------------------------------

\rm -f preprocess *.o *.mod
\rm -f ../../../obs_def/obs_def_mod.f90
\rm -f ../../../obs_kind/obs_kind_mod.f90

set MODEL = "lorenz_63"

echo 'building and running preprocess'

csh  mkmf_preprocess
make         || exit 1
./preprocess || exit 99

echo 'building perfect_model_obs'
csh mkmf_perfect_model_obs
make || exit 4

echo 'building filter'
csh mkmf_filter
make || exit 5

echo 'removing the compilation leftovers'
\rm -f *.o *.mod

echo 'running perfect_model_obs'
./perfect_model_obs || exit 41

echo 'running filter'
./filter            || exit 51

exit 0

# <next few lines under version control, do not edit>
# $URL$
# $Revision$
# $Date$

