function obj = set_constraints_props_ (obj, S)
% Set the constraints properties in a structure
%
%   >> obj = set_constraints_props_ (obj, S)
%
% Input:
% ------
%   obj     mfclass object
%
% Output:
% -------
%   obj     mfclass object
%   S       Constraints structure on output: fields are
%               bound_
%               bound_to_
%               ratio_
%               bound_to_res_
%               ratio_res_
%
% Output:
% -------
%   obj     mfclass object


% Original author: T.G.Perring
%
% $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)


obj.bound_ = S.bound_;
obj.bound_to_ = S.bound_to_;
obj.ratio_ = S.ratio_;
obj.bound_to_res_ = S.bound_to_res_;
obj.ratio_res_ = S.ratio_res_;
