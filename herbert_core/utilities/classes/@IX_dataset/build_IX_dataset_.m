function obj = build_IX_dataset_(obj, varargin)
% Construct IX_dataset object with the required dimensionality
%
% There are two general formats for arguments:
% - providing axis information one argument per axis for each time type
% - providing axis onformation with one argument for all axes for an itme type
%
%
% Individual axes:
% ----------------
% Construct with default captioning:
%   >> obj = build_IX_dataset_ (obj, x1, x2,...xn)
%   >> obj = build_IX_dataset_ (obj, x1, x2,...xn, signal)
%   >> obj = build_IX_dataset_ (obj, x1, x2,...xn, signal, error)
%   >> obj = build_IX_dataset_ (obj, x1, x2,...xn, signal, error,...
%                       x1_distribution, x2_distribution,..., xn_distribution)
%
% Construct with custom captioning:
%   >> obj = build_IX_dataset_ (obj, x1, x2,...xn, signal, error,...
%                       title, x1_axis, x2_axis,..., xn_axis, s_axis)
%
%   >> obj = build_IX_dataset_ (obj, x1, x2,...xn, signal, error,,...
%                       title, x1_axis, x2_axis,..., xn_axis, s_axis,
%                       x1_distribution, x2_distribution,..., xn_distribution)
%
% Older format constructor:
%   >> obj = build_IX_dataset_ (obj, title,  signal, error, s_axis,...
%                       x1, x1_axis, x1_distribution,...
%                       x2, x2_axis, x2_distribution,...
%                       xn, xn_axis, xn_distribution)
%
%
% Array arguments:
% ----------------
% Construct with default captioning:
%   >> obj = build_IX_dataset_ (obj, x)
%   >> obj = build_IX_dataset_ (obj, x, signal)
%   >> obj = build_IX_dataset_ (obj, x, signal, error)
%   >> obj = build_IX_dataset_ (obj, x, signal, error, x_distribution)
%
% Construct with custom captioning:
%   >> obj = build_IX_dataset_ (obj, x, signal, error, ...
%                       title, x_axis, s_axis)
%
%   >> obj = build_IX_dataset_ (obj, x, signal, error, ...
%                       title, x_axis, s_axis, x_distribution)
%
% Older format constructor:
%   >> obj = build_IX_dataset_ (obj, title,  signal, error, s_axis,...
%                       x, x_axis, x_distribution)
%
%   >> obj = build_IX_dataset_ (obj, title,  signal, error, s_axis, ax)


narg = numel(varargin);

% Get number of dimensions - comes from the child object
nd = obj.ndim();

% Determine if array argument input or not.
% The way to distinguish is:
% - for nd>=2 the first argument is a cell array of numeric vectors, or, 
%   if the first argument is the title, the fifth argument is.
% - the fifth argument is a structure (the axis structure)

if narg==0 || ...
        (narg>=1 && ~isempty(varargin{1}) && iscell(varargin{1}) && ...
        isnumeric(varargin{1}{1})) || ...
        (narg>=5 && ~isempty(varargin{5}) && iscell(varargin{5}) && ...
        isnumeric(varargin{5}{1})) || ...
        (narg==5 && isstruct(varargin{5}))
    % Default or axis items given in arrays
    obj = build_IX_dataset_internal_(obj, varargin{:});
    
else
    % Axis-by-axis construction
    if narg>=nd && narg<=nd+2
        % Default captioning and distribution flags
        x = varargin(1:nd); % as cell array
        obj = build_IX_dataset_internal_(obj, x, varargin{nd+1:end});
        
    elseif narg==(2*nd+2)
        % Default captioning and custom distribution flags
        x = varargin(1:nd); % as cell array
        signal = varargin{nd+1};
        error = varargin{nd+2};
        x_distribution = varargin(nd+3:2*nd+2); % as cell array
        obj = build_IX_dataset_internal_(obj, x, signal, error, x_distribution);
        
    elseif narg==(2*nd+4) || (narg==(3*nd+4) && isnumeric(varargin{1}))
        % Custom captioning and default/custom distribution flags
        x = varargin(1:nd); % as cell array
        signal = varargin{nd+1};
        error = varargin{nd+2};
        title = varargin{nd+3};
        x_axis = varargin(nd+4:2*nd+3); % as cell array
        s_axis = varargin{2*nd+4};
        if narg==(2*nd+4)
            obj = build_IX_dataset_internal_(obj, x, signal, error, ...
                title, x_axis, s_axis);
        else
            x_distribution = varargin(2*nd+5:3*nd+4);   % as cell array
            obj = build_IX_dataset_internal_(obj, x, signal, error, ...
                title, x_axis, s_axis, x_distribution);
        end
        
    elseif narg==(3*nd+4)
        % Construct with custom captioning and distribution flags - old style
        title = varargin{1};
        signal = varargin{2};
        error = varargin{3};
        s_axis = varargin{4};
        x = varargin(5:3:end);  % as cell array
        x_axis = varargin(6:3:end); % as cell array
        x_distribution = varargin(7:3:end); % as cell array
        obj = build_IX_dataset_internal_(obj, title, signal, error, ...
            s_axis, x, x_axis, x_distribution);
        
    else
        % Unrecognised input - pass to get standard error message
        obj = build_IX_dataset_internal_(obj, varargin{:});
    end
end


%--------------------------------------------------------------------------
function obj = build_IX_dataset_internal_(obj, varargin)
% Construct IX_dataset object with the required dimensionality
%
% Construct with default captioning:
%   >> obj = build_IX_dataset_ (obj, x)
%   >> obj = build_IX_dataset_ (obj, x, signal)
%   >> obj = build_IX_dataset_ (obj, x, signal, error)
%   >> obj = build_IX_dataset_ (obj, x, signal, error, x_distribution)
%
% Construct with custom captioning:
%   >> obj = build_IX_dataset_ (obj, x, signal, error, ...
%                       title, x_axis, s_axis)
%
%   >> obj = build_IX_dataset_ (obj, x, signal, error, ...
%                       title, x_axis, s_axis, x_distribution)
%
% Older format constructor:
%   >> obj = build_IX_dataset_ (obj, title,  signal, error, s_axis,...
%                       x, x_axis, x_distribution)
%
%   >> obj = build_IX_dataset_ (obj, title,  signal, error, s_axis, ax)
%
%
% Input:
% ------
%   x       Numeric vector (nd==1), or cell array of numeric vectors giving
%           bin boundaries or point  positions (one vector per axis).
%
%   signal  Array of signal values.
%
%   error   Array of standard deviations.
%
%   x_distribution  Logical vector, or cell array of logical scalars,
%           stating if the signal is a distribution (i.e. contains
%           signal per unit length) or not. One logical scalar per axis.
%
%   title   Cell array of character vectors, character vector or 2D
%           character array, or string array, containing the object title.
% 
%   x_axis  IX_axis object array, or cell array of caption information, one
%           element per axis. Caption information can be a cell array of
%           character vectors, a character vector or 2D character array, or
%           a string array.
%
%   s_axis  IX_axis object, cell array of character vectors, character 
%           vector or 2D character array, or string array, containing the
%           signal axis caption information.
%
%   ax      Structure array with the following fields, one element of the 
%           structure array per axis:
%             values        Values of bin boundaries (if histogram data)
%                           Values of data point positions (if point data)
%             axis          IX_axis object containing caption and units codes
%             distribution  Logical scalar: true if a distribution; false
%                           otherwise)
%
%
% Notes about sizes of arrays
% ---------------------------
% Dimensions method must return object dimensionality, nd, and extent along
% each dimension in a row vector, sz, according to the convention that
% size(sz) = [1,nd]. This is not necessarily the same at the size of the
% signal and error arrays as returned by the Matlab intrinsic function size.
%
% Object  nd  size                             Matlab signal size
%   0D  nd=0  sz=zeros(1,0)                    [1,1]
%   1D  nd=1  sz=n1                            [n1,1]
%   2D  nd=2  sz=[n1,n2]                       [n1,n2]
%   3D  nd=3  sz=[n1,n2,n3]     even if n3=1   [n1,n2,n3] less trailing singletons
%   4D  nd=4  sz=[n1,n2,n3,n4]  even if n4=1,  [n1,n2,n3,n4] "    "        "
%                               or n3=n4=1


narg = numel(varargin);

% Get number of dimensions - comes from the child object
nd = obj.ndim();

% Determine if already initialised
% (Will be used to determine if constructing unprovided properties with
% defaults or accepting their current values)
initialised = obj.valid_;

if ~initialised
    % Pre-allocate array properties with the correct size and type.
    % The ontents may not be valid defaults however. These will be filled
    % as the elements of these properties are populated.
    obj.xyz_ = cell(1, nd);
    obj.xyz_distribution_ = true(1, nd);
    obj.xyz_axis_ = repmat(IX_axis, [1, nd]);
end

if narg==0
    if ~initialised
        % Default object
        % --------------
        % Axis values
        obj = obj.check_and_set_x_([], 1:nd);
        
        % Signal and errors
        sz = cellfun(@numel, obj.xyz_);
        sz = [sz, ones(1,2-numel(sz))];
        obj = obj.check_and_set_signal_(zeros(sz)); % default for point data
        obj = obj.check_and_set_error_(zeros(sz));
        
        % Distributions
        obj = obj.check_and_set_x_distribution_([], 1:nd);
        
        % Title and captions
        obj = obj.check_and_set_title_([]);
        obj = obj.check_and_set_x_axis_([], 1:nd);
        obj = obj.check_and_set_s_axis_([]);
        
    else
        % Nothing to do - leave object unchanged
        % --------------------------------------
        return
    end

    
elseif narg>=1 && narg<=3
    % Construct with default captioning and distribution flags
    % --------------------------------------------------------
    %   >> obj = build_IX_dataset_ (obj, x)
    %   >> obj = build_IX_dataset_ (obj, x, signal)
    %   >> obj = build_IX_dataset_ (obj, x, signal, error)
    
    % Axis values
    obj = obj.check_and_set_x_(varargin{1}, 1:nd);
    
    % Signal and errors
    if narg>=2
        obj = obj.check_and_set_signal_(varargin{2});
    elseif ~initialised
        sz = cellfun(@numel, obj.xyz_);
        sz = [sz, ones(1,2-numel(sz))];
        obj = obj.check_and_set_signal_(zeros(sz));
    end
    
    if narg>=3
        obj = obj.check_and_set_error_(varargin{3});
    elseif ~initialised
        obj = obj.check_and_set_error_(zeros(size(obj.signal_)));
    end
    
    if ~initialised
        % Distributions
        obj = obj.check_and_set_x_distribution_([], 1:nd);
        
        % Title and captions
        obj = obj.check_and_set_title_([]);
        obj = obj.check_and_set_x_axis_([], 1:nd);
        obj = obj.check_and_set_s_axis_([]);
    end
    
    
elseif narg==4
    % Construct with default captioning and custom distribution flags
    % ---------------------------------------------------------------
    %   >> obj = build_IX_dataset_ (obj, x, signal, error, x_distribution)

    % Axis values
    obj = obj.check_and_set_x_(varargin{1}, 1:nd);
    
    % Signal and errors
    obj = obj.check_and_set_signal_(varargin{2});
    obj = obj.check_and_set_error_(varargin{3});
    
    % Distributions
    obj = obj.check_and_set_x_distribution_(varargin{4}, 1:nd);
    
    if ~initialised
        % Title and captions
        obj = obj.check_and_set_title_([]);
        obj = obj.check_and_set_x_axis_([], 1:nd);
        obj = obj.check_and_set_s_axis_([]);
    end
    
elseif narg==5
    % Construct with custom captioning and distribution flags from structure
    % ----------------------------------------------------------------------
    %   >> obj = build_IX_dataset_ (obj, title,  signal, error, s_axis, ax)
    
    % Title
    obj = obj.check_and_set_title_(varargin{1});
    
    % Signal and errors
    obj = obj.check_and_set_signal_(varargin{2});
    obj = obj.check_and_set_error_(varargin{3});
    obj = obj.check_and_set_s_axis_(varargin{4});
    
    % Axis values
    ax = varargin{5};
    if isstruct(ax) && numel(ax)==nd && ...
            all(isfield(ax,{'values','axis','distribution'}))
        for i = 1:nd
            obj = obj.check_and_set_x_(ax(i).values, i);
            obj = obj.check_and_set_x_axis_(ax(i).axis, i);
            obj = obj.check_and_set_x_distribution_(ax(i).distribution, i);
        end
    else
        error('HERBERT:build_IX_dataset_internal_:invalid_argument',...
            'Axis structure has incorrect fields or wrong number of elements')
    end
    
    
elseif narg==6 || (narg==7 && iscell(varargin{1}) && ~iscellstr(varargin{1}))
    % Construct with custom captioning and default/custom distribution flags
    % ----------------------------------------------------------------------
    %   >> obj = build_IX_dataset_ (obj, x, signal, error, ...
    %                       title, x_axis, s_axis)
    %
    %   >> obj = build_IX_dataset_ (obj, x, signal, error, ...
    %                       title, x_axis, s_axis, x_distribution)

    % Axis values
    obj = obj.check_and_set_x_(varargin{1}, 1:nd);

    % Signal and errors
    obj = obj.check_and_set_signal_(varargin{2});
    obj = obj.check_and_set_error_(varargin{3});
    
    % Distributions
    if narg==7
        obj = obj.check_and_set_x_distribution_(varargin{7}, 1:nd);
    elseif ~initialised
        obj = obj.check_and_set_x_distribution_([], 1:nd);
    end
    
    % Title and captions
    obj = obj.check_and_set_title_(varargin{4});
    obj = obj.check_and_set_x_axis_(varargin{5}, 1:nd);
    obj = obj.check_and_set_s_axis_(varargin{6});

    
elseif narg==7
    % Construct with custom captioning and distribution flags
    % -------------------------------------------------------
    %   >> obj = build_IX_dataset_ (obj, title,  signal, error, s_axis,...
    %                       x, x_axis, x_distribution)

    % Title
    obj = obj.check_and_set_title_(varargin{1});
    
    % Signal and errors
    obj = obj.check_and_set_signal_(varargin{2});
    obj = obj.check_and_set_error_(varargin{3});
    obj = obj.check_and_set_s_axis_(varargin{4});
    
    % Axis values
    obj = obj.check_and_set_x_(varargin{5}, 1:nd);
    obj = obj.check_and_set_x_axis_(varargin{6}, 1:nd);
    obj = obj.check_and_set_x_distribution_(varargin{7}, 1:nd);
    
else
    error('HERBERT:build_IX_dataset_internal_:invalid_argument',...
        'Invalid number or type of arguments')
end

% Check consistency between fields
obj = check_properties_consistency_(obj);

% Set to valid if not yet initialised
if ~initialised
    obj.valid_ = true;
end
