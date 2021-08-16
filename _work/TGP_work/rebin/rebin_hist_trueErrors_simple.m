function [sout, eout] = rebin_hist_trueErrors_simple (x, s, e, idim, xout)
% Simple implementation of rebinning nD histogram data
%
%   >> [sout, eout] = rebin_hist_trueErrors_simple (x, s, e, idim, xout)
%
% Implemented by looping over 1D integrals
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


sz = size(s);
if idim>numel(sz)
    sz = [sz, ones(idim-numel(sz))];
end
mx = numel(x)-1;

ix = 1:numel(sz);
ix(1) = idim;
ix(idim) = 1;
stmp = permute(s,ix);
etmp = permute(e,ix);
sz_tmp = size(stmp);
stmp = reshape(stmp,[mx,prod(sz)/mx]);
etmp = reshape(etmp,[mx,prod(sz)/mx]);

nx = numel(xout)-1;
sout = zeros([nx,prod(sz)/mx]);
eout = zeros([nx,prod(sz)/mx]);

for i=1:(prod(sz)/mx)
    [sout(:,i), eout(:,i)] = rebin_hist_1D_trueErrors(x, stmp(:,i), etmp(:,i), xout);
end

sout = reshape(sout, [nx, sz_tmp(2:end)]);
eout = reshape(eout, [nx, sz_tmp(2:end)]);
sout = permute(sout,ix);
eout = permute(eout,ix);
sz_out = sz;
sz_out(idim) = nx;
sout = reshape(sout,sz_out);
eout = reshape(eout,sz_out);
