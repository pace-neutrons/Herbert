function hist = ishistogram_(obj, iax)
% Return a logical array indicating axes that are histogram data
%
%   >> status = ishistogram_ (obj)
%   >> status = ishistogram_ (obj, iax)
%
% Input:
% ------
%   obj     IX_dataset object or array of objects
%   iax     [optional] axis index, or array of indicies, in range 1 to ndim
%           Default: 1:ndim
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
%   object = 'IX_dataset'
%   method = 'ishistogram_'
%   ndim = 'ndim'
% -----------------------------------------------------------------------------
% <#doc_beg:> IX_dataset
%   <#file:> <doc_file>
% <#doc_end:>
% -----------------------------------------------------------------------------


nd = obj(1).ndim();

% Check the validity of the axis indices
if nargin==1
    iax = 1:nd;
else
    if isempty(iax) || any(rem(iax,1)~=0) || any(iax<1) || any(iax>nd)
        if nd==1
            mess = 'Axis indices can only take the value 1 for a 1-dimensional object';
        else
            mess = ['Axis indices must be in the range 1 to ', num2str(nd),...
                ' for a 1-dimensional object'];
        end
        error('HERBERT:ishistogram_:invalid_argument', mess)
    end
end

% Calculate hist
if numel(obj)==1
    hist = ishistogram_single_(obj, iax);
    
elseif isscalar(iax)
    hist = arrayfun(@(x)(ishistogram_single_(x, iax)), obj);
    
else
    hist = arrayfun(@(x)(make_column(ishistogram_single_(x, iax))), obj,...
        'UniformOutput',false);
    hist = reshape([hist{:}], [nd, size(obj)]);
    hist = squeeze(hist);
end


%--------------------------------------------------------------------------
function hist = ishistogram_single_ (obj, iax)
% Return ishistogram for a single object as a row vector
sx = cellfun(@numel, obj.xyz_); % size of axis extents - row vector length nd
[~, sz] = dimensions_(obj);
hist = ((sx(iax)-sz(iax))==1);
