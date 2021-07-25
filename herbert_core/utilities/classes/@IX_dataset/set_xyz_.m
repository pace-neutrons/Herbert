function obj = set_xyz_(obj, val, iax)
% Method to change axis coordinates for a single axis
%
%   >> obj = set_xyz_(obj, val, iax)
%
% Input:
% ------
%   obj     IX_dataset object
%   val     Axis coordinates: numeric row vector
%               - all elements finite (i.e. no -Inf, Inf or NaN)
%               - monotonically increasing 
%   iax     Axis index 1,2,... ndim()
%
% Output:
% -------
%   obj     Updated object

% Update values along axis
obj = check_and_set_x_(obj, val, iax);

% Must check consistency of number of points with signal and error arrays
obj = check_properties_consistency_(obj);
