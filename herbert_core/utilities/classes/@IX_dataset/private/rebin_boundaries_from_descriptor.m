function xout = rebin_boundaries_from_descriptor (xdescr, is_boundaries,...
    xref, ishist)
% Get new x values from a bin boundary descriptor
%
% If no retained input values and descriptor ranges all finite:
%   >> x_out = rebin_boundaries_from_descriptor (xdescr)
%
% General case:
%   >> x_out = rebin_boundaries_from_descriptor (xdescr, is_boundaries,...
%                                                           xref, ishist)
%
% Input:
% ------
%   xdescr      Binning descriptor with the following form:
%
%         [x1, dx1, x2]
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
%                   boundaries. This is a statement about the finite values
%                   of x1, x2,... that appear in the descriptor]
%
%   xref        Reference array of values. Assumed that it is strictly
%               monotonic increasing (i.e. all(diff(xref)>0). Used where
%               dx=0 in the descriptor.
%
%   ishist      True if xref contains bin boundaries, false if contains
%               bin centres
%
% Output:
% --------
%   x_out       Bin boundaries for rebin array (row vector)


nout_filled = false;

while true
    % Pre-assign x_out if the size has been calculated
    if nout_filled
        xout = zeros(1,nout);
    end
    
    % For each range, accumulate the values xlo, (xlo+dx), (xlo+2*dx),...
    % (xlo+n*dx) < xhi to the output array
    
    ntot = 0;	% total number of bin boundaries in output array so far
    for i = 1:floor(numel(xdescr)/2)
        xlo = xdescr(2*i-1);
        del = xdescr(2*i);
        xhi = xdescr(2*i+1);
        
        if del > 0
            % Equally spaced bins
            n = floor((xhi-xlo)/del);
            if (xlo+n*del >= xhi), n=n-1; end   % remove xhi, and any rounding problem
            if nout_filled
                xout(ntot+1) = xlo;
                if n > 1
                    xout(ntot+2:ntot+n+1) = xlo + del*(1:n);
                end
            end
            ntot = ntot + (n+1);
            
        elseif del < 0
            % Logarithmic bins
            logmult = log(1+abs(del));
            n = floor(log(xhi/xlo)/logmult);
            if (xlo*exp(n*logmult) >= xhi), n=n-1; end  % remove xhi
            if nout_filled
                xout(ntot+1) = xlo;
                if n > 1
                    xout(ntot+2:ntot+n+1) = xlo*exp((1:n)*logmult);
                end
            end
            ntot = ntot + (n+1);
            
        else
            % Retain existing bins
            % Get lower and upper indicies of input array of bin boundaries
            % such that xlo < x_in(imin) <= x_in(imax) < xhi:
            imin = lower_index(xref, xlo);
            imax = upper_index(xref, xhi);
            if imin <= numel(xref) && imax >= 1
                if (xref(imin)==xlo), imin = imin + 1; end
                if (xref(imax)==xhi), imax = imax - 1; end
                n = imax - imin + 2;	% n is the number of extra bin boundaries that will be added (including XHI)
            else
                n = 1;
            end
            if nout_filled
                xout(ntot+1) = xlo;
                if n > 1
                    xout(ntot+2:ntot+n) = xref(imin:imax);
                end
            end
            ntot = ntot + n;
        end
    end
    
    % Completed loop over all ranges
    if nout_filled
        % If second pass, fill output x array and return
        xout(ntot+1) = xhi;
        break
    else
        % If first pass, set n_out and pass through again
        nout = ntot + 1;
        nout_filled=true;
    end
end
