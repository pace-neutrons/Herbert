classdef test_range_add_border < TestCase
    % Unit tests to check range_add_border function
    
    properties
    end
    
    methods
        function ps = test_range_add_border(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = 'test_range_add_border ';
            end
            ps = ps@TestCase(name);
        end
        %
        function test_zero_border_do_nothing(~)
            range = [-1*ones(1,4);ones(1,4)];
            range_out = range_add_border(range,0);
            assertEqual(range,range_out);
        end
        %
        function test_no_tol_eq_eps_tol(~)
            range = [-1*ones(1,4);ones(1,4)];
            range_no  = range_add_border(range);
            range_eps = range_add_border(range,-eps);
            assertEqual(range_no,range_eps );
        end
        %
        function test_zero_width(~)
            range = [-1,1,-1,1;-1,1,-1,1];
            range_zero  = range_add_border(range);
            fe = eps;
            ref_range = [-1-fe,1-fe,-1-fe,1-fe;
                -1+fe,1+fe,-1+fe,1+fe];
            assertEqual(range_zero,ref_range);
        end
        %
        function test_near_zero(~)
            range = [0,0,0,0;0,1,0,1];
            range_zero  = range_add_border(range);
            fe = eps;
            ref_range = [-fe,-fe,-fe,-fe;
                fe,1+fe,fe,1+fe];
            assertEqual(range_zero,ref_range);
        end
        %
        function test_large_value_relerr(~)
            range = [-100,-100;100,100];
            range_calc  = range_add_border(range);
            fe = eps;
            ref_range = [-100-100*fe,-100-100*fe;...
                100+100*fe,100+100*fe];
            assertEqual(range_calc,ref_range);
        end
        %
        function test_large_value_abserr_ignored(~)
            range = [-100,-100;100,100];
            fe = eps;
            range_calc  = range_add_border(range,fe);
            assertEqual(range_calc,range);
        end
        function test_eps_border_is_valid(~)
            range = [-1,1;-1,1];
            range_calc  = range_add_border(range);
            range_rat = range_calc(1,:)./range_calc(2,:);
            range_ref = range(1,:)./range(2,:);
            difr = abs(range_rat-range_ref)-2*eps;
            zer = zeros(1,2);
            assertEqual(difr ,zer);
        end
        
        function test_eps_abserr_on_large_border_is_relerr(~)
            range = [-100,100,-1,-10;-100,100,1,10];
            range_calc  = range_add_border(range,eps);
            
            assertEqual(range_calc(1,1),-100-100*eps);
            assertEqual(range_calc(2,1),-100+100*eps);
            assertEqual(range_calc(1,2),100-100*eps);
            assertEqual(range_calc(2,2),100+100*eps);
            assertEqual(range_calc(1,3),-1-eps);
            assertEqual(range_calc(2,3),1+eps);
            assertEqual(range_calc(1,4),-10);
            assertEqual(range_calc(2,4),10);
            
        end
        
        
    end
end

