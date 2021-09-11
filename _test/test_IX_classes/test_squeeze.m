classdef test_squeeze <  TestCaseWithSave
    % Test class to test squeeze methods
    
    properties
    end
    
    methods
        function obj=test_squeeze (name)
            obj@TestCaseWithSave(name);
            obj.save()
        end
        
        %------------------------------------------------------------------
        function test_n1n_to_nn(obj)
            w = make_testdata_IX_dataset_nd ([5,1,2], 1, '-seed', 0);
            ws_ref = squeeze_simple (w, [1,0,1]);
            ws = squeeze (w);
            assertEqual (ws_ref, ws)
        end
        
        %------------------------------------------------------------------
        function test_n11_to_n1(obj)
            w = make_testdata_IX_dataset_nd ([1,5,1], 1, '-seed', 0);
            ws_ref = squeeze_simple (w, [0,1,1]);
            ws = squeeze (w, [1,2]);
            assertEqual (ws_ref, ws)
        end
        
        %------------------------------------------------------------------
        function test_n11_to_n(obj)
            w = make_testdata_IX_dataset_nd ([5,1,1], 1, '-seed', 0);
            ws_ref = squeeze_simple (w, [1,0,0]);
            ws = squeeze (w);
            assertEqual (ws_ref, ws)
        end
        
        %------------------------------------------------------------------
        function test_11n_to_n(obj)
            w = make_testdata_IX_dataset_nd ([1,1,5], 1, '-seed', 0);
            ws_ref = squeeze_simple (w, [0,0,1]);
            ws = squeeze (w);
            assertEqual (ws_ref, ws)
        end
        
        %------------------------------------------------------------------
        function test_111_to_n(obj)
            w = make_testdata_IX_dataset_nd ([1,1,1], 1, '-seed', 0);
            ws_ref = squeeze_simple (w, [0,0,0]);
            ws = squeeze (w);
            assertEqual (ws_ref, ws)
        end
        
        %------------------------------------------------------------------
        function test_1n_to_n(obj)
            w = make_testdata_IX_dataset_nd ([1,5], 1, '-seed', 0);
            ws_ref = squeeze_simple (w, [0,1]);
            ws = squeeze (w);
            assertEqual (ws_ref, ws)
        end
        
        %------------------------------------------------------------------
        function test_n_to_n(obj)
            w = make_testdata_IX_dataset_nd (5, 1, '-seed', 0);
            ws_ref = squeeze_simple (w, 1);
            ws = squeeze (w);
            assertEqual (ws_ref, ws)
            assertEqual (w, ws)
        end
        
        %------------------------------------------------------------------
        % Test arrays of objects
        %------------------------------------------------------------------
        function test_11n_to_arr(obj)
            w = make_testdata_IX_dataset_nd ([1,1,5], [3,2], '-seed', 0);
            ws_ref = repmat(IX_dataset_1d, 3, 2);
            for i=1:numel(ws_ref)
                ws_ref(i) = squeeze_simple (w(i), [0,0,1]);
            end
            ws = squeeze (w);
            assertEqual (ws_ref, ws)
        end
        
        %------------------------------------------------------------------
        function test_111_to_arr(obj)
            w = make_testdata_IX_dataset_nd ([1,1,1], [3,5], '-seed', 0);
            ws = squeeze (w);
            assertTrue(isa(ws,'IX_dataset_2d'))
            
            tmp = squeeze_simple (w(3,4), [0,0,0]);
            assertEqual (ws.signal(3,4), tmp.val)
            assertEqual (ws.error(3,4), tmp.err)
        end
        
        %------------------------------------------------------------------
    end
end

%--------------------------------------------------------------------------
function wout = squeeze_simple (w, keep)
% Simple version of squeeze for helping test full version. Few checks!
%
%   >> wout = squeeze_simple (w, keep)
%
%   w       Input IX_dataset_Xd object
%   keep    Logical vector indicating which axes to keep

keep = logical(keep);

[nd, sz] = dimensions(w);
ndout = sum(keep);
if numel(keep)~=nd
    error('HERBERT:squeeze_simple:invalid_argument',...
        'Trying to squeeze away non-simgleton dimensions')
elseif any(sz(~keep)~=1)
    error('HERBERT:squeeze_simple:invalid_argument',...
        'Trying to squeeze away non-singleton dimensions')
end

if ndout>0
    % At least one axis kept
    ax = axis(w);
    szout = sz(keep);
    if numel(szout)==1
        szout = [szout,1];
    end
    wout = IX_dataset_nd (w.title, reshape(w.signal, szout),...
        reshape(w.error, szout), w.s_axis, ax(keep));
    
else
    % Must have all dimensions length one, so scalar signal
    if ~isscalar(w.signal)
        error('HERBERT:squeeze_simple:invalid_argument','Non-scalar signal')
    end
    wout.val = w.signal;
    wout.err = w.error;
end

end
