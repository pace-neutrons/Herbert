function [outputs,n_failed,task_ids,obj] = submit_and_run_job_(obj,...
    task_class_name, common_params,loop_params,return_results,...
    cluster_wrp,keep_workers_running)
% submit parallel job to run on cluster
%
%Inputs:
% task_class_name - the name of jobExecutor class which does the requested
%                   work
% common_params   - the parameters, which are common for any loop
%                   iterations
% loop_params     - cellarray of parameters, to spread between workers or
%                   the number of internal loop iterations
% cluster_wrp     - the pointer for the class, responsible for
%                   the job submission and communications with tasks
% keep_workers_running - if true, current task completion does not finish
% parallel job and the job workers remain running and waiting for the next
%                   portion of the task to run
%
%
%
% $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)
%


exit_worker_when_job_ends = cluster_wrp.exit_worker_when_job_ends;
n_workers                 = cluster_wrp.n_workers;
% access to class responsible for communications between head node
% and the pool of workers
mf                        = obj.mess_framework;
% determine the way of spliting job among workers.
[task_ids,taskInitMessages]=...
    obj.split_tasks(common_params,loop_params,return_results,n_workers);
%
% build jobExecutor initialization message used by each worker
je_init_message = mf.build_je_init(task_class_name,exit_worker_when_job_ends,keep_workers_running);

if obj.job_is_starting_
    log_message_prefix = 'starting';
else
    log_message_prefix = 'continuing';
end

% submit info to cluster and start job
cluster_wrp = cluster_wrp.start_job(je_init_message,taskInitMessages,log_message_prefix);

% wait until the job finishes
waiting_time = obj.task_check_time;
pause(waiting_time );

[completed,cluster_wrp]=cluster_wrp.check_progress();
cluster_wrp = cluster_wrp.display_progress();
% regularly checking the task state
while(~completed)
    pause(waiting_time);
    [completed,cluster_wrp]=cluster_wrp.check_progress();
    cluster_wrp = cluster_wrp.display_progress();
end
% retrieve final results
[outputs,n_failed]=  cluster_wrp.retrieve_results();
% retrieve and reject all messages may left after the job was completed
%  (e.g. if some tasks of the job have failed);
obj.mess_framework.clear_messages();
