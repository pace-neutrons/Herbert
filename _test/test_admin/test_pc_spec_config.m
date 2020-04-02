classdef test_pc_spec_config< TestCase
    % Testing default configuration manager, selecting
    % configuration as function of a pc type
    %
    properties
        working_dir;
    end
    methods
        %
        function this=test_pc_spec_config(name)
            if nargin<1
                name = 'test_pc_spec_config';
            end
            this = this@TestCase(name);
            this.working_dir = tmp_dir;
        end
        function test_load_config(obj)
            cm = opt_config_manager();
            assertTrue(isempty(cm.default_config));
            %
            % The strung sets configuration in memory. Should not be used
            % in tests.
            %cm = cm.load_configuration('-set_config','-change_only_default','-force_save');
            cm = cm.load_configuration();
            % Some pc type will be selected.
            assertFalse(isempty(cm.default_config));
            
            % check generic win_small configuration
            cm.this_pc_type = 'win_small';
            def_config = cm.default_config;
            assertFalse(def_config.hpc_config.build_sqw_in_parallel);
            assertEqual(def_config.hpc_config.mex_combine_thread_mode,0);
        end
        
        function test_constructor_and_initial_op(obj)
            herc = herbert_config;
            co1 = herc.get_data_to_store();
            parc = parallel_config();
            co2 = parc.get_data_to_store();
            clob_her = onCleanup(@()set(herc,co1));
            clob_par = onCleanup(@()set(parc,co2));
            if ~isempty(which('horace_init'))
                hc = hor_config();
                co3 = hc.get_data_to_store();
                hpc = hpc_config();
                co4 = hpc.get_data_to_store();
                clob_hc = onCleanup(@()set(hc,co3));
                clob_hpc = onCleanup(@()set(hpc,co4));
            else
                clob_hc = [];
                clob_hpc =[];
                
            end
            cm = opt_config_manager();
            source_dir = fileparts(which('opt_config_manager.m'));
            assertEqual(source_dir,cm.config_info_folder);
            % change config info folder to test save/load configuration.
            cm.config_info_folder = obj.working_dir;
            cm.this_pc_type = 'a_mac';
            assertEqual(cm.this_pc_type,'a_mac');
            
            conf_file = fullfile(cm.config_info_folder,cm.config_filename);
            clob = onCleanup(@()delete(conf_file));
            cm.save_configurations();
            assertTrue(exist(conf_file,'file')==2);
            
            hc = herbert_config;
            ll  = hc.log_level;
            hc.saveable = false;
            % set up different numer of threads
            hc.log_level= ll+1;
            assertEqual(hc.log_level,ll+1);
            
            cm.load_configuration('-set_config');
            % the previous number of threads have been restored
            assertEqual(hc.log_level,ll);
            
            % check that the configuration is stored/restored for second time
            cm.this_pc_type = 1;
            hc.log_level = ll+10;
            cm.save_configurations();
            assertTrue(exist(conf_file,'file')==2);
            hc.log_level=ll;
            cm.this_pc_type = 'a_mac';
            cm.load_configuration('-set_config');
            assertEqual(hc.log_level,ll);
        end
        
        function test_is_current_idaaas(obj)
            
            is = is_idaaas('some_host_name');
            assertFalse(is);
            
            is = is_idaaas('host_192_168_243_32');
            assertTrue(is);
        end
        %
        function test_set_pc_type(obj)
            cm = opt_config_manager();
            try
                cm.this_pc_type = 'rubbish';
                assertTrue(false,'No exception was thrown on invalid configuration')
            catch ME
                assertEqual(ME.identifier,'OPT_CONFIG_MANAGER:invalid_argument')
            end
            try
                cm.this_pc_type = -1;
                assertTrue(false,'No exception was thrown on invalid configuration')
            catch ME
                assertEqual(ME.identifier,'OPT_CONFIG_MANAGER:invalid_argument')
            end
            
            cm.this_pc_type = 1;
            assertEqual(cm.this_pc_type,'win_small');
            assertEqual(cm.pc_config_num,1);
            
            cm.this_pc_type = 7;
            assertEqual(cm.this_pc_type,'idaaas_large');
            assertEqual(cm.pc_config_num,7);
            
            cm.this_pc_type = 'a_mac';
            assertEqual(cm.this_pc_type,'a_mac');
            assertEqual(cm.pc_config_num,3);
            
            kpc = cm.known_pc_types;
            nconf = numel(kpc);
            for i=1:nconf
                cm.this_pc_type = i;
                assertEqual(cm.this_pc_type,kpc{i});
                assertEqual(cm.pc_config_num,i);
            end
            for i=1:nconf
                cm.this_pc_type = kpc{i};
                assertEqual(cm.this_pc_type,kpc{i});
                assertEqual(cm.pc_config_num,i);
            end
            
        end
    end
end

