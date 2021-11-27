function [np, varargout] = values_logarithmic_steps (x1, del, x2, origin, tol)
% Logarithmically spaced values in the semi-open interval [x1,x2)
%
%   >> [np, xout] = values_logarithmic_steps (x1, del, x2, origin)
%
%   >> [np, xout] = values_logarithmic_steps (x1, del, x2, origin, tol)
%
% Input:
% ------
%   x1      Lower limit (x1 > 0)
%
%   del     Step size : ratio of higher value to lower value is 1+del i.e.
%           xout(i+1) = xout(i) * (1 + del)  (del must be  greater than 0)
%
%   x2      Higher limit (x2 > 0)
%
%   origin  Determines where the values have their origin
%           'x1'    origin is x1 i.e. values are x1*(1 + |del|)^n, n integer
%           'x2'    origin is x2 i.e. values are x2*(1 + |del|)^n, n integer
%           'c0'    mid points are centred on zero
%
%   tol     Tolerance: smallest difference between values and end points as
%           a fraction of the penultimate spacings at each limit.
%           Prevents overly small extremal bins from being created.
%               tol >= 0;    default = 1e-10
%
% Output:
% -------
%   np      Number of points
%
%   xout    Output array (row)
%           origin = 'x1': xout = [x1, x1*(1+|del|), x1*(1+|del|)^2,..., xmax]
%               where xmax < x2
%           origin = 'x2': xout = [x1, xmin,..., x2*(1+|del|)^(-2),...
%                                                       x2*(1+|del|)^(-1)]
%               where x1 < xmin
%           origin = 'c0': xout = [x1, xmin,..., B*(1+|del|)^(-1), B,...
%                                    B*(1+|del|)^(1),..., xmax]
%               where x1 < xmin and xmax < x2; B = B = 1/(1 + 1/(1+|del|))
%
%           If x1 >= x2, then xout = []


if nargin==4
    tol = 1e-10;    % fractional tolerance on bin width to account for rounding
else
    tol = abs(tol); % ensured >=0
end

if x1 <= 0 || x2 <= 0 || del <= 0 || isinf(x1) || isinf(x2)
    error('HERBERT:values_logarithmic_steps:invalid_argument',...
        'Must have finite x1 > 0, x2 > 0, and del > 0')
end

if x1 < x2
    ratio = 1 + del;
    
    if strcmp(origin,'x1')
        % Steps from x1 (including x1) until within relative tolerance of x2
        np = floor(log(x2/x1)/log(ratio) - tol) + 1;
        if nargout==2
            varargout{1} = [x1, x1 * ratio.^(1:np-1)];
        end
        
    elseif strcmp(origin,'x2')
        % Steps from x2/ratio to within relative tolerance of x1, and then
        % also x1
        np = floor(log(x2/x1)/log(ratio) - tol) + 1;
        if nargout==2
            varargout{1} = [x1, x2 * ratio.^(1-np:-1)];
        end
        
    elseif strcmp(origin,'c0')
        % Midpoints have origin on unity; values lie within the interval to
        % within tol*del of x1 and x2, and then start with x1

        % The following algorithm is based on the fact that the midpoints
        %       c(n) = r ^ n        (where r = c(n+1)/c(n) > 0)
        % can be created from the values
        %       b(n) = B * (r ^ n)  (so b(n+1)/b(n) = r)
        % where
        %       B = 2/(1 + 1/r)     where r = 1 + abs(del);
        
        B = 2*(1+del)/(2+del);  % smallest value greater than unity
        nlo = ceil(log(x1/B)/log(ratio) + tol);
        nhi = floor(log(x2/B)/log(ratio) - tol);
        
        % If there are no values in the open interval (xlo,xhi) then nhi<nlo
        % but the following correcly given nlo:nhi as []
        np = nhi - nlo + 2;
        if nargout==2
            varargout{1} = [x1, B*(ratio.^(nlo:nhi))];
        end

    else
        error('HERBERT:values_equal_steps:invalid_argument',...
            'Unrecognised origin description')
    end
else
    np = 0;
    if nargout==2
        varargout{1} = [];
    end
end
