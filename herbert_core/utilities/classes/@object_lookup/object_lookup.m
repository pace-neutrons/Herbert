classdef object_lookup
    % Optimised lookup table for a set of arrays of objects.
    %
    % The purpose of this class is twofold:
    %
    %   (1) To minimise memory requirements by retaining only unique instances
    %       of the objects in the set of arrays;
    %   (2) To optimise the speed of selection of random points, or the speed
    %       of function evaluations, for an array of indices into one of the
    %       original object arrays in the set of object arrays. The optimisation
    %       arises when the array contains large numbers of repeated indices,
    %       that is, when the number of indices is much larger than the number
    %       of unique objects.
    %
    % For the indexed random number generation capability there must be a method
    % of the input object called rand that returns random points from the object.
    %
    %
    % Relationship to pdf_table_lookup:
    % ---------------------------------
    % This class has similarities to <a href="matlab:help('pdf_table_lookup');">pdf_table_lookup</a>, which is specifically
    % for random number generation. That class provides random sampling from a
    % set of arrays of one-dimensional probability distribution functions.
    % This class is more general because random sampling that results in a vector
    % or array is supported, for example when the object method rand suplies a set
    % of points in a 3D volume.
    %
    % The reason for using this class rather than pdf_table_lookup is when one or
    % more of the following apply:
    %   (1) The main purpose is to compress the memory to keep only unique objects;
    %   (2) The pdf is multi-dimensional, or there is no object method called pdf_table;
    %   (3) Indexed evaluation of other methods or functions may be needed.
    %
    % object_lookup Methods:
    %
    % The primary public methods are:
    %   object_lookup   - constructor
    %
    %   object_array    - retrieve a given object array from the set of object arrays
    %   object_elements - retrieve one or more elements from a given object array in the set
    %
    %   func_eval       - evaluate a method or function for indexed occurences in the object_lookup
    %   func_eval_ind   - evaluate a method or function for indexed occurences in the object_lookup
    %                     with indexed function arguments too
    %   rand_ind        - generate random points for indexed occurences in object_lookup
    %
    % See also pdf_table_lookup

    properties (Access=private)
        % Class version number
        class_version_ = 1;

        % Object array (column vector)
        object_store_ = []

        % Cell array of sizes of original object arrays
        sz_ = cell(0,1)

        % Index array (column vector)
        % Cell array of indices into the object_store_, where
        % ind{i} is a column vector of indices for the ith object array.
        % The length of ind{i} = number of objects in the ith object array
        indx_ = cell(0,1)
    end

    properties (Dependent)
        % Object array of unique instance of objects in the input array or cell array
        object_store

        % Cell array of indices into object_store.
        % ind{i} is a column vector of indices for the ith object array.
        % The length of ind{i} = number of objects in the ith object array
        indx

        % True or false according as the object containing one or more pdfs or not
        filled

    end

    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = object_lookup (objects)
            % Create object lookup from an array of objects
            %
            %   >> obj = object_lookup (objects)
            %
            % Input:
            % ------
            %   objects     Object array, or cell array of object arrays


            if nargin==1 && isstruct(objects)
                % Assume trying to initialise from a structure array of properties
                obj = object_lookup.loadobj(objects);

            elseif nargin>0

                % Make a cell array for convenience, if not already
                if ~iscell(objects)
                    objects = {objects};
                end

                % Check all arrays have the same class - requirement for sorting later on
                if numel(objects)>1
                    class_name = class(objects{1});
                    tf = cellfun(@(x)(strcmp(class(x),class_name)),objects);
                    if ~all(tf)
                        error('HERBERT:object_lookup:invalid_argument', 'The classes of the object arrays are not all the same')
                    end
                end

                % Assemble the objects in one array
                nw = numel(objects);
                nel = cellfun(@numel,objects(:));
                sz = cellfun(@size,objects(:),'uniformoutput',false);
                if any(nel==0)
                    error('HERBERT:object_lookup:invalid_argument', 'Cannot have any empty object arrays')
                end
                nend = cumsum(nel);
                nbeg = nend - nel + 1;
                ntot = nend(end);

                obj_all=repmat(objects{1}(1),[ntot,1]);
                for i=1:nw
                    obj_all(nbeg(i):nend(i))=objects{i}(:);
                end

                % Get unique entries
                if fieldsNumLogChar (obj_all, 'indep')
                    [obj_unique,~,ind] = uniqueObj(obj_all);    % simple object
                else
                    [obj_unique,~,ind] = genunique(obj_all,'resolve','indep');
                end

                % Fill lookup properties
                obj.object_store_ = obj_unique;
                obj.indx_ = mat2cell(ind,nel,1);
                obj.sz_ = sz;
            end

        end

        %------------------------------------------------------------------
        % Set methods for dependent properties

        function obj=set.object_store(obj,val)
            % Replace the object lookup table with another set of objects
            %
            %   >> obj.object_store = new_object_store
            %
            % The number of objects in new array must be scalar or match the
            % number in the current value of the property object_store.
            % - If scalar, then it is assumed that every object in the current
            %   array is to be replaced by a copy of the new object
            % - If array of same size as current object array, no check is
            %   made that the objects are unique. This will not cause an error,
            %   but calls to function evaluations or random point generation
            %   will not be as efficient as they could be.

            if numel(val)==numel(obj.object_store_) || isscalar(val)
                if numel(obj.object_store_)>0
                    if numel(val)==numel(obj.object_store_)
                        obj.object_store_ = val(:);
                    else
                        obj.object_store_ = repmat(val(:),size(obj.object_store_));
                    end
                else
                    % Force default null object_store if currently unassigned
                    null = object_lookup;
                    obj.object_store = null.object_store_;
                end
            else
                error('HERBERT:object_lookup:invalid_argument', 'Replacement for property ''object_store'' must be scalar or have the same number of objects')
            end
        end

        %------------------------------------------------------------------
        % Get methods for dependent properties

        function val=get.indx(obj)
            val=obj.indx_;
        end

        function val=get.object_store(obj)
            val=obj.object_store_;
        end

        function val=get.filled(obj)
            val=(numel(obj.object_store_)>0);
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
            %           or structure array)

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
