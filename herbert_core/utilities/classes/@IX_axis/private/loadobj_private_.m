function obj = loadobj_private_(S)
% Function to support loading of outdated versions of the class from mat files
%
%   >> obj = loadobj_private_(S)
%
% Input:
% ------
%   S       Structure (scalar). This will have been returned by the Matlab
%           intrinsic load function
%
% Output:
% -------
%   obj     Scalar instance of the class

try
    % Assume older format of saved data that includes public properties
    obj = IX_axis (S.caption, S.units, S.code, S.ticks);
    
catch
    % Assume the structure contains public properties. This really is a 
    % last chance saloon if the above has not been recognised!
    obj = IX_axis();    % Create default instance
    nams = fieldnames(S);
    for i=1:numel(nams)
        nam = nams{i};
        obj.(nam) = S.(nam);
    end
end
