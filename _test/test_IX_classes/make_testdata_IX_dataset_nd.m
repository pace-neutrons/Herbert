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

% Check optional random number
if numel(varargin)==2 && ischar(varargin{1}) && ...
        strncmpi(varargin{1}, '-seed', numel(varargin{1}))
    set_seed = true;
    seed = varargin{2};
elseif numel(varargin)==0
    set_seed = false;
else
    error('HERBERT:make_testdata_IX_dataset_nd:invalid_argument',...
        'Check optional argument(s)')
end

% Fill output object
ndim = numel(sz);
w = repmat (IX_dataset_nd(ndim), szarr);

if set_seed     % set the seed
    s = rng;
    rng(seed);
end

for i=1:prod(szarr)
    w(i) = make_testdata_IX_dataset_nd_single (sz);
end

if set_seed     % reset seed to input value
    rng(s);
end

%--------------------------------------------------------------------------
function w = make_testdata_IX_dataset_nd_single (sz)
% Create IX_datset_nd with random signal and error
%
%   sz          Size and extent of signal and error arrays
%               e.g. [3,4,1,1]  results in IX_dataset_4d, with the given
%               extents along each dimension. Note the significant
%               singleton dimensions


ndim = numel(sz);

title=['Test IX_dataset_',num2str(ndim),'d'];
signal = 10 * rand([sz,1,1]);
err = rand([sz,1,1]);
s_axis=IX_axis('Counts');
ax = repmat (struct ('values', [],'axis', [], 'distribution', []), [1, ndim]);
for i = 1:ndim
    ax(i).values = 1:(sz(i)+1);
    ax(i).axis = IX_axis(['Axis ',num2str(i)]);
    ax(i).distribution = false;
end

w = IX_dataset_nd (title, signal, err, s_axis, ax);
