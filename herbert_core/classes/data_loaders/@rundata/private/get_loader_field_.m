function val = get_loader_field_(this,field_name)
% function retrunds field name coordinaged with storage and data loader
%
persistent char_fields;
if isempty(this.loader)
    if isempty(char_fields)
        char_fields = {'par_file_name','file_name'};
    end
    if ismember(field_name,char_fields)
        val = '';
    else
        val=[];
    end
else
    val=this.loader__.(field_name);
end
