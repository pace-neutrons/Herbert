function [sout, eout] = rebin_hist_vectorised(x, s, e, xout)
% Rebins histogram data along axis iax=1 of an IX_dataset_nd with dimensionality ndim=1.
%
%   >> [sout, eout] = rebin_hist_vectorised (x, s, e, xout)
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
mx=numel(x)-1;
sz=[size(s),ones(1,ndim-numel(size(s)))];   % this works even if ndim=1, i.e. ones(1,-1)==[]
if mx<1 || sz(iax)~=mx || numel(size(s))~=numel(size(e)) || any(size(s)~=size(e))
    error('Check sizes of input arrays')
end

nx=numel(xout)-1;
if nx<1
    error('Check size of output axis array')
end


% Perform rebin
% -------------
if xout(end)>x(1) && xout(1)<x(end)
    % Get the counts and variances in each bin segment
    [bin, ibin, binout, jbin, okout, ib] = get_indices (x(:)', xout(:)');
    if ~isempty(bin) && bin(end)==numel(x)
        ok = true(numel(bin)-1,1);
    else
        ok = true(numel(bin),1);
    end
    if ~isempty(okout), okout(end)=false; end     % ensures the final bin boundary ignored
    
    xtot = zeros(jbin(end),1);
    stot = zeros(jbin(end)-1,1);
    vtot = zeros(jbin(end)-1,1);
    
    xtot(ibin) = x(bin);
    xtot(jbin) = xout;
    dxtot = diff(xtot);
    
    stot(ibin(ok)) = s(bin(ok));
    stot(jbin(okout)) = s(binout(okout));
    stot = stot.*dxtot;
    
    vtot(ibin(ok)) = e(bin(ok));
    vtot(jbin(okout)) = e(binout(okout));
    vtot = (vtot.*dxtot).^2;    % still the old-style error calculation
    
    % Accumulate counts in each bin
    dx = diff(xout(:));
    sout = accumarray (ib(1:end-1)', stot, [nx,1]) ./ dx;
    eout = sqrt(accumarray (ib(1:end-1)', vtot, [nx,1])) ./dx;
    
else
    sout = zeros(nx,1);
    eout = zeros(nx,1);
end



%-------------------------------------------------------------------------
function [bin, ibin, binout, jbin, okout, ib] = get_indices (x, xout)
% Everything rows coming in, rows going out

n = numel(xout)-1;

% Index of new bin boundaries into old bins (range [0, numel(x)])
[~, ~, binout] = histcounts (xout, [-Inf,x,Inf]);
binout = binout-1;

% Position of new bin boundaries in the ordered list of old and new
% boundaries (where an old and a new boundary match, the old comes first)
jbin = binout + (-binout(1)+1:-binout(1)+n+1);

% Index of old bin boundaries that lie within the new bins, into old bins
bin = binout(1)+1:binout(end);

% Position of old bin boundaries in the ordered list of old and new
% boundaries (where an old and a new boundary match, the old comes first)
ibin = true(1,jbin(end));
ibin(jbin) = false;
ibin = find(ibin);

% Index of ordered list of old and new boundaries into new bins
ib = zeros(1,jbin(end));
ib(jbin) = 1:(n+1);
ib(ibin) = replicate_iarray (1:n,diff(binout));

% New bin boundaries that lie within the old bin boundaries
okout = (binout>0 & binout<numel(x));
