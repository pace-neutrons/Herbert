function [x_label, s_label] = make_label_(obj)
% Create axis annotations
%
%   >> [x_label, s_label] = make_label_(obj)
%
% If given array of objects, get labels for the first object
%
% Input:
% ------
%   obj         IX_dataset object
%
% Output:
% -------
%   x_label     Cell array (row vector) of plot axis captions, one per axis
%               Each caption is a column cellstr
%
%   s_label     Signal axis caption (column cellstr)


% If given array of objects, get labels for the first element
x_label = arrayfun(@(x)make_label(x), obj(1).xyz_axis_);
[s_label,units_appended]=make_label(obj(1).s_axis);

% Now address any distributions
str='';
x_dist = obj(1).xyz_distribution_;
x_axis = obj.xyz_axis_;
for i = 1:numel(x_label)
    if x_dist(i) && ~isempty(x_axis(i).units)
        str=[str,' / ',x_axis(i).units];
    end
end

if ~isempty(str)
    if ~isempty(s_label)
        if units_appended
            s_label{end}=[s_label{end}(1:end-1),str,')'];
        else
            s_label{end}=[s_label{end},' (1',str,')'];
        end
    else
        s_label={['(1',str,')']};
    end
end
