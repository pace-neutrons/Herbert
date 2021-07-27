function obj = set_xyz_(obj, val, iax)
% Method to change axis coordinates for one or more axes
%
%   >> obj = set_xyz_(obj, val, iax)
%
% Input:
% ------
%   obj     IX_dataset object
%
%   val     Axis coordinates:
%               - numeric row vector, or
%               - cell array of numeric row vectors.
%           Each axis coordinates must have elements:
%               - all elements finite (i.e. no -Inf, Inf or NaN)
%               - monotonically increasing
%
%   iax     Axis index or array of indices that are assumed to lie in the
%           range 1,2,... ndim().
%           It is assumed that the number of axis indices and number of
%           axis coordinate arrays is the same
%
% Output:
% -------
%   obj     Updated object


% Update values along axis
if ~iscell(val)
    obj = check_and_set_x_(obj, val, iax);
else
    for i=1:numel
        obj = check_and_set_x_(obj, val{i}, iax(i));
    end
end

% Must check consistency of number of points with signal and error arrays
% (Do this once at the end to minimise calls to a potentially expensive
% method)
obj = check_properties_consistency_(obj);
