#!/bin/csh
#
# DART software - Copyright 2004 - 2013 UCAR. This open source software is
# provided by UCAR, "as is", without charge, subject to all terms of use at
# http://www.image.ucar.edu/DAReS/DART/DART_download
#
# DART $Id$
#
# This script copies a set of spun-up restarts from Yongfei into
# position in the NEWDIR directory .
#----------------------------------------------------------------------

set MYCASE = enstest_0907
set MYDATE = 2000-01-05-00000
set ORGDIR = /glade/scratch/yfzhang/clmcases/${MYCASE}/run
set NEWDIR = /glade/scratch/thoar/clmsafe

mkdir -p ${NEWDIR} || exit

cd ${ORGDIR}

foreach FILE ( ${MYCASE}.clm2_*.h0.${MYDATE}.nc )
   cp -v ${FILE} ${NEWDIR}/.
end

foreach FILE ( ${MYCASE}.clm2_*.r.${MYDATE}.nc )

   cp -v ${FILE} ${NEWDIR}/.

   ncatted -O -a    _FillValue,frac_sno,o,d,1.0e+36   ${NEWDIR}/${FILE}
   ncatted -O -a missing_value,frac_sno,o,d,1.0e+36   ${NEWDIR}/${FILE}
   ncatted -O -a    _FillValue,DZSNO,o,d,1.0e+36      ${NEWDIR}/${FILE}
   ncatted -O -a missing_value,DZSNO,o,d,1.0e+36      ${NEWDIR}/${FILE}
   ncatted -O -a    _FillValue,H2OSOI_LIQ,o,d,1.0e+36 ${NEWDIR}/${FILE}
   ncatted -O -a missing_value,H2OSOI_LIQ,o,d,1.0e+36 ${NEWDIR}/${FILE}
   ncatted -O -a    _FillValue,H2OSOI_ICE,o,d,1.0e+36 ${NEWDIR}/${FILE}
   ncatted -O -a missing_value,H2OSOI_ICE,o,d,1.0e+36 ${NEWDIR}/${FILE}
   ncatted -O -a    _FillValue,T_SOISNO,o,d,1.0e+36   ${NEWDIR}/${FILE}
   ncatted -O -a missing_value,T_SOISNO,o,d,1.0e+36   ${NEWDIR}/${FILE}

end

exit

# may need to change the internal date
foreach FILE ( rpointer.lnd_* )
   cp -v ${FILE} ${NEWDIR}/.
end

# may need to change the internal date/filename
cp /gpfs/blhome/yfzhang/CLM_DART/DART/models/clm/work/obs_seq.0Z.20000106 ${NEWDIR}/obs_seq.0Z.20000106

exit 0

# <next few lines under version control, do not edit>
# $URL$
# $Revision$
# $Date$

