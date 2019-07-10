function [ ] = ComputeBandDepth(isoval)
%% This code will compute the band depth of an ensemble of iscontours (corresponding to a given isovalue)
%% the filename is hard-coded, so this code will look for files starting with 'wrfout' in the given directory (dname)
%% inputs: directory name
%%         isovalue of interest
%% output: the depth value for each ensemble member
%%         the filename for the median

EAll = []; % holds the ensemble

%% read NetCDF files from a single directory given the number of files in that directory is exactly ENum
dname='./';
D = dir( fullfile(dname,'wrfout*') ); %dir(dname);
d = {D.name};

ENum = size(d, 2);

for i=1:ENum
    filename = d{i};
    C = ncread([dname filename], 'co');
    
    %% isocontour extraction
    I = find(C>isoval);
    m = zeros(size(C));
    m(I) = 1;
    EAll = [EAll, m(:)];
end

%% M is pxn matrix n being the ensembles ize
n = size(EAll,2);
p = size(EAll,1);

%% checking the band inclusion - this is n log n version of the combinatorial problem 
[~, R] = sort(EAll,2);
na = n - R;
nb = R - 1;
match = na.*nb;
proportion = sum(match, 1)/p;
depth = (proportion+n-1)/nchoosek(n,2);

%% sort the depth values and get the median index
[~, IS] = sort(depth);
med_fname = d{IS(end)};
cmd_str=strcat('export DEEP_MEMBER=',num2str(IS(end))); 
st=system('rm -rf shell_file.ksh');
st=system('touch shell_file.ksh');
fid=fopen('shell_file.ksh','w');
fprintf(fid,'%s',cmd_str);
fclose(fid);
st=system('chmod +x shell_file.ksh');
return
