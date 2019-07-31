classdef LogMessage<aMessage
    % Class describes message, used to report job progress
    %
    % $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)
    %
    properties(Dependent)
        % current step within the loop which doing the job
        step
        % number of steps this job will make
        n_steps
        %approximate time spend to make one step of the job
        time_per_step
        % additional information to print in a log. May be empty
        add_info
        % logs from all nodes, available on the reduced head-node log message
        worker_logs;
    end
    
    methods
        function obj = LogMessage(step,n_steps,step_time,add_info)
            obj = obj@aMessage('running');
            obj.payload=struct('step',step,'n_steps',n_steps,...
                'time',step_time,'add_info','');
            if ~isempty(add_info)
                obj.payload.add_info = add_info;
            end
        end
        %-----------------------------------------------------------------
        function st=get.step(obj)
            st = obj.payload.step;
        end
        function st=get.n_steps(obj)
            st = obj.payload.n_steps;
        end
        function st=get.time_per_step(obj)
            st = obj.payload.time;
        end
        function st=get.add_info(obj)
            st=obj.payload.add_info;
        end
        function ll = get.worker_logs(obj)
            if isfield(obj.payload,'worker_logs')
                ll  = obj.payload.worker_logs;
            else
                ll = {};
            end
        end
        function obj = set_worker_logs(obj,logal_logs_cellarray)
            obj.payload.worker_logs = logal_logs_cellarray;
        end
        
    end
    
end

