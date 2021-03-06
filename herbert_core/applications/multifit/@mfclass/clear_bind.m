function obj = clear_bind (obj, varargin)
% Clear any binding of parameters for one or more foreground functions
%
% Clear for all parameters for all foreground functions
%   >> obj = obj.clear_bind
%   >> obj = obj.clear_bind ('all')
%
% Clear for all parameters for one or more specific foreground function(s)
%   >> obj = obj.clear_bind (ifun)
%
% Input:
% ------
%   ifun    Row vector of foreground function indicies [Default: all functions]

% -----------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_clear_bind_intro = fullfile(mfclass_doc,'doc_clear_bind_intro.m')
%
%   type = 'fore'
%   pre = ''
%
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:> <doc_clear_bind_intro> <type> <pre>
% <#doc_end:>
% -----------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


% Process input
% -------------
isfore = true;
[ok, mess, obj] = clear_bind_private_ (obj, isfore, varargin);
if ~ok, error(mess), end

