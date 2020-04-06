classdef test_config_classes< TestCase
    % Test basic functionality of configuration classes
    %
    %   > >test_config_classes
    %
    % Author: T.G.Perring
    properties
        s0_def;
        s1_def;
        s2_def;
    end
    methods
        function this=test_config_classes(name)
            
            this = this@TestCase(name);
            
            %banner_to_screen(mfilename)
            
            % Set test config classes
            set(tgp_test_class,'default');
            set(tgp_test_class1,'default');
            set(tgp_test_class2,'default');
            
            ws=warning('off','CONFIG_STORE:restore_config');
            clob = onCleanup(@()warning(ws));
            
            this.s0_def=get(tgp_test_class);
            this.s1_def=get(tgp_test_class1);
            this.s2_def=get(tgp_test_class2);
            
        end
        function this=test_getstruct(this)
            config_store.instance().clear_config(tgp_test_class2,'-files');
            ws=warning('off','CONFIG_STORE:restore_config');
            clob = onCleanup(@()warning(ws));
            
            % ----------------------------------------------------------------------------
            % Test getting values from a configuration
            % ----------------------------------------------------------------------------
            s2_def_pub=get(tgp_test_class2);
            assertTrue(isequal(fieldnames(s2_def_pub),{'v1';'v2';'v3';'v4'}))
            assertTrue(isequal(this.s2_def.v1,s2_def_pub.v1))
            assertTrue(isequal(this.s2_def.v2,s2_def_pub.v2))
            
            [v1,v3]=get(tgp_test_class2,'v1','v3');
            
            assertTrue(isequal(this.s2_def.v1,v1),'Problem with: get(test2_config,''v1'',''v3'')')
            assertTrue(isequal(this.s2_def.v3,v3),'Problem with: get(test2_config,''v1'',''v3'')')
            
            config_store.instance().clear_config(tgp_test_class2,'-files');
        end
        
        function this=test_get_wrongCase(this)
            % This should fail because V3 is upper case, but the field is v3
            ws=warning('off','CONFIG_STORE:restore_config');
            clob = onCleanup(@()warning(ws));
            
            try
                [v1,v3]=get(tgp_test_class2,'v1','V3');
                ok=false;
            catch
                ok=true;
            end
            assertTrue(ok,'Problem with: get(test2_config,''v1'',''V3'')')
            
        end
        
        function this=test_get_and_save(this)
            % ----------------------------------------------------------------------------
            % Test getting values and saving
            % ----------------------------------------------------------------------------
            % Change the config without saving, change to default without saving - see that this is done properly
            ws = warning('off','CONFIG_STORE:restore_config');
            clob = onCleanup(@()warning(ws));
            
            set(tgp_test_class2,'v1',55,'-buffer');
            s2_buf=get(tgp_test_class2);
            
            set(tgp_test_class2,'def','-buffer');
            s2_tmp=get(tgp_test_class2);
            
            assertTrue(~isequal(s2_tmp,s2_buf),'Error in config classes code');
            assertTrue(isequal(s2_tmp,this.s2_def),'Error in config classes code');
            
            config_store.instance().clear_config(tgp_test_class2,'-files');
        end
        function this=test_set_withbuffer(this)
            set(tgp_test_class2,'v1',-30);
            s2_sav=get(tgp_test_class2);
            
            % Change the config without saving, change to save values, see this done properly
            set(tgp_test_class2,'v1',55,'-buffer');
            s2_buf=get(tgp_test_class2);
            
            set(tgp_test_class2,'save');
            s2_tmp=get(tgp_test_class2);
            
            assertTrue(~isequal(s2_tmp,s2_buf),'Error in config classes code')
            assertTrue(isequal(s2_tmp,s2_sav),'Error in config classes code')
            
            config_store.instance().clear_config(tgp_test_class2,'-files');
        end
        
        function this=test_set_herbert_tests(this)
            % Use presence or otherwise of TestCaseWithSave as a proxy for xunit tests on
            hc = herbert_config;
            old_config = hc.get_data_to_store();
            clob = onCleanup(@()set(hc,old_config));
            % Tests should be found as we are currently in a test suite
            found_on_entry = ~isempty(which('TestCaseWithSave.m'));
            assertTrue(found_on_entry);
            
            % Turn off tests
            set(herbert_config,'init_tests',0,'-buffer');
            found_when_init_tests_off = ~isempty(which('TestCaseWithSave.m'));
            
            % Turn tests back on
            set(herbert_config,'init_tests',1,'-buffer');
            found_when_init_tests_on = ~isempty(which('TestCaseWithSave.m'));
            
            % Can only use assertTrue, assertFalse etc when tests are on
            assertFalse(found_when_init_tests_off,' folder was not removed from search path properly');
            assertTrue(found_when_init_tests_on);
        end
        
    end
end
