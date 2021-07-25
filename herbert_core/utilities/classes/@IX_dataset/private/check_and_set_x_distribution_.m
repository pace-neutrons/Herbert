function obj = check_and_set_x_distribution_(obj, val, iax)
% Set distribution flag for a single axis
%
%   >> obj = check_and_set_x_distribution_(obj, val, iax)
%
% Input:
% ------
%   obj     IX_dataset object
%   val     Distribution flag: logical true or false (or 0 or 1) 
%   iax     Axis index, assumed to be a scalar in range 1,2,... ndim()
%
% Output:
% -------
%   obj     Updated object

if ~isempty(val)
    if islognumscalar(val)
        obj.xyz_distribution_(iax) = logical(val);
    else
        error('HERBERT:check_and_set_x_distribution_:invalid_argument',...
            ['Axis ', num2str(iax), ': distribution flag must be a logical scalar']);
    end
    
else
    obj.xyz_distribution_(iax) = true;  % default
end
