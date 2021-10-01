function xyz_distribution_ = check_and_set_x_distribution_(val, iax)
% Set distribution flag for one or more axes
%
%   >> xyz_distribution_ = check_and_set_x_distribution_(val, iax)
%
% Input:
% ------
%   val     Distribution flags:
%           - logical true or false, or 1 or 0 (if setting a single axis)
%           - Logical array (or arry of ones or zeros) (if setting
%             more than one axis)
%           - Cell array of logical scalars (i.e. true or false, 
%             or 1 or 0), one per axis
%
%           If val is empty for an axis, then the correspondng distribution
%           flag will be set to the default.
%
%   iax     Axis index. Assumed to be unique integers greater or equal to
%           one. One axis index per expected value. The number of expected
%           values is numel(iax).
%
% Output:
% -------
%   xyz_distribution_ Verified, and if necessary reformatted, distribution
%           information. Output is a logical row array


niax = numel(iax);

if ~isempty(val)
    % Fill axis or axes with provided values
    if numel(val)==niax
        xyz_distribution_ = false(1,niax);
        if iscell(val)
            for i=1:niax
                xyz_distribution_(i) = check_and_set_x_distribution_single_ ...
                    (val{i}, iax(i));
            end
        else
            for i=1:niax
                xyz_distribution_(i) = check_and_set_x_distribution_single_ ...
                    (val(i), iax(i));
            end
        end
    else
        error('HERBERT:check_and_set_x_distribution_:invalid_argument',...
            ['Distribution values must be a vector length %s of true or',...
            ' false (or 1 or 0)\nor a cell array of logical scalars'],...
            num2str(niax));
    end
else
    % Fill axis or axes with the default
    xyz_distribution_def = check_and_set_x_distribution_single_ ([], 1);
    xyz_distribution_ = repmat(xyz_distribution_def, 1, niax);
end


%--------------------------------------------------------------------------
function xyz_distribution_ = check_and_set_x_distribution_single_ (val, iax)
% Set distribution flag for a single axis
%
%   >> xyz_distribution_ = check_and_set_x_distribution_single_ (val, iax)
%
% Input:
% ------
%   val     Distribution flag: logical true or false (or 1 or 0)
%   iax     Axis index, assumed to be a scalar in range 1,2,... ndim()
%           If val is empty, then the distribution flag will be set to the
%           default.
%
% Output:
% -------
%   xyz_distribution_ Verified, and if necessary reformatted, distribution
%           information. 

if ~isempty(val)
    if islognumscalar(val)
        xyz_distribution_ = logical(val);
    else
        error('HERBERT:check_and_set_x_distribution_:invalid_argument',...
            ['Axis ', num2str(iax), ': distribution flag must be a logical scalar']);
    end
    
else
    xyz_distribution_ = true;  % default
end
