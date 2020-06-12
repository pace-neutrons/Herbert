function   [all_messages,tid_received_from] = receive_all_messages_(obj,task_ids,mess_name)
% retrieve all messages sent from jobs with id provided. if ids are empty,
% all messages, intended for this job.
%
if ~exist('task_ids','var') || isempty(task_ids) || (ischar(task_ids) && strcmpi(task_ids,'all'))
    task_ids = 1:obj.numLabs;
end
this_tid = task_ids == obj.labIndex;
if any(this_tid)
    task_ids = task_ids(~this_tid);
end


if ~exist('mess_name','var')
    mess_name = 'any';
end

if isempty(mess_name) || strcmp(mess_name,'any')
    lock_until_received = false;
else
    if obj.DEBUG_
        disp(['**********  waiting for message: ',mess_name,' to arrive from tasks: ']);
        disp(task_ids')
    end
    lock_until_received = ~MESS_NAMES.is_blocking(mess_name);
end


n_requested = numel(task_ids);
all_messages = cell(n_requested ,1);
mess_received = false(n_requested ,1);
tid_received_from = zeros(n_requested ,1);

[message_names,tid_from] = list_all_messages_(obj,task_ids,mess_name);
%[tid_from,im] = unique(tid_from);
%message_names = message_names(im);
present_now = ismember(task_ids,tid_from);
if obj.DEBUG_
    disp(' Messages present initially:');
    disp(present_now');
end

all_received = false;
nsteps = 0;
t0 = tic;
while ~all_received
    for i=1:n_requested
        if ~present_now(i); continue; end
        
        [ok,err_mess,message]=receive_message_(obj,task_ids(i),mess_name);
        if ok ~= MESS_CODES.ok
            if ok == MESS_CODES.job_canceled
                error('MESSAGE_FRAMEWORK:canceled',err_mess);
            else
                error('FILEBASED_MESSAGES:runtime_error',...
                    'Can not receive existing message: %s, Err: %s',...
                    message_names{i},err_mess);
            end
        end
        all_messages{i} = message;
        tid_received_from(i) = task_ids(i);
        mess_received(i) = true;
    end
    if obj.DEBUG_
        disp(' Messages received:');
        disp(mess_received');
        for i=1:numel(all_messages)
            disp(all_messages{i});
            if ~isempty(all_messages{i})
                disp(all_messages{i}.payload)
            end
        end
        
    end
    
    
    if lock_until_received
        all_received = all(mess_received);
        if ~all_received
            t1 = toc(t0);
            if t1>obj.time_to_fail_
                error('FILEBASED_MESSAGES:runtime_error',...
                    'Timeout waiting for receiving all messages')
            end
            [message_names,tid_from] = list_all_messages_(obj,task_ids,mess_name);
            %[tid_from,im] = unique(tid_from);
            %message_names = message_names(im);
            present_now = ismember(task_ids,tid_from);
            % verify data messages already present not to force overwriting
            % existing received data messages
            is_old_data_mess = cellfun(@is_data_message,all_messages,...
                'UniformOutput',true);
            if obj.DEBUG_
                nsteps  = nsteps +1;
                disp([' Messages arrived at step ',num2str(nsteps), 'vs old data mess']);
                disp(present_now);
                for i=1:numel(message_names)
                    disp(message_names{i});
                end
                disp(is_old_data_mess');
            end
            
            if any(is_old_data_mess )
                present_now = present_now & ~is_old_data_mess';
            end
            
            pause(0.1);
        end
    else
        break;
    end
    
end
if ~lock_until_received
    all_messages = all_messages(mess_received);
    tid_received_from = tid_received_from(mess_received);
end
% sort received messages according to task id to ensure consistent sequence
% of task messages
if ~isempty(tid_received_from)
    [tid_received_from,ic]  = sort(tid_received_from);
    all_messages  = all_messages(ic);
end



function is = is_data_message(mess)
if isempty(mess)
    is = false;
    return
end
is = mess.is_blocking;


