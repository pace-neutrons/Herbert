function keyval = parse_keyval (keywords, varargin)
% Parse keyword-argument list of form: key1, val1, key2, val2, ...
%
%   >> val = parse_keyval (keywords, varargin)
%   >> val = parse_keyval (keywords, defaults, key1, val1, key2, val2, ...)
%
% Input:
% ------
%   keywords        Cell array of strings containing valid keywords
%
%   defaults        Cell array with default values for keywords that do not
%                   appear in the list of arguments that follows.
%                   If not given, then default values are all [].
%                   [Optional argument - its presence/absence is determined
%                    by the total number of input arguments being even/odd]
%
%   key1, key2, ... Keywords. Unambiguous abbreviations are accepted
%   val1, val2, ... Associated values
%
% Output:
% -------
%   keyval          Cell array with values of keywords. If a keyword is not
%                   present, then the value is set to []
%
% This is a simple parsing utility function for a common task that attempts
% to be fast by avoiding packaging output in a structure or cell array.


narg=numel(varargin);

if narg>=1 && iscell(varargin{1}) && numel(varargin{1})==numel(keywords)
    % Default values must have been provided
    keyval = varargin{1}(:)';
    offset = 1;
else
    % No default values - use the default default
    keyval = cell(1, numel(keywords));
    offset = 0;
end

if rem(narg-offset,2)~=0
    error('HERBERT:parse_keyval:invalid_argument',...
        'Check number of arguments follows the form key1, val1, key2, val2, ...');
end

keyword_appeared = false(1, numel(keywords));
for i = 1:narg/2
    name = varargin{2*i-1+offset};
    ind = find(strncmpi(name, keywords, numel(name)));
    if numel(ind)>1 % more than one match, see if can find an exact length match
        ind = find(strcmpi(name,keywords));
        if isempty(ind)
            error('HERBERT:parse_keyval:invalid_argument',...
                'Ambiguous abbreviation of a keyword - check input arguments');
        elseif numel(ind)>1
            error('HERBERT:parse_keyval:invalid_argument',...
                'List of keywords is in error - problem in caller function');
        end
    end
    if numel(ind)==1
        if ~keyword_appeared(ind)
            keyval{ind} = varargin{2*i+offset};
            keyword_appeared(ind) = true;
        else
            error('HERBERT:parse_keyval:invalid_argument',...
                'Keyword ''%s'' appears more than once - check input', keywords{ind});
        end
    elseif isempty(ind)
        error('HERBERT:parse_keyval:invalid_argument',...
            'Unrecognised keyword ''%s'' - check input', name);
    end
end
