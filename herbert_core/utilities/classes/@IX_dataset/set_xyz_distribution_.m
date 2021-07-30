function obj = set_xyz_distribution_(obj, val, iax)
% Method to change the distribution flag for a single axis
%
%   >> obj = set_xyz_distribution_(obj, val, iax)
%
% This is a utility routine to set all or part of property xyz_distribution_.
% It takes the role of a conventional property set method, but because it
% enables only selected elements in the array to be set it requires more
% input arguments than a conventional set method permits.
%
% Input:
% ------
%   obj     IX_dataset object
%
%   val     Distribution flag(s): logical scalar or array where elements
%           have value true or false (or 0 or 1)
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
        error('HERBERT:set_xyz_distribution_:invalid_argument', mess)
    end
end

% Update distribution flags for the axes
if islognum(val) && numel(val)==numel(iax)
    for i=1:numel(iax)
        obj = check_and_set_x_distribution_(obj, val(i), iax(i));
    end
    
else
    error('HERBERT:set_xyz_distribution_:invalid_argument',...
        'The number of arrays of axis coordinates must match the number of axes indicies')
end
