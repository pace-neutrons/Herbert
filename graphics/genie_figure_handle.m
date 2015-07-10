function [h,ok,mess]=genie_figure_handle (fig_name)
% Return handle(s) of figure(s)
%
%   >> h=genie_figure_handle (fig_name)
%
%   fig_name    Figure name or cellstr of figure names
%
%   h           Column vector of handles of any figures with names that match one of the input names
%               Figure names that do not exist are simply ignored.
%   ok          True if all OK, false otherwise
%   mess        '' if OK, error message if not OK
%
%  If given figure handle(s) rather than name(s), then these are passed through
%  transparently (apart from conversion to column vector) unless one or more
%  of the handles is not a figure handle, in which case an error is thrown.

if isnumeric(fig_name)   % could be array of figure handles
    if verLessThan('matlab','8.4')
        id=fig_name;
        ok_id=ishandle(id);
        if all(ok_id) && isequal(findobj(id,'type','figure'),id(:))
            h=id(:);    % ensure column
            ok=true; mess=''; return
        else
            h=[]; ok=false; mess='Check validity of figure handle(s)'; return
        end
    else
        all_fig = get(0,'Children');
        fig_numbers = zeros(numel(all_fig),1);
        for i=1:numel(all_fig)
            fig_numbers(i)= all_fig(i).Number;
        end
        for i = 1:numel(fig_name)
            fi = find(fig_numbers==fig_name(i));
            if ~isempty(fi)
                h = all_fig(fi); ok=true; mess=[];
                return
            end
        end
        h=[]; ok=false; mess='Check validity of figure handle(s)';
        return        
    end
    
elseif ischar(fig_name) || iscellstr(fig_name)
    if ischar(fig_name) && numel(size(fig_name))==2
        fig_name=cellstr(fig_name);
    elseif ~iscellstr(fig_name)
        h=[]; ok=false; mess='Check validity of figure name(s)'; return
    end
    fig_name=strtrim(fig_name); % trim leading and training blanks
    h=[];
    for i=1:numel(fig_name)
        h=[h;findobj('name',fig_name{i},'type','figure')];
    end
    ok=true; mess=''; return
elseif isa(fig_name,'matlab.ui.Figure')
    h=fig_name; ok=true;mess=''; return
else
    h=[]; ok=false; mess='Check validity of figure name(s)'; return
end
