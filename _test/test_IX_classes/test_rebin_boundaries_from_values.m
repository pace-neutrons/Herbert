classdef test_rebin_boundaries_from_values < TestCaseWithSave
    % Test generation of bin boundaries from binning descriptors
    
    methods
        %--------------------------------------------------------------------------
        function self = test_rebin_boundaries_from_values (name)
            self@TestCaseWithSave(name);            
            
            self.save()
        end
        
        %==========================================================================
        %
        %--------------------------------------------------------------------------
        function test_1 (self)
            % Simple passing of bin boundaries, and generation from bin centres
            is_boundaries = true;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [14,17,19], is_boundaries);
            assertEqual (xout, [14,17,19])
            
            is_boundaries = false;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [14,17,19], is_boundaries);
            assertEqual (xout, [12.25, 15.75, 18.25, 19.75])
        end
        
        %--------------------------------------------------------------------------
        function test_2 (self)
            % Test that two equal bin boundaries go through unchallenged
            is_boundaries = true;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [14,14], is_boundaries);
            assertEqual (xout, [14,14])
        end
        
        %--------------------------------------------------------------------------
        function test_3 (self)
            % Resolve -Inf for bin boundaries and centres
            is_boundaries = true;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [-Inf, -10, -8, -6], is_boundaries, [-12]);
            assertEqual (xout, [-12, -10, -8, -6])
            
            is_boundaries = false;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [-Inf, -10, -8, -6], is_boundaries, [-12]);
            assertEqual (xout, [-12, -11, -9, -7, -5])
        end
        
        %--------------------------------------------------------------------------
        function test_4 (self)
            % Check tolerance measure
            is_boundaries = true;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [-Inf, -10, -8, -6], is_boundaries, [-10.1:3:15]);
            assertEqual (xout, [-10.1, -10, -8, -6])
            
            is_boundaries = true;
            tol = 0.2;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [-Inf, -10, -8, -6], is_boundaries, [-10.1:3:15], tol);
            assertEqual (xout, [-10.1, -8, -6])
        end
        
        %--------------------------------------------------------------------------
        function test_5 (self)
            % Data inside generated bin boundaries
            is_boundaries = false;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [-Inf,10,12,14], is_boundaries, [9.5,13,17]);
            assertEqual (xout, [9.5, 11, 13, 15])
            
            is_boundaries = false;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [-Inf,10,12,14], is_boundaries, [10.5,13,17]);
            assertEqual (xout, [10, 11, 13, 15])
        end
        
        %--------------------------------------------------------------------------
        function test_5b (self)
            % Data inside generated bin boundaries
            is_boundaries = true;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [-Inf,10,12,14], is_boundaries, [9.5,13,17]);
            assertEqual (xout, [9.5, 10, 12, 14])
            
            is_boundaries = true;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [-Inf,10,12,14], is_boundaries, [10.5,13,17]);
            assertEqual (xout, [10, 12, 14])
        end
        
        %--------------------------------------------------------------------------
        function test_5c (self)
            % Data inside generated bin boundaries
            is_boundaries = false;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [10,12,14,Inf], is_boundaries, [9.5,13,14.5]);
            assertEqual (xout, [9, 11, 13, 14.5])
            
            is_boundaries = false;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [10,12,14,Inf], is_boundaries, [10.5,13,13.5]);
            assertEqual (xout, [9, 11, 13, 14])
        end
        
        %--------------------------------------------------------------------------
        function test_5d (self)
            % Data inside generated bin boundaries
            is_boundaries = true;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [10,12,14,Inf], is_boundaries, [9.5,13,14.5]);
            assertEqual (xout, [10,12,14,14.5])
            
            is_boundaries = true;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [10,12,14,Inf], is_boundaries, [10.5,13,13.5]);
            assertEqual (xout, [10,12,14])
        end
        
        %--------------------------------------------------------------------------
        function test_6 (self)
            % Check [-Inf,Inf] for bin boundaries and centres. Should be
            % the same.
            is_boundaries = true;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [-Inf, Inf], is_boundaries, [-12:3:15]);
            assertEqual (xout, [-12,15])
            
            is_boundaries = false;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [-Inf, Inf], is_boundaries, [-12:3:15]);
            assertEqual (xout, [-12, 15])
        end
        
        %--------------------------------------------------------------------------
        function test_7 (self)
            % Cases when all data positions are the same
            is_boundaries = true;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [-Inf, 5, Inf], is_boundaries, [5, 5, 5, 5, 5, 5]);
            assertEqual (xout, [5, 5])
            
            is_boundaries = false;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [-Inf, 5, Inf], is_boundaries, [5, 5, 5, 5, 5, 5]);
            assertEqual (xout, [5, 5])
        end
        %--------------------------------------------------------------------------
        function test_8 (self)
            % Cases when all data positions are the same
            is_boundaries = true;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [-Inf, Inf], is_boundaries, [5]);
            assertEqual (xout, [5, 5])
            
            is_boundaries = false;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [-Inf, Inf], is_boundaries, [5]);
            assertEqual (xout, [5, 5])
        end
        %--------------------------------------------------------------------------
        function test_9 (self)
            % Cases when values outside range of data
            is_boundaries = true;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [6, Inf], is_boundaries, [5,5.5,5.99]);
            assertEqual (xout, [6,6])
            
            is_boundaries = false;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [6, Inf], is_boundaries, [5,5.5,5.99]);
            assertEqual (xout, [6,6])
        end
        %--------------------------------------------------------------------------
        function test_10 (self)
            % Cases when values outside range of data
            is_boundaries = true;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [-Inf, 4], is_boundaries, [5,5.5,5.99]);
            assertEqual (xout, [4,4])
            
            is_boundaries = false;
            xout = IX_dataset.test_gateway('rebin_boundaries_from_values',...
                [-Inf, 4], is_boundaries, [5,5.5,5.99]);
            assertEqual (xout, [4,4])
        end
        %--------------------------------------------------------------------------
    end
end
