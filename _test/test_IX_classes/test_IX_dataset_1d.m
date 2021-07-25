classdef test_IX_dataset_1d <  TestCase
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
        function this=test_IX_dataset_1d(varargin)
            if nargin == 0
                name = 'test_IX_dataset_1d';
            else
                name = varargin{1};
            end
            this = this@TestCase(name);
        end
        
        %------------------------------------------------------------------
        function test_properties(obj)
            id = IX_dataset_1d();
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
            
            % TGP 2021-07-18:
            % Modified the following tests as it is no longer possible to
            % set an object into an invalid state - an error is always thrown.
            % Also now create a non-empty dataset for the comparison
            ds = IX_dataset_1d(1:10,ones(1,10),ones(1,10),...
                'my object','x-axis name','y-axis name',false);
            
            try
                ds.x = 1:15;
                error('Failure to throw error due to invalid axes values')
%                 id.x = 1:10;
%                 assertFalse(id.get_isvalid())
%                 val = id.x;
%                 assertTrue(ischar(val));
%                 assertEqual('numel(signal)=0, numel(x)=10; numel(signal)  must be equal to numel(x) or numel(x)+1',val);
            catch ME
                if ~isequal(ME.identifier,...
                    'HERBERT:check_properties_consistency_:invalid_argument')
                    rethrow(ME)
                end
            end
            
            try
                ds.signal = ones(1,15);
                error('Failure to throw error due to invalid size of signal array')
%                 id.signal = ones(1,10);
%                 val = id.signal;
%                 assertTrue(ischar(val));
%                 assertEqual('numel(signal)=10, numel(error)=0; numel(signal)~=numel(error)',val);
%                 assertFalse(id.get_isvalid())
            catch ME
                if ~isequal(ME.identifier,...
                        'HERBERT:check_properties_consistency_:invalid_argument')
                    rethrow(ME)
                end
            end

        end
        
        
        %------------------------------------------------------------------
        function test_constructor(obj)
            %   >> w = IX_dataset_1d (x)
            ds = IX_dataset_1d(1:10);
            % assertTrue(ds.get_isvalid());     % *** DELETED PROPERTY
            assertEqual(ds.x,(1:10)');          % now column
            assertEqual(ds.signal,zeros(10,1));
            assertEqual(ds.error,zeros(10,1));
            
            
            %   >> w = IX_dataset_1d (x,signal)
            ds = IX_dataset_1d(1:10,ones(1,9));
            % assertTrue(ds.get_isvalid());     % *** DELETED PROPERTY
            assertEqual(ds.x,(1:10)');          % now column
            assertEqual(ds.signal,ones(9,1));
            assertEqual(ds.error,zeros(9,1));
            
            
            %   >> w = IX_dataset_1d (x,signal,error)
            ds = IX_dataset_1d(1:10,ones(1,10),ones(1,10));
            % assertTrue(ds.get_isvalid());     % *** DELETED PROPERTY
            assertEqual(ds.x,(1:10)');          % now column
            assertEqual(ds.signal,ones(10,1));
            assertEqual(ds.error,ones(10,1));
            

% *** RE-INSERT TEST
%             data = [1:10;2*ones(1,10);ones(1,10)];
%             ds = IX_dataset_1d(data);
%             % assertTrue(ds.get_isvalid());     % *** DELETED PROPERTY
%             assertEqual(ds.x,(1:10)');          % now column
%             assertEqual(ds.signal,2*ones(10,1));
%             assertEqual(ds.error,ones(10,1));
            
            
            %   >> w = IX_dataset_1d (x,signal,error,title,x_axis,s_axis)
            ds = IX_dataset_1d(1:10,ones(1,10),ones(1,10),'my object','x-axis name','y-axis name');
            % assertTrue(ds.get_isvalid());     % *** DELETED PROPERTY
            assertEqual(ds.x,(1:10)');          % now column
            assertEqual(ds.signal,ones(10,1));
            assertEqual(ds.error,ones(10,1));
            assertEqual(ds.title,{'my object'});
            assertEqual(ds.x_axis.caption,{'x-axis name'});
            assertEqual(ds.s_axis.caption,{'y-axis name'});
            
            
            %   >> w = IX_dataset_1d (x,signal,error,title,x_axis,s_axis, x_distribution)
            ds = IX_dataset_1d(1:10,ones(1,10),ones(1,10),...
                'my object','x-axis name','y-axis name',false);
            % assertTrue(ds.get_isvalid());     % *** DELETED PROPERTY
            assertEqual(ds.x,(1:10)');          % now column
            assertEqual(ds.signal,ones(10,1));
            assertEqual(ds.error,ones(10,1));
            assertEqual(ds.title,{'my object'});
            assertEqual(ds.x_axis.caption,{'x-axis name'});
            assertEqual(ds.s_axis.caption,{'y-axis name'});
            assertEqual(ds.x_distribution,false);
            
            
            %   >> w = IX_dataset_1d (title, signal, error, s_axis, x, x_axis, x_distribution)
            ds = IX_dataset_1d('my object',ones(1,10),ones(1,10),...
                'y-axis name',1:10,'x-axis name',false);
            % assertTrue(ds.get_isvalid());     % *** DELETED PROPERTY
            assertEqual(ds.x,(1:10)');          % now column
            assertEqual(ds.signal,ones(10,1));
            assertEqual(ds.error,ones(10,1));
            assertEqual(ds.title,{'my object'});
            assertEqual(ds.x_axis.caption,{'x-axis name'});
            assertEqual(ds.s_axis.caption,{'y-axis name'});
            assertEqual(ds.x_distribution,false);
        end
        
        
        %------------------------------------------------------------------
        function test_methods(obj)
            ds = IX_dataset_1d(1:10,ones(1,10),ones(1,10),...
                'my object','x-axis name','y-axis name');
            [ax,hist] = ds.axis;
            assertFalse(hist);
            assertEqual(ax.values,1:10);
            assertTrue(isa(ax.axis,'IX_axis'));
            assertTrue(ax.distribution);
            
            dsa = repmat(ds,2,1);
            dsa(2).x = 0.5:1:10.5;
            
            [ax,hist] = dsa.axis;
            assertEqual(hist,[false,true]);
            assertEqual(ax(1).values,1:10);
            assertEqual(ax(2).values,0.5:1:10.5);
            
            is_hist = dsa.ishistogram;
            is_hist1 = ishistogram(dsa,1);
            assertEqual(is_hist,is_hist1);
            assertFalse(is_hist(1));
            assertTrue(is_hist(2));
            
            ids = dsa.cnt2dist();
            idr = ids.dist2cnt();
            % Not equal -- bug in old code!
            %           assertEqual(dsa,idr);
            
        end
        
        
        %------------------------------------------------------------------
        function test_op_managers(obj)
            ds = IX_dataset_1d(1:10,ones(1,10),ones(1,10),...
                'my object','x-axis name','y-axis name');
            dsa = repmat(ds,2,1);
            
            dss = dsa(1) + dsa(2);
            assertEqual(dss.signal,2*ones(10,1));
            assertEqual(dss.error,sqrt(2*ones(10,1)));
            
            dsm = -ds;
            dss  = dss+dsm;
            assertEqual(dss.signal,ones(10,1));
            assertElementsAlmostEqual(dss.error,sqrt(3*ones(10,1)));
            
            dss  = dss+1;
            assertEqual(dss.signal,2*ones(10,1));
            assertElementsAlmostEqual(dss.error,sqrt(3*ones(10,1)));
            
            
            dss  = 1+ dss;
            assertEqual(dss.signal,3*ones(10,1));
            assertElementsAlmostEqual(dss.error,sqrt(3*ones(10,1)));
            
        end
        %------------------------------------------------------------------
    end
    
end
