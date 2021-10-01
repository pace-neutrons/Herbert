function [obj, ME] = isvalid (obj)
% Check consistency of properties
%
%   >> obj = isvalid (obj)          % throws error if onput not valid object
%   >> [obj, ME] = isvalid (obj)    % return with error message if not valid
%
% Input:
% ------
%   obj     Object to be validated
% 
% Output:
% -------
%   obj     Output object, where properties may have different format to
%           comply with class requirements (e.g. row vectors turned into
%           column vector or vice versa as required by the class)
%
%   ME      Empty character array if valid object (after any reformatting)
%           MException object if an error


if ~obj.valid_
    try
        obj = check_properties_consistency_(obj);
        ME = '';
    catch ME
        if nargout < 2
            rethrow (ME)
        end
    end
end
