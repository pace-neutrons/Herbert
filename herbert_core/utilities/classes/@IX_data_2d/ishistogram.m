function status = ishistogram(obj, varargin)
% Return a logical array indicating axes that are histogram data
%
%   >> status = ishistogram (obj)
%   >> status = ishistogram (obj, iax)
%
% Input:
% ------
%   obj     IX_dataset_2d object or array of objects
%   iax     [optional] axis index, or array of indicies, in range 1 to 2
%           Default: 1:2
%
% Output:
% -------
%   status  Logical array with true if an axis has histogram data, or false
%           if the axis corresponds to point data
%           - If a single object, size(status) = [1,numel(iax)]
%           - If a single axis,   size(status) = size(obj)
%           - If an array of objects and array of axes, then size(status) =
%             [numel(iax), size(w)] but with dimensions of length 1 removed
%           e.g. if ndim(obj) = 4, size(obj) = [1,3] then
%               ishstogram(obj)         size(status) = [4,3]  (not [4,1,3])
%
%           This behaviour is the same as that of the Matlab intrinsic
%           function squeeze.

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('IX_dataset')),'_docify')
%
%   doc_file = fullfile(doc_dir,'doc_ishistogram_method.m')
%
%   object = 'IX_dataset_2d'
%   method = 'ishistogram'
%   ndim = '2'
% -----------------------------------------------------------------------------
% <#doc_beg:> IX_dataset
%   <#file:> <doc_file>
% <#doc_end:>
% -----------------------------------------------------------------------------


status = ishistogram_(obj, varargin{:});
