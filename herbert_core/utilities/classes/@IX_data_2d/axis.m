function [ax, hist] = axis (obj, varargin)
% Return all information about an axis or set of axes from a dataset
%
%   >> [ax, hist] = axis(obj)
%   >> [ax, hist] = axis(obj, iax)
%
% Input:
% -------
%   obj     IX_dataset_2d object or array of objects
%   iax     [optional] axis index, or array of indicies, in range 1 to ndim
%           Default: 1:ndim
%
% Output:
% -------
%   ax      Structure or array structure with fields:
%             values        Values of bin boundaries (if histogram data)
%                           Values of data point positions (if point data)
%             axis          IX_axis object containing caption and units codes
%             distribution  Logical scalar: true if a distribution; false otherwise)
%
%   hist    Logical with true is axis is histogran, false where point data
%
%   The sizes of the output arguments are the same, and are determined as
%   follows:
%           - If a single object, size(status) = [1,numel(iax)]
%           - If a single axis,   size(status) = size(obj)
%           - If an array of objects and array of axes, then size(status) = 
%             [numel(iax), size(w)] but with dimensions of length 1 removed
%           e.g. if ndim(obj) = 4, size(obj) = [1,3] then
%               ishstogram(obj)         size(status) = [4,3]  (not [4,1,3])
%
%           This behaviour is the same as that of the Matlab intrinsic
%           function squeeze.

[ax, hist] = axis_ (obj, varargin{:});
