function obj = check_and_set_code_(obj, code)
% Check units code and set if valid, converting to character string if needed

if isempty(code)
    obj.code_ = '';
    
elseif is_string(code)
    obj.code_ = code;
    
elseif isstring(code) && numel(code)==1     % single string
    obj.code_ = char(code);
    
else
    error('HERBERT:check_and_set_code_:invalid_argument',...
        'Units code must be a character string');
end
