function [ok,err_mess,je]=worker_4tests_local(worker_controls_string)
% function used as standard worker to do a job in a separate Matlab
% session.
%
% To work, should be present on a data search path, before Herbert is
% initialized as may need to initialize Herbert and Horace itself
%
%Inputs:
% worker_controls_string - the structure, containing information, necessary to
%              initiate the job.
%              Due to the fact this string is transferred
%              through pipes its size is system dependent and limited, so
%              contains only minimal initialization information, namely the
%              folder name where the job initialization data are located on
%              a remote system
%
% $Revision: 822 $ ($Date: 2019-01-03 11:23:07 +0000 (Thu, 03 Jan 2019) $)
%
err_mess = [];
exit_at_the_end = true;
if isempty(which('herbert_init.m'))
    horace_on();
end
DO_LOGGING = false;


% Check current state of mpi framework and set up deployment status
% within Matlab code to run
mis = MPI_State.instance();
mis.is_deployed = true;
is_tested = mis.is_tested; % set up to tested state within unit tests.
%
% for testing we need to recover 'not-deployed' state to avoid clashes with
% other unit tests. The production job finishes Matlab and clean-up is not necessary
% though doing no harm.
clot = onCleanup(@()(setattr(mis,'is_deployed',false)));
%--------------------------------------------------------------------------
% 1) step 1 of the worker initialization.
%--------------------------------------------------------------------------
control_struct = iMessagesFramework.deserialize_par(worker_controls_string);
% Initialize config files to use on remote session. Needs to be initialized
% first as may be used by message framework.
%
%
% remove configurations, may be loaded in memory while Horace was
% initialized.
config_store.instance('clear');
% Place where config files are stored:
cfn = config_store.instance().config_folder_name;
config_exchange_folder = fullfile(control_struct.data_path,cfn);

% set pas to config sources:
config_store.set_config_folder(config_exchange_folder);
% Initialize the frameworks, responsible for communications within the
% cluster and between the cluster and the headnode.
[fbMPI,intercomm] = JobExecutor.init_frameworks(control_struct);
% initiate file-based framework to exchange messages between head node and
% the pool of workers

%--------------------------------------------------------------------------
% step 1 the initialization has been completed providing the
% communicator for exchange between control node and the cluster and
% between the clusters nodes. The control node communicator knows the
% folder for communications
%--------------------------------------------------------------------------
if DO_LOGGING
    log_name = sprintf('Job_%s_wkN%d#%d.log',fbMPI.job_id,intercomm.labIndex,intercomm.numLabs);
    flog_name = fullfile(config_exchange_folder,log_name);
    fh = fopen(flog_name,'w');
    clob_log = onCleanup(@()fclose(fh));
    fprintf(fh,'Log file %s :\n',log_name);
    fprintf(fh,'FB MPI settings:\n');
    fprintf(fh,'      Job ID         : %s:\n',fbMPI.job_id);
    fprintf(fh,'      Exchange folder: %s:\n',config_exchange_folder);
    fprintf(fh,'      LabNum         : %d:\n',fbMPI.labIndex);
    fprintf(fh,'      NumLabs        : %d:\n',fbMPI.numLabs);
    fprintf(fh,'Real MPI settings:\n');
    fprintf(fh,'      Job ID         : %s:\n',intercomm.job_id);
    fprintf(fh,'      Exchange folder: %s:\n',intercomm.mess_exchange_folder);
    fprintf(fh,'      LabNum         : %d:\n',intercomm.labIndex);
    fprintf(fh,'      NumLabs        : %d:\n',intercomm.numLabs);
    
end
keep_worker_running = true;
while keep_worker_running
    mess_cache.instance().clear()
    %
    %----------------------------------------------------------------------
    % 2) step 2 of the worker initialization.
    %----------------------------------------------------------------------
    
    %
    if DO_LOGGING
        fprintf(fh,'entered worker loop\n');
    	disp('WORKER_4TESTS: waiting for starting message ********************')
    end
    [ok,err,mess]= fbMPI.receive_message(0,'starting');
    %fprintf(fh,'got "starting" message\n');
    if ok ~= MESS_CODES.ok
        mess = aMessage('failed');
        err_mess = sprintf('job N%s failed while receive_je_info Error: %s:',...
            control_struct.job_id,err);
        mess.payload = err_mess;
        fbMPI.send_message(0,mess);
        ok = MESS_CODES.runtime_error;
        if exit_at_the_end;     exit;
        else;                   return;
        end
    else
        worker_init_data = mess.payload;
        keep_worker_running = worker_init_data.keep_worker_running;
    end
    %
    
    exit_at_the_end = ~is_tested && worker_init_data.exit_on_compl;
    %
    if DO_LOGGING
        fprintf(fh,['Received starting message with parameters: \n',...
            '         JobExecutor: %s;\n',...
            '         keep_running %d;\n',...
            '         exit lab on completion %d\n'],...
            worker_init_data.JobExecutorClassName,keep_worker_running,exit_at_the_end);
    end
    % instantiate job executor class.
    je = feval(worker_init_data.JobExecutorClassName);
    %----------------------------------------------------------------------
    % step 2 of the worker initialization completed. a jobExecutor is
    % initialized and worker knows what to do when it finishes or
    % fails.
    %----------------------------------------------------------------------
    %
    %----------------------------------------------------------------------
    % 3) step 3 of the worker initialization. Initializing the particular
    % job executor
    %----------------------------------------------------------------------
    
    
    % receive init message which defines the job parameters
    % implicit barrier exists which should block execution until
    % this message is received.
    
    [ok,err_mess,init_message] = fbMPI.receive_message(0,'init');
    if ok ~= MESS_CODES.ok
        [ok,err_mess]=je.finish_task(FailMessage(err_mess));
        if exit_at_the_end
            exit;
        else
            return
        end
    end
    if DO_LOGGING
        disp('WORKER_4TESTS: init message received ***********************')
        fprintf(fh,'***************************************\n');
        fprintf(fh,'got JE %s "init" message\n',worker_init_data.JobExecutorClassName);
    end
    
    try
        if DO_LOGGING
            fprintf(fh,'Trying to init JE: %s\n',worker_init_data.JobExecutorClassName);
            disp('WORKER_4TESTS: initializing worker ************************')
        end
        [je,mess] = je.init(fbMPI,intercomm,init_message,is_tested);
        
        if DO_LOGGING
            fprintf(fh,'JE: %s has been initialized, init error message: ''%s''\n',worker_init_data.JobExecutorClassName,mess);
            disp('WORKER_4TESTS: worker has been initialized ************************')
        end
        if ~isempty(mess)
            err = sprinft(' Error sending ''started'' message from task N%d',...
                fbMPI.labIndex);
            error('WORKER:init_worker',err);
        end
        % Successful je.init should return "started" message, initiating
        % blocking receive from all other workers.
        %
        % Attach jobExecutor methods to mpi singleton to be available from any part
        % of the code.
        mis.logger = @(step,n_steps,time,add_info)...
            (je.log_progress(step,n_steps,time,add_info));
        
        mis.check_canceled = @()(f_canc(je));
        
        % Execute job (run main job executor's do_job method
        if DO_LOGGING
            fprintf(fh,'je loop started\n');
            disp('WORKER_4TESTS:     Entering the job loop ******************')
        end
        
        % send first "running" log message and set-up starting time.
        n_steps = je.n_steps;
        mis.do_logging(0,n_steps);
        %
        while ~je.is_completed()
            je= je.do_job();
            % when its tested, workers are tested in single Matlab
            % session so it will hand up on synchronization
            je.do_job_completed = true;
            if ~is_tested
                if DO_LOGGING
                    fprintf(fh,'Waiting at barrier for all do_job completeon\n');
                    disp('WORKER_4TESTS: Waiting at barrier for all do_job completeon ')
                end

                
                % when not tested, the synchronization is mandatory
                je.labBarrier(false); % Wait until all workers finish their
                %                       job before reducing the data
            end
            if DO_LOGGING
                disp('WORKER_4TESTS: reducing data ')
                fprintf(fh,'Reducing data\n');
            end
            je = je.reduce_data();
        end
        % Sent final running message. The node 1 waits for other nodes to
        % send these this kind of messages
        mis.do_logging(n_steps,n_steps);
        if ~is_tested
            % stop other nodes until the node 1 finishes to produce the
            % final message
            je.labBarrier(false);
        end
        %fprintf(fh,'je loop completed\n');
    catch ME % Catch error in users code and finish task gracefully.
        if DO_LOGGING
            fprintf(fh,'je exception caught\n');
            disp(['WORKER_4TESTS: processing failure: ',ME.identifier])
        end
        try
            [ok,err_mess] = je.process_fail_state(ME,is_tested);
            
            if DO_LOGGING
                disp('WORKER_4TESTS: Process JE fail state is completed ')
                fprintf(fh,'Process JE fail state is completed for worker: %d\n',je.labIndex);
            end
            
            if keep_worker_running
                continue;
            else
                break;
            end
        catch ME1 % the only exception should happen here is "job canceled"
            if exit_at_the_end
                exit;
            else
                rethrow(ME1);
            end
            
        end
    end %Exception
    
    [ok,err_mess] = je.finish_task();
end
%pause
if exit_at_the_end
    exit;
end


function f_canc(job_executor)
if job_executor.is_job_canceled()
    error('MESSAGE_FRAMEWORK:canceled',...
        'Messages framework has been canceled or is not initialized any more')
end
