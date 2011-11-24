function this=rundata_config
% Retrieve or create the rundata configuration
% Defines default values for some rundata variables and other configurations for rundata class
%
%--------------------------------------------------------------------------------------------------
%  ***  Alter only the contents of the subfunction at the bottom of this file called     ***
%  ***  default_config, and the help section above, which describes the contents of the  ***
%  ***  configuration structure.                                                         ***
%--------------------------------------------------------------------------------------------------
% This block contains generic code. Do not alter. Alter only the sub-function default_config below
persistent this_local;

if isempty(this_local)
    config_name=mfilename('class');

    build_configuration(config,@default_config,config_name);    
    this_local=class(struct([]),config_name,config);
end
this = this_local;


%--------------------------------------------------------------------------------------------------
% Alter only the contents of the following subfunction, and the help section of the main function
% below
%--------------------------------------------------------------------------------------------------
function config_data=default_config

config_data=struct(...
    'is_crystal',true, ...
    'omega',0,...
	'dpsi', 0,...
	'gl',   0,...
	'gs',   0,...
    'sqw_ext','.tmp',... % the extension an sqw file generated from a runfile would have
    'sqw_path','',...    % the path to write temporary sqw files. Default -- the sama as initial sqw file. 
    'sealed_fields',{{'sealed_fields'}} ...
    );