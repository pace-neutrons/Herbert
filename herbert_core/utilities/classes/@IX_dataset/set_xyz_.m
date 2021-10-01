function obj = set_xyz_(obj, val, iax)
% Method to change axis coordinates for one or more axes
%
%   >> obj = set_xyz_(obj, val, iax)
%
% This is a utility routine to set all or part of property xyz_.
% It takes the role of a conventional property set method, but because it
% enables only selected elements in the array to be set it requires more
% input arguments than a conventional set method permits.
%
% Input:
% ------
%   obj     IX_dataset object
%
%   val     Axis coordinates:
%               - numeric vector (if settng a single axis), or
%               - cell array of numeric vectors (if setting one or more axes)
%           Each axis coordinates array must satisfy:
%               - all elements are finite (i.e. no -Inf, Inf or NaN)
%               - strictly monotonically increasing in the case of 
%                 histogram values (i.e. all bins must have non-zero width)
%               - arbitrary order in the case of point data
%
%   iax     Axis index or array of indices that must lie in the
%           range 1,2,... ndim(). Must be unique.
%
% Output:
% -------
%   obj     Updated object.

% Note: The axis values are checked for monotonicity and sorted if point
%       data elsewhere. This can only be done with knowledge of the
%       signal array size, as this will determine if the data is histogram,
%       point, or inconsistent (i.e. neither).


nd = obj.ndim();

% Check the validity of the axis indices
if nargin==1
    iax = 1:nd;
else
    if isempty(iax) || ~isnumeric(iax) || any(rem(iax,1)~=0) ||...
            any(iax<1) || any(iax>nd) || numel(unique(iax))~=numel(iax)
        if nd==1
            mess = 'Axis indices can only take the value 1';
        else
            mess = ['Axis indices must be unique and in the range 1 to ', num2str(nd)];
        end
        error('HERBERT:set_xyz_:invalid_argument', mess)
    end
end

% Update values along axes
xyz_new = obj.xyz_;
xyz_new(iax) = check_and_set_x_ (val, iax);
obj.xyz_ = xyz_new;

% Must check consistency of number of points with signal and error arrays
% (Do this once at the end to minimise calls to a potentially expensive
% method)
obj = check_properties_consistency_(obj);
