function signal_ = check_and_set_signal_ (val)
% Set signal array
%
%   >> signal_ = check_and_set_signal_ (val)
%
% Input:
% ------
%   val     Signal array
%
% Output:
% -------
%   signal_ Verified signal


% Leave the check of consistency of extent along each dimension to a
% method that performs checks that cut across properties
if isnumeric(val)
    if isa(val,'double')
        signal_ = val;
    else
        signal_ = double(val);
    end
else
    error('HERBERT:check_and_set_signal_:invalid_argument',...
        'Signal must be a numeric array');
end
