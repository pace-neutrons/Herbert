function obj_out = scale_x (obj, x)
% Rescale an IX_dataset_2d or array of objects along the x-axis
%
%   >> obj_out = scale_x (obj, val)
%
% Input:
% ------
%   obj         IX_dataset_2d object or array of objects
%
%   val         Scalar giving the rescaling factor along the the x-axis
%
% Output:
% -------
%   obj_out     Output IX_dataset_2d or array of IX_dataset_2d.

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('IX_dataset')),'_docify')
%
%   doc_file = fullfile(doc_dir,'doc_scale_method.m')
%
%   object = 'IX_dataset_2d'
%   method = 'scale_x'
%   axis_or_axes = 'the x-axis'
%   ndim = '1'
%   one_dim = 1
%   multi_dim = 0
% -----------------------------------------------------------------------------
% <#doc_beg:> IX_dataset
%   <#file:> <doc_file>
% <#doc_end:>
% -----------------------------------------------------------------------------


obj_out = scale_ (obj, x, 1);
