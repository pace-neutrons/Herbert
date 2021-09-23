function ticks_ = check_and_set_positions_(ticks_, val)
% Check tick label positions, converting to row vector if needed

% Checks that the new labels are consistent with the number of positions.

if ~isempty(val)
    % Fill positions, clearing tick labels if positions are changed
    if isnumeric(val)
        if ~isequal(ticks_.positions, val(:)')
            ticks_.positions = val(:)'; % make a row vector
            ticks_ = check_and_set_labels_ (ticks_, []); % set to default
        end
        
    else
        error('HERBERT:check_and_set_positions_:invalid_argument',...
            'Tick positions must be a numeric vector');
    end
    
else
    % Default empty positions array
    ticks_.positions = [];
end
