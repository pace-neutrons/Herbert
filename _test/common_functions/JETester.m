classdef JETester < JobExecutor
    % Class used to test job dispatcher functionality
    %
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
    %
    %
    
    properties(Access = private)
        is_finished_ = false;
    end
    
    methods
        function je = JETester()
        end
        function obj=do_job(obj)
            % Test do_job method implementation for testing purposes
            %
            % the particular JobDispatcher should write its own method
            % keeping the same meaning for the interface
            %
            % Input parameters:
            % control_struct -- a structure, containing job
            %                   parameters.
            % this structure is generated by JobDispatcher.send_jobs method
            % by dividing array or cellarray of input parameters between
            % workers.
            %
            % this particular implementation writes files according to template,
            % provided in test_job_dispatcher.m file
            %aa= input('enter_something')
            n_steps = obj.n_iterations_;
            task_num = obj.labIndex;
            disp('****************************************************');
            disp(['labN: ',num2str(task_num),' genrating n_files: ',num2str(n_steps)]);
            %fh = mess_cache.instance().log_file_h;
            %fprintf(fh,'entering do-job loop\n');
            job_par = obj.common_data_;
            if isfield(job_par,'fail_for_labsN')
                labnums2fail = job_par.fail_for_labsN;
                if any(obj.labIndex==labnums2fail)
                    disp('****************************************************');
                    fprintf('simulated failure for lab N %d\n',obj.labIndex);
                    disp('****************************************************');
                    pause(0.1)
                    error('JETester:runtime_error',...
                        'simulated failure for lab N %d',obj.labIndex);
                end
            end
            n0 = obj.n_first_iteration_;
            n1 = n0+n_steps-1;
            t0 = tic;
            for ji = n0:n1
                n_steps_done =  ji-n0+1;
                filename = sprintf(job_par.filename_template,task_num,n_steps_done);
                file = fullfile(job_par.filepath,filename);
                f=fopen(file,'w');
                fwrite(f,['file: ',file],'char');
                fclose(f);
                pause(0.1)
                disp('****************************************************');
                disp(['finished test job generating test file: ',filename]);
                disp('****************************************************');
                %fprintf(fh,'logging progress for step %d ',ji);
                obj.log_progress(n_steps_done,n_steps,toc(t0)/n_steps_done,'');
                disp(['log message about file',filename,' sent *']);                
                %fprintf(fh,'completed\n');
            end
            disp(['labN: ',num2str(task_num),' do_job completed successfully']);
            disp('****************************************************');
            if obj.return_results_
                out_str = sprintf('Job %d generated %d files',task_num,n_steps);
                obj.task_results_holder_ = out_str;
            end
        end
        function  obj=reduce_data(obj)
            obj.is_finished_ = true;
        end
        function ok = is_completed(obj)
            ok = obj.is_finished_;
        end
    end
    
end

