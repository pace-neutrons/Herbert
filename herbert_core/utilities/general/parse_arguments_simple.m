function [par, val, present] = parse_arguments_simple (keywords, flags,...
    defaults, args)
% Parse argument list with keyword-value and optional flag names
%
%   >> [par, val, present] = parse_arguments_simple (keywords, flags,...
%                                                       defaults, args)
%
% The argument list to be parsed is the contents of the cell array 
% argument called 'args', and can have the general form:
%
%   {par1, par2, ... parN, keyword1, val1, keyword2, val2, ...}
%
% Keywords in the argumnet list can be shortened to the minimum unambiguous
% abbreviation.
%
% The default values for the keywords are contained in the argument called
% 'defaults'. Selected keywords can be defined as flags in the argument
% called 'flags'. These can only take the value true or false; the presence
% of the keyword without a following value defines its value as true, its
% absence means it takes the defaul value in 'defaults'.
%
% EXAMPLE
%   >> keywords = {'background', 'normalise', 'modulate'};
%   >> flags = [false, true, true];
%   >> defaults = {[12000,18000], true, false};
%           :
%   >> args = {'data.dat', [10:5:30], 'mod', 'back', [15000,19000]};
%   >> [par, val, present] = parse_arguments_simple (keywords, flags,...
%                                                           defaults, args)
% Results in:
%   par = {'data.dat', [10 15 20 25 30]}
% 
%   val = {[15000 19000], true, true}
% 
%   present = [true, false, true]
%
%
% Input:
% ------
%   keywords        Cell array of strings containing valid keywords and
%                   flag names.
%                   A keyword must be followed by a corresponding value.
%                   A flag can be given the value true or false (or 0 or 1);
%                   if the flag name is present but not followed by a value
%                   it takes the value true, otherwise it takes the value
%                   given in the defaults
%
%   flags           Logical array with same length as keywords with
%                   elements either true or false where the corresponding
%                   keyword is a logical flag or not
%
%   defaults        Cell array with default values for keywords that do not
%                   appear in the list of arguments that follows.
%                   If not given, then default values are all [].
%                   [Optional argument - its presence/absence is determined
%                    by the total number of input arguments being even/odd]
%
%   args            Arguments to be parsed. The general 
%   key1, key2, ... Keywords. Unambiguous abbreviations are accepted
%   val1, val2, ... Associated values
%
% Output:
% -------
%   par             Leading parameters that are not keyword-value pairs or
%                   logical flags
%
%   val             Cell array with values of keywords. If a keyword is not
%                   present, then the value is set to []
%
%   present         Logical array with true or false according to whether
%                   or not the corresponding keyword was present in the
%                   argument list
%
% This is a simple parsing utility function for a common task that attempts
% to be fast by avoiding packaging output in a structure or cell array.


nkey = numel(keywords);
narg = numel(args);

% Elementary checks on the input arguments defining the keywords and their
% defaults. Incomplete, but designed to catch common errors from miscounting
% the number of elements
if numel(defaults)~=nkey || numel(flags)~=nkey
    error('HERBERT:parse_arguments_simple:invalid_argument',...
        'Number of keywords, defaults and length of flags array must all be the same');
end

val = defaults;
for i = 1:find(logical(flags))
    val{i} = logical(val{i});
end

% Parse input arguments
npar = 0;
expect_key = false;
present = false(1, nkey);
i = 1;
while i<=narg
    % Determine if argument is a keyword; ambiguous keywords are an error
    iskey = false;
    name = args{i};
    if ~isempty(name) && ischar(name) && numel(size(name))==2 && size(name,1)==1
        ind = find(strncmpi(name, keywords, numel(name)));
        if numel(ind)>1 % more than one match, see if can find an exact length match
            ind = find(strcmpi(name,keywords));
            if isempty(ind)
                error('HERBERT:parse_arguments_simple:invalid_argument',...
                    'Ambiguous abbreviation of a keyword - check input arguments');
            elseif numel(ind)>1
                error('HERBERT:parse_arguments_simple:invalid_argument',...
                    'List of keywords is in error - problem in caller function');
            end
        end
        if ~isempty(ind)
            iskey = true;
        end
    end
    
    if iskey
        % Argument is a keyword
        if ~present(ind)
            present(ind) = true;
        else
            error('HERBERT:parse_arguments_simple:invalid_argument',...
                'Keyword ''%s'' appears more than once - check input', keywords{ind});
        end
        
        if flags(ind)
            % Case of keyword is a flag
            if i==narg || ~islognumscalar(args{i+1})
                val{ind} = true;
            else
                i = i + 1;
                val{ind} = logical(args{i});
            end
        else
            % Keyword-value pair
            if i<narg
                i = i + 1;
                val{ind} = args{i};
            else
                error('HERBERT:parse_arguments_simple:invalid_argument',...
                    ['Keyword ''%s'' expects a value, but the keyword is ',...
                    'the final argument'], keywords{ind})
            end
            expect_key = true;
        end
        
    else
        % Argument is not a keyword, so must be a parameter
        if ~expect_key
            npar = npar + 1;
        else
            error('HERBERT:parse_arguments_simple:invalid_argument',...
                'Unrecognised keyword ''%s'' - check input', name);
        end
    end
    
    i = i + 1;
end

par = args(1:npar);
