classdef MessagesCppMPI_tester < MessagesCppMPI
    % Class to test protected methods of MessagesCppMPI class
    
    properties
        num_test_labs = uint64(10);
        this_labNum = uint64(1);
    end
    
    methods
        function obj = MessagesCppMPI_tester()
            obj = obj@MessagesCppMPI('test_mode');
            % make tester look like 10 workers
            obj.numLabs_ = obj.num_test_labs;
            obj.time_to_fail_ = 10;
        end
        function  obj = init_framework(obj,framework_info)
            if isstruct(framework_info)
                framework_info.test_mode = true;
            end
            obj = init_framework@MessagesCppMPI(obj,framework_info);
            if isstruct(framework_info) && isfield(framework_info,'numLabs')
                obj.num_test_labs = uint64(framework_info.numLabs);
                obj.this_labNum = uint64(framework_info.labID);                
            end
            obj.numLabs_ = obj.num_test_labs;
        end
        
        
        function [labNum,nLabs]=get_lab_index(obj)
            [labNum,nLabs] = obj.read_cpp_comm_pull_info();
            obj.numLabs_ = obj.num_test_labs;
            obj.task_id_ = obj.this_labNum;
        end
    end
end

