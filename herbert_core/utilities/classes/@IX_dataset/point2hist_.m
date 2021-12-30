function obj_out = point2hist_ (obj, iax)
% Convert point IX_dataset object or array to histogram object(s).
%
%   >> obj_out = point2hist_ (obj)        % convert all axes
%   >> obj_out = point2hist_ (obj, iax)   % convert given axis or axes
%
% Any histogram data axes are left unchanged.
%
% Input:
% -------
%   obj     IX_dataset object or array of objects
%
%   iax     [optional] axis index, or array of indicies, in range 1 to ndim
%           Default: 1:ndim
%
% Output:
% -------
%   obj_out IX_dataset object or array of objects with point axes
%           converted to histogram axes
%
%
% Notes:
% Point datasets are converted to distributions as follows:
%       Point distribution => Histogram distribution;
%                             Signal numerically unchanged
%
%         non-distribution => Histogram distribution;
%                             Signal numerically unchanged
%                             *** NOTE: The signal caption will be plotted
%                               incorrectly if units are given in the axis
%                               description of the point data
%
% Point data is always converted to a distribution: it is assumed that
% point data represents the sampling of a function at a series of points,
% and only a histogram as a distribution is consistent with that.

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('IX_dataset')),'_docify')
%
%   doc_file = fullfile(doc_dir,'doc_point2hist_method.m')
%
%   object = 'IX_dataset'
%   method = 'point2hist_'
%   ndim = 'ndim'
% -----------------------------------------------------------------------------
% <#doc_beg:> IX_dataset
%   <#file:> <doc_file>
% <#doc_end:>
% -----------------------------------------------------------------------------


nd = obj.ndim();    % works even if empty obj array, as static method

% Check the validity of the axis indices
if nargin==1
    iax = 1:nd;
else
    if isempty(iax) || ~isnumeric(iax) || any(rem(iax,1)~=0) ||...
            any(iax<1) || any(iax>nd) || numel(unique(iax))~=numel(iax)
        if nd==1
            mess = 'Axis indices can only take the value 1';
        else
            mess = ['Axis indices must be unique and in the range 1 to ',...
                num2str(nd)];
        end
        error('HERBERT:point2hist_:invalid_argument', mess)
    end
end

% Convert each object in turn
obj_out = obj;
for i = 1:numel(obj)
    obj_out(i) = point2hist_single_(obj(i), iax);
end


%--------------------------------------------------------------------------
function obj_out = point2hist_single_(obj, iax)
% Convert point data axes in an IX_dataset to histogram axes

ipnt2hist = iax(~ishistogram_(obj, iax));
if numel(ipnt2hist)>0
    x = obj.xyz_;
    s = obj.signal_;
    e = obj.error_;
    x_distribution = obj.xyz_distribution_;
    xcur = x;
    for idim = ipnt2hist
        % Average signal over points with the same positions on a point
        % data axis. Note that this operation is commutative across all
        % the point data axes, so we can repeatedly operate on the signal
        % and error arrays
        xdim = xcur{idim};
        if numel(xdim)>0
            dx_non_zero = (diff(xdim)~=0);
            if ~all(dx_non_zero)
                % Get unique x axis values. Even if there is only one unique
                % value, get bin boundaries from it
                xdim_unique = xdim([true, dx_non_zero]);
                x{idim} = bin_boundaries (xdim_unique);
                [~, s, e] = average_points (xcur{idim}, s, e, idim, x{idim});
            else
                x{idim} = bin_boundaries (xdim);
            end
        else
            % No data points on the axis, but must give a finite value
            x{idim} = 0;
        end
    end
    x_distribution(ipnt2hist) = true;
    obj_out = init_ (obj, x, s, e, x_distribution);
end
