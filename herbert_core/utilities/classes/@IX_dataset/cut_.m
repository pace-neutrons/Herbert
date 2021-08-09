function wout = cut_(win, iax, array_is_descriptor, varargin)
% Make a cut from an IX_dataset object or array of IX_dataset objects
%
%   >> wout = cut_ (win, iax, descr1, descr2,...)
%   >> wout = cut_ (win, iax, wref)
%
% Set averaging method for point data:
%   >> wout = cut_ (..., '-int')
%   >> wout = cut_ (..., '-ave')
%
% Input:
% ------
%   win     Input object or array of objects
%
%   iax     Index of axis, or array of axes indices, along which to cut
%
%   descr   Description of new bin boundaries. For each of the axes in iax
%           specify the new bin boundaries:
%           - 0 (or empty e.g. [])  Leave bins unchanged
%           - dx (numeric scalar)   New bins centred on zero with constant
%                                  width dx
%           - [xlo, xhi]            Single bin
%           - [xlo, dx, xhi]        Set of equal width bins centred at 
%                                  xlo, xlo+dx, xlo+2*dx,...
%
%           The lower limit can be -Inf and/or the upper limit +Inf, when the
%           corresponding limit is set by the full extent of the data.
% *OR*
%   wref    Reference IX_dataset to provide new bins along specified axes
%
% [Optional]
%   For an axis with point data (as opposed to histogram data), specify
%   how the new signal for a bin is to be calculated:
%
%   'ave'   Average the values of the points within each new bin (DEFAULT)
%   'int'   Integrate the function defined by linear interpolation between
%           the data points along each axis
%
% Output:
% -------
%   wout    Output object or array of objects
%
% NOTE:     If just one bin was specified along an axis, e.g. gave binning
%           descriptor [xlo, xhi], then the output object has dimension
%           reduced by one.
%
% EXAMPLES
%   >> wout = cut_xyz (win, iax, [])            % Cut extends over the full range
%                                               % of data for iax
%   >> wout = cut_xyz (win, iax, [-Inf,Inf])    % Equivalent to above
%   >> wout = cut_xyz (win, iax, 10)            % Boundaries [...,-15,-5,5,15,...]
%   >> wout = cut_xyz (win, iax, [2000,3000])
%   >> wout = cut_xyz (win, iax, [2000,Inf])
%   >> wout = cut_xyz (win, iax, [2000,3000,4000,5000,6000])
%
% Cut is similar to rebin, except that any axes that have just one bin reduce the
% dimensionality of the output object by one, and the rebin descriptor defines
% bin centres, not bin boundaries.


% Benign return if no arguments
if nargin==1
    wout=win;
    return
end     

% Call master rebin method
config.integrate_data = false;

config.point_average_method_default = 'average';

config.descsriptor_opts = struct(...
    'empty_is_one_bin',     false,...
    'range_is_one_bin',     true,...
    'array_is_descriptor',  array_is_descriptor,...
    'values_are_boundaries',false);

wout = rebin_IX_dataset_(win, iax, config, varargin{:});


% Squeeze object(s)
wout=wout.squeeze_IX_dataset(iax);  % *** check
