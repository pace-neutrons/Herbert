function ticks_ = check_and_set_labels_(ticks_, labels)
% Check tick labels are valid, converting to row cellstr if needed.
% Checks that the new labels are consistent with the number of positions.

if ~isempty(labels)
    % Set tick labels
    [ok, cout] = str_make_cellstr(labels);
    if ok
        if numel(ticks_.positions) == numel(cout)
            ticks_.labels = cout(:)';   % make it a row vector
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
    ticks_.labels = {};     % set to default empty value
end
