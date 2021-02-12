function ser = serialise(a)
%Wrapper to handle mex/nomex
use_mex = config_store.instance().get_value('herbert_config','use_mex');
if use_mex
    try
        ser = c_serialise(a);
        return
    catch ME
        warning(ME.identifier,'%s',ME.message);
        use_mex = false;
    end
end
if ~use_mex
    ser = hlp_serialise(a);
end
