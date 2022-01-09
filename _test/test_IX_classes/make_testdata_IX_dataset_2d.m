function [hh_gau, hp_gau, ph_gau, pp_gau] = make_testdata_IX_dataset_2d...
    (nx, ny, varargin)
% Create IX_dataset_2d object with random x and y axes and Gaussian signal
%
%   >> [hh_gau, hp_gau, ph_gau, pp_gau] = make_testdata_IX_dataset_2d (nx, ny)
%   >> ... = make_testdata_IX_dataset_2d (nx, ny, height, cent_xy, sig_xy)
%   >> ... = make_testdata_IX_dataset_2d (nx, ny, height, cent_xy, sig_xy, range_xy)
%
%   >> ... = make_testdata_IX_dataset_2d (..., '-seed', val)
%
% By default, the output objects are different everytime this function is 
% run, as a random number generator is used in their creation
% Alternatively, the seed can be explicitly set for reproducable output
%
%
% Input:
% ------
%   nx          Number of data points along x axis
%
%   ny          Number of data points along y axis
%
%   height      Peak of 2D Gaussian
%                   Default: 10
%
%   cent_xy     Centre of 2D Gaussian [x,y]
%                   Default: [5, 3]
%
%   sig_xy      Standard deviations along x and y axes [sigx, sigy]
%                   Default: [2.5, 1.5]
%
%   range_xy    Range of data, centred on cent_xy
%                   Default: [10, 6]
%
% Optional:
%   '-seed',val Give random number generator seed. This will enable the same
%               datasets to be regenerated.
%               Positive integer
%                   Default: the current value on entry (so random)
%
% Output:
% -------
%   hh_gau      hist-hist 2D Gaussian; distribution in both directions
%   hp_gau      hist-point (different x,y,signal and errors)
%   ph_gau      point-hist (different x,y,signal and errors)
%   pp_gau      point-point (different x,y,signal and errors)


% Author: T.G.Perring

keyval_def = struct('seed',[]);
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
    cent_x = par{2}(1); cent_y = par{2}(2);
else
    cent_x = 5; cent_y = 3;
end

if numel(par)>=3
    if ~isnumeric(par{3}), error('Check parameters'), end
    sig_x = par{3}(1); sig_y = par{3}(2);
else
    sig_x = 2.5; sig_y = 1.5;
end

if numel(par)>=4
    if ~isnumeric(par{4}), error('Check parameters'), end
    xrange = par{4}(1); yrange = par{4}(2);
else
    xrange=10; yrange=6;
end

% If requested, store and set random number generator status
if ~isempty(keyval.seed)
    rng(keyval.seed);
end

ebar_frac = 0.1;    % determines relative size of error bars

% Create datasets
% - hist-hist
x = ax_vals(cent_x, xrange, nx+1);
y = ax_vals(cent_y, yrange, ny+1);
[xx,yy] = ndgrid(0.5*(x(2:end)+x(1:end-1)), 0.5*(y(2:end)+y(1:end-1)));
signal = exp(-0.5*(((xx-cent_x)/(sig_x)).^2 + ((yy-cent_y)/(sig_y)).^2));
signal = height * (signal + ebar_frac*(4*rand(nx,ny)-2));
err = height*(ebar_frac*rand(nx,ny));

hh_gau = IX_dataset_2d(x, y, signal, err, 'hist-hist',...
    IX_axis('Energy transfer','meV','$w'), 'Temperature', 'Counts', true, true);

% - hist-point
x = ax_vals(cent_x, xrange, nx+1);
y = ax_vals(cent_y, yrange, ny);
[xx,yy] = ndgrid(0.5*(x(2:end)+x(1:end-1)), y);
signal = exp(-0.5*(((xx-cent_x)/(sig_x)).^2 + ((yy-cent_y)/(sig_y)).^2));
signal = height * (signal + ebar_frac*(4*rand(nx,ny)-2));
err = height*(ebar_frac*rand(nx,ny));

hp_gau = IX_dataset_2d(x, y, signal, err, 'hist-pnt',...
    IX_axis('Energy transfer','meV','$w'), 'Temperature', 'Counts', true, true);

% - point-hist
x = ax_vals(cent_x, xrange, nx);
y = ax_vals(cent_y, yrange, ny+1);
[xx,yy] = ndgrid(x, 0.5*(y(2:end)+y(1:end-1)));
signal = exp(-0.5*(((xx-cent_x)/(sig_x)).^2 + ((yy-cent_y)/(sig_y)).^2));
signal = height * (signal + ebar_frac*(4*rand(nx,ny)-2));
err = height*(ebar_frac*rand(nx,ny));

ph_gau = IX_dataset_2d(x, y, signal, err, 'pnt-hist',...
    IX_axis('Energy transfer','meV','$w'), 'Temperature', 'Counts', true, true);

% - point-point
x = ax_vals(cent_x, xrange, nx);
y = ax_vals(cent_y, yrange, ny);
[xx,yy] = ndgrid(x, y);
signal = exp(-0.5*(((xx-cent_x)/(sig_x)).^2 + ((yy-cent_y)/(sig_y)).^2));
signal = height * (signal + ebar_frac*(4*rand(nx,ny)-2));
err = height*(ebar_frac*rand(nx,ny));

pp_gau = IX_dataset_2d(x, y, signal, err, 'pnt-pnt',...
    IX_axis('Energy transfer','meV','$w'), 'Temperature', 'Counts', true, true);


%--------------------------------------------------------------------------
function a = ax_vals (cent, range, n)
% n equally spaced values covering the range, with the addition of a random
% component about the evenly spaced points drawn from a hat function

del = range/(n-1);  % spacing between values
frac = 1/3;         % maximum component that can be added or subtracted
a = (cent - range/2) + del*(0:n-1) + (frac*del)*(2*rand(1,n)-1);
