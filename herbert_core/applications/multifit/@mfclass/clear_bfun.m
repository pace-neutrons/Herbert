function obj = clear_bfun(obj, varargin)
% Clear background fit function(s), clearing any corresponding constraints
%
% Clear all background functions
%   >> obj = obj.clear_bfun
%   >> obj = obj.clear_bfun ('all')
%
% Clear a particular background function or set of background functions
%   >> obj = obj.clear_bfun (ifun)
%
% Input:
% ------
%   ifun    Row vector of background function indicies [Default: all functions]

% -----------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_clear_fun_intro = fullfile(mfclass_doc,'doc_clear_fun_intro.m')
%
%   type = 'back'
%   pre = 'b'
%
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:> <doc_clear_fun_intro> <type> <pre>
% <#doc_end:>
% -----------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)


% Process input
% -------------
isfore = false;
[ok, mess, obj] = clear_fun_private_ (obj, isfore, varargin);
if ~ok, error(mess), end
