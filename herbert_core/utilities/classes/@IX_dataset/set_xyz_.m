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
%               - numeric vector, or
%               - cell array of numeric vectors.
%           Each axis coordinates must have elements:
%               - all elements finite (i.e. no -Inf, Inf or NaN)
%               - monotonically increasing
%
%   iax     Axis index or array of indices that must lie in the
%           range 1,2,... ndim(). Must be unique.
%
% Output:
% -------
%   obj     Updated object


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
if ~iscell(val) && isscalar(iax)
    obj = check_and_set_x_(obj, val, iax);
    
elseif iscell(val) && numel(val)==numel(iax)
    for i=1:numel(iax)
        obj = check_and_set_x_(obj, val{i}, iax(i));
    end
    
else
    error('HERBERT:set_xyz_:invalid_argument',...
        'The number of arrays of axis coordinates must match the number of axes indicies')
end

% Must check consistency of number of points with signal and error arrays
% (Do this once at the end to minimise calls to a potentially expensive
% method)
obj = check_properties_consistency_(obj);
