classdef IX_data_1d < IX_dataset
    
    properties(Dependent)
        % x - vector of bin boundaries for histogram data or bin centers
        % for distribution
        x
        % x_axis -- IX_axis class containing x-axis caption
        x_axis;
        % x_distribution -- an identifier, stating if the x-data contain
        % points or distribution in x-direction
        x_distribution;
    end
    
    %======================================================================
    methods
        function obj=IX_data_1d(varargin)
            % Create IX_data_1d object
            %
            % Constructor to create IX_dataset_1d object:
            %
            %   >> w = IX_data_1d (x)
            %   >> w = IX_data_1d (x,signal)
            %   >> w = IX_data_1d (x,signal,error)
            %   >> w = IX_data_1d ([x;signal;error]) % 3xNs vector of data;
            %   >> w = IX_data_1d (x,signal,error, x_distribution)
            %   >> w = IX_data_1d (x,signal,error,title,x_axis,s_axis)
            %   >> w = IX_data_1d (x,signal,error,title,x_axis,s_axis, x_distribution)
            %   >> w = IX_data_1d (title, signal, error, s_axis, x, x_axis, x_distribution)
            %
            %  Creates an IX_dataset_1d object with the following elements:
            %
            % 	title				char/cellstr	Title of dataset for plotting purposes (character array or cellstr)
            % 	signal              double  		Signal (vector)
            % 	error				        		Standard error (vector)
            % 	s_axis				IX_axis			Signal axis object containing caption and units codes
            %                   (or char/cellstr    Can also just give caption; multiline input in the form of a
            %                                      cell array or a character array)
            % 	x					double      	Values of bin boundaries (if histogram data)
            % 						                Values of data point positions (if point data)
            % 	x_axis				IX_axis			x-axis object containing caption and units codes
            %                   (or char/cellstr    Can also just give caption; multiline input in the form of a
            %                                      cell array or a character array)
            % 	x_distribution      logical         Distribution data flag (true is a distribution; false otherwise)
            
            
            obj = build_IX_dataset_(obj,varargin{:});
        end
        
        %--- Not yet verified ---------------------------------------------
        function obj = init(obj,varargin)
            % efficiently (re)initialize object using constructor's code
            obj = build_IXdataset_1d_(obj,varargin{:});
        end
        %------------------------------------------------------------------

        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        
        function val = get.x(obj)
            val = obj.xyz_{1};
        end
        
        function val = get.x_axis(obj)
            val = obj.xyz_axis_(1);
        end
        
        function val = get.x_distribution(obj)
            val = obj.xyz_distribution_(1);
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        
        function obj = set.x(obj, val)
            obj = set_xyz_(obj, val, 1);
        end
        
        function obj = set.x_axis(obj, val)
            obj = set_xyz_axis_(obj, val, 1);
        end
        
        function obj = set.x_distribution(obj, val)
            obj = set_xyz_distribution_(obj, val, 1);
        end
        
        %-----------------------------------------------------------------
    end
    
    %======================================================================
    methods(Static)
        function nd  = ndim()
            % Return the number of class dimensions
            nd = 1;
        end
    end
    
    %======================================================================
    methods(Static, Access = protected)
        
        %--- Not yet verified ---------------------------------------------
        % Rebins histogram data along specific axis.
        [wout_s, wout_e] = rebin_hist(iax, x, s, e, xout)
        
        % Integrates point data along along specific axis.
        [wout_s, wout_e] = integrate_points(iax, x, s, e, xout)
    end
    
end
