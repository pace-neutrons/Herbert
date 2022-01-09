classdef test_make_testdata_IX_dataset_nd <  TestCaseWithSave
    % Test class to test make_testdata_IX_dataset_nd used in some tests
    
    methods
        function obj=test_make_testdata_IX_dataset_nd (name)
            obj@TestCaseWithSave(name);
            obj.save()
        end
        
        %------------------------------------------------------------------
        % 1D data
        %------------------------------------------------------------------
        function test_1D(obj)
            % 1D workspace
            sz_ref = 100;
            w = make_testdata_IX_dataset_nd (sz_ref, 1);
            
            [nd, sz] = dimensions(w);
            assertEqual (nd, 1)
            assertEqual (sz, sz_ref)
            assertEqual (ishistogram(w), true)
            assertTrue (max(diff(w.x)-1)==0)
        end
        
        function test_1D_randx(obj)
            % 1D workspace - randx
            sz_ref = 100;
            w = make_testdata_IX_dataset_nd (sz_ref, 1, '-frac', 0.2);
            
            [nd, sz] = dimensions(w);
            assertEqual (nd, 1)
            assertEqual (sz, sz_ref)
            assertEqual (ishistogram(w), true)
            assertTrue (max(diff(w.x)-1)>0)
        end
        
        function test_1D_random(obj)
            % test two workspaces created in succesion with the same input
            % arguments are different (because of the random signal)
            sz_ref = 100;
            wa = make_testdata_IX_dataset_nd (sz_ref, 1);
            wb = make_testdata_IX_dataset_nd (sz_ref, 1);
            
            assertFalse (isequal(wa,wb))
        end
        
        function test_1D_seed_reset(obj)
            % test two workspaces created in succesion with the same input
            % arguments are the same if the seed is reset.
            sz_ref = 100;
            wa = make_testdata_IX_dataset_nd (sz_ref, 1, '-seed', 0, '-frac', 0.2);
            wb = make_testdata_IX_dataset_nd (sz_ref, 1, '-seed', 0, '-frac', 0.2);
            
            assertTrue (isequal(wa,wb))

            [nd, sz] = dimensions(wa);
            assertEqual (nd, 1)
            assertEqual (sz, sz_ref)
            assertEqual (ishistogram(wa), true)
            assertTrue (max(diff(wa.x)-1)>0)
        end
        
        
        %------------------------------------------------------------------
        % 2D data
        %------------------------------------------------------------------
        function test_2D(obj)
            % 2D workspace with various options
            sz_ref = [100,3];
            w = make_testdata_IX_dataset_nd (sz_ref, 1);
            
            [nd, sz] = dimensions(w);
            assertEqual (nd, 2)
            assertEqual (sz, sz_ref)
            assertEqual (ishistogram(w), [true, true])
            assertTrue (max(diff(w.x)-1)==0)
            assertTrue (max(diff(w.y)-1)==0)
        end
        
        
        %------------------------------------------------------------------
        % 3D data
        %------------------------------------------------------------------
        function test_3D(obj)
            % 3D workspace
            sz_ref = [50,5,15];
            w = make_testdata_IX_dataset_nd (sz_ref, 1);
            
            [nd, sz] = dimensions(w);
            assertEqual (nd, 3)
            assertEqual (sz, sz_ref)
            assertEqual (ishistogram(w), [true, true, true])
            assertTrue (max(diff(w.x)-1)==0)
            assertTrue (max(diff(w.y)-1)==0)
            assertTrue (max(diff(w.z)-1)==0)
        end
        
        function test_3D_randx(obj)
            % 3D workspace - randx
            sz_ref = [50,5,15];
            w = make_testdata_IX_dataset_nd (sz_ref, 1, '-frac', 0.2);
            
            [nd, sz] = dimensions(w);
            assertEqual (nd, 3)
            assertEqual (sz, sz_ref)
            assertEqual (ishistogram(w), [true, true, true])
            assertTrue (max(diff(w.x)-1)>0)
        end
        
        function test_3D_random(obj)
            % test two workspaces created in succesion with the same input
            % arguments are different (because of the random signal)
            sz_ref = [50,5,15];
            wa = make_testdata_IX_dataset_nd (sz_ref, 1, '-frac', 0.4);
            wb = make_testdata_IX_dataset_nd (sz_ref, 1, '-frac', 0.4);
            
            assertFalse (isequal(wa,wb))
        end
        
        function test_3D_seed_reset(obj)
            % test two workspaces created in succesion with the same input
            % arguments are the same if the seed is reset.
            sz_ref = [50,5,15];
            wa = make_testdata_IX_dataset_nd (sz_ref, 1,...
                '-seed', 0, '-frac', 0.2, '-hist', 0);
            wb = make_testdata_IX_dataset_nd (sz_ref, 1,...
                '-seed', 0, '-frac', 0.2, '-hist', 0);
            
            assertTrue (isequal(wa,wb))

            [nd, sz] = dimensions(wa);
            assertEqual (nd, 3)
            assertEqual (sz, sz_ref)
            assertEqual (ishistogram(wa), [false,false,false])
            assertTrue (max(diff(wa.x)-1)>0)
        end
        
        function test_3D_zeroy(obj)
            % 3D workspace - randx
            sz_ref = [50,0,15];
            w = make_testdata_IX_dataset_nd (sz_ref, 1, '-frac', 0.2);
            
            [nd, sz] = dimensions(w);
            assertEqual (nd, 3)
            assertEqual (sz, sz_ref)
            assertEqual (ishistogram(w), [true, true, true])
            assertTrue (max(diff(w.x)-1)>0)
            assertTrue (numel(w.signal)==0)
            assertTrue (numel(w.y)==1)
        end
                

        %------------------------------------------------------------------
        % 4D data
        %------------------------------------------------------------------
        function test_4D(obj)
            % 4D workspace with various options
            sz_ref = [10,3,17,14];
            w = make_testdata_IX_dataset_nd (sz_ref, 1, '-hist', [0,1,1,0]);
            
            [nd, sz] = dimensions(w);
            assertEqual (nd, 4)
            assertEqual (sz, sz_ref)
            assertEqual (ishistogram(w), [false, true, true, false])
            assertTrue (max(diff(w.x)-1)==0)
            assertTrue (max(diff(w.y)-1)==0)
            assertTrue (max(diff(w.z)-1)==0)
            assertTrue (max(diff(w.w)-1)==0)
        end
        
        
        %------------------------------------------------------------------
        % Test array of objects
        %------------------------------------------------------------------
        function test_2D_array(obj)
            % Array of 2D objects
            sz_ref = [100,3];
            w = make_testdata_IX_dataset_nd (sz_ref, [5,7],...
                '-frac', 0.2, '-hist', [0,1]);
            
            [nd, sz] = dimensions(w(6));
            assertEqual (nd, 2)
            assertEqual (sz, sz_ref)
            assertEqual (ishistogram(w(6)), [false, true])
            assertTrue (max(diff(w(6).x)-1)>0)
            assertTrue (max(diff(w(6).y)-1)>0)
            
            assertFalse (isequal(w(6),w(7)))
        end
    end
end
