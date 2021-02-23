function save (w, file)
% Save a parObject object to file
%
%   >> save (w)              % prompt for file
%   >> save (w, file)        % give file
%
% Input:
% ------
%   w       parObject object (single object only, not an array)
%   file    [optional] File for output. if none given, then prompted for a file

% Original author: T.G.Perring


% Get file name - prompting if necessary
% --------------------------------------
if ~is_def('file'), file='*.par'; end
[file_full,ok,mess]=putfilecheck(file);
if ~ok, error(mess), end

% Write data to file
% ------------------
disp(['Writing par data to ',file_full,'...'])
[ok,mess] = put_parObject (w,file_full);
if ~ok; error(mess); end
