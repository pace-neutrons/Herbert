classdef test_multifit_1 < TestCaseWithSave
    % Performs a number of tests of syntax of multifit
    % Optionally writes results to output file or tests output against stored output
    %
    %   >> runtests test_multifit_1         % Compares with previously saved results in
    %                                       % test_multifit_1_output.mat
    %                                       % in the same folder as this function
    %
    %   >> test_multifit_1('-save)          % Save to test_multifit_1_output.mat
    %                                       % in the Matlab temporary folder (copy to
    %                                       % the same folder as this function after)
    %
    %   >> runtests test_multifit_1:<test_func> % run a particular test from this
    %                                       % this test suite
    %
    % Author: T.G.Perring

    properties
        source_data    % source data for fitting
        pin     % input fitting parameters
        ref     % reference data
    end

    methods
        function obj=test_multifit_1(name)
            % Construct object
            output_file = 'test_multifit_1_output.mat';
            obj = obj@TestCaseWithSave(name, output_file);

            obj.pin=[100,50,7,0,0];     % Note that it is assumed that these are good starting parameters for the fits

            % Read in data
            data_dir = fileparts(mfilename('fullpath'));
            obj.source_data = load(fullfile(data_dir,'testdata_multifit_1.mat'));

            % Turn structures in IX_dataset_1d objects if they have the appropriate number of fields
            flds =fieldnames(obj.source_data);
            for i=1:numel(flds)
                fld = flds{i};
                if isstruct(obj.source_data.(fld)) &&  numel(fieldnames(obj.source_data.(fld))) == 7
                    obj.source_data.(fld) = IX_dataset_1d(obj.source_data.(fld));
                end
            end

            % Save output, if requrested
            obj.save();

            ref = multifit(obj.source_data.w1);
            ref = ref.set_fun(@mftest_gauss_bkgd);
            ref = ref.set_pin(obj.pin);
            [obj.ref.fit, obj.ref.param] = ref.fit();

        end

        % =========================================================================================
        %  Tests with single input data set
        % =========================================================================================
        function obj = test_single_xye(obj)
            mf = multifit(obj.source_data.x1, obj.source_data.y1, obj.source_data.e1);
            mf = mf.set_fun(@mftest_gauss_bkgd);
            mf = mf.set_pin(obj.pin);
            [wout, fitpar] = mf.fit();
            assertEqualToTol(wout', obj.ref.fit.signal, obj.tol);
            assertEqualToTol(fitpar, obj.ref.param, obj.tol);
        end

        function obj = test_single_struct(obj)
            mf = multifit(obj.source_data.wstruct1);
            mf = mf.set_fun(@mftest_gauss_bkgd);
            mf = mf.set_pin(obj.pin);
            [wout, fitpar] = mf.fit();
            assertEqualToTol(wout.y', obj.ref.fit.signal, obj.tol);
            assertEqualToTol(fitpar, obj.ref.param, obj.tol);
        end

        function obj=test_single_input(obj)
            data = obj.source_data;    % abbreviate for clarity on the code

            % Reference output
            % ----------------
            % Create reference output
            [y1_fref, wstruct1_fref, w1_fref, p1_fref] = mftest_mf_and_f_single_dataset (...
                data.x1, data.y1, data.e1, data.wstruct1, data.w1,...
                @mftest_gauss_bkgd, obj.pin);

            % Test it or store to save later
            tol = [1e-10,1e-8];
            assertEqualToTolWithSave (obj, y1_fref, 'tol', tol)
            assertEqualToTolWithSave (obj, wstruct1_fref, 'tol', tol)
            assertEqualToTolWithSave (obj, w1_fref, 'tol', tol)
            assertEqualToTolWithSave (obj, p1_fref, 'tol', tol)

            % Slow convergence
            % ----------------
            [y1_fslow, wstruct1_fslow, w1_fslow, p1_fslow] = mftest_mf_and_f_single_dataset (...
                data.x1, data.y1, data.e1, data.wstruct1, data.w1,...
                @mftest_gauss_bkgd, obj.pin, [1,0,1,0,0]);

            % Test against saved or store to save later
            tol = [1e-10,1e-8];
            assertEqualToTolWithSave (obj, y1_fslow, 'tol', tol)
            assertEqualToTolWithSave (obj, wstruct1_fslow, 'tol', tol)
            assertEqualToTolWithSave (obj, w1_fslow, 'tol', tol)
            assertEqualToTolWithSave (obj, p1_fslow, 'tol', tol)


            % Equivalence of split foreground and background functions with single function
            % -----------------------------------------------------------------------------
            [y1_fsigfix, wstruct1_fsigfix, w1_fsigfix, p1_fsigfix] = mftest_mf_and_f_single_dataset (...
                data.x1, data.y1, data.e1, data.wstruct1, data.w1,...
                @mftest_gauss_bkgd, obj.pin, [1,0,1,1,1]);

            [y1_fsigfix_bk, wstruct1_fsigfix_bk, w1_fsigfix_bk, p1_fsigfix_bk] = mftest_mf_and_f_single_dataset (...
                data.x1, data.y1, data.e1, data.wstruct1, data.w1,...
                @mftest_gauss, obj.pin(1:3), [1,0,1], @mftest_bkgd, obj.pin(4:5));

            ltol=0;
            if ~equal_to_tol(y1_fsigfix,y1_fsigfix_bk,ltol)
                assertTrue(false,'Test failed: split foreground and background functions not equivalent to single function')
            end

            % Test against saved or store to save later
            tol = [1e-10,1e-8];
            assertEqualToTolWithSave (obj, y1_fsigfix, 'tol', tol)
            assertEqualToTolWithSave (obj, wstruct1_fsigfix, 'tol', tol)
            assertEqualToTolWithSave (obj, w1_fsigfix, 'tol', tol)
            assertEqualToTolWithSave (obj, p1_fsigfix, 'tol', tol)

            assertEqualToTolWithSave (obj, y1_fsigfix_bk, 'tol', tol)
            assertEqualToTolWithSave (obj, wstruct1_fsigfix_bk, 'tol', tol)
            assertEqualToTolWithSave (obj, w1_fsigfix_bk, 'tol', tol)
            assertEqualToTolWithSave (obj, p1_fsigfix_bk, 'tol', tol)

        end

        %------------------------------------------------------------------------------------------
        function obj=test_binding(obj)
            data = obj.source_data;    % abbreviate for clarity on the code

            % ---------------------------------------------
            prat=[6,0,0,0,0]; pbnd=[3,0,0,0,0];
            [y1_fbind1_ref, wstruct1_fbind1_ref, w1_fbind1_ref, p1_fbind1_ref] = mftest_mf_and_f_single_dataset...
                (data.x1,data.y1,data.e1,data.wstruct1,data.w1,...
                @mftest_gauss_bkgd_bind, [obj.pin,prat,pbnd], [0,0,1,1,0,zeros(1,10)]);

            % Test against saved or store to save later
            tol = [1e-10,1e-8];
            assertEqualToTolWithSave (obj, y1_fbind1_ref, 'tol', tol)
            assertEqualToTolWithSave (obj, wstruct1_fbind1_ref, 'tol', tol)
            assertEqualToTolWithSave (obj, w1_fbind1_ref, 'tol', tol)
            assertEqualToTolWithSave (obj, p1_fbind1_ref, 'tol', tol)

            % ---------------------------------------------
            [y1_fbind1_1, wstruct1_fbind1_1, w1_fbind1_1, p1_fbind1_1] = mftest_mf_and_f_single_dataset...
                (data.x1,data.y1,data.e1,data.wstruct1,data.w1,...
                @mftest_gauss, obj.pin(1:3), [1,0,1], {1,3,6}, @mftest_bkgd, obj.pin(4:5), [1,0]);

            % Test against saved or store to save later
            tol = [1e-10,1e-8];
            assertEqualToTolWithSave (obj, y1_fbind1_1, 'tol', tol)
            assertEqualToTolWithSave (obj, wstruct1_fbind1_1, 'tol', tol)
            assertEqualToTolWithSave (obj, w1_fbind1_1, 'tol', tol)
            assertEqualToTolWithSave (obj, p1_fbind1_1, 'tol', tol)

            ltol=0;
            if ~equal_to_tol(y1_fbind1_ref,y1_fbind1_1,ltol)     % can only compare output y values - we've fudged the reference fit function, and parameters are not 'real'
                assertTrue(false,'Test failed: binding problem')
            end

            % ---------------------------------------------
            [y1_fbind1_2, wstruct1_fbind1_2, w1_fbind1_2, p1_fbind1_2] = mftest_mf_and_f_single_dataset...
                (data.x1,data.y1,data.e1,data.wstruct1,data.w1,...    % Same, but pick ratio from input ht and sig
                @mftest_gauss, [6*obj.pin(3),obj.pin(2:3)], [1,0,1], {1,3}, @mftest_bkgd, obj.pin(4:5), [1,0]);

            % Test against saved or store to save later
            tol = [1e-10,1e-8];
            assertEqualToTolWithSave (obj, y1_fbind1_2, 'tol', tol)
            assertEqualToTolWithSave (obj, wstruct1_fbind1_2, 'tol', tol)
            assertEqualToTolWithSave (obj, w1_fbind1_2, 'tol', tol)
            assertEqualToTolWithSave (obj, p1_fbind1_2, 'tol', tol)

            ltol=0;
            if ~equal_to_tol(y1_fbind1_ref,y1_fbind1_2,ltol)
                assertTrue(false,'Test failed: binding problem')
            end
        end


        %------------------------------------------------------------------------------------------
        function obj=test_fix2background_foreground(obj)
            data = obj.source_data;    % abbreviate for clarity on the code

            % ---------------------------------------------
            prat=[6,0,0,0.01,0]; pbnd=[3,0,0,5,0];
            [y1_fbind2_ref, wstruct1_fbind2_ref, w1_fbind2_ref, p1_fbind2_ref] = mftest_mf_and_f_single_dataset...
                (data.x1,data.y1,data.e1,data.wstruct1,data.w1,...
                @mftest_gauss_bkgd_bind, [obj.pin,prat,pbnd], [0,0,1,0,1,zeros(1,10)]);

            % test against saved or store to save later
            tol = [1e-10,1e-8];
            assertEqualToTolWithSave (obj, y1_fbind2_ref, 'tol', tol)
            assertEqualToTolWithSave (obj, wstruct1_fbind2_ref, 'tol', tol)
            assertEqualToTolWithSave (obj, w1_fbind2_ref, 'tol', tol)
            assertEqualToTolWithSave (obj, p1_fbind2_ref, 'tol', tol)

            % ---------------------------------------------
            [y1_fbind2, wstruct1_fbind2, w1_fbind2, p1_fbind2] = mftest_mf_and_f_single_dataset...
                (data.x1,data.y1,data.e1,data.wstruct1,data.w1,...
                @mftest_gauss, obj.pin(1:3), [1,0,1], {1,3,6}, @mftest_bkgd, obj.pin(4:5), [1,1], {{1,2,0.01}});

            % test against saved or store to save later
            tol = [1e-10,1e-8];
            assertEqualToTolWithSave (obj, y1_fbind2, 'tol', tol)
            assertEqualToTolWithSave (obj, wstruct1_fbind2, 'tol', tol)
            assertEqualToTolWithSave (obj, w1_fbind2, 'tol', tol)
            assertEqualToTolWithSave (obj, p1_fbind2, 'tol', tol)

            ltol=0;
            if ~equal_to_tol(y1_fbind2_ref,y1_fbind2,ltol)     % can only compare output y values - we've fudged the reference fit function, and parameters are not 'real'
                assertTrue(false,'Test failed: binding problem')
            end
        end


        %------------------------------------------------------------------------------------------
        function obj=test_fix_parameters_across(obj)
            data = obj.source_data;    % abbreviate for clarity on the code

            % Fix parameters across the foreground and background
            % ---------------------------------------------------
            prat=[0,0,0.2,0,1/300]; pbnd=[0,0,4,0,2];
            [y1_fbind3_ref, wstruct1_fbind3_ref, w1_fbind3_ref, p1_fbind3_ref] = mftest_mf_and_f_single_dataset...
                (data.x1,data.y1,data.e1,data.wstruct1,data.w1,...
                @mftest_gauss_bkgd_bind, [100,50,5,20,0,prat,pbnd], [0,1,0,1,0,zeros(1,10)]);

            % Test against saved or store to save later
            tol = [1e-10,1e-8];
            assertEqualToTolWithSave (obj, y1_fbind3_ref, 'tol', tol)
            assertEqualToTolWithSave (obj, wstruct1_fbind3_ref, 'tol', tol)
            assertEqualToTolWithSave (obj, w1_fbind3_ref, 'tol', tol)
            assertEqualToTolWithSave (obj, p1_fbind3_ref, 'tol', tol)

            % ---------------------------------------------
            [y1_fbind3, wstruct1_fbind3, w1_fbind3, p1_fbind3] = mftest_mf_and_f_single_dataset...
                (data.x1,data.y1,data.e1,data.wstruct1,data.w1,...
                @mftest_gauss, [100,50,5], [0,1,1], {3,[1,-1],0.2}, @mftest_bkgd, [20,0],'', {{2,[2,-1],1/300}});
            % Test against saved or store to save later
            tol = [1e-10,1e-8];
            assertEqualToTolWithSave (obj, y1_fbind3, 'tol', tol)
            assertEqualToTolWithSave (obj, wstruct1_fbind3, 'tol', tol)
            assertEqualToTolWithSave (obj, w1_fbind3, 'tol', tol)
            assertEqualToTolWithSave (obj, p1_fbind3, 'tol', tol)

            ltol=0;
            if ~equal_to_tol(y1_fbind3_ref,y1_fbind3,ltol)  % can only compare output y values - we've fudged the reference fit function, and parameters are not 'real'
                assertTrue(false,'Test failed: binding problem')
            end
        end


        %------------------------------------------------------------------------------------------
        function obj = test_more_binding_of_par(obj)
            data = obj.source_data;    % abbreviate for clarity on the code

            % ---------------------------------------------
            prat=[2,0,0.2,0,1/300]; pbnd=[2,0,4,0,2];
            [y1_fbind4_ref, wstruct1_fbind4_ref, w1_fbind4_ref, p1_fbind4_ref] = mftest_mf_and_f_single_dataset...
                (data.x1,data.y1,data.e1,data.wstruct1,data.w1,...
                @mftest_gauss_bkgd_bind, [100,50,5,20,0,prat,pbnd], [0,1,0,1,0,zeros(1,10)]);

            % Test against saved or store to save later
            tol = [1e-10,1e-8];
            assertEqualToTolWithSave (obj, y1_fbind4_ref, 'tol', tol)
            assertEqualToTolWithSave (obj, wstruct1_fbind4_ref, 'tol', tol)
            assertEqualToTolWithSave (obj, w1_fbind4_ref, 'tol', tol)
            assertEqualToTolWithSave (obj, p1_fbind4_ref, 'tol', tol)

            % ---------------------------------------------
            [y1_fbind4, wstruct1_fbind4, w1_fbind4, p1_fbind4] = mftest_mf_and_f_single_dataset...
                (data.x1,data.y1,data.e1,data.wstruct1,data.w1,...
                @mftest_gauss, [100,50,5], '', {{1,2},{3,[1,-1],0.2}}, @mftest_bkgd, [20,0],'', {{2,[2,-1],1/300}});
            ltol=0;
            if ~equal_to_tol(y1_fbind4_ref,y1_fbind4,ltol)  % can only compare output y values - we've fudged the reference fit function, and parameters are not 'real'
                assertTrue(false,'Test failed: binding problem')
            end

            % Test against saved or store to save later
            tol = [1e-10,1e-8];
            assertEqualToTolWithSave (obj, y1_fbind4, 'tol', tol)
            assertEqualToTolWithSave (obj, wstruct1_fbind4, 'tol', tol)
            assertEqualToTolWithSave (obj, w1_fbind4, 'tol', tol)
            assertEqualToTolWithSave (obj, p1_fbind4, 'tol', tol)
        end


        % =========================================================================================
        % Test multiple datasets
        % =========================================================================================

        function obj = test_multiple_ds_fail(obj)
            skipTest('Awaiting refactoring of mftest_mf_and_f_multiple_datasets')
            % To test equivalence of fit and loop over multifit for multiple datasets

            data = obj.source_data;    % abbreviate for clarity on the code

            % ---------------------------------------------
            ww_objarr=[data.w1,data.w2,data.w3];
            [ww_fobjarr_f,pp_fobjarr,ok,mess] = mftest_mf_and_f_multiple_datasets...
                (ww_objarr, @mftest_gauss_bkgd, obj.pin);
            if ~ok, assertTrue(false,['Unexpected failure ',mess]), end
            % Test against saved or store to save later
            tol = [1e-10,1e-8];
            assertEqualToTolWithSave (obj, ww_fobjarr_f, 'tol', tol)
            assertEqualToTolWithSave (obj, pp_fobjarr, 'tol', tol)

            % ---------------------------------------------
            ww_objcellarr={data.w1,data.w2,data.w3};
            [ww_fobjcellarr_f,pp_fobjcellarr,ok,mess] = mftest_mf_and_f_multiple_datasets...
                (ww_objcellarr, @mftest_gauss_bkgd, obj.pin);
            if ~ok, assertTrue(false,['Unexpected failure ',mess]), end
            % Test against saved or store to save later
            %----------------
            % The following line doesn't appear to actually do anything, so comments out
            %obj.ref_data.ww_fobjcellarr_f = cellfun(@IX_dataset_1d,obj.ref_data.ww_fobjcellarr_f,'UniformOutput',false);
            %----------------
            tol = [1e-10,1e-8];
            assertEqualToTolWithSave (obj, ww_fobjcellarr_f, 'tol', tol)
            assertEqualToTolWithSave (obj, pp_fobjcellarr, 'tol', tol)

            % ---------------------------------------------
            ww_structarr=[data.wstruct1,data.wstruct2,data.wstruct3];
            [ww_fstructarr_f,pp_fstructarr,ok,mess] = mftest_mf_and_f_multiple_datasets...
                (ww_structarr, @mftest_gauss_bkgd, obj.pin);
            if ~ok, assertTrue(false,['Unexpected failure ',mess]), end
            % Test against saved or store to save later
            tol = [1e-10,1e-8];
            assertEqualToTolWithSave (obj, ww_fstructarr_f, 'tol', tol)
            assertEqualToTolWithSave (obj, pp_fstructarr, 'tol', tol)

            % ---------------------------------------------
            ww_cellarr={data.wstruct1,data.w2,data.wstruct3};
            [ww_fcellarr_f,pp_fcellarr,ok,mess] = mftest_mf_and_f_multiple_datasets...
                (ww_cellarr, @mftest_gauss_bkgd, obj.pin);
            if ok, assertTrue(false,['Should have failed, but did not',mess]), end
            % Test against saved or store to save later
            tol = [1e-10,1e-8];
            assertEqualToTolWithSave (obj, ww_fcellarr_f, 'tol', tol)
            assertEqualToTolWithSave (obj, pp_fcellarr, 'tol', tol)
        end
    end
end
