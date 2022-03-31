classdef IX_detector_bank < serializable
    % Defines a detector bank for detectors of one type, for example, helium
    % tubes, or slab detectors. The object contains detector positional
    % information and the detector information for a detector bank of a single
    % detector type. 
    
    properties (Access=private)
        class_version_ = 1; % Class version number
        id_  = []        % Detector identificers, integers greater than 0 (column vector, in ascending order)
        x2_  = []        % Sample-detector distance (m) (column vector)
        phi_ = []        % Scattering angle (degrees, in range 0 to 180) (column vector)
        azim_= []        % Azimuthal angle (degrees) (column vector)
        dmat_= eye(3);  % Detector orientation matrix [3,3,ndet]
        det_ = IX_det_slab     % scalar object of IX_det_abstractType
    end
    
    properties (Dependent)
        % Detector identificers, integers greater than 0 (column vector, in ascending order)
        id
        % Sample-detector distance (m) (column vector)
        x2
        % Scattering angle (degrees, in range 0 to 180) (column vector)
        phi
        % Azimuthal angle (degrees) (column vector)
        % The sense of rotation is that sitting on the beamstop and looking at the
        % sample, azim = 0 is east, azim = 90 is north
        azim
        % Detector orientation matrix [3,3,ndet]
        % The matrix gives components in the secondary spectrometer coordinate
        % frame given those in the detector coordinate frame:
        %       xf(i) = Sum_j [D(i,j) xdet(j)]
        dmat
        % Detector objects (column vector)
        % Each element of the array gives the detector information. The class
        % inherits from IX_det_abstractType e.g. IX_det_He3tube
        det
        % Number of detectors (get access only):
        ndet
        
        % combined - all the above in one field
        % bypasses the expand_args_by_ref of the individual sets
        combined
    end

    properties(Constant,Access=private)
        % fields_to_save_ = {'id','x2','phi','azim', 'dmat', 'det', 'ndet'};
        fields_to_save_ = {'combined'};
    end
    


    methods
        %------------------------------------------------------------------
        % Constructor
        function obj = IX_detector_bank (id, x2, phi, azim, det, varargin)
            % Construct a detector bank
            %
            %   >> obj = IX_detector_bank (id, x2, phi, azim, detector_type)
            %
            %   >> obj = IX_detector_bank (..., 'rotvec', V)
            % *OR*
            %   >> obj = IX_detector_bank (..., 'dmat, D)
            %
            % Input:
            % ------
            % Required:
            %   id          Array of detector identifiers (integer values)
            %   x2          Sample - detector distances
            %   phi         Scattering angles (degrees) (in range 0 - 180 degrees)
            %   azim        Azimuthal angles (degrees)
            %   det         Object (or array of objects, one per detector) of a
            %              class that inherits IX_det_abstractType e.g. IX_det_He3tube
            %
            % Optional arguments defining detector orientations:
            %
            %   One and only one of the follow can be given. The default if none is
            %   The default if none is given is that the detector coordinate frame is
            %  the same as the secondary spectrometer coordinate frame i.e. the default
            %  is: 'dmat',eye(3)
            %
            %   'rotvec',V  Rotation vector(s) that gives the orientation of the detector
            %              coordinate frame(s) with respect to the secondary spectrometer
            %              frame.
            %               Vector length 3 or array size [3,ndet] (degrees).
            %               The detector frame is obtained by rotation according to the vector
            %              which has components in the secondary frame given by V
            %
            %   'dmat',D    Rotation matrix that gives components in secondary spectrometer
            %              coordinate frame given those in the detector coordinate frame:
            %                       xf(i) = Sum_j [D(i,j) xdet(j)]
            %               Array size [3,3] or [3,3,ndet]
            
            if nargin==0, return, end   % Default single detector
            
            % Parse detector orientation. Must have one and just one of the keyval
            % present, and no other parameters
            if numel(varargin)==0
                dmat = eye(3);
                ndet0 = 1;
            else
                types = det_orient_trans();
                if numel(varargin)==2 && is_string(varargin{1}) && ~isempty(varargin{1})
                    iout = stringmatchi(varargin{1},types);
                    if isscalar(iout)
                        [ok,mess,ndet0,dmat] = det_orient_trans (varargin{2}, types{iout}, 'dmat');
                        if ~ok, error(mess); end
                    else
                        error('Unrecognised or ambiguous orientation type')
                    end
                else
                    error('Must supply one and only one detector orientation description')
                end
            end
            
            % Check detector identifiers
            [ok,mess,ix] = is_integer_id(id);
            if ok
                ndet = numel(id);
                if ndet>=1
                    obj.id_ = id(:);
                else
                    error('There must be at least one detector identifier')
                end
            else
                error(['Detector ',mess])
            end
            
            % Check position coordinates
            [x2_exp, phi_exp, azim_exp] = expand_args_by_ref (id, x2, phi, azim);
            if isempty(ix)
                obj.x2_   = x2_exp;
                obj.phi_  = phi_exp;
                obj.azim_ = azim_exp;
            else
                obj.x2_   = x2_exp(ix);
                obj.phi_  = phi_exp(ix);
                obj.azim_ = azim_exp(ix);
            end
            
            % Check detector orientation
            if ndet==ndet0
                if ~isempty(ix)
                    obj.dmat_ = dmat(:,:,ix);
                else
                    obj.dmat_ = dmat;
                end
            elseif ndet0==1 % must have ndet>1, as scalar case already caught
                obj.dmat_ = repmat(dmat,[1,1,ndet]);
            else
                error('Number of detector orientations must be unity or match the number of detector identifiers')
            end
            
            % Check detector parameters
            obj.det_ = det;     % this assignment will check correct class of det
            if det.ndet==ndet
                if ~isempty(ix)
                    obj.det_  = obj.det_.reorder(ix);
                end
            elseif det.ndet==1  % must have ndet>1, as scalar case already caught
                obj.det_ = obj.det_.replicate(ndet);
            else
                error('Number of detectors must be unity or match the number of detector identifiers')
            end
            
        end
        %------------------------------------------------------------------
        % Set methods
        %
        % Test the validity where there is no dependency on other private properties
        
        function obj = set.id_(obj,val)
            % Will have put val through checks before reaching here, either in the
            % constructor or the setting of dependent property id
            obj.id_ = val;
        end
        
        function obj = set.x2_(obj,val)
            if all(val(:) >= 0)
                obj.x2_ = val(:);
            else
                error('Sample - detector distance(s) must be greater or equal to zero')
            end
        end
        
        function obj = set.phi_(obj,val)
            if all(val(:) >= 0) && all(val(:)<180)
                obj.phi_ = val(:);
            else
                error('Scattering angle(s) must lie in the range 0 inclusive to 180 degrees exclusive')
            end
        end
        
        function obj = set.azim_(obj,val)
            obj.azim_ = val(:);
        end
        
        function obj = set.dmat_(obj,val)
            % Will have put val through checks before reaching here, either in the
            % constructor or the setting of dependent property id
            obj.dmat_ = val;
        end
        
        function obj = set.det_(obj,val)
            if isa(val,'IX_det_abstractType') && isscalar(val)
                obj.det_ = val;
            else
                error('Detector type must be a single IX_det_abstractType object')
            end
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        %
        % Checks that rely on interdependencies must go here
        
        function val = get.combined(obj)
            val = struct();
            val.id = obj.id_;
            val.x2 = obj.x2_;
            val.phi = obj.phi_;
            val.azim = obj.azim_;
            val.dmat = obj.dmat_;
            val.det = obj.det_;
        end
        
        function obj = set.combined(obj,val)
            obj.id_ = val.id;
            obj.x2_ = val.x2;
            obj.phi_ = val.phi;
            obj.azim_ = val.azim;
            obj.dmat_ = val.dmat;
            obj.det_ = val.det;
        end
        
        function obj = set.id (obj,val)
            if numel(val)==numel(obj.id_)
                [ok,mess,ix] = is_integer_id(val);
                if ok
                    obj.id_ = val(:);
                    if ~isempty(ix)
                        obj.x2_   = x2_exp(ix);
                        obj.phi_  = phi_exp(ix);
                        obj.azim_ = azim_exp(ix);
                        obj.dmat_ = obj.dmat_(:,:,ix);
                        obj.det_  = obj.det_.reorder(ix);
                    end
                else
                    error(['Detector ',mess])
                end
            else
                error('The number of detector identifiers must match the current number')
            end
        end
        
        function obj=set.x2(obj,val)
            obj.x2_ = expand_args_by_ref (obj.x2_, val);
        end
        
        function obj=set.phi(obj,val)
            obj.phi_ = expand_args_by_ref (obj.phi_, val);
        end
        
        function obj=set.azim(obj,val)
            obj.azim_ = expand_args_by_ref (obj.azim_, val);
        end
        
        function obj=set.dmat(obj,val)
            [ok,mess,ndet0] = det_orient_trans (val, 'dmat');
            if ~ok, error(mess), end
            
            if ok
                if obj.ndet == ndet0
                    obj.dmat_ = val;
                elseif ndet0==1
                    obj.dmat_ = repmat(val,[1,1,obj.ndet]);
                else
                    error('Number of detector orientations must be scalar or match the number of detector identifiers')
                end
            else
                error(mess)
            end
        end
        
        function obj=set.det(obj,val)
            obj.det_ = val;     % checks correct type
            if val.ndet~=obj.ndet
                if val.ndet==1
                    obj.det_ = val.replicate(obj.ndet);
                else
                    error('The number of detectors must match be unity or equal the number of detector identifiers')
                end
            end
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val = get.id(obj)
            val = obj.id_;
        end
        
        function val = get.x2(obj)
            val = obj.x2_;
        end
        
        function val = get.phi(obj)
            val = obj.phi_;
        end
        
        function val = get.azim(obj)
            val = obj.azim_;
        end
        
        function val = get.dmat(obj)
            val = obj.dmat_;
        end
        
        function val = get.det(obj)
            val = obj.det_;
        end
        
        function val = get.ndet(obj)
            val = obj.det_.ndet;
        end
        
        %------------------------------------------------------------------
        
    end
    methods
            % SERIALIZABLE interface
        %------------------------------------------------------------------
        function ver  = classVersion(~)
            % define version of the class to store in mat-files
            % and nxsqw data format. Each new version would presumably read
            % the older version, so version substitution is based on this
            % number
            ver = 1;
        end
        %
        function flds = indepFields(~)
            % get independent fields, which fully define the state of the
            % serializable object.
            flds = IX_detector_bank.fields_to_save_;
        end
    end
    

    
    %{
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
    %}
    %======================================================================
    % Custom loadobj and saveobj
    % - to enable custom saving to .mat files and bytestreams
    % - to enable older class definition compatibility

    methods
        %{
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
        %}
    end
    
    %------------------------------------------------------------------
    methods (Static)
        %{
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
        %}
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class 
            obj = IX_detector_bank();
            obj = loadobj@serializable(S,obj);
        end
        %------------------------------------------------------------------
        
    end
    %======================================================================
    
end
