classdef herbert_config<config_base
    % Create the Herbert configuration.
    %
    % To see the list of current configuration option values:
    %   >> herbert_config
    %
    % To set values:
    %   >> set(herbert_config,'name1',val1,'name2',val2,...)
    % or just
    %   >>hc = herbert_config();
    %   >>hc.name1 = val1;
    %
    % To fetch values:
    %   >> [val1,val2,...]=get(herbert_config,'name1','name2',...)
    % or just
    %   >>val1 = herbert_config.name1;
    
    %
    % Fields are:
    % -----------
    %   use_mex             Use C++ mex files for time-consuming
    %                       operation, if available
    %  force_mex_if_use_mex Force using mex (usually mex failure causes an
    %                       attempt to use Matlab).
    %                       This is option is for testing mex against Matlab
    %   log_level           Set verbosity of informational output
    %                           -1  No information messages printed
    %                            0  Major information messages printed
    %                            1  Minor information messages printed in addition
    %                                   :
    %                       The larger the value, the more information is printed
    %   init_tests          Enable the unit test functions
    %
    % Type >> herbert_config  to see the list of current configuration option values.
    
    
    properties(Dependent)
        %   Use C++ mex files for time-consuming operation, if
        %   available.
        use_mex;
        % force using mex (usually mex failure causes attempt to use
        % Matlab). This is rather for testing mex against Matlab
        force_mex_if_use_mex;
        % the level to report:
        % -1, do not tell even about an errors (useful for unit tests)
        % 0 - be quiet but report errors,
        % 1 report result of long-lasting operations,
        % 2 report elaborate timing
        log_level
        % add unit test folders to search path (option for Herbert testing)
        init_tests;
    end
    properties(Dependent,SetAccess=private)
        % location of the folder with unit tests
        unit_test_folder;
        
    end
    %
    properties(Constant,Access=private)
        saved_properties_list_={'use_mex','force_mex_if_use_mex',...
            'log_level','init_tests'};
    end
    properties(Access=private)
        % these values provide defaults for the properties above
        use_mex_              = false;
        force_mex_if_use_mex_ = false;
        log_level_            = 1;
        init_tests_           = false;
    end
    methods
        function this = herbert_config()
            % constructor
            this=this@config_base(mfilename('class'));
        end
        %-----------------------------------------------------------------
        % overloaded getters
        function use = get.use_mex(this)
            use = get_or_restore_field(this,'use_mex');
        end
        function force = get.force_mex_if_use_mex(this)
            force = get_or_restore_field(this,'force_mex_if_use_mex');
        end
        function level = get.log_level(this)
            level = get_or_restore_field(this,'log_level');
        end
        function doinit=get.init_tests(this)
            doinit = get_or_restore_field(this,'init_tests');
        end
        
        %-----------------------------------------------------------------
        % overloaded setters
        function this = set.use_mex(this,val)
            if val>0
                use = true;
            else
                use = false;
            end
            config_store.instance().store_config(this,'use_mex',use);
        end
        function this = set.force_mex_if_use_mex(this,val)
            if val>0
                use = true;
            else
                use = false;
            end
            config_store.instance().store_config(this,'force_mex_if_use_mex',use);
        end
        function this = set.log_level(this,val)
            if ~isnumeric(val)
                error('HERBERT_CONFIG:set_log_level',' log level should be a number')
            end
            config_store.instance().store_config(this,'log_level',val);
        end
        %
        function this=set.init_tests(this,val)
            if val>0
                init = true;
                path = process_unit_test_path(init,'set_path');
                if isempty(path)
                    return;
                end
            else
                init = false;
                process_unit_test_path(init,'set_path');
            end
            config_store.instance().store_config(this,'init_tests',init);
            
        end
        %------------------------------------------------------------------
        function folder=get.unit_test_folder(this)
            % getter for dependent property unit_test_folder;
            init = get_or_restore_field(this,'init_tests');
            if init
                folder = process_unit_test_path(init);
            else
                folder =[];
            end
        end
        
        %------------------------------------------------------------------
        function obj = set_unit_test_path(obj)
            % add Herbert unit test path to Matlab search path
            %
            % (overwrite Matlab's version of unit tests functions which
            % come with Matlab 2017b and have the interface different from
            % the classical unit tests.
            process_unit_test_path(true,'set_path');
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
end


