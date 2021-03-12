function [is,err_code,err_message] = check_job_cancelled_(obj)
% check if the filebased job is cancelled or message "cancelled" has been
% send from the task with tid requested.
mess_folder = obj.mess_exchange_folder;
if is_folder(mess_folder)
    is = false;
    err_code = MESS_CODES.ok;
    err_message = '';
else
    err_code    = MESS_CODES.job_cancelled;
    err_message = sprintf('Job: "%s" have been cancelled. No message folder exist',obj.job_id);
    is          = true;
end
