function [ok,mess] = save_config (file_name, config_data)
% Save configuration structure, stripping off the field with name of root config class
% 
% $Revision$ ($Date$)
%

% Delete existing configuration file, if there is one
if exist(file_name,'file')
    try
        delete(file_name)
    catch
        ok=false;
        mess=['Unable to delete existing configuration data file: ',file_name];
        return
    end
end

% Save structure
try
    save(file_name,'config_data')
    ok=true;
    mess='';
catch
    ok=false;
    mess=['Unable to save configuration to file: ',file_name];
    return
end
