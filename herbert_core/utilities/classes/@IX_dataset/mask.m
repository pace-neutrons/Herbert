function obj_out = mask (obj, mask_array)
% Remove the data points indicated by the mask array
%
%   >> obj_out = mask (obj, mask_array)
%
% Input:
% ------
%   obj             Input dataset
%
%   mask_array      Array of 1 or 0 (or true or false) that indicate
%                  which points to retain (true to retain, false to mask)
%                   Numeric or logical array with same number of elements
%                  as the signal array.
%                   You can determine the size of the signal array by
%                       >> size(obj.signal)
% Output:
% -------
%   obj_out         Output dataset. Masked points have signal and error set
%                  to NaN.


% Initialise output argument
obj_out = obj;

% Trivial case of empty or no mask arguments
if nargin==1 || isempty(mask_array)
    return
end

% Check mask is OK
if ~(isnumeric(mask_array) || islogical(mask_array)) ||...
        numel(mask_array)~=numel(obj.signal)
    error('HERBERT:mask:invalid_argument', ['Mask must be a numeric ',...
        'or logical array with same number of elements as the signal'])
end
if ~islogical(mask_array)
    mask_array = logical(mask_array);
end

% Mask signal and error arrays
obj_out.signal(~mask_array) = NaN;
obj_out.error(~mask_array) = NaN;
