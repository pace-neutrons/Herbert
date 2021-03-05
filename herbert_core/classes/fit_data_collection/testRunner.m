classdef testRunner < JobExecutor

    properties(Access = private)
        is_finished_ = false;
    end

    methods
        function obj = testRunner()
        end

        function  obj=reduce_data(obj)
            obj.is_finished_ = true;
        end
        function ok = is_completed(obj)
            ok = obj.is_finished_;
        end

        function do_job(obj)
            disp(obj)
        end
    end
end