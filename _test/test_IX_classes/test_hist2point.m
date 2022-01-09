classdef test_hist2point < TestCaseWithSave
    % Tests test_hist2point objects
    properties
        w1h_dist
        w1h_nodist
        w1p
        
        w2hh_dd
        w2hh_nd
        w2hh_dn
        w2hh_nn
        w2ph_nn
        w2hp_nd
        w2pp_dd
        w2pp_nd
        
        w3hhh_dnd
        w3hhp_ndn
        w3php_dnd
        w3ppp_ddd
        w3php_ddn
        
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_hist2point (name)
            self@TestCaseWithSave(name);
            
            % ----------------------------------------
            % Make some 1D datasets
            % ----------------------------------------
            x1h = [1, 2, 4, 6, 7, 9, 15];
            dx1 = diff(x1h);
            x1p = [1.5, 3, 5, 6.5, 8, 12];
            s1 = [10, 20, 30, 40, 50, 60];
            e1 = [2, 4, 6, 8, 10, 12];
            
            % Distribution: counts per unit x-axis
            self.w1h_dist = IX_dataset_1d (x1h, s1, e1, 'T', 'x', 'S', true);
            
            % Non-distribution: total counts in each bin
            self.w1h_nodist = IX_dataset_1d (x1h, s1.*dx1, e1.*dx1, 'T', 'x', 'S', false);
            
            % Output of hist2point for *ALL* the above
            self.w1p = IX_dataset_1d (x1p, s1, e1, 'T', 'x', 'S', true);

            
            % ----------------------------------------
            % Make some 2D datasets
            % ----------------------------------------
            x1h = [1, 2, 4, 6, 7, 9, 15];
            dx1 = diff(x1h);
            x1p = 0.5*(x1h(2:end)+x1h(1:end-1));
            n1 = numel(x1p);
            
            x2h = [11, 14, 18, 19, 23, 25, 35, 40, 42];
            dx2 = diff(x2h);
            x2p = 0.5*(x2h(2:end)+x2h(1:end-1));
            n2 = numel(x2p);
            
            rng(0); % Set seed for reproducible 'random' numbers
            s2 = rand(n1,n2);
            e2 = rand(n1,n2);
            
            d2n_1 = repmat(dx1(:),1,n2);    % distribution to non-distribution for axis 1
            d2n_2 = repmat(dx2,n1,1);       % distribution to non-distribution for axis 2
            
            % Various datasets, hist/point and non-distribution/sistribution on the axes
            self.w2hh_dd = IX_dataset_2d (x1h, x2h, s2, e2,...
                'T', 'x', 'y', 'S', true, true);
            self.w2hh_nd = IX_dataset_2d (x1h, x2h, s2.*d2n_1, e2.*d2n_1,...
                'T', 'x', 'y', 'S', false, true);
            self.w2hh_dn = IX_dataset_2d (x1h, x2h, s2.*d2n_2, e2.*d2n_2,...
                'T', 'x', 'y', 'S', true, false);
            self.w2hh_nn = IX_dataset_2d (x1h, x2h, s2.*d2n_1.*d2n_2, e2.*d2n_1.*d2n_2,...
                'T', 'x', 'y', 'S', false, false);

            self.w2ph_nn = IX_dataset_2d (x1p, x2h, s2.*d2n_2, e2.*d2n_2,...
                'T', 'x', 'y', 'S', false, false);
            self.w2hp_nd  = IX_dataset_2d (x1h, x2p, s2.*d2n_1, e2.*d2n_1,...
                'T', 'x', 'y', 'S', false, true);
            
            % Output of hist2point for different cases of the above
            self.w2pp_dd = IX_dataset_2d (x1p, x2p, s2, e2, 'T', 'x', 'y', 'S', true, true);
            self.w2pp_nd = IX_dataset_2d (x1p, x2p, s2, e2, 'T', 'x', 'y', 'S', false, true);

            
            % ----------------------------------------
            % Make some 3D datasets
            % ----------------------------------------
            x1h = [1, 2, 4, 6, 7, 9, 15];
            dx1 = diff(x1h);
            x1p = 0.5*(x1h(2:end)+x1h(1:end-1));
            n1 = numel(x1p);
            
            x2h = [11, 14, 18, 19, 23, 25, 35, 40, 42];
            dx2 = diff(x2h);
            x2p = 0.5*(x2h(2:end)+x2h(1:end-1));
            n2 = numel(x2p);
            
            x3h = [211, 224, 238, 249, 253, 265, 275, 280, 292, 300, 315, 322];
            dx3 = diff(x3h);
            x3p = 0.5*(x3h(2:end)+x3h(1:end-1));
            n3 = numel(x3p);
            
            rng(0); % Set seed for reproducible 'random' numbers
            s3 = rand(n1,n2,n3);
            e3 = rand(n1,n2,n3);
            
            d2n_1 = repmat(dx1(:),1,n2,n3);     % distribution to non-distribution for axis 1
            d2n_2 = repmat(dx2,n1,1,n3);        % distribution to non-distribution for axis 2
            d2n_3 = repmat(reshape(dx3,1,1,n3),n1,n2);  % distribution to non-distribution for axis 2
            
            % Various datasets, hist/point and non-distribution/sistribution on the axes
            self.w3hhh_dnd = IX_dataset_3d (x1h, x2h, x3h, s3.*d2n_2, e3.*d2n_2,...
                'T', 'x', 'y', 'z', 'S', true, false, true);
            self.w3hhp_ndn = IX_dataset_3d (x1h, x2h, x3p, s3.*d2n_1, e3.*d2n_1,...
                'T', 'x', 'y', 'z', 'S', false, true, false);

            % Output of hist2point for different cases of the above
            self.w3ppp_ddd = IX_dataset_3d (x1p, x2p, x3p, s3, e3,...
                'T', 'x', 'y', 'z', 'S', true, true, true);
            self.w3php_dnd = IX_dataset_3d (x1p, x2h, x3p, s3.*d2n_2, e3.*d2n_2,...
                'T', 'x', 'y', 'z', 'S', true, false, true);
            self.w3php_ddn = IX_dataset_3d (x1p, x2h, x3p, s3, e3,...
                'T', 'x', 'y', 'z', 'S', true, true, false);
            
            % ----------------------------------------
            % Save
            self.save()
        end
        
        
        %==========================================================================
        % Test one dimensional datasets
        %==========================================================================
        function test_1D_dist (self)
            % Convert histogram distribution to point
            wtest = hist2point (self.w1h_dist);

            assertEqual(wtest, self.w1p)
        end
        
        %--------------------------------------------------------------------------
        function test_1D_nodist (self)
            % Convert histogram non-distribution to point
            wtest = hist2point (self.w1h_nodist);

            assertEqual(wtest, self.w1p)
        end
        
        %--------------------------------------------------------------------------
        function test_1D_short_nodist (self)
            % Tiny datasets
            w1h_short_nodist = IX_dataset_1d ([5,7], 3, 6, 'T', 'S', 'x', false);
            wres = IX_dataset_1d (6, 1.5, 3, 'T', 'S', 'x', true);

            wtest = hist2point (w1h_short_nodist);
            assertEqual(wtest, wres)
        end

        %--------------------------------------------------------------------------
        function test_1D_null_nodist (self)
            % Tiny datasets
            w1h_null_nodist = IX_dataset_1d (-4, zeros(0,1), zeros(0,1), 'T', 'S', 'x', false);
            wres = IX_dataset_1d ([], zeros(0,1), zeros(0,1), 'T', 'S', 'x', true);

            wtest = hist2point (w1h_null_nodist);
            assertEqual(wtest, wres)
        end

        %--------------------------------------------------------------------------
        function test_1D_goodAxis (self)
            % Good axis argument
            wtest = hist2point (self.w1h_nodist, 1);

            assertEqual(wtest, self.w1p)
        end
        
        %--------------------------------------------------------------------------
        function test_1D_badAxis (self)
            % Bad axis argument
            try
                wtest = hist2point (self.w1h_nodist, 2);
                error('Failure to throw error due to invalid axes values')
            catch ME
                if ~isequal(ME.identifier,...
                    'HERBERT:hist2point_:invalid_argument')
                    rethrow(ME)
                end
            end
        end
        
        
        %==========================================================================
        % Test two dimensional datasets
        %==========================================================================
        function test_2D_hh_dd (self)
            wtest = hist2point (self.w2hh_dd);

            assertEqualToTol(wtest, self.w2pp_dd, 'tol', [1e-14, 1e-14])
        end
        
        %--------------------------------------------------------------------------
        function test_2D_hh_nd (self)
            % Test non-distribution axis conversion
            wtest = hist2point (self.w2hh_nd);

            assertEqualToTol(wtest, self.w2pp_dd, 'tol', [1e-14, 1e-14])
        end
        
        %--------------------------------------------------------------------------
        function test_2D_hh_dn (self)
            % Test non-distribution axis conversion
            wtest = hist2point (self.w2hh_dn);

            assertEqualToTol(wtest, self.w2pp_dd, 'tol', [1e-14, 1e-14])
        end
        
        %--------------------------------------------------------------------------
        function test_2D_hh_nn (self)
            % Test non-distribution axes conversion
            wtest = hist2point (self.w2hh_nn);

            assertEqualToTol(wtest, self.w2pp_dd, 'tol', [1e-14, 1e-14])
        end
        
        %--------------------------------------------------------------------------
        function test_2D_hh_nn_axis2 (self)
            % Select just one axis for conversion
            wtest = hist2point (self.w2hh_nn, 2);

            assertEqualToTol(wtest, self.w2hp_nd, 'tol', [1e-14, 1e-14])
        end
        
        %--------------------------------------------------------------------------
        function test_2D_hh_nn_axis12 (self)
            % Explicitly select both axes for conversion
            wtest = hist2point (self.w2hh_nn, [1,2]);

            assertEqualToTol(wtest, self.w2pp_dd, 'tol', [1e-14, 1e-14])
        end
        
        %--------------------------------------------------------------------------
        function test_2D_ph_nn (self)
            % The point axis should be ignored
            wtest = hist2point (self.w2ph_nn);

            assertEqualToTol(wtest, self.w2pp_nd, 'tol', [1e-14, 1e-14])
        end
        
        
        %==========================================================================
        % Test three dimensional datasets
        %==========================================================================
        function test_3D_hhh_dnd (self)
            % Convert all axes
            wtest = hist2point (self.w3hhh_dnd);

            assertEqualToTol(wtest, self.w3ppp_ddd, 'tol', [1e-14, 1e-14])
        end
        
        %--------------------------------------------------------------------------
        function test_3D_hhh_dnd_axis13 (self)
            % Pick out only two of the three histogram axes
            wtest = hist2point (self.w3hhh_dnd, [1,3]);

            assertEqualToTol(wtest, self.w3php_dnd, 'tol', [1e-14, 1e-14])
        end
        
        %--------------------------------------------------------------------------
        function test_3D_hhp_ndn_axis13 (self)
            % One of the requested axes is a point axis; this should be ignored
            wtest = hist2point (self.w3hhp_ndn, [1,3]);

            assertEqualToTol(wtest, self.w3php_ddn, 'tol', [1e-14, 1e-14])
        end
        
        %--------------------------------------------------------------------------
        function test_3D_short_nodist (self)
            % Tiny datasets
            w3in  = IX_dataset_3d ([5,7], [11,15], 7, 5, 0.5,...
                'T', 'x', 'y', 'z', 'S', true, false, false);
            w3out = IX_dataset_3d (6, 13, 7, 1.25, 0.125,...
                'T', 'x', 'y', 'z', 'S', true, true, false);
            
            wtest = hist2point (w3in);
            assertEqualToTol(wtest, w3out, 'tol', [1e-14, 1e-14])
        end

        %--------------------------------------------------------------------------
        function test_3D_null_nodist (self)
            % Tiny datasets
            w3in  = IX_dataset_3d (4, [11,15], 7, zeros(0,1), zeros(0,1),...
                'T', 'x', 'y', 'z', 'S', true, false, false);
            w3out = IX_dataset_3d (zeros(0,1), 13, 7, zeros(0,1), zeros(0,1),...
                'T', 'x', 'y', 'z', 'S', true, true, false);
            
            wtest = hist2point (w3in);
            assertEqualToTol(wtest, w3out, 'tol', [1e-14, 1e-14])
        end

        %--------------------------------------------------------------------------

    end
end
