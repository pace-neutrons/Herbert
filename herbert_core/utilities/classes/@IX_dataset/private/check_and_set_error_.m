function obj = check_and_set_error_(obj, val)
% Set error array
%
%   >> obj = check_and_set_error_(obj, val)
%
% Input:
% ------
%   obj     IX_dataset object
%   val     Error array - standrad deviations
%
% Output:
% -------
%   obj     Updated object. Any negative values of error will be made
%           positive


% Leave the check of consistency of extent along each dimension to a
% method that performs checks that cut across properties
if isnumeric(val)
    if isa(val,'double')
        obj.error_ = abs(val);
    else
        obj.error_ = abs(double(val));
    end
else
    error('HERBERT:check_and_set_error_:invalid_argument',...
        'Error (i.e. standard deviations) must be a numeric array');
end
