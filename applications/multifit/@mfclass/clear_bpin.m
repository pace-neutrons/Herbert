function obj = clear_bpin (obj, varargin)
% Clear all parameters and constraints for one or more background functions
%
% Clear all parameters for all background functions
%   >> obj = obj.clear_bpin
%   >> obj = obj.clear_bpin ('all')
%
% Clear all parameters for one or more specific background function(s)
%   >> obj = obj.clear_bpin (ifun)
%
% Input:
% ------
%   ifun    Row vector of background function indicies [Default: all functions]

% -----------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_clear_pin_intro = fullfile(mfclass_doc,'doc_clear_pin_intro.m')
%
%   type = 'back'
%   pre = 'b'
%
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:> <doc_clear_pin_intro> <type> <pre>
% <#doc_end:>
% -----------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)


% Process input
isfore = false;
[ok, mess, obj] = clear_pin_private_ (obj, isfore, varargin);
if ~ok, error(mess), end
