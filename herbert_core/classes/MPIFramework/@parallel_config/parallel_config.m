classdef parallel_config<config_base
    %The config class contains the information about the parallel cluster
    %and the parallel cluster available to run parallel Horace/Herbert
    %jobs
    %
    % To see the list of current configuration option values type:
    %   >> parallel_config
    %
    % To set values:
    %   >> set(parallel_config,'name1',val1,'name2',val2,...)
    % or just
    %   >>pc = parallel_config();
    %   >>pc.name1 = val1;
    %
    % To fetch values:
    %   >> [val1,val2,...]=get(parallel_config,'name1','name2',...)
    % or just
    %   >>
    %   >>val1 = pc.name1;
    %
    %parallel_config Methods:
    % ---------------------------------------------------------------------
    % worker               - The name of the script or program to run
    %                        on cluster in parallel using parallel
    %                        workers.
    %
    % is_compiled          - false if the worker is a Matlab script and
    %                        true if this script is compiled using Matlab
    %                        applications compiler.
    %
    % parallel_cluster   - The name of a cluster to use. Currently
    %                        available are h[erbert], p[arpool] and
    %                        [m]pi_cluster, clusters
    %
    % cluster_config       - The configuration class describing parallel
    %                        cluster, running selected cluster.
    %
    % shared_folder_on_local - The folder on your working machine containing
    %                          the job input and output data.
    %
    % shared_folder_on_remote - The place where job input and ouptut data 
    %                           should be found on (shared_folder_on_local) 
    %                           a remote worker.
    %
    % working_directory    - The folder, containing input data for the job
    %                        and tmp and output results should be stored. 
    %                        View from a remote worker. 
    % ---------------------------------------------------------------------
    % known_clusters     - Information method returning the list of
    %                        the parallel clusters, known to Herbert.
    % known_clust_configs  -  Information method returning the list of
    %                        the clusters, available to run the selected
    %                        cluster.
    % ---------------------------------------------------------------------
    % Type:
    %>>parallel_config  to see the list of current configuration option values.
    %
    properties(Dependent)
        % The name of the script or program to run on cluster in parallel
        % using parallel workers. The script has to be on the Matlab search
        % path for all
        worker;
        
        % False if the worker above is a Matlab script. The nodes need to
        % have  Matlab licenses or Matlab distributed cluster licenses to
        % run this code.
        % True if the worker above is compiled using Matlab applications
        % compiler. The nodes need to have appropriate Matlab
        % redistributable installed to run this application.
        is_compiled;
        
        % The name of a cluster to use for messages exchange. . Currently
        % available are h[erbert], p[arpool] and [m]pi_cluster-s .
        % where:
        %    [h]erbert --stands for Poor man MPI cluster, which runs on a single
        %              node only and is actually not uses MPI, but launches
        %              separate Matlab sessions using Java Launcher.
        %              The sessions exchange information between each other using
        %              file-based messages (.mat files), so this cluster is
        %              not suitable for any tasks, demanding heavy interprocess
        %              communications.
        %    [p]arpool --Uses Matlab parallel computing toolbox and it parallel
        %              cluster configured as default to run parallel jobs.
        %              Refer to the parallel toolbox user's manual for the
        %              description of such clusters.
        %    [m]piexec_mpi-- Deploys MPI libraries and mpiexec to run parallel jobs.
        %              On Windows these libraries are provided with Herbert and
        %              configured for running the parallel jobs on a working node,
        %              but a Linux machine needs these libraries installed and
        %              the cluster compiled using herbert_mex_mpi script
        %              If the jobs are expected to run on more then
        %              one node, the nodes should be configured for MPI
        %              communications (running mpiexec).
        %              Current cluster is build and tested using MPICH v3.
        %    none      -- not available. If worker can not be found on a
        %              path, any parallel cluster should be not
        %              available. Parallel extensions will not work.
        parallel_cluster;
        
        % The configuration class describing parallel cluster, running
        % selected cluster.
        % For herbert cluster, the configuration name can only be 'local'
        % as herbert clusters runs on a single node only. A parpool
        % cluster accepts only 'default' configuration and actual configuration
        % is set up as default on Dsitributed computing toolbox GUI.
        % 'mpi_cluster' can accept 'local' configuration for jobs, running
        % locally or any configuration, defined in
        % herbert_core/admin/mpi_cluster_configs
        % folder. The files, provided there are the files to use as input
        % for mpiexec /gmachinefile <file_name> on Windows or
        % -f <file_name> on Linux. The property picks up the file and
        % assumes that the cluster configuration, defined there is correct.
        cluster_config;

        % The folder on your working machine containing the job input and
        % output data mounted on local machine and available from the remote
        % machines.
        % Must have read/write permissions for all machines. Should be fast
        % /parallel file system on a remote machines
        %
        % If empty, assumed that the local machine filesystem is shared
        % with remote machine filesystem and have the same mounting points.
        shared_folder_on_local;
        
        % The place where a job data should be found on a remote worker.
        % Must have read/write permissions for all machines.
        %
        % On a MPI worker should point to the physical location equal to
        % the specified by shared_folder_on_local property
        %
        % If empty, assumed to be equal to shared_folder_on_local.
        shared_folder_on_remote;

        % Used as  the folder where tmp files should be stored in
        % parallel and non-parallel configuration.
        %
        % by default gen_sqw sets this value to place where spe files are
        % located.  If you never did gen_sqw on a given machine,
        % system tmp directory is used.
        %
        % Change this value to point to a fast&large disk or to a
        % parallel file system.
        % Assign empty value to restore it to default (system tmp
        % directory)
        %
        % If parallel Horace job is deployed, the value of this directory
        % evaluated on a remote worker equal to shared_folder_on_remote value        
        working_directory
        
        %------------------------------------------------------------------
        % Information fields, without setters:
        %------------------------------------------------------------------        
        % true, if working directory have not ever been set
        wkdir_is_default
        
        % Information method returning the list of the parallel clusters,
        % known to Herbert. You can not add or change a cluster
        % using this method, The cluster has to be defined and subscribed
        % via the clusters factory.
        known_clusters
        
        % Information method returning list of the known clusters,
        % available to run the selected cluster.
        % For mpiexec_mpi cluster, the cluster is defined
        % by a host file used as input for mpiexec (-f option).
        % These host files should be present in admin/mpi_cluster_configs
        % folder.
        % herbert cluster runs only on a local cluster.
        % The cluster used by parpool cluster is the default cluster,
        % selected in parallel computing toolbox GUI
        known_clust_configs
    end
    %
    properties(Constant,Access=private)
        saved_properties_list_={'worker',...
            'parallel_cluster','cluster_config',...
            'shared_folder_on_local','shared_folder_on_remote','working_directory'};
        %-------------------------------------------------------------------
    end
    properties(Access=protected)
        worker_ = 'worker_v2'
        is_compiled_ = false;
        % these values provide defaults for the properties above
        parallel_cluster_   = 'herbert';
        % the configuration, used as default
        cluster_config_ = 'local';
        % default remote folder is unset
        shared_folder_on_local_ ='';
        shared_folder_on_remote_ = '';
        %
        working_directory_ ='';
    end
    methods
        function this = parallel_config()
            % constructor
            this=this@config_base(mfilename('class'));
        end
        %-----------------------------------------------------------------
        % overloaded getters
        function wrkr = get.worker(obj)
            wrkr= get_or_restore_field(obj,'worker');
        end
        function wrkr = get.is_compiled(obj)
            % incomplete! Should be derived from worker
            wrkr= obj.is_compiled_;
        end
        
        function frmw =get.parallel_cluster(obj)
            frmw = get_or_restore_field(obj,'parallel_cluster');
        end
        function conf = get.cluster_config(obj)
            conf = get_or_restore_field(obj,'cluster_config');
        end
        %
        function folder =get.shared_folder_on_local(obj)
            folder = get_or_restore_field(obj,'shared_folder_on_local');
            if isempty(folder)
                is_depl = MPI_State.instance().is_deployed;
                if is_depl
                    folder = get_or_restore_field(obj,'working_directory');
                    if isempty(folder)
                        folder = tmp_dir;
                    end
                end
            end
        end
        %
        function folder =get.shared_folder_on_remote(obj)
            folder = get_or_restore_field(obj,'shared_folder_on_remote');
            if isempty(folder)
                folder = obj.shared_folder_on_local;
            end
        end
        
        function work_dir = get.working_directory(obj)
            is_depl = MPI_State.instance().is_deployed;
            if is_depl
                work_dir = obj.shared_folder_on_remote;
            else
                work_dir = get_or_restore_field(obj,'working_directory');
            end
            if isempty(work_dir)
                work_dir = tmp_dir;
            end
        end
        %
        function is = get.wkdir_is_default(obj)
            % returns true if working directory has not been set (points to
            % tmpdir)
            is_depl = MPI_State.instance().is_deployed;
            if is_depl
                work_dir = obj.shared_folder_on_remote;
            else
                work_dir = get_or_restore_field(obj,'working_directory');
            end
            if isempty(work_dir)
                is = true;
            else
                is = false;
            end
            
        end
        %------------------------------------------------------------------
        function frmw = get.known_clusters(obj)
            % Return list of clusters, known to Herbert
            frmw = MPI_clusters_factory.instance().known_clusters_names;
        end
        
        function clust_names = get.known_clust_configs(obj)
            % information about clusters (cluster configurations),
            % available for the selected cluster
            fram = obj.parallel_cluster;
            if strcmpi(fram,'none')
                clust_names = {'none'};
            else
                clust_names = MPI_clusters_factory.instance().get_all_configs();
            end
        end
        %
        %-----------------------------------------------------------------
        % overloaded setters
        function obj = set.worker(obj,new_wrkr)
            % Check and set new worker:
            % Input:
            % new_wrkr - the string, defining new worker function.
            %
            obj = check_and_set_worker_(obj,new_wrkr);
        end
        %
        function obj=set.parallel_cluster(obj,cluster_name)
            % Set up MPI cluster  to use.
            %
            % Available options defined by known_clusters and are
            % defined in MPI_clusters_factory
            %
            % The cluster name (can be defined by single symbol)
            % or by a cluster number in the list of clusters
            %
            obj = check_and_set_cluster_(obj,cluster_name);
        end
        %
        function obj = set.cluster_config(obj,val)
            % select one of the clusters which configuration is available
            opt = obj.known_clust_configs;
            if strcmpi(opt{1},'none')
                the_config = 'none';
            else
                the_config = select_option_(opt,val);
            end
            
            config_store.instance().store_config(obj,'cluster_config',the_config);
        end
        %
        function obj=set.shared_folder_on_local(obj,val)
            if isempty(val)
                val = '';
            end
            if ~ischar(val)
                error('PARALLEL_CONFIG:invalid_argument',...
                    ['The remote folder value should be a text string,',...
                    ' describing the location of the input/output'...
                    ' files on a remote machine'])
            end
            config_store.instance().store_config(obj,'shared_folder_on_local',val);
        end
        %
        function obj=set.shared_folder_on_remote(obj,val)
            if isempty(val)
                val = '';
            end
            
            if ~ischar(val)
                error('PARALLEL_CONFIG:invalid_argument',...
                    ['The remote folder value should be a text string,',...
                    ' describing the location of the input/output'...
                    ' files on a remote machine'])
            end
            config_store.instance().store_config(obj,'shared_folder_on_remote',val);
        end
        %
        function data=get_data_to_store(obj)
            data = get_data_to_store@config_base(obj);
            % temp working directory should not be stored
            working_dir = data.working_directory;
            tdr = tmp_dir;
            if strncmpi(working_dir,tdr,numel(working_dir))
                data.working_directory = '';
            end
        end
        
        function obj=set.working_directory(obj,val)
            % Check and set working directory
            if isempty(val)
                val = '';
            end
            if ~is_string(val)
                error('PARALLEL_CONFIG:invalid_argument',...
                    'working directory value should be a string')
            end
            if ~isempty(val)
                if strcmp(val,tmp_dir) % avoid storing tmp dir as working directory as this is default
                    val = '';
                else
                    test_dir = fullfile(val,'horace_test_write_directory');
                    clob = onCleanup(@()rmdir(test_dir,'s'));
                    ok = mkdir(test_dir);
                    if ~ok
                        warning('PARALLEL_CONFIG:invalid_argument',...
                            'working directory %s does not have write permissions. Changing it to %s directory',...
                            val,tmp_dir);
                        val = '';
                    end
                end
            end
            config_store.instance().store_config(obj,'working_directory',val);
        end
        %------------------------------------------------------------------
        % ABSTACT INTERFACE DEFINED
        %------------------------------------------------------------------
        function fields = get_storage_field_names(this)
            % helper function returns the list of the name of the structure,
            % get_data_to_store returns
            fields = this.saved_properties_list_;
        end
        function value = get_internal_field(this,field_name)
            % method gets internal field value bypassing standard get/set
            % methods interface
            value = this.([field_name,'_']);
        end
    end
    methods(Static)
        function the_opt = select_option(opt,arg)
            % Select single valued option from the list of available options
            % Inputs:
            % opt -- cellarray of available options
            % arg -- either string, which uniquely define one of the options or
            %        the number, selecting the option with number.
            %        Uniquely here means that the comparison of the
            %        argument with all options available returns only
            %        one match.
            %
            the_opt = select_option_(opt,arg);
        end
    end
end