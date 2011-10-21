function set_internal(this,config_name,varargin)
% this is protected function which should be only invoked by config
% childrents;

root_config_name = mfilename('class');   % the class for which this a method
% Parse arguments;
if nargin==3 && ischar(varargin{1}) && strncmpi(varargin{1},'defaults',3)
       % Set fields to default values, store in memory and on file, and return
        fetch_default = true;
        default_config_data = config_store(config_name,fetch_default);
        [ok,mess]=save_config(file_name,default_config_data);
        if ~ok, error(mess), end
        config_store(config_name,default_config_data);
        return;
   
else
    [field_nams,field_vals]=parse_config_arg(varargin{:});
end    

% Check arguments
if ~all_strings(field_nams)
    error('All field_names have to be strings');
end

% Get access to the internal structure
fetch_default = false;
config_data   = config_store(config_name,fetch_default);
config_fields = fieldnames(config_data);


% Check if any fields being altered are sealed fields or the root config class
if ~strcmp(class(this),'config')
    sealed_fields=ismember(config_data.sealed_fields,field_nams);
    if any(sealed_fields);    
        error('The values of some fields are sealed and can not be altered');
    end
end
if ismember(root_config_name,field_nams);
    error(['Cannot alter hidden field ''',root_config_name,''''])
end

% Check fields to be altered are in the valid name list
member_fields = ismember(config_fields,field_nams);
if sum(member_fields)~=numel(field_vals)
    error('CONFIG:set','Configuration ''%s'' does not have one or more of the fields you are trying to set',config_name);
end




% Set the fields
for i=1:numel(field_nams)
    config_data.(field_nams{i})=field_vals{i};
end
%
file_name = config_file_name (config_name);
% Save data into the corresponding configuration file and into memory;
[ok,mess]=save_config(file_name,config_data);
if ~ok, error(mess), end
config_store(config_name,config_data);


%--------------------------------------------------------------------------------------------------
function ok=all_strings(c)
% Check elements of a cell array are 1xn non-empty character strings
ok=true;
for i=1:numel(c)
    ok=ischar(c{i}) && ~isempty(c{i}) && size(c{i},1)==1;
end
