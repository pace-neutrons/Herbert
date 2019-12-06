function S = get_fun_props_ (obj)
% Get the functions properties in a structure
%
%   >> S = get_fun_props_ (obj)
%
% Input:
% ------
%   obj     mfclass object
%
% Output:
% -------
%   S       Functions structure on output: fields are 
%               foreground_is_local_, fun_, pin_, np_, free_
%               background_is_local_, bfun_, bpin_, nbp_, bfree_


% Original author: T.G.Perring
%
% $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)


S.foreground_is_local_ = obj.foreground_is_local_;
S.fun_ = obj.fun_;
S.pin_ = obj.pin_;
S.np_ = obj.np_;
S.free_ = obj.free_;

S.background_is_local_ = obj.background_is_local_;
S.bfun_ = obj.bfun_;
S.bpin_ = obj.bpin_;
S.nbp_ = obj.nbp_;
S.bfree_ = obj.bfree_;
