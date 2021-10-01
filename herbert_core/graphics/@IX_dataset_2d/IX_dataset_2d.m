classdef IX_dataset_2d < IX_data_2d
    % Class adds operations with graphics to main operations with 2-d data
    %
    % See IX_data_2d for main properties and constructors, used to operate 
    % with 2d data            
    % 
    % Constructor creates IX_dataset_2d object
    %
    %   >> w = IX_dataset_2d (x,y)
    %   >> w = IX_dataset_2d (x,y,signal)
    %   >> w = IX_dataset_2d (x,y,signal,error)
    %   >> w = IX_dataset_2d (x,y,signal,error,title,x_axis,y_axis,s_axis)
    %   >> w = IX_dataset_2d (x,y,signal,error,title,x_axis,y_axis,s_axis,x_distribution,y_distribution)
    %   >> w = IX_dataset_2d (title, signal, error, s_axis, x, x_axis, x_distribution, y, y_axis, y_distribution)
    %
    %  Creates an IX_dataset_2d object with the following elements:
    %
    %   title               char/cellstr    Title of dataset for plotting purposes (character array or cellstr)
    %   signal              double          Signal (2D array)
    %   error                               Standard error (2D array)
    %   s_axis              IX_axis         Signal axis object containing caption and units codes
    %                   (or char/cellstr    Can also just give caption; multiline input in the form of a
    %                                      cell array or a character array)
    %   x                   double          Values of bin boundaries (if histogram data)
    %                                       Values of data point positions (if point data)
    %   x_axis              IX_axis         x-axis object containing caption and units codes
    %                   (or char/cellstr    Can also just give caption; multiline input in the form of a
    %                                      cell array or a character array)
    %   x_distribution      logical         Distribution data flag (true is a distribution; false otherwise)
    %
    %   y                   double          -|
    %   y_axis              IX_axis          |- same as above but for y-axis
    %   y_distribution      logical         -|
        

    methods
        function obj= IX_dataset_2d(varargin)
            obj = obj@IX_data_2d(varargin{:});
        end
    end
    
    %======================================================================
    methods(Access=protected)
        % Support method for loadobj. This method needs to be accesible
        % both from loadobj, and from child classes loadobj_protected_
        % methods so that there is inheritable loadobj
        function obj = loadobj_protected_ (obj, S)
            obj = loadobj_protected_@IX_data_2d (obj, S);
        end
    end
        
    %======================================================================
    methods(Static)
        function obj = loadobj (S)
            % Function to support loading of outdated versions of the class
            % from mat files
            if isstruct(S)
                obj = IX_dataset_2d();
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
