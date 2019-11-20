function [obj,err]=init_je_(obj,fbMPI,intercomm,InitMessage)
% initiate the worker parameters
% Inputs:
% fbMPI              - file-based message exchange framework, used for
%                      exchange information between control machine and the
%                      main worker (and distributing initialization
%                      information among workers)
% job_control_struct - the structure containing information
%                      necessary to initialize the messages framework used
%                      for interaction between workers.
% InitMessage        - the framework initialization message, containing the
%                      particular job initialization information. 
%Output:
% obj    -- Initialized instance of the job executor
% err    -- empty on success or information about the reason for failure.
%
%
% Store framework, used for message exchange between the headnode and the 
% workers of the cluster.
obj.control_node_exch_ = fbMPI;
% Store framework, used to exchange messages between nodes
obj.mess_framework_   = intercomm;
% Store job parameters
obj.common_data_   = InitMessage.common_data;
obj.n_iterations_  = InitMessage.n_steps;
obj.loop_data_     = InitMessage.loop_data;
obj.return_results_= InitMessage.return_results;
obj.n_first_iteration_= InitMessage.n_first_step;
%
[~,err,obj]=obj.reduce_send_message('started',[],true);

