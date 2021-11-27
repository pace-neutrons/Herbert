function [origin, low_closed, high_closed] = parse_origin (str)

if numel(str)==2
    origin = str;
    low_closed = true;
    high_closed = false;
elseif numel(str)==4
    origin = str(2:3);
    low_closed = (str(1)=='[');
    if ~low_closed && str(1)~='('
        error('HERBERT:parse_origin:invalid_argument',...
            'Lower interval closure must be ''['' or ''(''')
    end
    high_closed = (str(4)==']');
    if ~high_closed && str(4)~=')'
        error('HERBERT:parse_origin:invalid_argument',...
            'Upper interval closure must be '']'' or '')''')
    end
else
    error('HERBERT:parse_origin:invalid_argument',...
        'Number of characters is incorrect in interval type')
end
