classdef test_cluster_wrapper < TestCase
    % Test running using the parpool job dispatcher.
    %
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
    %
    properties
    end
    
    methods
        function obj = test_cluster_wrapper(varargin)
            if ~exist('name','var')
                name = 'test_cluster_wrapper';
            end
            obj = obj@TestCase(name);
        end
        function test_cluster_init(obj)
            
            mf = MessagesFilebased('test_cluster_init');
            cluster = ClusterWrapper(3,mf);
            clob = onCleanup(@()finalize_all(cluster));
            
            % build message framework to respond instead of a worker
            cs = mf.get_worker_init('MessagesParpool',1,3);
            css = mf.deserialize_par(cs);
            meR1 = MessagesFilebased(css);
            
            cs = mf.get_worker_init('MessagesParpool',2,3);
            css = mf.deserialize_par(cs);
            meR2 = MessagesFilebased(css);
            
            cs = mf.get_worker_init('MessagesParpool',3,3);
            css = mf.deserialize_par(cs);
            meR3 = MessagesFilebased(css);
            
            % prepare fake data, usually generated by JobDispatcher
            jt = JETester();
            jeInit= jt.get_worker_init(false,false);
            worker_init_mess = {InitMessage(),InitMessage(),InitMessage()};
            worker_init_mess{1}.payload = 'a';
            worker_init_mess{2}.payload = 'b';
            worker_init_mess{3}.payload = 'c';
            
            %--------------------------------------------------------------
            cluster = cluster.init_workers(jeInit,worker_init_mess);
            % send ready messages do disable cluster locking            
            meR1.send_message(0,'started');
%             meR2.send_message(1,'started'); % these are now sent to
%             worker 1 and not tested here
%             meR3.send_message(1,'started');
            
            [completed,cluster] = cluster.check_progress();
            assertEqual(cluster.status.mess_name,'started');
            assertFalse(completed)
            %--------------------------------------------------------------
            % receive "starting" messages used to provide jeInit info to
            % each worker
            [ok,err,mess1]=meR1.receive_message(0,'starting');
            assertEqual(ok,MESS_CODES.ok,err);
            [ok,err,mess2]=meR2.receive_message(0,'starting');
            assertEqual(ok,MESS_CODES.ok,err);
            [ok,err,mess3]=meR3.receive_message(0,'starting');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(jeInit,mess1)
            assertEqual(jeInit,mess2)
            assertEqual(jeInit,mess3)
            
            
            % receive job init messages
            [ok,err,mess1]=meR1.receive_message(0,'init');
            assertEqual(ok,MESS_CODES.ok,err);
            [ok,err,mess2]=meR2.receive_message(0,'init');
            assertEqual(ok,MESS_CODES.ok,err);
            [ok,err,mess3]=meR3.receive_message(0,'init');
            assertEqual(ok,MESS_CODES.ok,err);
            
            assertEqual(worker_init_mess{1},mess1)
            assertEqual(worker_init_mess{2},mess2)
            assertEqual(worker_init_mess{3},mess3)
            
        end
        
        function test_check_progress_disp_results(obj)
            
            mf = MessagesFilebased('disp_prgrs');
            % test mode -- framework with 0 workers would not start
            % anything
            cluster = ClusterWrapper(0,mf);
            
            clob = onCleanup(@()finalize_all(cluster));
            
            cs = mf.get_worker_init('MessagesFilebases',1,10);
            css = mf.deserialize_par(cs);
            meR = MessagesFilebased(css);
            
            meR.send_message(0,'starting');
            
            cluster = cluster.display_progress();
            assertEqual(cluster.log_value,'.');
            cluster = cluster.display_progress();
            assertEqual(cluster.log_value,'.');
            
            cluster = cluster.display_progress('unknown state');
            ref_string = sprintf('\n%s\n','**** unknown state                            ****');
            assertEqual(cluster.log_value,ref_string);
            if verLessThan('matlab','9.1')
                CR =sprintf('\n');
            else
                CR =newline; % sprintf('\n');
            end
            [completed,cluster] = cluster.check_progress();
            assertFalse(completed);
            cluster = cluster.display_progress();
            ref_string = ['***Job : ',mf.job_id,' : state: starting |',CR];
            assertEqual(cluster.log_value,ref_string);
            [completed,cluster] = cluster.check_progress();
            assertFalse(completed);
            cluster = cluster.display_progress();
            assertEqual(cluster.log_value,'.');
            [completed,cluster] = cluster.check_progress();
            assertFalse(completed);
            [completed,cluster] = cluster.check_progress();
            assertFalse(completed);
            cluster = cluster.display_progress();
            assertEqual(cluster.log_value,'.');
            n_steps = cluster.log_wrap_length;
            for i=3:n_steps
                [completed,cluster] = cluster.check_progress();
                assertFalse(completed);
                cluster = cluster.display_progress();
                assertEqual(cluster.log_value,'.');
            end
            [completed,cluster] = cluster.check_progress();
            assertFalse(completed);
            cluster = cluster.display_progress();
            assertEqual(cluster.log_value,[CR,ref_string]);
            
            [completed,cluster] = cluster.check_progress();
            assertFalse(completed);
            cluster = cluster.display_progress();
            assertEqual(cluster.log_value,'.');
            
            mess = LogMessage(1,50,0,[]);
            meR.send_message(0,mess);
            
            [completed,cluster] = cluster.check_progress();
            assertFalse(completed);
            cluster = cluster.display_progress();
            ref_string = [CR,'***Job : ',mf.job_id,' : state:  running |Step#1.00/50, Estimated time left:  Unknown | ',CR];
            assertEqual(cluster.log_value,ref_string);
            
            %
            mess = LogMessage(2,50,1,[]);
            meR.send_message(0,mess);
            [completed,cluster] = cluster.check_progress();
            assertFalse(completed);
            cluster = cluster.display_progress();
            ref_string = ['***Job : ',mf.job_id,' : state:  running |Step#2.00/50, Estimated time left: 0.80(min)| ',CR];
            assertEqual(cluster.log_value,ref_string);
            
        end
        
        function test_utilises_logical_cores_when_n_workers_gt_physical_cores(obj)
            [physical_cores, logical_cores] = get_num_cores();
            if physical_cores == logical_cores
                % If no extra logical cores available, this test can do nothing
                return
            end
            msg_framework = MessagesFilebased('test_cluster_init');
            clust = ClusterParpoolWrapper();
            n_workers = physical_cores + 1;
            clust = clust.init(n_workers, msg_framework, ...
                               herbert_config().log_level);
            assertEqual(clust.n_workers, n_workers);
        end

        function test_num_workers_set_when_n_workers_lt_num_physical_cores(obj)
            physical_cores = get_num_cores();
            msg_framework = MessagesFilebased('test_cluster_init');
            clust = ClusterParpoolWrapper();
            n_workers = physical_cores - 1;
            clust = clust.init(n_workers, msg_framework, ...
                               herbert_config().log_level);
            assertEqual(clust.n_workers, n_workers);
        end

        function test_num_workers_set_when_n_workers_eq_num_physical_cores(obj)
            physical_cores = get_num_cores();
            msg_framework = MessagesFilebased('test_cluster_init');
            clust = ClusterParpoolWrapper();
            clust = clust.init(physical_cores, msg_framework, ...
                               herbert_config().log_level);
            assertEqual(clust.n_workers, physical_cores);
        end
        
        function test_init_fails_if_n_workers_gt_num_logical_cores(obj)
            [~, logical_cores] = get_num_cores();
            msg_framework = MessagesFilebased('test_cluster_init');
            clust = ClusterParpoolWrapper();
            n_workers = logical_cores + 1;
            assertExceptionThrown(@() clust.init(n_workers, msg_framework, ...
                                  herbert_config().log_level), ...
                                  'PARPOOL_CLUSTER_WRAPPER:runtime_error');
        end
    end
end
