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
        raw = cell(1, numel(files));
        json = cell(1, numel(files));
        for i = 1:numel(files)
            raw{i} = checkcode(files{i});
            for j = 1:numel(raw{i})
                raw{i}(j).filename = files{i};
                json{i} = [json{i},jsonencode(raw{i}(j)), nl];
            end
        end
    end

    if nargout > 0 && ~isempty(outputfile) % Already have the vars

        fh = fopen(outputfile,'w');
        fprintf(fh, '%s', cell2mat(json));
        fclose(fh);

    elseif ~isempty(outputfile) % Just printing

        fh = fopen(outputfile,'w');
        for i = 1:numel(files)
            raw = checkcode(files{i});
            json = '';
            for j = 1:numel(raw)
                raw(j).filename = files{i};
                json = [json,jsonencode(raw(j)), nl];
            end
            fprintf(fh, '%s', json);
        end
        fclose(fh);

    elseif nargout == 0  % No operation to perform
        error('MATLAB:badargs', 'lint_json called with bad args');
    end
end
