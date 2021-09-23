function code = check_and_set_code_ (val)
% Check units code and set if valid, converting to character string if needed

if ~isempty(val)
    % Set caption
    if is_string(val)
        code = val;
        
    elseif isstring(val) && numel(val)==1     % single string object
        code = char(val);
        
    else
        error('HERBERT:check_and_set_code_:invalid_argument',...
            'Units code must be a character string');
    end
    
else
    % Set code to default empty value
    code = '';
end