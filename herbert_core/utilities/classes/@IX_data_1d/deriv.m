function obj_out = deriv(obj)
% Differentiate an IX_dataset_1d or array of objects along the x-axis
%
%   >> obj_out = deriv (obj)
%
% Input:
% ------
%   obj         IX_dataset_1d object or array of objects
%
% Output:
% -------
%   obj_out     Output IX_dataset_1d or array of IX_dataset_1d.
%
%
% Identical to deriv_x

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('IX_dataset')),'_docify')
%
%   doc_file = fullfile(doc_dir,'doc_deriv_method.m')
%
%   object = 'IX_dataset_1d'
%   method = 'deriv'
%   axis = 'x-axis'
%   is_deriv = 1
% -----------------------------------------------------------------------------
% <#doc_beg:> IX_dataset
%   <#file:> <doc_file>
% <#doc_end:>
% -----------------------------------------------------------------------------


obj_out = deriv_ (obj, 1);
