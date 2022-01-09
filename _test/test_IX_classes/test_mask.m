classdef test_mask <  TestCaseWithSave
    % Test class to test signal masking
    
    properties
        w1  % one-dimensional dataset
        w2  % two-dimensional dataset
        w2b % another two-dimensional dataset
        w3  % three-dimensional dataset
        w4  % four-dimensional dataset
    end
    
    methods
        function obj=test_mask (name)
            obj@TestCaseWithSave(name);
            obj.save()
            
            % Make 1D dataset
            x = 1:1000;
            obj.w1 = IX_dataset_1d (x, rand(size(x)), rand(size(x)), ...
                'A title', 'x-axis', 'signal axis', true);
            
            % Make 2D dataset
            x1 = 1:100; x2 = 1001:1050;
            obj.w2 = IX_dataset_2d (x1, x2, rand(100,50), rand(100,50), ...
                'A title', 'x-axis', 'y-axis', 'signal axis', true, false);

            x1b = 1:10; x2b = 1001:1040;
            obj.w2b = IX_dataset_2d (x1b, x2b, rand(10,39), rand(10,39), ...
                'A title', 'x-axis', 'y-axis', 'signal axis', true, false);

            % Make 3D dataset
            x1 = 1:100; x2 = 1001:1050; x3 = 2001:2010;
            obj.w3 = IX_dataset_3d (x1, x2, x3, rand(100,50,10), rand(100,50,10), ...
                'A title', 'x-axis', 'y-axis', 'z-axis','signal axis',...
                true, false, true);

            % Make 4D dataset
            x1 = 1:30; x2 = 1001:1050; x3 = 2001:2010; x4 = 3001:3005;
            obj.w4 = IX_dataset_4d (x1, x2, x3, x4, rand(30,50,10,5), rand(30,50,10,5), ...
                'A title', 'x-axis', 'y-axis', 'z-axis', 'w-axis',...
                'signal axis', true, false,false,true);

        end
        
        %------------------------------------------------------------------
        % 1D data
        %------------------------------------------------------------------
        function test_1D(obj)
            % Random selection of points
            msk = logical(round(rand(size(obj.w1.signal))));
            % mask
            wm = mask (obj.w1, msk);
            % Reference answer
            wm_ref = obj.w1;
            wm_ref.signal(~msk) = NaN;
            wm_ref.error(~msk) = NaN;
            % Test
            assertEqual (wm_ref, wm)
        end
        
        function test_1D_all_true(obj)
            % Random selection of points
            msk = true(size(obj.w1.signal));
            % mask
            wm = mask (obj.w1, msk);
            % Reference answer
            wm_ref = obj.w1;
            % Test
            assertEqual (wm_ref, wm)
        end
        
        function test_1D_all_false(obj)
            % Random selection of points
            msk = false(size(obj.w1.signal));
            % mask
            wm = mask (obj.w1, msk);
            % Reference answer
            wm_ref = obj.w1;
            wm_ref.signal = NaN(size(wm_ref.signal));
            wm_ref.error = NaN(size(wm_ref.error));
            % Test
            assertEqual (wm_ref, wm)
        end
        
        function test_1D_error(obj)
            % Should fail as msk has invalid type
            msk = 'c';
            testfun = @()mask (obj.w1, msk);
            assertExceptionThrown(testfun, 'HERBERT:mask:invalid_argument');
        end
        
        function test_1D_error2(obj)
            % Should fail as the number of mask elements does not match signal
            msk = logical(round(rand(size(obj.w1.signal))));
            msk = [msk(:)', true];
            testfun = @()mask (obj.w1, msk);
            assertExceptionThrown(testfun, 'HERBERT:mask:invalid_argument');
        end
        
        %------------------------------------------------------------------
        % 2D data
        %------------------------------------------------------------------
        function test_2D(obj)
            % Random selection of points
            msk = logical(round(rand(size(obj.w2.signal))));
            % mask
            wm = mask (obj.w2, msk);
            % Reference answer
            wm_ref = obj.w2;
            wm_ref.signal(~msk) = NaN;
            wm_ref.error(~msk) = NaN;
            % Test
            assertEqual (wm_ref, wm)
        end
        
        function test_2D_msk_shape_change(obj)
            % Random selection of points
            msk = logical(round(rand(size(obj.w2.signal))));
            msk = msk(:)';
            % mask
            wm = mask (obj.w2, msk);
            % Reference answer
            wm_ref = obj.w2;
            wm_ref.signal(~msk) = NaN;
            wm_ref.error(~msk) = NaN;
            % Test
            assertEqual (wm_ref, wm)
        end
        
        function test_2D_all_true(obj)
            % Random selection of points
            msk = true(size(obj.w2.signal));
            % mask
            wm = mask (obj.w2, msk);
            % Reference answer
            wm_ref = obj.w2;
            % Test
            assertEqual (wm_ref, wm)
        end
        
        function test_2D_all_false(obj)
            % Random selection of points
            msk = false(size(obj.w2.signal));
            % mask
            wm = mask (obj.w2, msk);
            % Reference answer
            wm_ref = obj.w2;
            wm_ref.signal = NaN(size(wm_ref.signal));
            wm_ref.error = NaN(size(wm_ref.error));
            % Test
            assertEqual (wm_ref, wm)
        end
        
        function test_2D_error(obj)
            % Should fail as msk has invalid type
            msk = 'c';
            testfun = @()mask (obj.w2, msk);
            assertExceptionThrown(testfun, 'HERBERT:mask:invalid_argument');
        end
        
        function test_2D_error2(obj)
            % Should fail as the number of mask elements does not match signal
            msk = logical(round(rand(size(obj.w2.signal))));
            msk = [msk(:)', true];
            testfun = @()mask (obj.w2, msk);
            assertExceptionThrown(testfun, 'HERBERT:mask:invalid_argument');
        end
        
        %------------------------------------------------------------------
        % 3D data
        %------------------------------------------------------------------
        function test_3D(obj)
            % Random selection of points
            msk = logical(round(rand(size(obj.w3.signal))));
            % mask
            wm = mask (obj.w3, msk);
            % Reference answer
            wm_ref = obj.w3;
            wm_ref.signal(~msk) = NaN;
            wm_ref.error(~msk) = NaN;
            % Test
            assertEqual (wm_ref, wm)
        end
        
        function test_3D_msk_shape_change(obj)
            % Random selection of points
            msk = logical(round(rand(size(obj.w3.signal))));
            msk = msk(:)';
            % mask
            wm = mask (obj.w3, msk);
            % Reference answer
            wm_ref = obj.w3;
            wm_ref.signal(~msk) = NaN;
            wm_ref.error(~msk) = NaN;
            % Test
            assertEqual (wm_ref, wm)
        end
        
        function test_3D_all_true(obj)
            % Random selection of points
            msk = true(size(obj.w3.signal));
            % mask
            wm = mask (obj.w3, msk);
            % Reference answer
            wm_ref = obj.w3;
            % Test
            assertEqual (wm_ref, wm)
        end
        
        function test_3D_all_false(obj)
            % Random selection of points
            msk = false(size(obj.w3.signal));
            % mask
            wm = mask (obj.w3, msk);
            % Reference answer
            wm_ref = obj.w3;
            wm_ref.signal = NaN(size(wm_ref.signal));
            wm_ref.error = NaN(size(wm_ref.error));
            % Test
            assertEqual (wm_ref, wm)
        end
        
        function test_3D_error(obj)
            % Should fail as msk has invalid type
            msk = 'c';
            testfun = @()mask (obj.w3, msk);
            assertExceptionThrown(testfun, 'HERBERT:mask:invalid_argument');
        end
        
        function test_3D_error2(obj)
            % Should fail as the number of mask elements does not match signal
            msk = logical(round(rand(size(obj.w3.signal))));
            msk = [msk(:)', true];
            testfun = @()mask (obj.w3, msk);
            assertExceptionThrown(testfun, 'HERBERT:mask:invalid_argument');
        end
        
        
        %------------------------------------------------------------------
        % 4D data
        %------------------------------------------------------------------
        function test_4D(obj)
            % Random selection of points
            msk = logical(round(rand(size(obj.w4.signal))));
            % mask
            wm = mask (obj.w4, msk);
            % Reference answer
            wm_ref = obj.w4;
            wm_ref.signal(~msk) = NaN;
            wm_ref.error(~msk) = NaN;
            % Test
            assertEqual (wm_ref, wm)
        end
        
        function test_4D_msk_shape_change(obj)
            % Random selection of points
            msk = logical(round(rand(size(obj.w4.signal))));
            msk = msk(:)';
            % mask
            wm = mask (obj.w4, msk);
            % Reference answer
            wm_ref = obj.w4;
            wm_ref.signal(~msk) = NaN;
            wm_ref.error(~msk) = NaN;
            % Test
            assertEqual (wm_ref, wm)
        end
        
        function test_4D_all_true(obj)
            % Random selection of points
            msk = true(size(obj.w4.signal));
            % mask
            wm = mask (obj.w4, msk);
            % Reference answer
            wm_ref = obj.w4;
            % Test
            assertEqual (wm_ref, wm)
        end
        
        function test_4D_all_false(obj)
            % Random selection of points
            msk = false(size(obj.w4.signal));
            % mask
            wm = mask (obj.w4, msk);
            % Reference answer
            wm_ref = obj.w4;
            wm_ref.signal = NaN(size(wm_ref.signal));
            wm_ref.error = NaN(size(wm_ref.error));
            % Test
            assertEqual (wm_ref, wm)
        end
        
        function test_4D_error(obj)
            % Should fail as msk has invalid type
            msk = 'c';
            testfun = @()mask (obj.w4, msk);
            assertExceptionThrown(testfun, 'HERBERT:mask:invalid_argument');
        end
        
        function test_4D_error2(obj)
            % Should fail as the number of mask elements does not match signal
            msk = logical(round(rand(size(obj.w4.signal))));
            msk = [msk(:)', true];
            testfun = @()mask (obj.w4, msk);
            assertExceptionThrown(testfun, 'HERBERT:mask:invalid_argument');
        end
        
        %------------------------------------------------------------------
    end
end
