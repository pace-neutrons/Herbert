function d=get_xsigerr(w)
% OBSOLETE: Get the x-axis, signal and error arrays, together with distribution flags
%
%**************************************************************************
% 2021-12-31:
%
% This method is now obsolete. Please replace with
%   >> d = axis(obj)        % structure with axis and distribution information
%   >> signal = w.signal;   % signal array
%   >> err = w.error;       % error array
%
%**************************************************************************
%
%   >> d=get_xsigerr(w)
%
% Input:
% -----
%   w       IX_dataset_2d or array of IX_dataset_2d
%
% Output:
% -------
%   d       Structure or stucture array with same size and shape as the array of IX_dataset_2d
%           Field for ith dataset are
%               d(i).x              Cell array of arrays containing the x axis baoundaries or points
%               d(i).signal         Signal array
%               d(i).err            Array of standard deviations
%               d(i).distribution   Array of elements, one per axis, that is true if a distribution, false if not


classname = class(w);
error ('HERBERT:get_xsigerr:obsolete', ['This function is now obsolete.',...
    'Type ''doc ', classname, '/get_xsigerr'' for more information'])
