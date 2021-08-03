function obj_out = rebin_object_array_(obj, iax, config, varargin)
% Rebin an IX_dataset object or array of IX_dataset objects along one or more axes
%
%   >> obj_out = rebin_object_array_(obj, iax, config, p1, p2,...)
%   >> obj_out = rebin_object_array_(obj, iax, config, obj_ref)
%
%   >> obj_out = rebin_object_array_(..., 'average')
%   >> obj_out = rebin_object_array_(..., 'interpolate')
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
%       - descriptor_opts      
%       	Structure whose fields give the options that describe the
%           interpretation of rebin/integration intervals.
%
%           The fields are:
%           - empty_is_one_bin
%               If a descriptor is empty, then
%                   
%           true: [] or '' ==> [-Inf,Inf];
%                                              false: ==> [-Inf,0,Inf]
%           - range_is_one_bin        true: [x1,x2]  ==> one bin
%                                              false ==> [x1,0,x2]
%           - array_is_descriptor     true:  interpret array of three or more elements as descripor
%                                                       false: interpet as actual bin boundaries
%           - values_are_boundaries          true:  intepret x values as bin boundaries
%                                                       false: interpret as bin centres
%
%   p1, p2,...  Arrays of rebin/integration intervals, one per axis.
%               Depending on descriptor_opts.array_is_descriptor,
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


nax=numel(iax); % number of axes to be rebinned

% Check point integration option
% ------------------------------
if ~(numel(varargin)==1 && isa(varargin{1},class(obj))) && ...
        (numel(varargin)>=1 && ~isnumeric(varargin{end}))  
    % last argument is point integration option
    [point_integration, ok, mess] = rebin_point_integration_check_(nax, varargin{end});
    if ~ok, obj_out=[]; return, end
    args=varargin(1:end-1);
else
    point_integration=repmat(pnt_ave_method_default,[1,nax]);
    args=varargin;
end


% Check rebin parameters
% ----------------------
% If the rebin boundaries are the same for all input databases 
% (i.e. no knowledge of their axes is required to
% resolve infinities in the lower of upper rebin limits, or 
% retain original bin widths for some regions) then
% construct the new bin boundaries here to avoid repeated
% calculation in a loop over the size of win.

if numel(args)==1 && isa(args{1},class(obj))
    % Rebin according to bins in a reference object; for axes with point data,
    % construct bin boundaries by taking the half-way points between the points
    wref=args{1};
    if numel(wref)~=1
        error('IX_dataset:invalid_argument',...
            'Reference dataset for rebinning must be a single instance, not an array');
    end
    % --> Code that depends on data input class
    x=wref.xyz_;
    ishist=ishistogram(wref);
    % <--
    for i=1:nax
        if numel(x{iax(i)})<=1  
            % single point dataset, or histogram dataset with empty signal array
            error('IX_dataset:invalid_argument',...
                ['Reference dataset must have at least one bin (histogram data)',...
                'or two points (point data)'])
        end
    end
    xbounds=cell(1,nax);
    true_values=true(1,nax);
    for i=1:nax
        if ishist(iax(i))
            xbounds{i}=x{iax(i)};
        else
            [xbounds{i},ok,mess]=bin_boundaries_simple(x{iax(i)});
            if ~ok
                error('IX_dataset:invalid_argument',...
                    ['Unable to construct bin boundaries for point data axis',...
                    'number %d : %s'],num2str(iax(i)),mess);
            end
        end
    end
    is_descriptor=false(1,nax);
    
else
    % Use rebin description to define new bin boundaries
    [ok,xbounds,any_lim_inf,is_descriptor,any_dx_zero,mess] = ...
        rebin_boundaries_description_parse_(nax,descriptor_opt,args{:});
    if ~ok, obj_out=[]; return, end
    true_values= ~(any_lim_inf|any_dx_zero);   % true bin boundaries
    for i=find(true_values&is_descriptor)
        xbounds{i}=bin_boundaries_from_descriptor_(xbounds{i});
    end
    
end


% Perform rebin
% -------------
if numel(obj)==1
    [obj_out,ok,mess] = rebin_IX_dataset_single_(obj,iax,xbounds,true_values,...
        is_descriptor,integrate_data,point_integration);
    if ~ok, obj_out=[]; return, end
else
    % --> Code that depends on data input class    
    ndim=dimensions(obj(1));
    obj_out=repmat(IX_dataset_nd(ndim),size(obj));
    % <--
    for i=1:numel(obj)
        [obj_out(i),ok,mess] = rebin_IX_dataset_single_(obj(i),iax,xbounds,true_values,...
            is_descriptor,integrate_data,point_integration);
        if ~ok, obj_out=[]; return, end
    end
end
