classdef test_IX_sample < TestCaseWithSave
    % Test of obj2struct
    properties
        sam1
        sam2
        sam3
        s1
        s2
        s3
        slookup
    end

    methods
        %--------------------------------------------------------------------------
        function self = test_IX_sample (name)
            if nargin<1
                name = 'test_IX_sample';
            end
            self@TestCaseWithSave(name);

            % Make some samples and sample arrays
            self.sam1 = IX_sample ([1,0,0],[0,1,0],'cuboid',[2,3,4]);
            self.sam2 = IX_sample ([0,1,0],[0,0,1],'cuboid',[12,13,34]);
            self.sam3 = IX_sample ([1,1,0],[0,0,1],'cuboid',[22,23,24]);

            self.s1 = [self.sam1, self.sam1, self.sam2, self.sam2, self.sam2];
            self.s2 = [self.sam3, self.sam1, self.sam2, self.sam3, self.sam1];
            self.s3 = [self.sam2, self.sam3, self.sam1, self.sam2, self.sam3];

            self.slookup = object_lookup({self.s1, self.s2, self.s3});

            self.save()
        end

        %--------------------------------------------------------------------------
        function test_IX_sample_constructor_error_if_required_args_missing(name)
            f = @()IX_sample([1,0,0],[0,1,0],'cuboid');
            assertExceptionThrown(f, '')
        end

        %--------------------------------------------------------------------------
        function test_IX_sample_constructor_error_if_invalid_shape(name)
            f = @()IX_sample([1,0,0],[0,1,0],'banana',[2,3,4]);
            assertExceptionThrown(f, '')
        end

        %--------------------------------------------------------------------------
        function test_IX_sample_constructor_accepts_and_sets_hall_symbol(name)
            sample = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4], '-hall_symbol', 'hsymbol');
            assertEqual(sample.hall_symbol, 'hsymbol');
        end

        %--------------------------------------------------------------------------
        function test_IX_sample_constructor_accepts_and_sets_temperature(name)
            sample = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4], '-temperature', 1234.5);
            assertEqual(sample.temperature, 1234.5);
        end
        function test_IX_sample_constructor_errors_for_non_numeric_temperature(name)
            f = @()IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4], '-temperature', 'string');
            assertExceptionThrown(f, '')
        end

        %--------------------------------------------------------------------------
        function test_IX_sample_constructor_accepts_and_sets_name(name)
            sample = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4], '-name', 'test name');
            assertEqual(sample.name, 'test name');
        end

        %--------------------------------------------------------------------------
        function test_IX_sample_constructor_accepts_and_sets_mosaic_eta(name)
            eta = IX_mosaic(1234);
            sample = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4], '-eta', eta);
            assertEqual(sample.eta, eta);
        end
        function test_IX_sample_constructorsets_sets_numeric_eta_as_mosaic(name)
            sample = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4], '-eta', 4134);
            assertEqual(sample.eta, IX_mosaic(4134));
        end

        %--------------------------------------------------------------------------
        function test_covariance (self)
            s = self.slookup;
            cov = s.func_eval(2,[2,2,1,4,3],@covariance);
            assertEqualWithSave (self,cov);
        end

        %--------------------------------------------------------------------------
        function test_identical_samples_are_equal(obj)
            samp1 = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4]);
            samp2 = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4]);

            assertTrue(samp1 == samp2);
            assertFalse(samp1 ~= samp2)
        end

        function test_different_samples_are_not_equal(obj)
            samp1 = IX_sample ([1,0,0],[0,1,0],'cuboid',[2,3,4]);
            samp2 = IX_sample ([1,1,0],[0,0,1],'cuboid',[22,23,24]);

            assertFalse(samp1 == samp2);
            assertTrue(samp1 ~= samp2)
        end

        function test_identical_samples_with_matching_hall_symbol_are_equal(obj)
            samp1 = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4], '-hall_symbol', 'hsymbol');
            samp2 = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4], '-hall_symbol', 'hsymbol');

            assertTrue(samp1 == samp2);
            assertFalse(samp1 ~= samp2)
        end

        function test_matching_samples_with_missing_hall_symbol_are_not_equal(obj)
            samp1 = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4]);
            samp2 = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4], '-hall_symbol', 'hsymbol');

            assertFalse(samp1 == samp2);
            assertTrue(samp1 ~= samp2)
        end

        function test_matching_samples_with_different_hall_symbols_are_not_equal(obj)
            samp1 = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4], '-hall_symbol', 'other');
            samp2 = IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4], '-hall_symbol', 'hsymbol');

            assertFalse(samp1 == samp2);
            assertTrue(samp1 ~= samp2)
        end

        %--------------------------------------------------------------------------
        function test_pdf (self)
            nsamp = 1e7;
            ind = randselection([2,3],[ceil(nsamp/10),10]);     % random indicies from 2 and 3
            samp = rand_ind(self.slookup,2,ind);
            samp2 = samp(:,ind==2);
            samp3 = samp(:,ind==3);

            mean2 = mean(samp2,2);
            mean3 = mean(samp3,2);
            std2 = std(samp2,1,2);
            std3 = std(samp3,1,2);

            assertEqualToTol(mean2, [0;0;0], 'tol', 0.003);
            assertEqualToTol(mean3, [0;0;0], 'tol', 0.02);

            assertEqualToTol(std2, self.sam1.ps'/sqrt(12), 'reltol', 0.001);
            assertEqualToTol(std3, self.sam2.ps'/sqrt(12), 'tol', 0.01);
        end

    end
end

