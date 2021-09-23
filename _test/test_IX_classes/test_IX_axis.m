classdef test_IX_axis <  TestCase
    % Test class to test IX_axis methods
    
    properties
    end
    
    methods
        %-------------------------------------------------------------------
        function this=test_IX_axis(varargin)
            if nargin == 0
                name = 'test_IX_axis';
            else
                name = varargin{1};
            end
            this = this@TestCase(name);
        end
        
        %-------------------------------------------------------------------
        function test_load_1(obj)
            % Tick labels: 2017-2021: stored as column vector; Oct 2021 is
            % a row vector. Check that can load old format .mat file
            % correctly
            w = IX_axis();
            w.caption = {'Hello';'mister'};
            w.units = 'meV';
            w.code = '$w';
            ticks.positions = [1,3,5,7];
            ticks.labels = {'one','three','five','seven'};
            w.ticks = ticks;
            
            tmp = load('testdata_IX_axis_2017-2021_format.mat');
            
            assertEqual(w, tmp.w)
        end
        
        %-------------------------------------------------------------------
        function test_methods_1(obj)
            ia = IX_axis();
            ia.caption = 'my axis name';
            assertEqual(ia.caption, {'my axis name'});
        end
            
        function test_methods_2(obj)
            ia = IX_axis();
            ia.caption = 'my axis name';
            ia.units = 'mEv';
            ia.code = 'blabla';
            assertEqual(ia.units, 'mEv');
            assertEqual(ia.code, 'blabla');
        end
            
        function test_methods_3(obj)
            ia = IX_axis();
            ia.caption = 'my axis name';
            ia.units = 'mEv';
            ia.code = 'blabla';
            ia.ticks = [];
            %assertEqual(ia.ticks,'');
            assertEqual(ia.ticks, struct('positions',[],'labels',{{}}));
        end
            
        function test_methods_4(obj)
            ia = IX_axis();
            op = struct('type', '.', 'subs', 'ticks');
            f = @()subsasgn(ia, op, struct());  % function is: >> ia.ticks=struct()
            assertExceptionThrown(f, 'HERBERT:check_and_set_ticks_:invalid_argument');
        end
            
        function test_methods_5(obj)
            ia = IX_axis();
            data = struct('positions',[],'labels',{{}});
            ia.ticks = data;
            assertEqual(ia.ticks, data);
        end
            
        function test_methods_6(obj)
            ia = IX_axis();
            data.labels= {'1','2','3'};
            op = struct('type', '.', 'subs', 'ticks');
            f = @()subsasgn(ia, op, data);  % function is: >> ia.ticks=data
            assertExceptionThrown(f, 'HERBERT:check_and_set_ticks_:invalid_argument');
        end
            
        function test_methods_7(obj)
            ia = IX_axis();
            data.labels = {};
            data.positions = [1,2,3];
            ia.ticks = data;
            da = ia.ticks;
            assertEqual(da.positions, data.positions)
        end
            
        function test_methods_8(obj)
            ia = IX_axis();
            data.positions = [1,2,3];
            data.labels = {'a','b','c'};
            ia.ticks = data;
            assertEqual(ia.ticks.positions, data.positions);
            assertEqual(ia.ticks.labels, data.labels);
        end
        
        %-------------------------------------------------------------------
        function test_constructor_1(obj)
            ia = IX_axis('my axis name');
            assertEqual(ia.caption, {'my axis name'});
        end
        
        function test_constructor_2(obj)
            ia = IX_axis('my axis name','mEv');
            assertEqual(ia.caption, {'my axis name'});
            assertEqual(ia.units, 'mEv');
        end
        
        function test_constructor_3(obj)
            ia = IX_axis('my axis name','mEv','code');
            assertEqual(ia.caption, {'my axis name'});
            assertEqual(ia.units, 'mEv');
            assertEqual(ia.code, 'code');
        end
        
        function test_constructor_4(obj)
            ia = IX_axis('my axis name', 'mEv', '', [1,2,3]);
            assertEqual(ia.caption, {'my axis name'});
            assertEqual(ia.units, 'mEv');
            assertEqual(ia.code, '');
        end
        
        function test_constructor_5(obj)
            ia = IX_axis('my axis name', 'mEv', '', [1,2,3]);
            da = ia.ticks;
            assertEqual(da.positions, [1,2,3])
            assertTrue(iscell(da.labels));
            assertEqual(da.labels, {});
        end
        
        function test_constructor_5b(obj)
            ia = IX_axis('my axis name', 'mEv', '', [1,2,3], {'','',''});
            da = ia.ticks;
            assertEqual(da.positions, [1,2,3])
            assertTrue(iscell(da.labels));
            assertEqual(da.labels, {'','',''});
        end
        
        function test_constructor_6(obj)
            data.positions = [1,2,3];
            data.labels = {'a','b','c'};
            ia = IX_axis('my axis name','mEv','', data.positions, data.labels);

            assertEqual(ia.caption, {'my axis name'});
            assertEqual(ia.units, 'mEv');
            assertEqual(ia.code, '');
            da = ia.ticks;
            assertEqual(da.positions, [1,2,3])
            assertEqual(ia.ticks.labels, data.labels(:)');
        end
        
        function test_constructor_7(obj)
            data.positions = [1,2,3];
            data.labels = {'a','b','c'};
            ia = IX_axis('my axis name', 'mEv', '', data);

            assertEqual(ia.caption, {'my axis name'});
            assertEqual(ia.units, 'mEv');
            assertEqual(ia.code, '');
            da = ia.ticks;
            assertEqual(da.positions, [1,2,3])
            assertEqual(ia.ticks.labels, data.labels);
        end
        
        function test_constructor_8(obj)
            data.positions = [1,2,3];
            data.labels = {'a','b','c'};
            ia = IX_axis('my axis name', 'mEv', '', data);

            ias = structPublic(ia);
            ia = IX_axis(ias);
            
            assertEqual(ia.caption, {'my axis name'});
            assertEqual(ia.units, 'mEv');
            assertEqual(ia.code, '');
            da = ia.ticks;
            assertEqual(da.positions, [1,2,3])
            assertEqual(ia.ticks.labels, data.labels(:)');
        end
        
    end
    
end
