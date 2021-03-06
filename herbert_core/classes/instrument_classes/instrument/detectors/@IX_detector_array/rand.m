function X = rand (obj, varargin)
% Return an array of random points in detector(s) in a detector array
%
%   >> X = rand (obj, wvec)
%   >> X = rand (obj, ind, wvec)
%
% Input:
% ------
%   obj         IX_detector_array object
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
%   X           Array of random points in the detector coordinate frame.
%               The size of the array is [3,size(ind)] with any singleton
%              dimensions in sz squeezed away


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


if ~isscalar(obj)
    error('Only operates on a single detector array object (i.e. object must be scalar');
end

X = func_eval (obj.det_bank_, @rand, {'wvec'}, varargin{:});

