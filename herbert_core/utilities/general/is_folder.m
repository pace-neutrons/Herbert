function ok = is_folder(name)
% Tests if name is a folder on the file system without searching MATLAB path
%
%   >> ok = is_folder(name)
%
% On older versions of MATLAB this is done through ensuring the path is an
% explicit path and using exist. More recent versions simply call the
% MATLAB built-in isfolder.
%
% Input:
% ------
%   name    The name of the folder you want to check
%
% Output:
% -------
%   ok      Logical true (is a folder) or false (is not)
%
% Usage:
% ------
%  >> is_folder('/home/user/');    % True if folder exists
%  >> is_folder('test');           % True if folder exists in current folder
%


% Remove searching MATLAB path with explicit path
if ~verLessThan('matlab', '9.3')    % R2017b
    ok = isfolder(name);
else
    folder = fileparts(strtrim(name));
    if isempty(folder)
        folder = pwd();
        name = fullfile(folder, name);
    end
    ok = exist(name, 'dir') == 7;
end

end
