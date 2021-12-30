function sigvarobj = sigvar (obj)
% Create sigvar object
% 
%   >> sigvarobj = sigvar (obj)
%
% Input:
% ------
%   obj         Input object
%
% Output:
% -------
%   sigvarobj   Output sigvar object created from input object. 
%               <a href="matlab:help('sigvar');">Click here</a> for details.

sigvarobj = sigvar(obj.signal_, (obj.error_).^2, ~isnan(obj.signal_));
