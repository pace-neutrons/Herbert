function val = mean (obj, npath_in, varargin)
% Mean position of absorption in a slab detector
%
%   >> val = mean (obj, npath, wvec)
%   >> val = mean (obj, npath, ind, wvec)
%
% Input:
% ------
%   obj         IX_det_slab object
%
%   npath       Unit vectors along the neutron path in the detector coordinate
%               frame for each detector. Vector length 3 or an array size [3,n]
%               where n is the number of indices (see ind below). If a vector
%               then npath is expanded internally to [3,n] array
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
%   val         Mean position of absorption in the detector frame (m)
%               The size is [3,sz] where sz is the shape of whichever of ind
%               or wvec is an array, and then the array is squeezed.
%               If both ind and wvec are arrays, the shape is that of wvec


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


mx = mean_x (obj, npath_in, varargin{:});
my = mean_y (obj, npath_in, varargin{:});
mz = mean_z (obj, npath_in, varargin{:});

val = reshape([mx(:)';my(:)';mz(:)'], [3,size(mx)]);
val = squeeze(val);

