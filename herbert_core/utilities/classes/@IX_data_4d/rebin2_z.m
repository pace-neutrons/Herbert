function obj_out = rebin2_z (obj, varargin)
% Rebin an IX_dataset_3d object or array of IX_dataset_3d objects along the z-axis
%
%   >> obj_out = rebin2_z (obj, descr)
%   >> obj_out = rebin_z (obj, wref)           % reference object to provide output bins
%
%   >> obj_out = rebin_z (..., 'int')          % change averaging method for point data
%   
% Input:
% ------
%   obj     Input object or array of objects to be rebinned
%   descr   Description of new bin boundaries 
%           - [], '' or zero:       Leave bins unchanged
%           - dx (numeric scalar)   New bins centred on zero with constant width dx
%           - [xlo,xhi]             Single bin
%           - [x1,x2,...xn]         Set of bin boundaries
%
%           The lower limit can be -Inf and/or the upper limit +Inf, when the 
%           corresponding limit is set by the full extent of the data.
%  OR
%   wref    Reference IX_dataset_2d to provide new bins along z axis
%
%   Point data: for an axis with point data (as opposed to histogram data)
%   'ave'   average the values of the points within each new bin (DEFAULT)
%   'int'   average of the function defined by linear interpolation between the data points
%
% Output:
% -------
%   obj_out    Output object or array of objects
%
% EXAMPLES
%   >> obj_out = rebin2_z (obj, [])
%   >> obj_out = rebin2_z (obj, 10)
%   >> obj_out = rebin2_z (obj, [2000,3000])
%   >> obj_out = rebin2_z (obj, [2000,Inf])
%   >> obj_out = rebin2_z (obj, [2000,3000,4000,5000,6000])
%
% See also corresponding function rebin_z which accepts a rebin descriptor
% of form [x1,dx1,x2,dx2,...xn] instead of a set of bin boundaries


array_is_descriptor = false;
obj_out = rebin_ (obj, 3, array_is_descriptor, varargin{:});
