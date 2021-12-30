function obj_out = linspace (obj, n)
% Make a IX_dataset_2d with the same axis ranges but with a uniform grid of values
%
%   >> obj_out = linspace (obj, n)
%
% Input:
% ------
%   obj     IX_dataset_2d object or array of objects
%
%   n       Number of data points in which to divide the axes
%           - n is a scalar: each axis divided into the same number of points
%               e.g.  >> wout = linspace (win, 200);
%           - n is a vector with length 2: each axis divided differently
%               e.g.  >> wout = linspace (win, [100,200]);
%             Use zero  where you want an axis to remain unchanged
%               e.g.  >> wout = linspace (win, [100,0]);
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
%   obj_out Output IX_dataset_2d or array of IX_dataset_2d.
%           The signal and error arrays are set to zeros.
%
% Useful, for example, when plotting the result of a fit: often one wants
% a dataset with a fine grid over the range of the data to create a fine
% plot of the calculated function:
%
%   >> kk = multifit (wdata);
%   >>      :
%   >> [wfit, fitdata] = kk.fit (wdata, @gauss2d, p_init);
%   >> wtmp = linspace(wdata, 200);
%   >> wcalc = func_eval (wtmp ,@gauss2d, fitdata.p);
%   >> plot (wcalc)

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('IX_dataset')),'_docify')
%
%   doc_file = fullfile(doc_dir,'doc_linspace_method.m')
%
%   object = 'IX_dataset_2d'
%   method = 'linspace'
%   axis_or_axes = 'axes'
%   ndim = '2'
%   one_dim = 0
%       nval_scalar = '200'
%   multi_dim = 1
%       nval_vector = '[100,200]'
%       nval_vector0 = '[100,0]'
%   func = 'gauss2d'
% -----------------------------------------------------------------------------
% <#doc_beg:> IX_dataset
%   <#file:> <doc_file>
% <#doc_end:>
% -----------------------------------------------------------------------------


obj_out = linspace_ (obj, n);
