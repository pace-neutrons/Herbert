function [n_failed,outputs,job_ids,this]=send_jobs_to_workers_(this,...
    job_class_name,job_param_list,n_workers,varargin)
% send range of jobs to execute by external program
%
% Usage:
%>>jd = JobDispatcher();
%>>[n_failed,outputs,job_ids]= jd.send_jobs(job_class_name,job_param_list,...
%                               [number_of_workers,[job_query_time]])
%Where:
% job_param_list -- cellarray of structures containing the
%                   parameters of the jobs to run
% number_of_workers -- if present, number of Matlab sessions to
%                   start to deal with the jobs. By default,
%                   the number of sessions is equal to number
%                   of jobs
% job_query_time    -- if present -- time interval to check if
%                   jobs are completed. By default, check every
%                   4 seconds
%
% Returns
% n_failed  -- number of jobs that have failed.
%
% outputs   -- cellarray of outputs from each job.
%              Empty if jobs do not return anything
% job_ids   -- list containing relation between job_id (job
%              number) and job parameters from
%              job_param_list, assigned to this job
%
%
% $Revision$ ($Date$)
%
%
% identify number of jobs on the basis of number of parameters
% provided by input structure
%
% delete orphaned messages, which may belong to this framework, previous run
%
% clear all messages which may left in case of failure
clob = onCleanup(@()this.clear_all_messages());

[this,job_ids,worker_inits]=this.split_and_register_jobs(job_param_list,n_workers);

prog_start_str = this.worker_prog_string;
n_workers = numel(worker_inits);
%
processes = cell(1,n_workers);
%runtime = java.lang.Runtime.getRuntime();
runtime = java.lang.ProcessBuilder(prog_start_str);
job_common_str = {prog_start_str,'-nosplash','-nojvm','-r'};
for i=1:n_workers
    worker_init = worker_inits{i};
    worker_str = sprintf('worker(''%s'',''%s'');exit;',job_class_name,worker_init);
    if ispc
        %job_str = sprintf('%s -nojvm -nosplash -r worker(''%s'',''%s'');exit; & exit',...
        %    prog_start_str,job_class_name,worker_init);        
        run_mess = 'process has not exited';
    else
        %job_str = sprintf('%s -nosplash -nojvm -r "worker(''%s'',''%s'');exit;" &',...
        %    prog_start_str,job_class_name,worker_id);
        %job_str = {prog_start_str,'-nosplash','-nojvm','-logfile',...
        %    '/home/wkc26243/test_worker_log.log', '-r', ....
        %    };       
        run_mess = 'process hasn''t exited';
    end
    job_str = [job_common_str,{worker_str}];
    % run external job
    %[nok,mess]=system(job_str);
    runtime = runtime.command(job_str);
    processes{i} = runtime.start();
    
    
    [completed,ok,mess] = check_job_completed_(processes{i},run_mess);
    if completed && ~ok
        error('JobDispatcher:starting_workers',[' Can not start worker N %d.',...
            ' Message returned: %s'],i,mess);
    end
end
clob1 = onCleanup(@()clear_all_processes(processes));
pause(1);
waiting_time = this.jobs_check_time;


count = 0;
[completed,n_failed,~,this]=check_jobs_status_(this,processes,run_mess);
while(~completed)
    if count == 0
        fprintf('**** Waiting for workers to finish their jobs ****\n')
        this.running_jobs_=print_job_progress_log_(this.running_jobs_);
    end
    pause(waiting_time);
    [completed,n_failed,all_changed,this]=check_jobs_status_(this,processes,run_mess);
    count = count+1;
    fprintf('.')
    if mod(count,19)==0 || all_changed
        fprintf('\n')
        this.running_jobs_=print_job_progress_log_(this.running_jobs_);
    end
end
fprintf('\n')
this.running_jobs_=print_job_progress_log_(this.running_jobs_);
%--------------------------------------------------------------------------
% retrieve outputs (if any)
outputs = cell(n_workers,1);
job_info=this.running_jobs_;
for ind = 1:n_workers
    if job_info{ind}.is_failed
        outputs{ind} = ['Failed, Reason: ',job_info{ind}.fail_reason];
    else
        outputs{ind} = job_info{ind}.outputs;
    end
end

function clear_all_processes(proc_list)

for i=1:numel(proc_list)
    proc_list{i}.destroy();
end
