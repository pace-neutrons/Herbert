function w = set_simple_yse(w, y, s, e)
% OBSOLETE: Set y, signal and error fields in an object with minimal checking of consistency - for fast setting. Use carefully!
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
%   >> w = set_simple_yse(w, y, s, e)
%
%   y       y-axis array
%   s, e    Signal and error arrays - must be arrays with correct lengths along the x and y axes


classname = class(w);
error ('HERBERT:set_simple_yse:obsolete', ['This function is now obsolete.',...
    'Type ''doc ', classname, '/set_simple_yse'' for more information'])
