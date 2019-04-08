function  delete_all_files( this )
%method deletes all configuration files loaded to config_store

% $Revision:: 830 ($Date:: 2019-04-08 17:54:30 +0100 (Mon, 8 Apr 2019) $)

%
fields = fieldnames(this.config_storage_);
for i=1:numel(fields)
    class_name = fields{i};
    filename = fullfile(this.config_folder,[class_name,'.mat']);
    if exist(filename,'file')
        delete(filename);
    end
end


