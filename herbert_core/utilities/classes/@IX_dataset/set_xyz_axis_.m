function obj = set_xyz_axis_(obj, val, iax)
% Method to change axis information for a single axis
%
%   >> obj = set_xyz_axis_(obj, val, iax)
%
% Input:
% ------
%   obj     IX_dataset object
%   val     IX_axis object, or axis caption which is one of
%           - cellstr
%           - character string or 2D character array
%           - string array
%   iax     Axis index 1,2,... ndim()
%
% Output:
% -------
%   obj     Updated object


% Update information for the axis
obj = check_and_set_x_axis_(obj, val, iax);
