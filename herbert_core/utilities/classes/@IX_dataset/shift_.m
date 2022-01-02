function obj_out = shift_ (obj, xshift, iax)
% Shift an object or array of objects along one or more axes
%
%   >> obj_out = shift (obj, x, iax)
%
% Input:
% ------
%   obj         Input object or array of objects
%
%   xshift      Shift vector: vector with length equal to the number of
%               axes being shifted, as given by input argument iax
%
%   iax         Axis index or array of indices that must lie in the
%               range 1,2,... ndim(). Must be unique.
%
% Output:
% -------
%   obj_out     Output object


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
        error('HERBERT:shift_:invalid_argument', mess)
    end
end

if ~isvector(xshift) || numel(xshift)~=numel(iax)
    error('HERBERT:shift_:invalid_argument', ['Axis shift must be a vector ',...
        'with length equal to the number of axes to be shifted'])
end

% Convert each object in turn
obj_out = obj;
for i = 1:numel(obj)
    obj_out(i) = shift_single_(obj(i), xshift, iax);
end


%--------------------------------------------------------------------------
% Update values along axes
function obj_out = shift_single_(obj, xshift, iax)
val = obj.xyz_(iax);
for i=1:numel(iax)
    val{i} = val{i} + xshift(i);
end
obj_out = obj;
obj_out.xyz_(iax) = check_and_set_x_ (val, iax);
