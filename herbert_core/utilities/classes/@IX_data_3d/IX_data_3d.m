classdef IX_data_3d < IX_dataset
    % IX_data_3d
    
    properties(Dependent)
        % x - vector of bin boundaries for histogram data or bin centers
        % for distribution
        x
        % x_axis -- IX_axis class containing x-axis caption
        x_axis;
        % x_distribution -- an identifier, stating if the x-data contain
        % points or distribution in x-direction
        x_distribution;
        % y - vector of bin boundaries for histogram data or bin centers
        % for distribution in y-direction
        y
        % y_axis -- IX_axis class containing y-axis caption
        y_axis;
        % y_distribution -- an identifier, stating if the y-data contain
        % points or distribution in y-direction
        y_distribution;
        % z - vector of bin boundaries for histogram data or bin centers
        % for distribution in z-direction
        z
        % z_axis -- IX_axis class containing z-axis caption
        z_axis;
        % z_distribution -- an identifier, stating if the z-data contain
        % points or distribution in z-direction
        z_distribution;
    end

    %======================================================================
    methods
        function obj = IX_data_3d(varargin)
            % Create IX_data_3d object
            %
            %   >> w = IX_data_3d (x,y,z)
            %   >> w = IX_data_3d (x,y,z,signal)
            %   >> w = IX_data_3d (x,y,z,signal,error)
            %   >> w = IX_data_2d (x,y,z,signal,error, x_distribution,y_distribution,z_distribution)
            %   >> w = IX_data_3d (x,y,z,signal,error,title,x_axis,y_axis,z_axis,s_axis)
            %   >> w = IX_data_3d (x,y,z,signal,error,title,x_axis,y_axis,z_axis,s_axis,x_distribution,y_distribution,z_distribution)
            %   >> w = IX_data_3d (title, signal, error, s_axis, x, x_axis, x_distribution,...
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
            %   z_distribution      logical         -|            obj = build_IX_dataset(obj, varargin{:});

            
            obj = build_IX_dataset_(obj, varargin{:});
        end
        
        %--- Not yet verified ---------------------------------------------
        function obj = init(obj,varargin)
            % efficiently (re)initialize object using constructor's code
            obj = build_IXdataset_3d_(obj,varargin{:});
        end
        %------------------------------------------------------------------
        
  
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
        
        function val = get.x_axis(obj)
            val = obj.xyz_axis_(1);
        end
        
        function val = get.y_axis(obj)
            val = obj.xyz_axis_(2);
        end
        
        function val = get.z_axis(obj)
            val = obj.xyz_axis_(3);
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
        
        function obj = set.x_axis(obj, val)
            obj = set_xyz_axis_(obj, val, 1);
        end
        
        function obj = set.y_axis(obj, val)
            obj = set_xyz_axis_(obj, val, 2);
        end
        
        function obj = set.z_axis(obj, val)
            obj = set_xyz_axis_(obj, val, 3);
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
        
        %-----------------------------------------------------------------
    end
    
    
    %======================================================================
    methods(Static)
        function nd  = ndim()
            % Return the number of class dimensions
            nd = 3;
        end
    end
    
    %======================================================================
    methods(Static,Access = protected)
        
        %--- Not yet verified ---------------------------------------------
        % Rebins histogram data along specific axis.
        [wout_s, wout_e] = rebin_hist(iax,x, s, e, xout)

        % Integrates point data along along specific axis.
        [wout_s, wout_e] = integrate_points(iax, x, s, e, xout)
        
    end
    
end
