classdef test_IX_dataset_3d <  TestCase
    % Test class to test IX_dataset_3d methods
    %
    % Modified T.G.Perring 202-07-18 as part of refactoring of IX_dataset
    %   - axis values are now columns
    %   - IX_dataset properties valid_ and error_mess_ deleted, so that
    %     get_valid and associated methods no longer exist. Objects are 
    %     always valid if they were created.
    
    properties
    end
    
    methods
        function this=test_IX_dataset_3d(varargin)
            if nargin == 0
                name = 'test_IX_dataset_3d';
            else
                name = varargin{1};
            end
            this = this@TestCase(name);
        end
        
        
        %------------------------------------------------------------------
        function test_constructor(obj)
            %   >> w = IX_dataset_3d (x,y,z)
            ds = IX_dataset_3d(1:10,1:5,1:7);
            assertEqual(ds.x,(1:10)');          % now column
            assertEqual(ds.y,(1:5)');           % now column
            assertEqual(ds.z,(1:7)');           % now column
            assertEqual(ds.signal,zeros(10,5,7));
            assertEqual(ds.error,zeros(10,5,7));
            
            
            %   >> w = IX_dataset_3d (x,y,z,signal)
            ds = IX_dataset_3d(1:10,1:5,1:7,ones(9,4,6));
            assertEqual(ds.x,(1:10)');          % now column
            assertEqual(ds.y,(1:5)');           % now column
            assertEqual(ds.z,(1:7)');           % now column
            assertEqual(ds.signal,ones(9,4,6));
            assertEqual(ds.error,zeros(9,4,6));
            
            
            %   >> w = IX_dataset_3d (x,y,z,signal,error)
            ds = IX_dataset_3d(1:10,1:5,1:7,ones(10,5,7),ones(10,5,7));
            assertEqual(ds.x,(1:10)');          % now column
            assertEqual(ds.y,(1:5)');           % now column
            assertEqual(ds.z,(1:7)');           % now column
            assertEqual(ds.signal,ones(10,5,7));
            assertEqual(ds.error,ones(10,5,7));
            
            
            %   >> w = IX_dataset_3d (x,y,z,signal,error,title,x_axis,y_axis,z_axis,s_axis)
            ds = IX_dataset_3d(1:10,1:5,1:7,ones(10,5,7),ones(10,5,7),...
                'my 3D obj','x-axis','y-axis','z-axis','signal');
            assertEqual(ds.x,(1:10)');          % now column
            assertEqual(ds.y,(1:5)');           % now column
            assertEqual(ds.z,(1:7)');           % now column
            assertEqual(ds.signal,ones(10,5,7));
            assertEqual(ds.error,ones(10,5,7));
            assertEqual(ds.title,{'my 3D obj'});
            assertEqual(ds.x_axis.caption,{'x-axis'});
            assertEqual(ds.y_axis.caption,{'y-axis'});
            assertEqual(ds.z_axis.caption,{'z-axis'});
            assertEqual(ds.s_axis.caption,{'signal'});
            
            
            %   >> w = IX_dataset_3d (x,y,z,signal,error,title,x_axis,y_axis,z_axis,s_axis,x_distribution,y_distribution,z_distribution)
            ds = IX_dataset_3d(1:10,1:5,1:7,ones(10,5,7),ones(10,5,7),...
                'my 3D obj','x-axis','y-axis','z-axis','signal',...
                false,false,false);
            assertEqual(ds.x,(1:10)');          % now column
            assertEqual(ds.y,(1:5)');           % now column
            assertEqual(ds.z,(1:7)');           % now column
            assertEqual(ds.signal,ones(10,5,7));
            assertEqual(ds.error,ones(10,5,7));
            assertEqual(ds.title,{'my 3D obj'});
            assertEqual(ds.x_axis.caption,{'x-axis'});
            assertEqual(ds.y_axis.caption,{'y-axis'});
            assertEqual(ds.z_axis.caption,{'z-axis'});
            assertEqual(ds.s_axis.caption,{'signal'});
            assertEqual(ds.x_distribution,false);
            assertEqual(ds.y_distribution,false);
            assertEqual(ds.z_distribution,false);
            
            %   >> w = IX_dataset_3d (title, signal, error, s_axis, x, x_axis, x_distribution,...
            %                                          y, y_axis, y_distribution, z, z-axis, z_distribution)
            
            ds = IX_dataset_3d('my 3D obj',ones(10,5,7),ones(10,5,7),...
                'signal',1:10,'x-axis',false,...
                1:5,'y-axis',false,...
                1:7,'z-axis',false);
            assertEqual(ds.x,(1:10)');          % now column
            assertEqual(ds.y,(1:5)');           % now column
            assertEqual(ds.z,(1:7)');           % now column
            assertEqual(ds.signal,ones(10,5,7));
            assertEqual(ds.error,ones(10,5,7));
            assertEqual(ds.title,{'my 3D obj'});
            assertEqual(ds.x_axis.caption,{'x-axis'});
            assertEqual(ds.y_axis.caption,{'y-axis'});
            assertEqual(ds.z_axis.caption,{'z-axis'});
            assertEqual(ds.s_axis.caption,{'signal'});
            assertEqual(ds.x_distribution,false);
            assertEqual(ds.y_distribution,false);
            assertEqual(ds.z_distribution,false);
        end
        
        
        %------------------------------------------------------------------
        function test_properties(obj)
            
            id = IX_dataset_3d();
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
            
            ds = IX_dataset_3d(1:10,1:5,1:7,ones(10,5,7),ones(10,5,7),...
                'my 3D obj','x-axis','y-axis','z-axis','signal');
            
            try
                ds.x = 1:12;
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
            %   >> w = IX_dataset_3d (x,y,z,signal,error,title,x_axis,y_axis,s_axis)
            
            ds = IX_dataset_3d(1:10,1:5,1:15,ones(10,5,15),ones(10,5,15),...
                'test 3D object','x-axis','y-axis','z-axis','signal');
            dsa = repmat(ds,2,1);
            
            dss = dsa(1) + dsa(2);
            assertEqual(dss.signal,2*ones(10,5,15));
            assertEqual(dss.error,sqrt(2*ones(10,5,15)));
            
            dsm = -ds;
            dss  = dss+dsm;
            assertEqual(dss.signal,ones(10,5,15));
            assertElementsAlmostEqual(dss.error,sqrt(3*ones(10,5,15)));
            
            dss  = dss+1;
            assertEqual(dss.signal,2*ones(10,5,15));
            assertElementsAlmostEqual(dss.error,sqrt(3*ones(10,5,15)));
            
            
            dss  = 1+ dss;
            assertEqual(dss.signal,3*ones(10,5,15));
            assertElementsAlmostEqual(dss.error,sqrt(3*ones(10,5,15)));
            
        end
        %------------------------------------------------------------------
    end
end
