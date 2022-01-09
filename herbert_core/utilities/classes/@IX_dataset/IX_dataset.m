classdef (Abstract) IX_dataset
    % IX_dataset Abstract parent class for IX_data_1d, IX_data_2d etc.
    
    properties(Dependent)
        % These are public properties at all child classes will posess, so
        % we declare them here (together with their set and get methods)
        
        % Main title to be plotted on graphs
        title
        
        % Array of signal values
        % Numeric array, with first index corresponding to first dimension,
        % second index to second dimension etc.
        signal
        
        % Array containing standard deviations
        % Same size as signal array.
        error
        
        % Signal axis information
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
        
        % Error array, containing standard deviations. 
        % Numeric array, with first index corresponding to first dimension,
        % second index to second dimension etc.
        error_
        
        % Signal axis information. IX_axis object
        s_axis_
        
        % Bin boundaries or centres. Cell array (row) of numeric row
        % vectors, one per dimension.
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

    properties (Access=private)
        % True if the object has been initialised
        % Initial value must be false so that when loading from .mat files
        % a check of internal consistency and and any necessary reformatting
        % is performed in loadobj. If valid_ is already true when the object
        % is read from file then a validation method can detect this and
        % skip the consistency check.
        valid_ = false
    end
    
    methods
        %===================================================================
        % Properties:
        %===================================================================

        % Set methods for independent properties
        %
        % Set the independent properties, which for this class are the
        % private properties. We cannot make the set functions depend on
        % other independent properties (see Matlab documentation). Have to 
        % devolve any checks on interdependencies to another function.
        
        function obj = set.title_ (obj, val)
            obj.title_ = check_and_set_title_ (val);
        end
        
        function obj = set.signal_ (obj, val)
            obj.signal_ = check_and_set_signal_ (val);
        end
        
        function obj = set.error_ (obj,val)
            obj.error_ = check_and_set_error_ (val);
        end

        function obj = set.s_axis_ (obj, val)
            obj.s_axis_ = check_and_set_s_axis_ (val);
        end
        
        function obj = set.xyz_ (obj,val)
            nd = obj.ndim();
            obj.xyz_ = check_and_set_x_ (val, 1:nd);
        end

        function obj = set.xyz_axis_ (obj, val)
            nd = obj.ndim();
            obj.xyz_axis_ = check_and_set_x_axis_ (val, 1:nd);
        end
        
        function obj = set.xyz_distribution_ (obj, val)
            nd = obj.ndim();
            obj.xyz_distribution_ = check_and_set_x_distribution_ (val, 1:nd);
        end
        
        %------------------------------------------------------------------
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
        
        function obj = set.title (obj, val)
            obj.title_ = val;
        end
        
        function obj = set.signal (obj, val)
            obj.signal_ = val;
            obj = check_properties_consistency_ (obj);
        end
        
        function obj = set.error (obj,val)
            obj.error_ = val;
            obj = check_properties_consistency_ (obj);
        end

        function obj = set.s_axis (obj, val)
            obj.s_axis_ = val;
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val = get.title (obj)
            val = obj.title_;
        end
        
        function val = get.signal (obj)
            val = obj.signal_;
        end
        
        function val = get.error (obj)
            val = obj.error_;
        end
        
        function val = get.s_axis (obj)
            val = obj.s_axis_;
        end
        
    end
    
    %======================================================================
    methods
        % Publicly accessible methods. Although it is not necesary for 
        % their interfaces to be defined here, their explicit appearance
        % documents their purpose.
        %
        % Methods that define unary or binary operations are not presented
        % here. They use binary_op_manager, binary_op_manager_single and
        % unary_op_manager in the private folder and methods of the sigvar
        % class. They also use the IX_dataset sigvar methods for which the
        % interfaces are given below.
        % 
        % Note that abs does not use unary_op_manager or sigvar methods
        % because its functionality does not involve the error array.
        
        
        % Methods related to sigvar class
        % -------------------------------
        % - Needed by unary and binary arithmetic
        %   -------------------------------------
        % Create sigvar object from the dataset
        sigvarobj = sigvar (obj)
        
        % Set output object signal and variance from an input sigvar object
        obj_out = sigvar_set (obj, sigvarobj)
        
        % Size of signal array in sigvar object created from the input object
        sz = sigvar_size (obj)
        
        % - Needed in addition by multifit
        %   ------------------------------
        % Get signal and variance from object, and a logical mask array
        [s, var, msk] = sigvar_get (obj)
        
        % Get bin centres for the object
        x = sigvar_getx (obj)
        
        
        % xye method
        % ----------
        % Return a structure containing unmasked x,y,e data
        S = xye (obj)
        
        % Other methods
        % -------------
        % Mask data
        obj_out = mask (obj, mask_array)
        
        
        %--- Not yet verified ---------------------------------------------
        % Save object or array of objects of class type to binary file.
        % Inverse of read.
        save(w,file)        
    end

    %======================================================================
    methods(Access=protected)
        % These are interfaces to generic methods defined for IX_dataset.
        % However, class-specific implementations of methods can be 
        % provided if necessary.
        %
        % Mostly, the reason class-specific public methods exist is to
        % enable documentation to be provided that is specific for a 
        % particular dimensionality (e.g. IX_dataset_2d/axis calls 
        % IX_datset/axis_). Sometimes it is because there is a class-
        % specific method that calls the generic method (e.g. setters for
        % the IX_dataset_2d properties x and y, which call IX_datset/set_xyz_) 
        
        % Build object
        % ------------
        % Build a new object
        obj = build_IX_dataset_ (obj, varargin)
        
        % Re-initialise an object
        obj_out = init_ (obj, varargin)
        
        % Set child properties
        % --------------------
        obj = set_xyz_ (obj, val, iax)   % set axis data

        obj = set_xyz_axis_ (obj, val, iax)  % set axis annotation information

        obj = set_xyz_distribution_ (obj, val, iax)  % set axis distribution flag

        % Dimension independent methods used by child methods
        % ---------------------------------------------------
        % Get axis information
        [ax, hist] = axis_ (obj, iax)
        
        % Cut an IX_dataset object or array of IX_dataset objects along
        % one or more axes
        obj_out = cut_ (obj, iax, array_is_descriptor, varargin)
        
        % Get dimensionality and signal size
        [nd, sz] = dimensions_ (obj)

        % Evaluate a function
        obj_out = func_eval_ (obj, funchandle, pars, varargin)

        % Convert histogram axes to point axes
        obj_out = hist2point_ (obj, iax)

        % Integrate an IX_dataset object or array of IX_dataset objects
        % along one or more axes
        obj_out = integrate_ (obj, iax, array_is_descriptor, varargin)
        
        % Determine histogram or point status for axes
        status = ishistogram_ (obj, iax)
        
        % Create an object by performing linspace on the axes
        obj_out = linspace_ (obj, n)
        
        % Create plot labels
        [x_label, s_label] = make_label_ (obj)
        
        % Add random noise to an object
        obj_out = noisify_ (obj, varargin)
        
        % Convert point axes to histogram axes
        obj_out = point2hist_ (obj, iax)

        % Rebin an IX_dataset object or array of IX_dataset objects along
        % one or more axes
        obj_out = rebin_ (obj, iax, array_is_descriptor, varargin)
        
        % Scale an object along its axes
        obj_out = scale_ (obj, xscale, iax)
        
        % Remove dimensions of length one dimensions in an IX_dataset object
        obj_out = squeeze_ (obj, iax)
        
        % Shift an object along its axes
        obj_out = shift_ (obj, xshift, iax)
    end
    
    %======================================================================
    methods(Static)
        % Test utilities
        % --------------
        % Access internal function for testing purposes
        varargout = test_gateway (func_name, varargin)

        
        %--- Not yet verified ---------------------------------------------

        % Read object or array of objects of an IX_dataset type from
        % a binary matlab file. Inverse of save.
        obj = read(filename);
    end
    
    %======================================================================
    % Abstract interface:
    %======================================================================
    % These are interfaces to class-specific implementations of methods.
    % The source code will be found in the folders that defined those
    % classes.
    
    methods(Abstract)
        % Get axis information for one or more axes
        [ax, hist] = axis (obj, iax)

        % Cut an object or array of objects along one or more axes
        obj_out = cut (obj, varargin)
        
        % Return dimensionality and extent of signal along the dimensions
        [nd, sz] = dimensions (obj)
        
        % Evaluate a function
        obj_out = func_eval (obj, funchandle, pars, varargin)

        % Convert all or selected histogram axes to point axes
        obj_out = hist2point (obj, iax)
        
        % Re-initialize object using class constructor code
        obj_out = init (obj, varargin);
        
        % Integrate object or array of objects along one or more axes
        obj_out = integrate (obj, varargin)
        
        % Integrate object or array of objects along one or more axes
        obj_out = integrate2 (obj, varargin)
        
        % Return array containing true or false depending on dataset being
        % histogram or point;
        status = ishistogram (obj, iax)
        
        % Create an object by performing linspace on the axes
        obj_out = linspace (obj, n)
        
        % Create axis annoations
        varargout = make_label (obj)
        
        % Add random noise to an object
        obj_out = noisify (obj, varargin)
        
        % Convert point axes to histogram axes
        obj_out = point2hist (obj, iax)

        % Rebin object or array of objects along one or more axes
        obj_out = rebin (obj, varargin)
        
        % Rebin object or array of objects along one or more axes
        obj_out = rebin2 (obj, varargin)
        
        % Rescale an object along its axes
        obj_out = scale (obj, xscale)
        
        % Remove dimensions of length one dimensions in an IX_dataset object
        obj_out = squeeze (obj, iax)
        
        % Shift an object along its axes
        obj_out = shift (obj, xshift)
    end
    
    %======================================================================
    methods(Abstract, Access=protected)
        % Support method for loadobj. This method needs to be accesible
        % both from loadobj, and from child classes loadobj_protected_
        % methods so that there is inheritable loadobj
        obj = loadobj_protected_ (obj, S)
    end
    
    %======================================================================
    methods(Abstract, Static)
        % Get number of class dimensions
        nd  = ndim()

        % To support loading of outdated versions of the class from mat files
        obj = loadobj(data)
    end
end
