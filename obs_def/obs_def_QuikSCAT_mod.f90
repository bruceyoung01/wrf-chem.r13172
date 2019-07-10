! DART software - Copyright 2004 - 2013 UCAR. This open source software is
! provided by UCAR, "as is", without charge, subject to all terms of use at
! http://www.image.ucar.edu/DAReS/DART/DART_download
!
! DART $Id$

! This module supports the observation types from the SeaWinds instrument
! on the QuiKSCAT satellite.
! http://winds.jpl.nasa.gov/missions/quikscat/index.cfm
! Since the data already have an NCEP BUFR 'code' of QKSWND,
! we will drag that along.

! While nothing specific needs to be done to use QuikSCAT winds, declaring
! a specific type for them allows for the ability to differentiate them
! from other wind observation types, allowing for impact assessment, for example.

! BEGIN DART PREPROCESS KIND LIST
! QKSWND_U_WIND_COMPONENT,  KIND_U_WIND_COMPONENT,  COMMON_CODE
! QKSWND_V_WIND_COMPONENT,  KIND_V_WIND_COMPONENT,  COMMON_CODE
! END DART PREPROCESS KIND LIST

! <next few lines under version control, do not edit>
! $URL$
! $Id$
! $Revision$
! $Date$
