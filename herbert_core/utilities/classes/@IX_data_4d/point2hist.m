function obj_out = point2hist (obj, varargin)
% Convert point IX_dataset_4d object or array to histogram object(s).
%
%   >> obj_out = point2hist (obj)        % convert all axes
%   >> obj_out = point2hist (obj, iax)   % convert given axis or axes
%
% Any histogram data axes are left unchanged.
%
% Input:
% -------
%   obj     IX_dataset_4d object or array of objects
%
%   iax     [optional] axis index, or array of indicies, in range 1 to 4
%           Default: 1:4
%
% Output:
% -------
%   obj_out IX_dataset_4d object or array of objects with point axes
%           converted to histogram axes
%
%
% Notes:
% Point datasets are converted to distributions as follows:
%       Point distribution => Histogram distribution;
%                             Signal numerically unchanged
%
%         non-distribution => Histogram distribution;
%                             Signal numerically unchanged
%                             *** NOTE: The signal caption will be plotted
%                               incorrectly if units are given in the axis
%                               description of the point data
%
% Point data is always converted to a distribution: it is assumed that
% point data represents the sampling of a function at a series of points,
% and only a histogram as a distribution is consistent with that.

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('IX_dataset')),'_docify')
%
%   doc_file = fullfile(doc_dir,'doc_point2hist_method.m')
%
%   object = 'IX_dataset_4d'
%   method = 'point2hist'
%   ndim = '4'
% -----------------------------------------------------------------------------
% <#doc_beg:> IX_dataset
%   <#file:> <doc_file>
% <#doc_end:>
% -----------------------------------------------------------------------------


obj_out = point2hist_ (obj, varargin{:});
