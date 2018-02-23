classdef iTaskWrapper
    methods(Abstract)
        % abstract method to start generic MPI task
        obj = start_task(obj,mpi,task_class_name,task_id,task_inputs,varargin)
        % abstract method to stop generic MPI task        
        obj = stop_task(obj)
        % abstract method to check if a task is running generic MPI task                
        [ok,failed,mess] = is_running(obj)        
    end
end
