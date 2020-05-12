classdef test_CPP_MPI_exchange < MPI_Test_Common
    %
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
    %

    properties
    end
    methods
        %
        function obj = test_CPP_MPI_exchange(name)
            if ~exist('name', 'var')
                name = 'test_CPP_MPI_exchange';
            end
            obj = obj@MPI_Test_Common(name);
        end
        %
        function DISABLED_test_JobExecutor(obj)
            if isempty(which('cpp_communicator'))
                return
            end
            serverfbMPI = MessagesFilebased('test_JE_CppMPI');
            serverfbMPI.mess_exchange_folder = tmp_dir;

            [data_exchange_folder, JOB_id] = fileparts(serverfbMPI.mess_exchange_folder);
            cs = iMessagesFramework.build_worker_init(fileparts(data_exchange_folder), ...
                JOB_id, 'MessagesCppMPI_3wkrs_tester', 1, 3, true);

            % intercom constructor invoked here.
            [fbMPI, intercomm] = JobExecutor.init_frameworks(cs);
            clob1 = onCleanup(@()(finalize_all(intercomm)));
            clob2 = onCleanup(@()(finalize_all(fbMPI)));
            assertTrue(isa(intercomm, 'MessagesCppMPI'));
            assertEqual(intercomm.labIndex, uint64(1));
            assertEqual(intercomm.numLabs, uint64(3));


            % send fake messages, presumably generated by workers 2 and 3
            % JE will not run if not received these messages.
            m1 = aMessage('started');
            m1.payload = 'a';
            [ok, err_mess] = intercomm.send_message(2, m1);
            assertEqual(ok, MESS_CODES.ok, ['Error: ', err_mess]);
            m1.payload = 'b';
            [ok, err_mess] = intercomm.send_message(3, m1);
            assertEqual(ok, MESS_CODES.ok, ['Error: ', err_mess]);


            je = JETester();
            common_job_param = struct('filepath', data_exchange_folder, ...
                'filename_template', 'test_jobDispatcherL%d_nf%d.txt', ...
                'fail_for_labsN', 2:3);
            im = InitMessage(common_job_param, 1, 1, 1);
            % receive 'started' messages from all nodes reduce then and return
            % 'started' message to control node.
            je = je.init(fbMPI, intercomm, im, true);


            [ok, err_mess, message] = serverfbMPI.receive_message(1, 'started');
            assertEqual(ok, MESS_CODES.ok, ['Error: ', err_mess]);
            assertEqual(message.mess_name, 'started')
            assertEqual(numel(message.payload), 3);
            assertTrue(isempty(message.payload{1}));
            assertEqual(message.payload{2}, 'a');
            assertEqual(message.payload{3}, 'b');
            %--------------------------------------------------------------
            mess = LogMessage(0, 10, 1, '2');
            [ok, err] = intercomm.send_message(2, mess);
            assertEqual(ok, MESS_CODES.ok, ['Error = ', err])
            mess = LogMessage(1, 10, 1, '3');
            [ok, err] = intercomm.send_message(3, mess);
            assertEqual(ok, MESS_CODES.ok, ['Error = ', err])

            je.log_progress(1, 9, 2, '1');

            [ok, err_mess, message] = serverfbMPI.receive_message(1, 'log');
            assertEqual(ok, MESS_CODES.ok, ['Error: ', err_mess]);
            assertEqual(message.mess_name, 'log');
            assertEqual(numel(message.worker_logs), 3);
            assertTrue(iscell(message.worker_logs));

            mess = CompletedMessage();
            mess.payload = 'Job 2 has been completed';
            [ok, err] = intercomm.send_message(2, mess);
            assertEqual(ok, MESS_CODES.ok, ['Error = ', err])
            mess = FailedMessage('Test Failure from Node 3');
            [ok, err] = intercomm.send_message(3, mess);
            assertEqual(ok, MESS_CODES.ok, ['Error = ', err])


            [ok, err_mess] = je.finish_task();
            assertEqual(ok, true, ['Error: ', err_mess]);
            [ok, err_mess, message] = serverfbMPI.receive_message(1, 'log');
            assertEqual(ok, MESS_CODES.ok, ['Error: ', err_mess]);
            assertEqual(message.mess_name, 'failed');
            assertEqual(numel(message.payload), 3);
        end
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
        function test_SendReceive(obj)
            % Test communications in test mode
            if isempty(which('cpp_communicator'))
                return
            end
            mf = MessagesCppMPI_tester();
            clob = onCleanup(@()(finalize_all(mf)));

            assertEqual(mf.labIndex, uint64(1));
            assertEqual(mf.numLabs, uint64(10));

            mess = LogMessage(1, 10, 1, []);
            [ok, err_mess] = mf.send_message(5, mess);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));

            [ok, err_mess, messR] = mf.receive_message(5, mess.mess_name);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            assertEqual(mess, messR);

            [ok, err_mess, messR] = mf.receive_message(5, mess.mess_name);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            assertTrue(isempty(messR));

            % blocking receive in test node is not alowed
            [ok, err_mess, messR] = mf.receive_message(5, 'init');
            assertEqual(ok, MESS_CODES.a_recieve_error);
            assertTrue(isempty(messR));
            assertEqual(err_mess, 'Synchronized wating in test mode is not alowed');


            [ok, err_mess] = mf.send_message(4, mess);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));

            [ok, err_mess, messR] = mf.receive_message(5, 'any');
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            assertTrue(isempty(messR));

            [ok, err_mess, messR] = mf.receive_message(4, 'any');
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            assertEqual(mess, messR);

            [ok, err_mess] = mf.send_message(6, mess);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));

            [ok, err_mess, messR] = mf.receive_message('any', 'any');
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            assertEqual(mess, messR);
        end
        %
        function test_OutOfRange(obj)
            % Test communications in test mode
            if isempty(which('cpp_communicator'))
                return
            end
            % only 10 pseudo-workers are defined here.
            mf = MessagesCppMPI_tester();
            clob = onCleanup(@()(finalize_all(mf)));
            mess = LogMessage(1, 10, 1, []);
            assertEqual(mf.labIndex, uint64(1));
            assertEqual(mf.numLabs, uint64(10));


            f = @()send_message(mf, 0, mess);
            assertExceptionThrown(f, 'MESSAGES_CPP_MPI:invalid_argument')

            f = @()send_message(mf, 11, mess);
            assertExceptionThrown(f, 'MESSAGES_CPP_MPI:invalid_argument')

            f = @()receive_message(mf, 0, mess.mess_name);
            assertExceptionThrown(f, 'MESSAGES_CPP_MPI:invalid_argument')

            f = @()receive_message(mf, 11, mess.mess_name);
            assertExceptionThrown(f, 'MESSAGES_CPP_MPI:invalid_argument')

        end
        %
        function test_Send3Receive1Asynch(obj)
            % Test communications in test mode
            if isempty(which('cpp_communicator'))
                return
            end
            mf = MessagesCppMPI_tester();
            clob = onCleanup(@()(finalize_all(mf)));

            assertEqual(mf.labIndex, uint64(1));
            assertEqual(mf.numLabs, uint64(10));

            mess = LogMessage(1, 10, 1, []);
            [ok, err_mess] = mf.send_message(5, mess);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            mess = LogMessage(2, 10, 3, []);
            [ok, err_mess] = mf.send_message(5, mess);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));

            mess = LogMessage(3, 10, 5, []);
            [ok, err_mess] = mf.send_message(5, mess);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));

            [ok, err_mess, messR] = mf.receive_message(5, mess.mess_name);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));

            assertEqual(mess, messR);

            [mess_names, source_id_s] = mf.probe_all(5, 'any');
            assertTrue(isempty(mess_names));
            assertTrue(isempty(source_id_s));

        end
        %
        function test_SendProbe(obj)
            % Test communications in test mode
            if isempty(which('cpp_communicator'))
                return
            end
            mf = MessagesCppMPI_tester();
            clob = onCleanup(@()(finalize_all(mf)));

            assertEqual(mf.labIndex, uint64(1));
            assertEqual(mf.numLabs, uint64(10));

            mess = LogMessage(1, 10, 1, []);
            [ok, err_mess] = mf.send_message(5, mess);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));

            [mess_names, source_id_s] = mf.probe_all('any', 'any');
            assertEqual(numel(mess_names), 1);
            assertEqual(numel(source_id_s), 1);
            assertEqual(source_id_s(1), int32(5));
            assertEqual(mess_names{1}, mess.mess_name);

            [ok, err_mess] = mf.send_message(7, mess);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));

            [mess_names, source_id_s] = mf.probe_all('any', 'any');
            assertEqual(numel(mess_names), 2);
            assertEqual(numel(source_id_s), 2);
            assertEqual(source_id_s(1), int32(5));
            assertEqual(source_id_s(2), int32(7));
            assertEqual(mess_names{1}, mess.mess_name);

        end
        %
        function test_MessagesCppMPI_constructor(obj)
            if isempty(which('cpp_communicator'))
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
    end
end
