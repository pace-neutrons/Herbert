function isit = check_isconfigured(this,class_instance,check_mem_only)
% Method checks if the specific class is stored in config_store either in
% memory or still on HDD
%

% $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)


class_name = class_instance.class_name;
if isfield(this.config_storage_,class_name)
    isit = true;
    return
end
if ~check_mem_only
    config_file = fullfile(this.config_folder,[class_name,'.mat']);
    if exist(config_file,'file')
        isit = true;
    else
        isit = false;
    end
else
    isit = false;
end

