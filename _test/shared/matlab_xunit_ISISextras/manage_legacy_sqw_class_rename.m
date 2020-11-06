function processed = manage_legacy_sqw_class_rename(data)
% Perform pre-processing on data loaded from .mat files as part of the
% TestCaseWithSave workflow.
%
% This is a temporary function to manage reengineering of the `sqw` object
% during which the old class is renamed as `sqw_old`, and will load as
% a struct rather than class instance.

if isfield(data, 'main_header') && isfield(data, 'header') && isfield(data, 'detpar')
    processed = sqw_old(data);
elseif isstruct(data)
    field_names = fields(data);
    for idx = 1:length(field_names)
        field_name = field_names{idx};
        for inner_idx = 1:numel(data.(field_name))
            processed.(field_name)(inner_idx) = manage_legacy_sqw_class_rename(data.(field_name)(inner_idx));
        end
        processed.(field_name) = processed.(field_name)';
    end
else
    processed = data;
end
end