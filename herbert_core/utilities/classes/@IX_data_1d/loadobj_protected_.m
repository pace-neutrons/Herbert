function obj = loadobj_protected_ (obj, S)
% Function to support loading of outdated versions of the class from mat files
%
%   >> obj = loadobj_protected_ (obj, S)
%
% Input:
% ------
%   obj     Scalar instance of the class
%   S       Structure (scalar). This will have been returned by the Matlab
%           intrinsic load function
%
% Output:
% -------
%   obj     Scalar instance of the class with updated properties


try
    % 2017-2021: .mat file format where private properties are saved
    obj = init (obj, S.title_, S.signal_, S.error_, S.s_axis_,...
        S.xyz_, S.xyz_axis_, S.xyz_distribution_);
catch
    % Assume pre-2017 .mat format of saved public properties
    obj = init (obj, S.title, S.signal, S.error, S.s_axis,...
        S.x, S.x_axis, S.x_distribution);
end
