classdef test_loader_ascii< TestCase
    properties
        log_level;
        matlab_warning;
        test_data_path;
    end
    methods
        %
        function this=test_loader_ascii(name)
            if nargin<1
                name = 'test_loader_ascii';
            end
            this = this@TestCase(name);
            [~,tdp] = herbert_root();
            this.test_data_path = tdp;
        end
        function this=setUp(this)
            this.log_level = get(herbert_config,'log_level');
            set(herbert_config,'log_level',-1,'-buffer');
            this.matlab_warning = warning ('off','all');
        end
        function this=tearDown(this)
            set(herbert_config,'log_level',this.log_level,'-buffer');
            warning (this.matlab_warning);
        end
        
        % CONSTRUCTOR:
        % tests themself
        function test_wrong_first_argument(this)
            f = @()loader_ascii(10);
            % should throw; first argument has to be a file name
            assertExceptionThrown(f,'A_LOADER:invalid_argument');
        end
        
        function test_wrong_second_argument(this)
            f = @()loader_ascii(fullfile(this.test_data_path,'some_spe_file_which_was_checked_before.spe'),10);
            % should throw; third parameter has to be a file name
            assertExceptionThrown(f,'A_LOADER:invalid_argument');
        end
        function test_par_file_not_there(this)
            f = @()loader_ascii(fullfile(this.test_data_path,'some_spe_file_which_was_checked_before.spe'),...
                'missing_par_file.par');
            % should throw; par file do not exist
            assertExceptionThrown(f,'ASCIIPAR_LOADER:invalid_argument');
        end
        function test_spe_file_not_there(this)
            spe_file = fullfile(this.test_data_path,'missing_spe_file.spe');
            par_file = fullfile(this.test_data_path,'demo_par.par');
            f = @()loader_ascii(spe_file,par_file);
            % should throw; spe file does not exist
            assertExceptionThrown(f,'A_LOADER:invalid_argument');
        end
        function test_loader_defined(this)
            spe_file = fullfile(this.test_data_path,'MAP10001.spe');
            par_file = fullfile(this.test_data_path,'demo_par.par');
            ld = loader_ascii(spe_file,par_file);
            
            [~,fname,fext]= fileparts(ld.file_name);
            assertEqual([fname,fext],'MAP10001.spe');
            [~,fname,fext]= fileparts(ld.par_file_name);
            if ispc
                assertEqual([fname,fext],'demo_par.par');
            else
                assertEqual([fname,fext],'demo_par.PAR');
            end
        end
        % LOAD SPE
        function test_load_spe(this)
            loader=loader_ascii();
            % loads only spe data
            [S,ERR,en,loader]=load_data(loader,fullfile(this.test_data_path,'MAP10001.spe'));
            assertEqual(30*28160,numel(S))
            assertEqual(30*28160,numel(ERR))
            assertEqual(31,numel(en));
            [fpath,fname,fext]= fileparts(loader.file_name);
            assertEqual([fname,fext],'MAP10001.spe')
        end
        function test_load_spe_undefined_throws(this)
            loader=loader_ascii();
            % define spe file loader from undefined spe file
            f = @()load_data(loader);
            assertExceptionThrown(f,'LOAD_ASCII:load_data');
        end
        
        % DEFINED FIELDS
        function test_spe_fields_defined(this)
            spe_file = fullfile(this.test_data_path,'MAP10001.spe');
            loader=loader_ascii(spe_file);
            assertEqual({'S','ERR','en','n_detectors'},loader.defined_fields());
            
            loader.par_file_name =  fullfile(this.test_data_path,'demo_par.par');
            assertEqual({'S','ERR','en','n_detectors','det_par','n_det_in_par'},loader.defined_fields());
            
        end
        
        function test_par_fields_defined(this)
            loader=loader_ascii();
            par_file = fullfile(this.test_data_path,'demo_par.par');
            [~,loader]=load_par(loader,par_file);
            fields = get_par_defined(loader);
            assertEqual({'det_par','n_det_in_par'},fields);
            [~,fname,fext] = fileparts(loader.par_file_name);
            if ispc
                assertEqual([fname,fext],'demo_par.par');
            else
                assertEqual([fname,fext],'demo_par.PAR');
            end
            
        end
        %GET_RUN INFO:
        function test_get_run_info_no_par_file(this)
            loader=loader_ascii(fullfile(this.test_data_path,'spe_info_correspondent2demo_par.spe'));
            f = @()get_run_info(loader);
            assertExceptionThrown(f,'A_LOADER:runtime_error');
            % run info obtained from spe file
            loader.det_par = ones(6,28160);
            [ndet,en,this]=loader.get_run_info();
            assertEqual(28160,ndet);
            assertEqual(31,numel(en));
            assertEqual(en,this.en);
            
            assertTrue(~isempty(this.det_par));
            assertTrue(isempty(this.par_file_name));
        end
        function test_get_run_info_wrong_par(this)
            spe_file  = fullfile(this.test_data_path,'spe_info_correspondent2demo_par.spe');
            wrong_par = fullfile(this.test_data_path,'wrong_par.PAR');
            
            f = @()loader_ascii(spe_file,wrong_par);
            
            %f = @()get__info(loader);
            assertExceptionThrown(f,'ASCIIPAR_LOADER:invalid_argument');
        end
        function test_get_run_info_wrong_spe(this)
            wrong_spe = fullfile(this.test_data_path,'spe_wrong.spe');
            wrong_par = fullfile(this.test_data_path,'demo_par.par');
            
            f =@()loader_ascii(wrong_spe,wrong_par);
            assertExceptionThrown(f,'LOADER_ASCII:invalid_argument');
        end
        function test_get_run_info_inconsistent2spe(this)
            inconsistent_spe = fullfile(this.test_data_path,'spe_info_insonsistent2demo_par.spe');
            demo_par = fullfile(this.test_data_path,'demo_par.par');
            
            loader=loader_ascii(inconsistent_spe,demo_par);
            
            f = @()get_run_info(loader);
            % inconsistent spe and par files
            assertExceptionThrown(f,'A_LOADER:runtime_error');
        end
        function test_get_run_info_OK(this)
            SPE_file=fullfile(this.test_data_path,'spe_info_correspondent2demo_par.spe');
            PAR_file=fullfile(this.test_data_path,'demo_par.par');
            loader=loader_ascii(SPE_file,PAR_file);
            [ndet,en,loader]=get_run_info(loader);
            assertEqual(28160,ndet);
            assertEqual(31,numel(en));
            % assertEqual(ndet,loader.n_detectors)
            assertEqual(en,loader.en);
        end
        % DEAL WITH NAN
        function test_loader_ASCII_readsNAN(this)
            % reads symbolic NaN-s and agreed -1e+30 NaNs
            % from ascii file and transforms them into ISO NaN in memory
            loader=loader_ascii(fullfile(this.test_data_path,'spe_with_NANs.spe'));
            [S,ERR,en]=load_data(loader);
            % load all correctly
            assertEqual(size(S),[30,5]);
            assertEqual(size(S),size(ERR));
            assertEqual(size(en),[31,1]);
            % find ISO NaN-s
            mask=isnan(S);
            % check if they are all in right place, defined in 'spe_with_NANs.spe'
            assertEqual(mask(1:2,1),logical(ones(2,1)))
            assertEqual(mask(:,5),logical(ones(30,1)));
        end
        function test_get_data_info(this)
            spe_file_name = fullfile(this.test_data_path,'MAP10001.spe');
            [ndet,en,file_name]=loader_ascii.get_data_info(spe_file_name);
            
            assertEqual([31,1],size(en));
            assertEqual(28160,ndet);
            assertEqual(spe_file_name,file_name);
        end
        
        function test_can_load_and_init(this)
            spe_file_name = fullfile(this.test_data_path,'MAP10001.spe');
            other_file_name = fullfile(this.test_data_path,'MAP11014.nxspe');
            
            
            [ok,mess]=loader_ascii.can_load(other_file_name);
            assertTrue(~ok);
            assertEqual(' The extension .nxspe of file: MAP11014 is not among supported extensions',mess);
            
            [ok,fh]=loader_ascii.can_load(spe_file_name);
            assertTrue(ok);
            assertTrue(~isempty(fh));
            
            
            la = loader_ascii();
            la=la.init(spe_file_name,fh);
            
            [ndet,en,file_name]=loader_ascii.get_data_info(spe_file_name);
            assertEqual(en,la.en);
            assertEqual(file_name,la.file_name);
            
            f=@()la.get_run_info();
            assertExceptionThrown(f,'A_LOADER:runtime_error');
            
            par_file_name =fullfile(this.test_data_path,'demo_par.par');
            la.par_file_name = par_file_name;
            [ndet1,en1] = la.get_run_info();
            
            assertEqual(en,en1);
            assertEqual(ndet,ndet1);
        
        end
        function test_an_load_and_init_all(this)
            spe_file_name = fullfile(this.test_data_path,'MAP10001.spe');
            par_file_name =fullfile(this.test_data_path,'demo_par.par');
            
            [ok,fh] = loader_ascii.can_load(spe_file_name);
            assertTrue(ok);
            
            la = loader_ascii();
            la=la.init(spe_file_name,par_file_name,fh);
            
            [ndet,en]=la.get_run_info();
            assertEqual(28160,ndet);
            assertEqual(31,numel(en));
            
        end
        %
        function test_init_all(this)
            spe_file_name = fullfile(this.test_data_path,'MAP10001.spe');
            par_file_name =fullfile(this.test_data_path,'demo_par.par');
            
            la = loader_ascii();
            la=la.init(spe_file_name,par_file_name);
            
            [ndet,en]=la.get_run_info();
            assertEqual(28160,ndet);
            assertEqual(31,numel(en));
            
        end
        
        
        function test_get_file_extension(this)
            fext=loader_ascii.get_file_extension();
            
            assertEqual(fext,'.spe');
            assertEqual(4,numel(fext));
        end
        function test_is_loader_defined(this)
            spe_file_name = fullfile(this.test_data_path,'MAP10001.spe');
            par_file_name =fullfile(this.test_data_path,'demo_par.par');
            
            la = loader_ascii(spe_file_name,par_file_name );
            
            %f = @()get_run_info(loader);
            [ok,mess]=la.is_loader_valid();
            assertEqual(1,ok);
            assertEqual('',mess);
            
            la=la.load_data();
            [ok,mess]=la.is_loader_valid();
            assertEqual(1,ok);
            assertEqual('',mess);
            
            [par,la]=la.load_par();
            
            [ok,mess]=la.is_loader_valid();
            assertEqual(1,ok);
            assertEqual('',mess);
        end
        
        function test_load_phx(this)
            
        end
        
        
    end
end
