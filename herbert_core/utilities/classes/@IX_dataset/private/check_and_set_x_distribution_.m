function obj = check_and_set_x_distribution_(obj, val, iax)
% Set distribution flag for one or more axes
%
%   >> obj = check_and_set_x_distribution_(obj, val, iax)
%
% Input:
% ------
%   obj     IX_dataset object.
%
%   val     Distribution flags: array of logical true or false (or 0 or 1)
%           or cell array of logical scalars, one per axis.
%           If val is empty for an axis, then the correspondng distribution
%           flag will be set to the default.
%
%   iax     Axis index (assumed to be a scalar in range 1,2,... ndim()), or
%           array of axis indices (assumed to have unique elements), one
%           element per axis.
%
% Output:
% -------
%   obj     Updated object

nd = numel(iax);

if ~isempty(val)
    % Fill axis or axes with provided values
    if numel(val)==nd
        if iscell(val)
            for i=1:nd
                obj = check_and_set_x_distribution_single_ (obj, val{i}, iax(i));
            end
        else
            for i=1:nd
                obj = check_and_set_x_distribution_single_ (obj, val(i), iax(i));
            end
        end
    else
        error('HERBERT:check_and_set_x_distribution_:invalid_argument',...
            ['Distribution values must be a vector length %s of true or',...
            ' false (or 0 or 1)\nor a cell array of logical scalars'],...
            num2str(nd));
    end
else
    % Fill axis or axes with the default
    for i=1:nd
        obj = check_and_set_x_distribution_single_ (obj, [], iax(i));
    end
end


%--------------------------------------------------------------------------
function obj = check_and_set_x_distribution_single_ (obj, val, iax)
% Set distribution flag for a single axis
%
%   >> obj = check_and_set_x_distribution_single_ (obj, val, iax)
%
% Input:
% ------
%   obj     IX_dataset object
%   val     Distribution flag: logical true or false (or 0 or 1) 
%   iax     Axis index, assumed to be a scalar in range 1,2,... ndim()
%           If val is empty, then the distribution flag will be set to the
%           default.
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
