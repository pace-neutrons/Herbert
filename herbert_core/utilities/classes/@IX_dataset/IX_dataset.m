classdef (Abstract) IX_dataset
    % Abstract parent class for IX_data_1d, IX_data_2d etc.;
    
    properties(Dependent)
        % These are public properties at all child classes will posess, so
        % we declare them here (together with their set and get methods)
        
        % Title (plotted on graphs). Cell array (column) of character strings
        title
        
        % Signal array. Numeric array, with first index corresponding to
        % first dimension, second index to second dimension etc..
        signal
        
        % Error array, containing standard deviations.
        error
        
        % Signal axis information. IX_axis object
        s_axis
    end
    
    properties(Access=protected)
        % These are the class independent properties.
        % - Some of them are the mirrors of the dependent properties
        %   inherited by all child classes (see above).
        % - The others are arrays whose individual elements are mirrored by
        %   class-specific dependent properties of child classes.
        %
        % These properties need to be protected (not private) because this
        % class is inherited by IX_data_1d, IX_data_2d etc.
        
        % Title (plotted on graphs). Cell array (column) of character strings
        title_
        
        % Signal array. Numeric array, with first index corresponding to
        % first dimension, second index to second dimension etc.
        signal_
        
        % Error array, containing standard deviations. Numeric array, with
        % first index corresponding to first dimension, second index to
        % second dimension etc.
        error_
        
        % Signal axis information. IX_axis object
        s_axis_
        
        % Bin boundaries or centres. Cell array (row) of numeric row
        % vectors, one per dimension
        % Bin boundaries must be non-zero in width (i.e. array is *strictly*
        % monotonic increasing.
        % Point data must be monotonic increasing, but not strictly: this
        % means that points at the same x-axis value are permitted.
        xyz_
        
        % Axis information for each dimension. Row vector of IX_axis
        % objects
        xyz_axis_
        
        % Description of whether or not the signal along the axis is a
        % distribution (true) i.e. signal per unit measure, or not (false).
        % Logical row vector.
        xyz_distribution_
        
    end
    
    methods
        %===================================================================
        % Properties:
        %===================================================================

        % Set methods for dependent properties
        % Checks on validity of the passed value made in utility routines.
        % These are the same utility routines that are used by the class
        % constructor, and so full consistency between constructor and
        % set routines is guaranteed.
        %
        % Set methods for the other, class-specific, dependent properties
        % defined by child classes must be accessed via the special utility
        % set methods of IX_dataset. These set utilities perform the same
        % checks as the class constructor. Interfaces for these methods are 
        % declared elsewhere in this classdef
        
        function obj = set.title(obj, val)
            obj = check_and_set_title_(obj, val);
        end
        
        function obj = set.signal(obj, val)
            obj = check_and_set_signal_(obj, val);
            obj = check_properties_consistency_(obj);
        end
        
        function obj = set.error(obj,val)
            obj = check_and_set_error_(obj, val);
            obj = check_properties_consistency_(obj);
        end

        function obj = set.s_axis(obj, val)
            obj = obj.check_and_set_s_axis_(val);
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val = get.title(obj)
            val = obj.title_;
        end
        
        function val = get.signal(obj)
            val = obj.signal_;
        end
        
        function val = get.error(obj)
            val = obj.error_;
        end
        
        function val = get.s_axis(obj)
            val = obj.s_axis_;
        end
        
    end
    
    %======================================================================
    methods
        % Publicly accessible methods. They have their interface defined
        % here, but I do not know why, as they are public.
        %
        %------------------------------------------------------------------
        % Methors, which use unary/binary operation manager are stored
        % in the class folder only. Their signatures are not presented
        % here.
        %
        % Note that abs stands out because it does not involve the error
        % array.
        %------------------------------------------------------------------
        
        
        %--- Not yet verified ---------------------------------------------

        % set up object values using object structure. (usually as above)
        obj = init_from_structure(obj,struct)
        

        
        % Take absolute value of an IX_dataset_nd object or array of IX_dataset_nd objects
        % wout = abs(w)
        %------------------------------------------------------------------
        % Squeeze singleton dimensions awaay in IX_dataset_nd objects
        % to get to object of lower dimensionality
        wout=squeeze_IX_dataset(win,iax)
        
        % Rebin an IX_dataset object or array of IX_dataset objects along one or more axes
        [wout,ok,mess] = rebin_IX_dataset (win, integrate_data,...
            point_integration_default, iax, descriptor_opt, varargin)
        
        % Save object or array of objects of class type to binary file.
        % Inverse of read.
        save(w,file)
        
        % get sigvar object from the dataset
        wout = sigvar (w)
        %Get signal and variance from object, and a logical array of which values to keep
        [s,var,msk] = sigvar_get (w)
        % Set output object signal and variance fields from input sigvar object
        w = sigvar_set(w,sigvarobj)
        %Matlab size of signal array
        sz = sigvar_size(w)
        


        function xyz = get_xyz(obj,nd)
            % *** ONLY USED BY rebin_IX_dataset_nd:
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
        
        % *** ONLY USED BY rebin_IX_dataset_single_:
        % Set signal, error and selected axes in a single instance of an IX_dataset object
        wout=set_simple_xsigerr(win,iax,x,signal,err,xdistr)
        

        
    end
    
    %======================================================================
    methods(Static)
        
        %--- Not yet verified ---------------------------------------------

        % Read object or array of objects of an IX_dataset type from
        % a binary matlab file. Inverse of save.
        obj = read(filename);
        
        % Access internal function for testing purposes
        function [x_out, ok, mess] = bin_boundaries_from_descriptor(xbounds, x_in)
            [x_out, ok, mess] = bin_boundaries_from_descriptor_(xbounds, x_in);
        end
        
        % Access internal function for testing purposes
        function xout = test_rebin_values_from_descriptor(xdescr, varargin)
            xout = rebin_values_from_descriptor (xdescr, varargin{:});
        end
    end
    
    %======================================================================
    methods(Access=protected)
        % These are interfaces to generic methods defined for IX_dataset.
        % However, class-specific implementations of methods can be 
        % provided if requested.
        
        % Build object
        obj = build_IX_dataset_(obj, varargin)
        
        % Set child properties
        obj = set_xyz_(obj, val, iax)   % set axis data

        obj = set_xyz_axis_(obj, val, iax)  % set axis annotation information

        obj = set_xyz_distribution_(obj, val, iax)  % set axis distribution flag

        % Dimension independent methods used by child methods
        [ax, hist] = axis_(obj, iax)
        
        [nd, sz] = dimensions_(obj)
        
        obj_out = hist2point_(obj, iax)

        status = ishistogram_(obj, iax)
        
        [x_label, s_label] = make_label_(obj)
        
        
        %--- Not yet verified ---------------------------------------------
        
        % Make a cut from an IX_dataset object or array of IX_dataset objects along
        % specified axess direction(s).
        wout = cut_(win,dir,varargin)
        
        % Integrate an IX_dataset object or array of IX_dataset
        % objects along the axes, defined by direction
        wout = integrate_(win,array_is_descriptor, dir, varargin)
        
        % Rebin an IX_dataset object or array of IX_dataset objects along
        % along the axes, defined by direction
        wout = rebin_(win, array_is_descriptor,dir,varargin)
    end
    
    
    %======================================================================
    % Abstract interface:
    %======================================================================
    % These are interfaces to class-specific implementations of methods.
    % The source code will be found in the folders that defined those
    % classes.
    %
    % Notes
    % - init is actually defined in IX_data_1d.m, IX_data_2d.m rather than
    %   in a separate. I don't see why this should be the case.
    %
    % - dimensions, ishistogram, axis appear here as interfaces, and
    %   therefore required, but why not a host of other methods e.g.
    %   func_eval, hist2point ?
    
    
    methods(Abstract)
        % Get axis information for one or more axes
        [ax, hist] = axis(obj, iax)

        % Return dimensionality and extent of signal along the dimensions
        [nd, sz] = dimensions(obj)
        
        % Convert all or selected histogram axes to point axes
        obj_out = hist2point(obj, iax)
        
        % Return array containing true or false depending on dataset being
        % histogram or point;
        status = ishistogram(obj, iax)
        
        % Create axis annoations
        varargout = make_label(obj)
        
        %--- Not yet verified ---------------------------------------------
        % (re)initialize object using constructor' code
        obj = init(obj, varargin);
        
    end
    
    %======================================================================
    methods(Abstract,Static)
        % Get number of class dimensions
        nd  = ndim()

        %--- Not yet verified ---------------------------------------------
        % used to reload old style objects from mat files on hdd
        obj = loadobj(data)
    end
    
    
    %======================================================================
    methods(Abstract, Static, Access=protected)
        %--- Not yet verified ---------------------------------------------
        % Rebins histogram data along specific axis.
        [wout_s, wout_e] = rebin_hist(iax, wout_x);
        
        %Integrates point data along along specific axis.
        [wout_s,wout_e] = integrate_points(iax, xbounds_true);
    end
end

