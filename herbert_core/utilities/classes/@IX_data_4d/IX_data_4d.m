classdef IX_data_4d < IX_dataset
    % IX_data_4d
    
    properties(Dependent)
        % Bin boundaries or bin centres
        x
        % Caption information for x-axis
        x_axis
        % Logical value indicating data is from a distribution or not
        x_distribution

        % Bin boundaries or bin centres
        y
        % Caption information for y-axis
        y_axis
        % Logical value indicating data is from a distribution or not
        y_distribution
        
        % Bin boundaries or bin centres
        z
        % Caption information for z-axis
        z_axis
        % Logical value indicating data is from a distribution or not
        z_distribution
        
        % Bin boundaries or bin centres
        w
        % Caption information for w-axis
        w_axis
        % Logical value indicating data is from a distribution or not
        w_distribution
    end

    %======================================================================
    methods
        function obj = IX_data_4d(varargin)
            % Create IX_data_4d object
            %
            %   >> w = IX_data_4d (x,y,z)
            %   >> w = IX_data_4d (x,y,z,signal)
            %   >> w = IX_data_4d (x,y,z,signal,error)
            %   >> w = IX_data_2d (x,y,z,signal,error, x_distribution,y_distribution,z_distribution)
            %   >> w = IX_data_4d (x,y,z,signal,error,title,x_axis,y_axis,z_axis,s_axis)
            %   >> w = IX_data_4d (x,y,z,signal,error,title,x_axis,y_axis,z_axis,s_axis,x_distribution,y_distribution,z_distribution)
            %   >> w = IX_data_4d (title, signal, error, s_axis, x, x_axis, x_distribution,...
            %                                          y, y_axis, y_distribution, z, z-axis, z_distribution)
            %
            %  Creates an IX_dataset_4d object with the following elements:
            %
            % 	title				char/cellstr	Title of dataset for plotting purposes (character array or cellstr)
            % 	signal              double  		Signal (4D array)
            % 	error				        		Standard error (4D array)
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
            %
            %   w                   double          -|
            %   w_axis              IX_axis          |- same as above but for w-axis
            %   w_distribution      logical         -|

            obj = build_IX_dataset_(obj, varargin{:});
        end
  
        %------------------------------------------------------------------
        % Get methods for dependent properties
        
        function val = get.x(obj)
            val = obj.xyz_{1};
        end
        
        function val = get.y(obj)
            val = obj.xyz_{2};
        end
        
        function val = get.z(obj)
            val = obj.xyz_{3};
        end
        
        function val = get.w(obj)
            val = obj.xyz_{4};
        end
        
        function val = get.x_axis(obj)
            val = obj.xyz_axis_(1);
        end
        
        function val = get.y_axis(obj)
            val = obj.xyz_axis_(2);
        end
        
        function val = get.z_axis(obj)
            val = obj.xyz_axis_(3);
        end
        
        function val = get.w_axis(obj)
            val = obj.xyz_axis_(4);
        end
        
        function val = get.x_distribution(obj)
            val = obj.xyz_distribution_(1);
        end
        
        function val = get.y_distribution(obj)
            val = obj.xyz_distribution_(2);
        end
        
        function val = get.z_distribution(obj)
            val = obj.xyz_distribution_(3);
        end
        
        function val = get.w_distribution(obj)
            val = obj.xyz_distribution_(4);
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        
        function obj = set.x(obj, val)
            obj = set_xyz_(obj, val, 1);
        end
        
        function obj = set.y(obj, val)
            obj = set_xyz_(obj, val, 2);
        end
        
        function obj = set.z(obj, val)
            obj = set_xyz_(obj, val, 3);
        end
        
        function obj = set.w(obj, val)
            obj = set_xyz_(obj, val, 4);
        end
        
        function obj = set.x_axis(obj, val)
            obj = set_xyz_axis_(obj, val, 1);
        end
        
        function obj = set.y_axis(obj, val)
            obj = set_xyz_axis_(obj, val, 2);
        end
        
        function obj = set.z_axis(obj, val)
            obj = set_xyz_axis_(obj, val, 3);
        end
        
        function obj = set.w_axis(obj, val)
            obj = set_xyz_axis_(obj, val, 4);
        end
        
        function obj = set.x_distribution(obj, val)
            obj = set_xyz_distribution_(obj, val, 1);
        end
        
        function obj = set.y_distribution(obj, val)
            obj = set_xyz_distribution_(obj, val, 2);
        end
        
        function obj = set.z_distribution(obj, val)
            obj = set_xyz_distribution_(obj, val, 3);
        end
        
        function obj = set.w_distribution(obj, val)
            obj = set_xyz_distribution_(obj, val, 4);
        end
        
        %-----------------------------------------------------------------
    end
    
    
    %======================================================================
    methods(Static)
        function nd  = ndim()
            % Return the number of class dimensions
            nd = 4;
        end
    end
    
    %======================================================================
    methods(Static,Access = protected)
        
    end
    
end
