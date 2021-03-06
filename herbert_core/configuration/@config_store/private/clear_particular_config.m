function  clear_particular_config(this,class_instance,clear_file)
% internal method to remove particular configuration from memory 
%
% if clear_file == true also deletes the correspondent configuration file
%
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)
%

class_name =  class_instance.class_name;
if isfield(this.config_storage_,class_name)
    this.config_storage_=rmfield(this.config_storage_,class_name);
    if this.saveable_.isKey(class_name)
        this.saveable_.remove(class_name);
    end
end
if clear_file
    filename = fullfile(this.config_folder,[class_name,'.mat']);
    if is_file(filename)
        delete(filename)
    end
end

