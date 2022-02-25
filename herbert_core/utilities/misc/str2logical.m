function tf = str2logical(str)

str = split(str);
tf = cellfun(@str2logical_, str);

end

function tf = str2logical_(str)

switch lower(str)
  case 'true'
    tf = true;
  case 'false'
    tf = false;
  otherwise
    match = regexp(str, '^[0-9]+$', 'match');
    if ~isempty(match)
        tf = logical(str2num(match{1}));
    else
        tf = false;
    end
end

end
