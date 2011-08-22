function [fig_handle, axes_handle, plot_handle] = ds(w,varargin)
% Draw a surface plot of an IX_dataset_2d or array of IX_dataset_2d
%
%   >> ds(w)
%   >> ds(w,xlo,xhi)
%   >> ds(w,xlo,xhi,ylo,yhi)
%   >> ds(w,xlo,xhi,ylo,yhi,zlo,zhi)
%
% Advanced use:
%   >> ds(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = da(a,...) 

% Check input arguments
[ok,mess]=parse_args_simple_ok_syntax({'name'},varargin{:});
if ~ok
    error(mess)
end

% Perform plot
[fig_,axes_,plot_,ok,mess]=plot_twod (w,varargin{:},'newplot',true,'type','surface');
if ~ok
    error(mess)
end

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
