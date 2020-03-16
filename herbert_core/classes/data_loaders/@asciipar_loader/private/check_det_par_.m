function [det_par,n_det,file_name] = check_det_par_(obj,value)
% method checks if value can represent par file and detectors coordinates
% and converts this value into format, used in det_par field
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)
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
        error('A_LOADER:set_det_par',' attempt to set invalid detectors structure, necessary fields are missing')
    end
    n_det = numel(value.group);
    file_name   = fullfile(value.filepath,value.filename);
else
    [n_col,n_det] = size(value);
    if n_col ~= 6
        error('A_LOADER:set_det_par',...
            [' attempt to set invalid detectors parameters.',...
            ' Input is array but number of columns is %d instead of 6'],n_col)
    end
    value = get_hor_format(value,'');
end
det_par = value;




