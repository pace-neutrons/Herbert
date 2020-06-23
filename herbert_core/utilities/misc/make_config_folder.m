function folder_path=make_config_folder(folder_name,in_folder_path)
% Return location of a folder to store user configuration files, creating if necessary.
%
%   >> folder_path=make_config_folder(folder_name)
% or:
%   >> folder_path=make_config_folder(folder_name,in_folder_path)
%
% Input:
% ------
%   folder_name         Name of default folder to hold all configurations
%                       e.g. 'ISIS_config'
%   in_folder_path      Optional path to the config folder above.
%                       if the variable is specified and the folder can not
%                       be created on this path, the routine throws
%                       'CONFIG_FOLDER:invalid_argument'
% Output:
% -------
%   folder_path         Full path to default folder
%
% The attempt to create the default folder for user configurations takes place
% in the following order:
%
% 1) in the place where the startup.m file is located.
% 2) in Matlab preferences directory;
% 3) if there are no startup.m file or its folder is write-protected
%    try to create this folder under the user profile folder
% 4) if this location does not exist or write protected, try userpath
% 5) try working directory
%
% If 5) fails then something is fundamentally wrong and an error is thrown.
%
% Works under the asumption that the folder generated by this function is
% usually the same for a given machine, so the path to the configurations
% will be the same next next time the function is called.
if exist('in_folder_path','var')
    [success,folder_path,err_mess] = try_to_create_folder(in_folder_path,folder_name);
    if success
        return
    else
        error('CONFIG_FOLDER:invalid_argument',...
            'Can not create folder at the requested path: %s\n; Error: %s',...
            in_folder_path,err_mess);
    end
end

% First try to create where find startup.m
location = which('startup.m');
if ~isempty(location)
    location=fileparts(location);
    [success,folder_path] = try_to_create_folder(location,folder_name);
    if success, return, end
end

% Try to use matlab preferences directory
location = prefdir();
if exist(location,'dir')
    % store configuration in a version-independent location;
    version_folder=regexp(version() ,'\w*','match');
    verstr=version_folder{5};
    if ispc
        verstr=['\\',verstr];
    else
        verstr=[filesep,verstr];
    end
    location=regexprep(location, [verstr,'$'], '');
    
    [success,folder_path] = try_to_create_folder(location,folder_name);
    if success, return, end
end

% startup.m does not exist, preferences are unavailible; try user profile
if ispc
    location = getenv('USERPROFILE');
else
    location = getenv('HOME');
end

if exist(location,'dir')
    [success,folder_path] = try_to_create_folder(location,folder_name);
    if success, return, end
end

% Something wrong with user profile, try matlab user folder
location = userpath;
if exist(location,'dir')
    [success,folder_path] = try_to_create_folder(location,folder_name);
    if success, return, end
end

% Something is fundamentally wrong
location = pwd;
if exist(location,'dir')
    [success,folder_path,message] = try_to_create_folder(location,folder_name);
    if ~success
        help make_config_folder;
        error('Cannot create configuration directory %s; Error: %s',folder_name,message);
    end
else
    help make_config_folder;
    error('CONFIG_FOLDER:runtime_error',...
        'None of default locations exists or available for writing to create folder %s',...
        folder_name);
end


%--------------------------------------------------------------------------------------------------
