classdef test_rebin_values_from_descriptor < TestCaseWithSave
    % Test generation of bin boundaries from binning descriptors
    properties
        xref
        xref_pair
        xref_pnt
        xref_allsame
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_rebin_values_from_descriptor (name)
            self@TestCaseWithSave(name);
            
            % Conventional looking xref
            self.xref = [-10, -8, -5, -4, -1, 0, 2, 6, 10, 12];
            % Pair
            self.xref_pair = [8,9];
            % Value all the same
            self.xref_pnt = [4,4,5,5,5,5,5,7,7,7,7];
            % Value all the same
            self.xref_allsame = [5,5,5,5,5];
            
            
            self.save()
        end
        
        %==========================================================================
        % Simple finite tests
        %--------------------------------------------------------------------------
        function test_1 (self)
            is_boundaries = true;
            xout = IX_dataset.test_gateway('rebin_values_from_descriptor',...
                [5, 0.1, 6, 0.2, 7], is_boundaries);
            tol = [1e-14,1e-14];
            assertEqualToTol (xout, [(5:0.1:5.9999), (6:0.2:7)], tol)
        end
        
        %--------------------------------------------------------------------------
        function test_2 (self)
            is_boundaries = true;
            ishist = true;
            xout = IX_dataset.test_gateway('rebin_values_from_descriptor',...
                [4.5, 0, 6, 2, 8], is_boundaries, [3,4,5,5.5,6.5,7.5,8.5], ishist);
            tol = [1e-14,1e-14];
            assertEqualToTol (xout, [4.5,5,5.5,6,8], tol)
        end
        
        %--------------------------------------------------------------------------
        function test_3 (self)
            is_boundaries = true;
            ishist = true;
            xout = IX_dataset.test_gateway('rebin_values_from_descriptor',...
                [6.1,0,6.4], is_boundaries, [3,4,5,5.5,6.5,7.5,8.5], ishist);
            tol = [1e-14,1e-14];
            assertEqualToTol (xout, [6.1,6.4], tol)
        end

        
        %==========================================================================
        % Infinite limits and one or both ends
        %--------------------------------------------------------------------------
        function test_i1 (self)
            is_boundaries = true;
            ishist = true;
            xout = IX_dataset.test_gateway('rebin_values_from_descriptor',...
                [5, 1, 6, 2, Inf], is_boundaries, [3,4,5,5.5], ishist);
            assertEqual (xout, [5,6,Inf])
        end
        
        %--------------------------------------------------------------------------
        function test_i2 (self)
            is_boundaries = true;
            ishist = true;
            xout = IX_dataset.test_gateway('rebin_values_from_descriptor',...
                [5, 1, 6, 2, Inf], is_boundaries, [3,4,5,5.5,6], ishist);
            assertEqual (xout, [5,6,Inf])
        end
        
        %--------------------------------------------------------------------------
        function test_i3 (self)
            is_boundaries = true;
            ishist = true;
            tol = 1e-4;
            xout = IX_dataset.test_gateway('rebin_values_from_descriptor',...
                [5, 1, 6, 2, Inf], is_boundaries, [3,4,5,5.5,6.002], ishist, tol);
            assertEqual (xout, [5,6,Inf])
        end
        
        %--------------------------------------------------------------------------
        function test_i4 (self)
            is_boundaries = true;
            ishist = true;
            tol = 0.1;
            xout = IX_dataset.test_gateway('rebin_values_from_descriptor',...
                [5, 1, 6, 2, Inf], is_boundaries, [3,4,5,5.5,6.002], ishist, tol);
            assertEqual (xout, [5,6,Inf])
        end
        
        %--------------------------------------------------------------------------
        function test_i4b (self)
            is_boundaries = true;
            ishist = true;
            tol = 0.1;
            xout = IX_dataset.test_gateway('rebin_values_from_descriptor',...
                [5, 1, 6, 2, Inf], is_boundaries, [3,4,5,5.5,5.99], ishist, tol);
            assertEqual (xout, [5,6,Inf])
        end
        
        %--------------------------------------------------------------------------
        function test_i5 (self)
            is_boundaries = true;
            ishist = true;
            xout = IX_dataset.test_gateway('rebin_values_from_descriptor',...
                [-Inf, 0.5, 6, 0.5, Inf], is_boundaries, [4.2,5.2,6.2,7.3], ishist);
            tol = [1e-14,1e-14];
            assertEqualToTol (xout, [-Inf,4.5,5,5.5,6,6.5,7,Inf], tol)
        end
        
        %--------------------------------------------------------------------------
        function test_i6 (self)
            is_boundaries = false;
            ishist = false;
            xout = IX_dataset.test_gateway('rebin_values_from_descriptor',...
                [-Inf, 0.5, 6, 0.5, Inf], is_boundaries, [4.2,5.2,6.2,7.3], ishist);
            tol = [1e-14,1e-14];
            assertEqualToTol (xout, [-Inf,4.5,5,5.5,6,6.5,7,Inf], tol)
        end
        
        %--------------------------------------------------------------------------
        function test_i6a (self)
            is_boundaries = true;
            ishist = false;
            xout = IX_dataset.test_gateway('rebin_values_from_descriptor',...
                [-Inf, 0.5, 6, 0.5, Inf], is_boundaries, [4.2,5.2,6.2,7.3], ishist);
            tol = [1e-14,1e-14];
            assertEqualToTol (xout, [-Inf,4.5,5,5.5,6,6.5,7,Inf], tol)
        end
        
        %--------------------------------------------------------------------------
        function test_i7 (self)
            is_boundaries = false;
            ishist = false;
            xout = IX_dataset.test_gateway('rebin_values_from_descriptor',...
                [-Inf, 0.2, Inf], is_boundaries, [5,5,5,5,5], ishist);
            tol = [1e-14,1e-14];
            assertEqualToTol (xout, [-Inf, Inf], tol)
        end
        
        %--------------------------------------------------------------------------
        function test_i8 (self)
            is_boundaries = true;
            ishist = true;
            xout = IX_dataset.test_gateway('rebin_values_from_descriptor',...
                [-Inf, 0.2, Inf], is_boundaries, [5.35,6], ishist);
            tol = [1e-14,1e-14];
            assertEqualToTol (xout, [-Inf,5.5,5.7,5.9,Inf], tol)
        end
        
        %--------------------------------------------------------------------------
        function test_i8a (self)
            is_boundaries = false;
            ishist = true;
            xout = IX_dataset.test_gateway('rebin_values_from_descriptor',...
                [-Inf, 0.2, Inf], is_boundaries, [5.35,6], ishist);
            tol = [1e-14,1e-14];
            assertEqualToTol (xout, [-Inf,5.4,5.6,5.8,Inf], tol)
        end
        
        %--------------------------------------------------------------------------
        function test_i11 (self)
            is_boundaries = false;
            ishist = false;
            xout = IX_dataset.test_gateway('rebin_values_from_descriptor',...
                [-Inf, 0, 5, 0, Inf], is_boundaries, [5,5,5], ishist);
            tol = [1e-14,1e-14];
            assertEqualToTol (xout, [-Inf, 5, Inf], tol)
        end
        
        %--------------------------------------------------------------------------
    end
end