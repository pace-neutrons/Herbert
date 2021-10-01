classdef test_average_points_1 <  TestCaseWithSave
    % Test class to test point averaging algorithm
    
    methods
        function obj = test_average_points_1 (name)
            obj@TestCaseWithSave(name);
            
            obj.save()
        end
        
        %------------------------------------------------------------------
        function test_1(obj)
            % test two output bin: one starting before the data, the other
            % entirely within the data. Tests also how a point on the outer
            % boundary is included for the first bin (i.e. within the data)
            % and the second bin (outermost boundary).
            x = 1:10;
            s = (1010:10:1100)';
            e = (10:10:100)';
            
            xout = [0,4,8];
            
            xave_ref = [2, 6];
            sout_ref = [sum(s(1:3)) / 3; sum(s(4:8)) / 5];
            eout_ref = [sqrt(sum(e(1:3).^2)) / 3; sqrt(sum(e(4:8).^2)) / 5];
            
            [xave, sout, eout] = average_points (x, s, e, 1, xout);
            assertEqualToTol(xave, xave_ref, 'tol', [1e-12,1e-12])
            assertEqualToTol(sout, sout_ref, 'tol', [1e-12,1e-12])
            assertEqualToTol(eout, eout_ref, 'tol', [1e-12,1e-12])
            
        end
        
        %------------------------------------------------------------------
        function test_2(obj)
            % Tests first output bin entirely within the data, the second
            % finishes outside the data.
            x = 1:10;
            s = (1010:10:1100)';
            e = (10:10:100)';
            
            xout = [4,9,12];
            
            xave_ref = [6, 9.5];
            sout_ref = [sum(s(4:8)) / 5; 1095];
            eout_ref = [sqrt(sum(e(4:8).^2)) / 5; sqrt(90^2 + 100^2)/2];
            
            [xave, sout, eout] = average_points (x, s, e, 1, xout);
            assertEqualToTol(xave, xave_ref, 'tol', [1e-12,1e-12])
            assertEqualToTol(sout, sout_ref, 'tol', [1e-12,1e-12])
            assertEqualToTol(eout, eout_ref, 'tol', [1e-12,1e-12])
            
        end
        
        %------------------------------------------------------------------
        function test_3(obj)
            % Tests output bins that are empty before the data, within the
            % data, and beyond the data. Also a bin with one point only.
            x = [1, 1.8, 2.5, 4, 4.5, 6, 6.6, 8, 9, 10];
            s = (1010:10:1100)';
            e = (10:10:100)';
            
            xout = [-2, 0, 3.5, 3.7, 9, 10, 13, 15];
             
            xave_ref = [-1, sum(x(1:3))/3, 3.6, sum(x(4:8))/5, 9, 10, 14];
            sout_ref = [0; sum(s(1:3))/3; 0; sum(s(4:8))/5; 1090; 1100; 0];
            eout_ref = [0; sqrt(sum(e(1:3).^2))/3; 0;...
                sqrt(sum(e(4:8).^2))/5; 90; 100; 0];
            filled = logical([0,1,0,1,1,1,0]);
            
            [xave, sout, eout] = average_points (x, s, e, 1, xout, true);
            assertEqualToTol(xave, xave_ref, 'tol', [1e-12,1e-12])
            assertEqualToTol(sout, sout_ref, 'tol', [1e-12,1e-12])
            assertEqualToTol(eout, eout_ref, 'tol', [1e-12,1e-12])
            
            [xave, sout, eout] = average_points (x, s, e, 1, xout);
            assertEqualToTol(xave, xave_ref(filled), 'tol', [1e-12,1e-12])
            assertEqualToTol(sout, sout_ref(filled), 'tol', [1e-12,1e-12])
            assertEqualToTol(eout, eout_ref(filled), 'tol', [1e-12,1e-12])
            
        end
        
        %------------------------------------------------------------------
    end
    
end
