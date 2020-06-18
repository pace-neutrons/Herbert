classdef MessagesCppMPI < iMessagesFramework
    % The class provides C++ MPI message exchange functionality for Herbert
    % distributed jobs framework.
    %
    % The framework's functionality is similar to parfor
    % but does not required parallel toolbox and works by starting
    % separate Matlab sessions to do separate tasks.
    %
    % Works in conjunction with worker function from admin folder,
    % The worker has to be placed on Matlab search path
    % defined before Herbert is initiated
    %
    %
    % This class provides physical mechanism to exchange messages between tasks
    % using MPICH on Unix or MS MPI on Windows.
    %
    properties(Dependent)
    end
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    properties(Access=protected)
        % time to wait before checking for next blocking message if
        % previous attempt have not find it.
        time_to_react_ = 1; % (sec)
        %
        % equivalent to labNum in MPI, the number of the current running
        % MPI worker
        task_id_ = -1;
        % Total number of MPI workers, participating in a job.
        numLabs_ = 0;
        %
        % The variable to keep pointer to the internal C++ class,
        % responsible for MPI operations
        mpi_framework_holder_ = [];
        % The length of the queue to use for asynchronous messages.
        % if this number of asynchronous messages has been send and no
        % been received, something wrong is happening with the node or the
        % cluster, so the job should be interrupted (canceled)
        assync_messages_queue_length_ = 100;
        % the tag for the data message, used by cpp_communicator to process
        % data messages differently
        data_message_tag_;
        DEBUG_ = false;
        % The holder for is_tested property value
        is_tested_ = true;
    end
    %----------------------------------------------------------------------
    methods
        %
        function jd = MessagesCppMPI(varargin)
            % Initialize Messages framework for particular job
            % If provided with parameters, the first parameter should be
            % the sting-prefix of the job control files, used to
            % distinguish this job control files from any other job control
            % files.
            %Example
            % jd = MessagesFramework() -- use randomly generated job control
            %                             prefix
            % jd = MessagesFramework('test_mode')
            %
            
            % Initialise folder path
            jd = jd@iMessagesFramework();
            if nargin>0
                jd = jd.init_framework(varargin{:});
            end
            
        end
        %------------------------------------------------------------------
        %
        function  obj = init_framework(obj,framework_info)
            % using control structure initialize operational message
            % framework
            %  framework_info -- either:
            %   a) string, defining the job name (job_id)
            %     -- or:
            %   b) the structure, defined by worker_job_info function:
            %      in this case usually defines slave message exchange
            %      framework.
            %
            %      If the string is 'test_mode' or the structure contains the field
            %      .test_mode, the framework does not initializes real mpi, but runs
            %      sets numLab to one and labNum to 1 and runs as fake worker in the
            %      main process flow (not parallel)
            obj = init_framework_(obj,framework_info);
        end
        %------------------------------------------------------------------
        % MPI interface
        %
        %
        function [ok,err_mess] = send_message(obj,task_id,message)
            % send message to a task with specified id
            %
            % Usage:
            % >>mf = MessagesFramework();
            % >>mess = aMessage('mess_name')
            % >>[ok,err_mess] = mf.send_message(1,mess)
            % >>ok  if true, says that message have been successfully send to a
            % >>    task with id==1. (not received)
            % >>    if false, error_mess indicates reason for failure
            %
            [ok,err_mess] = send_message_(obj,task_id,message);
        end
        %
        function [ok,err_mess,message] = receive_message(obj,task_id,varargin)
            % receive message from a task with specified id.
            %
            % Blocking  or unblocking behavior depends on requested message
            % type.
            %
            % If the requested message type is blocking, blocks until the
            % message is available
            % if it is unblocking, return empty message if appropriate message
            % is not present in system
            % There is possibility directly ask for blocking or unblocking
            % behavior.
            %
            % Usage:
            % >>mf = MessagesFramework();
            % >>[ok,err_mess,message] = mf.receive_message(id,mess_name, ...
            %                           ['-synchronous'|'-asynchronous'])
            % or:
            % >>[ok,err_mess,message] = mf.receive_message(id,'any', ...
            %                           ['-synchronous'|'-synchronous'])
            %
            % Inputs:
            % id        - the address of the lab to receive message from
            % mess_name - name/tag of the message to receive.
            %             'any' means any tag.
            % Optional:
            % ['-s[ynchronous]'|'-a[synchronous]'] -- override default message
            %              receiving rules and receive the message
            %              block program execution if '-synchronous' keyword
            %              is provided, or continue execution if message has
            %              not been send ('-asynchronous' mode).
            %
            %Returns:
            %
            % >>ok  if MPI_err.ok, message have been successfully
            %       received from task with the specified id.
            % >>    if not, error_mess and error code indicates reasons for
            %       failure.
            % >> on success, message contains an object of class aMessage,
            %        with the received message contents.
            %
            [ok,err_mess,message] = receive_message_(obj,task_id,varargin{:});
        end
        %
        %
        function [all_messages_names,task_ids] = probe_all(obj,varargin)
            % list all messages existing in the system with id-s specified as input
            % and intended for this task
            %
            %Usage:
            %>> [mess_names,task_ids] = obj.probe_all([task_ids],[{mess_name,mess_tag}]);
            %Where:
            % task_ids -- array of task id-s to check messages for or all
            %             messages if this is empty
            % message_name or message_tag -- if present, check only for
            %             the messages of specific kind.
            %Returns:
            % mess_names   -- cellarray of strings, containing message names
            %                 for the requested tasks.
            % task_ids      -- array of task id-s for the message names
            %                  in the mess_names
            %
            % if no messages are present in the system
            % all_messages_names and task_ids are empty
            %
            [all_messages_names,task_ids] = labprobe_all_messages_(obj,varargin{:});
        end
        %
        function [all_messages,task_ids] = receive_all(obj,varargin)
            % retrieve (and remove from system) all messages
            % existing in the system for the tasks with id-s specified as input
            % Blocks execution until all messages are received.
            %
            %
            %Input:
            %task_ids -- array of task id-s to check messages for
            %Return:
            % all_messages -- cellarray of messages for the tasks requested and
            %                 have messages available in the system .
            % task_ids     -- array of task id-s for these messages
            % mess_name    -- if present, receive only the messages with
            %                 the name provided
            %
            %
            if nargin>1 && ischar(varargin{1})
                if strcmp('any',varargin{1})
                    warning('Outdated receive all interface. Use all instead of any')
                    varargin{1} = 'all';
                end
            end
            
            [all_messages,task_ids] = receive_all_messages_(obj,varargin{:});
        end
        %
        function obj=finalize_all(obj)
            % delete all messages belonging to this instance of messages
            % framework and delete the framework itself
            obj.persistent_fail_message_ = [];
            if ~isempty(obj.mpi_framework_holder_)
                obj.mpi_framework_holder_ = ...
                    cpp_communicator('finalize',obj.mpi_framework_holder_);
            end
            obj.task_id_ = -1;
            obj.numLabs_ = 0;
        end
        function clear_messages(obj)
            % receive and discard all MPI messages directed to this
            % workeer
            obj.persistent_fail_message_ = [];
            obj.mpi_framework_holder_= ...
                cpp_communicator('clearAll',obj.mpi_framework_holder_);
        end
        %
        function [ok,err]=labBarrier(obj,varargin)
            % this barrier never throws and never returns errors
            cpp_communicator('barrier',obj.mpi_framework_holder_);
            ok = true;
            err = [];
        end
                
        function is = is_job_canceled(obj)
            % method verifies if job has been canceled
            mess = obj.probe_all('all','canceled');
            if ~isempty(mess)
                is = true;
            else
                is=false;
            end
        end
        %
        function delete(obj)
            if ~isempty(obj.mpi_framework_holder_)
                cpp_communicator('finalize',obj.mpi_framework_holder_);
            end
            obj.mpi_framework_holder_ = [];
        end
        %
    end
    %----------------------------------------------------------------------
    methods (Access=protected)
        function ind = get_lab_index_(obj)
            ind = obj.task_id_;
        end
        function ind = get_num_labs_(obj)
            ind = obj.numLabs_;
        end
        function [numLabs,labNum] = read_cpp_comm_pull_info(obj)
            % service function, to retrieve MPI pull information from cpp
            % communicator. This info should not currently change from the
            % initialization time, but may be modified in a future.
            [obj.mpi_framework_holder_,labNum,numLabs]= ...
                cpp_communicator('labIndex',obj.mpi_framework_holder_);
            %
            obj.task_id_ = labNum;
            obj.numLabs_ = numLabs;
        end
        function is = get_is_tested(obj)
            % return true if the framework is tested (not real MPI)
            is = obj.is_tested_;
        end
        
    end
end


