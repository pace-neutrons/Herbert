function [ok,err_mess]=finish_job_(this)
% set up tag, indicating that the job have finished and
% send message with output job results
%
% clear all existing messages intended or generated by this job
this.receive_all_messages();
% send completion message
mess = aMessage('completed');
mess.payload = this.task_outputs;
[ok,err_mess] = this.send_message(mess);

