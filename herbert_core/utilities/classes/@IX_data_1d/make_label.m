function [x_label, s_label] = make_label(obj)
% Create axis annotations
%
%   >> [x_label, s_label] = make_label(obj)
%
% If given array of objects, get labels for the first object
%
% Input:
% ------
%   obj         IX_dataset_1d object
%
% Output:
% -------
%   x_label     x-axis axis caption (column cellstr)
%   s_label     Signal axis caption (column cellstr)


[x_label, s_label] = make_label_(obj);
