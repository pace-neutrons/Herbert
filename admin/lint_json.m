function lint_json(filesin, outputfile)
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

    issues = struct('issues', {{}}, 'size', 0);
    raw = checkcode(files, '-id');
    for i = 1:numel(raw)
        for j = 1:numel(raw{i})
            raw{i}(j).fileName = files{i};
            curr = wng_compat(raw{i}(j));
            issues.issues = {issues.issues{:}, curr};
        end
    end
    issues.size = numel(issues.issues);
    fprintf(fh, "%s", jsonencode(issues));
end

function struc = wng_compat(struc)
% Parse an mlint error struct into a Jenkins Warnings Next Gen compatible form
    struc = rename(struc, 'line', 'lineStart');
    struc = rename(struc, 'id', 'type');
    struc.columnStart = struc.column(1);
    struc.columnEnd = struc.column(2);
    struc = rmfield(struc,'column');
    struc = rmfield(struc,'fix');
    struc.severity = "NORMAL";
end

function struc = rename(struc, old, new)
% Rename a structure's field 'old' to 'new'
% From: https://stackoverflow.com/questions/2733582/how-do-i-rename-a-field-in-a-structure-array-in-matlab
    [struc.(new)] = struc.(old);
    struc = rmfield(struc,old);
end
