function [nd, sz] = dimensions_(obj)
% Find number of dimensions and extent along each dimension.
%
%   >> [nd, sz] = dimensions_ (obj)
%
% Input:
% ------
%   obj     IX_dataset object
%
% Output:
% -------
%   nd      Dimensionality of the object
%   sz      Extend along each of the dimensions (row vector length nd)
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
nd = obj.ndim();

% Get extent along each dimension from the signal array
% Get significant dimensions from sz, adding trailing singletons as needed
% [to check it works for all dimensionalities 0,1,2,3.., consider nd>nz,
% where nz = numel(size(obj.signal_))]
sz = size(obj.signal_);
sz = [sz(1:min(nd,numel(sz))), ones(1,nd-numel(sz))];   % length nd, trailing ones if needed
