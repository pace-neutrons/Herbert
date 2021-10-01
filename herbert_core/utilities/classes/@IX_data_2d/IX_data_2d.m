classdef IX_data_2d < IX_dataset
    % IX_data_2d

    properties(Dependent)
        % x - vector of bin boundaries for histogram data or bin centres
        % for distribution
        x
        % x_axis -- IX_axis class containing x-axis caption
        x_axis;
        % x_distribution -- an identifier, stating if the x-data contain
        % points or distribution in x-direction
        x_distribution;
        % y - vector of bin boundaries for histogram data or bin centers
        % for distribution
        y
        % y_axis -- IX_axis class containing y-axis caption
        y_axis;
        % y_distribution -- an identifier, stating if the y-data contain
        % class or distribution
        y_distribution;
    end
    
    %======================================================================
    methods
        function obj = IX_data_2d(varargin)
            % Create IX_data_2d object
            %
            % Construct with default captioning:
            %   >> w = IX_data_2d (x, y)
            %   >> w = IX_data_2d (x, y, signal)
            %   >> w = IX_data_2d (x, y, signal, error)
            %   >> w = IX_data_2d (x, y, signal, error, x_distribution, y_distribution)
            %
            % Construct with custom captioning:
            %   >> w = IX_data_2d (x, y, signal, error, title, x_axis, y_axis, s_axis)
            %   >> w = IX_data_2d (x, y, signal, error, title, x_axis, y_axis, s_axis, x_distribution, y_distribution)
            %
            % Old format constructor (retained for backwards compatibility)
            %   >> w = IX_data_2d (title,  signal, error, s_axis, x, x_axis, x_distribution, y, y_axis, y_distribution)
            %
            % Input:
            % ------
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
            

            obj = build_IX_dataset_(obj, varargin{:});
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        
        function obj = set.x (obj, val)
            obj = set_xyz_ (obj, val, 1);
        end
        
        function obj = set.y (obj, val)
            obj = set_xyz_ (obj, val, 2);
        end
        
        function obj = set.x_axis (obj, val)
            obj = set_xyz_axis_ (obj, val, 1);
        end
        
        function obj = set.y_axis (obj, val)
            obj = set_xyz_axis_ (obj, val, 2);
        end
        
        function obj = set.x_distribution (obj, val)
            obj = set_xyz_distribution_ (obj, val, 1);
        end
        
        function obj = set.y_distribution (obj, val)
            obj = set_xyz_distribution_ (obj, val, 2);
        end

        %------------------------------------------------------------------
        % Get methods for dependent properties
        
        function val = get.x (obj)
            val = obj.xyz_{1};
        end
        
        function val = get.y (obj)
            val = obj.xyz_{2};
        end
        
        function val = get.x_axis (obj)
            val = obj.xyz_axis_(1);
        end
        
        function val = get.y_axis (obj)
            val = obj.xyz_axis_(2);
        end
        
        function val = get.x_distribution (obj)
            val = obj.xyz_distribution_(1);
        end
        
        function val = get.y_distribution (obj)
            val = obj.xyz_distribution_(2);
        end
        
        %-----------------------------------------------------------------
    end
    
    %======================================================================
    methods(Access=protected)
        % Support method for loadobj. This method needs to be accesible
        % both from loadobj, and from child classes loadobj_protected_
        % methods so that there is inheritable loadobj
        obj = loadobj_protected_ (obj, S)
    end
    
    %======================================================================
    methods(Static)
        function nd  = ndim()
            % Return the number of class dimensions
            nd = 2;
        end
        
        function obj = loadobj(S)
            % Function to support loading of outdated versions of the class
            % from mat files
            if isstruct(S)
                obj = IX_data_2d();
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
