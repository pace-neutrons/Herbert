classdef test_rebin_histogram <  TestCaseWithSave
    % Test class to test rebinning algorithm for histogram data
    
    methods
        function obj = test_rebin_histogram (name)
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
            
            x = [5.16, 6.16, 8.16, 13.16, 14.16, 16.16];
            s = [10, 4, 13, 8, 2]';
            e = [1.1, 2.7, 1.5, 2.95, 0.35]';
            
            xout = [3.5, 4.1, 5, 5.3, 5.5, 5.9, 6, 6.25, 7.25, 8,...
                9, 11.5, 12.5, 13, 13.33, 14, 14.6, 15.1, 15.7, 16, 18, 20];
            
            % Rebin expected results
            sout_ref = [0 0   4.666666666666659  10.000000000000000  10 ...
                10.000000000000000   7.840000000000003   4.000000000000000 ...
                4.000000000000000  11.559999999999999  13.000000000000000 ...
                13.000000000000000  13.000000000000000  10.424242424242426 ...
                8.000000000000000   3.600000000000002   2.000000000000000 ...
                2.000000000000000   2.000000000000000   0.160000000000000  0]';
            eout_ref = [0  0   1.371941041817111   2.459674775249768 ...
                1.739252713092608   3.478505426185224  4.908441707915046 ...
                3.818376618407357   4.409081537009722   3.432608337693073 ...
                2.121320343559643   3.354101966249685   4.743416490252569 ...
                5.487631137427072   3.603998608511005   2.041377530547015 ...
                0.700000000000000   0.639009650422694   0.903696114115063 ...
                0.098994949366117                   0]';
            
            % Perform rebin
            [sout, eout] = rebin_histogram (x, s, e, 1, xout);
            
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
            s = [10,4,13,8,2]';
            e = [1.1,2.7,1.5,2.95,0.35]';
            
            xout = [3.5, 4.1, 5, 5.3, 5.5, 5.9, 6, 6.25, 7.25, 8,...
                9, 11.5, 12.5, 13, 13.33, 14, 14.6, 15.1, 15.7, 16, 18, 20];
            
            % Counts in each bin in the original array
            dx = diff(x');
            stot_ref = s .* dx;
            etot_ref = e .* dx;
            
            % Rebin onto finer bins
            [sout, eout] = rebin_histogram (x, s, e, 1, xout);
            assertEqual(sout(1:2), [0;0])
            assertEqual(eout(1:2), [0;0])
            assertEqual(sout(20:21), [0;0])
            assertEqual(eout(20:21), [0;0])
            
            % Sum counts in each bin to recover counts in the original array
            dx_fine = diff(xout');
            stot_fine = sout .* dx_fine;
            etot_fine = eout .* dx_fine;
            stot = [sum(stot_fine(3:6)); sum(stot_fine(7:9)); sum(stot_fine(10:13)); ...
                sum(stot_fine(14:15)); sum(stot_fine(16:19))];
            etot = sqrt([sum(etot_fine(3:6).^2); sum(etot_fine(7:9).^2); ...
                sum(etot_fine(10:13).^2); sum(etot_fine(14:15).^2); ...
                sum(etot_fine(16:19).^2)]);
            
            assertEqualToTol(stot_ref, stot, 'tol', tol)
            assertEqualToTol(etot_ref, etot, 'tol', tol)
            
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
            s = [10,4,13,8,2]';
            e = [1.1,2.7,1.5,2.95,0.35]';
            
            xout = [3.5, 4.1, 5, 5.3, 5.5, 6.25, 7.25, 8,...
                9, 11.5, 14, 14.6, 15.1, 15.7, 16, 18, 20];
            
            % Counts in each bin in the original array and sum to get the
            % signal in the final histogram array:  xfinal = [5,8,16];
            dx = diff(x');
            stot = s .* dx;
            etot = e .* dx;
            
            sfinal_ref = [sum(stot(1:2)); sum(stot(3:5))];
            efinal_ref = sqrt([sum(etot(1:2).^2); sum(etot(3:5).^2)]);
            
            % Rebin onto finer bins
            [sout, eout] = rebin_histogram (x, s, e, 1, xout);
            assertEqual(sout(1:2), [0;0])
            assertEqual(eout(1:2), [0;0])
            assertEqual(sout(15:16), [0;0])
            assertEqual(eout(15:16), [0;0])
            
            % Sum counts in each bin to recover counts in the final array
            dx_fine = diff(xout');
            stot_fine = sout .* dx_fine;
            etot_fine = eout .* dx_fine;
            
            sfinal = [sum(stot_fine(3:7)); sum(stot_fine(8:14))];
            efinal = sqrt([sum(etot_fine(3:7).^2); sum(etot_fine(8:14).^2)]);
            
            assertEqualToTol(sfinal_ref, sfinal, 'tol', tol)
            assertEqualToTol(efinal_ref, efinal, 'tol', tol)
            
        end
        
        %------------------------------------------------------------------
        function test_3(obj)
            % Test that multidimensional operation works
            tol = [1e-14,1e-14];

            n = [15,25,10,20];
            hist = true(size(n));
            [x,s,e] = create_testdata_nd (n, hist);
            
            x1_out = (5:3:15);
            x3_out = (1:0.3:12);
            
            % Rebin along 3rd axis, then along the 1st axis
            idim = 3;
            [s1, e1] = rebin_histogram (x{idim}, s, e, idim, x3_out);
            [s2, e2] = rebin_histogram_simple(x{idim}, s, e, idim, x3_out);
            idim = 1;
            [s1, e1] = rebin_histogram (x{idim}, s1, e1, idim, x1_out);
            [s2, e2] = rebin_histogram_simple(x{idim}, s2, e2, idim, x1_out);

            assertEqualToTol(s1, s2, 'tol', tol)
            assertEqualToTol(e1, e2, 'tol', tol)
        end
        
        %------------------------------------------------------------------
    end
    
end
