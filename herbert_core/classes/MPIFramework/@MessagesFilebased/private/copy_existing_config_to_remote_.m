function copy_existing_config_to_remote_(current_config_f,remote_config_f)
% copy configuration data necessary to initiate Herbert
% on a remote machine.
%

if ~(exist(remote_config_f ,'dir' ) == 7)
    mkdir(remote_config_f )
end

if(~strcmp(fullfile(current_config_f), fullfile(remote_config_f)))
    try
        copyfile(current_config_f,remote_config_f,'f');
    catch ME
        disp(ME)
        disp(ME.stack)
        disp(ME.cause)
    end
end
