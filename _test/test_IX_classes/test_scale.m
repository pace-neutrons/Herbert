classdef test_scale <  TestCaseWithSave
    % Test class to test axis rescaling methods
    
    properties
        w1  % one-dimensional dataset
        w2  % two-dimensional dataset
        w2b % another two-dimensional dataset
        w3  % three-dimensional dataset
        w4  % four-dimensional dataset
    end
    
    methods
        function obj=test_scale (name)
            obj@TestCaseWithSave(name);
            obj.save()
            
            % Make 1D dataset
            x = 1:10;
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
            % scale
            ws = scale (obj.w1, 5);
            % Reference answer
            ws_ref = obj.w1;
            ws_ref.x = ws_ref.x * 5;
            % Test
            assertEqual (ws_ref, ws)
        end
        
        function test_1D_error(obj)
            testfun = @()scale (obj.w1, [5,2]);
            assertExceptionThrown(testfun, 'HERBERT:scale_:invalid_argument');
        end
        
        function test_1D_error_neg(obj)
            testfun = @()scale (obj.w1, -3);
            assertExceptionThrown(testfun, 'HERBERT:scale_:invalid_argument');
        end
        
        %------------------------------------------------------------------
        % 2D data
        %------------------------------------------------------------------
        function test_2D(obj)
            % scale
            ws = scale (obj.w2, [5,3]);
            % Reference answer
            ws_ref = obj.w2;
            ws_ref.x = ws_ref.x * 5;
            ws_ref.y = ws_ref.y * 3;
            % Test
            assertEqual (ws_ref, ws)
        end
        
        function test_2D_x(obj)
            % scale
            ws = scale_x (obj.w2, 5);
            % Reference answer
            ws_ref = obj.w2;
            ws_ref.x = ws_ref.x * 5;
            % Test
            assertEqual (ws_ref, ws)
        end
        
        function test_2D_y(obj)
            % scale
            ws = scale_y (obj.w2, 3);
            % Reference answer
            ws_ref = obj.w2;
            ws_ref.y = ws_ref.y * 3;
            % Test
            assertEqual (ws_ref, ws)
        end
        
        function test_2D_error(obj)
            testfun = @()scale (obj.w2, 5);
            assertExceptionThrown(testfun, 'HERBERT:scale_:invalid_argument');
        end
        
        function test_2D_error2(obj)
            testfun = @()scale (obj.w2, []);
            assertExceptionThrown(testfun, 'HERBERT:scale_:invalid_argument');
        end
        
        function test_2D_error_x(obj)
            testfun = @()scale_x (obj.w2, [5,3]);
            assertExceptionThrown(testfun, 'HERBERT:scale_:invalid_argument');
        end
        
        function test_2D_error_neg(obj)
            testfun = @()scale (obj.w2, [5,-3]);
            assertExceptionThrown(testfun, 'HERBERT:scale_:invalid_argument');
        end
        
        %------------------------------------------------------------------
        % 3D data
        %------------------------------------------------------------------
        function test_3D(obj)
            % scale
            ws = scale (obj.w3, [5,3,99]);
            % Reference answer
            ws_ref = obj.w3;
            ws_ref.x = ws_ref.x * 5;
            ws_ref.y = ws_ref.y * 3;
            ws_ref.z = ws_ref.z * 99;
            % Test
            assertEqual (ws_ref, ws)
        end
        
        function test_3D_x(obj)
            % scale
            ws = scale_x (obj.w3, 5);
            % Reference answer
            ws_ref = obj.w3;
            ws_ref.x = ws_ref.x * 5;
            % Test
            assertEqual (ws_ref, ws)
        end
        
        function test_3D_y(obj)
            % scale
            ws = scale_y (obj.w3, 3);
            % Reference answer
            ws_ref = obj.w3;
            ws_ref.y = ws_ref.y * 3;
            % Test
            assertEqual (ws_ref, ws)
        end
        
        function test_3D_z(obj)
            % scale
            ws = scale_z (obj.w3, 99);
            % Reference answer
            ws_ref = obj.w3;
            ws_ref.z = ws_ref.z * 99;
            % Test
            assertEqual (ws_ref, ws)
        end
        
        function test_3D_error(obj)
            testfun = @()scale (obj.w3, 5);
            assertExceptionThrown(testfun, 'HERBERT:scale_:invalid_argument');
        end
        
        function test_3D_error_y(obj)
            testfun = @()scale_y (obj.w3, [5,3,99]);
            assertExceptionThrown(testfun, 'HERBERT:scale_:invalid_argument');
        end
        
        function test_3D_error_y_neg(obj)
            testfun = @()scale (obj.w3, -3);
            assertExceptionThrown(testfun, 'HERBERT:scale_:invalid_argument');
        end
        
        %------------------------------------------------------------------
        % 4D data
        %------------------------------------------------------------------
        function test_4D(obj)
            % scale
            ws = scale (obj.w4, [5,3,99,6]);
            % Reference answer
            ws_ref = obj.w4;
            ws_ref.x = ws_ref.x * 5;
            ws_ref.y = ws_ref.y * 3;
            ws_ref.z = ws_ref.z * 99;
            ws_ref.w = ws_ref.w * 6;
            % Test
            assertEqual (ws_ref, ws)
        end
        
        function test_4D_w(obj)
            % scale
            ws = scale_w (obj.w4, 5);
            % Reference answer
            ws_ref = obj.w4;
            ws_ref.w = ws_ref.w * 5;
            % Test
            assertEqual (ws_ref, ws)
        end

        
        %------------------------------------------------------------------
        % Test array of objects
        %------------------------------------------------------------------
        function test_2D_array(obj)
            % scale
            w = [obj.w2,obj.w2b];
            ws = scale (w, [5,3]);
            % Reference answer
            ws_ref = [scale(obj.w2, [5,3]), scale(obj.w2b, [5,3])];
            % Test
            assertEqual (ws_ref, ws) 
        end
    end
end
