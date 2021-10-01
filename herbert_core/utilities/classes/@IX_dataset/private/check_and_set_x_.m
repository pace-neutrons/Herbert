function xyz_ = check_and_set_x_ (val, iax)
% Set axis coordinates for all axes
%
%   >> xyz_ = check_and_set_x_ (val)
%
% Input:
% ------
%   val     Axis coordinates: numeric vector, or cell array of numeric
%           vectors, one per axis.
%           For each axis:
%               - all elements finite (i.e. no -Inf, Inf or NaN)
%
%           If val is empty for an axis, then the corresponding axis
%           coordinates will be set to the default.
%
%   iax     Axis index. Assumed to be unique integers greater or equal to
%           one. One axis index per expected value. The number of expected
%           values is numel(iax).
%
% Output:
% -------
%   xyz_    Verified, and if necessary reformatted, axis coordinates
%           Output is a row cell array of numeric row vectors


niax = numel(iax);

if ~isempty(val)
    % Fill axis or axes with provided values
    if isnumeric(val) && niax==1
        % Single numerical array - must be one dimension
        xyz_ = {check_and_set_x_single_(val, iax)};
        
    elseif iscell(val) && numel(val)==niax
        xyz_ = cell(1, niax);
        for i=1:niax
            xyz_{i} = check_and_set_x_single_ (val{i}, iax(i));
        end
    else
        if niax==1
            error('HERBERT:check_and_set_x_:invalid_argument',...
                ['Axis values must be a numeric array (or a cell array ',...
                'with a single numeric vector)'])
        else
            error('HERBERT:check_and_set_x_:invalid_argument',...
                'Axis values must be a cell array of %s numeric vectors',...
                num2str(niax));
        end
    end
else
    % Fill axis or axes with the default for zero number of axes
    xyz_def = check_and_set_x_single_ ([], 1);
    xyz_ = repmat(xyz_def, 1, niax);
end


%--------------------------------------------------------------------------
function x_ = check_and_set_x_single_ (val, iax)
% Set axis coordinates for a single axis
%
%   >> x_ = check_and_set_x_single_ (val, iax)
%
% Input:
% ------
%   val     Axis coordinates: numeric vector
%               - all elements must be finite (i.e. no -Inf, Inf or NaN)
%           If val is empty, then axis coordinates will be set to the
%           default
%   iax     Axis index (assumed to be a scalar in range 1,2,... ndim())
%
% Output:
% -------
%   x_      Verified, and  if necessary reformated, axis coordinates


if ~isempty(val)
    if isnumeric(val) && isvector(val)
        if size(val,2)==1
            x_ = double(val');   % make row vector
        else
            x_ = double(val);
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
    x_ = zeros(1,0);     % default: length zero row vector
end
