function obj = check_and_set_x_ (obj, val, iax)
% Set axis coordinates for one or more axes
%
%   >> obj = check_and_set_x_ (obj, val, iax)
%
% Input:
% ------
%   obj     IX_dataset object.
%
%   val     Axis coordinates: numeric vector, or cell array of numeric
%           vectors, one per axis.
%           For each axis:
%               - all elements finite (i.e. no -Inf, Inf or NaN)
%               - monotonically increasing
%           If val is empty for an axis, then the corresponding axis
%           coordinates will be set to the default.
%
%   iax     Axis index (assumed to be a scalar in range 1,2,... ndim()), or
%           array of axis indices (assumed to have unique elements), one
%           element per axis.
%
% Output:
% -------
%   obj     Updated object.
%           Axis coordinates are a row cell array of numeric row vectors

nd = numel(iax);

if ~isempty(val)
    % Fill axis or axes with provided values
    if isnumeric(val) && nd==1
        obj = check_and_set_x_single_ (obj, val, iax);
    elseif iscell(val) && numel(val)==nd
        for i=1:nd
            obj = check_and_set_x_single_ (obj, val{i}, iax(i));
        end
    else
        error('HERBERT:check_and_set_x_:invalid_argument',...
            'Axis values must be a cell array of %s numeric vectors',...
            num2str(nd));
    end
else
    % Fill axis or axes with the default
    for i=1:nd
        obj = check_and_set_x_single_ (obj, [], iax(i));
    end
end


%--------------------------------------------------------------------------
function obj = check_and_set_x_single_ (obj, val, iax)
% Set axis coordinates for a single axis
%
%   >> obj = check_and_set_x_single_ (obj, val, iax)
%
% Input:
% ------
%   obj     IX_dataset object
%   val     Axis coordinates: numeric vector
%               - all elements finite (i.e. no -Inf, Inf or NaN)
%               - monotonically increasing
%           If val is empty, then axis coordinates will be set to the
%           default
%   iax     Axis index (assumed to be a scalar in range 1,2,... ndim())
%
% Output:
% -------
%   obj     Updated object


if ~isempty(val)
    if isnumeric(val) && isvector(val)
        if size(val,2)==1
            obj.xyz_{iax} = double(val');   % make row vector
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
    
else
    obj.xyz_{iax} = zeros(1,0);     % default: length zero row vector
end
