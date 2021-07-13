classdef mfparallel < JobExecutor

    properties
        yc
        vc
        finished = false;
        my_int = 0;
    end

    methods
        % Constructor cannot take args as constructed by JobDispatcher
        function obj = mfparallel()
        end

        function obj=reduce_data(obj)
        % Performed at end of do job after synchronise
            mf = obj.mess_framework;
            if isempty(mf) % something wrong, framework deleted
                error('HORACE:mfparallel:runtime_error',...
                    'MPI framework failed to initialise');
            end

            if mf.labIndex == 1
                [all_messages,task_ids] = mf.receive_all('all','data');

                all_messages = all_messages(task_ids-1); % Sort into id order (shift due to 1 not sending to itself)

                obj.task_outputs.f = obj.yc;
                obj.task_outputs.v = obj.vc;

                for i=1:numel(all_messages)
                    obj.task_outputs.f(end) = obj.task_outputs.f(end) + all_messages{i}.payload.yc(1);
                    obj.task_outputs.v(end) = obj.task_outputs.v(end) + all_messages{i}.payload.vc(1);
                    obj.task_outputs.f = cat(1, obj.task_outputs.f, all_messages{i}.payload.yc(2:end));
                    obj.task_outputs.v = cat(1, obj.task_outputs.v, all_messages{i}.payload.vc(2:end));
                end
            else
                %
                message = DataMessage(struct('yc',obj.yc, 'vc',obj.vc, 'sender', mf.labIndex))

                [ok,err]=mf.send_message(1,message);
                if ok ~= MESS_CODES.ok
                    error('HORACE:mfparallel:runtime_error',err);
                end
            end

            obj.finished = true;
        end

        function ok = is_completed(obj)
        % If returns true, job will not run another cycle of do_job/reduce_data
            ok = obj.finished;
        end

        function obj = do_job(obj)

            data = obj.loop_data_{1};

            [obj.yc, obj.vc, S, Store] = multifit_lsqr_func_eval( ...
                data.w, ...
                data.xye, ...
                obj.common_data_.func, ...
                obj.common_data_.bfunc, ...
                obj.common_data_.pin, ...
                obj.common_data_.bpin, ...
                obj.common_data_.f_pass_caller_info, ...
                obj.common_data_.bf_pass_caller_info, ...
                obj.common_data_.p, ...
                obj.common_data_.p_info, ...
                true, ...
                data.S, ...
                data.Store , ...
                obj.common_data_.listing);

            % Output some data
            obj.task_outputs = struct('S', S, 'Store', Store);

        end
    end
end