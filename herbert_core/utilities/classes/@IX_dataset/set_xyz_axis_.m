function obj = set_xyz_axis_(obj, val, iax)
% Method to change axis information for a single axis
%
%   >> obj = set_xyz_axis_(obj, val, iax)
%
% This is a utility routine to set all or part of property xyz_axis_.
% It takes the role of a conventional property set method, but because it
% enables only selected elements in the array to be set it requires more
% input arguments than a conventional set method permits.
%
% Input:
% ------
%   obj     IX_dataset object
%
%   val     IX_axis object, or axis caption which is one of
%           - cellstr
%           - character string or 2D character array
%           - string array
%
%           Alternatively, an array of IX_axis if caption for more than one
%           axis is being set, one element for each axis.
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
        error('HERBERT:set_xyz_axis_:invalid_argument', mess)
    end
end

% Update captions for axes
if ~isa(val,'IX_axis') && isscalar(iax)
    obj = check_and_set_x_axis_(obj, val, iax);
    
elseif isa(val,'IX_axis') && numel(val)==numel(iax)
    for i=1:numel(iax)
        obj = check_and_set_x_axis_(obj, val(i), iax(i));
    end
    
else
    error('HERBERT:set_xyz_axis_:invalid_argument',...
        'The number of arrays of axis coordinates must match the number of axes indicies')
end
