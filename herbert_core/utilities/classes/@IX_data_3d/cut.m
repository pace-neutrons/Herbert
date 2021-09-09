function obj_out = cut (obj, varargin)
% Make a cut from an IX_dataset_3d object or array of IX_dataset_3d objects along the x-,y- and z-axes
%
%   >> obj_out = cut (obj, descr_x, descr_y, descr_z)
%   >> obj_out = cut (obj, wref)             % reference object to provide output bins
%   
%   >> obj_out = cut (..., 'int')            % change averaging method for axes with point data
%   
% Input:
% ------
%   obj     Input object or array of objects to be cut
%   descr   Description of new bin boundaries (one per axis)
%           - [], '' or zero:       Leave bins unchanged
%           - dx (numeric scalar)   New bins centred on zero with constant width dx
%           - [xlo,xhi]             Single bin
%           - [xlo,dx,xhi]          Set of equal width bins centred at xlo, xlo+dx, xlo+2*dx,...
%
%           The lower limit can be -Inf and/or the upper limit +Inf, when the 
%           corresponding limit is set by the full extent of the data.
%  OR
%   wref    Reference IX_dataset_3d to provide new bins along all three axes
%
%   Point data: for an axis with point data (as opposed to histogram data)
%   'ave'   average the values of the points within each new bin (DEFAULT)
%   'int'   integate the function defined by linear interpolation between the data points
%
% Output:
% -------
%   obj_out    Output object or array of objects
%           If just one bin was specified along an axis, i.e. gave just upper and
%          lower limits, then the output object has dimension reduced by one.
%
% EXAMPLES
%   >> obj_out = cut (obj, [],...)
%   >> obj_out = cut (obj, [-Inf,Inf],...)    % equivalent to above
%   >> obj_out = cut (obj, 10,...)
%   >> obj_out = cut (obj, [2000,3000],...)
%   >> obj_out = cut (obj, [2000,Inf],...)
%   >> obj_out = cut (obj, [2000,3000,4000,5000,6000],...)
%
% Cut is similar to rebin, except that any axes that have just one bin reduce the
% dimensionality of the output object by one, and the rebin descriptor defines
% bin centres, not bin boundaries.


array_is_descriptor = true;
obj_out = cut_ (obj, 1:3, array_is_descriptor, varargin{:});
