function w = asec (w1)
% Implements asec(w1) for objects
%
%   >> w = asec(w1)
%
% Input:
% ------
%   w1          Input object or array of objects on which to apply the
%               unary operator.
%
% Output:
% -------
%   w           Output object or array of objects.

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('sigvar')),'_docify')
%
%   doc_file_header = fullfile(doc_dir,'doc_unary_header.m')
%   doc_file_IO = fullfile(doc_dir,'doc_unary_general_args_IO_description.m')
%
%   list_operator_arg = 0
%   func_name = 'asec'
% -----------------------------------------------------------------------------
% <#doc_beg:> binary_and_unary_ops
%   <#file:> <doc_file_header>
%
%   <#file:> <doc_file_IO> <list_operator_arg>
% <#doc_end:>
% -----------------------------------------------------------------------------

w = unary_op_manager (w1, @asec);
