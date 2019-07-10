function data=read_field(ncFileID,times,member,elements,variable)
%% data = read_field(ncFileID, times, member, elements, variable)
%
% Given a NetCDF file handle, the times in question, the ensemble
% member in question, and the elements to read, reads in data from
% a DART NetCDF file

%% DART software - Copyright 2004 - 2013 UCAR. This open source software is
% provided by UCAR, "as is", without charge, subject to all terms of use at
% http://www.image.ucar.edu/DAReS/DART/DART_download
%
% DART $Id$

data = squeeze(ncFileID{variable}(times,member,elements));

% <next few lines under version control, do not edit>
% $URL$
% $Revision$
% $Date$

