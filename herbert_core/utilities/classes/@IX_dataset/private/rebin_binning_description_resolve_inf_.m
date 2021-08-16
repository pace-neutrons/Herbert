function xout=rebin_binning_description_resolve_inf_...
    (xin, is_descriptor, is_boundaries, xref)
% Resolve -Inf and/or Inf in bin boundaries or rebin descriptor
%
%   >> xb]=rebin_boundaries_description_resolve_inf...
%           (xbounds, is_descriptor, xlo, xhi)
%
% Input:
% ------
%   xbounds         Bin boundaries or rebin descriptor
%   is_descriptor   True if rebin descriptor, false if bin boundaries
%   xlo             Lower limit of data
%                  (histogram data: lowest bin boundary; point data: lowest point position)
%   xhi             Upper limit of data
%                  (histogram data: highest bin boundary; point data: highest point position)
%
% Output:
% -------
%   xb              Bin boundaries or rebin descriptor with infinities resolved
%                   - if is a descriptor and [-Inf,0,Inf] i.e. bins unchanged, then
%                       xb=[]
%                   - There are some circumstance when there are no bins, when
%                       xb is scalar (convention for histogram data with no data)
%
%                    e.g.  descriptor:     xbounds=[-Inf,5,10], [xlo,xhi]=[100,200]
%                          bin boundaries: xbounds=[-Inf,10], [xlo,xhi]=[100,200]
%                   then the output is a scalar, to be interpreted as no bins.
%                   Note: this circumstance can arise if only one of the outer limits
%                   is infinite, and there is just one bin (bin boundaries) or just one
%                   descriptor range (rebin descriptor). The scalar value of xb is the
%                   finite of the two limits.
%
% Assumes valid input i.e. xbounds is a valid descriptor or set of bin boundaries, and
% both xlo and xhi are finite with xlo<xhi.

xlo = xref(1);
xhi = xref(end);

% Catch the case that 
xout=xin;
if xout(1)==-Inf || xout(end)==Inf
    if is_descriptor
        % Binning descriptor
        if numel(xin)==3 && isinf(xin(1)) && isinf(xin(3))
            % Catch case of form [-Inf,dx,Inf]:
            if xin(2)==0
                xout=[];
            elseif xin>0
                xout=[low_limit(xlo,0,xin(2)),xin(2),high_limit(xhi,0,xin(2))];
            else
                if xlo>0
                    xout=[low_limit(xlo,1,xin(2)),xin(2),high_limit(xhi,1,xin(2))];
                else
                    error(['If lower limit is less than or equal to zero, ',...
                        'the rebin descriptor [-Inf,dx,Inf] with dx<0 is invalid']);
                end
            end
        else
            % Other cases
            if xout(1)==-Inf
                if xout(3)>xlo
                    [xout(1),ok]=low_limit(xlo,xout(3),xout(2));
                    if ~ok
                        error(['Unable to resolve rebin descriptor beginning ',...
                            '[-Inf,dx,...] - check dx and lower limit of data'])
                    end
                else
                    xout=xout(3:end);
                    % Convention for empty histogram data is single x value
                    if numel(xout)<3
                        return
                    end 
                end
            end
            if xout(end)==Inf
                if xout(end-2)<xhi
                    [xout(end),ok]=high_limit(xhi,xout(end-2),xout(end-1));
                    if ~ok
                        error(['Unable to resolve rebin descriptor ending ',...
                            '[...dx,Inf] - check dx and upper limit of data'])
                    end
                else
                    xout=xout(1:end-2);
                    if numel(xout)<3
                        % convention for empty histogram data is single x value
                        return
                    end 
                end
            end
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
        %   (values_are_boundaries = true), or be used to generate a set of
        %   bin boundaries (values_are_boundaries = false).
        %
        % - Inf (-Inf) will be resolved into xhi (xlo) and then made the
        %   more extreme of xhi and x(n-1) (xlo and x2) as the defining
        %   outer boundary. This is true for values_are_boundaries true or
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
        %       xin = [-Inf,10,12,14] and values_are_boundaries = false.
        %       Then bin boundaries are constructed at [9,11,13,15]. Now
        %       suppose the data has minimum of 9.5. We want the rebinning
        %       to extend no lower than the data unless an explicit finite
        %       value has been given. That is what the first guiding
        %       principle states. Therefore the lowest bin boundary is set
        %       to 9.5. If The data mionimum was 10.5, then it would be set
        %       to 10, as this appeared in the bin centres list.

         
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
end

%----------------------------------------------------------------------------------
function xlo = low_limit(x, xref, dx)
% Construct a lower limit from a bin descriptor, avoiding rounding errors
%
%   >> xlo = low_limit(x, xref, dx)
%
% Input:
% ------
%   x       Lowest value for which must have xout >= x
%   xref    Reference value from which to construct bins with width dx
%   dx      Bin step
%            dx +ve: equal bin sizes 
%            dx -ve: logarithmic bins between corresponding limits
%   xlo     Value such that 


if dx==0
    xlo=x;
elseif dx>0
    xlo=xref+dx*floor((x-xref)/dx);
    if xlo>x
        xlo=xlo-dx;
    elseif xlo<x && xlo+dx<=x
        xlo=xlo+dx;
    end
elseif dx<0 && x>0 && xref>0
    n=floor((log(xref/x)/log(1+abs(dx))));
    xlo=exp(log(xref)-n*log(1+abs(dx)));
    if xlo>x
        xlo=xlo/(1+abs(dx));
    elseif xlo<x && xlo*(1+abs(dx))<=x
        xlo=xlo*(1+abs(dx));
    end
else
    error('IX_dataset:invalid_argument','Invalid input')
end

%----------------------------------------------------------------------------------
function [xhi,ok]=high_limit(x,xref,dx)
% Carefully construct an upper limit from a bin descriptor to avoid rounding errors
%
%   >> xout=high_limit(x,xref,delta)
%
%   x       Highest value for which must have xout>=x
%   xref    Reference value from which to construct bins with width dx
%   dx      Bin step
%            dx +ve: equal bin sizes 
%            dx -ve: logarithmic bins between corresponding limits
%   xlo     Value such that 

ok=true;
if dx==0
    xhi=x;
elseif dx>0
    xhi=xref+dx*ceil((x-xref)/dx);
    if xhi<x
        xhi=xhi+dx;
    elseif xhi>x && xhi-dx>=x
        xhi=xhi-dx;
    end
elseif dx<0 && x>0 && xref>0
    n=ceil((log(x/xref)/log(1+abs(dx))));
    xhi=exp(log(xref)+n*log(1+abs(dx)));
    if xhi<x
        xhi=xhi*(1+abs(dx));
    elseif xhi>x && xhi/(1+abs(dx))>=x
        xhi=xhi/(1+abs(dx));
    end
else
    xhi=[];
    ok=false;
    if nargout==1, error('IX_dataset:invalid_argument','Invalid input'); end
end
