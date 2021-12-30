% Convert point <object> object or array to histogram object(s).
%
%   >> obj_out = <method> (obj)        % convert all axes
%   >> obj_out = <method> (obj, iax)   % convert given axis or axes
%
% Any histogram data axes are left unchanged.
%
% Input:
% -------
%   obj     <object> object or array of objects
%
%   iax     [optional] axis index, or array of indicies, in range 1 to <ndim>
%           Default: 1:<ndim>
%
% Output:
% -------
%   obj_out <object> object or array of objects with point axes
%           converted to histogram axes
%
%
% Notes:
% Point datasets are converted to distributions as follows:
%       Point distribution => Histogram distribution;
%                             Signal numerically unchanged
%
%         non-distribution => Histogram distribution;
%                             Signal numerically unchanged
%                             *** NOTE: The signal caption will be plotted
%                               incorrectly if units are given in the axis 
%                               description of the point data
%
% Point data is always converted to a distribution: it is assumed that
% point data represents the sampling of a function at a series of points,
% and only a histogram as a distribution is consistent with that.
