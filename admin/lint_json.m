function [raw, json] = lint_json(filesin, outputfile)
    if isempty(filesin)
        % Default to glob all
        filesin = "**/*.m";
    end

    files = [];
    for i = 1:numel(filesin)
        flist = dir(filesin{i});
        files = [files; arrayfun(@(file)(fullfile(file.folder, file.name)), flist, 'UniformOutput', false)];
    end

    if verLessThan('Matlab','R2016a')
        nl = sprintf('\n');
    else
        nl = newline;
    end

    if nargout > 0 % Build raw and json for potential output
        json = cell(1, numel(files));
        raw = checkcode(files);
        for i = 1:numel(raw)
            for j = 1:numel(raw{i})
                raw{i}(j).filename = files{i};
                json{i} = [json{i},jsonencode(wng_compat(raw{i}(j))), nl];
            end
        end
    end

    if nargout > 0 && ~isempty(outputfile) % Already have the vars

        fh = fopen(outputfile,'w');
        if fh == -1
            error("MATLAB:FileOpenError", "Failed to open file %s", outputfile);
        end
        fprintf(fh, '%s', cell2mat(json));
        fclose(fh);

    elseif ~isempty(outputfile) % Just printing

        fh = fopen(outputfile,'w');
        if fh == -1
            error("MATLAB:FileOpenError", "Failed to open file %s", outputfile);
        end
        for i = 1:numel(files)
            raw = checkcode(files{i});
            json = '';
            for j = 1:numel(raw)
                raw(j).filename = files{i};
                json = [json,jsonencode(wng_compat(raw(j))), nl];
            end
            fprintf(fh, '%s', json);
        end
        fclose(fh);

    elseif nargout == 0  % No operation to perform
        error('MATLAB:badargs', 'lint_json called with bad args');
    end
end

function struc = wng_compat(struc)
% Parse an mlint error struct into a Jenkins Warnings Next Gen compatible form
    struc = rename(struc, 'line', 'lineStart');
    struc.columnStart = struc.column(1);
    struc.columnEnd = struc.column(2);
    struc = rmfield(struc,'column');
    struc.severity = "NORMAL";
end

function struc = rename(struc, old, new)
% Rename a structure's field 'old' to 'new'
% From: https://stackoverflow.com/questions/2733582/how-do-i-rename-a-field-in-a-structure-array-in-matlab
    [struc.(new)] = struc.(old);
    struc = rmfield(struc,old);
end