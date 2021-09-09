function obj_out = rebin (obj, varargin)
% Rebin an IX_dataset_3d object or array of IX_dataset_3d objects along the x-,y- and z-axes
%
%   >> obj_out = rebin (obj, descr_x, descr_y, descr_z)
%   >> obj_out = rebin (obj, wref)             % reference object to provide output bins
%
%   >> obj_out = rebin (..., 'int')            % change averaging method for axes with point data
%
% Input:
% ------
%   obj     Input object or array of objects to be rebinned
%   descr   Description of new bin boundaries (one per axis)
%           - [], '' or zero:       Leave bins unchanged
%           - dx (numeric scalar)   New bins centred on zero with constant width dx
%           - [xlo,xhi]             Change limits but bin boundaries in between unchanged
%           - [xlo,dx,xhi]          Lower and upper limits xlo and xhi, with intervening bins
%                                       dx>0    constant bins within the range
%                                       dx<0    logarithmic bins within the range
%                                              (if dx1<0, then must have x1>0, dx2<0 then x2>0 ...)
%                                       dx=0    retain existing bins within the range
%           - [x1,dx1,x2,dx2...xn]  Generalisation to multiple contiguous ranges
%
%           The lower limit can be -Inf and/or the upper limit +Inf, when the
%           corresponding limit is set by the full extent of the data.
%  OR
%   wref    Reference IX_dataset_3d to provide new bins along all three axes
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
%   >> obj_out = rebin (obj, [],...)
%   >> obj_out = rebin (obj, 10,...)
%   >> obj_out = rebin (obj, [2000,3000],...)
%   >> obj_out = rebin (obj, [2000,Inf],...)
%   >> obj_out = rebin (obj, [2000,10,3000],...)
%   >> obj_out = rebin (obj, [5,-0.01,3000],...)
%   >> obj_out = rebin (obj, [5,-0.01,1000,20,4000,50,20000],...)
%
% See also corresponding function rebin2 which accepts a set of bin boundaries
% of form [x1,x2,x3,...xn] instead of a rebin descriptor


array_is_descriptor = true;
obj_out = rebin_ (obj, 1:3, array_is_descriptor, varargin{:});
