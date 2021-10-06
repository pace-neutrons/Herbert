function flags = parse_flags (flagnames, varargin)
% Simple verification that argument list has form: flag1, flag2, flag3, ...
%
%   >> flags = parse_flags (flagnames, varargin)
%
% Input:
% ------
%   flagnames       Cell array of strings containing the keywords
%
%   flag1, flag2,...Present flagnames
%
% Output:
% -------
%   flags           Logical array with true where the flag is present,
%                   and false if not, in the order of the names in
%                   flagnames
%
% This is a simple parsing utility function for a common task that attempts
% to be fast by avoiding packaging output in a structure or cell array.
%
% To create a structure with fields given by the flagnames and values by
% the contents of flags:
%
%   >> flags = cell2struct (num2cell(flag_appeared), flagnames(:));


flags = false(1, numel(flagnames));
for i = 1:numel(varargin)
    name = varargin{i};
    ind = find(strncmpi(name, flagnames, numel(name)));
    if numel(ind)>1 % more than one match, see if can find an exact length match
        ind = find(strcmpi(name,flagnames));
        if isempty(ind)
            error('HERBERT:parse_flags:invalid_argument',...
                'Ambiguous abbreviation of a flagname - check input arguments');
        elseif numel(ind)>1
            error('HERBERT:parse_flags:invalid_argument',...
                'List of flagnames is in error - problem in calling program');
        end
    end
    if numel(ind)==1
        if ~flags(ind)
            flags(ind) = true;
        else
            error('HERBERT:parse_flags:invalid_argument',...
                'Flagname ''%s'' appears more than once - check input', flagnames{ind});
        end
    elseif isempty(ind)
        error('HERBERT:parse_flags:invalid_argument',...
            'Unrecognised keyword ''%s'' - check input', name);
    end
end
