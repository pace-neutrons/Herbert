function obj = check_and_set_x_axis_(obj, val, iax)
% Set axis information, converting to column cellstr if needed
%
%   >> obj = check_and_set_x_axis_(obj, val)
%
% Input:
% ------
%   obj     IX_dataset object
%
%   val     Array of IX_axis objects or cell array of caption information,
%           one element per axis. Caption information is one of
%           - cellstr
%           - character string or 2D character array
%           - string array
%           If val is empty for an axis, then the corresponding axis
%           caption will be set to the default
%
%   iax     Axis index, assumed to be a scalar in range 1,2,... ndim()
%
% Output:
% -------
%   obj     Updated object

nd = numel(iax);

if ~isempty(val)
    % Fill axis or axes with provided values
    if iscell(val) && numel(val)==nd
        for i=1:nd
            obj = check_and_set_x_axis_single_ (obj, val{i}, iax(i));
        end
    elseif isa(val,'IX_axis') && numel(val)==nd
        for i=1:nd
            obj = check_and_set_x_axis_single_ (obj, val(i), iax(i));
        end
    elseif nd==1
        obj = check_and_set_x_axis_single_ (obj, val, iax);
    else
        error('HERBERT:check_and_set_x_axis_single_:invalid_argument',...
            ['Axis caption values must be a vector length %s of IX_axis ',...
            'objects, a cell\narray of IX_axis objects, or a cell array\n',...
            'of cell arrays of character strings'],...
            num2str(nd));
    end
else
    % Fill axis or axes with the default
    for i=1:nd
        obj = check_and_set_x_axis_single_ (obj, [], iax(i));
    end
end


%--------------------------------------------------------------------------
function obj = check_and_set_x_axis_single_ (obj, val, iax)
% Set axis information, converting to column cellstr if needed
%
%   >> obj = check_and_set_x_axis_single_ (obj, val, iax)
%
% Input:
% ------
%   obj     IX_dataset object
%
%   val     IX_axis object, or axis caption which is one of
%           - cellstr
%           - character string or 2D character array
%           - string array
%           If val is empty, then the axis caption will be set to the
%           default
%
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
