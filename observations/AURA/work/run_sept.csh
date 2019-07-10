#!/bin/csh
#
# DART software - Copyright 2004 - 2013 UCAR. This open source software is
# provided by UCAR, "as is", without charge, subject to all terms of use at
# http://www.image.ucar.edu/DAReS/DART/DART_download
#
# DART $Id$

@ day = 244

#cp input.nml inputDOY244.nml

while ( $day <= 273 ) 

 sed s/244/${day}/ inputDOY244.nml >! input.nml
 convert_aura

 @ day = $day + 1

end

exit 0

# <next few lines under version control, do not edit>
# $URL$
# $Revision$
# $Date$

