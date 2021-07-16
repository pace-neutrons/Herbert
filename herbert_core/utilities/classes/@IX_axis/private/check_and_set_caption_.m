function obj = check_and_set_caption_(obj, caption)
% Check caption and set if valid, converting to column cellstr if needed

if ~isempty(caption)
    % Set caption
    [ok, cout] = str_make_cellstr(caption);
    if ok
        obj.caption_ = cout;
    else
        error('HERBERT:check_and_set_caption_:invalid_argument',...
            'Caption must be character, string array or cell array of strings');
    end
    
else
    obj.caption_ = {};
end
