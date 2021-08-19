function [np, varargout] = values_equal_steps (x1, del, x2, tol)
% Equally spaced values in an interval
%
%   >> [np, xout] = values_equal_steps (x1, del, x2)
%
%   >> [np, xout] = values_equal_steps (x1, del, x2, tol)
%
% Input:
% ------
%   x1      Starting value
%
%   del     Step size
%
%   x2      limit value
%
%   tol     Tolerance: minimum size of first and final bins as fraction
%           of penultimate bins. Prevents overly small bins from being
%           created.
%               tol >= 0;    default = 1e-10
%
% Output:
% -------
%   np      Number of points
%
%   xout    Output array (row)
%           If x1 < x2, then [x1, x1+del, x1+2*del,..., x2)
%               i.e. maximum value is less than x2
%           If x1 > x2, then [x1, x1-del, x1-2*del,..., x2)
%               i.e. minimum value is greater than x1
%           If x1 = x2, then []


if nargin==3
    tol = 1e-10;    % fractional tolerance on bin width to account for rounding
else
    tol = abs(tol); % ensure >=0
end

if del <= 0 || isinf(x1) || isinf(x2)
    error('HERBERT:values_equal_steps:invalid_argument',...
        'Must have finite x1, x2, del, and del > 0')
end

if x1 < x2
    np = floor((x2-x1)/del - tol) + 1;
    if nargout==2
        varargout{1} = [x1, x1 + del*(1:np-1)];
    end
    
elseif x1 > x2
    np = floor((x1-x2)/del - tol) + 1;
    if nargout==2
        varargout{1} = [x1, x1 + del*(-1:-1:1-np)];
    end
    
else
    np = 0;
    if nargout==2
        varargout{1} = [];
    end
end
