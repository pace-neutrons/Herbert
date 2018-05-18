function [outputs,n_failed,task_ids,this]=...
    send_tasks_to_workers_(this,...
    task_class_name,common_params,loop_params,return_results,n_workers,task_query_time)
% send range of jobs to execute by external program
%
% Usage:
%>>jd = JobDispatcher();
%>>[outputs,n_failed,task_ids,jd]= jd.send_jobs(task_class_name,task_param_list,...
%                               [number_of_workers,[task_query_time]])
%Where:
% job_class_name -- name of the class - child of jobExecutor,
%                   which will process task on a separate worker
% common_params  -- a structure, containing the parameters, common
%                   for any loop iteration
% loop_params    -- either cellarray of structures, specific
%                   with each cell specific to a loop iteration
%                   or the number of iterations to do over
%                   common_params (which may depend on the
%                   iteration number)
% number_of_workers -- number of Matlab sessions to
%                    process the tasks
% task_query_time    -- if present -- time interval to check if
%                   jobs are completed. By default, check every
%                   4 seconds
%
% Returns
% outputs   -- cellarray of outputs from each job.
%              empty if job does not return anything or Failed message for failed tasks
% n_failed  -- number of jobs that have failed.
%
% task_ids   -- list containing relation between task_id (task
%              number) and task parameters from
%              task_param_list, assigned to this job
%
%
% $Revision: 699 $ ($Date: 2018-02-08 17:40:52 +0000 (Thu, 08 Feb 2018) $)
%
%
% identify number of jobs on the basis of number of parameters
% provided by input structure
%
% delete orphaned messages, which may belong to this framework, previous run
%
% clear all messages which may left in case of failure
mf = this.mess_framework_;

% initialize cluster
par_fm = parallel_config();
cluster = par_fm.get_cluster_wrapper(n_workers,mf);
clob_mf = onCleanup(@()finalize_all(cluster));



% split job
[task_ids,taskInitMessages]=...
    this.split_tasks(common_params,loop_params,return_results,n_workers);
je_init_message = mf.build_je_init(task_class_name,true,false);

cluster = cluster.start_job(je_init_message,@worker,taskInitMessages);



if exist('task_query_time','var') && ~isempty(task_query_time)
    this.task_check_time  = task_query_time;
end
waiting_time = this.task_check_time;
pause(waiting_time );

[completed,cluster]=cluster.check_progress();
cluster = cluster.display_progress();
%
while(~completed)    
    pause(waiting_time);
    [completed,cluster]=cluster.check_progress();    
    cluster = cluster.display_progress();   
end
[outputs,n_failed,this]=  this.retrieve_results();
