function val = mean_d (obj, varargin)
% Mean depth of absorption in detector(s) in a detector bank
%
%   >> val = mean_d (obj, wvec)
%   >> val = mean_d (obj, ind, wvec)
%
% Note: this is along the neutron path
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
%   val         Mean depth of absorption along the neutron path (m)
%               The shape is whichever of ind or wvec is an array.
%               If both ind and wvec are arrays, the shape is that of wvec


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


[~, ind] = parse_ind_wvec_ (obj.det, varargin{:});
val = mean_d (obj.det, squeeze(obj.dmat(1,:,ind(:))), varargin{:});

