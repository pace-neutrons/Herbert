function [ok, mess, obj] = remove_bind_private_ (obj, isfore, ifun)
% Remove clear constraints for foreground/background function(s)
%
%   >> [ok, mess, obj] = remove_bind_private_ (obj, isfore, ifun)


if isfore
    nfun = numel(obj.fun_);
else
    nfun = numel(obj.bfun_);
end

% Now check validity of input
% ---------------------------
[ok,mess,ifun] = function_indicies_parse (ifun, nfun);
if ~ok, return, end

% All arguments are valid, so populate the output object
% ------------------------------------------------------
% Now remove constraints properties
if isfore
    ipb = sawtooth_iarray (obj.np_(ifun));
    ifunb = replicate_iarray (ifun, obj.np_(ifun));
else
    ipb = sawtooth_iarray (obj.nbp_(ifun));
    ifunb = replicate_iarray (-ifun, obj.nbp_(ifun));
end
S_con = binding_clear (obj.get_constraints_props_, obj.np_, obj.nbp_, ipb, ifunb);

% Update the object
obj = obj.set_constraints_props_ (S_con);
