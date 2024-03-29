function Y = interp1_arr(ytable,xq,ind)
% Linearly interpolate on an array of tabulated functions
%
%   >> Y = interp1_arr(ytable,xq,ind)
%
% Works by linear interpolation.
%
% Input:
% ------
%   ytable      Array size [npnt,nfun] with ytable(:,i) containing the
%              values corresponding to equally spaced values of
%              abscissae between 0 and 1
%   xq          Array of query values of the abscissae. min(xq)>=0,
%              max(xq)<=1
%   ind         Array containing the function index from which the value
%              of y is to be taken. numel(ind)==numel(xq), and 
%              min(ind(:))>=1, max(ind(:))<=nfun
%
% Output:
% -------
%   Y           Array of values, with the same size as xq

% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


npnt = size(ytable,1);    % number of points in cumulative pdf
ipnt = 1 + (npnt-1)*xq(:) + npnt*(ind(:)-1);       % indicies (real) in closed interval [1,npnt]
Y = interp1(1:numel(ytable), ytable(:), ipnt, 'linear', 'extrap');
Y = reshape(Y,size(xq));

