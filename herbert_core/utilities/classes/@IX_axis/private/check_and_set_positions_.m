function obj = check_and_set_positions_(obj, positions)
% Check tick label positions, converting to row vector if needed

if isempty(positions)
    obj.ticks_.positions = [];
    obj.ticks_.labels = {};
    
elseif isnumeric(positions)
    if ~isequal(obj.ticks_.positions, positions(:)')
        obj.ticks_.positions = positions(:)';   % row vector
        obj.ticks_.labels = {};
    end
    
else
    error('HERBERT:check_and_set_positions_:invalid_argument',...
        'Tick positions must be a numeric vector');
end
