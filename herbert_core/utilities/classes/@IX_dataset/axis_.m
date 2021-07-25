function [ax, hist] = axis_(obj, iax)
% Return all information about an axis or set of axes from a dataset
%
%   >> [ax, hist] = axis_(obj)
%   >> [ax, hist] = axis_(obj, iax)
%
% Input:
% -------
%   obj     IX_dataset object or array of objects
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

nd = obj(1).ndim();

% Check the validity of the axis indices
if nargin==1
    iax = 1:nd;
else
    if isempty(iax) || any(rem(iax,1)~=0) || any(iax<1) || any(iax>nd)
        if nd==1
            mess = 'Axis indices can only take the value 1';
        else
            mess = ['Axis indices must be in the range 1 to ', num2str(nd)];
        end
        error('HERBERT:axis:invalid_argument', mess)
    end
end

% Calculate status
if numel(obj)==1
    [ax, hist] = axis_single_(obj, iax);
    
elseif isscalar(iax)
    [ax, hist] = arrayfun(@(x)(axis_single_(x, iax)), obj);
    
else
    [ax, hist] = arrayfun(@(x)(axis_single_(x, iax)), obj,...
        'UniformOutput',false);
    for i=1:numel(obj)
        ax = ax(:);
        hist = hist(:);
    end
    ax = reshape([ax{:}], [nd, size(obj)]);
    hist = reshape([hist{:}], [nd, size(obj)]);
    ax = squeeze(ax);
    hist = squeeze(hist);
end


%-------------------------------------------------------------------------- 
function [ax, hist] = axis_single_ (obj, iax)
% Get axis information for a single object as a row structure array
ax = struct('values', obj.xyz_(iax), 'axis', obj.xyz_axis_(iax),...
    'distribution', obj.xyz_distribution_(iax));

% Return ishistogram for a single object as a row vector
sx = cellfun(@numel, obj.xyz_); % size of axis extents - row vector length nd
[~, sz] = dimensions_(obj);
hist = ((sx(iax)-sz(iax))==1);
