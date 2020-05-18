function mess = process_fail_state_(obj,ME,is_tested,log_file_h)

if ~exist('log_file_h','var')
    log_file_h = [];
    DO_LOGGING = false;
else
    DO_LOGGING = true;
end

if strcmpi(ME.identifier,'JOB_EXECUTOR:canceled') || strcmpi(ME.identifier,'MESSAGE_FRAMEWORK:canceled')
    is_canceled = true;
    err_text = sprintf('Task N%d canceled',...
        obj.labIndex);
else
    is_canceled = false;
    err_text = sprintf('Task N%d failed at jobExecutor: %s. Reason: %s',...
        obj.labIndex,class(obj),ME.message);
end
%disp('error message')
%disp(ME)
%disp(['processing fail state, forming message: ',ME.identifier]);
mess = FailedMessage(err_text,ME);
% send canceled message to all other workers to finish their
% current job at log point.
if is_canceled
    if DO_LOGGING ; fprintf(log_file_h,'---> Job received "canceled" message\n'); end
else
    if DO_LOGGING ; fprintf(log_file_h,'---> Sending "canceled" message to neighbours\n'); end
    mf = obj.mess_framework;
    n_labs = mf.numLabs;
    this_lid = mf.labIndex;
    for lid=1:n_labs
        if lid ~=this_lid
            [ok,err]=mf.send_message(lid,'canceled');
            if ok ~=MESS_CODES.ok
                error('JOB_EXECUTOR:runtime_error',...
                    ' Error %s sending "canceled" message to neighouring node %d',...
                    err,lid);
            end
        end
    end
end

% finish task, in particular, removes all messages, directed to this
% lab
if ~is_tested
    % stop until other nodes fail due to cancellation and come
    % here
    % job has been interrupted before the barrier in the job
    % loop has been reached, so wait here for completed jobs to finish
    if obj.do_job_completed
        if DO_LOGGING ; fprintf(log_file_h,'--->Failing job not waiting for others\n'); end
    else
        if DO_LOGGING ; fprintf(log_file_h,'--->Arriving at Incompleted job barrier\n'); end
        obj.labBarrier(false);
    end
end

