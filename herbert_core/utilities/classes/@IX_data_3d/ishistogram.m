function status = ishistogram(obj, varargin)
% Return logical array indicating axes that are histogram data
%
%   >> status = ishistogram(obj)
%   >> status = ishistogram(obj, iax)
%
% Input:
% ------
%   obj     IX_dataset_3d object or array of objects
%   iax     [optional] axis index, or array of indicies, in range 1 to ndim
%           Default: 1:ndim
%
% Output:
% -------
%   status  Logical with true is axis is histogran, false where point data
%           - If a single object, size(status) = [1,numel(iax)]
%           - If a single axis,   size(status) = size(obj)
%           - If an array of objects and array of axes, then size(status) = 
%             [numel(iax), size(w)] but with dimensions of length 1 removed
%           e.g. if ndim(obj) = 4, size(obj) = [1,3] then
%               ishstogram(obj)         size(status) = [4,3]  (not [4,1,3])
%
%           This behaviour is the same as that of the Matlab intrinsic
%           function squeeze.

status = ishistogram_(obj, varargin{:});
