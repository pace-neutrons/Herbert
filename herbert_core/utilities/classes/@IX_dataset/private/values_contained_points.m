function [np, varargout] = values_contained_points (x1, xref, x2, type, tol)
% Retain values in the semi-open interval [x1,x2)
%
%   >> [np, xout] = values_contained_points (x1, xref, x2)
%
%   >> [np, xout] = values_contained_points (x1, xref, x2, tol)
%
% Input:
% ------
%   x1      Lower limit
%
%   xref    Array of strictly monotonic increasing values. Can be empty.
%
%   x2      Higher limit
%
%   type    Determines whether or not the intervals are open or closed.
%           Format is 'BE'
%           where 'B' is '[' or '(' (Includes or excludes x1)
%                 'E' is ']' or ')' (Includes or excludes x2)
%
%   tol     Tolerance: excludes values within a fraction tol of the
%           width of the interval from the end points.
%           Prevents overly narrow extremal bins from being created.
%               tol >= 0;    default = 1e-10
%
% Output:
% -------
%   np      Number of points
%
%   xout    Output array (row)
%           If x1 < x2, then retain where x1 <= xref < x2, and x1 if not
%           already included. Maximum value is less than x2.
%
%           If x1>=x2 then xout = []


if nargin==4
    tol = 1e-10;    % fractional tolerance on bin width to account for rounding
else
    tol = abs(tol); % ensure >=0
end

if isinf(x1) || isinf(x2)
    error('HERBERT:values_equal_steps:invalid_argument',...
        'Must have finite x1 and x2')
end

if x1 < x2
    [low_closed, high_closed] = parse_origin (type);
    if ~isempty(xref)
        % Get points that are on or within [x1,x2]:
        imin = lower_index (xref, x1);
        imax = upper_index (xref, x2);
        
        % Remove points within tolerance of x1 or x2
        % Note: we needed to get points on boundaries to compute what the
        % absolute tolerance criteria are from the extremal bin boundary
        % widths
        if imax>=imin
            if imax>imin
                % At least two points on or within [x1,x2].
                abstol_lo = tol*(xref(imin+1)-xref(imin));
                abstol_hi = tol*(xref(imax)-xref(imax-1));
            else
                % One point
                width = abs(x2-x1);
                abstol_lo = tol*width;
                abstol_hi = tol*width;
            end
            if (xref(imin) < x1 + abstol_lo)
                imin = imin + 1;
            end
            if (xref(imax) > x2 - abstol_hi)
                imax = imax - 1;
            end
        end
    else
        % Ensure imax<imin; means that xref(imin:imax) == [] in later use
        imin = 1;
        imax = 0;
    end

    np = max(imax - imin + 1, 0) + (low_closed + high_closed);
    if nargout==2
        if low_closed && high_closed
            varargout{1} = [x1, xref(imin:imax), x2];
        elseif low_closed
            varargout{1} = [x1, xref(imin:imax)];
        elseif high_closed
            varargout{1} = [xref(imin:imax), x2];
        else
            varargout{1} = xref(imin:imax);
        end
    end
    
else
    np = 0;
    if nargout==2
        varargout{1} = [];
    end
end

%--------------------------------------------------------------------------
function [low_closed, high_closed] = parse_origin (str)

if numel(str)==2
    low_closed = (str(1)=='[');
    if ~low_closed && str(1)~='('
        error('HERBERT:parse_origin:invalid_argument',...
            'Lower interval closure must be ''['' or ''(''')
    end
    high_closed = (str(2)==']');
    if ~high_closed && str(2)~=')'
        error('HERBERT:parse_origin:invalid_argument',...
            'Upper interval closure must be '']'' or '')''')
    end
else
    error('HERBERT:parse_origin:invalid_argument',...
        'Number of characters is incorrect in interval type')
end
