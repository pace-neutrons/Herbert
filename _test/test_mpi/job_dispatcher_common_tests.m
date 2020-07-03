classdef job_dispatcher_common_tests < MPI_Test_Common
    % The tests used by any parallel job dispatchers
    %
    properties
    end
    methods
        %
        function this = job_dispatcher_common_tests(test_name, framework_name)
            this = this@MPI_Test_Common(test_name, framework_name);
        end
        %
        function test_job_fail_restart(obj, varargin)
            if obj.ignore_test
                return;
            end
            fprintf('test_job_dispatcher_%s:test_job_fail_restart\n', ...
                obj.framework_name)
            if nargin > 1
                obj.setUp();
                clob0 = onCleanup(@()tearDown(obj));
            end
            function my_delete(varargin)
                for ii = 1:numel(varargin)
                    filename = varargin{ii};
                    if exist(filename, 'file') == 2
                        delete(filename);
                    end
                end
            end
            clear mex;
            %
            %             hc = herbert_config;
            
            display_fail_log = false;
            
            % overloaded to empty test -- nothing new for this JD
            % JETester specific control parameters
            rng('shuffle');
            FE = char(randi(25,1,5) + 64);
            common_param = struct('filepath', obj.working_dir, ...
                'filename_template', ['test_JD_', obj.framework_name,FE,'L%d_nf%d.txt'], ...
                'fail_for_labsN', 2);
            
            file1 = fullfile(obj.working_dir, ['test_JD_', obj.framework_name,FE, 'L1_nf1.txt']);
            file2 = fullfile(obj.working_dir, ['test_JD_', obj.framework_name,FE, 'L2_nf1.txt']);
            file3 = fullfile(obj.working_dir, ['test_JD_', obj.framework_name,FE, 'L3_nf1.txt']);
            file3a = fullfile(obj.working_dir, ['test_JD_', obj.framework_name,FE, 'L3_nf2.txt']);
            
            files = {file1, file3, file3a};
            co = onCleanup(@()(my_delete(files{:})));
            
            jd = JobDispatcher(['test_job_', obj.framework_name, '_fail_restart']);
            disp('*********************************************************')
            disp('**************FAIL-1 Lab2 Fails *************************')
            disp('*********************************************************')
            %1)----------------------------------------------------------
            [outputs, n_failed, ~, jd] = jd.start_job('JETester', common_param, 36, true, 3, true, 1);
            if display_fail_log || numel(outputs) ~=3
                jd.display_fail_job_results(outputs, n_failed,3);
            end
            
            function is = is_err(x)
                if isa(x, 'MException') || isa(x, 'ParallelException')
                    is = true;
                elseif iscell(x)
                    is_fail = cellfun(@is_err, x, 'UniformOutput', true);
                    is = any(is_fail);
                elseif isstruct(x) && isfield(x, 'error') && isa(x.error, 'MException')
                    is = true;
                else
                    is = false;
                end
            end
            assertTrue(n_failed > 0);
            assertEqual(numel(outputs), 3);
            fin = cellfun(@is_err, outputs);
            assertTrue(sum(fin) >= 1)
            
            if isstruct(outputs{2})
                assertEqual(outputs{2}.fail_reason, ...
                    'Task N2 failed at jobExecutor: JETester. Reason: simulated failure for lab N 2');
            else
                assertEqual(outputs{2}.message, ...
                    'simulated failure for lab N 2');
            end
            % file may exist or may not -- depending on relation between
            % speed of workers
            
            co = onCleanup(@()(my_delete(file3, file3a)));
            common_param.fail_for_labsN = 1;
            disp('*********************************************************')
            disp('**************FAIL-2 Lab1 Fail  *************************')
            disp('*********************************************************')
            
            %2)----------------------------------------------------------
            [outputs, n_failed, ~, jd] = jd.restart_job('JETester', common_param, 4, true, true, 1);
            if display_fail_log || numel(outputs) ~=3
                jd.display_fail_job_results(outputs, n_failed,3)
            end
            
            assertTrue(n_failed >= 1);
            assertEqual(numel(outputs), 3);
            fin = cellfun(@is_err, outputs);
            assertTrue(sum(fin) >= 1)
            
            clear co;
            % check long job cancelled due to part of the job failed
            disp('*********************************************************')
            disp('**************FAIL 3 Lab1-2 Fail -- long job*************')
            disp('*********************************************************')
            
            %3)----------------------------------------------------------
            [outputs, n_failed, ~, jd] = jd.restart_job('JETester', common_param, 99, true, true, 1);
            if display_fail_log || numel(outputs) ~=3
                jd.display_fail_job_results(outputs, n_failed,3)
            end
            
            assertTrue(n_failed > 0);
            assertEqual(numel(outputs), 3);
            fin = cellfun(@is_err, outputs);
            assertTrue(sum(fin) >= 1)
            
            for i = 1:33
                fileN = fullfile(obj.working_dir, sprintf('test_JD_%s%sL3_nf%d.txt', obj.framework_name,FE, i));
                if exist(fileN, 'file') == 2
                    delete(fileN);
                else
                    break;
                end
            end
            common_param.fail_for_labsN = 3;
            disp('*********************************************************')
            disp('**************FAIL 4 Lab-3 Fail, long job****************')
            disp('*********************************************************')
            
            
            %4)----------------------------------------------------------
            [outputs, n_failed, ~, jd] = jd.restart_job('JETester', common_param, 99, true, true, 1);
            if display_fail_log || numel(outputs) ~=3
                jd.display_fail_job_results(outputs, n_failed,3)
            end
            
            assertTrue(n_failed >= 1);
            assertEqual(numel(outputs), 3);
            fin = cellfun(@is_err, outputs);
            assertTrue(sum(fin) >= 1)
            
            
            for i = 1:33
                fileN1 = fullfile(obj.working_dir, sprintf('test_JD_%s%sL1_nf%d.txt', obj.framework_name,FE, i));
                if exist(fileN1, 'file') == 2
                    no_file1 = false;
                    delete(fileN1);
                else
                    no_file1 = true;
                end
                fileN2 = fullfile(obj.working_dir, sprintf('test_JD_%s%sL2_nf%d.txt', obj.framework_name,FE,i));
                if exist(fileN2, 'file') == 2
                    delete(fileN2);
                else
                    if no_file1
                        break;
                    end
                end
            end
            
            common_param = rmfield(common_param, 'fail_for_labsN');
            files = {file1, file2, file3, file3a};
            co = onCleanup(@()(my_delete(files{:})));
            
            disp('*********************************************************')
            disp('**************RUN 5 Should finish successfully **********')
            disp('*********************************************************')
            
            
            
            %5)----------------------------------------------------------
            [outputs, n_failed,~,jd] = jd.restart_job('JETester', common_param, 4, true, false, 1);
            if n_failed>0
                jd.display_fail_job_results(outputs, n_failed,3)
            end
            disp('*********************************************************')
            disp('**************RUN 5 FINISHED ****************************')
            disp('*********************************************************')
            
            
            assertEqual(n_failed, 0);
            assertEqual(numel(outputs), 3);
            
            assertEqual(outputs{1}, 'Job 1 generated 1 files');
            assertEqual(outputs{2}, 'Job 2 generated 1 files');
            assertEqual(outputs{3}, 'Job 3 generated 2 files');
            
            assertTrue(exist(file1, 'file') == 2);
            assertTrue(exist(file2, 'file') == 2);
            assertTrue(exist(file3, 'file') == 2);
            assertTrue(exist(file3a, 'file') == 2);
        end
        %
        function test_job_with_logs_2workers(obj, varargin)
            if obj.ignore_test
                return;
            end
            fprintf('test_job_dispatcher_%s:test_job_with_logs_2workers\n', ...
                obj.framework_name)
            if nargin > 1
                obj.setUp();
                clob0 = onCleanup(@()tearDown(obj));
            end
            clear mex;
            hc = herbert_config;
            display_ouptut = hc.log_level>0;
            
            % overloaded to empty test -- nothing new for this JD
            % JETester specific control parameters
            rng('shuffle');
            FE = char(randi(25,1,5) + 64);
            common_param = struct('filepath', obj.working_dir, ...
                'filename_template', ['test_JD_', obj.framework_name,FE,'L%d_nf%d.txt']);
            
            file1 = fullfile(obj.working_dir, ['test_JD_', obj.framework_name,FE, 'L1_nf1.txt']);
            file2 = fullfile(obj.working_dir, ['test_JD_', obj.framework_name,FE, 'L2_nf1.txt']);
            file3 = fullfile(obj.working_dir, ['test_JD_', obj.framework_name,FE, 'L2_nf2.txt']);
            files = {file1, file2, file3};
            co = onCleanup(@()(delete(files{:})));
            
            jd = JobDispatcher(['test_', obj.framework_name, '_2workers']);
            n_workers = 2;
            
            
            [outputs, n_failed,~,jd] = jd.start_job('JETester', common_param, 3, true, n_workers, true, 1);
            if n_failed>0
                jd.display_fail_job_results(outputs, n_failed,2)
            end
            if numel(outputs) ~=2
                disp('************* 2 workers run : failed  outputs :')
                disp(outputs);
            end
            
            
            assertEqual(n_failed, 0);
            assertEqual(numel(outputs), 2);
            assertEqual(outputs{1}, 'Job 1 generated 1 files');
            assertEqual(outputs{2}, 'Job 2 generated 2 files');
            assertTrue(exist(file1, 'file') == 2);
            assertTrue(exist(file2, 'file') == 2);
            assertTrue(exist(file3, 'file') == 2);
            
            n_steps = 30;
            common_param = struct('data_buffer_size',10000000);
            [outputs, n_failed] = jd.restart_job('JETesterSendData',...
                common_param,n_steps*n_workers,true, false, 1);
            if n_failed>0
                jd.display_fail_job_results(outputs, n_failed,2)
            end
            
            assertEqual(n_failed, 0);
            for i=1:numel(outputs)
                if display_ouptut
                    disp(outputs{i})
                end
                assertEqualToTol(outputs{i},(n_steps+1)*n_steps/2);
            end
            
            
        end
        %
        function test_job_with_logs_3workers(obj, varargin)
            if obj.ignore_test
                return;
            end
            fprintf('test_job_dispatcher_%s:test_job_with_logs_3workers\n', ...
                obj.framework_name)
            if nargin > 1
                obj.setUp();
                clob0 = onCleanup(@()tearDown(obj));
            end
            hc = herbert_config;
            display_ouptut = hc.log_level>0;
            % overloaded to empty test -- nothing new for this JD
            % JETester specific control parameters
            rng('shuffle');
            FE = char(randi(25,1,5) + 64);
            common_param = struct('filepath', obj.working_dir, ...
                'filename_template', ['test_JD_', obj.framework_name,FE,'L%d_nf%d.txt']);
            file1 = fullfile(obj.working_dir, ['test_JD_', obj.framework_name,FE, 'L1_nf1.txt']);
            file2 = fullfile(obj.working_dir, ['test_JD_', obj.framework_name,FE, 'L2_nf1.txt']);
            file3 = fullfile(obj.working_dir, ['test_JD_', obj.framework_name,FE, 'L3_nf1.txt']);
            files = {file1, file2, file3};
            co = onCleanup(@()(delete(files{:})));
            
            jd = JobDispatcher(['test_', obj.framework_name, '_3workers']);
            n_workers = 3;
            
            [outputs, n_failed,~,jd] = jd.start_job('JETester', common_param, 3, true, n_workers, true, 1);
            if n_failed>0
                jd.display_fail_job_results(outputs, n_failed,3)
            end
            if numel(outputs) ~=3
                disp('************* 3 workers successful run : failed  outputs :')
                disp(outputs);
            end
            
            assertEqual(n_failed, 0);
            assertEqual(numel(outputs), 3);
            assertEqual(outputs{1}, 'Job 1 generated 1 files');
            assertEqual(outputs{2}, 'Job 2 generated 1 files');
            assertEqual(outputs{3}, 'Job 3 generated 1 files');
            assertTrue(exist(file1, 'file') == 2);
            assertTrue(exist(file2, 'file') == 2);
            assertTrue(exist(file3, 'file') == 2);
            
            
            common_param = struct('data_buffer_size',10000000);
            n_steps = 30;
            [outputs, n_failed,~,jd] = jd.restart_job('JETesterWithData',...
                common_param,n_steps*n_workers, true,true, 1);
            if n_failed>0
                jd.display_fail_job_results(outputs, n_failed,3)
            end
            
            assertEqual(n_failed, 0);
            for i=1:numel(outputs)
                if display_ouptut
                    disp(outputs{i})
                end
                assertEqualToTol(outputs{i},(n_steps+1)*n_steps/2);
            end
            
            n_steps = 3;
            [outputs, n_failed,~,jd] = jd.restart_job('JETesterWithData',...
                common_param,n_steps*n_workers,true, true, 1);
            if n_failed>0
                jd.display_fail_job_results(outputs, n_failed,3)
            end
            
            
            assertEqual(n_failed, 0);
            disp('*********** JETesterWithData: outputs: ')
            for i=1:numel(outputs)
                if display_ouptut
                    disp(outputs{i})
                end
                assertEqualToTol(outputs{i},(n_steps+1)*n_steps/2);
            end
            
            
            n_steps = 30;
            common_param = struct('data_buffer_size',10000000);
            [outputs, n_failed] = jd.restart_job('JETesterSendData',...
                common_param,n_steps*n_workers,true, false, 1);
            if n_failed>0
                jd.display_fail_job_results(outputs, n_failed,3)
            end
            
            
            assertEqual(n_failed, 0);
            disp('*********** JETesterWithData: outputs: ')
            for i=1:numel(outputs)
                if display_ouptut
                    disp(outputs{i})
                end
                assertEqualToTol(outputs{i},(n_steps+1)*n_steps/2);
            end
        end
        %
        function test_job_with_logs_worker(obj, varargin)
            if obj.ignore_test
                return;
            end
            fprintf('test_job_dispatcher_%s:test_job_with_logs_worker\n', ...
                obj.framework_name)
            if nargin > 1
                obj.setUp();
                clob0 = onCleanup(@()tearDown(obj));
            end
            clear mex;
            
            % overloaded to empty test -- nothing new for this JD
            % JETester specific control parameters
            rng('shuffle');
            FE = char(randi(25,1,5) + 64);
            common_param = struct('filepath', obj.working_dir, ...
                'filename_template', ['test_JD_', obj.framework_name,FE,'L%d_nf%d.txt']);
            
            file1 = fullfile(obj.working_dir, ['test_JD_', obj.framework_name,FE,'L1_nf1.txt']);
            file2 = fullfile(obj.working_dir, ['test_JD_', obj.framework_name,FE,'L1_nf2.txt']);
            file3 = fullfile(obj.working_dir, ['test_JD_', obj.framework_name,FE,'L1_nf3.txt']);
            files = {file1, file2, file3};
            co = onCleanup(@()(delete(files{:})));
            
            jd = JobDispatcher(['test_', obj.framework_name, '_1worker']);
            
            [outputs, n_failed] = jd.start_job('JETester', common_param, 3, true, 1, false, 1);
            if n_failed>0
                jd.display_fail_job_results(outputs, n_failed,1)
            end
            
            assertEqual(n_failed, 0);
            assertEqual(numel(outputs), 1);
            assertEqual(outputs{1}, 'Job 1 generated 3 files');
            assertTrue(exist(file1, 'file') == 2);
            assertTrue(exist(file2, 'file') == 2);
            assertTrue(exist(file3, 'file') == 2);
        end
        %
    end
end
