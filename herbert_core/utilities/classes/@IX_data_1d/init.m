function obj_out = init (obj, varargin)
% Create a new IX_dataset_1d object by updating an existing object
%
%   >> obj_out = init (obj, arg1, arg2, ...)
%
% The input arguments are the same as the class constructor.
%
% This method exists for two reasons.
% - It is not always possible to update an object via the property set
%   methods because of interdependencies, for example changing the extent
%   of the signal array as this is coupled to the error array and axis
%   coordinates.
% - It is much more efficient to update many properties at once rather than
%   repeadedly have consistency checks made as each property is updated.
%
% Input:
% -------
%   obj             IX_dataset_1d object
%
%   arg1, arg2, ... Property values to update. The possible arguments are
%                   identical to the constructor for the IX_dataset_1d class
%
% Output:
% -------
%   obj_out         IX_dataset_1d object, updated according to the provided
%                   input arguments.
%
% See also IX_dataset_1d

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('IX_dataset')),'_docify')
%
%   doc_file = fullfile(doc_dir,'doc_init_method.m')
%
%   object = 'IX_dataset_1d'
%   method = 'init'
%   ndim = '1'
% -----------------------------------------------------------------------------
% <#doc_beg:> IX_dataset
%   <#file:> <doc_file>
% <#doc_end:>
% -----------------------------------------------------------------------------


obj_out = init_ (obj, varargin{:});
