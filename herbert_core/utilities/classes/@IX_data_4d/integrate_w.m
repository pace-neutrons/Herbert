function obj_out = integrate_w (obj, varargin)
% Integrate an IX_dataset_3d object or array of IX_dataset_3d objects along the z-axis
%
%   >> obj_out = integrate_z (obj, descr)
%   >> obj_out = integrate_z (obj, wref)           % reference object to provide output bins
%
%   >> obj_out = integrate_z (..., 'ave')          % change integration method for point data
%   
% Input:
% ------
%   obj     Input object or array of objects to be integrated
%   descr   Description of integration bin boundaries 
%
%           Integration is performed fo each bin defined in the description:
%           * If just one bin is specified, i.e. give just upper an lower limits,
%            then the dataset is integrated over the specified range.
%             The integrate axis disappears i.e. the output object has one less dimension.
%           * If several bins are defined, then the integral is computed for each
%            bin. Essentially, this is rebinning with integration of the contents.
%
%           General syntax for the description of new bin boundaries:
%           - [], ''                Integrate over the full range of the data
%           - 0                     Use current bins to define integration ranges
%           - dx (numeric scalar)   Integration bins centred on zero with constant width dx
%           - [xlo,xhi]             Single integration range
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
%   wref    Reference IX_dataset_3d to provide new bins along z axis
%
%   Point data: for an axis with point data (as opposed to histogram data)
%   'ave'   average the values of the points within each new bin and multiply by bin width
%   'int'   integate the function defined by linear interpolation between the data points (DEFAULT)
%
% Output:
% -------
%   obj_out    Output object or array of objects
%
% EXAMPLES
%   >> obj_out = integrate_z (obj)    % integrates entire dataset
%   >> obj_out = integrate_z (obj, [])
%   >> obj_out = integrate_z (obj, [-Inf,Inf])    % equivalent to above
%   >> obj_out = integrate_z (obj, 10)
%   >> obj_out = integrate_z (obj, [2000,3000])
%   >> obj_out = integrate_z (obj, [2000,Inf])
%   >> obj_out = integrate_z (obj, [2000,10,3000])
%   >> obj_out = integrate_z (obj, [5,-0.01,3000])
%   >> obj_out = integrate_z (obj, [5,-0.01,1000,20,4000,50,20000])
%
% See also corresponding function integrate2_z which accepts a set of bin boundaries
% of form [x1,x2,x3,...xn] instead of a rebin descriptor


array_is_descriptor = true;
obj_out = integrate_ (obj, 4, array_is_descriptor, varargin{:});
