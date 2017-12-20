function obj = clear_pin (obj, varargin)
% Clear all parameters and constraints for one or more foreground functions
%
% Clear all parameters for all foreground functions
%   >> obj = obj.clear_pin
%   >> obj = obj.clear_pin ('all')
%
% Clear all parameters for one or more specific foreground function(s)
%   >> obj = obj.clear_pin (ifun)
%
% Input:
% ------
%   ifun    Row vector of foreground function indicies [Default: all functions]

% -----------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_clear_pin_intro = fullfile(mfclass_doc,'doc_clear_pin_intro.m')
%
%   type = 'fore'
%   pre = ''
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
isfore = true;
[ok, mess, obj] = clear_pin_private_ (obj, isfore, varargin);
if ~ok, error(mess), end
