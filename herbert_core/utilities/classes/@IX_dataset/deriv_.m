function obj_out = deriv_ (obj, iax)
% Numerical first derivative along an axis of an IX_dataset object or array
%
%   >> obj_out = deriv (obj, iax)
%
% Input:
% ------
%   obj     Input object or array of objects
%
%   iax     Axis index in the range 1 to ndim (the dimensionality of the
%           object)
%
% Output:
% -------
%   obj_out Output object or array of objects


nd = obj.ndim();    % works even if empty obj array, as static method

% Check the validity of the axis indices
if nargin==1
    iax = 1;
else
    if ~isscalar(iax) || ~isnumeric(iax) || rem(iax,1)~=0 ||...
            iax<1 || iax>nd
        if nd==1
            mess = 'Axis indices can only take the value 1';
        else
            mess = ['Axis indices must be an integer in the range 1 to ',...
                num2str(nd)];
        end
        error('HERBERT:deriv_:invalid_argument', mess)
    end
end

% Convert each object in turn
obj_out = obj;
for i = 1:numel(obj)
    obj_out(i) = deriv_single_(obj(i), iax);
end


%--------------------------------------------------------------------------
function obj_out = deriv_single_(obj, iax)
% Numerical first derivative along an axis of an IX_dataset object

[ax, hist] = axis_(obj, iax);
if hist
    x = bin_centres (ax.values);
else
    x = ax.values;
end

obj_out = obj;
[obj_out.sout, obj.out.eout] = deriv_points (x, obj.signal_, obj.error_, iax);
