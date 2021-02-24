function ok = is_folder(name)
% tests if name is a valid folder
%
% Input:
% ------
%   name                The name of the file you want to check;
%
% Usage:
% ------
%  >> is_file('/home/user/test');        % True if folder exists
%  >> is_file('test');                   % True if folder exists in current dir
%

     if ~verLessThan('matlab', '9.1') % R2016b
         ok = isfolder(name);
     else
         [path,~,~] = fileparts(strtrim(name));
         if isempty(path)
             path = pwd();
         end
         name = fullfile(path, p.Results.name);

        ok = exist(name, 'dir') == 7;
     end

end
