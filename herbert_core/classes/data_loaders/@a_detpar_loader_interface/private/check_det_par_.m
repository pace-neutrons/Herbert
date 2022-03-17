function [det_par,n_det,file_name] = check_det_par_(~,value)
% method checks if value can represent par file and detectors coordinates
% and converts this value into format, used in det_par field
%
%
file_name='';
if isempty(value)
    det_par = [];
    n_det=[];
    return;
end
if isstruct(value)
    flds = fields(value);
    if ~all(ismember({'group','x2','phi','azim','width','height'},flds))
        error('HERBERT:a_detpar_loader:invalid_argument',...
            ' attempt to set invalid detectors structure, necessary fields are missing')
    end
    n_det = numel(value.group);
    file_name   = fullfile(value.filepath,value.filename);
else
    [n_col,n_det] = size(value);
    if n_col ~= 6
        error('HERBERT:a_detpar_loader:invalid_argument',...
            [' attempt to set invalid detectors parameters.',...
            ' Input is array but number of columns is %d instead of 6'],n_col)
    end
    value = get_hor_format(value,'');
end
det_par = value;
