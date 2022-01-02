function obj_out = scale_y (obj, x)
% Rescale an IX_dataset_4d or array of objects along the y-axis
%
%   >> obj_out = scale_y (obj, val)
%
% Input:
% ------
%   obj         IX_dataset_4d object or array of objects
%
%   val         Scalar giving the rescaling factor along the the y-axis
%
% Output:
% -------
%   obj_out     Output IX_dataset_4d or array of IX_dataset_4d.

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('IX_dataset')),'_docify')
%
%   doc_file = fullfile(doc_dir,'doc_scale_method.m')
%
%   object = 'IX_dataset_4d'
%   method = 'scale_y'
%   axis_or_axes = 'the y-axis'
%   ndim = '1'
%   one_dim = 1
%   multi_dim = 0
% -----------------------------------------------------------------------------
% <#doc_beg:> IX_dataset
%   <#file:> <doc_file>
% <#doc_end:>
% -----------------------------------------------------------------------------


obj_out = scale_ (obj, x, 2);
