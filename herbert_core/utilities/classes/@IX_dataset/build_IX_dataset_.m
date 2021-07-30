function obj = build_IX_dataset_(obj, varargin)
% Construct IX_dataset object with the required dimensionality
%
% Construct with default captioning:
%   >> w = build_IX_dataset_ (obj, x1, x2,...xn)
%   >> w = build_IX_dataset_ (obj, x1, x2,...xn, signal)
%   >> w = build_IX_dataset_ (obj, x1, x2,...xn, signal, error)
%   >> w = build_IX_dataset_ (obj, x1, x2,...xn, signal, error, x1_distribution,
%                             x1_distribution, x2_distribution,..., xn_distribution)
%
% Construct with custom captioning:
%   >> w = build_IX_dataset_ (obj, x1, x2,...xn, signal, error, title,
%                             x1_axis, x2_axis,..., xn_axis, s_axis)
%   >> w = build_IX_dataset_ (obj, x1, x2,...xn, signal, error, title,
%                             x1_axis, x2_axis,..., xn_axis, s_axis,
%                             x1_distribution, x2_distribution,..., xn_distribution)
%
% Old format constructor (retained for backwards compatibility)
%   >> w = build_IX_dataset_ (obj, title,  signal, error, s_axis, x1, x1_axis, x1_distribution,
%                             x2, x2_axis, x2_distribution,..., xn, xn_axis, xn_distribution)
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

% Fill default object
obj.xyz_ = cell(1, nd);
obj.xyz_distribution_ = true(1, nd);
obj.xyz_axis_ = repmat(IX_axis, [1, nd]);

if  narg==0
    % Default object
    % --------------
    % Axis values
    sz = ones(1, max(nd,2));    % size of default signal and error arrays if point data
    for iax = 1:nd
        obj = obj.check_and_set_x_([], iax);
        sz(iax) = numel(obj.xyz_{iax});
    end
    
    % Signal and errors
    obj = obj.check_and_set_signal_(zeros(sz));
    obj = obj.check_and_set_error_(zeros(sz));
    
    % Distributions
    for iax = 1:nd
        obj = obj.check_and_set_x_distribution_([], iax);
    end
    
    % Title and captions
    obj = obj.check_and_set_title_([]);
    for iax = 1:nd
        obj = obj.check_and_set_x_axis_([], iax);
    end
    obj = obj.check_and_set_s_axis_([]);

    
elseif narg>=nd && narg<=nd+2
    % Construct with default captioning and distribution flags
    % --------------------------------------------------------
    % Axis values
    sz = ones(1, max(nd,2));    % size of default signal and error arrays if point data
    for iax = 1:nd
        obj = obj.check_and_set_x_(varargin{iax}, iax);
        sz(iax) = numel(obj.xyz_{iax});
    end
    
    % Signal and errors
    if narg>=nd+1
        obj = obj.check_and_set_signal_(varargin{nd+1});
    else
        obj = obj.check_and_set_signal_(zeros(sz));
    end
    
    if narg>=nd+2
        obj = obj.check_and_set_error_(varargin{nd+2});
    else
        obj = obj.check_and_set_error_(zeros(size(obj.signal_)));
    end
    
    % Distributions
    for iax = 1:nd
        obj = obj.check_and_set_x_distribution_([], iax);
    end
    
    % Title and captions
    obj = obj.check_and_set_title_([]);
    for iax = 1:nd
        obj = obj.check_and_set_x_axis_([], iax);
    end
    obj = obj.check_and_set_s_axis_([]);
    
    
elseif narg==(2*nd+2)
    % Construct with default captioning and custom distribution flags
    % ---------------------------------------------------------------
    % Axis values
    for iax = 1:nd
        obj = obj.check_and_set_x_(varargin{iax}, iax);
    end
    
    % Signal and errors
    obj = obj.check_and_set_signal_(varargin{nd+1});
    obj = obj.check_and_set_error_(varargin{nd+2});
    
    % Distributions
    for iax = 1:nd
        obj = obj.check_and_set_x_distribution_(varargin{iax+(nd+2)}, iax);
    end
    
    % Title and captions
    obj = obj.check_and_set_title_([]);
    for iax = 1:nd
        obj = obj.check_and_set_x_axis_([], iax);
    end
    obj = obj.check_and_set_s_axis_([]);

    
elseif narg==(2*nd+4) || (narg==(3*nd+4) && isnumeric(varargin{1}))
    % Construct with custom captioning and default/custom distribution flags
    % ----------------------------------------------------------------------
    % Axis values
    for iax = 1:nd
        obj = obj.check_and_set_x_(varargin{iax}, iax);
    end
    
    % Signal and errors
    obj = obj.check_and_set_signal_(varargin{nd+1});
    obj = obj.check_and_set_error_(varargin{nd+2});
    
    % Distributions
    if narg==(2*nd+4)
        for iax = 1:nd
            obj = obj.check_and_set_x_distribution_([], iax);
        end
    else
        for iax = 1:nd
            obj = obj.check_and_set_x_distribution_(varargin{iax+(2*nd+4)}, iax);
        end
    end
    
    % Title and captions
    obj = obj.check_and_set_title_(varargin{nd+3});
    for iax = 1:nd
        obj = obj.check_and_set_x_axis_(varargin{iax+(nd+3)}, iax);
    end
    obj = obj.check_and_set_s_axis_(varargin{2*nd+4});

    
elseif narg==(3*nd+4)
    % Construct with custom captioning and distribution flags
    % -------------------------------------------------------
    % Title
    obj = obj.check_and_set_title_(varargin{1});
    
    % Signal and errors
    obj = obj.check_and_set_signal_(varargin{2});
    obj = obj.check_and_set_error_(varargin{3});
    obj = obj.check_and_set_s_axis_(varargin{4});
    
    % Axis values
    for iax = 1:nd
        obj = obj.check_and_set_x_(varargin{3*iax+2}, iax);
        obj = obj.check_and_set_x_axis_(varargin{3*iax+3}, iax);
        obj = obj.check_and_set_x_distribution_(varargin{3*iax+4}, iax);
    end
    
else
    error('HERBERT:build_IX_dataset_:invalid_argument',...
        'Invalid number or type of arguments')
end

% Check consistency between fields
obj = check_properties_consistency_(obj);
