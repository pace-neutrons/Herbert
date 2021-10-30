classdef test_rebin_values_from_descriptor_OneInterval < TestCaseWithSave
    % Test the individual descriptor generators in a full binning
    % description
    
    methods
        %--------------------------------------------------------------------------
        function self = test_rebin_values_from_descriptor_OneInterval (name)
            self@TestCaseWithSave(name);
            
            self.save()
        end
        
        %==========================================================================
        % Equally spaced, origin is beginning of interval
        %--------------------------------------------------------------------------
        function test_1 (self)
            [np, xout] = IX_dataset.test_gateway('values_equal_steps',...
                10, 2, 18-1e-4, 'x1');
            xout_ref = [10, 12, 14, 16];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_2 (self)
            [np, xout] = IX_dataset.test_gateway('values_equal_steps',...
                10, 2, 18-1e-10, 'x1');
            xout_ref = [10, 12, 14, 16];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_3 (self)
            [np, xout] = IX_dataset.test_gateway('values_equal_steps',...
                10, 2, 18, 'x1');
            xout_ref = [10, 12, 14, 16];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_4 (self)
            [np, xout] = IX_dataset.test_gateway('values_equal_steps',...
                10, 2, 18+1e-10, 'x1');
            xout_ref = [10, 12, 14, 16];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_5 (self)
            [np, xout] = IX_dataset.test_gateway('values_equal_steps',...
                10, 2, 18+1e-8, 'x1');
            xout_ref = [10, 12, 14, 16, 18];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_6 (self)
            [np, xout] = IX_dataset.test_gateway('values_equal_steps',...
                10, 2, 10, 'x1');
            xout_ref = [];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %==========================================================================
        % Equally spaced, origin is end of interval
        function test_7 (self)
            [np, xout] = IX_dataset.test_gateway('values_equal_steps',...
                10-1e-4, 2, 18, 'x2');
            xout_ref = [10-1e-4, 10, 12, 14, 16];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_8 (self)
            [np, xout] = IX_dataset.test_gateway('values_equal_steps',...
                10-1e-11, 2, 18, 'x2');
            xout_ref = [10-1e-11, 12, 14, 16];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_9 (self)
            [np, xout] = IX_dataset.test_gateway('values_equal_steps',...
                10, 2, 18, 'x2');
            xout_ref = [10, 12, 14, 16];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_10 (self)
            [np, xout] = IX_dataset.test_gateway('values_equal_steps',...
                10+1e-11, 2, 18, 'x2');
            xout_ref = [10+1e-11, 12, 14, 16];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_11 (self)
            [np, xout] = IX_dataset.test_gateway('values_equal_steps',...
                10+1e-4, 2, 18, 'x2');
            xout_ref = [10+1e-4, 12, 14, 16];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_12 (self)
            [np, xout] = IX_dataset.test_gateway('values_equal_steps',...
                10, 2, 10, 'x2');
            xout_ref = [];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %==========================================================================
        % Equally spaced, midpoints centred on zero
        % ------------------------------------------
        function test_13 (self)
            [np, xout] = IX_dataset.test_gateway('values_equal_steps',...
                -3-1e-6, 2, 7-1e-6, 'c0');
            xout_ref = [-3-1e-6, -3, -1, 1, 3, 5];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_14 (self)
            [np, xout] = IX_dataset.test_gateway('values_equal_steps',...
                -3-1e-11, 2, 7-1e-6, 'c0');
            xout_ref = [-3-1e-11, -1, 1, 3, 5];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_15 (self)
            [np, xout] = IX_dataset.test_gateway('values_equal_steps',...
                -3, 2, 7-1e-6, 'c0');
            xout_ref = [-3, -1, 1, 3, 5];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_16 (self)
            [np, xout] = IX_dataset.test_gateway('values_equal_steps',...
                -3+1e-11, 2, 7-1e-6, 'c0');
            xout_ref = [-3+1e-11, -1, 1, 3, 5];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_17 (self)
            [np, xout] = IX_dataset.test_gateway('values_equal_steps',...
                -2.9, 2, 7-1e-6, 'c0');
            xout_ref = [-2.9, -1, 1, 3, 5];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_18 (self)
            [np, xout] = IX_dataset.test_gateway('values_equal_steps',...
                -2.9, 2, 7-1e-11, 'c0');
            xout_ref = [-2.9, -1, 1, 3, 5];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_19 (self)
            [np, xout] = IX_dataset.test_gateway('values_equal_steps',...
                -2.9, 2, 7, 'c0');
            xout_ref = [-2.9, -1, 1, 3, 5];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_20 (self)
            [np, xout] = IX_dataset.test_gateway('values_equal_steps',...
                -2.9, 2, 7+1e-11, 'c0');
            xout_ref = [-2.9, -1, 1, 3, 5];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_21 (self)
            [np, xout] = IX_dataset.test_gateway('values_equal_steps',...
                -2.9, 2, 7+1e-6, 'c0');
            xout_ref = [-2.9, -1, 1, 3, 5, 7];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        % Negative interval
        % -----------------
        function test_22 (self)
            [np, xout] = IX_dataset.test_gateway('values_equal_steps',...
                10, 2, 4, 'x1');
            xout_ref = [];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %==========================================================================
        % Contained values increasing
        %--------------------------------------------------------------------------
        
        function test_23 (self)
            xref = [];
            [np, xout] = IX_dataset.test_gateway ('values_contained_points',...
                3, xref, 6, '[)');
            xout_ref = 3;
            assertEqual (np,1)
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_24 (self)
            xref = [0,1,2];
            [np, xout] = IX_dataset.test_gateway ('values_contained_points',...
                3, xref, 6, '[)');
            xout_ref = 3;
            assertEqual (np,1)
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_25 (self)
            xref = [0,10];
            [np, xout] = IX_dataset.test_gateway ('values_contained_points',...
                3, xref, 6, '[)');
            xout_ref = 3;
            assertEqual (np,1)
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_26 (self)
            xref = [10,11,12];
            [np, xout] = IX_dataset.test_gateway ('values_contained_points',...
                3, xref, 6, '[)');
            xout_ref = 3;
            assertEqual (np,1)
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_27 (self)
            xref = 1:10;
            [np, xout] = IX_dataset.test_gateway ('values_contained_points',...
                3, xref, 6, '[)');
            xout_ref = [3,4,5];
            assertEqual (np,3)
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_28 (self)
            xref = 1:10;
            [np, xout] = IX_dataset.test_gateway ('values_contained_points',...
                3, xref, 6.1, '[)');
            xout_ref = [3,4,5,6];
            assertEqual (np,4)
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_29 (self)
            xref = 1:10;
            [np, xout] = IX_dataset.test_gateway ('values_contained_points',...
                3, xref, 3, '[)');
            xout_ref = [];
            assertEqual (np,0)
            assertEqual (xout, xout_ref);
        end
        
        %--------------------------------------------------------------------------
        % Negative interval
        % -----------------
        function test_30 (self)
            xref = [];
            [np, xout] = IX_dataset.test_gateway ('values_contained_points',...
                6, xref, 3, '[)');
            xout_ref = [];
            assertEqual (np,0)
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_31 (self)
            xref = 1:10;
            [np, xout] = IX_dataset.test_gateway ('values_contained_points',...
                6, xref, 3, '[)');
            xout_ref = [];
            assertEqual (np,0)
            assertEqual (xout, xout_ref)
        end
        
        %==========================================================================
        % Logarithmic, origin beginning of interval
        % -----------------------------------------
        
        function test_32 (self)
            [np, xout] = IX_dataset.test_gateway ('values_logarithmic_steps',...
                10, 1, 80-1e-6, 'x1');
            xout_ref = [10, 20, 40];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_33 (self)
            [np, xout] = IX_dataset.test_gateway ('values_logarithmic_steps',...
                10, 1, 80-1e-8, 'x1');
            xout_ref = [10, 20, 40];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_34 (self)
            [np, xout] = IX_dataset.test_gateway ('values_logarithmic_steps',...
                10, 1, 80+1e-10, 'x1');
            xout_ref = [10, 20, 40];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_35 (self)
            [np, xout] = IX_dataset.test_gateway ('values_logarithmic_steps',...
                10, 1, 80+1e-8, 'x1');
            xout_ref = [10, 20, 40, 80];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_36 (self)
            [np, xout] = IX_dataset.test_gateway ('values_logarithmic_steps',...
                10, 1, 80+1e-6, 'x1');
            xout_ref = [10, 20, 40, 80];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %==========================================================================
        % Logarithmic, origin end of interval
        % -----------------------------------------
        function test_37 (self)
            [np, xout] = IX_dataset.test_gateway ('values_logarithmic_steps',...
                10+1e-6, 1, 80, 'x2');
            xout_ref = [10+1e-6, 20, 40];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_38 (self)
            [np, xout] = IX_dataset.test_gateway ('values_logarithmic_steps',...
                10, 1, 80, 'x2');
            xout_ref = [10, 20, 40];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_39 (self)
            [np, xout] = IX_dataset.test_gateway ('values_logarithmic_steps',...
                10-1e-10, 1, 80, 'x2');
            xout_ref = [10-1e-10, 20, 40];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_40 (self)
            [np, xout] = IX_dataset.test_gateway ('values_logarithmic_steps',...
                10-1e-6, 1, 80, 'x2');
            xout_ref = [10-1e-6, 10, 20, 40];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %==========================================================================
        % Logarithmic, centred on unity
        % -----------------------------------------
        function test_41 (self)
            [np, xout] = IX_dataset.test_gateway ('values_logarithmic_steps',...
                (1/3)+1e-6, 1, 16/3, 'c0');
            xout_ref = [(1/3)+1e-6, 2/3, 4/3, 8/3];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_42 (self)
            [np, xout] = IX_dataset.test_gateway ('values_logarithmic_steps',...
                (1/3)-1e-11, 1, 16/3, 'c0');
            xout_ref = [(1/3)-1e-11, 2/3, 4/3, 8/3];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_43 (self)
            [np, xout] = IX_dataset.test_gateway ('values_logarithmic_steps',...
                (1/3)-1e-6, 1, 16/3, 'c0');
            xout_ref = [(1/3)-1e-6, 1/3, 2/3, 4/3, 8/3];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_44 (self)
            [np, xout] = IX_dataset.test_gateway ('values_logarithmic_steps',...
                (1/3)-1e-6, 1, (16/3)+1e-11, 'c0');
            xout_ref = [(1/3)-1e-6, 1/3, 2/3, 4/3, 8/3];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_45 (self)
            [np, xout] = IX_dataset.test_gateway ('values_logarithmic_steps',...
                (1/3)-1e-6, 1, (16/3)+1e-6, 'c0');
            xout_ref = [(1/3)-1e-6, 1/3, 2/3, 4/3, 8/3, 16/3];
            assertEqual (np, numel(xout))
            assertEqual (xout, xout_ref)
        end
        
        %--------------------------------------------------------------------------
    end
end
