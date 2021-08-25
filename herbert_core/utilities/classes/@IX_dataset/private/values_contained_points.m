function [np, varargout] = values_contained_points (x1, xref, x2, tol)
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


% *** Need to make the tolerance checking more sophisticated: at the
%     moment it is as a fraction of the entire interval, rather than the
%     nearest reference bin widths at the extrema of the interval


if nargin==3
    tol = 1e-10;    % fractional tolerance on bin width to account for rounding
else
    tol = abs(tol); % ensure >=0
end

if isinf(x1) || isinf(x2)
    error('HERBERT:values_equal_steps:invalid_argument',...
        'Must have finite x1 and x2')
end

if x1 < x2
    if ~isempty(xref)
        % Get lower and upper indicies of input array of bin boundaries
        % such that x1 < xref(imin) <= xref(imax) < x2:
        width = abs(x2-x1);
        imin = lower_index(xref, x1 + tol*width);
        imax = upper_index(xref, x2 - tol*width);
        if imin <= numel(xref) && imax >= 1
            % There is an overlap of [xlo,xhi] and xref. There may not be
            % any values of xref within or on the boundaries of [xlo,xhi]
            if (xref(imin)==x1), imin = imin + 1; end
            if (xref(imax)==x2), imax = imax - 1; end
            np = imax - imin + 2;
            if nargout==2
                varargout{1} = [x1, xref(imin:imax)];
            end
        else
            np = 1;
            if nargout==2
                varargout{1} = x1;
            end
        end
    else
        np = 1;
        if nargout==2
            varargout{1} = x1;
        end
    end
    
else
    np = 0;
    if nargout==2
        varargout{1} = [];
    end
end
