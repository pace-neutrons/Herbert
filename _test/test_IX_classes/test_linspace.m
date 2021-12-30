classdef test_linspace <  TestCaseWithSave
    % Test class to test linspace methods
    %
    % These methods on IX_dataset_1d, _2d etc change the point density
    % along the axes, setting the signal and error to zero, but leave the
    % axis titling and distribution type unchanged
    
    properties
    end
    
    methods
        function obj=test_linspace (name)
            obj@TestCaseWithSave(name);
            obj.save()
        end
        
        %------------------------------------------------------------------
        % 1D data
        %------------------------------------------------------------------
        function test_1D_point_to_n(obj)
            % 1D object: linspace on point data
            w = IX_dataset_1d ([10,12,15], rand(3,1), rand(3,1), ...
                'A title', 'x-axis', 'signal axis', true);
            ws = linspace (w, 50);
            ws_ref = init (w, linspace(10,15,50), zeros(50,1), zeros(50,1));
            assertEqual (ws_ref, ws)
        end

        %------------------------------------------------------------------
        function test_1D_hist_to_n(obj)
            % 1D object: linspace on histogram data
            w = IX_dataset_1d ([10,12,15], rand(2,1), rand(2,1), ...
                'A title', 'x-axis', 'signal axis', true);
            ws = linspace (w, 50);
            ws_ref = init (w, linspace(10,15,51), zeros(50,1), zeros(50,1));
            assertEqual (ws_ref, ws)
        end

        %------------------------------------------------------------------
        function test_1D_hist_nochange(obj)
            % 1D object: linspace on histogram data, but no x-axis change
            w = IX_dataset_1d ([10,12,15], rand(2,1), rand(2,1), ...
                'A title', 'x-axis', 'signal axis', true);
            ws = linspace (w, 0);
            ws_ref = init (w, [10,12,15], zeros(2,1), zeros(2,1));
            assertEqual (ws_ref, ws)
        end

        %------------------------------------------------------------------
        function test_1D_point_norange(obj)
            % 1D object: linspace on point data, all points same x
            % Should result in no change (cannot apply linspace)
            w = IX_dataset_1d ([10,10,10], rand(3,1), rand(3,1), ...
                'A title', 'x-axis', 'signal axis', true);
            ws = linspace (w, 50);
            ws_ref = init (w, [10,10,10], zeros(3,1), zeros(3,1));
            assertEqual (ws_ref, ws)
        end

        %------------------------------------------------------------------
        function test_1D_hist_norange(obj)
            % 1D object: linspace on hist data, one boundary only
            % Should result in no change (cannot apply linspace)
            w = IX_dataset_1d (10, zeros(0,1), zeros(0,1), ...
                'A title', 'x-axis', 'signal axis', true);
            ws = linspace (w, 50);
            ws_ref = w;
            assertEqual (ws_ref, ws)
        end

        %------------------------------------------------------------------
        % 2D data
        %------------------------------------------------------------------
        function test_2D_pp_to_n(obj)
            % 2D object: linspace on point/point data
            w = IX_dataset_2d ([10,12,15], [100,140], rand(3,2), rand(3,2), ...
                'A title', 'x-axis', 'y-axis', 'signal axis', true, false);
            ws = linspace (w, [50,20]);
            ws_ref = init (w, linspace(10,15,50), linspace(100,140,20),...
                zeros(50,20), zeros(50,20));
            assertEqual (ws_ref, ws)
        end

        %------------------------------------------------------------------
        function test_2D_hp_to_n(obj)
            % 2D object: linspace on hist/point data
            w = IX_dataset_2d ([10,12,14,15], [100,140], rand(3,2), rand(3,2), ...
                'A title', 'x-axis', 'y-axis', 'signal axis', true, false);
            ws = linspace (w, [50,20]);
            ws_ref = init (w, linspace(10,15,51), linspace(100,140,20),...
                zeros(50,20), zeros(50,20));
            assertEqual (ws_ref, ws)
        end

        %------------------------------------------------------------------
        function test_2D_hp_no_y_change(obj)
            % 2D object: linspace on hist/point data, no change on y axis
            w = IX_dataset_2d ([10,12,14,15], [100,140], rand(3,2), rand(3,2), ...
                'A title', 'x-axis', 'y-axis', 'signal axis', true, false);
            ws = linspace (w, [50,0]);
            ws_ref = init (w, linspace(10,15,51), [100,140],...
                zeros(50,2), zeros(50,2));
            assertEqual (ws_ref, ws)
        end

        %------------------------------------------------------------------
        function test_2D_hp_no_y_range(obj)
            % 2D object: linspace on point data, all points same y
            % Should result in no change on y axis (cannot apply linspace)
            w = IX_dataset_2d ([10,12,14,15], [10,10,10,10,10],...
                rand(3,5), rand(3,5), 'A title', 'x-axis', 'y-axis',...
                'signal axis', true, true);
            ws = linspace (w, [50,80]);
            ws_ref = init (w, linspace(10,15,51), [10,10,10,10,10],...
                zeros(50,5), zeros(50,5));
            assertEqual (ws_ref, ws)
        end

        %------------------------------------------------------------------
        function test_2D_hp_no_x_range(obj)
            % 2D object: linspace on hist data, one boundary only
            % Should result in no change on x axis (cannot apply linspace)
            w = IX_dataset_2d ([10], [10,12,14,16,18],...
                rand(0,5), rand(0,5), 'A title', 'x-axis', 'y-axis',...
                'signal axis', false, true);
            ws = linspace (w, [50,80]);
            ws_ref = init (w, 10, linspace(10,18,80),...
                zeros(0,80), zeros(0,80));
            assertEqual (ws_ref, ws)
        end
        
        %------------------------------------------------------------------
        function test_2D_hp_no_xy_ranges(obj)
            % 2D object: linspace on hist data, one boundary only
            % Should result in no change on x axis (cannot apply linspace)
            w = IX_dataset_2d ([10], [10,10,10,10,10],...
                rand(0,5), rand(0,5), 'A title', 'x-axis', 'y-axis',...
                'signal axis', false, true);
            ws = linspace (w, [50,80]);
            ws_ref = init (w, 10, [10,10,10,10,10],...
                zeros(0,5), zeros(0,5));
            assertEqual (ws_ref, ws)
        end
        
        %------------------------------------------------------------------
        % 3D data
        % Bare check, as core algorithm is common to 1D and 2D. We just
        % want to check the 3D overloading to the common method
        %------------------------------------------------------------------
        function test_3D_ppp_to_n(obj)
            % 3D object: linspace on point/point data
            w = IX_dataset_3d ([10,12,15], [100,140], [201,202,204,205],...
                rand(3,2,4), rand(3,2,4), ...
                'A title', 'x-axis', 'y-axis', 'z-axis','signal axis',...
                true, false, true);
            ws = linspace (w, [50,20,30]);
            ws_ref = init (w, linspace(10,15,50), linspace(100,140,20),...
                linspace(201,205,30), zeros(50,20,30), zeros(50,20,30));
            assertEqual (ws_ref, ws)
        end

        %------------------------------------------------------------------
        % 4D data
        % Bare check, as core algorithm is common to 1D and 2D. We just
        % want to check the 3D overloading to the common method
        %------------------------------------------------------------------
        function test_4D_hphp_to_n(obj)
            % 2D object: linspace on hist/point data
            w = IX_dataset_4d ([10,12,14,15], [100,140], [201,202,204,205,206],...
                [301,302,304,305,307,310], rand(3,2,4,6), rand(3,2,4,6), ...
                'A title', 'x-axis', 'y-axis', 'z-axis', 'w-axis',...
                'signal axis', true, false,false,true);
            ws = linspace (w, [50,20,10,15]);
            ws_ref = init (w, linspace(10,15,51), linspace(100,140,20),...
                linspace(201,206,11), linspace(301,310,15),...
                zeros(50,20,10,15), zeros(50,20,10,15));
            assertEqual (ws_ref, ws)
        end
        
        %------------------------------------------------------------------
        % Test array of objects
        %------------------------------------------------------------------
        function test_1D_array(obj)
            w = repmat(IX_dataset_1d(),1,3);
            % 1D object: linspace on point data
            w(1) = IX_dataset_1d ([10,12,15], rand(3,1), rand(3,1), ...
                'A title', 'x-axis', 'signal axis', true);
            
            % 1D object: linspace on histogram data
            w(2) = IX_dataset_1d ([10,12,15], rand(2,1), rand(2,1), ...
                'A title', 'x-axis', 'signal axis', true);     
            
            % 1D object: linspace on point data, all points same x
            % Should result in no change (cannot apply linspace)
            w(3) = IX_dataset_1d ([10,10,10], rand(3,1), rand(3,1), ...
                'A title', 'x-axis', 'signal axis', true);
            
            ws = linspace (w, 50);
            
            ws_ref = repmat(IX_dataset_1d(),1,3);
            ws_ref(1) = init (w(1), linspace(10,15,50), zeros(50,1), zeros(50,1));
            ws_ref(2) = init (w(2), linspace(10,15,51), zeros(50,1), zeros(50,1));
            ws_ref(3) = init (w(3), [10,10,10], zeros(3,1), zeros(3,1));
            
            assertEqual (ws_ref, ws)
        end

        %------------------------------------------------------------------
    end
end
