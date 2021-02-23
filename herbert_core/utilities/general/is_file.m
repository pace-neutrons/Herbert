function ok = is_file(varargin)
% tests if name is a file on the file system
%
% Optional support for a cell array of file extensions which name must also match.
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

    p = inputParser;
    addRequired(p,'name', @is_string);
    addOptional(p,'extensions',{},@iscellstr);
    parse(p, varargin{:});

    % Remove searching MATLAB path with explicit path
    [path,~,ext] = fileparts(strtrim(p.Results.name));
    extensions = p.Results.extensions;

    if ~verLessThan('matlab', '9.1') % R2016b
        ok = isfile(p.Results.name);
    else
        if isempty(path)
            path = pwd();
        end
        name = fullfile(path, p.Results.name);

        ok = exist(name, 'file') == 2;
    end

    if ~isempty(extensions)
        ok = ok && any(strcmp(ext, extensions));
    end
end
