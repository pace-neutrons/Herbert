function [all_messages,mid_from] = list_all_messages_(obj,task_ids_requested,mess_name_or_tag)
% list all messages sent to this task and retrieve the names
% for the lobs with id, provided as input.
%
% if no message is returned for a job, its name cell remains empty.
%
if ~exist('mess_ids_requested','var')
    task_ids_requested = []; % list all available task_ids
elseif ischar(task_ids_requested) && strcmpi(task_ids_requested,'any')
    task_ids_requested = [];
end
if ~exist('mess_name_or_tag','var')
    mess_tag_requested = [];
    mess_names_req = {};    
elseif ischar(mess_name_or_tag)
    if isempty(mess_name_or_tag) || strcmpi(mess_name_or_tag,'any')
        mess_tag_requested = [];
        mess_names_req = {};            
    else
        mess_tag_requested = MESS_NAMES.mess_id(mess_name_or_tag);
        mess_names_req = mess_name_or_tag;
    end
elseif isnumeric(mess_name_or_tag)
    is = MESS_NAMES.tag_valid(mess_name_or_tag);
    if is
        mess_tag_requested = mess_name_or_tag;
        mess_names_req  = MESS_NAMES.mess_name(mess_tag_requested);
    else
        error('FILEBASED_MESSAGES:invalid_argument',...
            'one all of the tags among the tags provided in tags list is not recognized')
    end
else
end

if ischar(mess_names_req)
    mess_names_req = {mess_names_req};
end

mess_folder = obj.mess_exchange_folder;
if ~(exist(mess_folder,'dir')==7) % job was canceled
    error('FILEBASED_MESSAGES:runtime_error',...
        'Job with id %s has been canceled. No messages folder exist',obj.job_id)
end

folder_contents = get_folder_contents_(obj,mess_folder);



[mess_names,mid_from,mid_to] = parse_folder_contents_(folder_contents,'nolock');
if isempty(mess_names) % no messages
    all_messages = {};
    mid_from     = [];
    % add persistent messages names to the messages, received from other labs
    [all_messages,mid_from] = obj.retrieve_interrupt(all_messages,mid_from,task_ids_requested);
    return
end

to_this = mid_to == obj.labIndex;
if ~any(to_this) % no messages directed to this lab
    all_messages = {};
    mid_from     = [];
    % add persistent messages names to the messages, received from other labs
    [all_messages,mid_from] = obj.retrieve_interrupt(all_messages,mid_from,task_ids_requested);
    return
end
all_messages = mess_names(to_this);
mid_from     = mid_from(to_this);
if isempty(task_ids_requested) && isempty(mess_tag_requested) % all messages we need are listed
    % add persistent messages names to the messages, received from other labs
    [all_messages,mid_from] = obj.retrieve_interrupt(all_messages,mid_from,task_ids_requested);
    return;
end

if ~isempty(mess_tag_requested) % we have some particular message tags requested
    %mess_tags_present = MESS_NAMES.mess_id(all_messages);
    % allow to list fail message
    is_requested  = ismember(all_messages,[mess_names_req(:);'failed']);
    all_messages = all_messages(is_requested);
    mid_from     = mid_from(is_requested);
end

if ~isempty(task_ids_requested)
    is_requested = ismember(mid_from,task_ids_requested);
    all_messages = all_messages(is_requested);
    mid_from     = mid_from(is_requested);
end
% add persistent messages names to the messages, received from other labs
[all_messages,mid_from] = obj.retrieve_interrupt(all_messages,mid_from,task_ids_requested);

