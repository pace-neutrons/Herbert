% Create a new <object> object by updating an existing object
%
%   >> obj_out = <method> (obj, arg1, arg2, ...)
%
% The input arguments are the same as the class constructor.
%
% This method exists for two reasons.
% - It is not always possible to update an object via the property set
%   methods because of interdependencies, for example changing the extent
%   of the signal array as this is coupled to the error array and axis
%   coordinates.
% - It is much more efficient to update many properties at once rather than
%   repeadedly have consistency checks made as each property is updated.
%
% Input:
% -------
%   obj             <object> object
%
%   arg1, arg2, ... Property values to update. The possible arguments are
%                   identical to the constructor for the <object> class
%
% Output:
% -------
%   obj_out         <object> object, updated according to the provided
%                   input arguments.
%
% See also <object>
