function ok = is_file(name)
% tests if name is a file on the file system while NOT searching MATLAB path
%
% Optional support for a cell array of file extensions which name must also match.
%
% On older versions of matlab this is done through ensuring the path is an explicit path
% and using exist. More recent versions simply call the MATLAB built-in isfile.
%
% Input:
% ------
%   name                The name of the file you want to check;
%   {'.a','.b','.c'}    List of the permitted extensions
%
% Usage:
% ------
%  >> is_file('/home/user/test.m');        % True if file exists
%  >> is_file('test.m');                   % True if file exists in current dir
%  >> is_file('test.m', {'.txt', '.m'});   % True if file exists in current dir
%  >> is_file('test.par', {'.txt', '.m'}); % False (extensions don't match
%

    % Remove searching MATLAB path with explicit path
    if ~verLessThan('matlab', '9.1') % R2016b
        ok = isfile(name);
    else
        if isempty(path)
            path = pwd();
        end
        name = fullfile(path, name);

        ok = exist(name, 'file') == 2;
    end
end
