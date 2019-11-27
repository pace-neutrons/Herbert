function obj_out = replicate (obj, n)
% Replicate detector elements to make n-fold larger detector array
%
%   >> obj_out = reorder (obj, n)
%
% Input:
% ------
%   obj         Input object
%   n           Number of times to replicate the detectors
%
% Output:
% -------
%   obj_out     Output array such that all internal data has been
%               repeated n times, increasing the nmber of detectors by a
%               facator of n


% Replicate the detector arrays
obj_out = obj;
obj_out.dia_    = repmat(obj.dia_,[n,1]);
obj_out.height_ = repmat(obj.height_,[n,1]);
obj_out.wall_   = repmat(obj.wall_,[n,1]);
obj_out.atms_   = repmat(obj.atms_,[n,1]);