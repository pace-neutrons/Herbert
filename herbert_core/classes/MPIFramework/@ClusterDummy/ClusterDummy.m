classdef ClusterDummy < ClusterWrapper
    % The class to support Dummy cluster
    %
    %----------------------------------------------------------------------

    properties(Access=protected, Hidden=true)
        last_results_;
    end

    methods
        function obj = ClusterDummy(n_workers,mess_exchange_framework,log_level)
            % Constructor, which initiates wrapper around Dummy
            % MPI framework.
            %
            % The wrapper provides common interface to run various kind of
            % Herbert parallel jobs.
            %
            % Empty constructor generates wrapper, which has to be
            % initiated by init method.
            %
            % Non-empty constructor calls the init method itself
            %
            % Inputs:
            % n_workers -- number of independent Matlab workers to execute
            %              a job
            % mess_exchange_framework -- a class-child of
            %              iMessagesFramework, used  for communications
            %              between cluster and the host Matlab session,
            %              which started and controls the job.
            % log_level    if present, defines the verbosity of the
            %              operations over the framework
            obj = obj@ClusterWrapper();

            obj.starting_info_message_ = ...
                ':dummy configured: *** Starting dummy cluster with 1 workers ***\n';
            obj.started_info_message_  = ...
                '*** Dummy cluster initialized                              ***\n';
            % The default name of the messages framework, used for communications
            % between the nodes of the parallel job
            obj.pool_exchange_frmwk_name_ ='dummy';
            obj.cluster_config_ = 'local';
            obj.starting_cluster_name_ = class(obj);

            if nargin < 2
                return;
            end

            obj = obj.init(n_workers,mess_exchange_framework,log_level)

        end

        function obj = init(obj,n_workers,mess_exchange_framework,log_level)
            % The method to initate the cluster wrapper
            %
            % Inputs:
            % n_workers -- number of independent Matlab workers to execute
            %              a job
            % mess_exchange_framework -- a class-child of
            %              iMessagesFramework, used  for communications
            %              between cluster and the host Matlab session,
            %              which started and controls the job.
            %log_level     if present, the number, which describe the
            %              verbosity of the cluster operations outpt;
            if ~exist('log_level', 'var')
                log_level = -1;
            end

            if n_workers ~= 1
                warning('HERBERT:ClusterDummy:init', ...
                        'Cannot start dummy cluster with %d workers.', n_workers)
                n_workers = 1;
            end

            obj = init@ClusterWrapper(obj,n_workers,mess_exchange_framework,log_level);
        end

        function obj = start_job(obj,je_init_message,task_init_mess,log_prefix)

            try
                je = feval(je_init_message.payload.JobExecutorClassName);
                dummyMF = MessagesDummy();
                je = je.init(dummyMF, dummyMF, task_init_mess{1}.payload, false);

                % send first "running" log message and set-up starting time. Runs
                % asynchronously.

                while ~je.is_completed()
                    je.do_job_completed = false; % do 2 barriers on exception (one at process failure)
                                                 % Execute job (run main job executor's do_job method
                    je= je.do_job();
                    je = je.reduce_data();
                end
                je.do_job_completed = true; % do not wait at barrier if cancellation here
                obj.last_results_ = je.task_outputs;
            catch ME
                obj.last_results_ = ME;
            end

        end

        function [outputs,n_failed,obj] = retrieve_results(obj)
            outputs = obj.last_results_;
            n_failed = 0;
        end

        function [obj,ok] = wait_started_and_report(obj,check_time,varargin)
            ok = true;
            info = sprintf('Parallel cluster "%s" is ready to execute tasks',...
                           class(obj));

        end

        function [completed, obj] = check_progress(obj);
            completed = true;
        end

        function obj=finalize_all(obj)
            ...
        end

        function is = is_job_initiated(obj)
            % returns true, if the cluster wrapper is running bunch of
            % parallel java processes
            is = true;
        end

        %------------------------------------------------------------------

    end

    methods(Access = protected)
        function [running,failed,paused,mess] = get_state_from_job_control(obj)
            % Method checks if java framework is running
            running = true;
            failed = false;
            paused = false;
            mess = '';
        end


    end
end
