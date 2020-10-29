classdef test_mfit_settings < TestCase
    properties
    end
    methods
        %
        function this=test_mfit_settings(name)
            if nargin < 1
                name = 'test_mfit_settings';
            end
            this = this@TestCase(name);
        end
        
        function test_set_multifun(~)
            ds1 = IX_dataset_1d();
            ds2 = IX_dataset_1d();
            mfc=mfclass(ds1,ds2);
            funs = {@(x,p)(1+p*x),@(x,p)(p+x.^2)};
            par = {1,1};
            free = {1,1};
            mfc = mfc.set_local_foreground;
            mfc = mfc.set_fun(funs,par,free);
            assertTrue(mfc.local_foreground);
        end
        
        function test_set_multi_fun(~)
            ds1 = IX_dataset_1d();
            ds2 = IX_dataset_1d();
            mfc=mfclass(ds1,ds2);
            funs = {@(x,p)(1+p*x),@(x,p)(p+x.^2)};
            
            mfc = mfc.set_fun(funs);
            assertTrue(mfc.local_foreground);
            assertTrue(iscell(mfc.fun))
            setfun = mfc.fun;
            assertEqual(setfun{1},funs{1})
            assertEqual(setfun{2},funs{2})            
            
        end
        
        
    end
    
end

