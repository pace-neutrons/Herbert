function [hh_1d_gau,hp_1d_gau,pp_1d_gau]=make_testdata_IX_dataset_1d (nx0, nw, varargin)
% Create arrays of IX_dataset_1d with random x axes and 2D Gaussian signal
%
%   >> [hh_1d_gau, hp_1d_gau, pp_1d_gau] = make_testdata_IX_dataset_1d (nx0, nw)
%   >> ... = make_testdata_IX_dataset_1d (nx0, nw, height, cent, sig)
%   >> ... = make_testdata_IX_dataset_1d (nx0, nw, height, cent, sig, range)
%
%   >> ... = make_testdata_IX_dataset_1d (..., '-seed', val)
%   >> ... = make_testdata_IX_dataset_1d (..., '-nfrac', val)
%
% By default, the output objects are different everytime this function is 
% run, as a random number generator is used in their creation
% Alternatively, the seed can be explicitly set for reproducable output
%
%
% Input:
% -------
%   nx0         Used to generate values of points along the x axis.
%               Each IX_dataset_1d will have between nx0 and (1+nfrac)*nx0
%              data points, where nfrac is by default 0.2 (but can be set to
%              another value with option '-nfrac' below)
%   nw          Number of workspaces in the output IX_dataset_1d arrays
%   height      Peak of Gaussian
%                   Default: 10
%   cent        Centre of Gaussian
%                   Default: 5
%   sig         Standard deviations along x and y axes [sigx, sigy]
%                   Default: 2.5
%   range       Range of data, centred on cent_xy
%                   Default: 10
%
% Optional:
%   'seed',val  Give random number generator seed. This will enable the same
%               datasets to be regenerated.
%               Positive integer
%                   Default: the current value on entry (so random)
%   'nfrac',val Maximum number of additional points as a fraction of nx0.
%               A random number of additional point points is chosen with a
%              hat distribution. Can be set to zero by putting val=0.
%
%
% Output:
% -------
%   hh_1d_gau   Array of IX_dataset_1d objects (length nw)
%                - Histogram data, distribution==true
%                - x arrays have different lengths, but are
%                  approximately in the range 0-10.
%                - Signal and error correspond to a noisy 2D Gaussian
%                  centred on x=5 and the middle workspace number 
%                  i.e. nw/2.
%
%   hp_1d_gau   Array of IX_dataset_1d objects (length nw)
%                - Mixed histogram and point datasets, distribution==true
%                - x,signal,error a different noisy 2D Gaussian as above
%
%   pp_1d_gau   Array of IX_dataset_1d objects (length nw)
%                - Point data, distribution==true
%                - x,signal,error a different noisy 2D Gaussian as above


% Author: T.G.Perring

keyval_def = struct('seed',[],'nfrac',0.2);
opt.default = 'dashprefix_noneg';
[par, keyval] = parse_arguments (varargin, 0, 4, keyval_def, opt);

% Gaussian parameters
if numel(par)>=1
    if ~isnumeric(par{1}), error('Check parameters'), end
    height = par{1};
else
    height = 10;
end

if numel(par)>=2
    if ~isnumeric(par{2}), error('Check parameters'), end
    cent = par{2};
else
    cent = 5;
end

if numel(par)>=3
    if ~isnumeric(par{3}), error('Check parameters'), end
    sig = par{3};
else
    sig = 2.5;
end

if numel(par)>=4
    if ~isnumeric(par{4}), error('Check parameters'), end
    range = par{4};
else
    range = 10;
end

% If requested, store and set random number generator status
if ~isempty(keyval.seed)
    s = rng;
    rng(keyval.seed);
end

nfrac = keyval.nfrac;
ebar_frac = 0.1;    % determines relative size of error bars

cent_w = nw / 2;
sig_w = nw / 4;



% A big point array
% ------------------------------
nx = nx0 + round(nfrac*nx0*rand(nw,1));
pp_1d_gau = repmat(IX_dataset_1d,nw,1);
for i=1:nw
    x = ax_vals (cent, range, nx(i));
    y = exp(-0.5*(((x-cent)/sig).^2 + ((i-cent_w)/sig_w).^2));
    y = height * (y + ebar_frac * (4 * rand(1, nx(i)) - 2));
    e = height * (ebar_frac * rand(1, nx(i)));
    pp_1d_gau(i) = IX_dataset_1d(x, y, e, 'Point data, distribution',...
        IX_axis('Energy transfer','meV','$w'), 'Counts', true);
end


% A big histogram array
% ------------------------------
nx = nx0 + round(nfrac*nx0*rand(nw,1));
hh_1d_gau=repmat(IX_dataset_1d,nw,1);
for i=1:nw
    x = ax_vals (cent, range, nx(i) + 1);
    xp = 0.5*(x(2:end) + x(1:end-1));
    y = exp(-0.5*(((xp-cent)/sig).^2 + ((i-cent_w)/sig_w).^2));
    y = height * (y + ebar_frac * (4 * rand(1, nx(i)) - 2));
    e = height * (ebar_frac * rand(1, nx(i)));
    hh_1d_gau(i) = IX_dataset_1d(x, y, e, 'Histogram data, distribution',...
        IX_axis('Energy transfer','meV','$w'), 'Counts', true);
end


% A big mixed histogram and point array
% -------------------------------------
nx = nx0 + round(nfrac*nx0*rand(nw,1));
hp_1d_gau=repmat(IX_dataset_1d,nw,1);
for i=1:nw
    dn=round(rand(1));
    if dn==1
        x = ax_vals (cent, range, nx(i) + 1);
        xp = 0.5*(x(2:end) + x(1:end-1));
    else
        x = ax_vals (cent, range, nx(i));
        xp = x;
    end
    y = exp(-0.5*(((xp-cent)/sig).^2 + ((i-cent_w)/sig_w).^2));
    y = height * (y + ebar_frac * (4 * rand(1, nx(i)) - 2));
    e = height * (ebar_frac * rand(1, nx(i)));
    if dn==0
        type = 'Point data';
    else
        type = 'Histogram data';
    end
    hp_1d_gau(i) = IX_dataset_1d(x, y, e , [type,', distribution'],...
        IX_axis('Energy transfer','meV','$w'), 'Counts', true);
end


% Recover randon number generator state
if ~isempty(keyval.seed)
    rng(s);
end

%--------------------------------------------------------------------------
function a = ax_vals (cent, range, n)
% n equally spaced values covering the range, with the addition of a random
% component about the evenly spaced points drawn from a hat function

del = range/(n-1);  % spacing between values
frac = 0.25;        % maximum component that can be added or subtracted
a = (cent - range/2) + del*(0:n-1) + (frac*del)*(2*rand(1,n)-1);
