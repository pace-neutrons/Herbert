function obj_out = rebin_IX_dataset_ (obj, iax, config, varargin)
% Rebin an IX_dataset object or object array along one or more axes
%
%   >> obj_out = rebin_IX_dataset_(obj, iax, config, p1, p2,...)
%   >> obj_out = rebin_IX_dataset_(obj, iax, config, obj_ref)
%
%   >> obj_out = rebin_IX_dataset_(..., 'average')
%   >> obj_out = rebin_IX_dataset_(..., 'interpolate')
%
%
% Input:
% ------
%   obj         IX_dataset, or array of IX_dataset objects
%
%   iax         Axis index or array of axes indices. Must be unique
%               integers in the range 1,2...ndim, wheren ndim is the
%               dimensionality of the object(s)
%               It is assumed that the input is valid.
%
%   config      Structure describing configuration of rebinning. Fields are
%               as follows:
%
%       - integrate_data
%           Perform rebinning (false) or integration (true)
%           Rebinning means that the signal is normalised by the bin size
%           whereas integration means otherwise.
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
%      	array_is_descriptor     For the case of a binning description with
%                              three or more elements:
%                               true:  interpret array of three or more
%                                      elements as descriptor
%                               false: interpret as actual bin boundaries
%                                      or bin centres
%
%      	values_are_boundaries   For the case of a binning description with
%                              three or more elements:
%                               true:  interpret array as defining bin
%                                      boundaries
%                               false: interpret array as defining bin
%                                      centres
%
%   p1, p2,...  Arrays of binning descriptions, one per axis.
%               The binning description defines the intervals over which
%               the data is rebinned or integrated.
%               
%               Depending on the values of the fields in config.bin_opts
%               there are a number of different formats and defaults that
%               are valid. See the function rebin_parse_binning_description
%               for details.
%
%               If iax is scalar i.e. there is only one integration axis, 
%               then if p1, p2,... are all scalar they are interpreted as
%               forming the single binning description [p1, p2, p3,...]
%
%   obj_ref     Reference IX_dataset from which to take bins. Must be a 
%               scalar object, and have the same dimensionality as the
%               object to be rebinned.
%               Only those axes indicated by input argument iax are taken
%               from the reference object.
%
%   point_average_method   
%               Averaging method for point data axes:
%               - character string 'interpolate' or 'average' (or 
%                 abbreviation)
%               - cell array of character strings, one per axis being
%                 rebinned or integrated (i.e. the number is numel(iax))
%               If an axis is a histogram data axis, then its corresponding
%               entry is ignored.
%
%
% Output:
% -------
%   out_out     IX_dataset object or array of objects with the results of
%               the rebinning/integration


% Get object dimensionality
% -------------------------
if numel(obj)>0
    nd = obj.ndim();
else
    error('HERBERT:rebin_IX_dataset_:invalid_argument',...
        'Object array to rebin must contain at least one element')
end


% Check axes indices
% ------------------
niax=numel(iax); % number of axes to be rebinned

if isempty(iax) || ~isnumeric(iax) || any(rem(iax,1)~=0) ||...
        any(iax<1) || any(iax>nd) || numel(unique(iax))~=numel(iax)
    if nd==1
        mess = 'Axis indices along which to rebin can only take the value 1';
    else
        mess = ['Axis indices along which to rebin must be unique and ',...
            'in the range 1 to ', num2str(nd)];
    end
    error('HERBERT:rebin_IX_dataset_:invalid_argument', mess)
    
elseif any(iax>nd)
    str = str_compress(num2str(iax(iax>nd)),',');
    error('HERBERT:rebin_IX_dataset_:invalid_argument',...
        'Attempting to rebin  %dD object along %s direction(s)', nd, str)
end


% Check point averaging option
% ----------------------------
if ~(numel(varargin)==1 && isa(varargin{1},class(obj))) && ...
        (numel(varargin)>=1 && ~isnumeric(varargin{end}))
    % Last argument is point averaging option
    point_average_method = rebin_parse_point_averaging (varargin{end}, niax);
    args = varargin(1:end-1);
    
else
    % Use default point averaging method
    point_average_method = rebin_parse_point_averaging (...
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
                'or two points (point data) along each axis'])
        end
        
        % Get bin boundaries from any point axes
        xdescr = x;
        xdescr(~ishist(iax)) = cellfun (@bin_boundaries, x(~ishist(iax)));
        is_descriptor = false(1, niax);
        is_boundaries = true(1, niax);
        resolved = true(1, niax);
        
    else
        error('HERBERT:rebin_IX_dataset_:invalid_argument',...
            ['Reference dataset for rebinning must be a single instance, ',...
            'not an array of datasets']);
    end
    
else
    % Use rebin description(s) to define new bin boundaries
    if numel(args)==niax
        xdescr = cell(1, niax);
        is_descriptor = false(1, niax);
        is_boundaries = false(1, niax);
        resolved = false(1, niax);
        for i = 1:niax
            [xdescr{i}, is_descriptor(i), is_boundaries(i), resolved(i)] = ...
                rebin_parse_binning_description (args{i}, config.bin_opts);
        end
        
    elseif niax==1 && all(cellfun(@isscalar, args)) &&...
            all(cellfun(@isnumeric, args))
        % Single axis, all args are numeric scalars: collect as single array
        xdescr = cell(1, 1);
        [xdescr{1}, is_descriptor, is_boundaries, resolved] = ...
            rebin_parse_binning_description (cell2mat(args), config.bin_opts);
        
    else
        error('HERBERT:rebin_IX_dataset_:invalid_argument',...
            ['The number of bin boundary descriptions does not match ',...
            'the number of rebin axes']);
    end
    
    % For resolved axes (i.e. no -Inf or +Inf, and no binning interval in
    % a descriptor requires reference values to be retained) compute the
    % output bin boundaries
    for i = 1:niax
        if resolved(i)
            xdescr{i} = rebin_boundaries (xdescr{i}, is_descriptor(i),...
                is_boundaries(i));
        end
    end
end


% Perform rebin
% -------------
integrate_data = config.integrate_data;

if numel(obj)==1
    obj_out = rebin_IX_dataset_single_ (obj, iax, xdescr, is_descriptor,...
        is_boundaries, resolved, integrate_data, point_average_method);
else
    obj_out = repmat(eval(class(obj)), size(obj));  % 'eval' not nice, but blind
    for i=1:numel(obj)
        obj_out(i) = rebin_IX_dataset_single_ (obj(i), iax, xdescr, is_descriptor,...
            is_boundaries, resolved, integrate_data, point_average_method);
    end
end
