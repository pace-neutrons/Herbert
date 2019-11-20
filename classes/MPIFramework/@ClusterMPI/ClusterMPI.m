classdef ClusterMPI < ClusterWrapper
    % The class to support cluster of Matlab workers, communicating over
    % MPI interface started by by mpiexec.
    %
    %
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
    %
    %----------------------------------------------------------------------
    properties(Access = protected)
        
        
        matlab_starter_  = [];
        mpiexec_handle_ = [];
        %
        % running process Java exception message contents
        running_mess_contents_= 'process has not exited';
    end
    properties(Access = private)
        %
        DEBUG_REMOTE = false;
        % the folder, containng mpiexec cluster configurations (host files)
        config_folder_
    end
    
    methods
        function obj = ClusterMPI(n_workers,mess_exchange_framework)
            % Constructor, which initiates MPI wrapper
            %
            % The wrapper provides common interface to run various kinds of
            % Herbert parallel jobs, communication over mpi (mpich)
            %
            % Empty constructor generates wrapper, which has to be
            % initiated by init method.
            %
            % Non-empty constructor calls the init method itself
            %
            % Inputs:
            % n_workers -- number of independent Matlab workers to execute
            %              a job
            %
            % mess_exchange_framework -- a class-child of
            %              iMessagesFramework, used  for communications
            %              between cluster and the host Matlab session,
            %              which started and controls the job.
            %
            % log_level    if present, defines the verbosity of the
            %              operations over the framework
            obj = obj@ClusterWrapper();
            obj.starting_info_message_ = ...
                ':mpiexec MPI job configured: *** Starting MPI job  with %d workers ***\n';
            obj.started_info_message_  = ...
                '*** mpiexec MPI job started                                ***\n';
            %
            obj.pool_exchange_frmwk_name_ ='MessagesCppMPI';
            % define config folder containing cluster configurations
            root = fileparts(which('herbert_init'));
            obj.config_folder_ = fullfile(root,'admin','mpi_cluster_configs');
            if nargin < 2
                return;
            end
            if ~exist('log_level','var')
                log_level = -1;
            end
            obj = obj.init(n_workers,mess_exchange_framework,log_level);
        end
        %
        function obj = init(obj,n_workers,mess_exchange_framework,log_level)
            % The method to initate the cluster wrapper and start running
            % the cluster job.
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
            if ~exist('log_level','var')
                log_level = -1;
            end
            obj = init@ClusterWrapper(obj,n_workers,mess_exchange_framework,log_level);
            
            pc = parallel_config();
            obj.worker_name_        = pc.worker;
            obj.is_compiled_script_ = pc.is_compiled;
            
            %
            
            %
            prog_path  = find_matlab_path();
            if isempty(prog_path)
                error('CLUSTER_HERBERT:runtime_error','Can not find Matlab');
            end
            
            mpiexec = obj.get_mpiexec();
            if ispc()
                obj.running_mess_contents_= 'process has not exited';
                obj.matlab_starter_ = fullfile(prog_path,'matlab.exe');
            else
                obj.running_mess_contents_= 'process hasn''t exited';
                obj.matlab_starter_= fullfile(prog_path,'matlab');
            end
            mpiexec_str = {mpiexec,'-n',num2str(n_workers)};
            
            % build generic worker init string without lab parameters
            cs = obj.mess_exchange_.gen_worker_init(obj.pool_exchange_frmwk_name);
            worker_init = sprintf('%s(''%s'');exit;',obj.worker_name_,cs);
            task_info = [mpiexec_str(:)',{obj.matlab_starter_},...
                {'-batch'},{worker_init}];
            
            runtime = java.lang.ProcessBuilder(task_info);
            obj.mpiexec_handle_ = runtime.start();
            [ok,failed,mess] = obj.is_running(obj.mpiexec_handle_);
            if ~ok && failed
                error('CLUSTER_MPI:runtime_error',...
                    ' Can not start mpiexec with %d workers, Error: %s',...
                    mess);
            end
            
            %
            if log_level > -1
                fprintf(obj.started_info_message_);
            end
        end
        %
        function obj = start_job(obj,je_init_message,task_init_mess,log_message_prefix)
            %
            obj = obj.init_workers(je_init_message,task_init_mess,log_message_prefix);
        end
        %
        function obj=finalize_all(obj)
            obj = finalize_all@ClusterWrapper(obj);
            if ~isempty(obj.mpiexec_handle_)
                obj.mpiexec_handle_.destroy();
                obj.mpiexec_handle_ = [];
            end
        end
        function config = get_cluster_configs_available(obj)
            % The function returns the list of the availible clusters
            % to run using correspondent parallel framework.
            %
            % The clusters defined by the list of the available host files.
            %
            % The first configuration in the available clusters list would
            % be the default configuration.
            %
            config = find_and_return_host_files_(obj);
        end
        
        %
        function check_availability(obj)
            % verify the availability of the compiled Herbert MPI
            % communicaton library and the possibility to use the MPI cluster
            % to run parallel jobs.
            %
            % Should throw PARALLEL_CONFIG:not_avalable exception
            % if the particular framework is not avalable.
            %
            check_mpi_mpiexec_can_be_enabled_(obj);
        end
        
        %------------------------------------------------------------------
    end
    methods(Static)
        function mpi_exec=get_mpiexec()
            if ispc()
                rootpath = fileparts(which('herbert_init'));
                % only one version of mpiexec is used now. May change in a
                % future.
                mpi_exec = fullfile(rootpath,'DLL','_PCWIN64','MS_MPI_R2019b','mpiexec.exe');
            else
                [~,mpi_exec] = system('which mpiexec');
            end
        end
    end
    methods(Access = protected)
        function [ok,failed,mess] = is_running(obj,task_handle)
            % check if java process is still running or has been completed
            %
            % inputs:
            if isempty(task_handle)
                ok      = false;
                failed  = true;
                mess = 'process has not been started';
                return;
            end
            
            mess = '';
            if task_handle.isAlive
                ok      = true;
                failed  = false;
            else
                try
                    term = task_handle.exitValue();
                    if ispc() % windows does not hold correct process for Matlab
                        ok = true;
                    else
                        ok = false; % unix does
                    end
                    if term == 0
                        failed = false;
                        ok = true;
                    else
                        failed = true;
                        mess = fprintf('Startup error with ID: %d',term);
                    end
                catch Err
                    if strcmp(Err.identifier,'MATLAB:Java:GenericException')
                        part = strfind(Err.message, obj.running_mess_contents_);
                        if isempty(part)
                            mess = Err.message;
                            failed = true;
                            ok   = false;
                        else
                            ok = true;
                            failed = false;
                        end
                    else
                        rethrow(Err);
                    end
                end
            end
        end
        
    end
end

