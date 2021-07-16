classdef IX_dataset
    % Abstract parent class for IX_datasets_Nd;
    
    properties(Dependent)
        % title:  dataset title (will be plotted on a grapth)
        title
        % signal -- array of signal...
        signal
        % error  -- array of errors
        error
        % s_axis -- IX_axis class containing signal axis caption
        s_axis
    end
    
    properties(Access=protected)
        % Class independent properties
        % Need to be protected (not private) because this class is inherited
        % by IX_data_1d, IX_data_2d etc.
        
%         % Title. Cell array (column) of character strings
%         title_
%         
%         % Signal array. Array 
%         signal_
%         
%         % Variance array
%         error_
%         
%         % Signal axis information
%         s_axis_
% 
%         % Bin boundaries or centres. Cell array (row) of numeric column
%         % vectors, one per dimension
%         xyz_
%         
%         % Axis information for each dimensions: Cell array (row) of IX_axis
%         % objects
%         xyz_axis_
%         
%         % Description of whether or not the signal along the axis is a 
%         % distribution (true) i.e. signal per unit measure, or not (false).
%         % Logical row vector.
%         xyz_distribution_
%         
%         % Status of empty object - logical flag
%         valid_
%         
%         % Error message to report if not valid
%         error_mess_

        % Title. Cell array (column) of character strings
        title_ = cell(0,1)
        
        % Signal array. Array 
        signal_ = zeros(0,1)
        
        % Variance array
        error_ = zeros(0,1)
        
        % Signal axis information
        s_axis_ = IX_axis()

        % Bin boundaries or centres. Cell array (row) of numeric column
        % vectors, one per dimension
        xyz_ = cell(1,0)
        
        % Axis information for each dimensions: Cell array (row) of IX_axis
        % objects
        xyz_axis_ = cell(1,0)
        
        % Description of whether or not the signal along the axis is a 
        % distribution (true) i.e. signal per unit measure, or not (false).
        % Logical row vector.
        xyz_distribution_ = true(1,0)
        
        % Status of empty object - logical flag
        valid_ = true
        
        % Error message to report if not valid
        error_mess_ = ''
    end
    
    %======================================================================
    methods
        %------------------------------------------------------------------
        % Methors, which use unary/binary operation manager are stored
        % in the class folder only. Their signatures are not presented
        % here.
        %------------------------------------------------------------------
        % Signatures for common methods, which do not use unary/binary
        % operation manager:
        %------------------------------------------------------------------
        % return class structure
        public_struct = struct(this)
        % set up object values using object structure. (usually as above)
        obj = init_from_structure(obj,struct)
        %
        % method checks if common fiedls are consistent between each
        % other. Call this method from a program after changing
        % x,signal, error using set operations. Throws 'invalid_argument'
        % if class is incorrent and and the method is called with one
        % output argument. Returns error message, if class is incorrect and
        % method called with two output arguments.
        [obj,mess] = isvalid(obj)
        % Take absolute value of an IX_dataset_nd object or array of IX_dataset_nd objects
        wout = abs(w)
        %------------------------------------------------------------------
        %Sqeeze singleton dimensions awaay in IX_dataset_nd objects
        %to get to object of lower dimensionality
        wout=squeeze_IX_dataset(win,iax)
        % Rebin an IX_dataset object or array of IX_dataset objects along one or more axes
        [wout,ok,mess] = rebin_IX_dataset (win, integrate_data,...
            point_integration_default, iax, descriptor_opt, varargin)
        %
        
        % Save object or array of objects of class type to binary file.
        % Inverse of read.
        save(w,file)
        
        %
        % get sigvar object from the dataset
        wout = sigvar (w)
        %Get signal and variance from object, and a logical array of which values to keep
        [s,var,msk] = sigvar_get (w)
        % Set output object signal and variance fields from input sigvar object
        w = sigvar_set(w,sigvarobj)
        %Matlab size of signal array
        sz = sigvar_size(w)
        
        %------------------------------------------------------------------
        % accessors, whcih do not use properties
        %------------------------------------------------------------------

        %
        function sig = get_signal(obj)
            % get signal without checking for its validity
            sig = obj.signal_;
        end
        %
        function sig = get_error(obj)
            % get error without checking for its validity
            sig = obj.error_;
        end
        
        
        %------------------------------------------------------------------
        % *** ONLY USED BY rebin_IX_dataset_nd:
        function xyz = get_xyz(obj,nd)
            % get x (y,z) values without checking for their validity
            if ~exist('nd', 'var')
                xyz  = obj.xyz_;
            else
                xyz  = obj.xyz_{nd};
            end
        end
        
        function dis = get_isdistribution(obj)
            % *** ONLY USED BY rebin_IX_dataset_nd
            % get boolean array informing if the state of distribution
            % along all axis
            dis= obj.xyz_distribution_;
        end
        %------------------------------------------------------------------
        
        %
        function ok = get_isvalid(obj)
            % returns the state of the internal valid_ property
            ok = obj.valid_;
        end
        % Set signal, error and selected axes in a single instance of an IX_dataset object
        wout=set_simple_xsigerr(win,iax,x,signal,err,xdistr)
        
        %===================================================================
        % Properties:
        %===================================================================
        function tit = get.title(obj)
            tit = obj.title_;
        end
        %
        function sig = get.signal(obj)
            if obj.valid_
                sig = obj.signal_;
            else
                sig = obj.error_mess_;
            end
        end
        %
        function err = get.error(obj)
            if obj.valid_
                err = obj.error_;
            else
                err = obj.error_mess_;
            end
        end
        %------------------------------------------------------------------
        %
        function ax = get.s_axis(obj)
            ax = obj.s_axis_;
        end
        %
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        function obj = set.title(obj,val)
            obj = check_and_set_title_(obj,val);
        end
        %
        %
        function obj = set.s_axis(obj,val)
            obj.s_axis_ = obj.check_and_build_axis(val);
        end
        %
        %------------------------------------------------------------------
        %
        function obj = set.signal(obj,val)
            obj = check_and_set_sig_err(obj,'signal',val);
            [ok,mess] = check_joint_fields(obj);
            if ok
                obj.valid_ = true;
                obj.error_mess_ = '';
            else
                obj.valid_ = false;
                obj.error_mess_ = mess;
            end
        end
        %
        function obj = set.error(obj,val)
            obj = check_and_set_sig_err(obj,'error',val);
            [ok,mess] = check_joint_fields(obj);
            if ok
                obj.valid_ = true;
                obj.error_mess_ = '';
            else
                obj.valid_ = false;
                obj.error_mess_ = mess;
            end
        end
        %
    end
    %======================================================================
    methods(Access=protected)
        % common auxiliary service methods, which can be overloaded if
        % requested
        
        % Build object
        obj = build_IX_dataset(obj, varargin)
        
        
        %------------------------------------------------------------------
        % USED IN GET METHODS FOR AXIS ARRAYS BY IX_DATA_1D etc
        % get x, y or z axis data
        xyz = get_xyz_data(obj,nax)

        %------------------------------------------------------------------
        % set x, y or z axis data
        obj = set_xyz_data(obj,nax,val)
        %------------------------------------------------------------------
        
        
        % Integrate an IX_dataset object or array of IX_dataset
        % objects along the axes, defined by direction
        wout = integrate_xyz(win,array_is_descriptor, dir, varargin)
        % Make a cut from an IX_dataset object or array of IX_dataset objects along
        % specified axess direction(s).
        wout = cut_xyz(win,dir,varargin)
        % Rebin an IX_dataset object or array of IX_dataset objects along
        % along the axes, defined by direction
        wout = rebin_xyz(win, array_is_descriptor,dir,varargin)
    end
    
    %======================================================================
    methods(Static)
        % Read object or array of objects of an IX_dataset type from
        % a binary matlab file. Inverse of save.
        obj = read(filename);
        % Access internal function for testing purposes
        function [x_out, ok, mess] = bin_boundaries_from_descriptor(xbounds, x_in)
            [x_out, ok, mess] = bin_boundaries_from_descriptor_(xbounds, x_in);
        end
        
    end
    
    %======================================================================
    methods(Static,Access=protected)
        % verify if x,y,z field data are correct
        val = check_xyz(val);
        % Internal function used to verify and set up an axis
        obj = check_and_build_axis(val);
    end
    %======================================================================
    % Abstract interface:
    %======================================================================
    methods(Abstract)
        % (re)initialize object using constructor' code
        obj = init(obj,varargin);
        % Find number of dimensions and extent along each dimension of the signal arrays.
        [nd,sz] = dimensions(w)
        % Return array containing true or false depending on dataset being
        % histogram or point;
        status=ishistogram(w,n)
        % Get information for one or more axes and if it has histogram data
        % for each axis
        [ax,hist]=axis(w,n)        
    end
    %======================================================================
    methods(Abstract,Static)
        % used to reload old style objects from mat files on hdd
        obj = loadobj(data)
        % get number of class dimensions
        nd  = ndim()
    end
    %======================================================================
    methods(Abstract,Access=protected)
        % Generic checks:
        % Check if various interdependent fields of a class are consistent
        % between each other.
        [ok,mess] = check_joint_fields(obj);
        % verify and set signal or error arrays
        obj = check_and_set_sig_err(obj,field_name,value);
    end
    
    %======================================================================
    methods(Abstract,Static,Access=protected)
        % Rebins histogram data along specific axis.
        [wout_s, wout_e] = rebin_hist(iax, wout_x);
        %Integrates point data along along specific axis.
        [wout_s,wout_e] = integrate_points(iax, xbounds_true);
    end
end

