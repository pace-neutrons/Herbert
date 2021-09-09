function obj_out = rebin_(obj, iax, array_is_descriptor, varargin)
% Rebin an IX_dataset object or array of IX_dataset objects along all axis
%
%   >> wout = rebin (win)       % benign - output is the same as input
%
%   >> wout = rebin (win, iax, array_is_descriptor, descr1, descr2,...)
%   >> wout = rebin (win, array_is_descriptor, descr, 'int')
%
% Input:
% ------
%   win     Input object or array of objects to be rebinned
%
%   iax     Axis or axes to rebin. Must be unique integers in the range
%           1,2...ndim, wheren ndim is the dimensionality of the object(s)
%
%   array_is_descriptor
%           If true, then the following boundary descriptors are used to
%           generate the bin boundaries
%           If false, then the boundary descriptors are simply the bin
%           boundaries
%
%   descr   Description of new bin boundaries
%           if array_is_descriptor==true:
%
%   *** if cut:
%           - 0 (or empty e.g. [])  Leave bins unchanged
%           - dx (numeric scalar)   New bins centred on zero with constant
%                                  width dx
%           - [xlo, xhi]            Single bin
%           - [xlo, dx, xhi]        Set of equal width bins centred at 
%                                  xlo, xlo+dx, xlo+2*dx,...
%
%
%           - 0 (or empty e.g. [],''):       Leave bins unchanged
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
% 
%           If array_is_descriptor==false:
%           - [x1,x2,...x(n+1)]     The bin boundaries, monotonically
%                                   increasing
%
%   Point data: for an axis with point data (as opposed to histogram data)
%   'ave'   average the values of the points within each new bin (DEFAULT)
%   'int'   average of the function defined by linear interpolation between the data points
%
% Output:
% -------
%   wout    Output object or array of objects
%
% EXAMPLES
%   >> wout = rebin (win, [])
%   >> wout = rebin (win, 10)
%   >> wout = rebin (win, [2000,3000])
%   >> wout = rebin (win, [2000,Inf])
%   >> wout = rebin (win, [2000,10,3000])
%   >> wout = rebin (win, [5,-0.01,3000])
%   >> wout = rebin (win, [5,-0.01,1000,20,4000,50,20000])
%
% See also corresponding function rebin2 which accepts a set of bin boundaries
% of form [x1,x2,x3,...xn] instead of a rebin descriptor


% Benign return if no arguments
if nargin==1
    obj_out = obj;
    return
end     

% Call master rebin method
config.integrate_data = false;

config.point_average_method_default = 'average';

config.bin_opts = struct (...
    'empty_is_one_bin',     false,...
    'range_is_one_bin',     false,...
    'array_is_descriptor',  array_is_descriptor,...
    'values_are_boundaries',true);

obj_out = rebin_IX_dataset_ (obj, iax, config, varargin{:});
