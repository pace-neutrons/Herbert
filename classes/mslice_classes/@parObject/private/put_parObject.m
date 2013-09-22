function [ok,mess,filename,filepath]=put_parObject(data,file)
% Writes ASCII .par file
%   >> [ok,mess,filename,filepath]=put_parObject(data,file)
%
% The format of the file is described in get_parObject.
%
% Input:
% ------
%   data            parObject object
%   file            File name
%
% Output:
% -------
%   ok              True if all OK, false otherwise
%   mess            Error message; empty if ok=true
%   filename        Name of file excluding path; empty if problem
%   filepath        Path to file including terminating file separator; empty if problem

% T.G.Perring   14 September 2013

ok=true;
mess='';

% Remove blanks from beginning and end of filename
file_tmp=strtrim(file);

% Get file name and path (incl. final separator)
[path,name,ext]=fileparts(file_tmp);
filename=[name,ext];
filepath=[path,filesep];

% Write to file
try
    ndet=numel(data.group);
    arr=[data.x2;data.phi;-data.azim;data.width;data.height;data.group];    % note sign change of azimuthal angle
    fid=fopen(file_tmp,'wt');
    fprintf(fid,'%d \n',ndet);
    fprintf(fid,'%10.4f %10.4f %10.4f %10.4f %10.4f %8d \n',arr);
    fclose(fid);
    disp(['Saved information for ' num2str(ndet) ' detectors to .par file : ' file_tmp]);
catch
    if exist('fid','var') && fid>0 && ~isempty(fopen(fid)) % close file, if open
        fclose(fid);
    end
    ok=false;
    mess=['Error writing .par file data to ',file_tmp]';
    filename='';
    filepath='';
end
