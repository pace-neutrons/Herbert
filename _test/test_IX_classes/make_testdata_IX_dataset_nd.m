function w = make_testdata_IX_dataset_nd (sz, szarr, varargin)
% Create IX_dataset_Xd object array with a given dimensionality
%
% Single object:
%   >> w = make_testdata_IX_dataset_nd (sz)
%
% Single object:
%   >> w = make_testdata_IX_dataset_nd (sz, szarr)
%
% Single object:
%   >> w = make_testdata_IX_dataset_nd (sz, szarr, '-seed', val)
%
%
% Input:
% ------
%   sz          Size and extent of signal and error arrays
%               e.g. [3,4,1,1]  results in IX_dataset_4d, with the given
%               extents along each dimension. Note the significant
%               singleton dimensions
%
%   szarr       Size of array of objects to be created
%               e.g. szarr = n          n x n matrix of objects
%                    szarr = [n1,n2]
%
% Optional:
%   '-hist',val Indicate if histogram or point data along each axis
%               Can take the following values:
%                   1:  All axes are hisogram axes
%                   0:  All axes are point axes
%                   logical vector (or array of zeros and ones) length ndim
%                   (where ndim is the dimensionality):
%                       Axes are histogram where the corresponding element
%                       is 1 or point where it is 0
%               Default: 'hist'
%               
%   '-frac',val Give jitter on the otherwise equally spaced axis values
%               Must satisfy 0 <= frac < 1
%               Default: frac = 0 (i.e. no jitter)
%
%   '-seed',val Give random number generator seed. This will enable the
%               same datasets to be regenerated.
%               Positive integer
%               Default: the current value on entry (so random signal)
%
% Output:
% -------
%   w           Array of objects with the dimensionality defined by sz.
%               Histogram datasets. Contain random signal.


% Get size of output array
if nargin==1
    szarr = [1,1];
elseif numel(szarr)==1
    szarr = szarr * [1,1];
end

% Fill output object
ndim = numel(sz);
w = repmat (IX_dataset_nd(ndim), szarr);

% Parse optional arguments
vals = parse_keyval ({'-hist', '-frac', '-seed'}, {1, 0, []}, varargin{:});

if islognumscalar(vals{1})
    ishist = logical(repmat(vals{1},1,ndim));
elseif islognum(vals{1}) && numel(vals{1})==ndim
    ishist = logical(vals{1});
else
    error('HERBERT:make_testdata_IX_dataset_nd:invalid_argument',...
        'Check value of optional argument ''-hist''')
end

frac = vals{2};
if ~isnumeric(vals{2}) || frac >1 || frac < 0
    error ('HERBERT:linspace_rand:invalid_argument',...
        'Value of optional argument ''frac'' must satisfy 0 <= frac < 1')
end

seed = vals{3};
if ~isempty(seed)
    if seed==0
        rng('default')
    else
        rng(seed);
    end
end

% Create IX_dataset object(s)
for i=1:prod(szarr)
    w(i) = make_testdata_IX_dataset_nd_single (sz, ishist, frac);
end


%--------------------------------------------------------------------------
function w = make_testdata_IX_dataset_nd_single (sz, ishist, frac)
% Create IX_datset_nd with random signal and error
%
%   sz          Size and extent of signal and error arrays
%               e.g. [3,4,1,1]  results in IX_dataset_4d, with the given
%               extents along each dimension. Note the significant
%               singleton dimensions


ndim = numel(sz);

title=['Test IX_dataset_',num2str(ndim),'d'];
signal = 10 * rand([sz,1,1]); % trailing singletons will be lost
err = rand([sz,1,1]);
s_axis=IX_axis('Counts');
ax = repmat (struct ('values', [],'axis', [], 'distribution', []), [1, ndim]);
for i = 1:ndim
    ax(i).values = linspace_rand (1, sz(i)+ishist(i), sz(i)+ishist(i), frac);
    ax(i).axis = IX_axis(['Axis ',num2str(i)]);
    ax(i).distribution = false;
end

w = IX_dataset_nd (title, signal, err, s_axis, ax);
