function [fig_handle, axes_handle, plot_handle] = ppoc(w)
% Overplot markers and error bars for an IX_dataset_2d or array of IX_dataset_2d on the current plot
%
%   >> ppoc(w)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ppoc(w) 

% Check there is a current figure
if isempty(findall(0,'Type','figure'))
    disp('No current figure exists - cannot overplot.')
    return
end

% Perform plot
[fig_,axes_,plot_]=ppoc(IX_dataset_1d(w));

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
