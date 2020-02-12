classdef test_FileBaseMPI_Framework< TestCase
    %
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
    %
    
    properties
        working_dir
        old_config
        % if default current framework is not a Herbert framework,
        % one need to change the setup
        change_setup = false;
    end
    methods
        %
        function this=test_FileBaseMPI_Framework(name)
            if ~exist('name','var')
                name = 'test_FileBaseMPI_Framework';
            end
            this = this@TestCase(name);
            this.working_dir = tmp_dir;
            disp(['Running test_FileBaseMPI_Framework with working_dir = ', this.working_dir])
            pc = parallel_config;
            if strcmpi(pc.parallel_framework,'herbert')
                this.change_setup = false;
            else
                this.old_config = pc.get_data_to_store;
                pc.parallel_framework = 'herbert';
                this.change_setup = true;
            end
        end
        %
        function setUp(obj)
            if obj.change_setup
                pc = parallel_config;
                pc.parallel_framework = 'herbert';
            end
        end
        function teadDown(obj)
            if obj.change_setup
                set(parallel_config,obj.old_config);
            end
        end
        
        
        %
        function test_finalize_all(this)
            mf = MFTester('test_finalize_all');
            [ok,err]=mf.send_message(0,'starting');
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            [ok,err]=mf.send_message(0,'log');
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            %
            ok=mf.receive_message(0,'starting');
            assertEqual(ok,MESS_CODES.ok)
            ok = mf.receive_message(0,'log');
            assertEqual(ok,MESS_CODES.ok)
            
            
            [all_messages_names,task_ids] = mf.probe_all(0,'log');
            assertTrue(isempty(all_messages_names));
            assertTrue(isempty(task_ids));
            %
            
            
            ok = mf.is_job_canceled();
            assertFalse(ok);
            mf.finalize_all();
            ok = mf.is_job_canceled();
            assertTrue(ok);
        end
        %
        function test_message(this)
            fiis = iMessagesFramework.build_worker_init(this.working_dir,...
                'test_message','MessagesFilebased',0,3);
            fii = iMessagesFramework.deserialize_par(fiis);
            
            %
            job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcher%d_nf%d.txt');
            
            mess = aMessage('starting');
            mess.payload = job_param;
            
            mf0 = MFTester(fii);
            clob = onCleanup(@()mf0.finalize_all());
            [ok,err] = mf0.send_message(1,mess);
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            
            mess_fname = mf0.mess_name(1,'starting');
            assertTrue(exist(mess_fname,'file')==2);
            %
            fii.labID = 1;
            mf1 = MFTester(fii);
            [ok,err,the_mess]=mf1.receive_message(0,'starting');
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            assertFalse(exist(mess_fname,'file')==2);% Message received
            
            cont = the_mess.payload;
            assertEqual(job_param,cont);
            
            [all_messages_names,task_ids] = mf1.probe_all(0,'log');
            assertTrue(isempty(all_messages_names));
            assertTrue(isempty(task_ids));
            
            
            job_exchange_folder = fileparts(mess_fname);
            assertTrue(exist(job_exchange_folder,'dir') == 7)
            mf0.finalize_all();
            assertFalse(exist(job_exchange_folder,'dir') == 7)
        end
        %
        function test_receive_all_mess(this)
            fiis = iMessagesFramework.build_worker_init(this.working_dir,...
                'FB_MPI_Test_recevie_all','MessagesFilebased',0,3);
            fii = iMessagesFramework.deserialize_par(fiis);
            mf0 = MessagesFilebased(fii);
            
            clob = onCleanup(@()(mf0.finalize_all()));
            fii.labID = 1;
            mf1 = MessagesFilebased(fii);
            fii.labID = 2;
            mf2 = MessagesFilebased(fii);
            fii.labID = 3;
            mf3 = MessagesFilebased(fii);
            
            
            mess = aMessage('starting');
            [ok,err] = mf0.send_message(2,mess);
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            [messo,task_id] = mf2.receive_all(0);
            
            assertEqual(numel(messo),1);
            assertEqual(numel(task_id),1);
            assertEqual(task_id(1),0);
            assertEqual(messo{1}.mess_name,'starting')
            
            ok = mf0.send_message(3,mess);
            assertEqual(ok,MESS_CODES.ok)
            %
            [mess,task_id] = mf3.receive_all(0,'starting');
            assertEqual(numel(mess),1);
            assertEqual(numel(task_id),1);
            assertEqual(task_id(1),0);
            assertEqual(mess{1}.mess_name,'starting')
            %
            % Send 3 messages from "3 labs" and receive all of them
            % on the control lab
            ok = mf1.send_message(0,'started');
            assertEqual(ok,MESS_CODES.ok)
            
            ok = mf2.send_message(0,'started');
            assertEqual(ok,MESS_CODES.ok)
            
            ok = mf3.send_message(0,'started');
            assertEqual(ok,MESS_CODES.ok)
            
            
            [mess,task_id] = mf0.receive_all();
            assertEqual(numel(mess),3);
            assertEqual(numel(task_id),3);
            assertEqual(task_id(1),1);
            assertEqual(task_id(2),2);
            assertEqual(task_id(3),3);
        end
        %
        function test_probe_all(this)
            mf = MessagesFilebased('MFT_probe_all_messages');
            clob = onCleanup(@()(mf.finalize_all()));
            
            all_mess = mf.probe_all(1);
            assertTrue(isempty(all_mess));
            
            
            mess = aMessage('starting');
            % send message to itself
            [ok,err] = mf.send_message(0,mess);
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            [all_mess,mid_from] = mf.probe_all();
            assertTrue(ismember('starting',all_mess))
            assertFalse(ismember('started',all_mess))
            assertEqual(mid_from,0);
            
            
            [all_mess,mid_from] = mf.probe_all(0);
            assertTrue(ismember('starting',all_mess))
            assertEqual(mid_from,0);
            [all_mess,mid_from] = mf.probe_all(0,'starting');
            assertTrue(ismember('starting',all_mess))
            assertEqual(mid_from,0);
            
            
            
            [ok,err] = mf.send_message(0,'started');
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            mess = FailedMessage('failed');
            [ok,err] = mf.send_message(3,mess);
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            
            mess = aMessage('log');
            [ok,err] = mf.send_message(3,mess);
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            
            [all_mess,mid_from] = mf.probe_all(0);
            assertEqual(numel(all_mess),2);
            assertEqual(all_mess{1},'started');
            assertEqual(mid_from(1),0);
            assertEqual(mid_from(2),0);
            
            %
            %-------------------------------------------------------------
            % define external receiver, which would run on an MPI worker
            cs = mf.build_worker_init(mf.mess_exchange_folder,...
                mf.job_id,'MessagesFilebased',3,5);
            
            init_str = mf.deserialize_par(cs);
            mf3 = MessagesFilebased(init_str);
            [all_mess,id_from] = mf3.probe_all();
            
            
            assertEqual(numel(all_mess),2);
            assertEqual(id_from(1),0);
            assertEqual(id_from(2),0);
            
            mess = aMessage('log');
            % unlike normal mpi, filebased mpi allows sending message to
            % itself
            [ok,err] = mf3.send_message(3,mess);
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            
            
            [all_mess,id_from] = mf3.probe_all();
            assertEqual(numel(all_mess),3);
            assertEqual(id_from(1),0);
            assertEqual(id_from(2),0);
            assertEqual(id_from(3),3);
            
            
            [all_mess,id_from] = mf3.probe_all([0,3]);
            assertEqual(numel(all_mess),3);
            assertEqual(id_from(1),0);
            assertEqual(id_from(2),0);
            assertEqual(id_from(3),3);
            
            [all_mess,id_from] = mf3.probe_all('any','log');
            assertEqual(numel(all_mess),3);
            assertEqual(id_from(1),0);
            assertEqual(id_from(2),0);
            assertEqual(id_from(3),3);
        end
        
        function lock_file=build_fake_lock(this,mf,mess_name)
            mess_file = mf.mess_name(0,mess_name);
            [fp,fn] = fileparts(mess_file);
            lock_file = fullfile(fp,[fn,'.lockw']);
            fh = fopen(lock_file,'w');
            fclose(fh);
        end
        
        function test_ignore_locked(this)
            % test verifies that filebased messages which have lock are not
            % observed by the system until unlocked.
            function del_file(fname)
                if exist(fname,'file') == 2
                    delete(fname);
                end
            end
            mf = MessagesFilebased('MFT_ignore_locked_messages');
            clob = onCleanup(@()(mf.finalize_all()));
            
            all_mess = mf.probe_all(1);
            assertTrue(isempty(all_mess));
            
            
            mess = aMessage('starting');
            % send message to itself
            [ok,err] = mf.send_message(0,mess);
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            [all_mess,mid_from] = mf.probe_all();
            assertTrue(ismember('starting',all_mess))
            assertFalse(ismember('started',all_mess))
            assertEqual(mid_from,0);
            lock_starting = this.build_fake_lock(mf,'starting');
            clob_lock1 = onCleanup(@()del_file(lock_starting));
            
            all_mess = mf.probe_all();
            assertTrue(isempty(all_mess));
            
            
            % send another message to itself
            [ok,err] = mf.send_message(0,'started');
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            
            [all_mess,mid_from] = mf.probe_all();
            assertTrue(ismember('started',all_mess))
            assertEqual(mid_from,0);
            
            % create fake lock:
            lock_started = this.build_fake_lock(mf,'started');
            clob_lock2 = onCleanup(@()del_file(lock_started));
            all_mess = mf.probe_all();
            assertTrue(isempty(all_mess));
            
            % create just lock (no file yet)
            lock_running = this.build_fake_lock(mf,'log');
            clob_lock3 = onCleanup(@()del_file(lock_running ));
            
            all_mess = mf.probe_all();
            assertTrue(isempty(all_mess));
            
            
            delete(lock_starting);
            
            all_mess = mf.probe_all();
            assertTrue(ismember('starting',all_mess))
            assertEqual(mid_from,0);
            
            delete(lock_started);
            
            all_mess = mf.probe_all();
            assertEqual(numel(all_mess),2);
            
            [ok,err]=mf.receive_message(0,'starting');
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            
            all_mess = mf.probe_all();
            assertEqual(numel(all_mess),1);
            
            [ok,err]=mf.receive_message(0,'started');
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            
            all_mess = mf.probe_all();
            assertTrue(isempty(all_mess));
            
            
        end
        
        %
        function test_shared_folder(this)
            mf = MessagesFilebased();
            mf.mess_exchange_folder = this.working_dir;
            mf = mf.init_framework('test_shared_folder');
            clob = onCleanup(@()mf.finalize_all());
            
            cfn = config_store.instance().config_folder_name;
            jfn = fullfile(this.working_dir,cfn,mf.exchange_folder_name,mf.job_id);
            assertEqual(exist(jfn,'dir'),7);
            
            [ok,err] = mf.send_message(0,'starting');
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            
            [ok,err,the_mess] = mf.receive_message(0,'starting');
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            assertEqual(the_mess.mess_name,'starting');
            
            clear clob;
            assertTrue(exist(jfn,'dir')==0);
        end
        %
        function test_barrier(this)
            mf = MessagesFilebased('test_barrier');
            mf.mess_exchange_folder = this.working_dir;
            clob = onCleanup(@()mf.finalize_all());
            % create three pseudo-independent message exchange classes
            % presumably to run on independent workers
            css1 = iMessagesFramework.build_worker_init(...
                this.working_dir,mf.job_id,'MessagesFilebased',1,3);
            cs1  = iMessagesFramework.deserialize_par(css1);
            css2 = iMessagesFramework.build_worker_init(...
                this.working_dir,mf.job_id,'MessagesFilebased',2,3);
            cs2  = iMessagesFramework.deserialize_par(css2);
            css3 = iMessagesFramework.build_worker_init(...
                this.working_dir,mf.job_id,'MessagesFilebased',3,3);
            cs3 =  iMessagesFramework.deserialize_par(css3);
            
            fbMPI1 = MessagesFilebased(cs1);
            fbMPI2 = MessagesFilebased(cs2);
            fbMPI3 = MessagesFilebased(cs3);
            
            t0 = fbMPI3.time_to_fail;
            fbMPI3.time_to_fail = 0.1;
            % barrier fails at waiting time due to short time to fail
            try
                fbMPI3.labBarrier(false);
            catch ME
                assertEqual(ME.message,...
                    'Timeout waiting for message "barrier" for task with id: 3');
            end
            fbMPI2.time_to_fail = 0.1;
            try
                fbMPI2.labBarrier(false);
            catch ME
                assertEqual(ME.message,...
                    'Timeout waiting for message "barrier" for task with id: 2');
            end
            
            fbMPI3.time_to_fail = t0;
            fbMPI2.time_to_fail = t0;
            
            
            % will pass without delay as all other worker would reach the
            % barrier
            ok = fbMPI1.labBarrier(false);
            assertTrue(ok);
            
            % and other workers would pass barrier now
            ok = fbMPI3.labBarrier(false);
            assertTrue(ok);
            ok = fbMPI2.labBarrier(false);
            assertTrue(ok);
            
            % clear up the barrier messages
            [ok,err,mess] = fbMPI1.receive_message(2,'barrier');
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            assertEqual(mess.mess_name,'barrier');
            
            [ok,err,mess] = fbMPI1.receive_message(3,'barrier');
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            assertEqual(mess.mess_name,'barrier');
            
        end
        %
        function test_barrier_fail(this)
            mf = MessagesFilebased('test_barrier_fail');
            mf.mess_exchange_folder = this.working_dir;
            clob = onCleanup(@()mf.finalize_all());
            % create three pseudo-independent message exchange classes
            % presumably to run on independent workers
            css1 = iMessagesFramework.build_worker_init(...
                this.working_dir,mf.job_id,'MessagesFilebased',1,3);
            cs1  = iMessagesFramework.deserialize_par(css1);
            css2 = iMessagesFramework.build_worker_init(...
                this.working_dir,mf.job_id,'MessagesFilebased',2,3);
            cs2  = iMessagesFramework.deserialize_par(css2);
            css3 = iMessagesFramework.build_worker_init(...
                this.working_dir,mf.job_id,'MessagesFilebased',3,3);
            cs3 =  iMessagesFramework.deserialize_par(css3);
            
            fbMPI1 = MessagesFilebased(cs1);
            fbMPI2 = MessagesFilebased(cs2);
            fbMPI3 = MessagesFilebased(cs3);
            
            t0 = fbMPI3.time_to_fail;
            fbMPI3.time_to_fail = 0.1;
            % barrier fails at waiting time due to short time to fail
            try
                fbMPI3.labBarrier(false);
            catch ME
                assertEqual(ME.message,...
                    'Timeout waiting for message "barrier" for task with id: 3');
            end
            fbMPI2.time_to_fail = 0.1;
            [ok,err]=fbMPI2.send_message(1,'failed');
            assertEqual(ok,MESS_CODES.ok,err)
            
            
            % will pass without delay as all other worker would reach the
            % barrier
            ok = fbMPI1.labBarrier(false);
            assertTrue(ok);
            
            % and other workers would pass barrier now
            ok = fbMPI3.labBarrier(false);
            assertTrue(ok);
            ok = fbMPI2.labBarrier(false);
            assertTrue(ok);
            
            % clear up the barrier messages
            [ok,err,mess] = fbMPI1.receive_message(2,'barrier');
            assertEqual(ok,MESS_CODES.ok,err)
            assertEqual(mess.mess_name,'failed');
            
            [ok,err,mess] = fbMPI1.receive_message(3,'barrier');
            assertEqual(ok,MESS_CODES.ok,err)
            assertEqual(mess.mess_name,'barrier');
            
        end
        %
        function test_data_queue(obj)
            css1 = iMessagesFramework.build_worker_init(obj.working_dir,...
                'test_data_queue','MessagesFilebased',1,3);
            cs1  = iMessagesFramework.deserialize_par(css1);
            
            sender = MessagesFilebased(cs1);
            clob = onCleanup(@()sender.finalize_all());
            
            css2 = iMessagesFramework.build_worker_init(obj.working_dir,...
                'test_data_queue','MessagesFilebased',2,3);
            cs2  = iMessagesFramework.deserialize_par(css2);
            receiver = MessagesFilebased(cs2);
            
            mess = DataMessage();
            mess.payload  = 1;
            [ok,err] = sender.send_message(2,mess);
            assertEqual(ok,MESS_CODES.ok,err);
            mess.payload  = 2;
            [ok,err] = sender.send_message(2,mess);
            assertEqual(ok,MESS_CODES.ok,err);
            
            mess.payload  = 3;
            [ok,err] = sender.send_message(2,mess);
            assertEqual(ok,MESS_CODES.ok,err);
            
            [all_mess,mid_from] = receiver.probe_all([],'data');
            assertEqual(numel(all_mess),3)
            assertEqual(mid_from,ones(3,1))
            
            [ok,err,mess] = receiver.receive_message(1,'data');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.payload,1);
            
            [all_mess,mid_from] = receiver.probe_all([],'data');
            assertEqual(numel(all_mess),2)
            assertEqual(mid_from,ones(2,1))
            
            
            mess.payload  = 4;
            [ok,err] = sender.send_message(2,mess);
            assertEqual(ok,MESS_CODES.ok,err);
            
            [ok,err,mess] = receiver.receive_message(1,'data');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.payload,2);
            
            [ok,err,mess] = receiver.receive_message(1,'data');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.payload,3);
            
            [ok,err,mess] = receiver.receive_message(1,'data');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.payload,4);
            
            [all_mess,mid_from] = receiver.probe_all([],'data');
            assertTrue(isempty(all_mess))
            assertTrue(isempty(mid_from))
        end
        %
        function test_transfer_init_and_config(obj,varargin)
            
            if nargin>1
                obj.setUp();
                clob1 = onCleanup(@()tearDown(obj));
            end
            
            % testing the transfer of the initial information for a Herbert
            % job through a data exchange folder
            %
            % Prepare current configuration to be able to restore it after
            % the test finishes
            
            % set up basic default configuration
            pc = parallel_config;
            pc.saveable = false;
            cur_data = pc.get_data_to_store();
            clobC = onCleanup(@()set(pc,cur_data));
            % creates working directory
            pc.working_directory = fullfile(obj.working_dir,'some_irrelevant_folder_never_used_here');
            wkdir0 = pc.working_directory;
            clobW = onCleanup(@()rmdir(wkdir0,'s'));
            
            %--------------------------------------------------------------
            % check the case when local file system and remote file system
            % coincide
            
            pc.shared_folder_on_remote = '';
            pc.shared_folder_on_local = '';
            
            % test structure to send
            % store configuration in a local config folder as local and
            % remote jobs have the same file system
            mpi = MessagesFilebased('testiMPI_transferInit');
            mpi.mess_exchange_folder = obj.working_dir;
            clob0 = onCleanup(@()finalize_all(mpi));
            % the operation above copies config files to the folder
            % calculated by assign operation
            config_exchange = fileparts(fileparts(mpi.mess_exchange_folder));
            assertTrue(exist(fullfile(config_exchange,'herbert_config.mat'),'file')==2);
            
            jt = JETester();
            initMess = jt.get_worker_init();
            assertTrue(isa(initMess,'aMessage'));
            data = initMess.payload;
            assertTrue(data.exit_on_compl);
            assertFalse(data.keep_worker_running);
            
            % simulate the configuration operations happening on a remote machine side
            mis = MPI_State.instance();
            mis.is_deployed = true;
            mis.is_tested = true;
            clob4 = onCleanup(@()set(mis,'is_deployed',false,'is_tested',false));
            % the filesystem is shared so working_directory is used as
            % shared folder
            wk_dir = fullfile(obj.working_dir,'some_irrelevant_folder_never_used_here');
            assertEqual(pc.working_directory ,wk_dir );
            assertEqual(pc.shared_folder_on_local,wk_dir );
            assertEqual(pc.shared_folder_on_remote,wk_dir );
            
            
            %--------------------------------------------------------------
            %now test storing/restoring project configuration from a
            %directory different from default.
            mis.is_deployed = false;
            pc.shared_folder_on_local = obj.working_dir;
            assertEqual(pc.working_directory ,wk_dir );
            assertEqual(pc.shared_folder_on_local,obj.working_dir);
            assertEqual(pc.shared_folder_on_remote,obj.working_dir);
            
            
            %-------------------------------------------------------------
            % ensure default configuration location will be restored after
            % the test
            clob5 = onCleanup(@()config_store.instance('clear'));
            %
            cfn = config_store.instance().config_folder_name;
            remote_config_folder = fullfile(pc.shared_folder_on_remote,...
                cfn);
            clob6 = onCleanup(@()rmdir(remote_config_folder,'s'));
            % remove all configurations from memory to ensure they would be
            % read from non-default locations.
            config_store.instance('clear');
            
            % these operations would happen on worker
            mis.is_deployed = true;
            config_store.set_config_folder(remote_config_folder)
            
            % on a deployed program working directory coincides with shared_folder_on_remote
            pc = parallel_config;
            assertEqual(pc.working_directory ,pc.shared_folder_on_remote);
            
            
            r_config_folder = config_store.instance().config_folder;
            assertEqual(r_config_folder,remote_config_folder);
            
        end
        
    end
end

