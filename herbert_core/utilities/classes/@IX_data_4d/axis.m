function [ax, hist] = axis (obj, varargin)
% Return all information about an axis or set of axes from a dataset
%
%   >> [ax, hist] = axis (obj)
%   >> [ax, hist] = axis (obj, iax)
%
% Input:
% -------
%   obj     IX_dataset_4d object or array of objects
%   iax     [optional] axis index, or array of indicies, in range 1 to 4
%           Default: 1:4
%
% Output:
% -------
%   ax      Structure or array structure with fields:
%             values        Values of bin boundaries (if histogram data)
%                           Values of data point positions (if point data)
%             axis          IX_axis object containing caption and units codes
%             distribution  Logical scalar: true if a distribution; false
%                           otherwise)
%
%   hist    Logical with true is axis is histogram, false where point data
%
%   The sizes of the output arguments are the same, and are determined as
%   follows:
%           - If a single object, size(hist) = [1,numel(iax)]
%           - If a single axis,   size(hist) = size(obj)
%           - If an array of objects and array of axes, then size(hist) =
%             [numel(iax), size(w)] but with dimensions of length 1 removed
%           e.g. if ndim(obj) = 4, size(obj) = [1,3] then
%               ishistogram(obj)        size(status) = [4,3]  (not [4,1,3])
%
%           This behaviour is the same as that of the Matlab intrinsic
%           function squeeze.

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('IX_dataset')),'_docify')
%
%   doc_file = fullfile(doc_dir,'doc_axis_method.m')
%
%   object = 'IX_dataset_4d'
%   method = 'axis'
%   ndim = '4'
% -----------------------------------------------------------------------------
% <#doc_beg:> IX_dataset
%   <#file:> <doc_file>
% <#doc_end:>
% -----------------------------------------------------------------------------


[ax, hist] = axis_ (obj, varargin{:});
