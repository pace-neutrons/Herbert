function lint_wng(filesin, outputfile)
% Use mlint, but convert to a form mimicking that of pep8 for easy parsing by WNG
%
% Input:
% ------
% filesin              char array OR cell array of char arrays detailing files to parse
%                          if filesin is empty will recurse from current working directory
% outputfile           char array of filename to write output to (will overwrite)
%                          if outputfile is empty will write to stdout

    if isempty(filesin)
        % Default to glob all
        filesin = "**/*.m";
    end
    if isempty(outputfile) % Default to stdout
        fh = 1;
    else % Open file
        fh = fopen(outputfile,'w');
        if fh == -1
            error("MATLAB:FileOpenError", "Failed to open file %s", outputfile);
        end
        cleanup = onCleanup(@()(fclose(fh)));
    end

    files = [];
    for i = 1:numel(filesin)
        flist = dir(filesin{i});
        files = [files; arrayfun(@(file)(fullfile(file.folder, file.name)), flist, 'UniformOutput', false)];
    end

    [out, filepaths] = checkcode(files, '-id');
    for i = 1:numel(out)
        for j = 1:numel(out{i})
            curr = out{i}(j);
            curr.fileName = filepaths{i};
            fprintf(fh, "%s:%d:%d: %s %s\n", curr.fileName, curr.line, curr.column(1), curr.id, curr.message);
        end
    end

end
