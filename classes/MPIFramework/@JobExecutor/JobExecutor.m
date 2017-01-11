classdef JobExecutor<MessagesFramework
    % The class, responsible for running job on a worker
    %
    %
    % Works in conjunction with worker function from admin folder,
    % The worker has to be placed on Matlab search path
    % defined before Herbert is initiated
    %
    %
    % $Revision$ ($Date$)
    %
    %
    properties(Dependent)
        %-------------------------------------
        % Properties of a job runner:
        % the jd of the the job which is running
        job_id;
        % structure, containing output, returned from the job by
        % calling return_results method
        job_outputs;
    end
    %
    properties(Access=private)
        job_ID_ = 0;
        job_outputs_ = [];
    end
    methods(Abstract)
        this=do_job(this,control_struct);
        % abstract method to do particular job.
        % should be overloaded by a particular implementation
    end
    %------------------------------------------------------------------ ---
    methods
        function je = JobExecutor(varargin)
            % Initialize job executor
            % If provided with parameters, the first parameter should be
            % the sting-prefix of the job control files, used to distinguish
            % this job control files from any other job control files
            %Example
            % jd = JobExecutor() -- use randomly generated job control
            % prefix
            % jd = JobExecutor('target_file_name') -- add prefix
            %      which distinguish this job as the job which will produce
            %      the file with the name provided
            %
            % Initialise messaging framework
            je = je@MessagesFramework(varargin{:});
        end
        %
        function [this,argi,mess]=init_worker(this,job_control_string)
            % initiate worker side.
            %e.g:
            % set up tag, indicating that the job have started
            % and process main job control parameters, present in
            % inputs and files:
            %
            % job_control_string  -- the serialized structure,
            %                containing job control  information
            %
            % returns:
            % argi         the structure, containing job's arguments,
            %              used by do_job method
            % mess         if not empty, the reason for failure
            %
            [this,argi,mess]=this.init_worker_(job_control_string);
        end
        %
        function [ok,mess] =finish_job(this)
            % Clearly finish job execution
            [ok,mess] = finish_job_(this);
        end
		%
        function log_progress(this,step,n_steps,time_per_step,add_info)
            % log progress of the job execution and report it to the
            % calling framework.
            % Inputs:
            % step     --  current step within the loop which doing the job
            % n_steps  --  number of steps this job will make
            % time_per_step -- approximate time spend to make one step of
            %                  the job
            % add_info -- some additional information provided by the
            %             client. Not processed but printed in a log if not
            %             empty.
            % Outputs:
            % Sends message of type LogMessage to the job dispatcher.
            % Throws MESSAGE_FRAMEWORK:cancelled error in case the job has
            %
            log_progress_(this,step,n_steps,time_per_step,add_info);
        end
        %------------------------------------------------------------------
        function id = get.job_id(this)
            % get number (job id) of current running job
            id = this.job_ID_;
        end
        %
        function this = return_results(this,final_results)
            % function used by do_job method to return outputs from a job.
            %
            % input:
            % final_results -- the structure, which contain the job
            % output. As output is distributed within log message, it should not 
			% be too heavy. 
			% 
            this.job_outputs_ = final_results;
        end
        %
        function out = get.job_outputs(obj)
            out = obj.job_outputs_;
        end
        %------------------------------------------------------------------
        % overloads to exchange messages with JobDispatcher for particular job Executor
        function [ok,err_mess] = send_message(obj,message)
            % send message to job dispatcher
            % input:
            % message -- an instance of the class aMessage to send to job
            %            dispatcher
            %
            [ok,err_mess] = send_message@MessagesFramework(obj,obj.job_id,...
                message);
        end
        function [ok,err_mess,message] = receive_message(obj,mess_name)
            % receive message from job dispatcher
            [ok,err_mess,message] = receive_message@MessagesFramework(obj,obj.job_id,mess_name);
        end
        function ok=check_message(obj,mess_name)
            ok=check_message@MessagesFramework(obj,obj.job_id,mess_name);
        end
        function messages = receive_all_messages(obj)
            % retrieve (and remove from system) all messages 
            % existing in the system for the jobs with id-s specified as input
            %
            %Return:
            % all_messages -- cellarray of messages belonging to this job
            %                 have messages available in the system .
            %
            messages = receive_all_messages@MessagesFramework(obj,obj.job_id);
        end
        
    end
    
end

