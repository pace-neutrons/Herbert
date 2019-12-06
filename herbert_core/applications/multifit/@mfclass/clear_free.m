function obj = clear_free (obj, varargin)
% Free all parameters to vary in fitting for one or more foreground functions
%
% Free all parameters for all foreground functions
%   >> obj = obj.clear_free
%   >> obj = obj.clear_free ('all')
%
% Free all parameters for one or more specific foreground function(s)
%   >> obj = obj.clear_free (ifun)
%
% Input:
% ------
%   ifun    Row vector of foreground function indicies [Default: all functions]

% -----------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_clear_free_intro = fullfile(mfclass_doc,'doc_clear_free_intro.m')
%
%   type = 'fore'
%   pre = ''
%
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:> <doc_clear_free_intro> <type> <pre>
% <#doc_end:>
% -----------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)


% Process input
isfore = true;
[ok, mess, obj] = clear_free_private_ (obj, isfore, varargin);
if ~ok, error(mess), end
