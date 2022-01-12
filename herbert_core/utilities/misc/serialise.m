function ser = serialise(a)
%Wrapper to handle mex/nomex
[use_mex,fm] = config_store.instance().get_value('herbert_config',...
    'use_mex','force_mex_if_use_mex');

if use_mex
    try
        ser = c_serialise(a);
    catch ME
        if fm
            rethrow(ME);
        else
            warning(ME.identifier,'%s',ME.message);
            ser = hlp_serialise(a);
        end
    end

else
    ser = hlp_serialise(a);
end

end
