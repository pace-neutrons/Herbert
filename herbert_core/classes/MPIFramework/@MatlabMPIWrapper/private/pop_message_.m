function [message,tag_rec,source] = pop_message_(obj,target_id,mess_tag,is_blocking)
% Restore requested message from the message cache, if it is
% there, or throw error, if the message is not available
%
% Inputs:
% target_id -- the fake labNum to check for message
% mess_tag  -- if not empty, the message tag to check message
%              for. Empty if any tag is suitable
% is_blocking -- what kind of message is requested. If blocking, throw on
%                missing message, if non-blocking, return empty message on
%                failure.
% Returns:
% message -- the instance of aMessage class, presumablu
%            returned from the target
% tag_rec -- the tag of the received message (duplicates the
%            message class information but provided for
%            consistency.
% source  -- the address of the node, the result has been returned from.
%            current version -- must be equal to taget_id
%
source = target_id;
if isKey(obj.messages_cache_,target_id)
    cont = obj.messages_cache_(target_id);
    info = cont{1};
    tag_rec = info.tag;
    message = info.mess;
    message = aMessage.loadobj(message);
    if ~isempty(mess_tag)
        tag = mess_tag;
        if ~(tag==-1 || strcmp(tag,'any'))
            if tag ~=tag_rec
                if is_blocking
                    error('MATLAB_MPI_WRAPPER:runtime_error',...
                        'Attempt to issue blocking receive from lab %d, tag %d Tag present: %d',...
                        target_id,tag,tag_rec )
                else
                    message = [];
                    return;
                end
            end
        end
    end
    if numel(cont)>1
        cont = cont(2:end);
        obj.messages_cache_(target_id) = cont;
    else
        remove(obj.messages_cache_,target_id);
    end
else
    if isempty(target_id)
        error('MATLAB_MPI_WRAPPER:runtime_error',...
            'Requesting receive from undefined lab')
        % PREVIOUS VERSION: should this behaviour to be supported?
        %         if obj.messages_cache_.Count == 0
        %             error('MATLAB_MPI_WRAPPER:runtime_error',...
        %                 'Attempt to issue blocking receive from Any lab')
        %         end
        %         sources = obj.messages_cache_.keys;
        %         source = sources{1};
        %         [message,tag_rec] = pop_message_(obj,source);
        %         return;
    end
    if is_blocking
        error('MATLAB_MPI_WRAPPER:runtime_error',...
            'Attempt to issue blocking receive from lab %d',...
            target_id)
    else
        message = [];
        tag_rec = [];
    end
end
