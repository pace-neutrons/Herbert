classdef IX_dataset_1d < IX_data_1d
    % Class adds operations with graphics to main operations with 1-d data
    %
    % See IX_data_1d for main properties and constructors, used to operate
    % with 1d data
    %
    % Common way to create IX_dataset_1d object:
    %
    %   >> w = IX_dataset_1d (x)
    %   >> w = IX_dataset_1d (x,signal)
    %   >> w = IX_dataset_1d (x,signal,error)
    %   >> w = IX_dataset_1d ([x;signal;error]) % 3xNs vector of data;
    %   >> w = IX_dataset_1d (x,signal,error,title,x_axis,s_axis)
    %   >> w = IX_dataset_1d (x,signal,error,title,x_axis,s_axis, x_distribution)
    %   >> w = IX_dataset_1d (title, signal, error, s_axis, x, x_axis, x_distribution)
    %
    %  Creates an IX_dataset_1d object with the following elements:
    %
    %   title           char/cellstr    Title of dataset for plotting purposes (character array or cellstr)
    %   signal          double          Signal (vector)
    %   error                               Standard error (vector)
    %   s_axis          IX_axis         Signal axis object containing caption and units codes
    %                   (or char/cellstr    Can also just give caption; multiline input in the form of a
    %                                      cell array or a character array)
    %   x                   double          Values of bin boundaries (if histogram data)
    %                                       Values of data point positions (if point data)
    %   x_axis          IX_axis         x-axis object containing caption and units codes
    %                   (or char/cellstr    Can also just give caption; multiline input in the form of a
    %                                      cell array or a character array)
    %   x_distribution  logical         Distribution data flag (true is a distribution; false otherwise)
   
    
    methods
        function obj= IX_dataset_1d(varargin)
            obj = obj@IX_data_1d (varargin{:});
        end
    end
    
    %======================================================================
    methods(Access=protected)
        % Support method for loadobj. This method needs to be accesible
        % both from loadobj, and from child classes loadobj_protected_
        % methods so that there is inheritable loadobj
        function obj = loadobj_protected_ (obj, S)
            obj = loadobj_protected_@IX_data_1d (obj, S);
        end
    end
        
    %======================================================================
    methods(Static)
        function obj = loadobj (S)
            % Function to support loading of outdated versions of the class
            % from mat files
            if isstruct(S)
                obj = IX_dataset_1d();
                obj = arrayfun(@(x)loadobj_protected_(obj, x), S);
            else
                obj = S;    % must be an instance of the object
            end
            
            % Check consistency of object - if it is older version then
            % might not be consistent
            obj = arrayfun(@isvalid, obj);

        end
    end
    
end
