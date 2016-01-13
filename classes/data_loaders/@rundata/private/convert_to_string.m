function str= convert_to_string(run)
% convert rundata class to a plain string representation
% allowing later conversion back into the run
%
%
% $Revision: 371 $ ($Date: 2014-04-04 17:34:46 +0100 (Fri, 04 Apr 2014) $)
%

[undefined,fields_from_loader,fields_undef] = check_run_defined(run);
if (undefined>2)
    undef_str = strjoin(fields_undef,'; ');
    error('RUNDATA:to_string','Can not confvert to string undefined rundata class due to undefined fields %s',undef_str)
end
fields = {'data_file_name','par_file_name','efix','emode','is_crystal','lattice'};

in_loader = ismember(fields,fields_from_loader);
left_fields = fields(~in_loader);

out_struct = struct();
for nf=1:numel(left_fields)
    out_struct.(left_fields{nf}) = run.(left_fields{nf});      
end
if ~isfield(out_struct,'data_file_name')
    out_struct.data_file_name = run.data_file_name;
end
if ~isfield(out_struct,'par_file_name')
    out_struct.par_file_name = run.par_file_name;
end

v = hlp_serialize(out_struct);
str_arr =num2str(v);
str = reshape(str_arr,numel(str_arr),1);