function obj = check_and_set_ticks_(obj, ticks)
% Method verifies axis ticks properties and sets axis ticks if valid

if isempty(ticks)
    obj = check_and_set_positions_(obj, []);
    obj = check_and_set_labels_(obj, {});
    
elseif isstruct(ticks) && all(isfield(ticks,{'positions','labels'}))
    try
        obj = check_and_set_positions_(obj, ticks.positions);
        obj = check_and_set_labels_(obj, ticks.labels);
    catch ME
        rethrow(ME)
    end
else
    error('HERBERT:check_and_set_ticks_:invalid_argument',...
        'Ticks structure must have fields ''positions'' and ''labels''');
end
