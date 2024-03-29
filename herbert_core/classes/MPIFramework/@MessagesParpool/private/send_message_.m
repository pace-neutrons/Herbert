function [ok,err_mess] = send_message_(obj,task_id,message)
% Send message to a job with specified ID
%
ok = MESS_CODES.ok;
err_mess=[];
if ~is_folder(obj.mess_exchange_folder_)
    ok = MESS_CODES.job_cancelled;
    err_mess = sprintf('Job with id %s have been cancelled',obj.job_id);
    return;
end
%
if is_string(message) && ~isempty(message)
    message = aMessage(message);
end
if ~isa(message,'aMessage')
    error('FILEBASE_MESSAGES:runtime_error',...
        'Can only send instances of aMessage class, but attempting to send %s',...
        class(message));
end
mess_name = message.mess_name;
mess_fname = obj.job_stat_fname_(task_id,mess_name);
save(mess_fname,'message');

