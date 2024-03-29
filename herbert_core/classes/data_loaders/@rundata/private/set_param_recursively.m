function obj=set_param_recursively(obj,a_struct,varargin)
% function to fill the rundata class from data, defined in the input
% structure,class or their combinations
%
%
if isempty(a_struct)
    return;
end

if isa(a_struct,'rundata')
    obj = a_struct;
    if numel(varargin) == 0
        return;
    end
    if isstruct(varargin{1})
        obj=set_param_recursively(obj,varargin{1},varargin{2:end});
    else
        obj=parse_arg(obj,varargin{:});
    end
elseif isstruct(a_struct)
    field_names    = fieldnames(a_struct);
    dir_fields = obj.saveableFields;
    % check if some fields can be set up directly on the
    [obj,field_names]=set_fields_subset(obj,a_struct,dir_fields,field_names);
    if isempty(field_names)
        return;
    end
    % check the fields, defined by lattice
    lat = obj.lattice;
    if isempty(lat)
        lat = oriented_lattice();
    end
    lat_fields = lat.saveableFields();
    [lat,field_names]=set_fields_subset(lat,a_struct,lat_fields,field_names);
    obj.lattice = lat;
    if isempty(field_names)
        return;
    end
    % is there no loader and there are loader fields? They also
    ldf = obj.loader_dependent_fields_;
    [obj,field_names]=set_fields_subset(obj,a_struct,ldf,field_names);
    if ~isempty(field_names)
        error('HERBERT:rundata:invalid_argument',...
            'Attempting to set unknown field(s): %s',...
            strjoin(field_names,'; '));
    end
else
    argi = [a_struct,varargin];
    obj=parse_arg(obj,argi{:});
end
function [targ,remains]=set_fields_subset(targ,source,all_fields,field_selection)
set_here = ismember(field_selection,all_fields);
if any(set_here)
    fld_nms = field_selection(set_here);
    for i=1:numel(fld_nms)
        targ.(fld_nms{i}) = source.(fld_nms{i});
    end
end
remains = field_selection(~set_here);


function this= parse_arg(this,varargin)
% function processes arguments, which are present in varargin as
% couple of 'key','value' parameters or as a structure
% and sets correspondent fields in the input data_structure
%
% usage:
%>> result = parse_arg(source,'a',10,'b','something')
%
%                 source -- structure or class with public fields a and b
%                 result   -- the same structure as source with
%                 result.a==10 and result.b=='something'
%
% throws error if field a and b are not present in source
% usage:
%>> result = parse_arg(template,source)
%                similar to above but fields a and b with correspondent
%                values are set in structure source e.g.

% Parse arguments;
narg = length(varargin);
if narg==0
    return;
end

[field_nams,field_vals] = parse_config_arg(varargin{:});
valid = ~cellfun('isempty',field_vals);
field_nams=field_nams(valid);
field_vals=field_vals(valid);
target_fields = fieldnames(this);

this = set_fields_skip_special(this,field_nams,field_vals,target_fields);

%----------------------------------------------------------------------------------------
function [field_nams,field_vals] = parse_config_arg(varargin)
% Process arguments, which are present in varargin as a number of 'key','value' pairs
% or as a structure, and returns two output cell arrays of fields and values.
%
%   >> [field_nams,field_vals] = parse_config_arg('a',10,'b','something')
%
%   >> [field_nams,field_vals] = parse_config_arg(source)
%                             Similar to above but fields a and b with corresponding
%                             values are set in structure source e.g.
%                             source.a==10 and source.b=='something'

% Parse arguments;
narg = length(varargin);
if narg==0
    return;
elseif narg==1
    svar = varargin{1};
    is_struct = isa(svar,'struct');
    is_cell   = iscell(svar);
    if ~(is_struct || is_cell)
        error('HERBERT:rundata:invalid_argument',...
            'input parameter has to be a structure or a cell array');
    end
    if is_struct
        field_nams = fieldnames(svar)';
        field_vals = cell(1,numel(field_nams));
        for i=1:numel(field_nams)
            field_vals{i}=svar.(field_nams{i});
        end
    end
    if is_cell
        field_nams = svar(1:2:end);
        field_vals = svar(2:2:end);
    end
else
    if (rem(narg,2) ~= 0)
        error('HERBERT:rundata:invalid_argument',...
            'incomplete set of (field,value) pairs given');
    end
    field_nams = varargin(1:2:narg);
    field_vals = varargin(2:2:narg);

end

function this=set_fields_skip_special(this,field_names,field_values,target_fields)
% set rundata fields to the values specified checking if such fields exist
% and are the special fields which redefine loader
%
file_name = '';
par_file_name = '';
loader_redefined = false;
for i=1:numel(field_names)
    cur_field = field_names{i};

    if strcmp(cur_field,'file_name') || strcmp(cur_field,'data_file_name')
        file_name = field_values{i};
        loader_redefined=true;
        continue
    end
    if strcmp(cur_field,'par_file_name')
        par_file_name = field_values{i};
        loader_redefined=true;
        continue
    end

    if ~ismember(cur_field,target_fields)
        if ismember(cur_field,oriented_lattice.lattice_fields())
            this = set_lattice_field(this,cur_field,field_values{i});
            continue
        else
            error('HERBERT:rundata:invalid_arguments',...
                'Attempt to set non-existing field: %s',cur_field);
        end
    end

    if ~isempty(field_names{i})
        this.(field_names{i})=field_values{i};
    end
end
if loader_redefined
    if isempty(this.loader_)
        this=select_loader_(this,file_name,par_file_name);
    else
        if isempty(file_name)
            this.loader_.par_file_name = par_file_name;
        else
            this.loader_ = loaders_factory.instance().get_loader(file_name,par_file_name);
        end
    end
end
