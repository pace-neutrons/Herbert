function ticks = check_and_set_ticks_ (val)
% Method verifies axis ticks properties and sets axis ticks if valid

ticks = struct('positions', [], 'labels', []);

if ~isempty(val)
    % Create ticks structure
    if isstruct(val) && all(isfield(val,{'positions','labels'}))
        try
            ticks = check_and_set_positions_ (ticks, val.positions);
            ticks = check_and_set_labels_ (ticks, val.labels);
        catch ME
            rethrow(ME)
        end
        
    else
        error('HERBERT:check_and_set_ticks_:invalid_argument',...
            'Ticks structure must have fields ''positions'' and ''labels''');
    end
    
else
    % Fill ticks with default values
    try
        ticks = check_and_set_positions_ (ticks, []);
        ticks = check_and_set_labels_ (ticks, []);
    catch ME
        rethrow(ME)
    end
end
