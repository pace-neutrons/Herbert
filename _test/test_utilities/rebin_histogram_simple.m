function [sout, eout] = rebin_histogram_simple (x, s, e, idim, xout)
% Simple implementation of rebinning nD histogram data
%
%   >> [sout, eout] = rebin_histogram_simple (x, s, e, idim, xout)
%
% Implemented by looping over 1D integrals. Input and output arguments are
% the same as the function rebin_histogram. So long as that function
% satisfies the unit tests designed for one dimensional data, then this
% function can be used to test it in multiple dimensions.


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
    [sout(:,i), eout(:,i)] = rebin_histogram (x, stmp(:,i), etmp(:,i), 1, xout);
end

sout = reshape(sout, [nx, sz_tmp(2:end)]);
eout = reshape(eout, [nx, sz_tmp(2:end)]);
sout = permute(sout,ix);
eout = permute(eout,ix);
sz_out = sz;
sz_out(idim) = nx;
sout = reshape(sout,sz_out);
eout = reshape(eout,sz_out);
