function [fig_handle, axes_handle, plot_handle] = de(w,varargin)
% Draws a plot of error bars for an IX_dataset_2d or array of IX_dataset_2d
%
%   >> de(w)
%   >> de(w,xlo,xhi)
%   >> de(w,xlo,xhi,ylo,yhi)
%
% Advanced use:
%   >> de(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = de(w,...) 

% Check input arguments
[ok,mess]=parse_args_simple_ok_syntax({'name'},varargin{:});
if ~ok
    error(mess)
end

% Perform plot
[fig_,axes_,plot_]=de(IX_dataset_1d(w),varargin{:});

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
