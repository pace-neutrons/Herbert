function s_axis_ = check_and_set_s_axis_(val)
% Set signal axis information
%
%   >> s_axis_ = check_and_set_s_axis_(val)
%
% Input:
% ------
%   val     IX_axis object, or signal caption which is one of
%           - cellstr
%           - character string or 2D character array
%           - string array
%           If val is empty, then the signal caption will be set to the
%           default
%
% Output:
% -------
%   s_axis_ Verified, and if necessary reformatted, signal axis


if ~isempty(val)
    if isa(val,'IX_axis') && numel(val)==1
        s_axis_ = val;
        
    else
        [ok, cout] = str_make_cellstr(val);
        if ok
            s_axis_ = IX_axis(cout);
        else
            error('HERBERT:check_and_set_s_axis_:invalid_argument',...
                ['Title must be a IX_axis object (type help IX_axis),\n',...
                'or character, string array or cell array of strings']);
        end
    end
    
else
    % Set to default empty value
    s_axis_ = IX_axis();
end
