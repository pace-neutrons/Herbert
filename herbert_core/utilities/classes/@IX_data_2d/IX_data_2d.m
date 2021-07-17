classdef IX_data_2d < IX_dataset
    % IX_data_2d Holds 

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
            % Create IX_dataset_2d object
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
            

            obj = build_IX_dataset(obj, varargin{:});
        end
        
        function obj = init(obj,varargin)
            % efficiently (re)initialize object using constructor's code
            obj = build_IXdataset_2d_(obj,varargin{:});
        end
        

        %------------------------------------------------------------------
        % Get methods for dependent properties
        
        function xx = get.x(obj)
            xx = obj.get_xyz_data(1);
        end
        
        function yy = get.y(obj)
            yy = obj.get_xyz_data(2);
        end
        
        function ax = get.x_axis(obj)
            ax = obj.xyz_axis_(1);
        end
        
        function ax = get.y_axis(obj)
            ax = obj.xyz_axis_(2);
        end
        
        function dist = get.x_distribution(obj)
            dist = obj.xyz_distribution_(1);
        end
        
        function dist = get.y_distribution(obj)
            dist = obj.xyz_distribution_(2);
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        
        function obj = set.x(obj, val)
            obj = set_xyz_data(obj,1,val);
        end
        
        function obj = set.y(obj, val)
            obj = set_xyz_data(obj,2,val);
        end
        
        function obj = set.x_axis(obj, val)
            obj.xyz_axis_(1) = obj.check_and_build_axis(val);
        end
        
        function obj = set.y_axis(obj, val)
            obj.xyz_axis_(2) = obj.check_and_build_axis(val);
        end
        
        function obj = set.x_distribution(obj, val)
            % TODO: should setting it to true/false involve chaning x from
            % disrtibution to bin centers and v.v.?
            obj.xyz_distribution_(1) = logical(val);
        end
        
        function obj = set.y_distribution(obj, val)
            % TODO: should setting it to true/false involve chaning y from
            % disrtibution to bin centers and v.v.? + signal changes
            obj.xyz_distribution_(2) = logical(val);
        end
        
        %-----------------------------------------------------------------
    end
    
    
    %======================================================================
    methods
        % *** DO NOT KNOW WHY NEED TO DEFINE THIS INTERFACE
        %     No methods attributes are set
        % Get information for one or more axes and if is histogram data for each axis
        [ax,hist]=axis(w,n)
    end
    
    %======================================================================
    methods(Static)
        function nd  = ndim()
            %return the number of class dimensions
            nd = 2;
        end
    end
    
    %======================================================================
    methods(Access=protected)
        % *** SHOULD BECOME IRRELEVANT WITH RE_ENGINEERING OF IX_DATASET ?
        
        function  [ok,mess] = check_joint_fields(obj)
            % implement class specific check for connected fiedls
            % consistency
            [ok,mess] = check_joint_fields_(obj);
        end
        
        function obj = check_and_set_sig_err(obj,field_name,value)
            % verify and set up signal or error arrays. Throw if
            % input can not be converted to correct array data.
            obj = check_and_set_sig_err_(obj,field_name,value);
        end
    end
    
    %======================================================================
    methods(Static,Access = protected)
        % Rebins histogram data along specific axis.
        [wout_s, wout_e] = rebin_hist(iax, x, s, e, xout)
        %Integrates point data along along specific axis.
        [wout_s,wout_e] = integrate_points(iax, x, s, e, xout)
        
    end
    
end
