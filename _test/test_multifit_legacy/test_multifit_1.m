classdef test_multifit_1< TestCaseWithSave
    % Performs a number of tests of syntax and equivalence of multifit and fit.
    % Optionally writes results to output file or tests output against stored output
    %
    %   >> runtests test_multifit_1  % Compares with previously saved results in test_multifit_1_output.mat
    %                                % in the same folder as this function
    %   >>save(test_multifit_1())    % Save to  c:\temp\test_multifit_1_output.mat
    %
    %   >>test_name(test_multifit_1()) % run particular test from this
    %                                    suite -- subsitute test_name to
    %                                    by the name of exisitng test
    %
    % Reads previously created test data in .\make_data\test_multifit_datasets_1.mat
    %
    % Author: T.G.Perring
    
    properties
        test_data_path;
        sd;  % source data for fitting
        pin; % input fitting parameters
        % data for test fitting
        data_filename='testdata_multifit_1.mat';
    end
    
    methods
        function this=test_multifit_1(varargin)
            % constructor
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            warning('off','MATLAB:unknownObjectNowStruct');
            clob = onCleanup(@()warning('on','MATLAB:unknownObjectNowStruct'));
            
            this = this@TestCaseWithSave(name,fullfile(fileparts(mfilename('fullpath')),'test_multifit_1_output.mat'));
            
            this.pin=[100,50,7,0,0];     % Note that it is assumed that these are good starting parameters for the fits
            
            rootpath=fileparts(mfilename('fullpath'));
            
            
            this.sd=load(fullfile(rootpath,this.data_filename));
            flds =fieldnames(this.sd);
            for i=1:numel(flds)
                fld = flds{i};
                if isstruct(this.sd.(fld)) &&  numel(fieldnames(this.sd.(fld))) == 7
                    this.sd.(fld) = IX_dataset_1d(this.sd.(fld));
                end
            end
%             flds =fieldnames(this.ref_data);
%             for i=1:numel(flds)
%                 fld = flds{i};
%                 if isstruct(this.ref_data.(fld)) &&  numel(fieldnames(this.ref_data.(fld))) == 7
%                     this.ref_data.(fld) = IX_dataset_1d(this.ref_data.(fld));
%                 end
%             end
            
        end
        
        
        % =====================================================================================================================
        %  Tests with single input data set
        % ======================================================================================================================
        function this=test_single_input(this)
            
            % Reference output
            % ----------------
            % Create reference output
            [y1_fref, wstruct1_fref, w1_fref, p1_fref] = mftest_mf_and_f_single_dataset (this.sd.x1,this.sd.y1,this.sd.e1,this.sd.wstruct1,this.sd.w1, @mftest_gauss_bkgd, this.pin);
            % Test it or store to save later
            this=save_or_test_variables(this,y1_fref, wstruct1_fref, w1_fref, p1_fref);
            
            % Slow convergence
            [y1_fslow, wstruct1_fslow, w1_fslow, p1_fslow] = mftest_mf_and_f_single_dataset (...
                this.sd.x1,this.sd.y1,this.sd.e1,this.sd.wstruct1,this.sd.w1, @mftest_gauss_bkgd, this.pin, [1,0,1,0,0]);
            % Test against saved or store to save later
            this=save_or_test_variables(this,y1_fslow, wstruct1_fslow, w1_fslow, p1_fslow);
            
            
            % Equivalence of split foreground and background functions with single function
            [y1_fsigfix, wstruct1_fsigfix, w1_fsigfix, p1_fsigfix] = mftest_mf_and_f_single_dataset (...
                this.sd.x1,this.sd.y1,this.sd.e1,this.sd.wstruct1,this.sd.w1,...
                @mftest_gauss_bkgd, this.pin, [1,0,1,1,1]);
            [y1_fsigfix_bk, wstruct1_fsigfix_bk, w1_fsigfix_bk, p1_fsigfix_bk] = mftest_mf_and_f_single_dataset (this.sd.x1,this.sd.y1,this.sd.e1,this.sd.wstruct1,this.sd.w1,...
                @mftest_gauss, this.pin(1:3), [1,0,1], @mftest_bkgd, this.pin(4:5));
            
            ltol=0;
            if ~equal_to_tol(y1_fsigfix,y1_fsigfix_bk,ltol)
                assertTrue(false,'Test failed: split foreground and background functions not equivalent to single function')
            end
            % Test against saved or store to save later
            this=save_or_test_variables(this,y1_fsigfix, wstruct1_fsigfix, w1_fsigfix, p1_fsigfix);
            this=save_or_test_variables(this,y1_fsigfix_bk, wstruct1_fsigfix_bk, w1_fsigfix_bk, p1_fsigfix_bk);
            
        end
        
        function this=test_binding(this)
            % Fix ratio of two of the foreground parameters
            prat=[6,0,0,0,0]; pbnd=[3,0,0,0,0];
            [y1_fbind1_ref, wstruct1_fbind1_ref, w1_fbind1_ref, p1_fbind1_ref] = mftest_mf_and_f_single_dataset (this.sd.x1,this.sd.y1,this.sd.e1,this.sd.wstruct1,this.sd.w1,...
                @mftest_gauss_bkgd_bind, [this.pin,prat,pbnd], [0,0,1,1,0,zeros(1,10)]);
            % Test against saved or store to save later
            this=save_or_test_variables(this,y1_fbind1_ref, wstruct1_fbind1_ref, w1_fbind1_ref, p1_fbind1_ref);
            
            [y1_fbind1_1, wstruct1_fbind1_1, w1_fbind1_1, p1_fbind1_1] = mftest_mf_and_f_single_dataset (this.sd.x1,this.sd.y1,this.sd.e1,this.sd.wstruct1,this.sd.w1,...
                @mftest_gauss, this.pin(1:3), [1,0,1], {1,3,0,6}, @mftest_bkgd, this.pin(4:5), [1,0]);
            % Test against saved or store to save later
            this=save_or_test_variables(this,y1_fbind1_1, wstruct1_fbind1_1, w1_fbind1_1, p1_fbind1_1);
            
            ltol=0;
            if ~equal_to_tol(y1_fbind1_ref,y1_fbind1_1,ltol)     % can only compare output y values - we've fudged the reference fit function, and parameters are not 'real'
                assertTrue(false,'Test failed: binding problem')
            end
            
            [y1_fbind1_2, wstruct1_fbind1_2, w1_fbind1_2, p1_fbind1_2] = mftest_mf_and_f_single_dataset (this.sd.x1,this.sd.y1,this.sd.e1,this.sd.wstruct1,this.sd.w1,...    % Same, but pick ratio from input ht and sig
                @mftest_gauss, [6*this.pin(3),this.pin(2:3)], [1,0,1], {1,3}, @mftest_bkgd, this.pin(4:5), [1,0]);
            % Test against saved or store to save later
            this=save_or_test_variables(this,y1_fbind1_2, wstruct1_fbind1_2, w1_fbind1_2, p1_fbind1_2);
            
            
            ltol=0;
            if ~equal_to_tol(y1_fbind1_ref,y1_fbind1_2,ltol)
                assertTrue(false,'Test failed: binding problem')
            end
        end
        
        function this=test_fix2background_foreground(this)
            % Fix ratio of two of the foreground, and two of the background parameters
            prat=[6,0,0,0.01,0]; pbnd=[3,0,0,5,0];
            [y1_fbind2_ref, wstruct1_fbind2_ref, w1_fbind2_ref, p1_fbind2_ref] = mftest_mf_and_f_single_dataset (...
                this.sd.x1,this.sd.y1,this.sd.e1,this.sd.wstruct1,this.sd.w1,...
                @mftest_gauss_bkgd_bind, [this.pin,prat,pbnd], [0,0,1,0,1,zeros(1,10)]);
            % test against saved or store to save later
            this=save_or_test_variables(this,y1_fbind2_ref, wstruct1_fbind2_ref, w1_fbind2_ref, p1_fbind2_ref);
            
            
            [y1_fbind2, wstruct1_fbind2, w1_fbind2, p1_fbind2] = mftest_mf_and_f_single_dataset (this.sd.x1,this.sd.y1,this.sd.e1,this.sd.wstruct1,this.sd.w1,...
                @mftest_gauss, this.pin(1:3), [1,0,1], {1,3,0,6}, @mftest_bkgd, this.pin(4:5),'', {{1,2,1,0.01}});
            % test against saved or store to save later
            this=save_or_test_variables(this,y1_fbind2, wstruct1_fbind2, w1_fbind2, p1_fbind2);
            
            ltol=0;
            if ~equal_to_tol(y1_fbind2_ref,y1_fbind2,ltol)     % can only compare output y values - we've fudged the reference fit function, and parameters are not 'real'
                assertTrue(false,'Test failed: binding problem')
            end
        end
        
        function this=test_fix_parameters_across(this)
            % Fix parameters across the foreground and background
            prat=[0,0,0.2,0,1/300]; pbnd=[0,0,4,0,2];
            [y1_fbind3_ref, wstruct1_fbind3_ref, w1_fbind3_ref, p1_fbind3_ref] = mftest_mf_and_f_single_dataset (this.sd.x1,this.sd.y1,this.sd.e1,this.sd.wstruct1,this.sd.w1,...
                @mftest_gauss_bkgd_bind, [100,50,5,20,0,prat,pbnd], [0,1,0,1,0,zeros(1,10)]);
            % Test against saved or store to save later
            this=save_or_test_variables(this,y1_fbind3_ref, wstruct1_fbind3_ref, w1_fbind3_ref, p1_fbind3_ref);
            
            
            [y1_fbind3, wstruct1_fbind3, w1_fbind3, p1_fbind3] = mftest_mf_and_f_single_dataset (this.sd.x1,this.sd.y1,this.sd.e1,this.sd.wstruct1,this.sd.w1,...
                @mftest_gauss, [100,50,5], [0,1,1], {3,1,1,0.2}, @mftest_bkgd, [20,0],'', {{2,2,0,1/300}});
            % Test against saved or store to save later
            this=save_or_test_variables(this,y1_fbind3, wstruct1_fbind3, w1_fbind3, p1_fbind3);
            
            ltol=0;
            if ~equal_to_tol(y1_fbind3_ref,y1_fbind3,ltol)  % can only compare output y values - we've fudged the reference fit function, and parameters are not 'real'
                assertTrue(false,'Test failed: binding problem')
            end
        end
        
        function this = test_more_binding_of_par(this)
            % Yet more binding of parameters
            prat=[2,0,0.2,0,1/300]; pbnd=[2,0,4,0,2];
            [y1_fbind4_ref, wstruct1_fbind4_ref, w1_fbind4_ref, p1_fbind4_ref] = mftest_mf_and_f_single_dataset (...
                this.sd.x1,this.sd.y1,this.sd.e1,this.sd.wstruct1,this.sd.w1,...
                @mftest_gauss_bkgd_bind, [100,50,5,20,0,prat,pbnd], [0,1,0,1,0,zeros(1,10)]);
            % Test against saved or store to save later
            this=save_or_test_variables(this,y1_fbind4_ref, wstruct1_fbind4_ref, w1_fbind4_ref, p1_fbind4_ref);
            
            [y1_fbind4, wstruct1_fbind4, w1_fbind4, p1_fbind4] = mftest_mf_and_f_single_dataset (...
                this.sd.x1,this.sd.y1,this.sd.e1,this.sd.wstruct1,this.sd.w1,...
                @mftest_gauss, [100,50,5], '', {{1,2},{3,1,1,0.2}}, @mftest_bkgd, [20,0],'', {{2,2,0,1/300}});
            ltol=0;
            if ~equal_to_tol(y1_fbind4_ref,y1_fbind4,ltol)  % can only compare output y values - we've fudged the reference fit function, and parameters are not 'real'
                assertTrue(false,'Test failed: binding problem')
            end
            
            % Test against saved or store to save later
            this=save_or_test_variables(this,y1_fbind4, wstruct1_fbind4, w1_fbind4, p1_fbind4);
            
            
        end
        
        % =====================================================================================================================
        % Test multiple datasets
        % ======================================================================================================================
        function this=test_multiple_ds_fail(this)
            ww_objarr=[this.sd.w1,this.sd.w2,this.sd.w3];
            [ww_fobjarr_f,pp_fobjarr,ok,mess] = mftest_mf_and_f_multiple_datasets(ww_objarr, @mftest_gauss_bkgd, this.pin);
            if ~ok, assertTrue(false,['Unexpected failure ',mess]), end
            % Test against saved or store to save later
            this=save_or_test_variables(this,ww_fobjarr_f,pp_fobjarr);
            
            
            ww_objcellarr={this.sd.w1,this.sd.w2,this.sd.w3};
            [ww_fobjcellarr_f,pp_fobjcellarr,ok,mess] = mftest_mf_and_f_multiple_datasets(ww_objcellarr, @mftest_gauss_bkgd, this.pin);
            if ~ok, assertTrue(false,['Unexpected failure ',mess]), end
            % Test against saved or store to save later
            this.ref_data.ww_fobjcellarr_f = cellfun(@IX_dataset_1d,this.ref_data.ww_fobjcellarr_f,'UniformOutput',false);
            this=save_or_test_variables(this,ww_fobjcellarr_f,pp_fobjcellarr);
            
            
            ww_structarr=[this.sd.wstruct1,this.sd.wstruct2,this.sd.wstruct3];
            [ww_fstructarr_f,pp_fstructarr,ok,mess] = mftest_mf_and_f_multiple_datasets(ww_structarr, @mftest_gauss_bkgd, this.pin);
            if ~ok, assertTrue(false,['Unexpected failure ',mess]), end
            % Test against saved or store to save later
            this=save_or_test_variables(this,ww_fstructarr_f,pp_fstructarr);
            
            
            ww_cellarr={this.sd.wstruct1,this.sd.w2,this.sd.wstruct3};
            [ww_fcellarr_f,pp_fcellarr,ok,mess] = mftest_mf_and_f_multiple_datasets(ww_cellarr, @mftest_gauss_bkgd, this.pin);
            if ok, assertTrue(false,['Should have failed, but did not',mess]), end
            % Test against saved or store to save later
            this=save_or_test_variables(this,ww_fcellarr_f,pp_fcellarr);
            
        end
        
    end
end
