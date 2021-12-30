function [s, var, msk] = sigvar_get (obj)
% Get signal and variance from object, and a logical array of which values to keep
% 
%   >> [s, var, msk] = sigvar_get (obj)
%
% Input:
% ------
%   obj     Input object
%
% Output:
% -------
%   s       Signal array
%   var     Variance array; same size as signal array
%   msk     Mask array with same size as signal and variance arrays
%           Elements are true (active) or false (masked)
%
%
% NOTE:
% This method exists only for backwards compatibility. Please use the
% sigvar method instead: 
%   >> sigvarobj = sigvar (obj)
% and then use the properties of sigvarobj: s, e and msk 
%
% <a href="matlab:help('sigvar');">Click here</a> for details.

sigvarobj = sigvar (obj);
s = sigvarobj.s;
var = sigvarobj.e;
msk = sigvarobj.msk;
