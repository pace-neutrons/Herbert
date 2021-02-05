function lint_wng(filesin, outputfile)

    out = lint_json(filesin,'');
    fh = fopen(outputfile,'w');
    if fh == -1
        error("MATLAB:FileOpenError", "Failed to open file %s", outputfile);
    end
    for i = 1:numel(out)
        for j = 1:numel(out{i})
            curr = out{i}(j);
            fprintf(fh, "%s:%d:%d: W404 %s\n", curr.fileName, curr.line, curr.column(1), curr.message);
        end
    end
    fclose(fh);
end