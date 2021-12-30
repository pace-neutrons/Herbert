classdef test_noisify <  TestCaseWithSave
    % Test class to test noisify methods
    %
    % Minimal tests that check one of the optional syntax forms for noisify.
    % The goal is to test the correct call of the function noisify within
    % the IX_dataset method. In November 2021 it was found that noisify
    % was being called with the standard deviation, not the variance.
    
    
    properties
    end
    
    methods
        function obj=test_noisify (name)
            obj@TestCaseWithSave(name);
            obj.save()
        end
        
        %------------------------------------------------------------------
        % 1D data
        %------------------------------------------------------------------
        function test_1D(obj)
            % 1D object
            x = 1:1000;
            w = IX_dataset_1d (x, rand(size(x)), rand(size(x)), ...
                'A title', 'x-axis', 'signal axis', true);
            
            s = rng;    % get rng state
            rng(0);     % set random number generator seed
            ws = noisify (w);
            rng(0);
            [signal_new, variance_new] = noisify (w.signal, (w.error).^2);
            rng(s)      % reset rng state
            ws_ref = w;
            ws_ref.signal = signal_new;
            ws_ref.error = sqrt(variance_new);
            assertEqual (ws_ref, ws)
        end
        
        %------------------------------------------------------------------
        % 2D data
        %------------------------------------------------------------------
        function test_2D(obj)
            % 2D object
            x1 = 1:100; x2 = 1001:1050;
            w = IX_dataset_2d (x1, x2, rand(100,50), rand(100,50), ...
                'A title', 'x-axis', 'y-axis', 'signal axis', true, false);
            
            s = rng;    % get rng state
            rng(0);     % set random number generator seed
            ws = noisify (w);
            rng(0);
            [signal_new, variance_new] = noisify (w.signal, (w.error).^2);
            rng(s)      % reset rng state
            ws_ref = w;
            ws_ref.signal = signal_new;
            ws_ref.error = sqrt(variance_new);
            assertEqual (ws_ref, ws)
        end
        
        %------------------------------------------------------------------
        % 3D data
        %------------------------------------------------------------------
        function test_3D_ppp_to_n(obj)
            % 3D object
            x1 = 1:100; x2 = 1001:1050; x3 = 2001:2010;
            w = IX_dataset_3d (x1, x2, x3, rand(100,50,10), rand(100,50,10), ...
                'A title', 'x-axis', 'y-axis', 'z-axis','signal axis',...
                true, false, true);
            
            s = rng;    % get rng state
            rng(0);     % set random number generator seed
            ws = noisify (w);
            rng(0);
            [signal_new, variance_new] = noisify (w.signal, (w.error).^2);
            rng(s)      % reset rng state
            ws_ref = w;
            ws_ref.signal = signal_new;
            ws_ref.error = sqrt(variance_new);
            assertEqual (ws_ref, ws)
        end
        
        %------------------------------------------------------------------
        % 4D data
        %------------------------------------------------------------------
        function test_4D_hphp_to_n(obj)
            % 4D object
            x1 = 1:30; x2 = 1001:1050; x3 = 2001:2010; x4 = 3001:3005;
            w = IX_dataset_4d (x1, x2, x3, x4, rand(30,50,10,5), rand(30,50,10,5), ...
                'A title', 'x-axis', 'y-axis', 'z-axis', 'w-axis',...
                'signal axis', true, false,false,true);
            
            s = rng;    % get rng state
            rng(0);     % set random number generator seed
            ws = noisify (w);
            rng(0);
            [signal_new, variance_new] = noisify (w.signal, (w.error).^2);
            rng(s)      % reset rng state
            ws_ref = w;
            ws_ref.signal = signal_new;
            ws_ref.error = sqrt(variance_new);
            assertEqual (ws_ref, ws)
        end
        
        %------------------------------------------------------------------
        % Test array of objects
        %------------------------------------------------------------------
        function test_1D_array(obj)
            w = repmat(IX_dataset_1d(),1,3);
            
            w(1) = IX_dataset_1d (1:500, rand(500,1), rand(500,1), ...
                'A title', 'x-axis', 'signal axis', true);
            w(2) = IX_dataset_1d (1:100, rand(100,1), rand(100,1), ...
                'A title', 'x-axis', 'signal axis', true);
            w(3) = IX_dataset_1d (1:5000, rand(5000,1), rand(5000,1), ...
                'A title', 'x-axis', 'signal axis', true);
            
            s = rng;    % get rng state
            rng(0);     % set random number generator seed
            ws = noisify (w);
            
            rng(0);
            ws_ref = w;
            for i=1:3
                [signal_new, variance_new] = noisify (w(i).signal, (w(i).error).^2);
                ws_ref(i).signal = signal_new;
                ws_ref(i).error = sqrt(variance_new);
            end
            rng(s)      % reset rng state
            
            assertEqual (ws_ref, ws)
        end
        
        %------------------------------------------------------------------
    end
end
