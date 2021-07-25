function [label, units_appended] = make_label(obj)
% Create axis annotation
%
%   >> [label, units_appended] = make_label(obj)
%
% Input:
% ------
%   obj     IX_axis object
%
% Output:
% -------
%   label           Caption for a plot (cellstr)
%
%   units_appended  Logical flag:
%                   - true if units have been appended to the caption
%                     (happens if the units property is non-empty)
%                   - false otherwise
%                   Equivalent to ~isempty(obj.units)


if ~isempty(obj.units)
    if ~isempty(obj.caption)
        label = obj.caption;
        label{end} = [obj.caption{end},' (',obj.units,')'];
    else
        label = {['(',obj.units,')']};
    end
    units_appended = true;
else
    label = obj.caption;
    units_appended = false;
end
