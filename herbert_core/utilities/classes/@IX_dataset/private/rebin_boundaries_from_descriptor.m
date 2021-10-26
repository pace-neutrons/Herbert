function xout = rebin_boundaries_from_descriptor (xdescr, is_boundaries,...
    varargin)
% Get new x values from a bin boundary descriptor
%
% If no retained input values and descriptor ranges are all finite:
%   >> xout = rebin_boundaries_from_descriptor (xdescr, is_boundaries)
%
%   >> xout = rebin_boundaries_from_descriptor (xdescr, is_boundaries, tol)
%
% General case:
%   >> xout = rebin_boundaries_from_descriptor (xdescr, is_boundaries,...
%                                                       xref, ishist)
%
%   >> xout = rebin_boundaries_from_descriptor (xdescr, is_boundaries,...
%                                                       xref, ishist, tol)
%
% Input:
% ------
%   xdescr          Binning descriptor with the following form:
%
%         [x1, dx1, x2, dx2, x3,...xn]
%               where -Inf <= x1 < x2 < x3...< xn <= Inf  (n >= 2), and
%
%               dx +ve: equal bin sizes between corresponding limits
%               dx -ve: logarithmic bins between corresponding limits
%                      (note: if dx1<0 then x1>0, dx2<0 then x2>0 ...)
%               dx=0  : retain existing bins between corresponding limits
%
%   is_boundaries   Logical flag:
%                    - true if xdescr defines bin boundaries
%                    - false if xdescr defines bin centres
%                  [Note that -Inf and Inf always end up defining bin
%                   boundaries. The value of is_boundaries is a statement
%                   about the finite values of [x1,] x2, x3... that appear
%                   in the descriptor]
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
%   ishist          Logical flag:
%                    - true if xref defines bin boundaries
%                    - false if xref defines bin centres
%
%   tol             Tolerance: smallest difference between values and end
%                   points as a fraction of the penultimate spacings
%                   at each limit. Prevents overly small extremal bins from
%                   being created.
%                       tol >= 0;    default = 1e-10
%
% Output:
% --------
%   xout            Bin boundaries for rebin array (row vector)
%               It is possible to end up with just two bin boundaries whose
%               values are the same (for example, descriptor is [5,0,Inf]
%               and xref = [5,5,5] i.e. point data where all points have
%               the same position along the axis).


% How the algorithm works
% -----------------------
% Overview:
%         [x1, dx1, x2, dx2, x3,...xn]
%               where -Inf <= x1 < x2 < x3...< xn <= Inf  (n >= 2)
%
% The descriptors define bin boundaries or bin centres according as
% is_boundaries. At the end generated bin centres are converted to bin
% boundaries as the return argument xout is always bin boundaries.
%
% Inf and -Inf are resolved into the extremes of the data, that is
% xhi = xref(end) and xlo = xref(1), regardless of whether xref is point
% or histogram data. That is because these are the true extremes of the
% data.
%
% Each descriptor block  [x(m), dx(m), x(m+1)] is filled independently in
% turn. The functions that do this for the three cases dx>0, dx<0, dx=0 all
% return values starting at x(m) and excluding x(m+1), as the next block
% will provide the value x(m+1) as its starting value. The exceptions are
% the first and last descriptor blocks:
%
% - if generating boundaries, then the first block will include x(1) (if it
%   generates any points at all: if x(1) and/or x(2) is resolved from
%   -Inf &/or Inf then we could have x(1) >= x(2) in which case there will
%   be no points generated at all)
%
% - if generating bin centres, then the last block will *not* include x(n)
%
%
%
% Consider different cases:
%
% [x(m), dx, x(m+1)]  (x(m), x(m+1) finite)
% -------------------
%   - If dx=0, use reference data. Convert to bin centres or boundaries
%     as required by value of is_boundaries (here abbreviated to B) from
%     the reference values which are boundaries or not according to ishist
%     (here abbreviated to H).
%
%   - If (B & ~H) then get unique values of xref before converting to bin
%     boundaries (as point data may have several points at the same value
%     of x); if only one point, then use this as a boundary (i.e. treat the
%     data as having two identical bin boundaries, but recognise that for
%     a valid IX_dataset bin boundaries must be strictly monotonic
%     increasing).
%
%   - If (~B & H) then we may end up with just one bin centre. That is OK.
%
% *Note: by supposition xref will have to have at least two bin boundaries
%        (H) or one point value (~H) or an error will have been thrown
%        before reaching this function. This is even though a valid
%        IX_dataset can have a single boundary or no point value. These
%        cases are not recognised as being valid for providing a reference
%        x array for bin boundary generation.
%
% [x(n-1), dx, Inf]  (x(n-1) finite)
% ------------------
% If dx~=0:     Compute:
%   B   H     [x(n-1), dx, xhi]
%   B  ~H     [x(n-1), dx, xhi]
%  ~B   H     [x(n-1), dx, xhi] Convert to bin boundaries at end
%                               Then replace final boundary with xhi, or
%                               append xhi if
%
%  ~B  ~H     [x(n-1), dx, xhi) Convert to bin boundaries at end; the final
%                               boundary will be greater than xhi but the
%                               next highest less than xhi.
%                               Replace highest boundary with xhi
%
% *Note: in the case of ~B, we perform the generation of bin boundaries
% once all descriptors have been computed and concatenated. This is
% because the final boundaries are dependent on the entire set of bin
% centres.
%
% If dx=0:
%   B   H     [x(n-1), 0, xhi]  Use xref for reference points
%
%   B  ~H     [x(n-1), 0, xhi]  Use bin boundaries computed from xref as
%                               reference points
%
%  ~B   H     [x(n-1), 0, chi]  Use bin centres computed from xref as
%                               reference points.
%                               chi is highest bin centre, which will
%                               satisfy chi < xhi
%                               Convert to bin boundaries at end; the final
%                               boundary will be greater than chi but the
%                               next highest less than chi and therefore
%                               less than xhi.
%                               Replace highest boundary with xhi.
%
%  ~B  ~H     [x(n-1), 0, xhi]  Use xref for reference points
%                               Convert to bin boundaries at end; the final
%                               boundary will be greater than xhi but the
%                               next highest less than xhi.
%                               Replace highest boundary with xhi
%
% [-Inf, dx, x2]  (x2 finite)
% --------------
% Treat this in the same way as [x(n-1), 0, Inf], except that:
% (1) when dx~=0 the computations are done with x2 as the starting point
%   (i.e. the higher value);
% (2) when dx=0 the lower boundary is handled in mirror image to how the
%   upper boundary was above.


% Parse input arguments
narg = numel(varargin);
if narg==1 || narg==3
    tol = varargin{end};
else
    tol = 1e-10;    % default
end

if narg==2 || narg==3
    xref = varargin{1};
    ishist = varargin{2};
elseif narg>3
    error('HERBERT:rebin_boundaries_from_descriptor:invalid_argument',...
        'Too many input arguments');
end


% Convert reference bin boundaries to centres, or vice versa, if required
del_array = xdescr(2:2:end);
if any(del_array==0)
    if is_boundaries && ~ishist
        % Descriptor of bin boundaries, reference data is centres or points
        % but need to fill an interval with reference bin boundaries
        %
        % If there is only one unique point value; retain this as a single
        % value as cannot have a final output set of bin boundaries where
        % there are two equal bin boundaries
        if numel(xref)==1
            xref_tmp = xref;
        else
            xref_unique = xref(diff(xref)~=0);
            if numel(xref_unique)==1
                xref_tmp = xref_unique;
            else
                xref_tmp = bin_boundaries (xref_unique);
            end
        end
        
    elseif ~is_boundaries && ishist
        % Descriptor of bin centres, reference data is bin boundaries but
        % need to fill up an interval with reference centres
        xref_tmp = bin_centres (xref);  % OK as at least two elements of xref
        
    else
        % Use xref unchanged
        xref_tmp = xref;
    end
end


% Loop over the descriptor intervals. On first pass accumulate the number
% of points in each interval. On the second pass assign the output array
% now that the total number of points is known, and then fill the output
% array.

nout_filled = false;
xout_allocated = false;

while ~xout_allocated
    % Pre-assign x_out once the size has been calculated
    if nout_filled
        xout = zeros(1,nout);
        xout_allocated = true;
    end
    
    % Loop over the intervals
    ntot = 0;	% total number of values in output array so far
    ndescr = floor(numel(xdescr)/2);    % number of descriptor intervals
    for i = 1:ndescr
        % Get the lower and upper limits of the descriptor interval, and
        % the step size.
        % In the case of intervals where one or both bounds is infinite
        % the limits are resolved as being the range of the data. These are
        % the extremal bin boundaries in the case of histogram data, or the
        % extremal x coordinates in the case of point data, regardless of
        % whether the descriptor is of bin boundaries or bin centres.
        
        % Get xlo, del, xhi for descriptor interval [xlo,del,xhi]
        first_and_Inf = (i==1 && isinf(xdescr(1)));
        if first_and_Inf
            % Case that first descriptor starts with -Inf
            xlo = xref(1);
        else
            xlo = xdescr(2*i-1);
        end
        
        del = xdescr(2*i);
        
        last_and_Inf = (i==ndescr && isinf(xdescr(end)));
        if last_and_Inf
            % Case that last descriptor ends with Inf
            xhi = xref(end);
        else
            xhi = xdescr(2*i+1);
        end
        
        % Get origin for values
        if first_and_Inf && last_and_Inf
            if is_boundaries
                type = '(c0)';
            else
                type = '(v0)';
            end
        elseif first_and_Inf
            type = '(x2)';
        else
            type = '(x1)';
        end
        
        % Increment ntot to hold lower limit of the interval
        if xout_allocated
            if first_and_Inf
                xout(ntot+1) = -Inf;
            else
                xout(ntot+1) = xlo;
            end
        end
        ntot = ntot + 1;
        
        % Get the values (boundaries or centres; we convert to boundaries
        % at the end)
        if del > 0
            % Equally spaced bins
            np = values_equal_steps (xlo, del, xhi, type, tol);
            if xout_allocated
                [~, xout(ntot+1:ntot+np)] = values_equal_steps (...
                    xlo, del, xhi, type, tol);
            end
            ntot = ntot + np;
            
        elseif del < 0
            % Logarithmic bins
            np = values_logarithmic_steps (xlo, abs(del), xhi, type, tol);
            if xout_allocated
                [~, xout(ntot+1:ntot+np)] = values_logarithmic_steps (...
                    xlo, abs(del), xhi, type, tol);
            end
            ntot = ntot + np;
            
        else
            % Retain existing bins
            np = values_contained_points (xlo, xref_tmp, xhi, type([1,4]), tol);
            if xout_allocated
                [~, xout(ntot+1:ntot+np)] = values_contained_points (...
                    xlo, xref_tmp, xhi, type([1,4]), tol);
            end
            ntot = ntot + np;
        end
        
        % Increment ntot to hold upper limit of the final interval
        if i==ndescr
            if xout_allocated
                if isinf(xdescr(end))
                    xout(ntot+1) = Inf;
                else
                    xout(ntot+1) = xhi;
                end
            end
            ntot = ntot + 1;
        end
        
    end
    
    if ~nout_filled
        % Store the size of the output array
        nout = ntot;
        nout_filled = true;
    end
    
end
