function [res,varargout] = parpool_mpi_probe_all_tester(job_control,communicator_control)
%
if isempty(which('herbert_init'))
    herbert_on();
end

if exist('communicator_control', 'var')
    if isstruct(communicator_control)
        pm = MessagesParpool(communicator_control);
    else
        pm = communicator_control;
    end
else
    pm = MessagesParpool('parpool_MPI_tester');
end

nl = pm.numLabs;
if nl > 1 && ~pm.is_tested
    mis = MPI_State.instance();
    mis.is_deployed = true;
end



all_lab_ind = 1:nl;
are_receivers = rem(all_lab_ind,3)==0;
receiver_ind  = all_lab_ind(are_receivers);

li = pm.labIndex;

filepath = job_control.filepath;
fnt = job_control.filename_template;
fname = sprintf(fnt,li,nl);
file = fullfile(filepath,fname);
fileID = fopen(file,'w');
fprintf(fileID,'%s; numlabs: %d,labID: %d\n',fname,nl,li);
fclose(fileID);



if ismember(li,receiver_ind)
    receiver= true;
else
    receiver = false;
end
%

if receiver
    lab_senders = find_lab_senders(li,nl);
    n_senders = numel(lab_senders);
    res  = cell2struct(cell(5,n_senders),...
        {'srcWkrInd','senders','mess_names','mess','rec_mess_id'});
    
    pause(1);
    [mess_names,task_ids_from] = pm.probe_all(lab_senders);
    res = set_results(li,res,task_ids_from,mess_names);
    
    
    [all_messages,task_ids_from] = pm.receive_all(lab_senders,'started','-synch');
    for i=1:n_senders
        res(i).mess = all_messages{i};
        res(i).rec_mess_id =task_ids_from(i);
    end
    err = [];
else %sender
    
    lab_receiver = find_lab_receiver(li,nl,receiver_ind);
    
    if lab_receiver == 0
        res = [];
        err = 1;
        return;
    end
    if lab_receiver < li
        mess1 = aMessage('queued');
        mess2 = aMessage('started');
    else
        mess1 = LogMessage();
        mess2 = aMessage('started');
        
    end
    [ok1,err1] = pm.send_message(lab_receiver,mess1);
    [ok2,err2] = pm.send_message(lab_receiver,mess2);
    %[ok2,err2] = pm.send_message(lab_receiver,mess2);
    res = (ok1 == MESS_CODES.ok) &&(ok2 == MESS_CODES.ok);
    if res
        err = [];
    else
        err = {err1,err2};
    end
    %res = ok1;
    %err = err1;
end
if nargout>1
   varargout{1} = err;    
end
if nargout>2
    varargout{2} = pm;
else
    pm.clear_messages();
end

function ind = cycle_ind(ind0,period)
ind = ind0;
if ind  < 1
    ind = ind + period;
end
if ind > period
    ind  = ind - period;
end

function res = set_results(li,res,task_ids,mess_names)
n_senders = numel(task_ids);
for i=1:n_senders
    tid = task_ids(i);
    %fprintf(' lab: %d, tid: %d\n',li,tid);
    if tid  == 0
        continue;
    end
    res(i).srcWkrInd = li;
    if isempty(res(i).senders)
        res(i).senders = tid;
        res(i).mess_names = mess_names{i};
    else
        res(i).senders  = [{tid},res(i).senders ];
        res(i).mess_names = [{mess_names{i}},res(i).mess_names];
    end
end


function lab_rec = find_lab_receiver(li,num_labs,receiver_ind)

ind = cycle_ind(li-1,num_labs);
if ismember(ind,receiver_ind)
    lab_rec = ind;
    return
end
ind = cycle_ind(li+1,num_labs);
if ismember(ind,receiver_ind)
    lab_rec = ind;
    return
end
lab_rec  = 0;

function lab_send = find_lab_senders(li,num_labs)

lab_send  = [cycle_ind(li-1,num_labs),cycle_ind(li+1,num_labs)];
