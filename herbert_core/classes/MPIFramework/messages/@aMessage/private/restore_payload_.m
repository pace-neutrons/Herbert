function payload = restore_payload_(input)
% Convert data structure, generated by saveobj into initial set of objects
%
%
%
% Itput:
% ------
%   struc   - the structure build by saveopbj method.
%   payload - the data restored by the function on the presious level of
%             iteration
%
% Output:
% -------
%   payload  -- restored data, presumably in the form, before saveobj was
%               applied

if isfield(input,'class_name')
    cls = input.class_name;
    try
        % try to use the loadobj function
        payload = eval([cls '.loadobj(input)']);
    catch ME
        try
            % pass the struct directly to the constructor
            payload = eval([cls '(input)']);
        catch ME
            try
                % try to set the fields manually
                payload = feval(cls);
                fn = fieldnames(input);
                for i=1:numel(fn)
                    try
                        set(payload,fn{i},input.(fn{i}));
                    catch ME
                        % Note: if this happens, your deserialized object might not be fully identical
                        % to the original (if you are lucky, it didn't matter, through). Consider
                        % relaxing the access rights to this property or add support for loadobj from
                        % a struct.
                        warn_once('restore_payload:restricted_access',...
                            'No permission to set property %s in object of type %s.',fn{i},cls);
                    end
                end
            catch
                payload = input;
            end
        end
    end
elseif isstruct(input)
    names=fieldnames(input);
    if numel(input) > 1
        % NOT IMPLEMENTED EFFICIENTLY. NEEDS RETHINKING
        data = struct2cell(input);
        data = cellfun(@(c)restore_payload_(c),data,...
            'UniformOutput',false);
        payload = cell2struct(data,names,1);
    else
        payload = struct();
        for i=1:numel(names)
            payload.(names{i}) = restore_payload_(input.(names{i}));
        end
    end
elseif iscell(input)
    payload  = cellfun(@(c)restore_payload_(c),input,...
        'UniformOutput',false);
else
    payload = input;
end


