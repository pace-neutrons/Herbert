function obj_out = squeeze (obj, varargin)
% Remove dimensions of length one dimensions in an IX_dataset_1d object
%
%   >> obj_out = squeeze (obj)         % check all axes
%   >> obj_out = squeeze (obj, iax)    % check selected axes
%
% Input:
% -------
%   obj     IX_dataset_1d object or array of objects to squeeze
%           If the input is an array of objects, then it is possible that
%           different objects could have a different number of axes with
%           length one. In this case, only dimensions that have length one
%           in all objects are removed.
%
%   iax     [optional] axis index, or array of indicies, to check for
%           removal. Values must be in the range 1 to 1
%           Default: 1:1  (i.e. check all axes)
%
% Output:
% -------
%   obj_out IX_dataset_1d object or array of objects with dimensions of
%           length one removed, to produce an array of the same length with
%           reduced dimensionality.
%
%           If all axes are removed, then this is will be because all
%           dimensions have extent one and the signal is a scalar. The
%           output in this case is as follows:
%             - if obj is a single IX_dataset_1d object, obj_out is a
%               structure
%                   obj_out.val     value
%                   obj_out.err     standard deviation
%
%             - if obj is an array of IX_dataset_1d objects, then obj_out
%               is an IX_dataset_Xd object with dimensionality X
%               corresponding tosize(obj), where the signal and error
%               arrays give the scalar values of each of the input objects.

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('IX_dataset')),'_docify')
%
%   doc_file = fullfile(doc_dir,'doc_squeeze_method.m')
%
%   object = 'IX_dataset_1d'
%   method = 'squeeze'
%   ndim = '1'
% -----------------------------------------------------------------------------
% <#doc_beg:> IX_dataset
%   <#file:> <doc_file>
% <#doc_end:>
% -----------------------------------------------------------------------------


obj_out = squeeze_ (obj, varargin{:});
