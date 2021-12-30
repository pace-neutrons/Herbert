function obj_out = linspace (obj, n)
% Make a IX_dataset_1d with the same axis ranges but with a uniform grid of values
%
%   >> obj_out = linspace (obj, n)
%
% Input:
% ------
%   obj     IX_dataset_1d object or array of objects
%
%   n       Number of data points in which to divide the axis
%               e.g.  >> wout = linspace (win, 1000);
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
%   obj_out Output IX_dataset_1d or array of IX_dataset_1d.
%           The signal and error arrays are set to zeros.
%
% Useful, for example, when plotting the result of a fit: often one wants
% a dataset with a fine grid over the range of the data to create a fine
% plot of the calculated function:
%
%   >> kk = multifit (wdata);
%   >>      :
%   >> [wfit, fitdata] = kk.fit (wdata, @gauss, p_init);
%   >> wtmp = linspace(wdata, 1000);
%   >> wcalc = func_eval (wtmp ,@gauss, fitdata.p);
%   >> plot (wcalc)

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('IX_dataset')),'_docify')
%
%   doc_file = fullfile(doc_dir,'doc_linspace_method.m')
%
%   object = 'IX_dataset_1d'
%   method = 'linspace'
%   axis_or_axes = 'axis'
%   ndim = '1'
%   one_dim = 1
%       nval_scalar = '1000'
%   multi_dim = 0
%   func = 'gauss'
% -----------------------------------------------------------------------------
% <#doc_beg:> IX_dataset
%   <#file:> <doc_file>
% <#doc_end:>
% -----------------------------------------------------------------------------


obj_out = linspace_ (obj, n);
