function [nd, sz] = dimensions(obj)
% Return number of dimensions and extent along each dimension.
%
%   >> [nd, sz] = dimensions(obj)
%
% Input:
% ------
%   obj     IX_dataset_3d object
%
% Output:
% -------
%   nd      Dimensionality of the object
%   sz      Extend along each of the dimensions (row vector length nd)


[nd, sz] = dimensions_(obj);
