classdef test_exchange_ParpoolMPI < exchange_common_tests
    
    properties
    end
    methods
        %
        function obj = test_exchange_ParpoolMPI(name)
            if ~exist('name', 'var')
                name = 'test_exchange_ParpoolMPI';
            end
            cs = struct('job_id','exchangeFileBasedMPI','labID',1,'numLabs',3,...
                'test_mode',true);
            obj = obj@exchange_common_tests(name,...
                'MessagesMatlabMPI_tester','parpool',cs);
            
            obj.ignore_test = ~license('checkout', 'Distrib_Computing_Toolbox');
            
        end
        %
        function test_MessagesMPIWrapper_two_mess_test_mode(~)
            mf = MessagesMatlabMPI_tester(2,6);
            clob = onCleanup(@()(finalize_all(mf)));
            
            assertTrue(mf.is_tested);
            
            assertEqual(mf.labIndex, 2);
            % fake numLabs, generated by tester.
            assertEqual(mf.numLabs, 6);
            %
            % get real lab-indexes, initiated in test mode.
            mpi_wrapper = mf.get_mpi_wrapper();
            
            assertTrue(mpi_wrapper.is_tested);
            assertEqual(mpi_wrapper.numLabs, 6);
            assertEqual(mpi_wrapper.labIndex, 2);
            
            mess1 = LogMessage(1,10,0);
            mess2 = FailedMessage('test failure');
            mpi_wrapper.mlabSend(mess1,5);
            mpi_wrapper.mlabSend(mess2,5);
            [avail,tag,source]=mpi_wrapper.mlabProbe(5);
            assertTrue(avail)
            assertEqual(tag,mess1.tag);
            assertEqual(source,5);
            [avail,tag,source]=mpi_wrapper.mlabProbe([]);
            assertTrue(avail)
            assertEqual(tag,mess1.tag);
            assertEqual(source,5);
            
            [mess_r,tag,source]=mpi_wrapper.mlabReceive(5);
            assertEqual(mess_r,mess1);
            assertEqual(tag,mess1.tag);
            assertEqual(source,5);
            [avail,tag,source]=mpi_wrapper.mlabProbe(5);
            assertTrue(avail)
            assertEqual(tag,mess2.tag);
            assertEqual(source,5);
            
            [mess_r,tag,source]=mpi_wrapper.mlabReceive(5);
            assertEqual(mess_r,mess2);
            assertEqual(tag,mess2.tag);
            assertEqual(source,5);
        end
        function test_MessagesMPIWrapper_two_mess_probe_test_mode(~)
            mf = MessagesMatlabMPI_tester(2,6);
            clob = onCleanup(@()(finalize_all(mf)));
            
            assertTrue(mf.is_tested);
            
            assertEqual(mf.labIndex, 2);
            % fake numLabs, generated by tester.
            assertEqual(mf.numLabs, 6);
            %
            % get real lab-indexes, initiated in test mode.
            mpi_wrapper = mf.get_mpi_wrapper();
            
            assertTrue(mpi_wrapper.is_tested);
            assertEqual(mpi_wrapper.numLabs, 6);
            assertEqual(mpi_wrapper.labIndex, 2);
            
            mess = LogMessage(1,10,0);
            mpi_wrapper.mlabSend(mess,5);
            mpi_wrapper.mlabSend(mess,3);
            [avail,tag,source]=mpi_wrapper.mlabProbe(5);
            assertTrue(avail)
            assertEqual(tag,mess.tag);
            assertEqual(source,5);
            %
            [avail,tag,source]=mpi_wrapper.mlabProbe([]);
            assertTrue(avail)
            assertEqual(numel(tag),2);
            assertEqual(tag(1),mess.tag);
            assertEqual(source(1),3);
            assertEqual(source(2),5);            

            [avail,tag,source]=mpi_wrapper.mlabProbe('all');
            assertTrue(avail)
            assertEqual(numel(tag),2);
            assertEqual(tag(1),mess.tag);
            assertEqual(source(1),3);
            assertEqual(source(2),5);            
            
        end
        
        %
        function test_MessagesMPIWrapper_one_mess_test1_send_receive(~)
            mf = MessagesMatlabMPI_tester();
            clob = onCleanup(@()(finalize_all(mf)));
            
            mess = InitMessage(1,10,0);
            tag = mess.tag;
            mpi_wrapper = mf.get_mpi_wrapper();
            assertExceptionThrown(@()mlabReceive(mpi_wrapper,2,tag),...
                'MESSAGES_FRAMEWORK:runtime_error',...
                'Should throw when trying to receive non-existing blocking message from wrong tag');
            
            
            % return nothing requesting missing non-blocking message
            [mess_r,tag,source]=mpi_wrapper.mlabReceive(2,tag+1);
            assertTrue(isempty(mess_r));
            assertEqual(tag,mess.tag+1);
            assertEqual(source,2);
            
            mpi_wrapper.mlabSend(mess,2);
            tag = mess.tag;
            
            
            [mess_r,tag_r,source]=mpi_wrapper.mlabReceive(2,tag);
            assertEqual(mess_r,mess);
            assertEqual(tag_r,mess.tag);
            assertEqual(source,2);
            
            
            mpi_wrapper.mlabSend(mess,2);
            [mess_r,tag_r,source]=mpi_wrapper.mlabReceive(2);
            assertEqual(mess_r,mess);
            assertEqual(tag_r,mess.tag);
            assertEqual(source,2);
            
            assertExceptionThrown(@()mlabReceive(mpi_wrapper,2,mess.tag),...
                'MESSAGES_FRAMEWORK:runtime_error',...
                'Should throw when trying to receive non-exising blocking message in test mode');
            
        end
        %
        function test_MessagesMPIWrapper_one_mess_test1(~)
            mf = MessagesMatlabMPI_tester();
            clob = onCleanup(@()(finalize_all(mf)));
            
            assertTrue(mf.is_tested);
            
            assertEqual(mf.labIndex, 1);
            % fake numLabs, generated by tester.
            assertEqual(mf.numLabs, 10);
            %
            % get real lab-indexes, initiated in test mode.
            mpi_wrapper = mf.get_mpi_wrapper();
            
            assertTrue(mpi_wrapper.is_tested);
            assertEqual(mpi_wrapper.numLabs, 10);
            assertEqual(mpi_wrapper.labIndex, 1);
            
            mess = LogMessage(1,10,0);
            mpi_wrapper.mlabSend(mess,5);
            [avail,tag,source]=mpi_wrapper.mlabProbe(5);
            assertTrue(avail)
            assertEqual(tag,mess.tag);
            assertEqual(source,5);
            [avail,tag,source]=mpi_wrapper.mlabProbe(6);
            assertFalse(avail)
            assertTrue(isempty(tag));
            assertEqual(source,6);
            

            [avail,tag,source]=mpi_wrapper.mlabProbe('all');
            assertTrue(avail)
            assertEqual(tag,mess.tag);
            assertEqual(source,5);
            
            assertExceptionThrown(@()mlabReceive(mpi_wrapper,[]),...
                'MESSAGES_FRAMEWORK:invalid_argument',...
                'Should throw when trying to receive message from undefined lab');
            
            [mess_r,tag,source]=mpi_wrapper.mlabReceive(5);
            assertEqual(mess_r,mess);
            assertEqual(tag,mess.tag);
            assertEqual(source,5);
            
            [avail,tag,source]=mpi_wrapper.mlabProbe(5);
            assertFalse(avail)
            assertTrue(isempty(tag));
            assertEqual(source,5);
            
            
            [avail,tag,source]=mpi_wrapper.mlabProbe([]);
            assertFalse(avail)
            assertTrue(isempty(tag));
            assertTrue(isempty(source));
            
        end
    end
end
