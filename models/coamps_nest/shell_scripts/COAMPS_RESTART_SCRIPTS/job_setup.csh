#!/bin/tcsh 
#
# DART software - Copyright 2004 - 2013 UCAR. This open source software is
# provided by UCAR, "as is", without charge, subject to all terms of use at
# http://www.image.ucar.edu/DAReS/DART/DART_download
#
# DART $Id$
#
########################################################################
#
# SCRIPT:	job_setup.csh
# AUTHOR:	T. R. Whitcomb
#           Naval Research Laboratory
#
# Sets up the configuration (e.g. Linux modules) for a script run
# in a resource manager - this file is not executed, but is sourced
# by various run scripts.
######

# These are based on the ACESGrid setup at MIT
if ( -f /etc/profile.d/modules.csh ) then
    source /etc/profile.d/modules.csh
endif
module load mpich/pgi
module load mpiexec

exit 0

# <next few lines under version control, do not edit>
# $URL$
# $Revision$
# $Date$

