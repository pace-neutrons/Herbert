function val = effic (obj, npath_in, varargin)
% Efficiency of a old Tobyfit approx to a 3He cylindrical tube
%
%   >> val = effic (obj, npath_in, wvec)
%   >> val = effic (obj, npath_in, ind, wvec)
%
% Input:
% ------
%   obj         IX_det_TobyfitClassic object
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
%   val         Efficiency (in range 0 to 1) averaged over the tube.
%               The shape is whichever of ind or wvec is an array.
%               If both ind and wvec are arrays, the shape is that of wvec


% Original author: T.G.Perring
%
% $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)


sz = parse_npath_ind_wvec_ (obj, npath_in, varargin{:});
val = ones(sz);

