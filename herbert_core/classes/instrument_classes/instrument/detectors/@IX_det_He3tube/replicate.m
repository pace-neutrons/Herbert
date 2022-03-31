function obj_out = replicate (obj, n)
% Replicate detector elements to make n-fold larger detector array
% or reverse replication - get single object out of replicated one.
% The first values will be used for reverse replication.
%
%   >> obj_out = replicate (obj, n)
%
% Input:
% ------
%   obj         Input object
%   n           Number of times to replicate the detectors
%               If n<0, replace replicated items with first element.
%
% Output:
% -------
%   obj_out     Output array such that all internal data has been
%               repeated n times, increasing the nmber of detectors by a
%               factor of n
%               If n<1, reduce size to one item per property


% Replicate the detector arrays
if n<0
    obj_out = obj;
    obj_out.dia_    = obj.dia_(1);
    obj_out.height_ = obj.height_(1);
    obj_out.wall_   = obj.wall_(1);
    obj_out.atms_   = obj.atms_(1);
else
    obj_out = obj;
    obj_out.dia_    = repmat(obj.dia_,[n,1]);
    obj_out.height_ = repmat(obj.height_,[n,1]);
    obj_out.wall_   = repmat(obj.wall_,[n,1]);
    obj_out.atms_   = repmat(obj.atms_,[n,1]);
end