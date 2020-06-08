function herbert_off
% Remove paths to Herbert root directory and all sub-directories.
%
% To remove Herbert from the Matlab path, type
%   >> herbert_off

% T.G.Perring

% Call cleanup routine(s) before clearing any paths (e.g. persistent variables)
%   - not any at the moment -

% root directory is assumed to be that in which this function resides
rootpath = fileparts(fileparts(which('herbert_init')));
on_path = fileparts(which('herbert_on'));

% turn off warnings (so we don't get errors if we remove non-existent paths)
warn_state=warning('off','all');
try
    paths = genpath(rootpath);
    % make sure we are not removing the path to herbert_on
    if ~isempty(on_path)
        paths = strrep(paths,[on_path,pathsep],'');
    end
    rmpath(paths);
    warning(warn_state);  % return warnings to initial state
catch
    warning(warn_state);  % return warnings to initial state if error encountered
    error('Problems removing "%s" and sub-directories from Matlab path',rootpath)
end
% Make sure we're not removing any global paths
addpath(getenv('MATLABPATH'));
