function xout = rebin_boundaries_from_descriptor (xdescr, is_boundaries,...
    varargin)
% Get new x values from a bin boundary descriptor
%
% If no retained input values and descriptor ranges all finite:
%   >> xout = rebin_boundaries_from_descriptor (xdescr, is_boundaries)
%   >> xout = rebin_boundaries_from_descriptor (xdescr, is_boundaries, tol)
%
% General case:
%   >> xout = rebin_boundaries_from_descriptor (xdescr, is_boundaries,...
%                                                       xref, ishist)
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
% Output:
% --------
%   xout            Bin boundaries for rebin array (row vector)
%               It is possible to end up with just two bin boundaries whose
%               values are the same (for example, descriptor is [5,0,Inf] 
%               and xref = [5,5,5] i.e. point data where all points have 
%               the same position along the axis). 
%
%
%               The special case of xdescr = [-Inf,0,Inf] means that the
%               output bin boundaries are the same as those defined by the 
%               reference axis values. This will be indicated by xout = []


% How the algorithm works
% -----------------------
% Overview:
%         [x1, dx1, x2, dx2, x3,...xn]
%               where -Inf <= x1 < x2 < x3...< xn <= Inf  (n >= 2)
%
% The descriptors define bin boundaries or bin centres according as
% is_boundaries. At the end they are converted to bin boundaries as the
% return argument xout is always bin boundaries.
%
% Inf and -Inf are resolved into the extremes of the data, that is 
% xhi = xref(end) and xlo = xref(1), regardless of whether xref is point
% or histogram data. That is because these are the true extremes of the
% data.
%
% Each descriptor block  [x(m), dx(m), x(m+1)] is filled independently in 
% turn. The functions that do this for the three cases dx>0, dx<0, dx=0 all
% return values starting at x(m) and excluding x(m+1), as the next block
% will provide the value x(m+1) as its starting value.
%
% Consider different cases:
%
% [x1, dx, x2]  (x1, x2 finite)
% ------------
%   - If dx=0, use reference data. Convert to bin centres or boundaries
%     as required by value of is_boundaries (here abbreviated to B) from
%     the reference values which are boundaries or not according to ishist
%     (here abbreviated to H).
%   - If (B & ~H) then get unique values of xref before converting to bin
%     boundaries (as point data may have several points at the same value
%     of x); if only one point, then use this as a boundary (i.e. treat the
%     data as having two identical bin boundaries, but recognise that for
%     a valid IX_dataset bin boundaries must be strictly monotonic
%     increasing).
%   - If (~B & H) then we may end up with just one bin centre. That is OK.
%
% *Note: by supposition xref will have to have at least two bin boundaries
%        (H) or one point value (~H) or an error will have been thrown 
%        before reaching this function. This is even though a valid
%        IX_dataset can have a single boundary or no point value. These
%        cases are no recognised as being valid as a reference x array here.
%
% [x(n-1), dx, Inf]  (x(n-1) finite)
% -------------
% If dx~=0:     Compute:
%   B   H     [x(n-1), dx, xhi]
%   B  ~H     [x(n-1), dx, xhi]
%  ~B   H     [x(n-1), dx, chi] chi is highest bin centre, which will
%                               satisfy chi < xhi
%                               Convert to bin boundaries at end; the final
%                               boundary will be greater than chi but the
%                               next highest less than chi and therefore
%                               less than xhi.
%                               Replace highest boundary with xhi.
%                           
%  ~B  ~H     [x(n-1), dx, xhi]   Convert to bin boundaries at end; the final
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
%  ~B  ~H     [x(n-1), 0, xhi]  Use bin boundaries computed from xref as
%                               reference points
%                               Convert to bin boundaries at end; the final
%                               boundary will be greater than xhi but the
%                               next highest less than xhi.
%                               Replace highest boundary with xhi
%
% [-Inf, dx, x1]  (x1 finite)
% --------------
% Treat this in the same way as [x(n-1), 0, Inf], except that:
% (1) when dx~=0 the computations are done with x1 as the starting point 
%   (i.e. the higher value) not x(n-1) (i.e. the lower value;
% (2) when dx=0 the lower boundary is handled in mirror image to how the
%   upper boundary was above.


del_array = xdescr(2:2:end);

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
end

if narg>3
    error('HERBERT:rebin_boundaries_from_descriptor:invalid_argument',...
        'Too many input arguments');
end

% Check that input arguments required to resolve infinities or steps of
% zero length are present if required
if (any(del_array==0) || isinf(xdescr(1)) || isinf(xdescr(end))) &&...
    narg <=1
    error('HERBERT:rebin_boundaries_from_descriptor:invalid_argument',...
        ['Reference binning information required to resolve descriptor ',...
        'is not given']);
end

% Catch case of [-Inf,del,Inf]
% Most straightforwardly handled as a special case
if numel(xdescr)==3 && isinf(xdescr(1)) && isinf(xdescr(3))
    del = xdescr(2);
    origin = 'c0';
    if del > 0
        [~, xout] = values_equal_steps (xref(1), del, xref(end), origin, tol);
    elseif del < 0
        [~, xout] = values_logarithmic_steps (xref(1), abs(del), xref(end),...
            origin, tol);
    else
        xout = [];
    end
    return
end

% Convert reference bin boundaries to centres, or vice versa, if required
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
        xref_tmp = bin_centres (xref);
        
    else
        xref_tmp = xref;
    end
end


% Loop over the descriptor intervals. On first pass accumulate the number
% of points in each interval. On the second pass assign the output array
% now that the total number of points is knownn, and then fill the output
% array.

nout_filled = false;
while true
    % Pre-assign x_out once the size has been calculated
    if nout_filled
        xout = zeros(1,nout);
    end
    
    % Loop over the intervals
    ntot = 0;	% total number of bin boundaries in output array so far
    ndescr = floor(numel(xdescr)/2);    % number of descriptor intervals
    for i = 1:ndescr
        % Generally, the origin for point generation is the lower interval
        % limit
        origin = 'x1';
        
        % Get the lower and upper limits of the descriptor interval, and
        % the step size.
        % In the case of intervals where one of the bounds is infinite
        % the limit is resolved as being the range of the data. Note that
        % if the descriptor defines centres but the data is histogram that
        % we use the extremal bin centres. This is because at the end the
        % set of bin centres is turned into boundaries; at that point the
        % extremal values will be reassigned to the true data extrema.
        
        if i==1 && isinf(xdescr(1)) 
            % Case that first descriptor starts with -Inf
            origin = 'x2';  % origin for point generation is upper limit
            if ~is_boundaries && ishist
                xlo = xref_tmp(1);
            else
                xlo = xref(1);
            end
        else
            xlo = xdescr(2*i-1);
        end
        
        del = xdescr(2*i);
        
        if i==ndescr && isinf(xdescr(end))
            % Case that last descriptor ends with Inf
            if ~is_boundaries && ishist
                xhi = xref_tmp(end);
            else
                xhi = xref(end);
            end
        else
            xhi = xdescr(2*i+1);
        end
        
        % Get the values (boundaries or centres; we convert to boundaries
        % at the end)
        if del > 0
            % Equally spaced bins
            np = values_equal_steps (xlo, del, xhi, origin, tol);
            if nout_filled
                [~, xout(ntot+1:ntot+np)] = values_equal_steps (...
                    xlo, del, xhi, origin, tol);
            end
            ntot = ntot + np;
            
        elseif del < 0
            % Logarithmic bins
            np = values_logarithmic_steps (xlo, abs(del), xhi, origin, tol);
            if nout_filled
                [~, xout(ntot+1:ntot+np)] = values_logarithmic_steps (...
                    xlo, abs(del), xhi, origin, tol);
            end
            ntot = ntot + np;
            
        else
            % Retain existing bins
            np = values_contained_points (xlo, xref_tmp, xhi, tol);
            if nout_filled
                [~, xout(ntot+1:ntot+np)] = values_contained_points (...
                    xlo, xref_tmp, xhi, tol);
            end
            ntot = ntot + np;
        end
        
    end
    
    % Completed the loop over all ranges
    % - If first pass, set nout and pass through again
    % - If second pass, fill final point
    % There are circumstances where a different behaviour is followed on
    % the first pass.
    %
    % Detailed explanation:
    %
    % In the case of the final interval being an explicitly finite one,
    % [xlo,del,xhi], this will contribute at least one point (xlo) to
    % xout, and the last point should be set to xhi. We end up with
    % at least two points in xout, and all points are strictly
    % monotonic increasing.
    %
    % However, if one of the descriptor limits is -Inf or Inf it is
    % possible to have no points from an interval because in these
    % cases xlo >= xhi can occur if:
    % (1) the interval is [-Inf,del,xhi] and the lower limit of the
    %     data range is greater or equal to xhi;
    % (2) the interval is [xlo,del,Inf] and the data range is less
    %     than or equal to xlo.
    % (Note, we consider the case [-Inf,del,Inf] separately elsewhere)
    %
    % Consider now the various cases where the final interval in the
    % descriptor is not an explicitly finite one:
    %
    % - If the descriptor is only one semi-infinite interval, then
    %   xlo > xhi is invalid. If xlo=xhi, this is valid if point data,
    %   all points have same x (i.e. all x = xlo = xhi).
    %
    % - If the descriptor is just both intervals: [-Inf,d1,x0,d2,Inf]
    %     - There could be no points if all data has x = x0. This will
    %       be valid under the same circumstances as above for one
    %       interval.
    %     - If the data has a non-zero range, there will be one point
    %       (x0 <= minimum of data, or x0 >= maximum of data), or two
    %       points (x0 lies within the range of the data). We will get
    %       the correct interval(s) in all cases if the last point of
    %       xout is set to max(xlo,xhi) for the second interval.
    %
    % Note that max(xlo,xhi) will also correctly give xhi for an
    % explicitly finite interval. The overall set of possibilities is
    % covered
    
    if ntot>0
        % At least one point already determined in xout; there is
        % necessarily an extra point to add at the end
        if ~nout_filled
            nout = ntot + 1;
            nout_filled=true;
        else
            xout(nout) = max(xlo,xhi);
            break
        end
    else
        % Case of no valid rebin range unless point data and all points
        % have the same x value
        if ~ishist && xref(1)==xref(end)
            xout = [xref(1),xref(end)];
            return
        else
            error('HERBERT:rebin_boundaries_from_descriptor:invalid_argument',...
            ['Resolving -Inf or +Inf in a binning descriptor results in ',...
            'upper limit < lower limit']);
        end
    end
end

% At this point xout will be an array of at least two points and xout is
% monotonically increasing.
%
% If the descriptor defined bin centres, compute the bin boundaries and
% and then in the case of an original descriptor limit being infinite,
% replace the corresponding outer value by the input data range
if ~is_boundaries
    xout = bin_boundaries (xout);
    if isinf(xdescr(1))
        xout(1) = xref(1);
    end
    if isinf(xdescr(end))
        xout(end) = xref(end);
    end
end
