function [sout, eout] = integrate_points (x, s, e, idim, xout, distr)
% Integrate point data along one dimension of signal and error arrays
%
% Integral in a set of continuous intervals defined by xout:
%
%   >> [sout, eout] = integrate_points (x, s, e, idim, xout)
%
% If the signal and error per unit length is wanted: set distr==true in:
%
%   >> [sout, eout] = integrate_points (x, s, e, idim, xout, distr)
%
%
% Input:
% ------
%   x       Point positions along the axis to be integrated (row or column
%          vector).
%           There must be at least two points.
%           It is assumed that the values of x are strictly monotonic
%          increasing i.e. all bins have width greater than zero.
%
%   s       Signal array. The extent along dimension idim must match the
%          number of points i.e. numel(x).
%
%   e       Standard deviations on the values in the signal array.
%          The sizes of the signal and error arrays must be the same
%
%   idim    Dimension of signal and error arrays to be rebinned (scalar).
%          Assumes idim >= 1.
%
%   xout    Output integration axis bin boundaries (row or column vector).
%           There must be at least two bin boundaries i.e. at least one bin.
%           It is assumed that the values of xout are strictly monotonic
%          increasing i.e. all bins have width greater than zero.
%           The integrated signal and standard deviation in the ith bin
%          i.e. from xout(i) to xout(i+1) are placed in the output arrays
%          at position i i.e. sout(i) and eout(i).
%
% Optional argument:
%   distr   Logical flag: false if want integral, true if want average
%          (i.e. distribution).
%           Default: false (i.e. integrals are returned)
%
% Output:
% -------
%   sout    Integrated signal array. The size of the array is the same as
%          the input array except for dimension number idim, which has 
%          extent equal to the number of output bins i.e. (numel(xout)-1).
%
%   eout    Standard deviations on integrated signal. Has the same size as
%          the rebinned signal array, sout.
% 
% The method to calculate the standard deviations on the integrated data
% assures consistency of splitting those on the original points such that
% the bins can recombined to yield the same standard deviations as
% integrating the whole bins.

% The rebinning is performed by permuting and reshaping the signal and 
% error arrays to size = [n,mx] where mx is the number of bins along the
% axis to be rebinned, and n = prod(size(s))/mx. The loop over bins for
% array sections in this 2D array turns out to be optimised by the Matlab
% JIT compiler (tested in R2021a on Dell 5540 mobile workstation running
% Win10, August 2021).


% Perform checks on input parameters and get size of output arrays
% ----------------------------------------------------------------
mx = numel(x) - 1;      % number of intervals along the input axis
if mx<1
    error('HERBERT:integrate_points:invalid_argument',...
        'The input point position array must have at least two values')
end

if numel(size(s))~=numel(size(s)) || ~all(size(s)==size(e))
    error('HERBERT:integrate_points:invalid_argument',...
        'The sizes of signal array (=[%s]) and error array (=[%s]) do not match',...
        str_compress(num2str(size(s)),','),...
        str_compress(num2str(size(e)),','))
end

nx = numel(xout) - 1;   % number of bins along the output rebin axis
if nx<1
    error('HERBERT:integrate_points:invalid_argument',...
        'The output bin boundary array must have at least two bin boundaries')
end

% Matlab size of signal array with trailing singletons if idim is larger 
% than the dimension of input signal array, s
sz = [size(s), ones(1, idim-numel(size(s)))];

if sz(idim) ~= (mx+1)
    error('HERBERT:integrate_points:invalid_argument',...
        ['The extent of the signal array along axes number %s and the ',...
        'number of values in the input point position array is ',...
        'inconsistent with point data along that axis'], num2str(idim))
end

% Size of output arrays
% (note: any trailing singletons will be eliminated on allocation)
sz_out = [sz(1:idim-1), nx, sz(idim+1:end)];

% Check optional parameter
if nargin==6
    if islognumscalar(distr)
        distr_out = logical(distr);
    else
        error('HERBERT:integrate_points:invalid_argument',...
            'Optional argument ''distr'' must be logical true or false (or 1 or 0)')
    end
else
    distr_out = false;
end


% Perform integration
% -------------------
% Find the first output bin to which there is a contribution from the input bins
% and find the index of the first input bin which makes that contribution

% - Largest index such that x(iin) <= xout(1), or unity if x(1)>xout(1):
iin = max(1, upper_index(x, xout(1)));      
% - Largest index such that xout(iout) <= x(1), or unity if xout(1)>x(1):
iout= max(1, upper_index(xout, x(1)));      

if iin==mx+1 || iout==nx+1
    % Return if there is no overlap between x and xout
    sout = zeros(sz_out);
    eout = zeros(sz_out);
    return
end

% Reshape input array for performing integration to size [p,mx,q], permute
% axes to place the rebin axis at the end, and allocate output arrays
% (The following works for any length of sz and value of idim >=1, because
% prod([])=1)
s = reshape (s, [prod(sz(1:idim-1)), (mx+1), prod(sz(idim+1:end))]);
e = reshape (e, [prod(sz(1:idim-1)), (mx+1), prod(sz(idim+1:end))]);
s = permute(s,[3,1,2]);
e = permute(e,[3,1,2]);
s = reshape(s,[prod(sz)/(mx+1), (mx+1)]);
e = reshape(e,[prod(sz)/(mx+1), (mx+1)]);
sout = zeros([prod(sz)/(mx+1), nx]);
eout = zeros([prod(sz)/(mx+1), nx]);

% Perform the integration
delta_iin = x(iin+1) - x(iin);
if iin > 1, twodelta_lo = x(iin+1) - x(iin-1); else, twodelta_lo = delta_iin; end
if iin < mx-1, twodelta_hi = x(iin+2) - x(iin); else, twodelta_hi = delta_iin; end

while true
    xlo = max(xout(iout),x(iin));
    xhi = min(xout(iout+1),x(iin+1));
    xcent = (xhi + xlo)/2;
    xcent_1 = xcent - x(iin);
    xcent_2 = xcent - x(iin+1);
    delta = xhi - xlo;
    sout(:,iout) = sout(:,iout) + delta *...
        (s(:,iin) * (1 - xcent_1/delta_iin) +...
        s(:,iin+1) * (1 + xcent_2/delta_iin));
    eout(:,iout) = eout(:,iout) + (delta/2) *...
        ((e(:,iin).^2) * (twodelta_lo * (1 - xcent_1/delta_iin)) + ...
        (e(:,iin+1).^2) * (twodelta_hi * (1 + xcent_2/delta_iin)));
    
    if xout(iout+1) >= x(iin+1)
        % Increment input bin counter; break if no further bins
        if iin < mx
            iin = iin + 1;
            delta_iin = x(iin+1) - x(iin);
            twodelta_lo = x(iin+1) - x(iin-1);
            if iin < mx-1
                twodelta_hi = x(iin+2) - x(iin);
            else
                twodelta_hi = delta_iin;
            end
        else
            if distr_out
                dx_out = xout(iout+1) - xout(iout);
                sout(:,iout) = sout(:,iout) / dx_out;
                eout(:,iout) = sqrt(eout(:,iout)) / dx_out;
            else
                eout(:,iout) = sqrt(eout(:,iout));
            end
            break
        end
    else
        % Increment output bin counter; break if no further bins
        if distr_out
            dx_out = xout(iout+1) - xout(iout);
            sout(:,iout) = sout(:,iout) / dx_out;
            eout(:,iout) = sqrt(eout(:,iout)) / dx_out;
        else
            eout(:,iout) = sqrt(eout(:,iout));
        end
        if iout < nx
            iout = iout + 1;
        else
            break
        end
    end
end

% Reshape output arrays
sout = reshape(sout, [prod(sz(idim+1:end)), prod(sz(1:idim-1)), nx]);
eout = reshape(eout, [prod(sz(idim+1:end)), prod(sz(1:idim-1)), nx]);
sout = permute(sout, [2,3,1]);
eout = permute(eout, [2,3,1]);
sout = reshape(sout, sz_out);
eout = reshape(eout, sz_out);
