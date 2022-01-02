function obj = set_xyz_distribution_(obj, val, iax)
% Method to change the distribution flag for one or more axes
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
%   val     Distribution flag(s): 
%               - logical true or false, or 1 or 0 (if setting a single axis)
%               - Logical array (or arry of ones or zeros) (if setting
%                 more than one axis)
%               - Cell array of logical scalars (i.e. true or false, 
%                 or 1 or 0), one per axis
%
%   iax     Axis index or array of indices that must lie in the
%           range 1,2,... ndim(). Must be unique.
%
% Output:
% -------
%   obj     Updated object


nd = obj.ndim();

% Check the validity of the axis indices
if nargin==2
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
xyz_distribution_new = obj.xyz_distribution_;
xyz_distribution_new(iax) = check_and_set_x_distribution_ (val, iax);
obj.xyz_distribution_ = xyz_distribution_new;
