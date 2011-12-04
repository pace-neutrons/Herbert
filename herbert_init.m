function varargout = herbert_init (opt)
% Adds the paths needed by Herbert.
%
% In your startup.m, add the Herbert root path and call herbert_init, e.g.
%       addpath('c:\mprogs\herbert')
%       herbert_init
%
% Is PC and Unix compatible.

% T.G.Perring

% Get options
% -----------
if exist('opt','var') && ~(ischar(opt) && size(opt,1)==1 && ~isempty(opt))
    error('Check option is character string')
elseif ~exist('opt','var')
    opt='fortran';
end

% Root directory is assumed to be that in which this function resides
% (keep this path, as may be removed by call to application_off)
rootpath = fileparts(which('herbert_init'));


% Remove all instances of Herbert
% -------------------------------
% (This might include this version of Herbert)
application_off('herbert')


% Add paths
% ---------
addpath(rootpath)  % MUST have rootpath so that herbert_init, herbert_off included

% Class definitions, with methods and operator definitions
addgenpath_message (rootpath,'classes');

% Utilities definitions
addgenpath_message (rootpath, 'utilities')

% Graphics
addgenpath_message (rootpath,'graphics')
genieplot_init

% Applications definitions
addgenpath_message (rootpath, 'applications')

% Configurations
addgenpath_message (rootpath,'configuration');

% % Put mex files on path
% if strncmpi(opt,'fortran',numel(opt))
%     fortran_root = fullfile(rootpath,'external_code','Fortran');
%     addpath_message (fortran_root);
%     [mex_dir,mex_dir_full] = mex_dir_name(fortran_root);
%     output.external_code_option='fortran';
%     addpath_message (mex_dir_full);
%     
% elseif strncmpi(opt,'matlab',numel(opt))
%     output.external_code_option='matlab';
%     addgenpath_message (rootpath,'external_code','matlab')
%     
% else
%     output.external_code_option=opt;
%     addgenpath_message (rootpath,'_test','external_code_ref',opt)   
% end

% Developer options disabled by default but should be enabled when checking
% or on a developer's machine;
if get(herbert_config,'init_tests')
    addpath_message (rootpath,'_test/matlab_xunit/xunit');
end

% Return output argument
if nargout>0
    varargout{1}=output;
end
disp('!------------------------------------------------------------------!')
disp('!                      HERBERT                                     !')
disp('! =================================================================!')
disp('!         Utilites for visualisation and analysis                  !')
disp('!              of neutron spectroscopy data                        !')
disp('!------------------------------------------------------------------!')


%=========================================================================================================
function addpath_message (varargin)
% Add a path from the component directory names, printing a message if the
% directory does not exist.
% e.g.
%   >> addpath_message('c:\mprogs\libisis','bindings','matlab','classes')

% T.G.Perring

string=fullfile(varargin{:},'');    % '' needed to circumvent bug in fullfile if only on argument, Matlab 2008b (& maybe earlier)
if exist(string,'dir')==7
    try
        addpath (string);
    catch
        herbert_off
        error(lasterr);
    end
else
    herbert_off
    error([string, ' is not a directory - not added to path']);
end

%=========================================================================================================
function addgenpath_message (varargin)
% Add a recursive toolbox path from the component directory names, printing
% a message if the directory does not exist.
% e.g.
%   >> addpath_message('c:\mprogs\libisis','bindings','matlab','classes')

% T.G.Perring

string=fullfile(varargin{:},'');    % '' needed to circumvent bug in fullfile if only on argument, Matlab 2008b (& maybe earlier)
if exist(string,'dir')==7
    try
        addpath (genpath_special(string));
    catch
        herbert_off
        error(lasterr);
    end
else
    herbert_off
    error([string, ' is not a directory - not added to path']);
end

%=========================================================================================================
function [mex_dir,mex_dir_full] = mex_dir_name(fortran_root)
% Get directory for mex files, and the absolute path (NOT simply relative to rootpath)
if strcmpi(computer,'PCWIN64')
    mex_dir='x64';
    mex_dir_full=fullfile(fortran_root,'mex','x64');
elseif strcmpi(computer,'PCWIN')
    mex_dir='Win32';
    mex_dir_full=fullfile(fortran_root,'mex','Win32');
else
    error('Architecture type not supported yet')
end

%=========================================================================================================
function application_off(app_name)
% Remove paths to all instances of the application.

start_dir=pwd;

% Determine the rootpaths of any instances of the application by looking for app_name on the matlab path
application_init_old = which([app_name,'_init'],'-all');

for i=1:numel(application_init_old)
    try
        rootpath=fileparts(application_init_old{i});
        cd(rootpath)
        if exist(fullfile(pwd,[app_name,'_off.m']),'file') % check that 'off' routine exists in the particular rootpath
            try
                feval([app_name,'_off'])    % call the 'off' routine
            catch
                disp(['Unable to run function ',app_name,'_off.m'])
            end
        else
            disp(['Function ',app_name,'_off.m not found in ',rootpath])
            disp('Clearing rootpath and subdirectories from matlab path in any case')
        end
        paths = genpath(rootpath);
        warn_state=warning('off','all');    % turn of warnings (so don't get errors if remove non-existent paths)
        rmpath(paths);
        warning(warn_state);    % return warnings to initial state
        cd(start_dir)           % return to starting directory
    catch
        cd(start_dir)           % return to starting directory
        disp(['Problems removing ',rootpath,' and any sub-directories from matlab path']);
    end
end
