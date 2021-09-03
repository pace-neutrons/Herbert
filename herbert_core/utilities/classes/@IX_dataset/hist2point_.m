function obj_out = hist2point_(obj, iax)
% Convert histogram IX_dataset object or array to point object(s).
%
%   >> obj_out = hist2point_ (obj)        % convert all axes
%   >> obj_out = hist2point_ (obj, iax)   % convert given axis or axes
%
% Any point data axes are left unchanged.
%
% Input:
% -------
%   obj     IX_dataset object or array of objects
%   iax     [optional] axis index, or array of indicies, in range 1 to ndim
%           Default: 1:ndim
%
% Output:
% -------
%   obj_out IX_dataset object or array of objects with histogram axes
%           converted to point axes
%
%
% Notes:
% Histogram datasets are converted to distribution as follows:
%       Histogram distribution => Point data distribution;
%                                 Signal numerically unchanged
%
%             non-distribution => Point data distribution;
%                                 Signal converted to signal per unit axis
%                                 length
%
% Histogram data is always converted to a distribution: it is assumed that
% point data represents the sampling of a function at a series of points,
% and histogram non-distribution data is not consistent with that.

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('IX_dataset')),'_docify')
%
%   doc_file = fullfile(doc_dir,'doc_hist2point_method.m')
%
%   object = 'IX_dataset'
%   method = 'hist2point_'
%   ndim = 'ndim'
% -----------------------------------------------------------------------------
% <#doc_beg:> IX_dataset
%   <#file:> <doc_file>
% <#doc_end:>
% -----------------------------------------------------------------------------


nd = obj(1).ndim();

% Check the validity of the axis indices
if nargin==1
    iax = 1:nd;
else
    if isempty(iax) || ~isnumeric(iax) || any(rem(iax,1)~=0) ||...
            any(iax<1) || any(iax>nd) || numel(unique(iax))~=numel(iax)
        if nd==1
            mess = 'Axis indices can only take the value 1';
        else
            mess = ['Axis indices must be unique and in the range 1 to ', num2str(nd)];
        end
        error('HERBERT:hist2point_:invalid_argument', mess)
    end
end

% Convert each object in turn
obj_out = obj;
for i = 1:numel(obj)
    obj_out(i) = hist2point_single_(obj(i), iax);
end


%--------------------------------------------------------------------------
function obj_out = hist2point_single_(obj, iax)
% Convert histogram axes in an IX_dataset to point axes

obj_out = obj;

ihist2pnt = iax(ishistogram_(obj, iax));
if numel(ihist2pnt)>0
    x = obj.xyz_;
    x_new = cell(1,numel(ihist2pnt));
    
    % Get bin centres and change object
    % (Note: we can have the case of a histogram axis with one bin boundary
    % and dimension extent zero - must account for this case)
    % (Note also that we divide by 2 rather than multiply by 0.5 so that
    % integer bins with integer centres are computed exactly)
    for i = 1:numel(ihist2pnt)
        x_new{i} = bin_centres (x{ihist2pnt(i)});
    end
    obj_out = set_xyz_(obj, x_new, ihist2pnt);
    
    % Convert to distribution signal and error values, if necessary
    % (If there is a dimension extent zero then signal is empty, and so no
    % conversion needed)
    [nd, sz] = dimensions(obj);
    xdist = obj.xyz_distribution_;
    ihist_not_dist = ihist2pnt(~xdist(ihist2pnt));
    if numel(ihist_not_dist)>0
        
        % Convert to distribution signal and error values
        % (Note: if there is a dimension extent zero then signal is empty,
        % and so no conversion needed)
        if prod(sz)>0
            signal = obj.signal_;
            error = obj.error_;
            for i = ihist_not_dist
                sz_dx = ones(1,max(nd,2)); sz_dx(i) = sz(i);
                dx = reshape(diff(x{i}), sz_dx);
                signal = bsxfun(@rdivide, signal, dx);  % implicit expansion
                error = bsxfun(@rdivide, error, dx);
            end
            obj_out.signal = signal;
            obj_out.error = error;
        end
        
        % Relabel axes as distributions (must be done even in the case
        % of empty data)
        xdist_new = true(1,numel(ihist_not_dist));
        obj_out = set_xyz_distribution_(obj_out, xdist_new, ihist_not_dist);
    end
    
end
