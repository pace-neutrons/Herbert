function w = acos_single (w1)
% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('sigvar')),'_docify')
%   doc_file_header = fullfile(doc_dir,'doc_sigvar_unary_single.m')
%
%   func_name = 'acos'
% -----------------------------------------------------------------------------
% <#doc_beg:> binary_and_unary_ops
%   <#file:> <doc_file_header>
% <#doc_end:>
% -----------------------------------------------------------------------------

s = acos(w1.signal_);
if ~isempty(w1.variance_)
    e = w1.variance_./abs(1-s.^2);     % ensure positive
else
    e = [];
end

w = sigvar(s,e);
