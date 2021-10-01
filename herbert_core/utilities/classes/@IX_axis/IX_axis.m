classdef IX_axis
    %  IX_axis object contains information to construct axis annotation and ticks

    properties(Access=private)
        % Private properties. Do not set these except via the public set methods
        % as there may be interdependencies (e.g. the number of tick positions and
        % labels must match, and the public set methods explicitly check this)
        
        % Caption: cell array of strings (column vector). Single element for
        % single line, vector if multi-line caption.
        caption_ = {};
        
        % Units: character vector (row)
        units_ = '';

        % Units code: character vector (row). This is an optional tag for
        % the user to interpret as they wish.
        code_ = '';
        
        % Ticks: structure with specified positions of tick marks (row vector)
        % and labels (cellstr, row vector)
        % If positions is [], then labels will be empty {}, and default
        % positions and labels will be used by any plotting function
        % If positions are given, then labels is either filled or is {},
        % when default tick labels will be plotted
        ticks_ = struct('positions',[],'labels',{{}});
    end
    
    properties(Dependent)
        % Publicly visible properties
        
        caption     % Axis caption (cellstr)
        units       % Axis units e.g. 'meV' (character string)
        code        % Custom user units code e.g. '$w' (character string)
        positions   % Positions of tick marks if explicit values set
        labels      % Tick labels if explicit values set
        ticks       % Structure with tick positions and labels
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_axis(varargin)
            % Create IX_axis object
            %
            %   >> w = IX_axis (caption)
            %   >> w = IX_axis (caption, units)
            %   >> w = IX_axis (caption, units, code)   % tag with a units code
            %
            % Setting custom tick positions and labels
            %   >> w = IX_axis (..., positions)         % positions
            %   >> w = IX_axis (..., positions, labels) % positions and labels
            %   >> w = IX_axis (..., ticks)             % structure with fields
            %                                           % 'position' and 'labels'
            %
            % Input:
            % ------
            % 	caption		Axis caption (character string, 2D character array, or
            %               cell array of strings)
            %
            %   units       Units for axis e.g. 'meV' (character string)
            %
            %   code        Custom user units code e.g. '$w' (character string)
            %
            %   positions   Tick mark positions (numeric vector)
            %               If not given, then default positions will be used in
            %               any plotting functions
            %
            %   labels      Character array or cellstr of tick labels
            %               If not given, then default values will be used in
            %               any plotting functions
            %
            %   ticks       Alternative to giving positions and labels separately
            %               Structure with fields
            %                   positions   Tick mark positions (numeric vector)
            %                   labels      Character or cell array of tick labels
            
            
            if nargin==1 && isa(varargin{1},'IX_axis')
                % Already an IX_axis object, so return
                obj = varargin{1};

            elseif nargin==1 && isstruct(varargin{1})
                % Structure input
                obj = IX_axis.loadobj(varargin{1});

            else
                % Build from other arguments
                if nargin > 0
                    obj = build_IX_axis_(obj, varargin{:});
                end
            end
        end
        
        %------------------------------------------------------------------
        % Set methods for independent properties
        %
        % Set the independent properties, which for this class are the
        % private properties. We cannot make the set functions depend on
        % other independent properties (see Matlab documentation). Have to 
        % devolve any checks on interdependencies to another function.
        
        function obj = set.caption_ (obj, val)
            obj.caption_ = check_and_set_caption_ (val);
        end
        
        function obj = set.units_ (obj, val)
            obj.units_ = check_and_set_units_ (val);
        end
        
        function obj = set.code_ (obj, val)
            obj.code_ = check_and_set_code_ (val);
        end
        
        function obj = set.ticks_ (obj, val)
            obj.ticks_ = check_and_set_ticks_ (val);
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        
        function obj = set.caption (obj, val)
            obj.caption_ = val;
        end
        
        function obj = set.units (obj, val)
            obj.units_ = val;
        end
        
        function obj = set.code (obj, val)
            obj.code_ = val;
        end
        
        function obj = set.ticks (obj, val)
            obj.ticks_ = val;
        end
        
        function obj = set.positions(obj, val)
            obj.ticks_ = check_and_set_positions_ (obj.ticks_, val);
        end
        
        function obj = set.labels(obj, val)
            obj.ticks_ = check_and_set_labels_ (obj.ticks_, val);
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        
        function val = get.caption (obj)
            val = obj.caption_;
        end
        
        function val = get.units (obj)
            val = obj.units_;
        end
        
        function val = get.code (obj)
            val = obj.code_;
        end
        
        function val = get.ticks (obj)
            val = obj.ticks_;
        end        
        
        function val = get.positions (obj)
            val = obj.ticks_.positions;
        end        
        
        function val = get.labels (obj)
            val = obj.ticks_.labels;
        end
        
        %------------------------------------------------------------------
    end
    
    %------------------------------------------------------------------
    methods(Static)
       function obj = loadobj(S)
            % Function to support loading of outdated versions of the class
            % from mat files
            if isstruct(S)
                obj = arrayfun(@(x)loadobj_private_(x), S);
            else
                obj = S;    % must be an instance of the object
            end
        end    
    end
    %------------------------------------------------------------------
end
