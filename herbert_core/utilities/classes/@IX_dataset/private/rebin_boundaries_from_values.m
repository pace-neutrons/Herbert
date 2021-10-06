function xout = rebin_boundaries_from_values (xin, is_boundaries, varargin)
% Resolve -Inf and/or Inf in the array of bin boundaries or centres
%
% If x-axis values are all finite:
%   >> xout = rebin_boundaries_from_values (xin, is_boundaries)
%   >> xout = rebin_boundaries_from_values (xin, is_boundaries, tol)
%
% General case:
%   >> xout = rebin_boundaries_from_values (xin, is_boundaries, xref)
%   >> xout = rebin_boundaries_from_values (xin, is_boundaries, xref, tol)
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
%                   boundaries. The value of is_boundaries is a statement
%                   about the finite values of [x1,] x2, x3... that appear
%                   in the descriptor]
%
%   xref            Reference axis values.
%                    - If bin boundaries then there will be at least two
%                      values and all bin widths are greater than zero
%                      (i.e. the values are strictly monotonic increasing)
%                    - If bin centres, then they will be monotonic
%                      increasing, but there may be repeated values, which
%                      corresponds to two or more data points that have the
%                      same position along the axis.
%
%   tol             If the terminal bin widths from resolving infinities
%                   are less than fraction tolerance tol of the penultimate
%                   bin widths then the terminal bins are merged with the
%                   penultimate bins. Prevents very narrow bins being 
%                   created.
%
%
% Output:
% -------
%   xout            Bin boundaries for rebin array (row vector)
%               It is possible to end up with just two bin boundaries whose
%               values are the same 

if ~(isinf(xin(1)) || isinf(xin(end)))
    % All input values are finite
    if is_boundaries
        xout = xin;
    else
        xout = bin_boundaries (xin);    % there are at least two centres
    end
    
else
    % One or both end values are infinite
    %
    % Bin boundaries or centres:
    %   [x1, x2, x3,...xn]
    %       where -Inf <= x1 < x2 <...< xn <= Inf
    %
    % Guiding principles in resolving +/-infinity:
    %
    % - Inf (-Inf) if present define the value of the outermost bin
    %   boundaries, unless there is an explicit value (boundary or centre)
    %   in the description that is more extreme.
    %
    % - The finite values will always exist as bin boundaries
    %   (is_boundaries = true), or be used to generate a set of
    %   bin boundaries (is_boundaries = false).
    %
    % - Inf (-Inf) will be resolved into xhi (xlo) and then made the
    %   more extreme of xhi and x(n-1) (xlo and x2) as the defining
    %   outer boundary. This is true whether is_boundaries is true or
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
    %       to 9.5. If The data minimum was 10.5, then it would be set
    %       to 10, as this appeared in the bin centres list.
    
    % Parse input arguments
    narg = numel(varargin);
    if narg==1 || narg==2
        xref = varargin{1};
        if numel(xref)<1
            % A most basic check to catch serious misuse of xref
            error('HERBERT:rebin_boundaries_from_values:invalid_argument',...
                'Reference x values array cannot be empty');
        end
        if narg==2
            tol = varargin{2};
        else
            tol = 1e-10;    % default
        end
    elseif narg > 2
        error('HERBERT:rebin_boundaries_from_values:invalid_argument',...
            'Too many input arguments');
    else
        error('HERBERT:rebin_boundaries_from_values:invalid_argument',...
            ['Reference binning information required to resolve infinities ',...
            'is not given']);
    end
    
    xlo = xref(1);
    xhi = xref(end);
    
    if ~is_boundaries && ...
            (numel(xin) - isinf(xin(1)) - isinf(xin(end))) >= 2
        % Contains at least two finite bin centres so able to generate
        % bin boundaries.
        % These finite bin centres will have a non-zero separation (by
        % supposition - see input argument description), so
        % we are guaranteed to have at least one, non-zero width bin
        % at the conclusion of this block of code.
        xout = bin_boundaries (xin(1+isinf(xin(1)):end-isinf(xin(end))));
        if xin(1) == -Inf
            if xlo < xout(1)
                % Data lies outside bin boundaries, so add an extra bin
                % or, if inside tolerance, broaden the bin
                if (xout(1)-xlo)/(xout(2)-xout(1)) < tol
                    xout(1) = xlo;
                else
                    xout = [xlo, xout];
                end
            else
                % Limit of data greater than outer bin; truncate bin at the
                % data minimum or lowest finite value i.e. xin(2) - even
                % though this was given as a bin centre)
                xout(1) = min(xlo, xin(2));
            end
        end
        if xin(end) == Inf
            if xhi > xout(end)
                % Data lies outside bin boundaries, so add an extra bin
                % or, if inside tolerance, broaden the bin
                if (xhi-xout(end))/(xout(end)-xout(end-1)) < tol
                    xout(end) = xhi;
                else
                    xout = [xout, xhi];
                end
            else
                % Limit of data within outer bin; truncate bin at the
                % data maximum or highest finite value i.e. xin(end-1) -
                % even though this was given as a bin centre)
                xout(end) = max(xhi, xin(end-1));
            end
        end
        
    else
        % Bin boundaries, or bin centres with one or no finite value (and
        % so not possible to generate bin boundaries).
        % It is possible to have a single bin [xlo,xhi] at the end,
        % This will be valid if the data is point data and all points
        % have the same value of x == xlo.
        xout = xin(1+isinf(xin(1)):end-isinf(xin(end)));
        if xin(1) == -Inf
            if ~isempty(xout)
                if xlo < xout(1)
                    % Data lies outside bin boundaries, so add an extra bin
                    % or, if inside tolerance, broaden the bin. Note that
                    % there may not be two values in xout, so must check 
                    % if a bin exists
                    if numel(xout)>=2 && (xout(1)-xlo)/(xout(2)-xout(1)) < tol
                        xout(1) = xlo;
                    else
                        xout = [xlo, xout];
                    end
                else
                    % Limit of data greater than outer bin; truncate bin at
                    % the data minimum or lowest bin boundary
                    xout(1) = min(xlo, xout(1));
                end
            else
                xout = xlo;
            end
        end
        if xin(end) == Inf
            if xhi > xout(end)
                % Data lies outside bin boundaries, so add an extra bin
                % or, if inside tolerance, broaden the bin. Note that
                % there may not be two values in xout, so must check 
                % if a bin exists
                if numel(xout)>=2 && ...
                        (xhi-xout(end))/(xout(end)-xout(end-1)) < tol
                    xout(end) = xhi;
                else
                    xout = [xout, xhi];
                end
            else
                % Limit of data less than outer bin; truncate bin at
                % the data maximum or largest bin boundary
                xout(end) = max(xhi, xout(end));
            end
        end
        if numel(xout)==1
            % Make a bin of zero width.
            xout = [xout,xout];
        end
    end
    
end
