function xout = rebin_boundaries (xdescr, is_descriptor, is_boundaries, varargin)
% Get new bin boundaries from binning description
%
% If binning description is resolved (i.e. no -Inf or +Inf, and no binning
% interval in a descriptor requires reference values to be retained):
%   >> xout = rebin_boundaries (xdescr, is_descriptor, is_boundaries)
%
%   >> xout = rebin_boundaries (xdescr, is_descriptor, is_boundaries, tol)
%
% General case:
%   >> xout = rebin_boundaries (xdescr, is_descriptor, is_boundaries,...
%                                                       xref, ishist)
%   >> xout = rebin_boundaries (xdescr, is_descriptor, is_boundaries,...
%                                                       xref, ishist, tol)
%
% Input:
% ------
%   xdescr          Binning description in one of the following forms:
%
%       is_descriptor==true
%       -------------------
%         [x1, dx1, x2, dx2, x3,...xn]
%               where -Inf <= x1 < x2 < x3...< xn <= Inf  (n >= 2), and
%
%               dx +ve: equal bin sizes between corresponding limits
%               dx -ve: logarithmic bins between corresponding limits
%                      (note: if dx1<0 then x1>0, dx2<0 then x2>0 ...)
%               dx=0  : retain existing bins between corresponding limits
%
%       is_descriptor==false
%       --------------------
%       Binning description defines actual bin boundaries or centres:
%         [x1, x2, x3,...xn]
%               where -Inf <= x1 < x2 <...< xn <= Inf   (n >=2)
%
%       The special case of n=2, finite x1, x2 and x1=x2 is permitted (a
%       bin of zero width, which will be valid if point data, all points
%       with x=x1)
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
%                    - If bin boundaries then there must be at least two
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


% Parse input arguments
narg = numel(varargin);
if narg==1 || narg==3
    tol = varargin{end};
else
    tol = 1e-10;    % default
end

if narg==2 || narg==3
    xref_present = true;
    xref = varargin{1};
    ishist = varargin{2};
    if numel(xref)<1 || (ishist && numel(xref)<2)
        % Check on number of elements of xref for both point and histogram
        error('HERBERT:rebin_boundaries:invalid_argument',...
            ['Reference x-array must have at least one element (point data) or\n',...
            'two elements (histogram data)']);
    end
else
    xref_present = false;
end

if narg>3
    error('HERBERT:rebin_boundaries:invalid_argument',...
        'Too many input arguments');
end

% Generate bin boundaries if input is a binning descriptor, and resolve any
% terminal infinities in the bin boundaries
if is_descriptor
    % Values are generated by a descriptor
    % Check that input arguments required to resolve infinities or steps of
    % zero length are present if required
    del_array = xdescr(2:2:end);
    if (any(del_array==0) || isinf(xdescr(1)) || isinf(xdescr(end))) &&...
            ~xref_present
        error('HERBERT:rebin_boundaries_from_descriptor:invalid_argument',...
            ['Reference binning information required to resolve descriptor ',...
            'is not given']);
    end
    
    % Resolve descriptors and then any infinities
    if xref_present
        xvals = rebin_boundaries_from_descriptor...
            (xdescr, is_boundaries, xref, ishist, tol);
        xout = rebin_boundaries_from_values (xvals, is_boundaries, xref, tol);
    else
        xvals = rebin_boundaries_from_descriptor (xdescr, is_boundaries, tol);
        xout = rebin_boundaries_from_values (xvals, is_boundaries, tol);
    end
    
else
    % Boundaries to be generated from values
    if xref_present
        xout = rebin_boundaries_from_values (xdescr, is_boundaries, xref, tol);
    else
        xout = rebin_boundaries_from_values (xdescr, is_boundaries, tol);
    end
end
