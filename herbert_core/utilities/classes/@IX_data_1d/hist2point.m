function obj_out = hist2point(obj, varargin)
% Convert histogram IX_dataset_1d object or array to point object(s).
%
%   >> obj_out = hist2point (obj)        % convert all axes
%   >> obj_out = hist2point (obj, iax)   % convert given axis or axes
%
% Any point data axes are left unchanged.
%
% Input:
% -------
%   obj     IX_dataset_1d object or array of objects
%
%   iax     [optional] axis index, or array of indicies, in range 1 to 1
%           Default: 1:1
%
% Output:
% -------
%   obj_out IX_dataset_1d object or array of objects with histogram axes
%           converted to point axes
%
%
% Notes:
% Histogram datasets are converted to distribution as follows:
%       Histogram distribution => Point data distribution;
%                                 Signal numerically unchanged
%
%             non-distribution => Point data distribution;
%                                 Signal converted to signal per unit axis
%                                 length
%
% Histogram data is always converted to a distribution: it is assumed that
% point data represents the sampling of a function at a series of points,
% and histogram non-distribution data is not consistent with that.

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('IX_dataset')),'_docify')
%
%   doc_file = fullfile(doc_dir,'doc_hist2point_method.m')
%
%   object = 'IX_dataset_1d'
%   method = 'hist2point'
%   ndim = '1'
% -----------------------------------------------------------------------------
% <#doc_beg:> IX_dataset
%   <#file:> <doc_file>
% <#doc_end:>
% -----------------------------------------------------------------------------


obj_out = hist2point_(obj, varargin{:});
