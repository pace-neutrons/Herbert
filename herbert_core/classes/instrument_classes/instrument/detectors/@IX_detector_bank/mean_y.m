function val = mean_y (obj, varargin)
% Mean position of absorption along the y-axis in detector(s) in a detector bank
%
%   >> val = mean_y (obj, wvec)
%   >> val = mean_y (obj, ind, wvec)
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
%   val         Mean point of absorption along the y-axis (m)
%               The shape is whichever of ind or wvec is an array.
%               If both ind and wvec are arrays, the shape is that of wvec


% Original author: T.G.Perring
%
% $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)


[~, ind] = parse_ind_wvec_ (obj.det, varargin{:});
val = mean_y (obj.det, squeeze(obj.dmat(1,:,ind(:))), varargin{:});
