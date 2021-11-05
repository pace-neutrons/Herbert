classdef IX_inst_DGdisk < IX_inst
    % Instrument with double disk shaping and monochromating choppers
    
    properties (Access=private)
        class_version_ = 1;
        mod_shape_mono_ = IX_mod_shape_mono
        horiz_div_ = IX_divergence_profile
        vert_div_ = IX_divergence_profile
    end
    
    properties (Dependent)
        mod_shape_mono  % Moderator-shaping chopper-monochromating chopper combination
        moderator       % Moderator (object of class IX_moderator)
        shaping_chopper % Moderator shaping chopper (object of class IX_doubledisk_chopper)
        mono_chopper    % Monochromating chopper (object of class IX_doubledisk_chopper)
        horiz_div       % Horizontal divergence lookup (object of class IX_divergence profile)
        vert_div        % Vertical divergence lookup (object of class IX_divergence profile)
        energy          % Incident neutron energy (meV)
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_inst_DGdisk (varargin)
            % Create double disk chopper instrument
            %
            %   obj = IX_inst_DGdisk (moderator, shaping_chopper, mono_chopper,...
            %               horiz_div, vert_div)
            %
            % Optionally:
            %   obj = IX_inst_DGdisk (..., energy)
            %
            %  one or both of:
            %   obj = IX_inst_DGdisk (..., '-name', name)
            %   obj = IX_inst_DGdisk (..., '-source', source)
            %
            %   moderator       Moderator (IX_moderator object)
            %   shaping_chopper Moderator shaping chopper (IX_doubledisk_chopper object)
            %   mono_chopper    Monochromating chopper (IX_doubledisk_chopper object)
            %   horiz_div       Horizontal divergence (IX_divergence object)
            %   vert_div        Vertical divergence (IX_divergence object)
            %   energy          Neutron energy (meV)
            %   name            Name of instrument (e.g. 'LET')
            %   source          Source: name (e.g. 'ISIS') or IX_source object
            
            % General case
            % make DGdisk not empty by default
            obj.name_ = '_';
            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_inst_DGdisk.loadobj(varargin{1});
                
            elseif nargin>0
                namelist = {'moderator','shaping_chopper','mono_chopper',...
                    'horiz_div','vert_div','energy','name','source'};
                [S, present] = parse_args_namelist (namelist, varargin{:});
                
                % Superclass properties: TODO: call superclass to set them
                if present.name
                    obj.name_ = S.name;
                end
                if present.source
                    obj.source_ = S.source;
                end
                
                % Set monochromating components
                if present.moderator && present.shaping_chopper && present.mono_chopper
                    if present.energy
                        obj.mod_shape_mono_ = IX_mod_shape_mono(S.moderator,...
                            S.shaping_chopper, S.mono_chopper, S.energy);
                    else
                        obj.mod_shape_mono_ = IX_mod_shape_mono(S.moderator,...
                            S.shaping_chopper, S.mono_chopper);
                    end
                else
                    error('Must give all of moderator, shaping, and monochromating chopper')
                end
                
                % Set divergences
                if present.horiz_div && present.vert_div
                    obj.horiz_div_ = S.horiz_div;
                    obj.vert_div_ = S.vert_div;
                else
                    error('Must give both the horizontal and vertical divegences')
                end
                
            end
        end
        
        %------------------------------------------------------------------
        % Set methods for independent properties
        %
        % Devolve any checks on interdependencies to the constructor (where
        % we refer only to the independent properties) and in the set
        % functions for the dependent properties.
        %
        % There is a synchronisation that must be maintained as the checks
        % in both places must be identical.
        
        function obj=set.mod_shape_mono_(obj,val)
            if isa(val,'IX_mod_shape_mono') && isscalar(val)
                obj.mod_shape_mono_ = val;
            else
                error('''mod_shape_mono_'' must be an IX_mod_shape_mono object')
            end
        end
        
        function obj=set.horiz_div_(obj,val)
            if isa(val,'IX_divergence_profile') && isscalar(val)
                obj.horiz_div_ = val;
            else
                error('The horizontal divergence must be an IX_divergence_profile object')
            end
        end
        
        function obj=set.vert_div_(obj,val)
            if isa(val,'IX_divergence_profile') && isscalar(val)
                obj.vert_div_ = val;
            else
                error('The vertical divergence must be an IX_divergence_profile object')
            end
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        function obj=set.mod_shape_mono(obj,val)
            obj.mod_shape_mono_ = val;
        end
        
        function obj=set.moderator(obj,val)
            obj.mod_shape_mono_.moderator = val;
        end
        
        function obj=set.shaping_chopper(obj,val)
            obj.mod_shape_mono_.shaping_chopper = val;
        end
        
        function obj=set.mono_chopper(obj,val)
            obj.mod_shape_mono_.mono_chopper = val;
        end
        
        function obj=set.horiz_div(obj,val)
            obj.horiz_div_ = val;
        end
        
        function obj=set.vert_div(obj,val)
            obj.vert_div_ = val;
        end
        
        function obj=set.energy(obj,val)
            obj.mod_shape_mono_.energy = val;
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.mod_shape_mono(obj)
            val = obj.mod_shape_mono_;
        end
        
        function val=get.moderator(obj)
            val = obj.mod_shape_mono_.moderator;
        end
        
        function val=get.shaping_chopper(obj)
            val = obj.mod_shape_mono_.shaping_chopper;
        end
        
        function val=get.mono_chopper(obj)
            val = obj.mod_shape_mono_.mono_chopper;
        end
        
        function val=get.horiz_div(obj)
            val = obj.horiz_div_;
        end
        
        function val=get.vert_div(obj)
            val = obj.vert_div_;
        end
        
        function val=get.energy(obj)
            val = obj.mod_shape_mono_.energy;
        end
        
        %------------------------------------------------------------------
    end
    
    %======================================================================
    % Methods for fast construction of structure with independent properties
    methods (Static, Access = private)
        function names = propNamesIndep_
            % Determine the independent property names and cache the result.
            % Code is boilerplate
            persistent names_store
            if isempty(names_store)
                names_store = fieldnamesIndep(eval(mfilename('class')));
            end
            names = names_store;
        end
        
        function names = propNamesPublic_
            % Determine the visible public property names and cache the result.
            % Code is boilerplate
            persistent names_store
            if isempty(names_store)
                names_store = properties(eval(mfilename('class')));
            end
            names = names_store;
        end
        
        function struc = scalarEmptyStructIndep_
            % Create a scalar structure with empty fields, and cache the result
            % Code is boilerplate
            persistent struc_store
            if isempty(struc_store)
                names = eval([mfilename('class'),'.propNamesIndep_''']);
                arg = [names; repmat({[]},size(names))];
                struc_store = struct(arg{:});
            end
            struc = struc_store;
        end
        
        function struc = scalarEmptyStructPublic_
            % Create a scalar structure with empty fields, and cache the result
            % Code is boilerplate
            persistent struc_store
            if isempty(struc_store)
                names = eval([mfilename('class'),'.propNamesPublic_''']);
                arg = [names; repmat({[]},size(names))];
                struc_store = struct(arg{:});
            end
            struc = struc_store;
        end
    end
    
    methods
        function S = structIndep(obj)
            % Return the independent properties of an object as a structure
            %
            %   >> s = structIndep(obj)
            %
            % Use <a href="matlab:help('structArrIndep');">structArrIndep</a> to convert an object array to a structure array
            %
            % Has the same behaviour as the Matlab instrinsic struct in that:
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            % - If the object is non-empty array, returns a scalar structure corresponding
            %   to the the first element in the array of objects
            %
            %
            % See also structPublic, structArrIndep, structArrPublic
            
            names = obj.propNamesIndep_';
            if ~isempty(obj)
                tmp = obj(1);
                S = obj.scalarEmptyStructIndep_;
                for i=1:numel(names)
                    S.(names{i}) = tmp.(names{i});
                end
            else
                args = [names; repmat({cell(size(obj))},size(names))];
                S = struct(args{:});
            end
        end
        
        function S = structArrIndep(obj)
            % Return the independent properties of an object array as a structure array
            %
            %   >> s = structArrIndep(obj)
            %
            % Use <a href="matlab:help('structIndep');">structIndep</a> for behaviour that more closely matches the Matlab
            % intrinsic function struct.
            %
            % Has the same behaviour as the Matlab instrinsic struct in that:
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            %
            % However, differs in the behaviour if an object array:
            % - If the object is non-empty array, returns a structure array of the same
            %   size. This is different to the instrinsic Matlab, which returns a scalar
            %   structure from the first element in the array of objects
            %
            %
            % See also structIndep, structPublic, structArrPublic
            
            if numel(obj)>1
                S = arrayfun(@fill_it, obj);
            else
                S = structIndep(obj);
            end
            
            function S = fill_it (obj)
                names = obj.propNamesIndep_';
                S = obj.scalarEmptyStructIndep_;
                for i=1:numel(names)
                    S.(names{i}) = obj.(names{i});
                end
            end
            
        end
        
        function S = structPublic(obj)
            % Return the public properties of an object as a structure
            %
            %   >> s = structPublic(obj)
            %
            % Use <a href="matlab:help('structArrPublic');">structArrPublic</a> to convert an object array to a structure array
            %
            % Has the same behaviour as struct in that
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            % - If the object is non-empty array, returns a scalar structure corresponding
            %   to the the first element in the array of objects
            %
            %
            % See also structIndep, structArrPublic, structArrIndep
            
            names = obj.propNamesPublic_';
            if ~isempty(obj)
                tmp = obj(1);
                S = obj.scalarEmptyStructPublic_;
                for i=1:numel(names)
                    S.(names{i}) = tmp.(names{i});
                end
            else
                args = [names; repmat({cell(size(obj))},size(names))];
                S = struct(args{:});
            end
        end
        
        function S = structArrPublic(obj)
            % Return the public properties of an object array as a structure array
            %
            %   >> s = structArrPublic(obj)
            %
            % Use <a href="matlab:help('structPublic');">structPublic</a> for behaviour that more closely matches the Matlab
            % intrinsic function struct.
            %
            % Has the same behaviour as the Matlab instrinsic struct in that:
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            %
            % However, differs in the behaviour if an object array:
            % - If the object is non-empty array, returns a structure array of the same
            %   size. This is different to the instrinsic Matlab, which returns a scalar
            %   structure from the first element in the array of objects
            %
            %
            % See also structPublic, structIndep, structArrIndep
            
            if numel(obj)>1
                S = arrayfun(@fill_it, obj);
            else
                S = structPublic(obj);
            end
            
            function S = fill_it (obj)
                names = obj.propNamesPublic_';
                S = obj.scalarEmptyStructPublic_;
                for i=1:numel(names)
                    S.(names{i}) = obj.(names{i});
                end
            end
            
        end
    end
    
    %======================================================================
    % Custom loadobj and saveobj
    % - to enable custom saving to .mat files and bytestreams
    % - to enable older class definition compatibility
    
    methods
        %------------------------------------------------------------------
        function S = saveobj(obj)
            % Method used my Matlab save function to support custom
            % conversion to structure prior to saving.
            %
            %   >> S = saveobj(obj)
            %
            % Input:
            % ------
            %   obj     Scalar instance of the object class
            %
            % Output:
            % -------
            %   S       Structure created from obj that is to be saved
            
            % The following is boilerplate code
            
            S = structIndep(obj);
        end
    end
    
    %------------------------------------------------------------------
    methods (Static)
        function obj = loadobj(S)
            % Static method used my Matlab load function to support custom
            % loading.
            %
            %   >> obj = loadobj(S)
            %
            % Input:
            % ------
            %   S       Either (1) an object of the class, or (2) a structure
            %           or structure array
            %
            % Output:
            % -------
            %   obj     Either (1) the object passed without change, or (2) an
            %           object (or object array) created from the input structure
            %       	or structure array)
            
            % The following is boilerplate code; it calls a class-specific function
            % called loadobj_private_ that takes a scalar structure and returns
            % a scalar instance of the class
            
            if isobject(S)
                obj = S;
            else
                obj = arrayfun(@(x)loadobj_private_(x), S);
            end
        end
        %------------------------------------------------------------------
        
    end
    %======================================================================
    
end
