function [np, varargout] = values_logarithmic_steps (x1, del, x2, type, tol)
% Logarithmically spaced values in the interval x1 to x2.
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
%   type    Determines where the values have their origin and whether or 
%           not the intervals are open or closed. Format is 'BxxE'
%           where 'B' is '[' or '(' (Includes or excludes x1)
%                 'E' is ']' or ')' (Includes or excludes x2)
%           and 'xx' is one of:
%           'x1'    origin is x1 i.e. values are x1*(1 + |del|)^n, n integer
%           'x2'    origin is x2 i.e. values are x2*(1 + |del|)^n, n integer
%           'c0'    mid points are centred on unity
%                   i.e. mid-points are at (1+del)^n, n integer
%           'v0'    origin is 0 i.e. values are n*del, n integer
%                   i.e. values are (1+del)^n, n integer
%
%           For example for x1=10, del=0.5, x2=25 with:
%           '[x1]' ==>  xout = [10, 15, 22.5, 25]
%           '(x1]' ==>  xout = [15, 22.5, 25]
%           '[x1)' ==>  xout = [10, 15, 22.5]
%           '(x1)' ==>  xout = [15, 22.5]
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
    
    [origin, low_closed, high_closed] = parse_origin (type);
    if strcmp(origin,'x1')
        % Steps from x1 (until within relative tolerance of x2
        np = max(floor(log(x2/x1)/log(ratio) - tol), 0);
        if high_closed && x1*(ratio^np) >= x2*(ratio^-tol)
            np = max(np - 1, 0);    % catch case of tol==0 &/or rounding error
        end
        if nargout==2
            if low_closed && high_closed
                varargout{1} = [x1, x1 * ratio.^(1:np), x2];
            elseif low_closed
                varargout{1} = [x1, x1 * ratio.^(1:np)];
            elseif high_closed
                varargout{1} = [x1 * ratio.^(1:np), x2];
            else
                varargout{1} = x1 * ratio.^(1:np);
            end
        end
        
    elseif strcmp(origin,'x2')
        % Steps from x2/ratio to within relative tolerance of x1
        np = max(floor(log(x2/x1)/log(ratio) - tol), 0);
        if low_closed && x2*(ratio^-np) <= x1*(ratio^tol)
            np = max(np - 1, 0);    % catch case of tol==0 &/or rounding error
        end
        if nargout==2
            if low_closed && high_closed
                varargout{1} = [x1, x2 * ratio.^(-np:-1), x2];
            elseif low_closed
                varargout{1} = [x1, x2 * ratio.^(-np:-1)];
            elseif high_closed
                varargout{1} = [x2 * ratio.^(-np:-1), x2];
            else
                varargout{1} = x2 * ratio.^(-np:-1);
            end
        end
        
    elseif strcmp(origin,'c0')
        % Midpoints have origin on unity; values lie within the interval to
        % within tol*del of x1 and x2

        % The following algorithm is based on the fact that the midpoints
        %       c(n) = r ^ n        (where r = c(n+1)/c(n) > 0)
        % can be created from the values
        %       b(n) = B * (r ^ n)  (so b(n+1)/b(n) = r)
        % where
        %       B = 2/(1 + 1/r)     where r = 1 + abs(del);
        
        B = 2*(1+del)/(2+del);  % smallest value greater than unity
        nlo = ceil(log(x1/B)/log(ratio) + tol);
        nhi = floor(log(x2/B)/log(ratio) - tol);
        if low_closed && B*(ratio^nlo) <= x1*(ratio^tol)
            nlo = nlo + 1;  % catch case of tol==0 &/or rounding error
        end
        if high_closed && B*(ratio^nhi) >= x2*(ratio^-tol)
            nhi = nhi - 1;  % catch case of tol==0 &/or rounding error
        end
        
        % If there are no values in the open interval (xlo,xhi) then nhi<nlo
        % but the following correcly given nlo:nhi as []
        np = max(nhi - nlo + 1, 0);
        if nargout==2
            if low_closed && high_closed
                varargout{1} = [x1, B*(ratio.^(nlo:nhi)), x2];
            elseif low_closed
                varargout{1} = [x1, B*(ratio.^(nlo:nhi))];
            elseif high_closed
                varargout{1} = [B*(ratio.^(nlo:nhi)), x2];
            else
                varargout{1} = B*(ratio.^(nlo:nhi));
            end
        end

    elseif strcmp(origin,'v0')
        % Points have origin on unity; values lie within the interval to
        % within tol*del of x1 and x2
        
        nlo = ceil(log(x1)/log(ratio) + tol);
        nhi = floor(log(x2)/log(ratio) - tol);
        if low_closed && ratio^nlo <= x1*(ratio^tol)
            nlo = nlo + 1;  % catch case of tol==0 &/or rounding error
        end
        if high_closed && ratio^nhi >= x2*(ratio^-tol)
            nhi = nhi - 1;  % catch case of tol==0 &/or rounding error
        end
        
        % If there are no values in the open interval (xlo,xhi) then nhi<nlo
        % but the following correcly given nlo:nhi as []
        np = max(nhi - nlo + 1, 0);
        if nargout==2
            if low_closed && high_closed
                varargout{1} = [x1, ratio.^(nlo:nhi), x2];
            elseif low_closed
                varargout{1} = [x1, ratio.^(nlo:nhi)];
            elseif high_closed
                varargout{1} = [ratio.^(nlo:nhi), x2];
            else
                varargout{1} = ratio.^(nlo:nhi);
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
