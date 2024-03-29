function [fig_handle, axes_handle, plot_handle] = phoc(w)
% Overplot histogram for a spectrum or array of spectra on the current plot
%
%   >> phoc(w)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = phoc(w) 


% Check input arguments
opt=struct('newplot',false,'over_curr',true);
[args,ok,mess,lims,fig]=genie_figure_parse_plot_args(opt);
if ~ok, error(mess), end

% Perform plot
type='h';
[fig_,axes_,plot_,ok,mess]=plot_oned (w,opt.newplot,type,fig);
if ~ok, error(mess), end

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
