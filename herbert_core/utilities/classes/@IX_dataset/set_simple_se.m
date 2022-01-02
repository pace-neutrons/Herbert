function w = set_simple_se(w, s, e)
% OBSOLETE: Set signal and error fields in an object with minimal checking of consistency - for fast setting. Use carefully!
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
%   >> w = set_simple_se(w, s, e)
%
%   s, e    Signal and error arrays - must be arrays with correct lengths along the x and y axes
%
% Only allows replacement signal and error arrays to have same size as current arrays i.e.
% cannot change between histogram and point mode for either the x or y axes.


classname = class(w);
error ('HERBERT:set_simple_se:obsolete', ['This function is now obsolete.',...
    'Type ''doc ', classname, '/set_simple_se'' for more information'])
