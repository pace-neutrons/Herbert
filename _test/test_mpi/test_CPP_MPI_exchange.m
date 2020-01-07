classdef test_CPP_MPI_exchange< TestCase
    %
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
    %
    
    properties
    end
    methods
        %
        function obj=test_CPP_MPI_exchange(name)
            if ~exist('name','var')
                name = 'test_CPP_MPI_exchange';
            end
            obj = obj@TestCase(name);
        end
        function test_JobExecutor(obj)
            if isempty(which('cpp_communicator'))
                return
            end
            serverfbMPI  = MessagesFilebased('test_JE_CppMPI');
            serverfbMPI.mess_exchange_folder = tmp_dir;
            
            [data_exchange_folder,JOB_id] = fileparts(serverfbMPI.mess_exchange_folder);
            cs = iMessagesFramework.build_worker_init(fileparts(data_exchange_folder),...
                JOB_id,'MessagesCppMPI',1,1,true);
            
            % intercomm constructor invoked here.
            [fbMPI,intercomm] = JobExecutor.init_frameworks(cs);
            clob1 = onCleanup(@()(finalize_all(intercomm)));
            clob2 = onCleanup(@()(finalize_all(fbMPI)));
            
            assertTrue(isa(intercomm,'MessagesCppMPI'));
            assertEqual(intercomm.labIndex,uint64(1));
            assertEqual(intercomm.numLabs,uint64(1));
            
            
            je = JETester();
            common_job_param = struct('filepath',data_exchange_folder,...
                'filename_template','test_jobDispatcherL%d_nf%d.txt',...
                'fail_for_labsN',2:3);
            im = InitMessage(common_job_param,1,1,1);
            
            je = je.init(fbMPI,intercomm,im,true);
            
            
            [ok,err_mess,message] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            assertEqual(message.mess_name,'started')
            
            
        end
        function test_SendReceive(obj)
            % Test communications in test mode
            if isempty(which('cpp_communicator'))
                return
            end
            mf = MessagesCppMPI_tester();
            clob = onCleanup(@()(finalize_all(mf)));
            
            assertEqual(mf.labIndex,uint64(1));
            assertEqual(mf.numLabs,uint64(10));
            
            mess = LogMessage(1,10,1,[]);
            [ok,err_mess]  = mf.send_message(5,mess);
            assertEqual(ok,MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            
            [ok,err_mess,messR]  = mf.receive_message(5,mess.mess_name);
            assertEqual(ok,MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            assertEqual(mess,messR);
            
            [ok,err_mess,messR]  = mf.receive_message(5,mess.mess_name);
            assertEqual(ok,MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            assertTrue(isempty(messR));
            
            % blocking receive in test node is not alowed
            [ok,err_mess,messR] = mf.receive_message(5,'init');
            assertEqual(ok,MESS_CODES.a_recieve_error);
            assertTrue(isempty(messR));
            assertEqual(err_mess,'Synchronized wating in test mode is not alowed');
            
            
            [ok,err_mess]  = mf.send_message(4,mess);
            assertEqual(ok,MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            
            [ok,err_mess,messR]  = mf.receive_message(5,'any');
            assertEqual(ok,MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            assertTrue(isempty(messR));
            
            [ok,err_mess,messR]  = mf.receive_message(4,'any');
            assertEqual(ok,MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            assertEqual(mess,messR);
            
            [ok,err_mess]  = mf.send_message(6,mess);
            assertEqual(ok,MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            
            [ok,err_mess,messR]  = mf.receive_message('any','any');
            assertEqual(ok,MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            assertEqual(mess,messR);
        end
        function test_OutOfRange(obj)
            % Test communications in test mode
            if isempty(which('cpp_communicator'))
                return
            end
            % only 10 pseudo-workers are defined here.
            mf = MessagesCppMPI_tester();
            clob = onCleanup(@()(finalize_all(mf)));
            mess = LogMessage(1,10,1,[]);
            assertEqual(mf.labIndex,uint64(1));
            assertEqual(mf.numLabs,uint64(10));
            
            
            f = @()send_message(mf,0,mess);
            assertExceptionThrown(f,'MESSAGES_CPP_MPI:invalid_argument')
            
            f = @()send_message(mf,11,mess);
            assertExceptionThrown(f,'MESSAGES_CPP_MPI:invalid_argument')
            
            f = @()receive_message(mf,0,mess.mess_name);
            assertExceptionThrown(f,'MESSAGES_CPP_MPI:invalid_argument')
            
            f = @()receive_message(mf,11,mess.mess_name);
            assertExceptionThrown(f,'MESSAGES_CPP_MPI:invalid_argument')
            
        end
        %
        function test_Send3Receive1Asynch(obj)
            % Test communications in test mode
            if isempty(which('cpp_communicator'))
                return
            end
            mf = MessagesCppMPI_tester();
            clob = onCleanup(@()(finalize_all(mf)));
            
            assertEqual(mf.labIndex,uint64(1));
            assertEqual(mf.numLabs,uint64(10));
            
            mess = LogMessage(1,10,1,[]);
            [ok,err_mess]  = mf.send_message(5,mess);
            assertEqual(ok,MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            mess = LogMessage(2,10,3,[]);
            [ok,err_mess]  = mf.send_message(5,mess);
            assertEqual(ok,MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            
            mess = LogMessage(3,10,5,[]);
            [ok,err_mess]  = mf.send_message(5,mess);
            assertEqual(ok,MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            
            [ok,err_mess,messR]  = mf.receive_message(5,mess.mess_name);
            assertEqual(ok,MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            
            assertEqual(mess,messR);
            
            [mess_names,source_id_s] = mf.probe_all(5,'any');
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
            
            assertEqual(mf.labIndex,uint64(1));
            assertEqual(mf.numLabs,uint64(10));
            
            mess = LogMessage(1,10,1,[]);
            [ok,err_mess]  = mf.send_message(5,mess);
            assertEqual(ok,MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            
            [mess_names,source_id_s] = mf.probe_all('any','any');
            assertEqual(numel(mess_names),1);
            assertEqual(numel(source_id_s),1);
            assertEqual(source_id_s(1),int32(5));
            assertEqual(mess_names{1},mess.mess_name);
            
            [ok,err_mess]  = mf.send_message(7,mess);
            assertEqual(ok,MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            
            [mess_names,source_id_s] = mf.probe_all('any','any');
            assertEqual(numel(mess_names),2);
            assertEqual(numel(source_id_s),2);
            assertEqual(source_id_s(1),int32(5));
            assertEqual(source_id_s(1),int32(7));
            assertEqual(mess_names{1},mess.mess_name);
            
        end
        
        function test_MessagesCppMPI_constructor(obj)
            if isempty(which('cpp_communicator'))
                return
            end
            mf = MessagesCppMPI_tester();
            clob = onCleanup(@()(finalize_all(mf)));
            
            assertEqual(mf.labIndex,uint64(1));
            assertEqual(mf.numLabs,uint64(10));
            [labNum,nLabs] = mf.get_lab_index();
            
            assertEqual(labNum,uint64(1));
            assertEqual(nLabs,uint64(1));
            
        end
        
        
    end
end


