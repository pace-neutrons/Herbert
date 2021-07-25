function obj = check_and_set_x_(obj, val, iax)
% Set axis coordinates for a single axis
%
%   >> obj = check_and_set_x_(obj, val, iax)
%
% Input:
% ------
%   obj     IX_dataset object
%   val     Axis coordinates: numeric row vector
%               - all elements finite (i.e. no -Inf, Inf or NaN)
%               - monotonically increasing 
%   iax     Axis index, assumed to be a scalar in range 1,2,... ndim()
%
% Output:
% -------
%   obj     Updated object


% if isempty(val) || (numel(size(val))==2 && all(size(val)==[0,0]))
%     % *** val == [0,0] should be valid??
if ~isempty(val)
    if isnumeric(val) && isvector(val)
        if size(val,1)==1
            obj.xyz_{iax} = double(val(:));   % make column vector
        else
            obj.xyz_{iax} = double(val);
        end
    else
        error('HERBERT:check_and_set_x_:invalid_argument',...
            ['Axis ', num2str(iax), ': values must be a numeric vector']);
    end
    
    if ~all(isfinite(val))
        error('HERBERT:check_and_set_x_:invalid_argument',...
            ['Axis ', num2str(iax),...
            ': values must all be finite (i.e. cannot be -Inf,  Inf or NaN)']);
    end
    
    if any(diff(val)<0)
        error('HERBERT:check_and_set_x_:invalid_argument',...
            ['Axis ', num2str(iax),...
            ': values or histogram bin boundaries must be monotonically increasing']);
    end
    
else
    obj.xyz_{iax} = zeros(0,1);     % default: length zero
end
