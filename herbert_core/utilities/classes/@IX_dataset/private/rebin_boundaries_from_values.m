function xout = rebin_boundaries_from_values (xin, is_boundaries, xref)
% Resolve -Inf and/or Inf in the array of bin boundaries or centres
%
% If x-axis values are all finite:
%   >> xout = rebin_boundaries_from_values (xin, is_boundaries)
%
% General case:
%   >> xout = rebin_boundaries_from_values (xin, is_boundaries, xref)
%
% Input:
% ------
%   xin             Actual bin boundaries or centres:
%
%         [x1, x2, x3,...xn]
%               where -Inf <= x1 < x2 <...< xn <= Inf   (n >=2)
%
%       The special case of n=2, finite x1, x2 and x1=x2 is permitted (a
%       bin of zero width, which will be valid if point data, all points
%       with x=x1)
%
%   is_boundaries   Logical flag:
%                    - true if xin defines bin boundaries
%                    - false if xin defines bin centres
%                  [Note that -Inf and Inf always end up defining bin
%                   boundaries. This is a statement about the finite values
%                   of x1, x2,... that appear in the descriptor]
%
%   xref            Reference axis values.
%                    - If bin boundaries then there will be at least two
%                      values and with bin widths greater than zero (i.e.
%                      the values are strictly monotonic increasing)
%                    - If bin centres, then they will be monotonic
%                      increasing, but there may be repeated values, which
%                      corresponds to two or more data points that have the
%                      same position along the axis.
%
% Output:
% -------
%   xout            Bin boundaries for rebin array (row vector)
%               It is possible to end up with just two bin boundaries whose
%               values are the same 

if ~(isinf(xin(1)) || isinf(xin(end)))
    % All input values are all finite
    if is_boundaries
        xout = xin;
    else
        xout = bin_boundaries (xin);
    end
    
else
    % Bin boundaries or centres:
    %   [x1, x2, x3,...xn]
    %       where -Inf <= x1 < x2 <...< xn <= Inf
    %
    % Guiding principles in resolving +/-infinity:
    %
    % - Inf (-Inf) if present define the value of the outermost bin
    %   boundaries, unless an explicit value (boundary or centre) in
    %   the description that is more extreme.
    %
    % - The finite values will always exist as bin boundaries
    %   (is_boundaries = true), or be used to generate a set of
    %   bin boundaries (is_boundaries = false).
    %
    % - Inf (-Inf) will be resolved into xhi (xlo) and then made the
    %   more extreme of xhi and x(n-1) (xlo and x2) as the defining
    %   outer boundary. This is true for is_boundaries true or
    %   false [*1]. That is, Inf and -Inf if present will declare the
    %   extent of the data as the outer boundaries, except where there
    %   is an explicit value in the description that is more extreme.
    %
    % - If the resolved values have x1=xn (can happen if n=2 or n=3
    %   e.g. [-Inf,5,Inf] where point data with all points having x=5,
    %   or [5,Inf] where histogram data where boundaries are [2,3,4,5])
    %   this can be valid if:
    %       - the data is point data (so the first of the two examples)
    %       - there are data at x1
    %       - the point averaging method is overidden to 'ave'
    %
    %
    %  [*1] The reason for this is as follows. Suppose we have
    %       xin = [-Inf,10,12,14] and is_boundaries = false.
    %       Then bin boundaries are constructed at [9,11,13,15]. Now
    %       suppose the data has minimum of 9.5. We want the rebinning
    %       to extend no lower than the data unless an explicit finite
    %       value has been given. That is what the first guiding
    %       principle states. Therefore the lowest bin boundary is set
    %       to 9.5. If The data mionimum was 10.5, then it would be set
    %       to 10, as this appeared in the bin centres list.
    
    xlo = xref(1);
    xhi = xref(end);
    
    if ~is_boundaries && ...
            (numel(xin) - isinf(xin(1)) - isinf(xin(end))) >= 2
        % Contains at least two finite bin centres so able to generate
        % bin boundaries.
        % These finite bin centres will have a non-zero separation, so
        % we are guaranteed to have at least one, non-zero width bin
        % at the conclusion of this block of code.
        xout = bin_boundaries(xin(1+isinf(xin(1)):end-isinf(xin(end))));
        if xin(1) == -Inf
            if xlo < xout(1)
                % Data lies outside bin boundaries, so add an extra bin
                xout = [xlo, xout];
            else
                % Limit of data within outer bin; truncate bin
                xout(1) = min(xlo, xin(2));
            end
        end
        if xin(end) == Inf
            if xhi > xout(end)
                % Data lies outside bin boundaries, so add an extra bin
                xout = [xout, xhi];
            else
                % Limit of data within outer bin; truncate bin
                xout(end) = max(xhi, xin(end-1));
            end
        end
        
    else
        % Bin boundaries, or bin centres with one or no finite value.
        % It is possible to have a single bin [xlo,xhi] at the end,
        % This will be valid if the data is point data and all points
        % have the same value of x == xlo.
        xout = xin(1+isinf(xin(1)):end-isinf(xin(end)));
        if xin(1) == -Inf
            if ~isempty(xout)
                if xlo < xout(1)
                    xout = [xlo, xout];
                else
                    xout(1) = min(xlo, xout(1));
                end
            else
                xout = xlo;
            end
        end
        if xin(end) == Inf
            if xhi > xout(end)
                xout = [xout, xhi];
            else
                xout(end) = max(xhi, xout(end));
            end
        end
        if numel(xout)==1
            % Make a bin of zero width.
            xout = [xout,xout];
        end
    end
    
end
