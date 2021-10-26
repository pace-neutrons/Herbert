function [np, varargout] = values_equal_steps (x1, del, x2, type, tol)
% Equally spaced values in the interval x1 to x2.
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
%   type    Determines where the values have their origin and whether or 
%           not the intervals are open or closed. Format is 'BxxE'
%           where 'B' is '[' or '(' (Includes or excludes x1)
%                 'E' is ']' or ')' (Includes or excludes x2)
%           and 'xx' is one of:
%           'x1'    origin is x1 i.e. values are (x1 + n*del), n integer
%           'x2'    origin is x2 i.e. values are (x2 + n*del), n integer
%           'c0'    mid-points have origin at zero 
%                   i.e. values are del*(n + 1/2), n integer
%           'v0'    origin is 0 i.e. values are n*del, n integer
%
%           For example for x1=10, del=2, x2=15 with:
%           '[x1]' ==>  xout = [10,12,14,15]
%           '(x1]' ==>  xout = [12,14,15]
%           '[x1)' ==>  xout = [10,12,14]
%           '(x1)' ==>  xout = [12,14]
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
% 
%           origin = 'x1':
%           '['     [x1,\                                 /, x2]    ']'
%                          x1+del, x1+2*del,..., x1+n*del
%           '('        [/                                 \]        ')'
%               where x1 + n*del < x2 if ')'
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
    [origin, low_closed, high_closed] = parse_origin (type);
    if strcmp(origin,'x1')
        % Steps from x1 until within tol*del of x2
        np = max(floor((x2-x1)/del - tol), 0);
        if high_closed && (x1+del*np) >= x2 - tol*del
            np = max(np - 1, 0);    % catch case of tol==0 &/or rounding error
        end
        if nargout==2
            if low_closed && high_closed
                varargout{1} = [x1, x1 + del*(1:np), x2];
            elseif low_closed
                varargout{1} = [x1, x1 + del*(1:np)];
            elseif high_closed
                varargout{1} = [x1 + del*(1:np), x2];
            else
                varargout{1} = x1 + del*(1:np);
            end
        end
        
    elseif strcmp(origin,'x2')
        % Steps from x2 to within tol*del of x1
        np = max(floor((x2-x1)/del - tol), 0);
        if low_closed && (x2-del*np) <= x1 + tol*del
            np = max(np - 1, 0);    % catch case of tol==0 &/or rounding error
        end
        if nargout==2
            if low_closed && high_closed
                varargout{1} = [x1, x2 + del*(-np:-1), x2];
            elseif low_closed
                varargout{1} = [x1, x2 + del*(-np:-1)];
            elseif high_closed
                varargout{1} = [x2 + del*(-np:-1), x2];
            else
                varargout{1} = x2 + del*(-np:-1);
            end
        end
        
    elseif strcmp(origin,'c0')
        % Midpoints have origin on zero; values lie within the interval to
        % within tol*del of x1 and x2
        
        % Get measure w.r.t. x = del/2
        % Peculiar calculation for exactness if integer boundaries and tol=0
        nlo = ceil((2*x1-del)/(2*del) + tol);
        nhi = floor((2*x2-del)/(2*del) - tol);
        if low_closed && (del*(2*nlo+1))/2 <= x1 + tol*del
            nlo = nlo + 1;  % catch case of tol==0 &/or rounding error
        end
        if high_closed && (del*(2*nhi+1))/2 >= x2 - tol*del
            nhi = nhi - 1;  % catch case of tol==0 &/or rounding error
        end
        
        % If there are no values in the open interval (xlo,xhi) then nhi<nlo
        % but the following correcly given nlo:nhi as []
        np = max(nhi - nlo + 1, 0);
        if nargout==2
            if low_closed && high_closed
                varargout{1} = [x1, (del*((2*nlo:2:2*nhi)+1))/2, x2];
            elseif low_closed
                varargout{1} = [x1, (del*((2*nlo:2:2*nhi)+1))/2];
            elseif high_closed
                varargout{1} = [(del*((2*nlo:2:2*nhi)+1))/2, x2];
            else
                varargout{1} = (del*((2*nlo:2:2*nhi)+1))/2;
            end
        end
        
    elseif strcmp(origin,'v0')
        % Points have origin on zero; values lie within the interval to
        % within tol*del of x1 and x2
        
        % Get measure w.r.t. x = 0
        nlo = ceil(x1/del + tol);
        nhi = floor(x2/del - tol);
        if low_closed && del*nlo <= x1 + tol*del
            nlo = nlo + 1;    % catch case of tol==0 &/or rounding error
        end
        if high_closed && del*nhi >= x2 - tol*del
            nhi = nhi - 1;    % catch case of tol==0 &/or rounding error
        end
        
        % If there are no values in the open interval (xlo,xhi) then nhi<nlo
        % but the following correcly given nlo:nhi as []
        np = max(nhi - nlo + 1, 0);
        if nargout==2
            varargout{1} = [x1, del*(nlo:nhi)];
            if low_closed && high_closed
                varargout{1} = [x1, del*(nlo:nhi), x2];
            elseif low_closed
                varargout{1} = [x1, del*(nlo:nhi)];
            elseif high_closed
                varargout{1} = [del*(nlo:nhi), x2];
            else
                varargout{1} = del*(nlo:nhi);
            end
        end
        
    else
        error('HERBERT:values_equal_steps:invalid_argument',...
            'Unrecognised origin description')
    end

    % Update the number of values
    np = np + (low_closed + high_closed);
    
else
    np = 0;
    if nargout==2
        varargout{1} = [];
    end
end

%--------------------------------------------------------------------------
function [origin, low_closed, high_closed] = parse_origin (str)

if numel(str)==2
    origin = str;
    low_closed = true;
    high_closed = false;
elseif numel(str)==4
    origin = str(2:3);
    low_closed = (str(1)=='[');
    if ~low_closed && str(1)~='('
        error('HERBERT:parse_origin:invalid_argument',...
            'Lower interval closure must be ''['' or ''(''')
    end
    high_closed = (str(4)==']');
    if ~high_closed && str(4)~=')'
        error('HERBERT:parse_origin:invalid_argument',...
            'Upper interval closure must be '']'' or '')''')
    end
else
    error('HERBERT:parse_origin:invalid_argument',...
        'Number of characters is incorrect in interval type')
end
