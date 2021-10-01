classdef IX_dataset_3d < IX_data_3d
    % Class adds operations with graphics to main operations with 3-d data
    %
    % See IX_data_3d for main properties and constructors, used to operate
    % with 3d data
    %
    % Constructor creates IX_dataset_3d object
    %
    %   >> w = IX_dataset_3d (x,y,z)
    %   >> w = IX_dataset_3d (x,y,z,signal)
    %   >> w = IX_dataset_3d (x,y,z,signal,error)
    %   >> w = IX_dataset_3d (x,y,z,signal,error,title,x_axis,y_axis,z_axis,s_axis)
    %   >> w = IX_dataset_3d (x,y,z,signal,error,title,x_axis,y_axis,z_axis,s_axis,x_distribution,y_distribution,z_distribution)
    %   >> w = IX_dataset_3d (title, signal, error, s_axis, x, x_axis, x_distribution,...
    %                                          y, y_axis, y_distribution, z, z-axis, z_distribution)
    %
    %  Creates an IX_dataset_3d object with the following elements:
    %
    % 	title				char/cellstr	Title of dataset for plotting purposes (character array or cellstr)
    % 	signal              double  		Signal (3D array)
    % 	error				        		Standard error (3D array)
    % 	s_axis				IX_axis			Signal axis object containing caption and units codes
    %                   (or char/cellstr    Can also just give caption; multiline input in the form of a
    %                                      cell array or a character array)
    % 	x					double      	Values of bin boundaries (if histogram data)
    % 						                Values of data point positions (if point data)
    % 	x_axis				IX_axis			x-axis object containing caption and units codes
    %                   (or char/cellstr    Can also just give caption; multiline input in the form of a
    %                                      cell array or a character array)
    % 	x_distribution      logical         Distribution data flag (true is a distribution; false otherwise)
    %
    %   y                   double          -|
    %   y_axis              IX_axis          |- same as above but for y-axis
    %   y_distribution      logical         -|
    %
    %   z                   double          -|
    %   z_axis              IX_axis          |- same as above but for z-axis
    %   z_distribution      logical         -|
    
    
    methods
        function obj= IX_dataset_3d(varargin)
            obj = obj@IX_data_3d(varargin{:});
        end
    end
        
    %======================================================================
    methods(Access=protected)
        % Support method for loadobj. This method needs to be accesible
        % both from loadobj, and from child classes loadobj_protected_
        % methods so that there is inheritable loadobj
        function obj = loadobj_protected_ (obj, S)
            obj = loadobj_protected_@IX_data_3d (obj, S);
        end
    end
        
    %======================================================================
    methods(Static)
        function obj = loadobj (S)
            % Function to support loading of outdated versions of the class
            % from mat files
            if isstruct(S)
                obj = IX_dataset_3d();
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
