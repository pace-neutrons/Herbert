function fname=make_filename(in_dir,str)
% function makes full filename from file path and filename and verifies, if
% such file exists
%
%   $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)
%

if exist(str,'file')
    fname=str;
    return;
end
[fp,filename,fext] = fileparts(str);
fname=fullfile(in_dir,fp,[filename,fext]);       
if ~exist(fname,'file')
    error('HERBERT_MEX:invalid_argument','file: %s expected to be compiled but does not exist',fname);
end

