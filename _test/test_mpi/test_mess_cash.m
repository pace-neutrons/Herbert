classdef test_mess_cash < TestCase
    %
    % $Revision: 702 $ ($Date: 2018-02-12 19:05:22 +0000 (Mon, 12 Feb 2018) $)
    %
    
    properties
    end
    methods
        %
        function this=test_mess_cash(name)
            if ~exist('name','var')
                name = 'test_mess_cash';
            end
            this = this@TestCase(name);
        end
        
        function test_cash_operations(obj)
            
            mess_list{1} = aMessage('running');
            mess_list{2} = aMessage('running');
            mess_list{3} = aMessage('completed');
            mess_list{4} = aMessage('failed');
            tid = [3,4,5,9];
            
            mc = mess_cash.instance(10);
            mc.clear();            
            assertEqual(mc.cash_capacity,10)
            
            mc.push_messages(tid,mess_list);
            
            [mess_rec,tid ] = mess_cash.instance().pop_messages(1:4);
            assertEqual(numel(mess_rec),2)
            assertEqual(numel(tid ),2)
            assertEqual(tid(1),3);
            assertEqual(tid(2),4);
            assertEqual(mc.cash_capacity,10)
            
            mess_list1{1} = aMessage('running');
            mess_list1{2} = aMessage('completed');
            tid = [3,4];
            mc.push_messages(tid,mess_list1);
            
            assertEqual(mc.cash_capacity,10)
            assertEqual(mc.get_n_occupied(),4);
            
            [mess_rec,tid ] = mess_cash.instance().pop_messages([],'completed');
            assertEqual(numel(mess_rec),3)
            assertEqual(numel(tid ),3)
            assertEqual(tid(1),4);
            assertEqual(tid(2),5);
            assertEqual(tid(3),9);           
            assertTrue(strcmp(mess_rec{3}.mess_name,'failed'));
            assertEqual(mc.cash_capacity,10)
            %  failed messaged are persistent so should not be
            % removed from the cash while all other should
            assertEqual(mc.get_n_occupied(),2);
            
        end
        function test_cash_boolean(obj)
            mess_list = cell(1,10);
            tid = [3,5,7,9,10];
            mess_list{tid(1)} = aMessage('running');
            mess_list{tid(2)} = aMessage('running');
            mess_list{tid(3)} = aMessage('completed');
            mess_list{tid(4)} = aMessage('failed');
            mess_list{tid(5)} = aMessage('running');
            
            
            mc = mess_cash.instance(10);
            mc.clear();
            assertEqual(mc.cash_capacity,10)
            
            tid_bool = cellfun(@(x)~isempty(x),mess_list);
            mc.push_messages(tid_bool ,mess_list);
            assertEqual(mc.cash_capacity,10)
            
            [mess_rec,tid ] = mess_cash.instance().pop_messages(6:10,'running');
            assertEqual(numel(mess_rec),2)
            assertEqual(numel(tid ),2)
            assertEqual(tid(1),9);
            assertEqual(tid(2),10);
            assertTrue(strcmp(mess_rec{1}.mess_name,'failed'));
            
        end
    end
    
end
