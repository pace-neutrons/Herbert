classdef test_box_intersect3D < TestCase
    %
    properties
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_box_intersect3D(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = 'test_box_intersect3D';                
            end            
            self = self@TestCase(name);            
        end
        %--------------------------------------------------------------------------        
        function test_intersect_box3D_parallel_inside(~)
            % 
            cp = box_intersect([0,0,0;1,1,1]',[0.5,0.5,0;0.5,1,0;0.5,0.5,0.5]');
            assertEqual(cp,[0.5,0,0;0.5,1,0;0.5,0,1;0.5,1,1]');
        end
        
        function test_intersect_box3D_parallel_outside(~)
            % 
            cp = box_intersect([0,0,0;1,1,1]',[2,0,0;2,2,0;2,0,2]');
            assertTrue(isempty(cp));
        end
        function test_intersect_box3D_4pointsDir1(~)
            % 
            cp = box_intersect([0,0,0;1,1,1]',[1/2,0,0;1/2,0,1;1,1/2,0]');
            assertEqual(cp,[1/2,0,0;1,1/2,0;1/2,0,1;1,1/2,1]');
        end        
        function test_intersect_box3D_3points(~)
            % 
            cp = box_intersect([0,0,0;1,1,1]',[1/2,0,0;1,0,1/2;1,1/2,0]');
            assertEqual(cp,[1/2,0,0;1,1/2,0;1,0,1/2]');
        end        
        function test_intersect_box3D_in2points_degenerated(~)
            % 
            cp = box_intersect([0,0,0;1,1,1]',[1,1,1;2,2,2;1,0,0]');
            assertEqual(cp,[0,0,0;1,0,0;0,1,1;1,1,1]');
        end
    end
end
