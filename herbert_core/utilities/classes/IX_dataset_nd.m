function w = IX_dataset_nd (varargin)
% Constructor for generic n-dimensional dataset. Not a class method, but gateway to constructors
%
% Create default object of the requested dimensionality:
%   >> w = IX_dataset_nd (ndim)
%
% Create populated object:
%   >> w = IX_dataset_nd (title, signal, err, s_axis, ax)
%   >> w = IX_dataset_nd (title, signal, err, s_axis, x, x_axis, x_distribution)
%
%
% 	title				char/cellstr	Title of dataset for plotting purposes (character array or cellstr)
% 	signal              double  		Signal
% 	err                                 Standard error
% 	s_axis				IX_axis			Signal axis object containing caption and units codes
%                   (or char/cellstr    Can also just give caption; multiline input in the form of a
%                                      cell array or a character array)
%   ax                  structure       Array of axis information structures; numel(ax)=dimensionality
%                                       Each element of ax has fields:
%           values          double     	Values of bin boundaries (if histogram data)
% 						                Values of data point positions (if point data)
%           axis            IX_axis     IXaxis object containing caption and units codes
%                   (or char/cellstr    Can also just give caption; multiline input in the form of a
%                                      cell array or a character array)
%           distribution    logical     Distribution data flag (true is a distribution; false otherwise)

% -------------------------------------------------------------------------
if nargin==1 && isnumeric(varargin{1}) && isscalar(varargin{1})
    % Format is: w = IX_dataset_nd (ndim)
    ndim=varargin{1};
    if ndim==1
        w=IX_dataset_1d;
    elseif ndim==2
        w=IX_dataset_2d;
    elseif ndim==3
        w=IX_dataset_3d;
    elseif ndim==4
        w=IX_dataset_4d;
    else
        error('HERBERT:IX_dataset_nd:invalid_argument', ['IX_dataset_nd with ',...
            'dimensionality ndim = ',num2str(ndim),' is not supported'])
    end
    
    % ---------------------------------------------------------------------
elseif numel(varargin)==5
    % Format is: w = IX_dataset_nd (title, signal, err, s_axis, ax)
    title=varargin{1};
    signal=varargin{2};
    err=varargin{3};
    s_axis=varargin{4};
    ax=varargin{5};
    fields = {'values';'axis';'distribution'};
    
    ndim=numel(ax);
    if isstruct(ax) && all(isfield(ax,fields))
        if ndim==1
            w=IX_dataset_1d (title, signal, err, s_axis, ax);
        elseif ndim==2
            w=IX_dataset_2d (title, signal, err, s_axis, ax);
        elseif ndim==3
            w=IX_dataset_3d (title, signal, err, s_axis, ax);
        elseif ndim==4
            w=IX_dataset_4d (title, signal, err, s_axis, ax);
        else
            error('HERBERT:IX_dataset_nd:invalid_argument', ['IX_dataset_nd with ',...
                'dimensionality ndim = ',num2str(ndim),' is not supported'])
        end
    else
        error('HERBERT:IX_dataset_nd:invalid_argument', ...
            'Axis description does not have correct fields')
    end
    
    % ---------------------------------------------------------------------
elseif numel(varargin)==7
    % Format is: w = IX_dataset_nd (title, signal, err, s_axis, x, x_axis, x_distribution)
    title=varargin{1};
    signal=varargin{2};
    err=varargin{3};
    s_axis=varargin{4};
    x=varargin{5};
    x_axis=varargin{6};
    x_distribution=varargin{7};
    
    ndim=numel(x_distribution);
    if ndim==1
        w=IX_dataset_1d (title, signal, err, s_axis, x, x_axis, x_distribution);
    elseif ndim==2
        w=IX_dataset_2d (title, signal, err, s_axis, x, x_axis, x_distribution);
    elseif ndim==3
        w=IX_dataset_3d (title, signal, err, s_axis, x, x_axis, x_distribution);
    elseif ndim==4
        w=IX_dataset_4d (title, signal, err, s_axis, x, x_axis, x_distribution);
    else
        error('HERBERT:IX_dataset_nd:invalid_argument', ['IX_dataset_nd with ',...
            'dimensionality ndim = ',num2str(ndim),' is not supported'])
    end
    
    
    % ---------------------------------------------------------------------
else
    error('HERBERT:IX_dataset_nd:invalid_argument', ...
        'Check number and type of input arguments')
end
