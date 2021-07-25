function obj = set_xyz_distribution_(obj, val, iax)
% Method to change the distribution flag for a single axis
%
%   >> obj = set_xyz_distribution_(obj, val, iax)
%
% Input:
% ------
%   obj     IX_dataset object
%   val     Distribution flag: logical true or false (or 0 or 1) 
%   iax     Axis index 1,2,... ndim()
%
% Output:
% -------
%   obj     Updated object

% Update distribution flag for the axis
obj = check_and_set_x_distribution_(obj, val, iax);
