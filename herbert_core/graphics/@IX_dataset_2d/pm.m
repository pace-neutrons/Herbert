function [fig_handle, axes_handle, plot_handle] = pm(w,varargin)
% Overplot markers for an IX_dataset_2d or array of IX_dataset_2d on an existing plot
%
%   >> pm(w)
%
% Advanced use:
%   >> pm(w,'name',fig_name)        % overplot on figure with name = fig_name
%                                   % or figure with given figure number or handle
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = pm(w,...) 


% Check input arguments
opt=struct('newplot',false);
[args,ok,mess]=genie_figure_parse_plot_args(opt,varargin{:});
if ~ok, error(mess), end

% Perform plot
[fig_,axes_,plot_] = pm(IX_dataset_1d(w), args{:});

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
