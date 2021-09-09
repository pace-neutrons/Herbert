function obj_out = rebin_y (obj, varargin)
% Rebin an IX_dataset_3d object or array of IX_dataset_3d objects along the y-axis
%
%   >> obj_out = rebin_y (obj, descr)
%   >> obj_out = rebin_y (obj, wref)           % reference object to provide output bins
%
%   >> obj_out = rebin_y (..., 'int')          % change averaging method for point data
%   
% Input:
% ------
%   obj     Input object or array of objects to be rebinned
%   descr   Description of new bin boundaries 
%           - [], '' or zero:       Leave bins unchanged
%           - dx (numeric scalar)   New bins centred on zero with constant width dx
%           - [xlo,xhi]             Change limits but bin boundaries in between unchanged
%           - [xlo,dx,xhi]          Lower and upper limits xlo and xhi, with intervening bins
%                                       dx>0    constant bins within the range
%                                       dx<0    logarithmic bins within the range
%                                              (if dx1<0, then must have x1>0, dx2<0 then x2>0 ...)
%                                       dx=0    retain existing bins within the range
%           - [x1,dx1,x2,dx2...xn]  Generalisation to multiple contiguous ranges
%  OR
%   wref    Reference IX_dataset_2d to provide new bins along y axis
%
%           The lower limit can be -Inf and/or the upper limit +Inf, when the 
%           corresponding limit is set by the full extent of the data.
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
%   >> obj_out = rebin_y (obj, [])
%   >> obj_out = rebin_y (obj, 10)
%   >> obj_out = rebin_y (obj, [2000,3000])
%   >> obj_out = rebin_y (obj, [2000,Inf])
%   >> obj_out = rebin_y (obj, [2000,10,3000])
%   >> obj_out = rebin_y (obj, [5,-0.01,3000])
%   >> obj_out = rebin_y (obj, [5,-0.01,1000,20,4000,50,20000])
%
% See also corresponding function rebin2_y which accepts a set of bin boundaries
% of form [x1,x2,x3,...xn] instead of a rebin descriptor


array_is_descriptor = true;
obj_out = rebin_ (obj, 2, array_is_descriptor, varargin{:});
