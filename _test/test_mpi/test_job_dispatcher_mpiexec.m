classdef test_job_dispatcher_mpiexec < job_dispatcher_common_tests
    %
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
    %
    
    properties
    end
    methods
        %
        function this=test_job_dispatcher_mpiexec(name)
            if ~exist('name','var')
                name = 'test_job_dispatcher_herbert';
            end
            this = this@job_dispatcher_common_tests(name,'mpiexec_mpi');
        end
        %     
        function test_job_fail_restart(obj, varargin)
            if isunix
                return
            else
                test_job_fail_restart@job_dispatcher_common_tests(obj, varargin{:})                                
            end
        end
        function test_job_with_logs_3workers(obj, varargin)
            % disabled for windows and unix
        end
        
    end
end

