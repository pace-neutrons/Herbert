function obj = set_bfree (obj, varargin)
% Set which background function parameters are free and which are bound
%
% Set for all background functions
%   >> obj = obj.set_bfree           % All parameters set to free
%   >> obj = obj.set_bfree (pfree)   % Row vector (applies to all) or cell array (one per function)
%
% Set for one or more specific background function(s)
%   >> obj = obj.set_bfree (ifun)
%   >> obj = obj.set_bfree (ifun, pfree)


% Check there are function(s)
% ---------------------------
if numel(obj.bfun_)==0
    error ('Cannot set free/fixed status of background function(s) before they have been set.')
end

% Process input
% -------------
isfore = false;
[ok, mess, obj] = set_free_private_ (obj, isfore, varargin);
if ~ok, error(mess), end
