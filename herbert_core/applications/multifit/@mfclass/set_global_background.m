function obj = set_global_background(obj,set_global)
% Specify that there will be a global background fit function
%
%   >> obj = obj.set_global_background          % set global background
%   >> obj = obj.set_global_background (status) % set global background true or false
%
% If the scope changes i.e. is altered from global to local, or local to global,
% then the background fit functions and any previously set constraints are
% cleared
%
% See also: set_local_background set_local_foreground 

% -----------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_set_scope_intro = fullfile(mfclass_doc,'doc_set_scope_intro.m')
%
%   type  = 'back'
%   scope = 'global'
%
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:> <doc_set_scope_intro> <type> <scope>
%
% See also: set_local_background set_local_foreground
% <#doc_end:>
% -----------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


if nargin==1
    set_global = true;
end
isfore = false;
obj = set_scope_private_(obj, isfore, ~set_global);

