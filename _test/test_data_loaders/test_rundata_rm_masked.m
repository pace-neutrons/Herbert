classdef test_rundata_rm_masked< TestCase
    %
    %
    
    properties
    end
    methods
        %
        function this=test_rundata_rm_masked(name)
            this = this@TestCase(name);
        end
        % tests themself
        function test_throws_on_empty_rundata(~)
            f = @()rm_masked(rundata());
            assertExceptionThrown(f,'RUNDATA:rm_masked');
        end
        function test_throws_on_inconsisten_rundata(~)
            run=rundata();
            run.S=ones(3,5);
            run.ERR=ones(3,5);
            run.det_par=ones(6,3);
            f = @()rm_masked(run);
            assertExceptionThrown(f,'RUNDATA:rm_masked');
        end
        function test_works_do_nothing(~)
            run=rundata();
            run.S=ones(3,5);
            run.ERR=ones(3,5);
            run.en = 1:4;
            run.det_par=ones(6,5);
            [s,err,det]=rm_masked(run);
            
            assertEqual(run.S,s);
            assertEqual(run.ERR,err);
            assertEqual(run.det_par,det);
        end
        function test_works_removesNAN(~)
            run=rundata();
            run.S=ones(3,5);
            run.ERR=ones(3,5);
            run.en = 1:4;
            run.det_par=get_hor_format(ones(6,5),'fffff');
            
            run.S(1,1)=NaN;
            run.S(1,2)=Inf;
            
            [s,err,det]=rm_masked(run);
            
            assertEqual(size(s),[3,3]);
            assertEqual(size(err),size(s));
            assertEqual(numel(det.width),3);
        end
        function test_all_masking_disabled(~)
            run=rundata();
            run.S=ones(3,5);
            run.ERR=ones(3,5);
            run.en = 1:4;
            run.det_par=get_hor_format(ones(6,5),'fffff');
            
            run.S(1,1)=NaN;
            run.S(1,2)=Inf;
            
            [s,err,det]=rm_masked(run,false,false);
            
            assertEqual(size(s),[3,5]);
            assertEqual(size(err),size(s));
            assertEqual(numel(det.width),5);
        end
        
        function test_inf_masking_disabled(~)
            run=rundata();
            run.S=ones(3,5);
            run.ERR=ones(3,5);
            run.en = 1:4;
            run.det_par=get_hor_format(ones(6,5),'fffff');
            
            run.S(1,1)=NaN;
            run.S(1,2)=Inf;
            
            [s,err,det]=rm_masked(run,true,false);
            
            assertEqual(size(s),[3,4]);
            assertEqual(size(err),size(s));
            assertEqual(numel(det.width),4);
        end
        
        function test_nan_masking_disabled(~)
            run=rundata();
            run.S=ones(3,5);
            run.ERR=ones(3,5);
            run.en = 1:4;
            run.det_par=get_hor_format(ones(6,5),'fffff');
            
            run.S(1,1)=NaN;
            run.S(1,2)=Inf;
            
            [s,err,det]=rm_masked(run,false);
            
            assertEqual(size(s),[3,4]);
            assertEqual(size(err),size(s));
            assertEqual(numel(det.width),4);
        end
        
        
    end
end

