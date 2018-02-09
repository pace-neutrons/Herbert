function all_messages = list_all_messages_(obj,task_ids)
% list all messages belonging to the job and retrieve all their names
% for the lobs with id, provided as input.
% if no message is returned for a job, its name cell remains empty.
if ~exist('task_ids','var')
    task_ids = [];
end


mess_folder = obj.exchange_folder;
folder_contents = dir(mess_folder);
if numel(folder_contents )==0
    return;
end
[mess_names,mess_id] = parce_folder_contents_(folder_contents);
if isempty(task_ids)||numel(task_ids) == 0
    all_messages = mess_id;
else    
    all_messages = cell(numel(task_ids),1);
    for id=1:numel(task_ids)
        
        %correct_ind = ismember(mess_id,task_ids(id));
        correct_ind = (mess_id == task_ids(id));
        if any(correct_ind)
            if sum(correct_ind) > 1 % this may only happen in tests when test failed initially but then
                % has been fixed but previous messages have not been deleted.
                all_messages(id)={mess_names(correct_ind)};
            else
                all_messages(id)=mess_names(correct_ind);
            end
        end
    end
    
end
