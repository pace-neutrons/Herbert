function [sout, eout] = rebin_hist_trueErrors(x, s, e, xout)
% Rebins histogram data along axis iax=1 of an IX_dataset_nd with dimensionality ndim=1.
%
%   >> [sout, eout] = rebin_hist_trueErrors (x, s, e, xout)
%
% Input:
% ------
%   x       Rebin axis bin boundaries (row or column vector)
%   s       Signal array (column vector)
%   e       Standard deviations on signal array (column vector)
%   xout    Output rebin axis bin boundaries (row or column vector)
%
% Output:
% -------
%   sout    Rebinned signal (column vector)
%   eout    Standard deviations on rebinned signal (column vector)
% 
% Assumes that the intensity and error are for a distribution (i.e. signal per unit along the axis)
% Assumes that input x and xout are strictly monotonic increasing
%
%
%**************************************************************************
% T.G.Perring 8 Aug 2021:
% -----------------------
% Vectorised version of original rebin_hist_
% Retains the old-style error bar calculation i.e. adding in quadrature,
% which does not deal consistently with split bins
%**************************************************************************

iax=1;
ndim=1;

% Perform checks on input parameters and initialise output arrays
% ---------------------------------------------------------------
mx=numel(x)-1;      % number of bins along the input rebin axis
sz=[size(s),ones(1,ndim-numel(size(s)))];   % this works even if ndim=1, i.e. ones(1,-1)==[]
if mx<1 || sz(iax)~=mx || numel(size(s))~=numel(size(e)) || any(size(s)~=size(e))
    error('Check sizes of input arrays')
end

nx=numel(xout)-1;   % number of bins along the output rebin axis
if nx<1
    error('Check size of output axis axis')
end
sz_out=sz;
sz_out(iax)=nx;

sout=zeros(sz_out); % trailing singletons in sz do not matter - they are squeezed out in the call to zeros
eout=zeros(sz_out);


% Perform rebin
% -------------
% Find the first output bin to which there is a contribution from the input bins
% and find the index of the first input bin which makes that contribution
iin = max(1, upper_index(x, xout(1)));      % largest index such that x(iin) <= xout(1), or unity if x(1)>xout(1)
iout= max(1, upper_index(xout, x(1)));      % largest index such that xout(iout) <= x(1), or unity if xout(1)>x(1)
if iin==mx+1 || iout==nx+1,  return, end    % guarantees that there is an overlap between x and xout

while true
    delta = (min(xout(iout+1),x(iin+1)) - max(xout(iout),x(iin)));
    sout(iout) = sout(iout) +  delta * s(iin);
    eout(iout) = eout(iout) + delta * (x(iin+1) - x(iin)) * (e(iin).^2);
    if xout(iout+1) >= x(iin+1)
        if iin<mx
            iin = iin + 1;
        else
            sout(iout) = sout(iout) / (xout(iout+1)-xout(iout));		% end of input array reached
            eout(iout) = sqrt(eout(iout)) / (xout(iout+1)-xout(iout));
            break
        end
    else
        sout(iout) = sout(iout) / (xout(iout+1)-xout(iout));
        eout(iout) = sqrt(eout(iout)) / (xout(iout+1)-xout(iout));
        if iout<nx
            iout = iout + 1;
        else
            break
        end
    end
end
