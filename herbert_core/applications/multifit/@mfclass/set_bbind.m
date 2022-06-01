function obj = set_bbind (obj,varargin)
% -----------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_set_bind_intro = fullfile(mfclass_doc,'doc_set_bind_intro.m')
%
%   type = 'back'
%   pre = 'b'
%   atype = 'fore'
%   func  = 'set'
%
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
% Set bindings of <type>ground parameters to <type>- &/or <atype>ground parameters
%
%   <#file:> <doc_set_bind_intro> <type> <pre> <atype> <func>
%
%
% See also add_bbind set_bfun set_bind add_bind set_fun
% <#doc_end:>
% -----------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


% Process input
% -------------
isfore = false;

% Clear all bindings first
[ok, mess, obj] = clear_bind_private_ (obj, isfore, {'all'});
if ~ok, error(mess), end

% Add new bindings
[ok, mess, obj] = add_bind_private_ (obj, isfore, varargin);
if ~ok, error(mess), end

