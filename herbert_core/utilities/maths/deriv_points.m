function [sout, eout] = deriv_points (x, s, e, idim)
% Differentiate point data along one dimension of signal and error arrays
%
%   >> [sout, eout] = deriv_points (x, s, e, idim)
%
%
% Input:
% ------
%   x       Point positions along the axis to be differentiated (row or 
%          column vector).
%           It is assumed that the values of x are strictly monotonic
%          increasing.
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
% Output:
% -------
%   sout    Differentiated signal array. The size of the array is the same
%          as the input array.
%
%   eout    Standard deviations on integrated signal. Has the same size as
%          the input array.

% The differentiation is performed by permuting and reshaping the signal and 
% error arrays to size = [n,mx] where mx is the number of bins along the
% axis to be rebinned, and n = prod(size(s))/mx. The loop over bins for
% array sections in this 2D array turns out to be optimised by the Matlab
% JIT compiler (tested in R2021a on Dell 5540 mobile workstation running
% Win10, August 2021).


% Perform checks on input parameters and get size of output arrays
% ----------------------------------------------------------------
mx = numel(x);      % number of points along the input axis

if numel(size(s))~=numel(size(e)) || ~all(size(s)==size(e))
    error('HERBERT:integrate_points:invalid_argument',...
        'The sizes of signal array (=[%s]) and error array (=[%s]) do not match',...
        str_compress(num2str(size(s)),','),...
        str_compress(num2str(size(e)),','))
end

% Matlab size of signal array with trailing singletons if idim is larger 
% than the dimension of input signal array, s
sz = [size(s), ones(1, idim-numel(size(s)))];

if sz(idim) ~= mx
    error('HERBERT:integrate_points:invalid_argument',...
        ['The extent of the signal array along axes number %s and the ',...
        'number of values in the input point position array is ',...
        'inconsistent with point data along that axis'], num2str(idim))
end

% Catch case of less than two points
if mx<=1
    % Numerical derivative must be NaN
    sout = NaN(size(s));
    eout = NaN(size(e));
    return
end

% Size of output arrays
% (note: any trailing singletons will be eliminated on allocation)
sz_out = [sz(1:idim-1), mx, sz(idim+1:end)];


% Perform differentiation
% -----------------------
% Reshape input array for performing differentiation to size [p,mx,q], permute
% axes to place the rebin axis at the end, and allocate output arrays
% (The following works for any length of sz and value of idim >=1, because
% prod([])=1)
sz_resize = [prod(sz(1:idim-1)), mx, prod(sz(idim+1:end))];
s = reshape (s, sz_resize);
e = reshape (e, sz_resize);
s = permute(s,[3,1,2]);
e = permute(e,[3,1,2]);
s = reshape(s,[prod(sz)/mx, mx]);
e = reshape(e,[prod(sz)/mx, mx]);
sout = zeros([prod(sz)/mx, mx]);
eout = zeros([prod(sz)/mx, mx]);

% Calculate derivative
dxtmp = repmat(reshape(x(3:end)-x(1:end-2), 1, mx-2), [prod(sz)/mx, 1]);
sout(:,1) = (s(:,2) - s(:,1)) ./ (x(2) - x(1));
sout(:,2:end-1) = (s(:,3:end) - s(:,1:end-2)) ./ dxtmp;
sout(:,end) = (s(:,end) - s(:,end-1)) ./ (x(end) - x(end-1));

% Calculate error bars using standard method
eout(:,1) = sqrt(e(:,2).^2 + e(:,1).^2) ./ (x(2) - x(1));
eout(:,2:end-1) = sqrt(e(:,3:end).^2 + e(:,1:end-2).^2) ./ dxtmp;
eout(:,end) = sqrt(e(:,end).^2 + e(:,end-1).^2) ./ (x(end) - x(end-1));

% Reshape output arrays
sz_return = [prod(sz(idim+1:end)), prod(sz(1:idim-1)), mx];
sout = reshape(sout, sz_return);
eout = reshape(eout, sz_return);
sout = permute(sout, [2,3,1]);
eout = permute(eout, [2,3,1]);
sout = reshape(sout, sz_out);
eout = reshape(eout, sz_out);
