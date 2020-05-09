classdef test_MESS_NAMES_factory< TestCase
    %
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
    %
    properties
    end
    methods
        %
        function obj=test_MESS_NAMES_factory(name)
            if ~exist('name','var')
                name = 'test_MESS_NAMES_factory';
            end
            obj = obj@TestCase(name);
        end
        function test_persistent(obj)
            is = MESS_NAMES.is_persistent('failed');
            assertTrue(is);
            
            is = MESS_NAMES.is_persistent(0);
            assertTrue(is);
            
            mess = aMessage('canceled');
            is = MESS_NAMES.is_persistent(mess);
            assertFalse(is);
            
        end
        %
        function test_selection(obj)
            name = MESS_NAMES.mess_name(8);
            assertTrue(iscell(name));
            assertEqual(numel(name),1);
            
            is = MESS_NAMES.name_exist(name);
            assertTrue(is);
            is = MESS_NAMES.name_exist(name{1});
            assertTrue(is);
            
            
            id = MESS_NAMES.mess_id(name);
            assertEqual(id,8);
            id = MESS_NAMES.mess_id(name{1});
            assertEqual(id,8);
            
            selection = [1,3,5];
            names = MESS_NAMES.mess_name(selection);
            is = MESS_NAMES.name_exist(names);
            assertTrue(is);
            
            ids = MESS_NAMES.mess_id(names);
            assertEqual(ids,selection);
            
            % failed message should have 0 id, as its hardcoded in
            % filebased messages
            ids = MESS_NAMES.mess_id('failed');
            assertEqual(ids,0);
        end
        %
        function test_operations(obj)
            names = MESS_NAMES.all_mess_names();
            
             for i=1:numel(names)
                name = names{i};
                assertTrue(MESS_NAMES.name_exist(name));
                [~,mess] = MESS_NAMES.mess_class_name(name);
                
                assertEqual(mess.mess_name,name);
                assertEqual(mess.is_blocking,is_blocking(i));
                assertEqual(tag2name_map(i-2),name);
                if MESS_NAMES.is_persistent(name)
                    assertEqual(name2tag_map(name),0);
                else
                    assertEqual(name2tag_map(name),i-2);
                end
            end
        end
        
        
        function test_specialized_classes(obj)
            % initialize empty init message using generic constructor
            try
                mc = aMessage('init');
                thrown = false;
            catch ME
                thrown = true;
                assertEqual(ME.identifier,'AMESSAGE:invalid_argument');
            end
            assertTrue(thrown,' Successfull attempt to intialize specialized message using generic constructor');
                        
            mc = InitMessage('some init info');
            assertTrue(isa(mc,'InitMessage'));            
            
            assertEqual(mc.common_data,'some init info');
        end
    end
end


