function [np, varargout] = values_logarithmic_steps (x1, del, x2, tol)
% Logarithmically spaced values in an interval
%
%   >> [np, xout] = values_logarithmic_steps (x1, del, x2, up)
%
% Input:
% ------
%   x1      Starting value (x1 > 0)
%
%   del     Step size : ratio of higher valueto lower value is 1+del i.e.
%           x' = x * (1 + del) (del must be >0)
%
%   x2      Limit value (x2 > 0)
%
%   tol     Tolerance: minimum size of first and final bins as fraction
%           of penultimate bins. Prevents overly small bins from being
%           created.
%               tol >= 0;    default = 1e-10%
% Output:
% -------
%   np      Number of points
%
%   xout    Output array (row)
%           If x1 < x2, then [x1, x1*(1+del), x1*(1+del)^2,..., x2)
%               i.e. maximum value is less than x2
%           If x1 > x2, then [x1, x1*(1+del)^(-1), x1*(1+del)^(-2),..., x2)
%               i.e. minimum value is greater than x2
%           If x1 = x2, then []


if nargin==3
    tol = 1e-10;    % fractional tolerance on bin width to account for rounding
else
    tol = abs(tol); % ensure >=0
end

if x1 <= 0 || x2 <= 0 || del <= 0 || isinf(x1) || isinf(x2)
    error('HERBERT:values_logarithmic_steps:invalid_argument',...
        'Must have finite x1 > 0, x2 > 0, and del > 0')
end

if x1 < x2
    ratio = 1 + abs(del);
    np = floor(log(x2/x1)/log(ratio) - tol) + 1;
    if nargout==2
        varargout{1} = [x1, x1 * ratio.^(1:np-1)];
    end
    
elseif x1 > x2
    ratio = 1 + abs(del);
    np = floor(log(x1/x2)/log(ratio) - tol) + 1;
    if nargout==2
        varargout{1} = [x1, x1 * ratio.^(-1:-1:1-np)];
    end
    
else
    np = 0;
    if nargout==2
        varargout{1} = [];
    end
end
