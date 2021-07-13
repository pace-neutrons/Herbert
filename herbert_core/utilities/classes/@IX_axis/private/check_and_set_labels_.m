function obj = check_and_set_labels_(obj, labels)
% Check tick labels are valid, converting to row cellstr if needed

if ~isempty(labels)
    % Set tick labels
    [ok, cout] = str_make_cellstr(labels);
    if ok
        if numel(obj.ticks_.positions) == numel(cout)
            obj.ticks_.labels = cout';   % row vector
        else
            error('HERBERT:check_and_set_labels_:invalid_argument',...
                'Number of tick labels must match the number of tick positions');
        end
    else
        error('HERBERT:check_and_set_labels_:invalid_argument',...
            'Tick labels must be a character array or cell array of character strings');
    end
else
    % Clear tick labels
    obj.ticks_.labels = {};     % set to default empty value
end
