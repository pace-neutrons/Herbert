function [file_out,ok,mess] = translate_write (file)
% Resolve a global path in a file name for writing.
% Global path prefix has form e.g. inst_data:::my_file.dat
%
%   >> file_out = translate_write (file)            % error thrown if not OK
%
%   >> [file_out,ok,mess] = translate_write (file)  % return ok flag and non-empty message if ~ok

if ~isempty(file) && ischar(file) && size(file,1)==1 && numel(size(file))==2
    ok=true;
    mess='';
    ind=strfind(file,':::');
    if ~isempty(ind) && ind>1 && length(file)>ind+2     % has form xxx:::yyy with xxx, yyy not empty
        pathname=file(1:ind-1);
        filename=file(ind+3:end);
        if existgpath(pathname)
            dir=getgpath(pathname,'full');
            if ~isempty(dir)
                for i=1:numel(dir)
                    if exist(dir{i},'dir')==7
                        file_out=fullfile(dir{i},filename);
                        return
                    end
                end
                file_out='';
                ok=false;
                mess=['Cannot find a location to write file: ',file];
            else
                file_out='';
                ok=false;
                mess=['Global path ''',pathname,''' is empty. Cannot resolve file name: ',file];
            end
        else
            file_out='';
            ok=false;
            mess=['Global path ''',pathname,''' does not exist. Cannot resolve file name: ',file];
        end
    else
        file_out=file;  % assume file
        [pathname,filename,ext]=fileparts(file_out);
        if ~(isempty(pathname) || exist(pathname,'dir')==7)
            file_out='';
            ok=false;
            mess=['Cannot find a location to write file: ',file];
        end
        if ~isvarname(filename)
            file_out='';
            ok=false;
            mess=['Invalid file name or extension: ',file];
        end
        if ~(isempty(ext)||(numel(ext)>1 && isvarname(ext(2:end))))     % allow extension to be empty
            file_out='';
            ok=false;
            mess=['Invalid file name or extension: ',file];
        end
    end
else
    file_out='';
    ok=false;
    mess='Filename input argument must be non-empty character string';
end

% If not given ok as output argument, fail if ~ok
if nargout==1 && ~ok
    error(mess);
end
