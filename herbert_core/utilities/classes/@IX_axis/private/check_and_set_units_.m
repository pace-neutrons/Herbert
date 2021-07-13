function obj = check_and_set_units_(obj, units)
% Check units and set if valid, converting to character string if needed

if isempty(units)
    obj.units_ = '';
    
elseif is_string(units)
    obj.units_ = units;
    
elseif isstring(units) && numel(units)==1     % single string
    obj.units_ = char(units);
    
else
    error('HERBERT:check_and_set_units_:invalid_argument',...
        'Units code must be a character string');
end
