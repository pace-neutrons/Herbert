function obj = check_and_set_x_axis_(obj, val, iax)
% Set axis information, converting to column cellstr if needed
%
%   >> obj = check_and_set_x_axis_(obj, val)
%
% Input:
% ------
%   obj     IX_dataset object
%   val     IX_axis object, or axis caption which is one of
%           - cellstr
%           - character string or 2D character array
%           - string array
%   iax     Axis index, assumed to be a scalar in range 1,2,... ndim()
%
% Output:
% -------
%   obj     Updated object


if isa(val,'IX_axis') && numel(val)==1
    obj.xyz_axis_(iax) = val;
    
elseif ~isempty(val)
    [ok, cout] = str_make_cellstr(val);
    if ok
        obj.xyz_axis_(iax) = IX_axis(cout);
    else
        error('HERBERT:check_and_set_x_axis_:invalid_argument',...
            ['Axis ', num2str(iax), ': axis caption must be a IX_axis object (type help IX_axis),\n',...
            'or character string, string array or cell array of strings']);
    end
    
else
    obj.xyz_axis_(iax) = IX_axis();
end
