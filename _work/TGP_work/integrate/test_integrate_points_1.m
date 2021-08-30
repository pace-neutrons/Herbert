classdef test_integrate_points_1 <  TestCaseWithSave
    % Test class to test point averaging algorithm
    
    methods
        function obj = test_integrate_points_1 (name)
            obj@TestCaseWithSave(name);
            
            obj.save()
        end
        
        %------------------------------------------------------------------
        function test_0(obj)
            % Rebin onto finer bins. Tests absolute values of signal and
            % error after rebinning.
            %
            % At the same time, checks that empty output bins correctly
            % contain zero signal and error
            
            tol = [1e-14,1e-14];
            
            x = [5,6,8,13,14,16];
            s = [10,4,13,8,2,12]';
            e = [1.1,2.7,1.5,2.95,0.35,4]';
            
            xout = [3.5, 4.1, 5, 5.3, 5.5, 5.9, 6, 6.25, 7.25, 8,...
                9, 11.5, 12.5, 13, 13.33, 14, 14.6, 15.1, 15.7, 16, 18, 20];
            
            % Perform integral using points as boundaries
            sout_ref = [0,  0,   2.729999999999998,   1.520000000000001, ...
                2.320000000000002,   0.429999999999998, ...
                1.140625000000000,   7.375000000000000,   8.484375000000000, ...
                12.500000000000000,  26.875000000000000,   9.000000000000000,...
                4.125000000000000,   2.313300000000002,   2.686700000000003, ...
                2.100000000000001,   3.124999999999999,   5.399999999999992, ...
                3.375000000000008,                   0,                   0]';
            eout_ref = [0 0   0.803958954176145   0.973344748791507 ...
                1.770423678106459   1.020710536832062 ...
                1.638883003755912   3.128498042192132   2.517252967025762 ...
                3.114201342238488   6.340273061942995   4.739303746332366 ...
                3.549357336194822   2.682770338195204   2.426338457944401 ...
                1.238431467623462   1.858178711803576   2.598667927996956 ...
                2.108111566070451                   0                   0]';
            
            % Perform integration onto finer bins
            [sout, eout] = integrate_points_trueErrors (x, s, e, 1, xout);
            
            assertEqualToTol(sout_ref, sout, 'tol', tol)
            assertEqualToTol(eout_ref, eout, 'tol', tol)
            
        end
        
        %------------------------------------------------------------------
        function test_1(obj)
            % Rebin onto finer bins, and check that when sum signal and
            % errors in quadrature that the same result is obtained as if
            % the bins are integrated immediately. This tests that the
            % splitting of the error bars is correct when subdividing
            % intervals
            %
            % At the same time, checks that empty output bins correctly
            % contain zero signal and error
            
            tol = [1e-14,1e-14];
            
            x = [5,6,8,13,14,16];
            s = [10,4,13,8,2,12]';
            e = [1.1,2.7,1.5,2.95,0.35,4]';
            
            xout = [3.5, 4.1, 5, 5.3, 5.5, 5.9, 6, 6.25, 7.25, 8,...
                9, 11.5, 12.5, 13, 13.33, 14, 14.6, 15.1, 15.7, 16, 18, 20];
            
            % Perform integral using points as boundaries
            [sout1_ref, eout1_ref] = integrate_points_trueErrors (x, s, e, 1, x);
            
            % Perform integration onto finer bins
            [sout, eout] = integrate_points_trueErrors (x, s, e, 1, xout);
            assertEqual(sout(1:2), [0;0])
            assertEqual(eout(1:2), [0;0])
            assertEqual(sout(20:21), [0;0])
            assertEqual(eout(20:21), [0;0])
            
            % Sum integrals in quadrature onto original bins
            sout1 = [sum(sout(3:6)); sum(sout(7:9)); sum(sout(10:13)); ...
                sum(sout(14:15)); sum(sout(16:19))];
            eout1 = sqrt([sum(eout(3:6).^2); sum(eout(7:9).^2); sum(eout(10:13).^2); ...
                sum(eout(14:15).^2); sum(eout(16:19).^2)]);
            
            assertEqualToTol(sout1_ref, sout1, 'tol', tol)
            assertEqualToTol(eout1_ref, eout1, 'tol', tol)
            
        end
        
        %------------------------------------------------------------------
        function test_2(obj)
            % Rebin onto finer bins that are incommensurate with the
            % original data points except at a few points. Check that when
            % sum signal and errors in quadrature that the same result is
            % obtained as if the bins are integrated onto the commensurate
            % points. This tests that the splitting of the error bars is 
            % correct when intervals span across the original points.
            %
            % At the same time, checks that empty output bins correctly
            % contain zero signal and error
            
            tol = [1e-14,1e-14];
            
            x = [5,6,8,13,14,16];
            s = [10,4,13,8,2,12]';
            e = [1.1,2.7,1.5,2.95,0.35,4]';
            
            xout = [3.5, 4.1, 5, 5.3, 5.5, 6.25, 7.25, 8,...
                9, 11.5, 14, 14.6, 15.1, 15.7, 16, 18, 20];
            
            xfinal = [5,8,16];

            % Perform integral cirect onto final bins
            [sfinal_ref, efinal_ref] = integrate_points_trueErrors (x, s, e, 1, xfinal);
            
            % Perform integration onto finer bins
            [sout, eout] = integrate_points_trueErrors (x, s, e, 1, xout);
            assertEqual(sout(1:2), [0;0])
            assertEqual(eout(1:2), [0;0])
            assertEqual(sout(15:16), [0;0])
            assertEqual(eout(15:16), [0;0])
            
            % Sum integrals in quadrature onto original bins
            sfinal = [sum(sout(3:7)); sum(sout(8:14))];
            efinal = sqrt([sum(eout(3:7).^2); sum(eout(8:14).^2)]);
            
            assertEqualToTol(sfinal_ref, sfinal, 'tol', tol)
            assertEqualToTol(efinal_ref, efinal, 'tol', tol)
            
        end
        
        %------------------------------------------------------------------
    end
    
end
