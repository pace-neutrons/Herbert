function obj = loadobj_private_(S)
% Function to support loading of outdated versions of the class from mat files
%
%   >> obj = loadobj_private_(S)
%
% Input:
% ------
%   S       Structure (scalar). This will have been returned by the Matlab
%           instrinsic load function
%
% Output:
% -------
%   obj     Scalar instance of the class

obj = IX_axis();    % Create default instance

% Assume the structure contains public properties
nams = fieldnames(S);
for i=1:numel(nams)
    nam = nams{i};
    obj.(nam) = S.(nam);
end
