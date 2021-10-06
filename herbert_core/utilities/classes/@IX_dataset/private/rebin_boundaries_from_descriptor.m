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
% will provide the value x(m+1) as its starting value. At the end of the 
% loop over all blocks, x(m+1) will be appended to complete the set of bin
% boundaries.
%
% Consider different cases:
%
% [x(m), dx, x(m+1)]  (x(m), x(m+1) finite)
% -------------------
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
%        cases are not recognised as being valid for providing a reference
%        x array here.
%
% [x(n-1), dx, Inf]  (x(n-1) finite)
% ------------------
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
%  ~B  ~H     [x(n-1), dx, xhi] Convert to bin boundaries at end; the final
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
% [-Inf, dx, x2]  (x2 finite)
% --------------
% Treat this in the same way as [x(n-1), 0, Inf], except that:
% (1) when dx~=0 the computations are done with x2 as the starting point 
%   (i.e. the higher value);
% (2) when dx=0 the lower boundary is handled in mirror image to how the
%   upper boundary was above.
%
% [-Inf, dx, Inf]  
% ---------------
% This is most straightforwardly handled by considering as a special case.
% We do not need to handle the cases of is_boundaries true and false
% separately, as we create the bin boundaries directly, with the bin 
% centres having origin at x=0 (linear bins) or x=1 (logarithmic bins).


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
    if numel(xref)<1 || (ishist && numel(xref)<2)
        % Check on number of elements of xref for both point and histogram
        error('HERBERT:rebin_boundaries_from_descriptor:invalid_argument',...
            ['''ref'' must have at least one element (point data) or\n',...
            'two elements (histogram data)']);
    end
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

% % Catch case of [-Inf,del,Inf]
% % Most straightforwardly handled as a special case
% if numel(xdescr)==3 && isinf(xdescr(1)) && isinf(xdescr(3))
%     del = xdescr(2);
%     origin = 'c0';
%     if del > 0
%         [~, xout] = values_equal_steps (xref(1), del, xref(end), origin, tol);
%     elseif del < 0
%         [~, xout] = values_logarithmic_steps (xref(1), abs(del), xref(end),...
%             origin, tol);
%     else
%         xout = [];
%     end
%     return
% end

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
% now that the total number of points is known, and then fill the output
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
        % Get the lower and upper limits of the descriptor interval, and
        % the step size.
        % In the case of intervals where one of the bounds is infinite
        % the limit is resolved as being the range of the data. Note that
        % if the descriptor defines centres but the data is histogram that
        % we use the extremal bin centres. This is because at the end the
        % set of bin centres is turned into boundaries; at that point the
        % extremal values will be reassigned to the true data extrema.
        
        first_and_negInf = i==1 && isinf(xdescr(1));
        if first_and_negInf
            % Case that first descriptor starts with -Inf
            if ~is_boundaries && ishist
                xlo = (xref(1) + xref(2))/2;    % use bin centre
            else
                xlo = xref(1);
            end
        else
            xlo = xdescr(2*i-1);
        end
        
        del = xdescr(2*i);
        
        last_and_posInf = (i==ndescr && isinf(xdescr(end)));
        if last_and_posInf
            % Case that last descriptor ends with Inf
            if ~is_boundaries && ishist
                xhi = (xref(end-1) + xref(end))/2;  % use bin centre
            else
                xhi = xref(end);
            end
        else
            xhi = xdescr(2*i+1);
        end
        
        if first_and_negInf && last_and_posInf
            origin = 'c0';
        elseif first_and_negInf
            origin = 'x2';
        else
            origin = 'x1';
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
    % - If first pass, set nout and then pass through the loop again to
    %   pre-assign xout and accumulate x values from each descriptor
    %   interval
    % - If second pass, accumulate the fill final point in the x array if 
    %   there is at least one interval, or create a bin of width zero if
    %   there is not.
    %
    % Explanation in more detail:
    %
    % If a descriptor interval has xlo < xhi then it will generate at least
    % two points: xlo and xhi, the latter coming either because there is a
    % following interval that will generate it as its first point, or
    % because the interval is the last one and so xhi will be accumulated
    % as the final point. (Recall that each descriptor generates points
    % in the semi open interval [xlo,xhi) i.e. excludes xhi itself).
    %
    % Firstly, consider the case that at least one point has been
    % generated by descriptor intervals. It follows there will need to be a
    % last point accumulated from the final interval. This is because 
    % either:
    % - the final interval itself has xlo < xhi and so generates x values,
    %   with xhi needed to be added at the end; or
    % - if xlo >= xhi for the final interval, then the previous interval
    % must have generated points (by supposition we have at least one point
    % generated, and it cannot have come from the final interval).It is
    % expected that the final point to be added is xhi, which is in fact
    % xlo for the final interval.
    % The final point is correctly computed in both cases by max(xlo,xhi)
    %
    % Now consider the case where no points have been generated. Because 
    % any explicitly finite interval [xlo,dx,xhi] must have xlo,xhi by
    % supposition, this can only be because the full descriptor has one of
    % the forms:
    % - [-Inf, dx, Inf] with xlo=xhi
    % - [-Inf, dx, xhi] with xlo=xhi
    % - [ xlo, dx, Inf] with xlo=xhi
    % - [-Inf, dx, x1, dx', Inf] with xlo=x1=xhi.
    % In the last case, if xlo>x1 or xhi<x1 then one of the two descriptor
    % intervals will have non-zero interval length and so will have
    % generated one or more x-values.
    % The situation of no points therefore only arises if all data points
    % have the same value of x. This is valid in the case of point data,
    % and we set the output bin to be [xlo,xhi] (here xlo=xhi of course).
    
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
        % have the same x value: set single bin width zero, and return
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
% strictly monotonically increasing.
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
