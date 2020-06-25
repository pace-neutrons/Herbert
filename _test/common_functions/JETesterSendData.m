classdef JETesterSendData < JobExecutor
    % Class used to test job dispatcher functionality
    % when data messages are exchenged doing data message-level
    % syncronization (messages send as ready and received when possible)
    %
    %
    
    properties(Access = private)
        is_finished_ = false;
        build_data = false;
        n_step
        buffer;
        partial_data_cache
        %
        log_step
        log_step_count
    end
    
    methods
        function je = JETesterSendData()
        end
        function  [obj,mess] = init(obj,fbMPI,intercomm,init_message,is_tested)
            [obj,mess] = init@JobExecutor(obj,fbMPI,intercomm,init_message,is_tested);
            if ~isempty(mess)
                return;
            end
            
            job_par = obj.common_data_;
            obj.partial_data_cache = zeros(1,obj.n_steps);
            obj.n_step = 0;
            dbs = job_par.data_buffer_size;
            obj.buffer = ones(1,dbs);
            if obj.n_steps > 10
                obj.log_step = floor(obj.n_steps/10);
            else
                obj.log_step = 1;
            end
            obj.log_step_count = 0;
            
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
            
            task_num = obj.labIndex;
            
            disp('****************************************************');
            fprintf('labN: %d Do_job; do %d steps processing datablock of %d\n',...
                task_num,obj.n_steps,numel(obj.buffer));
            
            obj=obj.gen_data(task_num);
        end
        function  obj=reduce_data(obj)
            % always arithmetic progression on number of steps.
            disp('  partial_data_cache: ')
            disp(obj.partial_data_cache)
            obj.task_outputs = sum(obj.partial_data_cache);
            obj.is_finished_ = true;
        end
        function ok = is_completed(obj)
            ok = obj.is_finished_;
        end
        function obj=gen_data(obj,task_num)
            mis = MPI_State.instance();
            
            
            if task_num == 1
                for j=1:obj.n_steps
                    fprintf('******** STEP: %d\n',j)
                    
                    all_mess = obj.mess_framework.receive_all('all','data');
                    disp(all_mess);
                    for i=1:numel(all_mess)
                        fprintf('%d  ',all_mess{i}.payload.step);
                    end
                    fprintf('\n');
                    accum = 0;
                    for i=1:numel(all_mess)
                        accum = accum+sum(all_mess{i}.payload.data)/numel(all_mess{i}.payload.data);
                    end
                    accum = accum/numel(all_mess); % should give step number as the result
                    fprintf(' step: %d; accum: %d\n',j,accum);
                    obj.partial_data_cache(j) = accum;
                    obj.log_step_count = obj.log_step_count+1;
                    if obj.log_step_count >=obj.log_step                        
                        mis.do_logging(j,obj.n_steps)
                        obj.log_step_count=0;
                    end
                end
            else
                me = DataMessage();
                for i=1:obj.n_steps
                    fprintf('\n******** STEP: %d\n',i)
                    me.payload = struct('data',obj.buffer*i,'step',i);
                    obj.mess_framework.send_message(1,me);
                    obj.partial_data_cache(i) = i;
                    obj.log_step_count = obj.log_step_count+1;
                    if obj.log_step_count >=obj.log_step
                        mis.do_logging(i,obj.n_steps)
                        obj.log_step_count=0;
                    end
                    
                end
            end
        end
    end
    
end

