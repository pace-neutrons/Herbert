classdef ClusterParpoolWrapper < ClusterWrapper
    % The class-wrapper for parallel computing toolbox cluster and MPI
    % job submition routinge providing the same interface as Herbert
    % custom parallel class
    %
    %
    % $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)
    %
    %----------------------------------------------------------------------
    properties(Dependent)
        % current job identifier the class controls
        current_job;
    end
    properties(Access = protected)
        cluster_ =[];
        current_job_ = [];
        task_ = [];
        
        cluster_prev_state_ =[];
        cluster_cur_state_ = [];
    end
    properties(Constant,Access = private)
        % list of states availible for parallel computer toolbox cluster
        % class
        par_cluster_state_names_ = {'pending','paused','queued','running',...
            'finished',...
            'failed','unavailable','deleted'}
        par_cluster_state_codes_ = {0,1,2,3,4,...
            101,102,103}
        cluster_name2code = containers.Map(...
            ClusterParpoolWrapper.par_cluster_state_names_ ,...
            ClusterParpoolWrapper.par_cluster_state_codes_ )
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
    end
    
    methods
        function obj = ClusterParpoolWrapper(n_workers,mess_exchange_framework)
            % Constructor, which initiates wrapper
            %
            obj = obj@ClusterWrapper(n_workers,mess_exchange_framework);
            
            obj.cluster_  = parcluster();
            cl = obj.cluster_;
            num_labs = cl.NumWorkers;
            if num_labs < obj.n_workers
                error('PARPOOL_CLUSTER_WRAPPER:runtime_error',...
                    'job %s requested more workers (%d) then the cluster allows (%d)',...
                    obj.job_id,obj.n_workers,num_labs);
            end
            cjob = createCommunicatingJob(cl,'Type','SPMD');
            if n_workers > 0
                cjob.NumWorkersRange  = obj.n_workers;
            end
            cjob.AutoAttachFiles = false;
            obj.current_job_  = cjob;
            [completed,obj] = obj.check_progress();
            if completed
                error('PARPOOL_CLUSTER_WRAPPER:runtime_error',...
                    'parpool culster for job %s finished before startgin any job. State: %s',...
                    obj.job_id,obj.status_name);
            end
        end
        %
        function obj = start_job(obj,je_init_message,hWorker,task_init_mess)
            %
            % delete interactive parallel cluster if any exist
            cl = gcp('nocreate');
            if ~isempty(cl)
                delete(cl);
            end
            
            
            % build generic worker init string without lab parameters
            cs = obj.mess_exchange_.gen_worker_init();
            % clear up interactive pool if exist as this method will start
            % batch job.
            % actually submit the job
            cjob = obj.current_job_;
            task = createTask(cjob,hWorker,0,{cs});
            obj.task_ = task;
            submit(cjob);
            obj = obj.init_cluster_job(je_init_message,task_init_mess);
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
                            obj.current_status_ = FailMessage(...
                                sprintf('cluster job %s failed returning error:  %s, code: %s',...
                                obj.job_id,mess_texst,obj.cluster_cur_state_ ),...
                                err);
                        end
                        completed = true;                        
                    else % finished
                        if ~completed
                            [completed, obj] = check_progress@ClusterWrapper(obj);                        
                        end
                        if ~strcmpi(obj.current_status_.mess_name,'completed')
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
        function cjob = get.current_job(obj)
            cjob = obj.current_job_;
        end
    end
    methods(Access = protected)
        %         function obj = set_cluster_status(obj,mess)
        %             if ~isempty(obj.current_job_)
        %                 obj.cluster_job_prev_status_ = obj.cluster_job_status_;
        %                 cljb = obj.current_job_;
        %                 obj.cluster_job_status_ = cljb.State;
        %                 if ~isempty(cljb.Task_ID_of_Errors)
        %                     obj.cluster_job_status_  = 'falied';
        %                     if ~isa(mess,'FailMessage')
        %                         mess = FailMessage(...
        %                             sprintf('Job reported %d - failures',numel(cljb.Task_ID_of_Errors)));
        %                     end
        %                 end
        %             end
        %             obj = set_cluster_status@ClusterWrapper(obj,mess);
        %         end
        
    end
end

