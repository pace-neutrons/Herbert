function y = linspace_rand (x1, x2, n, frac, varargin)
% Generate linspace with random fluctuations
%
%   >> y = linspace_rand (x1, x2, n, frac)
%
% Just like the Matlab intrinsic function linspace, this generates n
% equally spaced points between x1 and x2, except that the values of y have
% random deviations added to them which are drawn from a uniform
% distribution from the equally spaced values.
%
% Input
% -----
%   x1, x2  Lower and upper values of the equally spaced points before
%           random deviates are added
%
%   n       Number of points. Points spaced by (x2-x1)/(n-1)
%
%   frac    Gives width of uniform distribution centred on each value of y
%           as a fraction of the point spacing. 0 <=frac < 1
%
% Optional:
%   '-seed', val    Set the random number generator seed to val.
%                   If val=0 then reset the default random generator
%                  method and the seed to zero. Recover the input state of
%                  the generator on exit.
%
% Output:
% -------
%   y       Output values


% Parse arguments
if frac >1 || frac < 0
    error ('HERBERT:linspace_rand:invalid_argument',...
        'Argument ''frac'' must satisfy 0 <= frac < 1')
end

val = parse_keyval ({'-seed'}, {[]}, varargin{:});
seed = val{1};
if ~isempty(seed)
    S = rng;
    if seed==0
        rng('default')
    else
        rng(seed);
    end
end

% Return jittery linspace
y = linspace(x1, x2, n);

if frac ~= 0
    if n > 1
        delta = (x2 - x1)/(numel(y) - 1);
        y = y + delta * (rand(size(y)) - 0.5);
    elseif n == 1
        y = y + (rand(size(y)) - 0.5);
    end
end
