function ok = is_file(name)
% Tests if name is a file on the file system without searching MATLAB path
%
%   >> ok = is_file(name)
%
% On older versions of MATLAB this is done through ensuring the file is an
% explicit file and using exist. More recent versions simply call the
% MATLAB built-in isfile.
%
% Input:
% ------
%   name    The name of the file you want to check;
%
% Output:
% -------
%   ok      Logical true (is a file) or false (is not)
%
% Usage:
% ------
%  >> is_file('/home/user/test.m');        % True if file exists
%  >> is_file('test.m');                   % True if file exists in current dir
%


% Remove searching MATLAB path with explicit path
if ~verLessThan('matlab', '9.3') % R2017b
    ok = isfile(name);
else
    folder = fileparts(name);
    if isempty(folder)
        folder = pwd();
        name = fullfile(folder, name);
    end
    ok = exist(name, 'file') == 2;
end
