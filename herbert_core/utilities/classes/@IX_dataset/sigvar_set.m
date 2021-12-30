function obj_out = sigvar_set (obj, sigvarobj)
% Set output object signal and variance fields from input sigvar object
%
%   >> obj_out = sigvar_set (obj, sigvarobj)
%
% Input:
% ------
%   obj         Input object
%   sigvarobj   Input sigvar object
%
% Output:
% -------
%   obj_out     Output object
%               Signal is masked wherever the signal in the sigvar object
%               is masked or isnan.

if ~isequal(size(obj.signal), size(sigvarobj.s))
    error('HERBERT:sigvar_set:invalid_argument',...
        '%s and sigvar object have inconsistent sizes', class(obj))
end

% Output object with updated signal and error arrays
obj_out = obj;
obj_out.signal_ = sigvarobj.s;
obj_out.error_ = sqrt(sigvarobj.e);

% Explicitly mask signal, as sigvar does not 
msk = (~isnan(sigvarobj.s) | sigvarobj.msk);
obj_out = mask_(obj_out, msk);    
