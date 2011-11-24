function wout = rebind(win, varargin)
% Rebin an IX_dataset_1d object or array of IX_dataset_1d objects along the x-axis
%
%   >> wout = rebind(win, xlo, xhi)      % keep data between xlo and xhi, retaining existing bins
%
%	>> wout = rebind(win, xlo, dx, xhi)  % rebin from xlo to xhi in intervals of dx
%
%       e.g. rebind(win,2000,10,3000)    % rebins from 2000 to 3000 in bins of 10
%
%       e.g. rebind(win,5,-0.01,3000)    % rebins from 5 to 3000 with logarithmically
%                                     spaced bins with width equal to 0.01 the lower bin boundary 
%
%   >> wout = rebind(win, [x1,dx1,x2,dx2,x3...]) % one or more regions of different rebinning
%
%       e.g. rebind(win,[2000,10,3000])
%       e.g. rebind(win,[5,-0.01,3000])
%       e.g. rebind(win,[5,-0.01,1000,20,4000,50,20000])
%
%   >> wout = rebind(win,wref)           % rebin win with the bin boundaries of wref
%
% For any datasets of the array win that contain point data the averaging of the points
% can be controlled:
%
%   >> wout = rebind (...)               % default method: point averaging
%   >> wout = rebind (..., 'int')        % trapezoidal integration
%
%
% Note that this function correctly accounts for x_distribution if histogram data.
% Point data is averaged, as it is assumed point data is sampling a function.
% The individual members of the array of output datasets, wout, have the same type as the 
% corresponding input datasets.

% T.G.Perring 3 June 2011 Based on the original mgenie rebin routine, but with
%                         extension to non-distribution histogram datasets, added
%                         trapezoidal integration for point data.

if numel(win)==0, error('Empty object to rebin'), end
if nargin==1, wout=win; return, end     % benign return if no arguments

rebin_hist_func={@rebin_1d_hist};
integrate_points_func={@integrate_1d_points};
integrate_data=false;
point_integration_default=false;
iax=1;                      % axes to integrate over
isdescriptor=true;          % accept only rebin descriptor

[wout,ok,mess] = rebin_IX_dataset_nd (win, rebin_hist_func, integrate_points_func,...
                     integrate_data, point_integration_default, iax, isdescriptor, varargin{:});
if ~ok, error(mess), end
