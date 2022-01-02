function w = set_simple(w, varargin)
% OBSOLETE: Set fields in an object without checking consistency - for fast setting. Use carefully!
%
%**************************************************************************
% 2021-12-31:
%
% This method is now obsolete; it was only ever intended for internal use
% and permitted inconsistent class property values if used without care.
%
% Please replace with appropriate calls to the relevant object property set
% methods.
%
%**************************************************************************
%
%   >> w = set_simple (w, varargin)
%
% e.g.
%   >> w = set_simple (w, 'x', [13,14], 'error', 2.1)


classname = class(w);
error ('HERBERT:set_simple:obsolete', ['This function is now obsolete.',...
    'Type ''doc ', classname, '/set_simple'' for more information'])
