function units = check_and_set_units_ (val)
% Check units and set if valid, converting to character string if needed

if ~isempty(val)
    % Set units
    if is_string(val)
        units = val;
        
    elseif isstring(val) && numel(val)==1     % single string object
        units = char(val);
        
    else
        error('HERBERT:check_and_set_units_:invalid_argument',...
            'Units code must be a character string');
    end
    
else
    % Set units to default (empty charater array)
    units = '';
end
