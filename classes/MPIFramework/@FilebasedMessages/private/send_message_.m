function [ok,err_mess] = send_message_(obj,task_id,message)
% Send message to a job with specified ID
%
ok = MES_CODES.ok;
err_mess=[];
if ~exist(obj.exchange_folder,'dir')
    ok = MES_CODES.job_canceled;
    err_mess = sprintf('Job with id %s have been canceled',obj.job_control_pref);
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

