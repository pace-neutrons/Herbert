function handle = get_builtin_handle(fn_name)
    % Gets the handle to a builtin function
    list = which(fn_name, '-all');
    f = strncmp(list, matlabroot, numel(matlabroot)); % locate 1st in list under matlabroot
    if any(f)
        [funcpath, ~] = fileparts(list{find(f, 1, 'first')});
        here = cd(funcpath);              % temporarily switch to the containing folder
        cleanup = onCleanup(@()cd(here)); % go back to where we came from
        handle = str2func(fn_name);       % grab a handle to the function
        clear('cleanup');
    else
        error(['Cannot find built-in ' fn_name ' function!']);
    end
end

