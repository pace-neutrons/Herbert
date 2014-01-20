classdef a_loader < asciipar_loader;
    % Base class for all data loaders used by the rundata class and
    % loaders_factory
    %
    % Defines the interface for all common methods, used by loaders
    %
    % A new particular loader should define all abstract methods defined by this
    % loader and register new loader with the loaders_factory class.
    %
    % If the main data file contains detector information, new loader should also
    % overload methods responsible for loading detector's information to work
    % both with ASCII par files and the detector information containing in
    % the main data file (if the later intended to be used). These methods
    % are defined in asciipar_loader.
    %
    % When overloading abstract methods, a new loader should use (set/get)
    % protected data properties as public properties for
    % data variables ensure integrity of variables (waste of time when
    % loading from file)
    %
    % $Author: Alex Buts; 05/01/2014
    %
    %
    % $Revision$ ($Date$)
    %
    % the properties common for all data loaders.
    properties(Dependent)
        % number of detectors in par file or in data file (should be
        % consistent if both are present;
        n_detectors=[];
        % signal
        S     = [];
        % error
        ERR   = [];
        % energy boundaries
        en   = [];
        % the variable which describes the file from which main part or
        % all data should be loaded
        file_name='';
    end
    
    properties(Access=protected)
        % number of detectors defined by data file (e.g. second dimension
        % of SPE Signal array)
        n_detindata_stor=[];
        % Internal Signal array
        S_stor=[];
        % Internal Error array
        ERR_stor=[];
        % internal energy bins array
        en_stor=[];
        % name of data file to load data from
        data_file_name_stor='';
        % the data fields which are defined in the main data file
        loader_defines={};
    end
    %
    methods(Abstract, Static)
        [ok,fh] = can_load(file_name);
        % method checks if the file_name can be processed by this file loader
        %
        %>>[is,fh]=loader.can_load(file_name)
        % Input:
        % file_name -- the name of the file to check
        % Output:
        %
        % is -- True if the file can be processed by the loader
        % fh -- (optional) the information which accelerates work with file
        %        recognized as suitable for a loader e.g. open file handle
        %        for an ASCII file to load. This information is used by
        %        loader's init function.
        [ndet,en,varargout]=get_data_info(file_name);
        % get information about spe-part of data defined in the data file
        % namely number of detectors and the energy bins
        %
        descr=get_file_description();
        % get the description of the file format, (e.g. used in GUI)
        %
        fext=get_file_extension();
        % returns the file extension used by this loader
    end
        %------------------------------------------------------------------
        % A_LOADER Interface:
        %------------------------------------------------------------------
    
    methods(Abstract)
        [varargout]=load_data(this,varargin);
		% Load main data defined for the loader. (e.g. Signal and Error)
		% Expected interface:
		%>>this=load_data(this,varargin);             1)
		%>>[S,ERR]=load_data(this,varargin);          2)
		%>>[S,ERR,en]=load_data(this,varargin);       3)
		%>>[S,ERR,en,this]=load_data(this,varargin);  4)
		% 
		% the class instance has to be present in the RHS of the load_data statement in form 1 or 4
        % if one wants to load data into the the class memory itself.
		% forms 2) and 3) just load and return signal, error and energy bins if possible. 
        %
        %
        %
        
        this=init(this,data_file_name,varargin);
        % the method performs the initialization of the main part of the constructor.
		%
        % Invoked separately it initializes a loader, defined by empty constructor.
        %
        % Common constructor of a specific loader the_loader should have the form similar to
        % the following:
        %
        % function this = the_loader(data_file,par_file,varargin)
        %   this =the_loader@a_loader(par_file);
        %   this=this.init(data_file,varargin);
        % end
		% See loader_ascii or loader_nxspe for actual example of init method and the constructor. 

        this=set_data_info(this,file_name);
        % method sets internal file information obtained for appropriate file
        % by get_data_info method into internal class memory. 
    end
    
    methods
        % constructor;
        function this=a_loader(varargin)
            % initiate the list of the fields this loader defines
            %>>Accepts:
            %   default empty constructor:
            %>>this=a_loader();
            %   constructor, which specifies par file name:
            %>>this=a_loader(par_file_name);
            %   copy constructor:
            %>>this=a_loader(other_loader);
            %
            this=this@asciipar_loader(varargin{:});
        end
        function [ndet,en,this]=get_run_info(this)
            % Get number of detectors and energy boundaries defined by the data files
            % and detector files processed by this class instance
			%
            % The definition can be both in data and detector part of the file
			% and this method checks if these data are consistent. 
            %
            % >> [ndet,en] = get_par_info(the_loader)
            
            %  the_loader     -- is the instance of  a particular loader with initiated file.
            %  ndet            -- number of detectors defined in par&data file
            %  en              -- energy boundaries, defined in data file (e.g. spe file);
            %
            %
            
            [ok,mess,ndet,en] = is_loader_valid(this);
            if ok<1
                error('A_LOADER:get_run_info',mess);
            end
            
            if isempty(this.en)
                this.en_stor = en;
            end
            if isempty(this.n_detectors)
                this.n_detectors = ndet;
            end
        end
        %
        function fields = loader_can_define(this)
            % what fields loader can actually define
            fields = this.loader_defines;
            if ~isempty(this.par_file_name)
                par_fields = this.par_can_define();
                not_in_loader = ~ismember(par_fields,fields);
                fields = [fields,par_fields{not_in_loader}];
            end
        end
        %
        function fields = defined_fields(this)
            % the method returns the cellarray of fields names,
            % which are defined by current instance of loader class
            %
            % e.g. loader_ascii defines {'S','ERR','en','n_detectrs} if par file is not defined and
            % {'S','ERR','en','det_par'} if it is defined and loader_nxspe defines
            % {'S','ERR','en','det_par','efix','psi'}(if psi is set up)
            %usage:
            %>> fields= defined_fields(loader);
            %   loader -- the specific loader constructor
            %
            
            % the method returns the cellarray of fields names, which are
            % defined by ascii spe file and par file if present
            %usage:
            %>> fields= defined_fields(loader);
            %
            fields = check_defined_fields(this);
        end
        %
        function this=delete(this)
            % delete all memory demanding data/fields from memory and close all
            % open files (if any)
            %
            % loader class has to be present in RHS to propagate the changes
            % Deleter is generic until loaders fields are generic. Any specific
            % deleter should be overloaded
            %
            %
            this.S_stor = [];
            this.ERR_stor = [];
            if isempty(this.data_file_name_stor)
                this.en_stor=[];
                this.n_detindata_stor=[];
            end
            this=this.delete_par();
        end
        function [ok,mess,ndet,en]=is_loader_valid(this)
            % method checks if a loader is fully defined and valid
            %Usage:
            %[ok,message,ndet,en]=loader.is_loader_valid();
            %
            %ok =  -1 if loader is undefined,
            %         0 if it is incosistant (e.g size(S) ~= size(ERR)) or size(en,1)
            %         ~=size(S,2) etc...
            %
            % if ok =1, intenal ndet and en fields are defined. This method can not
            % be invoked for a_loader, as uses abstract class methods,
            % defined by particular loaders
            [ok,mess,ndet,en] = is_loader_valid_internal(this);
        end
        
        function this=load(this,varargin)
            % load all information, stored in data and par files into
            % memory
            %usage:
            %loader = load(loader,['-keepexisting'])
            %
            %presumes that data file name and par file name (if necessary)
            %are already set up
            % -keepexisting  if option is present, method does not load/overwrite
            %                data, already loaded in memory if these data are consistent with 
			%                the data defined by the file. 
            %
            options = {'-keepexisting'};
            [ok,mess,keepexising]=parse_char_options(varargin,options);
            if ~ok
                error('A_LOADER:load',mess);
            end
            if keepexising
                [s_empty,err_empty,dat_empty,det_empty] = data_empty(this);
                if dat_empty
                    [S,ERR,en]=this.load_data();
                    this.en_stor = en;
                    if s_empty
                        this.S_stor = S;
                    end
                    if err_empty
                        this.ERR_stor = ERR;
                    end
                    this.n_detindata_stor = size(S,2);
                end
                if det_empty
                    [~,this]=this.load_par();
                end
                [ok,mess]=is_loader_valid(this);
                if ~ok
                    error('A_LOADER:load',mess);
                end
            else
                this=this.load_data();
                [~,this]=this.load_par();
            end
        end
        %
        function this=saveNXSPE(this,filename,efix,psi)
            % method to save loaders data stored in memory as nxspe file
            
            % filename -- the name of the file to write data to. Should not exist
            % efix     -- incident energy for direct or indirect instrument. Only
            %             direct is currently supported through NEXUS instrument
            % Optional variables:
            % psi      -- the rotation angle of crystal. will be NaN if absent
            %
            
            this=load(this,'-keep');
            save_nxspe_internal(this,filename,efix,psi);
        end
        % -----------------------------------------------------------------
        % ---- SETTERS GETTERS FOR CLASS PROPERTIES     -------------------
        % -----------------------------------------------------------------
        function this=set.file_name(this,new_name)
            % method checks if a file with the name file_name exists
            %
            % Then it sets this file name as the source data file name,
            % reads file info, calculates all dependent information and
            % clears all previously loaded run information
            % (if any) inconsistent with the new file or occupying substantial
            % memory.
            
            if isempty(new_name)
                % disconnect detector information in memory from a par file
                this.file_name_stor = '';
                if isempty(this.S_stor)
                    this.en_stor = [];
                    this.n_detindata_stor=[];
                end
            else
                [ok,mess,f_name] = check_file_exist(this,new_name);
                if ~ok
                    error('A_LOADER:set_file_name',mess);
                end
            end
            if ~strcmp(this.data_file_name_stor,f_name)
                this= this.delete();
                this=this.set_data_info(f_name);
            else
                return
            end
        end
        %
        function filename = get.file_name(this)
            % returns actual data file name, which is the source of the data, 
			% this class instance is responsible for. 
			
            filename = this.data_file_name_stor;
        end
        %
        function ndet = get.n_detectors(this)
            %method to get number of detectors
            ndet = this.n_detinpar_stor;
            if isempty(ndet)
                ndet = this.n_detindata_stor;
            else
                if ~isempty(this.n_detindata_stor)
                    if this.n_detindata_stor ~= this.n_detinpar_stor
                        ndet = 'n_det from par file ~= n_det from data file';
                    end
                end
            end
        end
        %
        function S = get.S(this)
            % get signal if all signal&error&energy fields are well defined
            S = get_consistent_array(this,'S_stor');
        end
        %
        function this = set.S(this,value)
            % set signal value consistent with error value
            this = set_consistent_array(this,'S_stor',value);
        end
        %
        function ERR = get.ERR(this)
            % get error if all signal&error&energy fields are well defined
            ERR = get_consistent_array(this,'ERR_stor');
        end
        %
        function this = set.ERR(this,value)
            % set error consistent with signal value
            % disabled: and break connection between the error and the
            % data file if any
            this = set_consistent_array(this,'ERR_stor',value);
        end
        %
        function en = get.en(this)
            % get energy bins
            en = this.en_stor;
        end
        %
        function this = set.en(this,value)
            % set energy bin boundaries. 
            sv = size(value);
            if sv(1) == 1 && sv(2)>1
                value = value';
            end
            this = set_consistent_array(this,'en_stor',value);
        end
        % ------------------------------------------------------------------
        function [ok,mess,f_name]=check_file_exist(this,new_name)
            % method to check if file with extension correspondent to this
            % loader exists. Make public for easy overloading and work with memfiles.           
            [ok,mess,f_name] = check_file_exist(new_name,this.get_file_extension());
        end
    end
    
end
