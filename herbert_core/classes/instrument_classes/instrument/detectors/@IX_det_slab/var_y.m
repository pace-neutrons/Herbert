function val = var_y (obj, npath_in, varargin)
% Variance of position of absorption along y-axis in a slab detector
%
%   >> val = var_y (obj, npath, wvec)
%   >> val = var_y (obj, npath, ind, wvec)
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
%   val         Variance of position of absorption (m^2)
%               The shape is whichever of ind or wvec is an array.
%               If both ind and wvec are arrays, the shape is that of wvec


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


[sz,~,ind] = parse_npath_ind_wvec_ (obj, npath_in, varargin{:});

width = obj.width_(ind(:));
if ~isscalar(ind)
    val = (reshape(width, sz).^2)/12;
else
    val = ((width.^2)/12) *ones(sz);
end

