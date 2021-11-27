function [np, varargout] = values_equal_steps (x1, del, x2, origin, tol)
% Equally spaced values in the semi-open interval [x1,x2)
%
%   >> [np, xout] = values_equal_steps (x1, del, x2, origin)
%
%   >> [np, xout] = values_equal_steps (x1, del, x2, origin, tol)
%
% Input:
% ------
%   x1      Lower limit
%
%   del     Step size (del>0)
%
%   x2      Higher limit
%
%   origin  Determines where the values have their origin
%           'x1'    origin is x1 i.e. values are (x1 + n*del), n integer
%           'x2'    origin is x2 i.e. values are (x2 + n*del), n integer
%           'c0'    mid-points have origin at zero 
%                   i.e. values are del*(n + 1/2), n integer
%
%   tol     Tolerance: smallest difference between values and end points as
%           a fraction of del.
%           Prevents overly small extremal bins from being created.
%               tol >= 0;    default = 1e-10
%
% Output:
% -------
%   np      Number of points
%
%   xout    Output array (row)
%           origin = 'x1':
%           '['     [x1, x1+del, x1+2*del,..., xmax]
%           '('     [    x1+del, x1+2*del,..., xmax]
%               where xmax < x2 if ')'
%               where xmax <= x2 if ']'
%               where xmax >= x2 if '('
%
%
%           origin = 'x2': xout = [x1, xmin,..., x2-2*del, x2-del]
%               where x1 < xmin
%           origin = 'c0': xout = [x1, xmin,..., -3*del/2, -del/2, del/2,...
%                                    3*del/2,..., xmax]
%               where x1 < xmin and xmax < x2
%
%           If x1>=x2 then xout = []


if nargin==4
    tol = 1e-10;    % fractional tolerance on bin width to account for rounding
else
    tol = abs(tol); % ensure >=0
end

if del <= 0 || isinf(x1) || isinf(x2)
    error('HERBERT:values_equal_steps:invalid_argument',...
        'Must have finite x1, x2, del, and del > 0')
end

if x1 < x2
    if strcmp(origin,'x1')
        % Steps from x1 (including x1) until within tol*del of x2
        np = floor((x2-x1)/del - tol) + 1;
        if nargout==2
            varargout{1} = [x1, x1 + del*(1:np-1)];
        end
        
    elseif strcmp(origin,'x2')
        % Steps from x2-del to within tol*del of x1, and then also x1
        np = floor((x2-x1)/del - tol) + 1;
        if nargout==2
            varargout{1} = [x1, x2 + del*(1-np:-1)];
        end
        
    elseif strcmp(origin,'c0')
        % Midpoints have origin on zero; values lie within the interval to
        % within tol*del of x1 and x2, and then start with x1
        
        % Get measure w.r.t. x = del/2
        % Peculiar calculation for exactness if integer boundaries and tol=0
        nlo = ceil((2*x1-del)/(2*del) + tol);
        nhi = floor((2*x2-del)/(2*del) - tol);
        
        % If there are no values in the open interval (xlo,xhi) then nhi<nlo
        % but the following correcly given nlo:nhi as []
        np = nhi - nlo + 2;
        if nargout==2
            varargout{1} = [x1, (del*((2*nlo:2:2*nhi)+1))/2];
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
