function val = var_z (obj, varargin)
% Variance of height of absorption along the z-axis in detector(s) in a detector bank
%
%   >> val = var_z (obj, wvec)
%   >> val = var_z (obj, ind, wvec)
%
% Input:
% ------
%   obj         IX_detector_bank object
%
%   ind         Indices of detectors for which to calculate. Scalar or array.
%               Default: all detectors (i.e. ind = 1:ndet)
%
%   wvec        Wavevector of absorbed neutrons (Ang^-1). Scalar or array.
%
% If both ind and wvec are arrays, then they must have the same number of elements
%
%
% Output:
% -------
%   val         Variance of absorption along the z-axis(m^2)
%               The shape is whichever of ind or wvec is an array.
%               If both ind and wvec are arrays, the shape is that of wvec


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


[~, ind] = parse_ind_wvec_ (obj.det, varargin{:});
val = var_z (obj.det, squeeze(obj.dmat(1,:,ind(:))), varargin{:});

