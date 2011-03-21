function [fig_h, axes_h, plot_h, plot_type] = genie_figure_all_handles (fig)
% Get figure, axes and plot handles for current figure or named figure
%
%   >> [fig_h, axes_h, plot_h] = genie_figure_handles
%   >> [fig_h, axes_h, plot_h] = genie_figure_handles (fig)

% Determine which figure to get handles
if ~exist('fig','var')||(isempty(fig)),
    if isempty(findall(0,'Type','figure'))
        disp('No current figure exists - no figure to get handles.')
        return
    else
        fig=gcf;
    end
else
    [fig,ok,mess]=genie_figure_handle(fig);
    if ~ok, error(mess), end
    if isempty(fig)
        disp('No figure(s) with given name(s) or figure number(s) - no figures to get handles.')
        return
    end
end

% Figure handle
fig_h=fig;

% Axes handle
h_children=get(fig_h,'children');
type_children=get(h_children,'type');
ind=find(strcmp('axes',type_children));
if numel(ind)==1
    axes_h=h_children(ind);
elseif numel(ind)>0
    error('More than one axes handles - function not valid with this figure')
elseif numel(ind)==0
    error('No axes handle - function not valid with this figure')
end
    
% Plot handle(s)
h_children=get(axes_h,'children');
type_children=get(h_children,'type');
ok_plot_types={'line','patch','surface'};
isplot_h=false(size(h_children));
plot_type=cell(size(h_children));
for i=1:numel(ok_plot_types)
    ok_ind=strcmp(ok_plot_types{i},type_children);
    isplot_h=isplot_h | ok_ind;
    plot_type(ok_ind)=ok_plot_types(i);
end
plot_h=h_children(ind);
plot_type=plot_type(isplot_h);
