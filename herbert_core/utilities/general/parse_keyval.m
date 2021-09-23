function keyval = parse_keyval (keywords, varargin)
% Simple verification that argument list has form: key1, val1, key2, val2, ...
%
%   >> keyval = parse_keyval (keywords, varargin)
%
% Input:
% ------
%   keywords        Cell array of strings containing valid keywords
%   key1, key2, ... Keywords. Unambiguous abbreviations are accepted
%   val1, val2, ... Associated values
%
% Output:
% -------
%   keyval          Structure with fields equal to the keywords and values
%                   given in the argument list. If a keyword did not appear
%                   its value is set to []


keyval = cell2struct(repmat({[]}, numel(keywords), 1), keywords(:));

narg=numel(varargin);
if rem(narg,2)~=0
    error('HERBERT:parse_keyval:invalid_argument',...
        'Check number of arguments follows the form key1, val1, key2, val2, ...');
end

keyword_appeared = false(1, numel(keywords));
for i = 1:narg/2
    name = varargin{2*i-1};
    ind = find(strncmpi(name, keywords, numel(name)));
    if numel(ind)>1 % more than one match, see if can find an exact length match
        ind = find(strcmpi(name,keywords));
        if isempty(ind)
            error('HERBERT:parse_keyval:invalid_argument',...
                'Ambiguous abbreviation of a keyword - check input arguments');
        elseif numel(ind)>1
            error('HERBERT:parse_keyval:invalid_argument',...
                'List of keywords is in error - problem in calling program');
        end
    end
    if numel(ind)==1
        if ~keyword_appeared(ind)
            keyval.(keywords{ind}) = varargin{2*i};
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
