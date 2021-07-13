function obj = check_and_set_caption_(obj, caption)
% Check caption and set if valid, converting to column cellstr if needed

if isempty(caption)
    obj.caption_ = {};
    
elseif ischar(caption) && numel(size(caption))==2
    obj.caption_ = cellstr(caption);
    
elseif iscellstr(caption)
    obj.caption_ = caption(:);
    
elseif isstring(caption)
    obj.caption_ = cellstr(caption(:));
    
else
    error('HERBERT:check_and_set_caption_:invalid_argument',...
        'Caption must be character, string array or cell array of strings');
end
