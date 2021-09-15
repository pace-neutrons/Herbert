classdef test_IX_dataset_2d <  TestCase
    % Test class to test IX_dataset_1d methods
    %
    % Modified T.G.Perring 202-07-18 as part of refactoring of IX_dataset
    %   - IX_dataset properties valid_ and error_mess_ deleted, so that
    %     get_valid and associated methods no longer exist. Objects are
    %     always valid if they were created.
    
    properties
    end
    
    methods
        function this=test_IX_dataset_2d(varargin)
            if nargin == 0
                name = 'test_IX_dataset_2d';
            else
                name = varargin{1};
            end
            this = this@TestCase(name);
        end
        
        
        %------------------------------------------------------------------
        function test_constructor(obj)
            % >> w = IX_dataset_2d (x,y)
            ds = IX_dataset_2d(1:10,1:20);
            assertEqual(ds.x,(1:10));
            assertEqual(ds.y,(1:20));
            assertEqual(ds.signal,zeros(10,20));
            assertEqual(ds.error,zeros(10,20));
            
            
            %   >> w = IX_dataset_2d (x,y,signal)
            ds = IX_dataset_2d(1:10,1:20,ones(9,19));
            assertEqual(ds.x,(1:10));
            assertEqual(ds.y,(1:20));
            assertEqual(ds.signal,ones(9,19));
            assertEqual(ds.error,zeros(9,19));
            
            
            %   >> w = IX_dataset_2d (x,y,signal,error)
            ds = IX_dataset_2d(1:10,1:20,ones(10,20),ones(10,20));
            assertEqual(ds.x,(1:10));
            assertEqual(ds.y,(1:20));
            assertEqual(ds.signal,ones(10,20));
            assertEqual(ds.error,ones(10,20));
            
            
            %   >> w = IX_dataset_2d (x,y,signal,error,title,x_axis,y_axis,s_axis)
            ds = IX_dataset_2d(1:20,1:10,ones(20,10),ones(20,10),...
                'my object','x-axis name','y-axis name','signal');
            assertEqual(ds.x,(1:20));
            assertEqual(ds.y,(1:10));
            assertEqual(ds.signal,ones(20,10));
            assertEqual(ds.error,ones(20,10));
            assertEqual(ds.title,{'my object'});
            assertEqual(ds.x_axis.caption,{'x-axis name'});
            assertEqual(ds.y_axis.caption,{'y-axis name'});
            assertEqual(ds.s_axis.caption,{'signal'});
            
            
            %   >> w = IX_dataset_2d (x,y,signal,error,title,...
            %           x_axis,y_axis,s_axis,x_distribution,y_distribution)
            ds = IX_dataset_2d(1:20,1:10,ones(20,10),ones(20,10),...
                'my object','x-axis name','y-axis name','signal',false,false);
            assertEqual(ds.x,(1:20));
            assertEqual(ds.y,(1:10));
            assertEqual(ds.signal,ones(20,10));
            assertEqual(ds.error,ones(20,10));
            assertEqual(ds.title,{'my object'});
            assertEqual(ds.x_axis.caption,{'x-axis name'});
            assertEqual(ds.y_axis.caption,{'y-axis name'});
            assertEqual(ds.s_axis.caption,{'signal'});
            assertEqual(ds.x_distribution,false);
            assertEqual(ds.y_distribution,false);
            
            
            %   >> w = IX_dataset_2d (title, signal, error, s_axis,...
            %           x, x_axis, x_distribution, y, y_axis, y_distribution)
            ds = IX_dataset_2d('my object',ones(15,10),ones(15,10),...
                'signal',1:15,'x-axis name',false,...
                1:10,'y-axis name',false);
            assertEqual(ds.x,(1:15));
            assertEqual(ds.y,(1:10));
            assertEqual(ds.signal,ones(15,10));
            assertEqual(ds.error,ones(15,10));
            assertEqual(ds.title,{'my object'});
            assertEqual(ds.x_axis.caption,{'x-axis name'});
            assertEqual(ds.y_axis.caption,{'y-axis name'});
            assertEqual(ds.s_axis.caption,{'signal'});
            assertEqual(ds.x_distribution,false);
            assertEqual(ds.y_distribution,false);
        end
        
        function test_constructor_by_array_args(obj)
            % >> w = IX_dataset_2d (x,y)
            ds = IX_dataset_2d(1:10,1:20);
            ds2 = IX_dataset_2d({1:10,1:20});
            assertEqual(ds, ds2);


            %   >> w = IX_dataset_2d (x,y,signal)
            ds = IX_dataset_2d(1:10,1:20,ones(9,19));
            ds2 = IX_dataset_2d({1:10,1:20},ones(9,19));
            assertEqual(ds, ds2);
            
            
            %   >> w = IX_dataset_2d (x,y,signal,error)
            ds = IX_dataset_2d(1:10,1:20,ones(10,20),ones(10,20));
            ds2 = IX_dataset_2d({1:10,1:20},ones(10,20),ones(10,20));
            assertEqual(ds, ds2);
            
            
            %   >> w = IX_dataset_2d (x,y,signal,error,title,x_axis,y_axis,s_axis)
            ds = IX_dataset_2d(1:20,1:10,ones(20,10),ones(20,10),...
                'my object','x-axis name','y-axis name','signal');
            ds2 = IX_dataset_2d({1:20,1:10},ones(20,10),ones(20,10),...
                'my object',{'x-axis name','y-axis name'},'signal');
            assertEqual(ds, ds2);
            
            
            %   >> w = IX_dataset_2d (x,y,signal,error,title,...
            %           x_axis,y_axis,s_axis,x_distribution,y_distribution)
            ds = IX_dataset_2d(1:20,1:10,ones(20,10),ones(20,10),...
                'my object','x-axis name','y-axis name','signal',false,false);
            ds2 = IX_dataset_2d({1:20,1:10},ones(20,10),ones(20,10),...
                'my object',{'x-axis name','y-axis name'},'signal',[false,false]);
            assertEqual(ds, ds2);
            
            
            %   >> w = IX_dataset_2d (title, signal, error, s_axis,...
            %           x, x_axis, x_distribution, y, y_axis, y_distribution)
            ds = IX_dataset_2d('my object',ones(15,10),ones(15,10),...
                'signal',1:15,'x-axis name',false,...
                1:10,'y-axis name',false);
            ds2 = IX_dataset_2d('my object',ones(15,10),ones(15,10),...
                'signal',{1:15, 1:10},{'x-axis name','y-axis name'},...
                [false,false]);
            assertEqual(ds, ds2);
            
            
            %   >> w = IX_dataset_2d (title, signal, error, s_axis,...
            %           x, x_axis, x_distribution, y, y_axis, y_distribution)
            ds = IX_dataset_2d('my object',ones(15,10),ones(15,10),...
                'signal',1:15,'x-axis name',false,...
                1:10,'y-axis name',false);
            ds2 = IX_dataset_2d('my object',ones(15,10),ones(15,10),...
                'signal',{1:15, 1:10},{'x-axis name','y-axis name'},...
                {false,false});
            assertEqual(ds, ds2);
        end
        
        function test_constructor_via_IX_dataset_nd(obj)
            w = IX_dataset_2d;
            wtmp = IX_dataset_nd(2);
            assertEqual(w,wtmp)
            
            ds = IX_dataset_2d('my object',ones(15,10),ones(15,10),...
                'signal',1:15,'x-axis name',false,...
                1:10,'y-axis name',false);
            ds2 = IX_dataset_nd('my object',ones(15,10),ones(15,10),...
                'signal',{1:15, 1:10},{'x-axis name','y-axis name'},...
                [false,false]);
            assertEqual(ds, ds2)
            
            ax(1).values = 1:15;
            ax(1).axis = 'x-axis name';
            ax(1).distribution = false;
            ax(2).values = 1:10;
            ax(2).axis = 'y-axis name';
            ax(2).distribution = false;
            ds2 = IX_dataset_nd('my object',ones(15,10),ones(15,10),...
                'signal',ax);
            assertEqual(ds, ds2)
        end
        
        function test_constructor_small(obj)
            % Single point is valid
            ds = IX_dataset_2d(1, 10);
            assertEqual(size(ds.error),[1,1])
        end
        
        function test_constructor_null(obj)
            % Single bin boundary is valid
            ds = IX_dataset_2d(1, [4,5], zeros(0,1));
            assertEqual(size(ds.error),[0,1])
        end
        
        function test_non_monotonic_point (obj)
            %   >> w = IX_dataset_2d (x,y,signal,error)
            % This should fail, as only in 1D will the IX_dataset constructor
            % re-order the axes
            try
                ds = IX_dataset_2d([1:7,9,8,10],1:20,ones(10,20),ones(10,20));
                error('Failure to throw error due to invalid axes values')
            catch ME
                if ~isequal(ME.identifier,...
                        'HERBERT:check_properties_consistency_:invalid_argument')
                    rethrow(ME)
                end
            end
        end
        
        function test_non_strictly_monotonic_hist (obj)
            %   >> w = IX_dataset_1d (x,signal,error)
            % Should re-order the data
            try
                ds = IX_dataset_2d([1:7,7,9:11],1:20,ones(10,20),ones(10,20));
                error('Failure to throw error due to invalid axes values')
            catch ME
                if ~isequal(ME.identifier,...
                        'HERBERT:check_properties_consistency_:invalid_argument')
                    rethrow(ME)
                end
            end
        end
        
        %------------------------------------------------------------------
        function test_properties(obj)
            
            id = IX_dataset_2d();
            id.title = 'my title';
            assertEqual(id.title,{'my title'});
            
            id.x_axis = 'Coord';
            ax = id.x_axis;
            assertTrue(isa(ax,'IX_axis'));
            assertEqual(ax.caption,{'Coord'});
            
            ax.units = 'A^-1';
            id.s_axis = ax;
            as = id.s_axis;
            assertTrue(isa(as,'IX_axis'));
            assertEqual(id.s_axis.units,'A^-1');
            
            id.y_axis = 'dist';
            ay = id.y_axis;
            assertTrue(isa(ay,'IX_axis'));
            assertEqual(ay.caption,{'dist'});
            
            ay.units = 'A^-1';
            id.y_axis = ay;
            assertTrue(isa(id.y_axis,'IX_axis'));
            assertEqual(id.y_axis.caption,{'dist'});
            assertEqual(id.y_axis.units,'A^-1');
            
            ds = IX_dataset_2d('my object',ones(15,10),ones(15,10),...
                'signal',1:15,'x-axis name',false,...
                1:10,'y-axis name',false);
            
            try
                ds.x = 1:10;
                error('Failure to throw error due to invalid axes values')
            catch ME
                if ~isequal(ME.identifier,...
                        'HERBERT:check_properties_consistency_:invalid_argument')
                    rethrow(ME)
                end
            end
            
            try
                ds.signal = ones(10,20);
                error('Failure to throw error due to invalid size of signal array')
            catch ME
                if ~isequal(ME.identifier,...
                        'HERBERT:check_properties_consistency_:invalid_argument')
                    rethrow(ME)
                end
            end
            
            try
                ds.error = ones(20,10);
                error('Failure to throw error due to invalid size of error array')
            catch ME
                if ~isequal(ME.identifier,...
                        'HERBERT:check_properties_consistency_:invalid_argument')
                    rethrow(ME)
                end
            end
            
        end
        
        
        %------------------------------------------------------------------
        function test_op_managers(obj)
            ds = IX_dataset_2d(1:10,1:20,ones(10,20),ones(10,20),...
                'my object','x-axis name','y-axis name','signal');
            dsa = repmat(ds,2,1);
            
            dss = dsa(1) + dsa(2);
            assertEqual(dss.signal,2*ones(10,20));
            assertEqual(dss.error,sqrt(2*ones(10,20)));
            
            dsm = -ds;
            dss  = dss+dsm;
            assertEqual(dss.signal,ones(10,20));
            assertElementsAlmostEqual(dss.error,sqrt(3*ones(10,20)));
            
            dss  = dss+1;
            assertEqual(dss.signal,2*ones(10,20));
            assertElementsAlmostEqual(dss.error,sqrt(3*ones(10,20)));
            
            
            dss  = 1+ dss;
            assertEqual(dss.signal,3*ones(10,20));
            assertElementsAlmostEqual(dss.error,sqrt(3*ones(10,20)));
            
        end
        %------------------------------------------------------------------
    end
end
