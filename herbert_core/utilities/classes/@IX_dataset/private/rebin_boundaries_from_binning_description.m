function xout = rebin_boundaries_from_binning_description (xin,...
    is_descriptor, is_boundaries, varargin)
% Get new bin boundaries from binning description
%
% If binning description is resolved (i.e. no -Inf or +Inf, and no binning
% interval in a descriptor requires reference values to be retained):
%   >> xout = rebin_boundaries_from_binning_description ...
%                                     (xdescr, is_boundaries)
%
% General case:
%   >> xout = rebin_boundaries_from_binning_description ...
%                                     (xdescr, is_boundaries, xref, ishist)
%
% Input:
% ------
%   xdescr          Binning description in one of the following forms:
%
%       is_descriptor==true
%       -------------------
%         [x1, dx1, x2]
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
%                   boundaries. This is a statement about the finite values
%                   of x1, x2,... that appear in a binning description]
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


narg = numel(varargin);
if narg <= 2
    if is_descriptor
        xout = rebin_boundaries_from_descriptor (xin, is_boundaries, varargin{:});
    else
        xout = rebin_boundaries_from_values (xin, is_boundaries,...
            varargin{1:min(1,narg)});
    end
else
    error('HERBERT:rebin_boundaries_from_binning_description:invalid_argument',...
        'Too many input arguments');
end
