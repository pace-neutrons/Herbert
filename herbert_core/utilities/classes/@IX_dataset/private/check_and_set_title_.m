function obj = check_and_set_title_(obj, val)
% Set title, converting to column cellstr if needed
%
%   >> obj = check_and_set_title_(obj, val)
%
% Input:
% ------
%   obj     IX_dataset object
%
%   val     Title for plot. One of:
%           - cellstr
%           - character string or 2D character array
%           - string array
%           If val is empty, then the title will be set to the default
%
% Output:
% -------
%   obj     Updated object
%           Title is a column cell array of character strings


if ~isempty(val)
    % Set title
    [ok, cout] = str_make_cellstr(val);
    if ok
        obj.title_ = cout;
    else
        error('HERBERT:check_and_set_title_:invalid_argument',...
            'Title must be character, string array or cell array of strings');
    end
    
else
    obj.title_ = cell(0,1);
end
