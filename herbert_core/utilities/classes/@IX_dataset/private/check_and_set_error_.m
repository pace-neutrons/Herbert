function error_ = check_and_set_error_ (val)
% Set error array
%
%   >> error_ = check_and_set_error_ (val)
%
% Input:
% ------
%   val     Error array - standard deviations
%
% Output:
% -------
%   error_  Error array verified, and negative values made positive


% Leave the check of consistency of extent along each dimension to a
% method that performs checks that cut across properties
if isnumeric(val)
    if isa(val,'double')
        error_ = abs(val);
    else
        error_ = abs(double(val));
    end
else
    error('HERBERT:check_and_set_error_:invalid_argument',...
        'Error (i.e. standard deviations) must be a numeric array');
end
