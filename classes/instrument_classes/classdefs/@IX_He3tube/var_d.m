function val = var_d (obj, wvec, sintheta)
% Variance of depth of absorbtion in a 3He cylindrical tube
%
%   >> val = var_d (obj, wvec)
%   >> val = var_d (obj, wvec, sintheta)
%
% Input:
% ------
%   obj         IX_He3tube object
%   wvec        Wavevector of absorbed neutrons (Ang^-1). Scalar or array
%   sintheta    [Optional] Sine of the angle between the cylinder axis and
%              the direction of travel of the neutron i.e. sintheta=1 when
%              the neutron hits the detector perpendicular to the tube
%              axis. Scalar or array.
%               Default: sintheta=1 (i.e. beam perpendicular to cylinder)
%
%   Note: either or both of wvec and sintheta can be arrays, but if both
%   are arrays then they must have the same size and shape.
%
% Output:
% -------
%   val         Variance of depth of aborption (m^2)


% Original author: T.G.Perring
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)


alf = macro_xs_dia (obj, wvec);
if nargin==3
    alf = alf./sintheta;
end

val = (obj.inner_rad^2) * var_d(alf);
if nargin==3
    val = val./(sintheta.^2);
end
