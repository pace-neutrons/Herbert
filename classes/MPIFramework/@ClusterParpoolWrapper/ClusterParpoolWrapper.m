classdef ClusterParpoolWrapper < ClusterWrapper
    % The class-wrapper for parallel computing toolbox cluster and MPI
    % job submission routine providing the same interface as Herbert
    % custom parallel class
    %
    %
    % $Revision$ ($Date$)
    %
    %----------------------------------------------------------------------
    properties(Access = protected)
        cluster_ =[];
        current_job_ = [];
        task_ = [];
        
        cluster_prev_state_ =[];
        cluster_cur_state_ = [];
    end
    properties(Constant,Access = private)
        % list of states available for parallel computer toolbox cluster
        % class
        par_cluster_state_names_ = {'pending','paused','queued','running',...
            'finished',...
            'failed','unavailable','deleted'}
        par_cluster_state_codes_ = {0,1,2,3,4,...
            101,102,103}
        cluster_name2code = containers.Map(...
            ClusterParpoolWrapper.par_cluster_state_names_ ,...
            ClusterParpoolWrapper.par_cluster_state_codes_ )
        % List of states parallel computing toolbox may report
        %Pending     ( 'pending'     , 0  )
        %Paused      ( 'paused'      , 1  )
        %Queued      ( 'queued'      , 2  )
        %Running     ( 'running'     , 3  )
        %Finished    ( 'finished'    , 4  )
        % The following states are all >= Finished to ensure that "wait"s
        % terminate if the job fails or becomes unavailable.
        %Failed      ( 'failed'      , 101 )
        %Unavailable ( 'unavailable' , 102 )
        %Destroyed   ( 'deleted'     , 103 )
        %------------------------------------------------------------------------
        % the handle for the function to run a remote job. The function must be
        % on the Matlab data search path before Horace is initialized.
        h_worker_ = @worker_v1;
    end
    
    methods
        function obj = ClusterParpoolWrapper(n_workers,mess_exchange_framework)
            % Constructor, which initiates wrapper
            %
            obj = obj@ClusterWrapper(n_workers,mess_exchange_framework);
            
            % delete interactive parallel cluster if any exist
            cl = gcp('nocreate');
            if ~isempty(cl)
                delete(cl);
            end
            % build generic worker init string without lab parameters
            cs = obj.mess_exchange_.gen_worker_init();
            
            
            cl  = parcluster();
            
            num_labs = cl.NumWorkers;
            if num_labs < obj.n_workers
                error('PARPOOL_CLUSTER_WRAPPER:runtime_error',...
                    'job %s requested %d workers while the cluster allows only %d',...
                    obj.job_id,obj.n_workers,num_labs);
            end
            cjob = createCommunicatingJob(cl,'Type','SPMD');
            
            if n_workers > 0
                cjob.NumWorkersRange  = obj.n_workers;
            end
            cjob.AutoAttachFiles = false;
            
            
            task = createTask(cjob,obj.h_worker_,0,{cs});
            
            obj.cluster_ = cl;
            obj.current_job_  = cjob;
            obj.task_ = task;
            
            [completed,obj] = obj.check_progress();
            if completed
                error('PARPOOL_CLUSTER_WRAPPER:runtime_error',...
                    'parpool cluster for job %s finished before starting any job. State: %s',...
                    obj.job_id,obj.status_name);
            end
            
            
            
            %clear up interactive pool if exist as this method will start
            %batch job.
            %actually submit the job
            
            submit(cjob);
            %wait(cjob);
        end
        %
        function obj = start_job(obj,je_init_message,task_init_mess,log_message_prefix)
            %
            obj = obj.init_workers(je_init_message,task_init_mess,log_message_prefix);
        end
        function [completed,obj] = check_progress(obj,varargin)
            % overload check progress method to account for changes
            % reported by parpool cluster
            [completed, obj] = check_progress@ClusterWrapper(obj,varargin{:});
            %
            if nargin == 1 && ~isempty(obj.current_job_)
                cljob = obj.current_job_;
                obj.cluster_prev_state_ = obj.cluster_cur_state_;
                obj.cluster_cur_state_ = cljob.State;
                if ~strcmp(obj.cluster_prev_state_,obj.cluster_cur_state_)
                    obj.status_changed_ = true;
                end
                code = obj.cluster_name2code(obj.cluster_cur_state_);
                if code > 3 % job completed
                    if code > 4 %failed
                        mess_texst = obj.task_.ErrorMessage;
                        err = obj.task_.Error;
                        if ~isa(obj.current_status_,'FailMessage')
                            pause(1);
                            [completed, obj] = check_progress@ClusterWrapper(obj,varargin{:});
                            if ~completed
                                obj.current_status_ = FailMessage(...
                                    sprintf('cluster job %s failed returning error:  %s, code: %s',...
                                    obj.job_id,mess_texst,obj.cluster_cur_state_ ),...
                                    err);
                                completed = true;
                            end
                        end
                    else % finished
                        if ~completed
                            [completed, obj] = check_progress@ClusterWrapper(obj);
                        end
                        if isempty(obj.current_status_) || ~strcmpi(obj.current_status_.mess_name,'completed')
                            if ~completed
                                completed = true;
                                fm = FailMessage('Cluster reports job completed but results have not been returned to host');
                            else
                                fm = FailMessage('Cluster reports job completed but the final completed message has not been received');
                            end
                            obj.current_status_  = fm;
                        end
                    end
                else
                    if ~obj.status_changed
                        obj.status = cljob.State;
                    end
                end
                
            end
        end
        
        function obj=finalize_all(obj)
            obj = finalize_all@ClusterWrapper(obj);
            if ~isempty(obj.current_job_)
                delete(obj.current_job_);
                obj.current_job_ = [];
                obj.cluster_prev_state_ = obj.cluster_cur_state_;
                obj.cluster_cur_state_ = [];
                obj.status_changed_ = false;
            end
            
        end
        %------------------------------------------------------------------
    end
    methods(Access = protected)
        function ex = exit_worker_when_job_ends_(obj)
            ex  = false;
        end
        function obj = set_cluster_status(obj,mess)
            % protected set status function, necessary to be able to
            % overload set.status method.
            if isa(mess,'aMessage')
                stat_mess = mess;
            elseif ischar(mess)
                if strcmp(mess,'running')
                    if ~isempty(obj.current_status_) && strcmp(obj.current_status_.mess_name,'running')
                        stat_mess = obj.current_status_;
                    else
                        stat_mess = aMessage(mess);
                    end
                elseif strcmp(mess,'finished')
                    stat_mess = aMessage('completed');
                else
                    stat_mess = aMessage(mess);
                end
            else
                error('CLUSTER_WRAPPER:invalid_argument',...
                    'status is defined by aMessage class only or a message name')
            end
            obj.prev_status_ = obj.current_status_;
            obj.current_status_ = stat_mess;
            if obj.prev_status_ ~= obj.current_status_
                obj.status_changed_ = true;
            end
            
        end
        
        
    end
end

