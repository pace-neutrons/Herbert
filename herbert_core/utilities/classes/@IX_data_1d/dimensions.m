function [nd, sz] = dimensions(obj)
% Find number of dimensions and extent along each dimension.
%
%   >> [nd, sz] = dimensions (obj)
%
% Input:
% ------
%   obj     IX_dataset_1d object, or array of IX_dataset_1d objects
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
%               dimensions(obj)  size(sz) = [4,3]  (not [4,1,3])
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
%   object = 'IX_dataset_1d'
%   method = 'dimensions'
%   ndim = '1'
% -----------------------------------------------------------------------------
% <#doc_beg:> IX_dataset
%   <#file:> <doc_file>
% <#doc_end:>
% -----------------------------------------------------------------------------


[nd, sz] = dimensions_(obj);
