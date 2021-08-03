function [x_label, y_label, s_label] = make_label(obj)
% Create axis annotations
%
%   >> [x_label, y_label, s_label] = make_label(obj)
%
% If given array of objects, get labels for the first object
%
% Input:
% ------
%   obj         IX_dataset_2d object
%
% Output:
% -------
%   x_label     x-axis axis caption (column cellstr)
%   y_label     y-axis axis caption (column cellstr)
%   s_label     Signal axis caption (column cellstr)


[x_labels, s_label] = make_label_(obj);
x_label = x_labels{1};
y_label = x_labels{2};
