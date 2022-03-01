function [Valid, Msg] = CheckFileName(S)
% Determine if a string is a valid file name
%
%   >> [Valid, Msg] = CheckFileName(S)
%
% Input:
% ------
%   S       Character string
%
% Output:
% -------
%   Valid   True or false
%
%   Msg     Empty string if Valid; otherwise gives a message string
%
%
% Taken from the MATLAB Answers forum 2022-02-25
% https://uk.mathworks.com/matlabcentral/answers/363670-is-there-a-way-to-
% determine-illegal-characters-for-file-names-based-on-the-computer-operating-system
Msg = '';
if ispc
  BadChar = '<>:"/\|?*';
  BadName = {'CON', 'PRN', 'AUX', 'NUL', 'CLOCK$', ...
             'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', ...
             'COM7', 'COM8', 'COM9', ...
             'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', ...
             'LPT7', 'LPT8', 'LPT9'};
    bad = ismember(BadChar, S);
    if any(bad)
       Msg = ['Name contains bad characters: ', BadChar(bad)];
    elseif any(S < 32)
       Msg = ['Name contains non printable characters, ASCII:', sprintf(' %d', S(S < 32))];
    elseif ~isempty(S) && (S(end) == ' ' || S(end) == '.')
       Msg = 'A trailing space or dot is forbidden';
    else
       % "AUX.txt" fails also, so extract the file name only:
       [~, name] = fileparts(S);
       if any(strcmpi(name, BadName))
          Msg = ['Name not allowed: ', name];
       end
    end
else  % Mac and Linux:
  if any(S == '/')
     Msg = '/ is forbidden in a file name';
  elseif any(S == 0)
     Msg = '\0 is forbidden in a file name';
  end
end
Valid = isempty(Msg);
end
