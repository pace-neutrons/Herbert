function [data,ok,mess]=get_spe_header(filename)
% Load header information of ASCII .spe file
%   >> [data,ok,mess] = get_spe_header(filename)
%
% data has following fields:
%   data.filename   Name of file excluding path
%   data.filepath   Path to file including terminating file separator
%   data.ndet       Number of detector groups
%   data.en         Column vector of energy bin boundaries

% Original author: T.G.Perring

ok=true;
mess='';
try
    % Remove blanks from beginning and end of filename
    filename=strtrim(filename);

    % Get file name and path (incl. final separator)
    [path,name,ext]=fileparts(filename);
    data.filename=[name,ext];
    data.filepath=[path,filesep];

    % Read start of spe file using matlab (not likely to be too large, so OK)
    fid=fopen(filename,'rt');
    nsize = str2num(fgets(fid));    % number of detector groups and energy bins
    ndet = nsize(1);
    ne = nsize(2);
    tmp = fgets(fid);   % read ### Phi grid
    phi = fscanf(fid,'%10f',ndet+1);    % dummy detector angles - are rubbish
    tmp = fgetl(fid);   % read end-of-line
    tmp = fgets(fid);   % read ### Energy grid
    en=fscanf(fid,'%10f',ne+1);    % energy bin boundaries
    fclose(fid);

    % Transfer pointers of read quantities to output data structure
    data.ndet = ndet;
    data.en = en;
catch
    ok=false;
    mess='Unable to open or read header from spe file';
end
