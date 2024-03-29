function mess = accumulate_message (varargin)
% Accumulate messages
%
%   >> mess = accumulate_message (mess1, mess2, ...)
%
% Input:
% ------
%   mess1,mess2,... Input messages (character string or cell array of strings)
%
% Output:
% -------
%   mess            Accumulated message, having trimmed trailing whitespace.
%                   If all strings are empty, returns ''
%                   If just one non-empty string, then returns a character string
%                   Otherwise, cell array of non-empty strings


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


[ok,mess]=str_make_cellstr(varargin{:});
if ~ok
    error('One or more inputs are not character strings or cell array of characters')
end

end
