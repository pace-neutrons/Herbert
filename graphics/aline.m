function aline(varargin)
% Change the line type (given by character string) and width
%
% Syntax examples:
%	>> aline(2)
%	>> aline(0.5,':')
%   >> aline('-.')
%	>> aline('-',10)
%
% Arguments can set a sequence of type and/or size for cascade plots e.g.
%   >> aline (1,2,':','-','-.')
%   >> aline ({'-','--'},1:0.5:4)   % example with a cell array and implicit array of linewidths
%
% Valid line types: type either the Matlab code or text equivalent (as minimum abbreviations)
%        '-'      solid
%        '--'     dashed
%        ':'      dotted
%        '-.'     ddot (dashed-dot)
%
% Line width is in points (default size is 0.5)

% Create two row vectors, of line widths and line styles:
narg = length(varargin);

% No argument => display current colour(s)
if narg < 1
    %line_width=get_global_var('genieplot','line_width');
    %line_style=get_global_var('genieplot','line_style');
    [line_width,yscale]=get(graph_config,'line_width','line_style');	
    disp('Current line width(s) and style(s):')
    disp(line_width)
    disp(line_style)
    return
end

line_width = [];
line_type =[];
for i = 1:narg
    try
        temp = evalin('caller',varargin{i});
    catch
        temp = varargin{i};
    end
    if isnumeric(temp) && isvector(temp)
        line_width = [line_width,temp(:)']; % make argument a row vector
    elseif iscellstr(temp)
        temp=strtrim(temp);
        line_type = [line_type,temp(:)'];   % make argument a row vector
    elseif ischar(temp) && length(size(temp))==2
        temp=strtrim(cellstr(temp));
        line_type = [line_type,temp(:)'];   % make argument a row vector
    else
        error ('Check argument type(s)')
    end
end

% Check validity of input arguments
if ~isempty(line_width)
    if min(line_width) >= 0.1 && max(line_width) <= 50
        %set_global_var('genieplot','line_width',line_width);
		set(graph_config,'line_width',line_width);	
    else
        error ('Line width(s) too small or too large - current value(s) left unchanged')
    end
end

lstyle_char = {'-','--',':','-.'};
lstyle_name = {'solid','dashed','dotted','ddot'};
if ~isempty(line_type)
    for i=1:length(line_type)
        itype = string_find (line_type{i}, lstyle_char);
        if itype == 0
            itype = string_find (line_type{i}, lstyle_name);
        end
        if itype>0
            line_type{i} = lstyle_char{itype};
        elseif itype==0
            error ('Invalid line style - left unchanged (aline)')
        elseif itype<0
            error ('Ambiguous abbreviation of line style - left unchanged (aline)')
        end
    end
    %set_global_var('genieplot','line_type',line_type);
	set(graph_config,'line_type',line_type);		
end
