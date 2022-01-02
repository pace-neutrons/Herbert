function obj_out = shift (obj, x)
% Shift an IX_dataset_4d or array of objects along the axes
%
%   >> obj_out = shift (obj, val)
%
% Input:
% ------
%   obj         IX_dataset_4d object or array of objects
%
%   val         Vector length 4 giving the shift along the axes
%
% Output:
% -------
%   obj_out     Output IX_dataset_4d or array of IX_dataset_4d.

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('IX_dataset')),'_docify')
%
%   doc_file = fullfile(doc_dir,'doc_shift_method.m')
%
%   object = 'IX_dataset_4d'
%   method = 'shift'
%   axis_or_axes = 'the axes'
%   ndim = '4'
%   one_dim = 0
%   multi_dim = 1
% -----------------------------------------------------------------------------
% <#doc_beg:> IX_dataset
%   <#file:> <doc_file>
% <#doc_end:>
% -----------------------------------------------------------------------------


obj_out = shift_ (obj, x, 1:4);
