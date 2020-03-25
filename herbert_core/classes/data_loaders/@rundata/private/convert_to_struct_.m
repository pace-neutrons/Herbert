function out_struct = convert_to_struct_(obj)

%  Convert rundata object into a structure, 
out_struct = struct();
out_struct.class_name = class(obj);

fields = {'data_file_name','par_file_name','efix','emode'};

if ~isempty(obj.loader_)
    fields_from_loader = obj.loader_.loader_define();
    in_loader = ismember(fields,fields_from_loader);
    left_fields = fields(~in_loader);  
else
    left_fields = fields;
end


for nf=1:numel(left_fields)
    out_struct.(left_fields{nf}) = obj.(left_fields{nf});
end
if ~isempty(obj.efix_)  %incident energy have is not in the loader or have 
                         % been fixed externally
    out_struct.efix = obj.efix_;
end
if obj.is_crystal
    out_struct.lattice = obj.oriented_lattice_.struct();
end
%-------------------- Store data loaded in memory if necessary.
%
if isempty(out_struct.data_file_name) || ...
        ~(exist(out_struct.data_file_name,'file')==2) || ...
        obj.is_loaded() %
    data_fields = {'S','ERR','en'};
    for i=1:numel(data_fields)
        out_struct.(data_fields{i}) = obj.(data_fields{i});
    end
end
%-------------------- Store detector info if necessary
if ~isfield(out_struct,'par_file_name')
    out_struct.par_file_name = obj.par_file_name;
end

if ~isempty(obj.det_par)
    out_struct.det_par = obj.det_par;
end

if ~isempty(obj.instrument)
    out_struct.instrument = obj.instrument;
end
if ~isempty(obj.sample)
    out_struct.sample = obj.sample;
end
