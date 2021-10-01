function [sout, eout] = rebin_hist_trueErrors_xNx(x, s, e, idim, xout)
% Rebins histogram data along one dimension of signal and error arrays
%
%   >> [sout, eout] = rebin_hist_trueErrors_ (x, s, e, idim, xout)
%
% Assumes that the intensity and error are for a distribution (i.e. signal 
% per unit measure along the x-axis)
%
% *** Method permutes the integration axis to the middle of three dimensions
%
% Input:
% ------
%   x       Bin boundaries along axis to be rebinned (row or column vector).
%           It is assumed that the values of x are strictly monotonic
%          increasing i.e. all bins have width greater than zero.
%
%   s       Signal array. The extent along dimension idim must match the
%          number of bins i.e. (numel(x)-1).
%           If the number of dimensions of the signal array as determined
%          using the size function is less than idim, then following the
%          standard Matlab convention the array is treated as having higher
%          dimensions of length one. Accordingly, x must have length 2.
%
%   e       Standard deviations on the values in the signal array.
%          The sizes of the signal and error arrays must be the same
%
%   idim    Dimension of signal and error arrays to be rebinned (scalar).
%          Assumes idim >= 1.
%
%   xout    Output rebin axis bin boundaries (row or column vector).
%           It is assumed that the values of x are strictly monotonic
%          increasing i.e. all bins have width greater than zero.
%
% Output:
% -------
%   sout    Rebinned signal array. The size of the array is the same as the
%          input array s excepty for dimension number idim, which has 
%          extent equal to the number of output bins i.e. (numel(xout)-1).
%
%   eout    Standard deviations on rebinned signal. Has the same size as
%          the rebinned signal array, sout.
% 
% The method to calculate the standard deviations on the rebinned data
% assures consistency of splitting those on the original bins such that the
% bins can recombined to recover the original standard deviations.


% Perform checks on input parameters and get size of output arrays
% ----------------------------------------------------------------
mx=numel(x)-1;      % number of bins along the input rebin axis
if mx<1
    error('HERBERT:rebin_hist_trueErrors_:invalid_argument',...
        'The input bin boundary array must have at least two bin boundaries')
end

if numel(size(s))~=numel(size(s)) || ~all(size(s)==size(e))
    error('HERBERT:rebin_hist_trueErrors_:invalid_argument',...
        'The sizes of signal array (=[%s]) and error array (=[%s]) do not match',...
        str_compress(num2str(size(s)),','),...
        str_compress(num2str(size(e)),','))
end

nx=numel(xout)-1;   % number of bins along the output rebin axis
if nx<1
    error('HERBERT:rebin_hist_trueErrors_:invalid_argument',...
        'The output bin boundary array must have at least two bin boundaries')
end

% Matlab size of signal array with trailing singletons if idim is larger 
% than the dimension of input signal array, s
sz = [size(s), ones(1, idim-numel(size(s)))];

if sz(idim)~=mx
    error('HERBERT:rebin_hist_trueErrors_:invalid_argument',...
        ['The extent of the signal array along axes number %s and the ',...
        'number of axis values in the input bin boundary array is ',...
        'inconsistent with histogram data along that axis'], num2str(idim))
end

% Size of output arrays
% (note: any trailing singletons will be eliminated on allocation)
sz_out = [sz(1:idim-1), nx, sz(idim+1:end)];


% Perform rebin
% -------------
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

% Reshape input array for performing integration to size [p,mx,q], and
% allocate output arrays with size [p,nx,q]
% (The following works for any length of sz and value of idim >=1, because
% prod([])=1)
sz_tmp = [prod(sz(1:idim-1)), mx, prod(sz(idim+1:end))];
s = reshape (s, sz_tmp);
e = reshape (e, sz_tmp);

sz_out_tmp = [prod(sz(1:idim-1)), nx, prod(sz(idim+1:end))];
sout = zeros(sz_out_tmp);
eout = zeros(sz_out_tmp);

% Perform the rebinning
while true
    delta = (min(xout(iout+1),x(iin+1)) - max(xout(iout),x(iin)));
    sout(:,iout,:) = sout(:,iout,:) + delta * s(:,iin,:);
    eout(:,iout,:) = eout(:,iout,:) + delta * (x(iin+1) - x(iin)) * (e(:,iin,:).^2);
    if xout(iout+1) >= x(iin+1)
        if iin<mx
            iin = iin + 1;
        else
            sout(:,iout,:) = sout(:,iout,:) / (xout(iout+1)-xout(iout));		% end of input array reached
            eout(:,iout,:) = sqrt(eout(:,iout,:)) / (xout(iout+1)-xout(iout));
            break
        end
    else
        sout(:,iout,:) = sout(:,iout,:) / (xout(iout+1)-xout(iout));
        eout(:,iout,:) = sqrt(eout(:,iout,:)) / (xout(iout+1)-xout(iout));
        if iout<nx
            iout = iout + 1;
        else
            break
        end
    end
end

% Reshape output arrays
sout = reshape(sout, sz_out);
eout = reshape(eout, sz_out);
