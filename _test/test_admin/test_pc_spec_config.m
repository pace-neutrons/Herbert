classdef test_pc_spec_config< TestCase
    %
    % $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)
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
            this.working_dir = tempdir;
        end
        function test_constructor_and_initial_op(obj)
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
            
            hc = hor_config;
            n_threads = hc.threads;
            hc.saveable = false;
            % set up different numer of threads
            hc.threads = n_threads+1;
            assertEqual(hc.threads,n_threads+1);
            
            cm.load_configuration('-set_config');
            % the previous number of threads have been restored
            assertEqual(hc.threads,n_threads);
            
            % check that the configuration is stored/restored for second time
            cm.this_pc_type = 1;
            hc.threads = n_threads+10;
            cm.save_configurations();
            assertTrue(exist(conf_file,'file')==2);
            hc.threads=n_threads;
            cm.this_pc_type = 'a_mac';
            cm.load_configuration('-set_config');
            assertEqual(hc.threads,n_threads);
        end
        
        function test_is_current_idaaas(obj)
            
            is = is_idaaas('some_host_name');
            assertFalse(is);
            
            is = is_idaaas('host_192_168_243_32');
            assertTrue(is);
        end
        function test_set_pc_type(obj)
            cm = opt_config_manager();
            try
                cm.this_pc_type = 'rubbish';
                assertTrue(false,'No exception was thrown on invalid argument')
            catch ME
                assertEqual(ME.identifier,'OPT_CONFIG_MANAGER:invalid_argument')
            end
            try
                cm.this_pc_type = -1;
                assertTrue(false,'No exception was thrown on invalid argument')
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
        end
        
    end
end
