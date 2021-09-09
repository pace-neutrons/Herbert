% Convert histogram <object> object or array to point object(s).
%
%   >> obj_out = <method> (obj)        % convert all axes
%   >> obj_out = <method> (obj, iax)   % convert given axis or axes
%
% Any point data axes are left unchanged.
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
%   obj_out <object> object or array of objects with histogram axes
%           converted to point axes
%
%
% Notes:
% Histogram datasets are converted to distribution as follows:
%       Histogram distribution => Point data distribution;
%                                 Signal numerically unchanged
%
%             non-distribution => Point data distribution;
%                                 Signal converted to signal per unit axis
%                                 length
%
% Histogram data is always converted to a distribution: it is assumed that
% point data represents the sampling of a function at a series of points,
% and histogram non-distribution data is not consistent with that.
