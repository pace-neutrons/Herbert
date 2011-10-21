function this=config(varargin)
% Base configuration class inherited by user-modifiable application configurations
%
%   >> this = config

global class_configurations_holder;

config_name=mfilename('class');
if ~isstruct(class_configurations_holder)||isempty(class_configurations_holder)
    config_store(config_name,default_config,default_config);
    class_configurations_holder = struct(config_name,class(struct('ok',{true}),config_name));    
end
this = class_configurations_holder.(config_name);


%--------------------------------------------------------------------------------------------------
function config_data=default_config

config_data = struct(...
   'config_folder_name','mprogs_config',...
   'config_folder_path','',...
   'sealed_fields',{{'config_folder_name','config_folder_path'}});
config_data.config_folder_path = make_config_folder(config_data.config_folder_name);
