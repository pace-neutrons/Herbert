function [nd, sz] = dimensions_(obj)
% Find number of dimensions and extent along each dimension.
%
%   >> [nd, sz] = dimensions_ (obj)
%
% Input:
% ------
%   obj     IX_dataset object, or array of IX_dataset objects
%
% Output:
% -------
%   nd      Dimensionality of the object
%
%   sz      Extend along each of the dimensions (row vector length nd)
%           If obj is an array of objects, then sz is array size [nobj,nd]
%           - If a single object, size(sz) = [1,nd] (i.e. row vector)
%           - If one-dimensional, size(sz) = size(obj)
%           - If an array of multi-dimensional objects,
%                                 size(sz) = [nd, size(obj)]
%             but with dimensions of length one removed
%           e.g. if nd = 4, size(obj) = [1,3] then
%               dimensions_(obj)  size(sz) = [4,3]  (not [4,1,3])
%
%           This behaviour is the same as that of the Matlab intrinsic
%           function squeeze.
%
%
% Notes about sizes of arrays
% ---------------------------
% Dimensions method must return object dimensionality, nd, and extent along
% each dimension in a row vector, sz, according to the convention that
% size(sz) = [1,nd]. This is not necessarily the same at the size of the
% signal and error arrays as returned by the Matlab intrinsic function size.
%
% Object  nd  size                             Matlab signal size
%   0D  nd=0  sz=zeros(1,0)                    [1,1]
%   1D  nd=1  sz=n1                            [n1,1]
%   2D  nd=2  sz=[n1,n2]                       [n1,n2]
%   3D  nd=3  sz=[n1,n2,n3]     even if n3=1   [n1,n2,n3] less trailing singletons
%   4D  nd=4  sz=[n1,n2,n3,n4]  even if n4=1,  [n1,n2,n3,n4] "    "        "
%                               or n3=n4=1

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('IX_dataset')),'_docify')
%
%   doc_file = fullfile(doc_dir,'doc_dimensions_method.m')
%
%   object = 'IX_dataset'
%   method = 'dimensions_'
%   ndim = 'ndims'
% -----------------------------------------------------------------------------
% <#doc_beg:> IX_dataset
%   <#file:> <doc_file>
% <#doc_end:>
% -----------------------------------------------------------------------------


% Dimensionality
nd = obj.ndim();    % works even if empty obj array, as static method

% Get extent along each dimension from the signal array
% Get significant dimensions from sz, adding trailing singletons as needed
% [to check it works for all dimensionalities 0,1,2,3.., consider nd>ns,
% where ns = numel(size(obj.signal_))]
if numel(obj)==1
    sz = size(obj.signal_);
    sz = [sz(1:min(nd,numel(sz))), ones(1,nd-numel(sz))];
    
elseif nd==1
    sz = zeros(size(obj));
    for i=1:numel(obj)
        sz(i) = size(obj(i).signal_,1);
    end
    
else
    sz = ones(nd, numel(obj));
    for i=1:numel(obj)
        sztmp = size(obj(i).signal_);
        if i==1
            n = min(nd,numel(sztmp));
        end
        sz(1:n, i) = sztmp(1:n);
    end
    sz = squeeze(reshape(sz, [nd, size(obj)]));
end
