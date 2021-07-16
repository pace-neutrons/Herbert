function obj = check_and_set_signal_(obj, val)
% Set signal array
%
%   >> obj = check_and_set_signal_(obj, val)
%
% Input:
% ------
%   obj     IX_dataset object
%   val     Signal array
%
% Output:
% -------
%   obj     Updated object


% Leave the check of consistency of extent along each dimension to a
% method that performs checks that cut across properties
if isnumeric(val)
    if isa(val,'double')
        obj.signal_ = val;
    else
        obj.signal_ = double(val);
    end
else
    error('HERBERT:check_and_set_signal_:invalid_argument',...
        'Signal must be a numeric array');
end
