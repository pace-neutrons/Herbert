function obj_out = linspace_ (obj, n)
% Make a IX_dataset with the same axis ranges but with a uniform grid of values
%
%   >> obj_out = linspace_ (obj, n)
%
% Input:
% ------
%   obj     IX_dataset object or array of objects
%
%   n       Number of data points in which to divide the axes
%           - n is a scalar: each axis divided into the same number of points
%               e.g.  >> wout = linspace (win, 200);
%           - n is a vector with length ndims: each axis divided differently
%               e.g.  >> wout = linspace (win, [100,80,50,...]);
%             Use zero  where you want an axis to remain unchanged
%               e.g.  >> wout = linspace (win, [100,0,50,...]);
%
%           The number of bin boundaries in the output object is n+1 for a
%           histogram axis, which corresponds to n data points on that axis.
%
%           If the extent of an axis is zero (e.g. the data is point data
%           and there is only one point along that axis), then the
%           axis is not subdivided.
%
% Output:
% -------
%   obj_out Output IX_dataset or array of IX_dataset.
%           The signal and error arrays are set to zeros.
%
% Useful, for example, when plotting the result of a fit: often one wants
% a dataset with a fine grid over the range of the data to create a fine
% plot of the calculated function:
%
%   >> kk = multifit (wdata);
%   >>      :
%   >> [wfit, fitdata] = kk.fit (wdata, @gauss_nd, p_init);
%   >> wtmp = linspace(wdata, 200);
%   >> wcalc = func_eval (wtmp ,@gauss_nd, fitdata.p);
%   >> plot (wcalc)

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('IX_dataset')),'_docify')
%
%   doc_file = fullfile(doc_dir,'doc_linspace_method.m')
%
%   object = 'IX_dataset'
%   method = 'linspace_'
%   axis_or_axes = 'axes'
%   ndim = 'ndims'
%   one_dim = 0
%       nval_scalar = '200'
%   multi_dim = 1
%       nval_vector = '[100,80,50,...]'
%       nval_vector0 = '[100,0,50,...]'
%   func = 'gauss_nd'
% -----------------------------------------------------------------------------
% <#doc_beg:> IX_dataset
%   <#file:> <doc_file>
% <#doc_end:>
% -----------------------------------------------------------------------------


% Dimensionality
nd = obj.ndim();    % works even if empty obj array, as static method

% Check the validity of n
if isnumeric(n) && all(rem(n,1)==0) && all(n>=0)
    if isscalar(n)
        n=n*ones(1,nd);
    elseif numel(n)~=nd
        error('HERBERT:hist2point_:invalid_argument',...
            ['The requested number of data points must be a scalar ',...
            'or a vector length ',num2str(nd)])
    end
else
    error('HERBERT:hist2point_:invalid_argument',...
        ['The requested number of data points must be integer(s) greater than zero\n',...
        '(or zero where axis values are to be left unchanged)'])
end

% Convert each object in turn
obj_out = obj;
for i = 1:numel(obj)
    obj_out(i) = linspace_single_(obj(i), n);
end


%--------------------------------------------------------------------------
function obj_out = linspace_single_ (obj, n)
% Perform linspace for a single object
% Note that for an axis to have linspace applied, it must have n>0 and
% a non-zero range.

nx = n + ishistogram(obj);  % number of values accounting for histogram data
[nd, sz] = dimensions(obj);
sz_new = sz;
xyz_new = obj.xyz_;
for idim = 1:nd
    x = xyz_new{idim};
    if n(idim) > 0 && numel(x) >= 2 && (x(end) > x(1))
        xyz_new{idim} = linspace(x(1), x(end), nx(idim));
        sz_new(idim) = n(idim);
    end
end
if numel(sz_new)==1
    sz_new = [sz_new, 1];   % create true Matlab size in case of nd==1 
end
signal_new = zeros(sz_new);
error_new = zeros(sz_new);
obj_out = obj.init_ (xyz_new, signal_new, error_new);
