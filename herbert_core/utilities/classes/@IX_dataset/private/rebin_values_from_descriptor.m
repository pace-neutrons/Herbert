function xout = rebin_values_from_descriptor(xdescr, xref)
% Get new x values from a bin boundary descriptor
%
%   >> x_out = rebin_values_from_descriptor(xdescr, xref)
%   >> x_out = rebin_values_from_descriptor(xdescr, xref)
%
% Input:
% ------
%   xdescr      Binning description in one of the following forms:
%
%       is_descriptor==true
%       -------------------
%         [x1, dx1, x2]
%         [x1, dx1, x2, dx2, x3,...xn]
%               where -Inf <= x1 <= x2 <= x3...<= xn <= Inf, or
%                     (only x1 and xn can possibly be infinite)
%
%               and
%
%               dx +ve: equal bin sizes between corresponding limits
%               dx -ve: logarithmic bins between corresponding limits
%                      (note: if dx1<0 then x1>0, dx2<0 then x2>0 ...)
%               dx=0  : retain existing bins between corresponding limits
%
%
%       is_descriptor==false
%       --------------------
%       Descriptor defines bin boundaries:
%         [x1, x2, x3,...xn]        
%               where -Inf <= x1 <= x2 <=...<= xn <= Inf
%                     (only x1 and xn can possibly be infinite)
%
%   xref        Reference array of values. Assumed that it is monotonic 
%               increasing. Used where dx=0 in the descriptor
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
