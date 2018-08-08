function unlock_(fh,filename)
n_attempts_allowed = 100;
tried = 0;
fclose(fh);
ws=warning('off','MATLAB:DELETE:Permission');
permission_denied = false;
while exist(filename,'file')==2 || permission_denied
    delete(filename);
    [~,warn_id] = lastwarn;
    if strcmpi(warn_id,'MATLAB:DELETE:Permission')
        permission_denied=true;
        lastwarn('');
        pause(0.1)
        tried = tried+1;
        if tried > n_attempts_allowed
            warning('UNLOCK:runtime_error',...
                ' Can not remove lock %s. It looks like threads got dead-locked. Breaking lock forcibly',...
                filename);
            break
        end
    else
        permission_denied=false;
    end
    
end
warning(ws);

