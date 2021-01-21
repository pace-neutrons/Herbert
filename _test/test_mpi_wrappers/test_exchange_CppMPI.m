classdef test_exchange_CppMPI < exchange_common_tests


    properties
    end
    methods
        %
        function obj = test_exchange_CppMPI(name)
            if ~exist('name', 'var')
                name = 'test_exchange_CppMPI';
            end
            cs = struct('job_id','exchangeCppMPI','labID',1,'numLabs',3,...
                'test_mode',true);
            obj = obj@exchange_common_tests(name,...
                'MessagesCppMPI_tester','mpiexec_mpi',cs);
        end
        %
        %
        function test_OutOfRange(obj)
            % Test communications in test mode
            if obj.ignore_test
                skipTest();
            end
            % only 10 pseudo-workers are defined here.
            mf = MessagesCppMPI_tester();
            clob = onCleanup(@()(finalize_all(mf)));
            mess = LogMessage(1, 10, 1, []);
            assertEqual(mf.labIndex, 1);
            assertEqual(mf.numLabs, 10);


            f = @()send_message(mf, 0, mess);
            assertExceptionThrown(f, 'MESSAGES_FRAMEWORK:invalid_argument',...
                'CPP Messages framework can not communicate with lab 0' )

            f = @()send_message(mf, 11, mess);
            assertExceptionThrown(f, 'MESSAGES_FRAMEWORK:invalid_argument')

            f = @()receive_message(mf, 0, mess.mess_name);
            assertExceptionThrown(f, 'MESSAGES_FRAMEWORK:invalid_argument',...
                'CPP Messages framework can not communicate with lab 0' )

            f = @()receive_message(mf, 11, mess.mess_name);
            assertExceptionThrown(f, 'MESSAGES_FRAMEWORK:invalid_argument')

        end
        %
        %
        function test_MessagesCppMPI_constructor(obj)
            if obj.ignore_test
                skipTest();
            end
            mf = MessagesCppMPI_tester();
            clob = onCleanup(@()(finalize_all(mf)));

            assertEqual(mf.labIndex, 1);
            % fake numLabs, generated by tester.
            assertEqual(mf.numLabs, 10);
            %
            % get real lab-indexes, initiated in test mode.
            [nLabs,labNum] = mf.get_lab_index();

            assertEqual(labNum, int32(1));
            assertEqual(nLabs, int32(10));
        end
    end
end
