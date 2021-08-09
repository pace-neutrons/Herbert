function obj_out = rebin_IX_dataset_(obj, iax, config, varargin)
% Rebin an IX_dataset object or array of IX_dataset objects along one or more axes
%
%   >> obj_out = rebin_IX_dataset_(obj, iax, config, p1, p2,...)
%   >> obj_out = rebin_IX_dataset_(obj, iax, config, obj_ref)
%
%   >> obj_out = rebin_IX_dataset_(..., 'average')
%   >> obj_out = rebin_IX_dataset_(..., 'interpolate')
%
% Input:
% ------
%   win         IX_dataset_nd, or array or IX_dataset_nd (n=1,2,3)
%
%   iax         Axis index or array of axes indices. Must be unique
%               integers in the range 1,2...ndim, wheren ndim is the
%               dimensionality of the object(s)
%               It is assumed that the input is valid.
%
%   config      Structure describing configuration of rebinning. Fields are
%       - integrate_data
%           Perform rebinning (false) or integration (true)
%
%       - point_average_method_default
%           Default averging method for axes with point data (ignored by
%           histogram axes)
%               'interpolate'   Trapezoidal integration
%               'average'       Point averaging
%
%       - bin_opts
%           Options that control the interpretation of the binning
%           descriptions above. It is a structure with fields:
%
%       empty_is_one_bin        true:  [] or '' ==> [-Inf,Inf];
%                               false:          ==> [-Inf,0,Inf]
%
%     	range_is_one_bin        true:   [x1,x2] ==> one bin
%                               false:          ==> [x1,0,x2]
%
%      	array_is_descriptor     true:  interpret array of three or more
%                                      elements as descriptor
%                               false: interpret as actual bin boundaries
%                                      or bin centres
%
%      	values_are_boundaries   true:  interpret array as defining bin
%                                      boundaries
%                               false: interpret array as defining bin
%                                      centres%
%   p1, p2,...  Arrays of rebin/integration intervals, one per axis.
%               Depending on bin_opts.array_is_descriptor,
%                      there are a number of different formats and defaults that are valid.
%                       If win is one dimensional, then if all the arguments can be scalar they are treated as the
%                      elements of range_1
%         *OR*
%   wref                Reference dataset from which to take bins. Must be a scalar, and the same class as win
%                      Only those axes indicated by input argument iax are taken from the reference object.
%
%   point_average_method   Averaging method if point data (if not given, then uses default determined by point_integration_default above)
%                        - character string 'integration' or 'average'
%                        - cell array with number of entries equalling number of rebin/integration axes (i.e. numel(iax))
%                          each entry the character string 'integration' or 'average'
%                       If an axis is a histogram data axis, then its corresponding entry is ignored
%
% Output:
% -------
%   wout                IX_dataset_nd object or array of objects following the rebinning/integration
%                   *OR*
%                       Structure array, where the fields of each element are
%                           wout(i).x             Cell array of arrays containing the x axis boundaries or points
%                           wout(i).signal        Signal array
%                           wout(i).err           Array of standard deviations
%                           wout(i).distribution  Array of elements, one per axis that is true if a distribution, false if not


% NOTES
% To be able to rebin or integrate we need to specify at least two bin
% boundaries. This can be done either 
% - directly, by specification of two or more finite bin boundaries
% - indirectly via taking the lower &/or upper range of the input data to
%   resolve -Inf &/or -Inf in a binning descriptor
% In the direct case, the axis can have a zero length signal, and the output
% is trivial: zeros for the data
% In the indirect case, there must be at least one data point (which can
% be used to reolve both -Inf and +Inf to give a bin of zero width)


% Get object dimensionality
% -------------------------
if numel(obj)>0
    ndims = win.ndim();
else
    error('HERBERT:rebin_IX_dataset_:invalid_argument',...
        'Object array to rebin must contain at least one element')
end


% Check axes indices
% ------------------
niax=numel(iax); % number of axes to be rebinned

if isempty(iax) || ~isnumeric(iax) || any(rem(iax,1)~=0) ||...
        any(iax<1) || any(iax>nd) || numel(unique(iax))~=numel(iax)
    if ndims==1
        mess = 'Axis indices along which to rebin can only take the value 1';
    else
        mess = ['Axis indices along which to rebin must be unique and ',...
            'in the range 1 to ', num2str(nd)];
    end
    error('HERBERT:rebin_IX_dataset_:invalid_argument', mess)
    
elseif any(iax>ndims)
    str = str_compress(num2str(iax(iax>ndims)),',');
    error('HERBERT:rebin_IX_dataset_:invalid_argument',...
        'Attempting to rebin  %dD object along %s direction(s)', ndims, str)
end


% Check point averaging option
% ----------------------------
if ~(numel(varargin)==1 && isa(varargin{1},class(obj))) && ...
        (numel(varargin)>=1 && ~isnumeric(varargin{end}))
    % Last argument is point averaging option
    point_average_method = rebin_point_averaging_parse_(varargin{end}, niax);
    args = varargin(1:end-1);
    
else
    % Use default point averaging method
    point_average_method = rebin_point_averaging_parse_(...
        config.point_average_method_default, niax);
    args = varargin;
end


% Check rebin parameters
% ----------------------
% If the rebin boundaries are the same for all input objects (i.e. no
% knowledge of their axes is required to resolve infinities in the lower of
% upper rebin limits, or retain original bin widths for some regions) then
% construct the new bin boundaries here to avoid repeated re-calculation in
% the loop over the elements of the object array.

if numel(args)==1 && isa(args{1},class(obj))
    % Rebin according to bins in a reference object; for axes with point
    % data, construct bin boundaries
    obj_ref = args{1};
    if numel(obj_ref)==1
        x = obj_ref.xyz_;
        ishist = ishistogram (obj_ref);
        
        % Check that the reference dataset has at least one bin or two
        % points along each rebinning axis
        if any(cellfun(@numel, x(iax)) <= 1)
            error('HERBERT:rebin_IX_dataset_:invalid_argument',...
                ['Reference dataset must have at least one bin (histogram data)',...
                'or two points (point data)'])
        end
        
        % Get bin boundaries from any point axes
        xdescr = x;
        xdescr(~ishist(iax)) = cellfun (@bin_boundaries, x(~ishist(iax)));
        is_descriptor = false(1,niax);
        resolved = true(1,niax);
        
    else
        error('HERBERT:rebin_IX_dataset_:invalid_argument',...
            ['Reference dataset for rebinning must be a single instance, ',...
            'not an array']);
    end
    
else
    % Use rebin description(s) to define new bin boundaries
    if numel(args)==niax
        opts = config.bin_opts;
        xdescr = cell(1, niax);
        is_descriptor = false(1,niax);
        resolved = false(1,niax);
        for i = 1:iax
            [xdescr{i}, is_descriptor(i), resolved(i)] = ...
                rebin_binning_description_parse_(args{i}, opts);
        end
    else
        error('HERBERT:rebin_IX_dataset_:invalid_argument',...
            ['The number of bin boundary descriptions does not match ',...
            'the number of rebin axes']);
    end
end


% Perform rebin
% -------------
integrate_data = config.integrate_data;
values_are_boundaries = config.values_are_boundaries;

if numel(obj)==1
    obj_out = rebin_IX_dataset_single_ (obj, iax, xdescr, is_descriptor,...
        resolved, values_are_boundaries, integrate_data, point_average_method);
else
    % --> Code that depends on data input class
    ndim=dimensions(obj(1));
    obj_out=repmat(IX_dataset_nd(ndim),size(obj));
    % <--
    for i=1:numel(obj)
        obj_out(i) = rebin_IX_dataset_single_ (obj(i), iax, xdescr, is_descriptor,...
            resolved, values_are_boundaries, integrate_data, point_average_method);
    end
end
