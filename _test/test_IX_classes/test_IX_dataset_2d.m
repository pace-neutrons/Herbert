classdef test_IX_dataset_2d <  TestCase
    %Test class to test IX_dataset_1d methods
    %
    % Modified T.G.Perring 202-07-18 as part of refactoring of IX_dataset
    %   - axis values are now columns
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
            
            % TGP 2021-07-18:
            % Modified the following tests as it is no longer possible to
            % set an object into an invalid state - an error is always thrown.
            % Also now create a non-empty dataset for the comparison
            ds = IX_dataset_2d('my object',ones(15,10),ones(15,10),...
                'signal',1:15,'x-axis name',false,...
                1:10,'y-axis name',false);
            
            try
                ds.x = 1:10;
                error('Failure to throw error due to invalid axes values')
%                 id.x = 1:10;
%                 assertFalse(id.get_isvalid())     % *** DELETED PROPERTY
%                 val = id.x;
%                 assertTrue(ischar(val));
%                 assertEqual('size(signal,1)=0, numel(x)=10; size(signal,1) must be equal to numel(x) or numel(x)+1',val);
            catch ME
                if ~isequal(ME.identifier,...
                    'HERBERT:check_properties_consistency_:invalid_argument')
                    rethrow(ME)
                end
            end
            
            try
                ds.signal = ones(10,20);
                error('Failure to throw error due to invalid size of signal array')
%                 id.signal = ones(10,20);
%                 val = id.signal;
%                 assertTrue(ischar(val));
%                 assertEqual('size(signal)=[10,20], size(error)=[0,1]; size(signal)~=size(error)',val);
%                 assertFalse(id.get_isvalid())
            catch ME
                if ~isequal(ME.identifier,...
                    'HERBERT:check_properties_consistency_:invalid_argument')
                    rethrow(ME)
                end
            end
            
            try
                ds.error = ones(20,10);
                error('Failure to throw error due to invalid size of error array')
%                 id.error = ones(20,10);
%                 assertFalse(id.get_isvalid())
%                 val = id.x;
%                 assertTrue(ischar(val));
%                 assertEqual('size(signal,2)=20, numel(y)=0; size(signal,2)  must be equal to numel(y) or numel(y)+1',val);
            catch ME
                if ~isequal(ME.identifier,...
                    'HERBERT:check_properties_consistency_:invalid_argument')
                    rethrow(ME)
                end
            end

%             Redundant test - isvalid no longer exists
%             id.y = 1:20;
%             assertTrue(id.get_isvalid())    % *** DELETED PROPERTY
%             val = id.signal;
%             assertFalse(ischar(val));
%             assertEqual(val,ones(10,20));
%             assertEqual(id.error,ones(10,20));
        end
        
        
        %------------------------------------------------------------------
        function test_constructor(obj)
            % >> w = IX_dataset_2d (x,y)
            ds = IX_dataset_2d(1:10,1:20);
            % assertTrue(ds.get_isvalid());     % *** DELETED PROPERTY
            assertEqual(ds.x,(1:10)');          % now column
            assertEqual(ds.y,(1:20)');          % now column
            assertEqual(ds.signal,zeros(10,20));
            assertEqual(ds.error,zeros(10,20));
            
            
            %   >> w = IX_dataset_2d (x,y,signal)
            ds = IX_dataset_2d(1:10,1:20,ones(9,19));
            % assertTrue(ds.get_isvalid());     % *** DELETED PROPERTY
            assertEqual(ds.x,(1:10)');          % now column
            assertEqual(ds.y,(1:20)');          % now column
            assertEqual(ds.signal,ones(9,19));
            assertEqual(ds.error,zeros(9,19));
            
            
            %   >> w = IX_dataset_2d (x,y,signal,error)
            ds = IX_dataset_2d(1:10,1:20,ones(10,20),ones(10,20));
            % assertTrue(ds.get_isvalid());     % *** DELETED PROPERTY
            assertEqual(ds.x,(1:10)');          % now column
            assertEqual(ds.y,(1:20)');          % now column
            assertEqual(ds.signal,ones(10,20));
            assertEqual(ds.error,ones(10,20));
            
            
            %   >> w = IX_dataset_2d (x,y,signal,error,title,x_axis,y_axis,s_axis)
            ds = IX_dataset_2d(1:20,1:10,ones(20,10),ones(20,10),...
                'my object','x-axis name','y-axis name','signal');
            % assertTrue(ds.get_isvalid());     % *** DELETED PROPERTY
            assertEqual(ds.x,(1:20)');          % now column
            assertEqual(ds.y,(1:10)');          % now column
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
            % assertTrue(ds.get_isvalid());     % *** DELETED PROPERTY
            assertEqual(ds.x,(1:20)');          % now column
            assertEqual(ds.y,(1:10)');          % now column
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
            % assertTrue(ds.get_isvalid());     % *** DELETED PROPERTY
            assertEqual(ds.x,(1:15)');          % now column
            assertEqual(ds.y,(1:10)');          % now column
            assertEqual(ds.signal,ones(15,10));
            assertEqual(ds.error,ones(15,10));
            assertEqual(ds.title,{'my object'});
            assertEqual(ds.x_axis.caption,{'x-axis name'});
            assertEqual(ds.y_axis.caption,{'y-axis name'});
            assertEqual(ds.s_axis.caption,{'signal'});
            assertEqual(ds.x_distribution,false);
            assertEqual(ds.y_distribution,false);
        end
        
        
        %------------------------------------------------------------------
        function test_methods(obj)
            ds = IX_dataset_2d(1:10,1:15,ones(10,15),ones(10,15),...
                'my object','x-axis name','y-axis name','signal');
            
            [ax,hist] = ds.axis(2);
            assertFalse(hist);
            assertEqual(ax.values,1:15);
            assertTrue(isa(ax.axis,'IX_axis'));
            assertTrue(ax.distribution);
            
            dsa = repmat(ds,2,1);
            dsa(2).x = 0.5:1:10.5;
            
            [ax,hist] = dsa(1).axis;
            assertEqual(hist,false);
            assertEqual(ax(1).values,1:10);
            assertEqual(ax(2).values,1:15);
            
            is_hist = dsa.ishistogram;
            is_hist1 = ishistogram(dsa,1);
            is_hist2 = ishistogram(dsa,2);
            assertEqual(is_hist,[is_hist1;is_hist2]);
            assertFalse(is_hist(1,1));
            assertTrue(is_hist(1,2));
            assertFalse(is_hist(2,1));
            assertFalse(is_hist(2,2));
                        
            ids = dsa.point2hist();
            idr = ids.hist2point();
            %BUG?
            %           assertEqual(dsa,idr);
            
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
