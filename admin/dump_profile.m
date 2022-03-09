function dump_profile(prof, filename)
    extract = {'FunctionName' 'NumCalls' 'TotalTime' 'TotalMemAllocated' 'TotalMemFreed' 'PeakMem'};

    ft = prof.FunctionTable;

    maxTime = max([ft.TotalTime]);

    fn = fieldnames(ft);
    sd = setdiff(fn, extract);
    m = rmfield(ft, sd);

    percent = arrayfun(@(x) 100*x.TotalTime/maxTime, m, 'UniformOutput', false);
    [m.PercentageTime] = percent{:};
    sp_time = arrayfun(@(x) sum([x.Children.TotalTime]), ft);
    self_time = arrayfun(@(x,y) x-y, [ft.TotalTime]', sp_time, 'UniformOutput', false);
    [m.SelfTime] = self_time{:};
    percent = arrayfun(@(x) 100*x.SelfTime/maxTime, m, 'UniformOutput', false);
    [m.SelfPercentageTime] = percent{:};

    dataStr = evalc('struct2table(m)');

    % Remove HTML, braces and header
    dataStr = regexprep(dataStr, '<.*?>', '');
    dataStr = regexprep(dataStr, '[{}]', ' ');
    dataStr = dataStr(24:end);

    fh = fopen(filename, 'w');
    fwrite(fh, dataStr);
    fclose(fh);

end
