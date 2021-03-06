classdef MPI_clusters_factory<handle
    % The class, providing the subscription factory for
    % various type of MPI frameworks, available to users.
    %
    % Any new type of framework should subscribe to this factory.
    %
    % Implemented as classical singleton.
    %
    properties(Dependent)
        % current active cluster and message exchange framework
        % used for messages exchange between cluster's workers.
        parallel_cluster;
        %
        % Information method returning the list of names of the parallel
        % frameworks, known to Herbert. You can not add or change a framework
        % using this method, The framework has to be defined and subscribed
        % via the algorithms factory.
        known_cluster_names
        %
    end
    properties(Access=protected)
    end
    properties(Constant, Access=protected)
        % Subscription factory:
        % the list of the known framework names.
        known_cluster_names_ = {'herbert','parpool','mpiexec_mpi'};
        % The map to existing parallel frameworks clusters
        known_clusters_ = containers.Map(MPI_clusters_factory.known_cluster_names_,...
            {ClusterHerbert(),ClusterParpoolWrapper(),ClusterMPI()});
        % the map of the framework indexes
        cluster_ids_ = containers.Map(MPI_clusters_factory.known_cluster_names_,...
            {1,2,3});
        
    end
    %----------------------------------------------------------------------
    methods(Access=private)
        function obj=MPI_clusters_factory()
        end
    end
    %----------------------------------------------------------------------
    methods(Static)
        function obj = instance(varargin)
            persistent obj_state;
            if isempty(obj_state)
                obj_state = MPI_clusters_factory();
            end
            obj=obj_state;
        end
    end
    %----------------------------------------------------------------------
    methods
        %------------------------------------------------------
        function fw = get.parallel_cluster(~)
            fw = config_store.instance.get_config_field(...
                'parallel_config','parallel_cluster');
        end
        function set.parallel_cluster(obj,val)
            % Set up MPI framework to use. Available options are:
            % h[erbert], p[arpool] or m[pi_cluster]
            % (can be defined by single symbol) or by a framework number
            % in the list of frameworks.
            %
            % No protection against invalid input key is provided here so
            % use parallel_config to get this protection, or organize it
            % before the call. Throws invalid_key for unknown framework
            % names. Throws PARALLEL_CONFIG:not_available or
            % PARALLEL_CONFIG:invalid_configuration if the cluster is not
            % available on the current system.
            %
            [cl,cluster_name]= obj.get_cluster(val);
            % will throw PARALLEL_CONFIG:invalid_configuration if the
            % particular cluster is not available on current system
            cl.check_availability();
            %
            config_store.instance().store_config(...
                'parallel_config','parallel_cluster',cluster_name);
        end
        function [cl,cluster_name] = get_cluster(obj,val)
            % return non-initialized cluster wrapper for the framework with
            % the name provided as input.
            %
            cluster_name = parallel_config.select_option(...
                obj.known_cluster_names_,val);
            cl = obj.known_clusters_(cluster_name);
            
        end
        function cfg = get_all_configs(obj,cluster_name)
            % return all known configurations for the selected framework.
            %
            % frmw_name - if provided, return configuration for this
            %             frameowk. If not provided, the configurations are
            %             taken for the framework, selected current in
            %             parallel_config
            %
            if exist('cluster_name', 'var')
                cluster_name = parallel_config.select_option(...
                    obj.known_cluster_names_,cluster_name);
            else
                cluster_name = obj.parallel_cluster;
            end
            if strcmpi(cluster_name,'none')
                cfg = {'none'};
            else
                controller = obj.known_clusters_(cluster_name);
                cfg = controller.get_cluster_configs_available();
            end
        end
        
        
        function clusters = get.known_cluster_names(obj)
            clusters = obj.known_cluster_names_;
        end
        
        %-----------------------------------------------------------------
        function controller = get_initialized_cluster(obj,n_workers,cluster_to_host_exch_fmwork)
            % return the initialized and running MPI cluster, selected as default
            % Inputs:
            % n_workers -- number of running workers
            % cluster_to_host_exch_fmwork -- the instance of the messaging
            %              framework, used for initial communication with
            %              the cluster. Currently only FileBased
            % Returns:
            % controller -- the initialized instance of the cluster,
            %               selected as current in parallel_config. The
            %               cluster controls the requested number of the
            %               parallel workers, communicating between each
            %               other using the method, chosen for the
            %               cluster.
            log_level = config_store.instance().get_value('herbert_config','log_level');
            fram      = obj.parallel_cluster;
            if strcmpi(fram,'none')
                error('PARALLEL_CONFIG:not_available',...
                    ' Can not run jobs in parallel. Any parallel framework is not available. Worker may be not installed.')
            else
                controller= obj.known_clusters_(fram);
            end
            %
            controller = controller.init(n_workers,cluster_to_host_exch_fmwork,log_level);
        end
        
    end
    
    
end

