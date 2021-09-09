classdef test_IX_dataset_1d <  TestCaseWithSave
    % Test class to test IX_dataset_1d methods
    %
    % Modified T.G.Perring 202-07-18 as part of refactoring of IX_dataset
    %   - IX_dataset properties valid_ and error_mess_ deleted, so that
    %     get_valid and associated methods no longer exist. Objects are
    %     always valid if they were created.
    
    properties
        w1ref
        S
    end
    
    methods
        function obj=test_IX_dataset_1d (name)
            obj@TestCaseWithSave(name);
            
            S.title = 'My object';
            S.signal = 1001:1010;
            S.error = 11:20;
            S.s_axis  = 'y-axis name';
            S.x = 101:111;
            S.x_axis = 'x-axis name';
            S.x_distribution = false;
            
            obj.w1ref = struct_to_IX_dataset_1d(S);
            obj.S = S;
            
            obj.save()
        end
        
        %------------------------------------------------------------------
        function test_constructor(obj)
            %   >> w = IX_dataset_1d (x)
            ds = IX_dataset_1d(1:10);
            assertEqual(ds.x,(1:10));
            assertEqual(ds.signal,zeros(10,1));
            assertEqual(ds.error,zeros(10,1));
            
            
            %   >> w = IX_dataset_1d (x,signal)
            ds = IX_dataset_1d(1:10,ones(1,9));
            assertEqual(ds.x,(1:10));
            assertEqual(ds.signal,ones(9,1));
            assertEqual(ds.error,zeros(9,1));
            
            
            %   >> w = IX_dataset_1d (x,signal,error)
            ds = IX_dataset_1d(1:10,ones(1,10),ones(1,10));
            assertEqual(ds.x,(1:10));
            assertEqual(ds.signal,ones(10,1));
            assertEqual(ds.error,ones(10,1));
            
            
            % *** RE-INSERT TEST
            %             data = [1:10;2*ones(1,10);ones(1,10)];
            %             ds = IX_dataset_1d(data);
            
            
            %   >> w = IX_dataset_1d (x,signal,error,title,x_axis,s_axis)
            ds = IX_dataset_1d(1:10,ones(1,10),ones(1,10),'my object',...
                'x-axis name','y-axis name');
            assertEqual(ds.x,(1:10));
            assertEqual(ds.signal,ones(10,1));
            assertEqual(ds.error,ones(10,1));
            assertEqual(ds.title,{'my object'});
            assertEqual(ds.x_axis.caption,{'x-axis name'});
            assertEqual(ds.s_axis.caption,{'y-axis name'});
            
            
            %   >> w = IX_dataset_1d (x,signal,error,title,x_axis,s_axis,...
            %                                               x_distribution)
            ds = IX_dataset_1d(1:10,ones(1,10),ones(1,10),...
                'my object','x-axis name','y-axis name',false);
            assertEqual(ds.x,(1:10));
            assertEqual(ds.signal,ones(10,1));
            assertEqual(ds.error,ones(10,1));
            assertEqual(ds.title,{'my object'});
            assertEqual(ds.x_axis.caption,{'x-axis name'});
            assertEqual(ds.s_axis.caption,{'y-axis name'});
            assertEqual(ds.x_distribution,false);
            
            
            %   >> w = IX_dataset_1d (title, signal, error, s_axis, x,...
            %                                       x_axis, x_distribution)
            ds = IX_dataset_1d('my object',ones(1,10),ones(1,10),...
                'y-axis name',1:10,'x-axis name',false);
            assertEqual(ds.x,(1:10));
            assertEqual(ds.signal,ones(10,1));
            assertEqual(ds.error,ones(10,1));
            assertEqual(ds.title,{'my object'});
            assertEqual(ds.x_axis.caption,{'x-axis name'});
            assertEqual(ds.s_axis.caption,{'y-axis name'});
            assertEqual(ds.x_distribution,false);
        end
        
        function test_constructor_by_array_args(obj)
            %   >> w = IX_dataset_1d (x)
            ds = IX_dataset_1d(1:10);
            ds2 = IX_dataset_1d({1:10});
            assertEqual(ds, ds2);
            
            
            %   >> w = IX_dataset_1d (x,signal)
            ds = IX_dataset_1d(1:10,ones(1,9));
            ds2 = IX_dataset_1d({1:10},ones(1,9));
            assertEqual(ds, ds2);
            
            
            %   >> w = IX_dataset_1d (x,signal,error)
            ds = IX_dataset_1d(1:10,ones(1,10),ones(1,10));
            ds2 = IX_dataset_1d({1:10},ones(1,10),ones(1,10));
            assertEqual(ds, ds2);
            
            
            % *** RE-INSERT TEST
            %             data = [1:10;2*ones(1,10);ones(1,10)];
            %             ds = IX_dataset_1d(data);
            
            
            %   >> w = IX_dataset_1d (x,signal,error,title,x_axis,s_axis)
            ds = IX_dataset_1d(1:10,ones(1,10),ones(1,10),'my object',...
                'x-axis name','y-axis name');
            ds2 = IX_dataset_1d({1:10},ones(1,10),ones(1,10),{'my object'},...
                {'x-axis name'},{'y-axis name'});
            assertEqual(ds, ds2);
            
            
            %   >> w = IX_dataset_1d (x,signal,error,title,x_axis,s_axis,...
            %                                               x_distribution)
            ds = IX_dataset_1d(1:10,ones(1,10),ones(1,10),...
                'my object','x-axis name','y-axis name',false);
            ds2 = IX_dataset_1d(1:10,ones(1,10),ones(1,10),...
                {'my object'},'x-axis name',{'y-axis name'},false);
            assertEqual(ds, ds2);
            
            
            %   >> w = IX_dataset_1d (title, signal, error, s_axis, x,...
            %                                       x_axis, x_distribution)
            ds = IX_dataset_1d('my object',ones(1,10),ones(1,10),...
                'y-axis name',1:10,{'x-axis name','Indeed!'},false);
            ds2 = IX_dataset_1d('my object',ones(1,10),ones(1,10),...
                {'y-axis name'},{1:10},{'x-axis name','Indeed!'},{false});
            assertEqual(ds, ds2);
        end
        
        function test_constructor_small(obj)
            % Single point is valid
            ds = IX_dataset_1d(1, 10);
            assertEqual(size(ds.error),[1,1])
        end
        
        function test_constructor_null(obj)
            % Single bin boundary is valid
            ds = IX_dataset_1d(1, zeros(0,1));
            assertEqual(size(ds.error),[0,1])
        end
        
        function test_non_monotonic_point (obj)
            %   >> w = IX_dataset_1d (x,signal,error)
            % Should re-order the data
            ds = IX_dataset_1d([1:7,9,8,10],[1001:1007,1009,1008,1010],...
                [101:107,109,108,110]);
            assertEqual(ds.x,(1:10));
            assertEqual(ds.signal,(1001:1010)');
            assertEqual(ds.error,(101:110)');
        end
        
        function test_non_strictly_monotonic_hist (obj)
            %   >> w = IX_dataset_1d (x,signal,error)
            % Should fail
            try
                ds = IX_dataset_1d([1:7,7,9,10,11],[1001:1007,1009,1008,1010],...
                    [101:107,109,108,110]);
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
            
            ds = IX_dataset_1d(1:10,ones(1,10),ones(1,10),...
                'my object','x-axis name','y-axis name',false);
            
            try
                ds.x = 1:15;
                error('Failure to throw error due to invalid axes values')
            catch ME
                if ~isequal(ME.identifier,...
                        'HERBERT:check_properties_consistency_:invalid_argument')
                    rethrow(ME)
                end
            end
            
            try
                ds.signal = ones(1,15);
                error('Failure to throw error due to invalid size of signal array')
            catch ME
                if ~isequal(ME.identifier,...
                        'HERBERT:check_properties_consistency_:invalid_argument')
                    rethrow(ME)
                end
            end
            
        end
        
        
        %------------------------------------------------------------------
        function test_set_1(obj)
            % Change title
            test_property_change_ok (obj.S, 'title', 'New title')
        end
        
        function test_set_2(obj)
            % Change title to invalid data type
            mess = 'HERBERT:check_and_set_title_:invalid_argument';
            test_property_change_ok (obj.S, 'title', sigvar(37), mess)
        end
        
        function test_set_3(obj)
            % Go from hist to point dataset
            test_property_change_ok (obj.S, 'x', obj.S.x(1:end-1))
        end
        
        function test_set_4(obj)
            % Change distribution type
            test_property_change_ok (obj.S, 'x_distribution', 1)
        end
        
        function test_set_non_strictly_monotonic_hist (obj)
            % Should fail
            ds = IX_dataset_1d(1:11,[1001:1007,1009,1008,1010],...
                    [101:107,109,108,110]);
            try
                ds.x = [1:6,6:10];
                error('Failure to throw error due to invalid axes values')
            catch ME
                if ~isequal(ME.identifier,...
                        'HERBERT:check_properties_consistency_:invalid_argument')
                    rethrow(ME)
                end
            end
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

%==========================================================================
function test_property_change_ok (Struc, name, value, message_ID)
% Check that a property change is correctly made.
% If the property name is invalid or a change is not valid, then an error
% is expected; in this case an error with the given message_ID must be created

% Create reference object - this had better work!
wref = struct_to_IX_dataset_1d (Struc);

% Create object using the constructor but with the named field changed
Struc_new = Struc;
Struc_new.(name) = value;
try
    wnew = struct_to_IX_dataset_1d (Struc_new);
    % We expect an error to be thrown if message is present
    if exist('message_ID','var')
        error (['Failure to throw error with identifier: ', '''',message_ID,''''])
    end
catch ME
    if exist('message_ID','var') && isequal(ME.identifier, message_ID)
        % We expect this error
        return
    else
        % Throw an error only if the error message ID is unexpected
        rethrow(ME)
    end
end

% If reached this point, then we expect to be able to change the field
% Get object by changing object property
wtest = wref;
wtest.(name) = value;

assertEqualToTol(wtest, wnew, 'tol', [1e-14, 1e-14])

end

%-----------------------------------------
function obj = struct_to_IX_dataset_1d (S)
% Create IX_dataset_1d from structure
C = struct2cell(S)';
obj = IX_dataset_1d(C{:});

end
