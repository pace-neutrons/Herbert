classdef test_exchange_CppMPI < exchange_common_tests
    
    
    properties
    end
    methods
        %
        function obj = test_exchange_CppMPI(name)
            if ~exist('name', 'var')
                name = 'test_exchange_CppMPI';
            end
            obj = obj@exchange_common_tests(name,...
                'MessagesCppMPI_tester','mpiexec_mpi');
            
            obj.ignore_test = isempty(which('cpp_communicator'));
            if obj.ignore_test
                warning('test_exchange_CppMPI:test_disabled',...
                    'CPP MPI tests disabled -- no access to cpp_communicator');
            end
        end
        %
        %
        function test_receive_all_mess(this)
            
            intercomm = MessagesCppMPI_3wkrs_tester();
            clob1 = onCleanup(@()(finalize_all(intercomm)));
            
            mess = LogMessage(0, 10, 1, '0');
            % CPP_MPI messages in test mode are "reflected" from target node
            [ok, err] = intercomm.send_message(2, mess);
            assertEqual(ok, MESS_CODES.ok, ['Error = ', err])
            [ok, err] = intercomm.send_message(3, mess);
            assertEqual(ok, MESS_CODES.ok, ['Error = ', err])
            
            [all_mess, task_ids] = intercomm.receive_all('any', 'any');
            assertEqual(numel(all_mess), 2);
            assertEqual(numel(task_ids), 2);
            assertEqual(task_ids, [2; 3]);
        end
        
        %
        %
        function test_OutOfRange(obj)
            % Test communications in test mode
            if obj.ignore_test
                return
            end
            % only 10 pseudo-workers are defined here.
            mf = MessagesCppMPI_tester();
            clob = onCleanup(@()(finalize_all(mf)));
            mess = LogMessage(1, 10, 1, []);
            assertEqual(mf.labIndex, uint64(1));
            assertEqual(mf.numLabs, uint64(10));
            
            
            f = @()send_message(mf, 0, mess);
            assertExceptionThrown(f, 'MESSAGES_FRAMEWORK:invalid_argument')
            
            f = @()send_message(mf, 11, mess);
            assertExceptionThrown(f, 'MESSAGES_FRAMEWORK:invalid_argument')
            
            f = @()receive_message(mf, 0, mess.mess_name);
            assertExceptionThrown(f, 'MESSAGES_FRAMEWORK:invalid_argument')
            
            f = @()receive_message(mf, 11, mess.mess_name);
            assertExceptionThrown(f, 'MESSAGES_FRAMEWORK:invalid_argument')
            
        end
        %
        %
        function test_MessagesCppMPI_constructor(obj)
            if obj.ignore_test
                return
            end
            mf = MessagesCppMPI_tester();
            clob = onCleanup(@()(finalize_all(mf)));
            
            assertEqual(mf.labIndex, uint64(1));
            % fake numLabs, generated by tester.
            assertEqual(mf.numLabs, uint64(10));
            %
            % get real lab-indexes, initiated in test mode.
            [labNum, nLabs] = mf.get_lab_index();
            
            assertEqual(labNum, uint64(1));
            assertEqual(nLabs, uint64(1));
        end
        function test_JobExecutor(obj)
            if obj.ignore_test
                return
            end
            warning('JobExecutor test for CPP MPI is currently disabled')
        end
        
    end
end
