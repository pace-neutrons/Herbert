function lint_json(filesin, outputfile, varargin)
% Use mlint, and convert to a json for easy parsing by WNG
%
% Input:
% ------
% filesin              char array OR cell array of char arrays detailing files to parse
%                          if filesin is empty will recurse from current working directory
% outputfile           char array of filename to write output to (will overwrite)
%                          if outputfile is empty will write to stdout

    p = inputParser;
    addOptional(p, 'filesin', {['**', filesep, '*.m']});
    addOptional(p, 'outputfile', '_screen', @ischar);
    addParameter(p, 'exclude', {}, @iscellstr);
    parse(p, filesin, outputfile, varargin{:});

    if strcmp(p.Results.outputfile, '_screen')
        fh = 1;
    else % Open file
        fh = fopen(p.Results.outputfile,'w');
        if fh == -1
            error("MATLAB:FileOpenError", "Failed to open file %s", p.Results.outputfile);
        end
        cleanup = onCleanup(@()(fclose(fh)));
    end

    files = [];
    for i = 1:numel(p.Results.filesin)
        flist = dir(p.Results.filesin{i});
        % Filter doc files
        flist = filter_list(flist, @(x)(startsWith(x.name,'doc_')));
        flist = arrayfun(@(file)(fullfile(file.folder, file.name)), flist, 'UniformOutput', false);
        files = unique([files; flist]);
    end

    for i = 1:numel(p.Results.exclude)
        excl = dir(p.Results.exclude{i});
        excl = arrayfun(@(file)(fullfile(file.folder, file.name)), excl, 'UniformOutput', false);
        files = setdiff(files, excl);
    end

    issuesList = struct('issues', {{}}, 'size', 0);
    raw = checkcode(files, '-id');
    for i = 1:numel(raw)
        for j = 1:numel(raw{i})
            curr = wng_compat(raw{i}(j), files{i});
            issuesList.issues = {issuesList.issues{:}, curr};
        end
    end

    issuesList.size = numel(issuesList.issues);
    fprintf(fh, "%s", jsonencode(issuesList));
end

function struc = wng_compat(struc, filename)
% Parse an mlint error struct into a Jenkins Warnings Next Gen compatible form
    struc = rename(struc, 'line', 'lineStart');
    struc = rename(struc, 'id', 'type');
    struc.fileName = filename;
    struc.columnStart = struc.column(1);
    struc.columnEnd = struc.column(2);
    struc = rmfield(struc,'column');
    struc = rmfield(struc,'fix');
    struc.severity = 'NORMAL';
end

function struc = rename(struc, old, new)
% Rename a structure's field 'old' to 'new'
% From: https://stackoverflow.com/questions/2733582/how-do-i-rename-a-field-in-a-structure-array-in-matlab
    [struc.(new)] = struc.(old);
    struc = rmfield(struc,old);
end

function to_filt = filter_list(to_filt, match)
% Filter a list based on match function handle
    filter = arrayfun(match, to_filt);
    if any(filter)
        filtered = to_filt(filter);
        fprintf("Skipping: %s\n", filtered.name);
        to_filt = to_filt(~filter);
    end
end
