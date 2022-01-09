function [yd, ed] = deriv_xye (x, y, e)
% Numerical first derivative of x-y-e data
%
%   >> [yd, ed] = deriv_xye (x, y, e)
%
% Input:
% ------
%   x   x values (vector)
%   y   Signal (vector same length as x)
%   e   Standard deviations on signal (vector same length as signal)
%
% Output:
% -------
%   yd  Derivative of signal. Has the same size as the input y.
%       If there is only one point along the axis, the derivative is
%       returned as NaN
%   ed  Standard deviation. Has the same size as the input e.
%
%
% Method:
% The derivative is calculated at point i as 
%   dy(i) = (y(i+1) - y(i-1)) / (x(i+1) - x(i-1))
%
% At the end points
%   dy(1) = (y(2)-y(1))/(x(2)-x(1))
%   dy(end) = (y(end) - y(end-1)) / (x(end) - x(end-1))


% Check lengths of input arrays
np=numel(x);
if numel(y)~=np || numel(e)~=np
    error('HERBERT:deriv_xye:invalid_argument',...
        'x,y,e arrays must have equal lengths')
end

% Catch trivial case of empty arrays or one point
if np <= 1
    yd = NaN(size(y));
    ed = NaN(size(e));
    return
end

% Calculate derivative
dx = x(3:end) - x(1:end-2);
dy = y(3:end) - y(1:end-2);
yd_beg = (y(2) - y(1)) / (x(2) - x(1));
yd_end = (y(end) - y(end-1)) / (x(end) - x(end-1));
yd = [yd_beg; dy(:)./dx(:); yd_end];

% Calculate error bars using standard method
edsqr = e(3:end).^2 + e(1:end-2).^2;
ebeg = sqrt(e(2)^2 + e(1)^2) / (x(2)-x(1));
eend = sqrt(e(end)^2 + e(end-1)^2) / (x(end)-x(end-1));
ed = [ebeg; sqrt(edsqr(:))./dx(:); eend];

% Return arrays to original sizes
yd = reshape(yd, size(y));
ed = reshape(ed, size(e));
