function wout = simple_integrate_x(win, varargin)
% Integrate IX_dataset_2d along x axis using reference 1D algorithm
%
%   >> wout = simple_integrate_x (win, xmin, xmax)
%   >> wout = simple_integrate_x (win, [xmin, xmax])
%
% Simple implementation converting to array of IX_dataset_1d, and then converting back.
% Only works for a single input IX_dataset_2d.
% Does not do full syntax checking

if numel(win)~=1
    error('Method only works for a single input dataset, not an array')
end

if numel(varargin)>=1
    wtmp=IX_dataset_1d(win);
    wouttmp=integrate_ref(wtmp,varargin{:});
    wout=IX_dataset_2d(wouttmp);
    wout.y=win.y;
    wout.y_axis=win.y_axis;
    wout.y_distribution=win.y_distribution;
else
    wout=win;
end
