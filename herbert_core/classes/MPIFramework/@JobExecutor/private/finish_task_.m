function [ok,err_mess,obj]=finish_task_(obj,varargin)
% set up tag, indicating that the job have finished and
% send message with output job results.
%
%Input form:
% [ok,err_mess,obj]= finish_task_(obj,OtherMessage,mess_reduction_function,...
%                    ['-synchronous'|'-asynchronous']);
%
% clear all existing messages intended or generated by this job
%
% wait for all messages of this kind to arrive
pause(0.1); % rather for tests then for any reasonable error.
syncronize = true;
if nargin > 1
    [ok,err_mess,synchr,asynch,argi] = parse_char_options(varargin,{'-synchronous','-asynchronous'});
    if ~ok
        error('JOB_EXECUTOR:invalid_argument',err_mess);
    end
    if synchr
        if asynch
            error('JOB_EXECUTOR:invalid_argument',...
                'both -synchronous and -asynchronous options can not be specified together');
        else
            syncronize = true;
        end
    else
        syncronize = ~asynch;
    end
    
else
    argi = {};
end

if numel(argi) > 0
    is_mess = cellfun(@(x)isa(x,'aMessage'),argi,'UniformOutput',true);
    if any(is_mess)
        mess = argi{is_mess}; % only one should occur. Will reject second one.
        argi = argi(~is_mess);
    else
        mess = [];
    end
else
    mess = [];
end

if isempty(mess) % Job completed successfully
    mess = CompletedMessage();
    if obj.return_results_
        mess.payload = obj.task_results_holder_;
    end
else %
    %disp(['in finish task, got message with id: ',mess.mess_name]);
    if obj.return_results_  && ~isempty(obj.task_results_holder_)
        if isempty(mess.payload)
            mess.payload = obj.task_results_holder_;
        else
            mess.payload = [{mess.payload},obj.task_results_holder_];
        end
    end
end
%
if ~isempty(argi)
    is_fh = cellfun(@(x)isa(x,'function_handle'),argi,'UniformOutput',true);
    mess_reduction_function = argi{is_fh}; % again, only first will be returned, which is correct but implicit
else
    mess_reduction_function = [];
end
%
obj.mess_framework.throw_on_interrupts = false;
[ok,err_mess,obj] = obj.reduce_send_message(mess,'completed',mess_reduction_function,syncronize);
obj.mess_framework.throw_on_interrupts = true;

if ok == MESS_CODES.ok
    ok  = true;
else
    ok  = false;
end

try
    % clear all previous messages may be left in the message cache
    % (especially 'failed' message which is never popped in normal way)
    obj.mess_framework.clear_messages();
catch ME
    ok = false;
    err_mess = ['JE Message framework Error clearing messages: ' ME.message];
end
try
    % Also clear data messes counters, to restart data messages queue from the
    % beginning
    obj.control_node_exch.clear_messages();
catch ME
    if ~ok
        err_mess = [err_mess, ' and JE control node exchange: ' ME.message];
    else
        ok = false;
        err_mess = ['JE control note exchange framework Error clearing messages: ' ME.message];
    end
end
% clear task results holder
obj.task_results_holder_ = {};
