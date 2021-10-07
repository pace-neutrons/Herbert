classdef MFParallel_Job < JobExecutor

    properties
        yc
        vc
        finished = false;
        my_int = 0;
    end

    methods
        % Constructor cannot take args as constructed by JobDispatcher
        function obj = MFParallel_Job()
        end

        function obj=reduce_data(obj)
        % Performed at end of do job after synchronise
            obj.finished = true;
        end

        function ok = is_completed(obj)
        % If returns true, job will not run another cycle of do_job/reduce_data
            ok = obj.finished;
        end

        function obj = do_job(obj)

            data = obj.loop_data_{1};

            if isfield(data, 'tobyfit_data')
                for i=1:numel(data.tobyfit_data)
                    obj.common_data_.pin(i).plist_{3} = data.tobyfit_data{i};
                end
            end

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
            obj.task_outputs = struct('f', {obj.yc}, 'v', {obj.vc}, 'S', S, 'Store', Store);

        end
    end
end