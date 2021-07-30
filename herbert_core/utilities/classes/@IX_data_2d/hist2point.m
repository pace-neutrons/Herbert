function obj_out = hist2point(obj, varargin)
% Convert histogram IX_dataset_2d (or an array of them) to point dataset(s).
%
%   >> wout=hist2point(win)
%
% Leaves point datasets unchanged.
%
% Histogram datasets are converted to distribution as follows:
%       Histogram distribution => Point data distribution;
%                                 Signal numerically unchanged
%
%             non-distribution => Point data distribution;
%                                 Signal converted to signal per unit axis length
%
% Histogram data is always converted to a distribution: it is assumed that point
% data represents the sampling of a function at a series of points, and histogram
% non-distribution data is not consistent with that.

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('sigvar')),'_docify')
%
%   doc_file_header = fullfile(doc_dir,'doc_binary_op_manager_header.m')
%   doc_file_IO = fullfile(doc_dir,'doc_binary_general_args_IO_description.m')
%   doc_file_notes = fullfile(doc_dir,'doc_binary_op_manager_notes.m')
%   doc_file_sigvar_notes = fullfile(doc_dir,'doc_sigvar_notes.m')
%
%   list_operator_arg = 1
% -----------------------------------------------------------------------------
% <#doc_beg:> binary_and_unary_ops
%   <#file:> <doc_file_header>
%
%   <#file:> <doc_file_IO> <list_operator_arg>
%
%
% NOTES:
%   <#file:> <doc_file_notes>
%
%   <#file:> <doc_file_sigvar_notes>
% <#doc_end:>
% -----------------------------------------------------------------------------

obj_out = hist2point_(obj, varargin{:});
