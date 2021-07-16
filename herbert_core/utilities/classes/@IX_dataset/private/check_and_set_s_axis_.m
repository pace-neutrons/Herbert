function obj = check_and_set_s_axis_(obj, val)
% Set axis information, converting to column cellstr if needed
%
%   >> obj = check_and_set_s_axis_(obj, val)
%
% Input:
% ------
%   obj     IX_dataset object
%   val     IX_axis object, or signal caption which is one of
%           - cellstr
%           - character string or 2D character array
%           - string array
%   iax     Axis index 1,2,... ndim()
%
% Output:
% -------
%   obj     Updated object


if isa(val,'IX_axis') && numel(val)==1
    obj.s_axis_ = val;
    
elseif ~isempty(val)
    [ok, cout] = str_make_cellstr(val);
    if ok
        obj.s_axis_ = cout;
    else
        error('HERBERT:check_and_set_s_axis_:invalid_argument',...
            ['Title must be a IX_axis object (type help IX_axis),\n',...
            'or character, string array or cell array of strings']);
    end
    
else
    obj.s_axis_ = IX_axis();
end
