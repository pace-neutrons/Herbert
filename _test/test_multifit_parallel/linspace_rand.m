function y = linspace_rand (x1, x2, n, frac)
% Generate linspace with random fluctuations
%
%   >> y = linspace_rand (x1, x2, n, frac)
%
% Exactly like the Matlab instrinsic fuinction linspace, this generates n
% equally spaced points between x1 and x2, except that the values of y have
% random deviations from the equally spaced values.
%
% Input
% -----
%   x1, x2  Lower and upper values of the equally spaced points before
%           random deviates are added
%
%   n       Number of points (default=100). Points spaced by (x2-x1)/(n-1)
% 
%   frac    Gives width of uniform distribution centred on each value of y
%           as a frzction of the point spacing. 0 <=frac < 1
%
% Output:
% -------
%   y       Output values of equally spaced points with rnadom deviates
%           added


y = linspace(x1, x2, n);

if frac > 0 && frac < 1
    delta = (x2 - x1)/(numel(y) - 1);
    y = y + delta * (rand(size(y)) - 0.5);
    
elseif frac~=0
    error ('HERBERT:linspace_rand:invalid_argument',...
        'Argument ''frac'' must satisfy 0 <= frac < 1')
end
