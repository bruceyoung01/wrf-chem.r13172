function copy_index = get_copy_index(fname, copystring, context)
%% GET_COPY_INDEX  Gets an index corresponding to copy metadata string
% Retrieves index associated with a given string in the 
% CopyMetaData netCDF variable in the given file. If the string
% does not exist - a fatal error is thrown.
%
% Example:
% fname = 'obs_diag_output.nc';
% copystring = 'N_DARTqc_5';
% copy_index = get_copy_index(fname, copystring);

%% DART software - Copyright UCAR. This open source software is provided
% by UCAR, "as is", without charge, subject to all terms of use at
% http://www.image.ucar.edu/DAReS/DART/DART_download
%
% DART $Id$

errorstring = sprintf('\nERROR: "%s" is not a valid CopyMetaData value for file %s\n', ...
              strtrim(copystring), fname);

if (nargin == 3)
   msgstring = sprintf('valid values for "%s" are', context);
else
   msgstring = 'valid values for CopyMetaData are';
end

if ( exist(fname,'file') ~= 2 ), error('%s does not exist.',fname); end

% Matlab seems to always need to transpose character variables.
copy_meta_data  = ncread(fname,'CopyMetaData')';
[num_copies, ~] = nc_dim_info(fname,'copy');
[metalen, ~]    = nc_dim_info(fname,'stringlength');

if( size(copy_meta_data,1) ~= num_copies || size(copy_meta_data,2) ~= metalen)
    error('%s from %s does not have the shape expected',copystring,fname)
end

nowhitecs = dewhite(copystring);

% Figure out which copy is the matching one
copy_index = -1;
for i = 1:num_copies,

   % for matching -- we want to ignore whitespace -- find it & remove it
   nowhitemd = dewhite(copy_meta_data(i,:));

   if strcmp(nowhitemd , nowhitecs) == 1
      copy_index = i;
   end
end

% Provide modest error support

if (copy_index < 0)
   for i = 1:num_copies,
      msgstring = sprintf('%s\n%s',msgstring,deblank(copy_meta_data(i,:)));
   end
   error(sprintf('%s\n%s',errorstring,msgstring))
end


function str2 = dewhite(str1)
%  function to remove ALL whitespace from a character string

str2 = str1(~isspace(str1));


% <next few lines under version control, do not edit>
% $URL$
% $Revision$
% $Date$
