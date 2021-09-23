function caption = check_and_set_caption_ (val)
% Check caption and set if valid, converting to column cellstr if needed

if ~isempty(val)
    % Set caption
    [ok, caption] = str_make_cellstr(val);
    if ~ok
        error('HERBERT:check_and_set_caption_:invalid_argument',...
            'Caption must be character, string array or cell array of strings');
    end
    
else
    % Set caption to default empty value
    caption = {};
end
