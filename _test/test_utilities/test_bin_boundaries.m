classdef test_bin_boundaries <  TestCaseWithSave
    % Test class to test bin_boundaries methods
    %
    % Modified T.G.Perring 202-07-18 as part of refactoring of IX_dataset
    %   - axis values are now columns
    %   - IX_dataset properties valid_ and error_mess_ deleted, so that
    %     get_valid and associated methods no longer exist. Objects are 
    %     always valid if they were created.
    
    properties
        % Exact unequally spaced integer boundaries and centres
        xb1     % a few bins
        xc1
        
        xb2     % O(50,000) bins
        xc2
        
        % Exact unequally spaced integer boundaries and centres
        % Some bin(s) of zero width
        xb1_0   % a few bins, one of zero width
        xc1_0
        
        xb2_0   % O(50,000) bins, O(5,000) with zero width
        xc2_0
        
        % Set of exact integer equally spaced bin boundaries and centres
        xb3_eq  % a few bins
        xc3_eq
        
        xb4_eq  % O(50,000) bins
        xc4_eq
    end
    
    methods
        function obj = test_bin_boundaries (name)
            obj@TestCaseWithSave(name);

            % Exact integer boundaries and centres
            obj.xb1 = [-6, -4, 0, 2, 8, 10, 20];
            obj.xc1 = [-5, -2, 1, 5, 9, 15];
            
            % Exact integer boundaries and centres, with a bin of zero width
            obj.xb1_0 = [-6, -4, 0, 2, 8, 10, 10, 20];
            obj.xc1_0 = [-5, -2, 1, 5, 9, 10, 15];
            
            % Big set of exact bin boundaries and centres
            rng(0);    % set random number generator seed
            obj.xb2_0 = 2*sort(round(200000*rand(1,50000)));  % many bin widths = 0
            obj.xb2 = unique(obj.xb2_0);    % all bins widths > 0
            
            obj.xc2_0 = (obj.xb2_0(1:end-1)+obj.xb2_0(2:end))/2;
            obj.xc2 = (obj.xb2(1:end-1)+obj.xb2(2:end))/2;
            
            % Set of exact integer equally spaced bin boundaries and centres
            obj.xb3_eq = -15:4:25;
            obj.xc3_eq = obj.xb3_eq(1:end-1)+2;
            
            obj.xb4_eq = -1000:10:500000;   % big set
            obj.xc4_eq = obj.xb4_eq(1:end-1) + 5;
            
            obj.save()
        end
        
        %------------------------------------------------------------------
        function test_1(obj)
            % A few exact integer equally spaced bin boundaries and centres
            xb = bin_boundaries (obj.xc3_eq);
            assertEqual(xb, obj.xb3_eq);
            
            % Flip vectors:
            xb = bin_boundaries (obj.xc3_eq');
            assertEqual(xb, obj.xb3_eq');
        end
        
        %------------------------------------------------------------------
        function test_2(obj)
            % O(50000) exact integer equally spaced bin boundaries and centres
            xb = bin_boundaries (obj.xc4_eq);
            assertEqual(xb, obj.xb4_eq);
            
            % Flip vectors:
            xb = bin_boundaries (obj.xc4_eq');
            assertEqual(xb, obj.xb4_eq');
        end
        
        %------------------------------------------------------------------
        function test_3(obj)
            % All bins are zero width
            xb_ref = (exp(1)/2.3)*ones(1,1000);
            xc_ref = xb_ref(1:end-1);
            
            xb = bin_boundaries (xc_ref);
            assertEqual(xb, xb_ref);
            
            % Flip vectors:
            xb = bin_boundaries (xc_ref');
            assertEqual(xb, xb_ref');
        end
        
        %------------------------------------------------------------------
        function test_4(obj)
            % Single bin centre
            xb_ref = [37.25, 38.25];
            xc_ref = 37.75;
            
            xb = bin_boundaries (xc_ref);
            assertEqual(xb, xb_ref);
            
            % Flip vectors:
            xb = bin_boundaries (xc_ref');
            assertEqual(xb, xb_ref);    % still output as a row
        end
        
        %------------------------------------------------------------------
        function test_5(obj)
            % Two points - so must be caught by the algorithm that deals
            % with equal bins
            xc_ref = [37.25, 38.25];
            xb_ref = [36.75, 37.75, 38.75];
            
            xb = bin_boundaries (xc_ref);
            assertEqual(xb, xb_ref);
            
            % Flip vectors:
            xb = bin_boundaries (xc_ref');
            assertEqual(xb, xb_ref');
        end
        
        %------------------------------------------------------------------
        function test_6(obj)
            % Small set exact integer unequally spaced bin boundaries and centres
            [xb,status] = bin_boundaries (obj.xc1);
            assertTrue(status,'Unexpected failure to compute bin boundaries')
            assertEqual((xb(2:end)+xb(1:end-1))/2, obj.xc1);
            
            % Flip vectors:
            [xb,status] = bin_boundaries (obj.xc1');
            assertTrue(status,'Unexpected failure to compute bin boundaries')
            assertEqual((xb(2:end)+xb(1:end-1))/2, obj.xc1');
        end
        
        %------------------------------------------------------------------
        function test_7(obj)
            % O(50000) exact integer unequally spaced bin boundaries and centres
            [xb,status] = bin_boundaries (obj.xc2);
            assertTrue(status,'Unexpected failure to compute bin boundaries')
            assertEqual((xb(2:end)+xb(1:end-1))/2, obj.xc2);
            
            % Flip vectors:
            [xb,status] = bin_boundaries (obj.xc2');
            assertTrue(status,'Unexpected failure to compute bin boundaries')
            assertEqual((xb(2:end)+xb(1:end-1))/2, obj.xc2');
        end
        
        %------------------------------------------------------------------
        function test_8(obj)
            % Small set exact integer unequally spaced bin boundaries and centres
            % Some bins zero width
            [xb,status] = bin_boundaries (obj.xc1_0);
            assertTrue(status,'Unexpected failure to compute bin boundaries')
            assertEqual((xb(2:end)+xb(1:end-1))/2, obj.xc1_0);
            
            % Flip vectors:
            [xb,status] = bin_boundaries (obj.xc1_0');
            assertTrue(status,'Unexpected failure to compute bin boundaries')
            assertEqual((xb(2:end)+xb(1:end-1))/2, obj.xc1_0');
        end
        
        %------------------------------------------------------------------
        function test_9(obj)
            % O(50000) exact integer unequally spaced bin boundaries and centres
            % Some bins zero width
            [xb,status] = bin_boundaries (obj.xc2_0);
            assertTrue(status,'Unexpected failure to compute bin boundaries')
            assertEqual((xb(2:end)+xb(1:end-1))/2, obj.xc2_0);
            
            % Flip vectors:
            [xb,status] = bin_boundaries (obj.xc2_0');
            assertTrue(status,'Unexpected failure to compute bin boundaries')
            assertEqual((xb(2:end)+xb(1:end-1))/2, obj.xc2_0');
        end
        
        %------------------------------------------------------------------
        function test_10(obj)
            % No solution possible with true bin centres
            xc = [2,3,8,9];
            xmid = [1.5, 2.5, 5.5, 8.5, 9.5];
            
            [xb, status] = bin_boundaries (xc);
            assertFalse(status,'Status should be false')
            assertEqual(xb, xmid);
            
            % Flip vectors:
            [xb, status] = bin_boundaries (xc');
            assertFalse(status,'Status should be false')
            assertEqual(xb, xmid');
        end
        
        %------------------------------------------------------------------
    end
end
