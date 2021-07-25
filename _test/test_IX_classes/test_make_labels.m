classdef test_make_labels <  TestCaseWithSave
    % Test making of labels
    
    properties
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_make_labels (name)
            self@TestCaseWithSave(name);
            
            self.save()
        end
        
        
        %--------------------------------------------------------------------------
        function test_1 (self)
            % Not distribution along both axis
            x_axis = IX_axis('x-axis name');   x_dist = false;
            y_axis = IX_axis('y-axis name');   y_dist = false;
            s_axis = IX_axis('signal');
            w2 = IX_dataset_2d(1:20,1:10,3+rand(20,10),rand(20,10),...
                'my object',x_axis,y_axis,s_axis,x_dist,y_dist);
            
            [xcap,ycap,scap] = make_label(w2);
            
            assertEqual(xcap, {'x-axis name'})
            assertEqual(ycap, {'y-axis name'})
            assertEqual(scap, {'signal'})
        end
        
        
        %--------------------------------------------------------------------------
        function test_2 (self)
            % Not distribution along both axis; give units to the signal axis
            x_axis = IX_axis('x-axis name');   x_dist = false;
            y_axis = IX_axis('y-axis name');   y_dist = false;
            s_axis = IX_axis('signal','Counts');
            w2 = IX_dataset_2d(1:20,1:10,3+rand(20,10),rand(20,10),...
                'my object',x_axis,y_axis,s_axis,x_dist,y_dist);
            
            [xcap,ycap,scap] = make_label(w2);
            
            assertEqual(xcap, {'x-axis name'})
            assertEqual(ycap, {'y-axis name'})
            assertEqual(scap, {'signal (Counts)'})
        end
        
        
        %--------------------------------------------------------------------------
        function test_3 (self)
            % Distribution along both axis
            x_axis = IX_axis('x-axis name','Qx');   x_dist = true;
            y_axis = IX_axis('y-axis name','Qy');   y_dist = true;
            s_axis = IX_axis('signal');
            w2 = IX_dataset_2d(1:20,1:10,3+rand(20,10),rand(20,10),...
                'my object',x_axis,y_axis,s_axis,x_dist,y_dist);
            
            [xcap,ycap,scap] = make_label(w2);
            
            assertEqual(xcap, {'x-axis name (Qx)'})
            assertEqual(ycap, {'y-axis name (Qy)'})
            assertEqual(scap, {'signal (1 / Qx / Qy)'})
        end
        
        %--------------------------------------------------------------------------
        function test_4 (self)
            % Distribution along both axis; give units to the signal axis
            x_axis = IX_axis('x-axis name','Qx');   x_dist = true;
            y_axis = IX_axis('y-axis name','Qy');   y_dist = true;
            s_axis = IX_axis('signal','Counts');
            w2 = IX_dataset_2d(1:20,1:10,3+rand(20,10),rand(20,10),...
                'my object',x_axis,y_axis,s_axis,x_dist,y_dist);
            
            [xcap,ycap,scap] = make_label(w2);
            
            assertEqual(xcap, {'x-axis name (Qx)'})
            assertEqual(ycap, {'y-axis name (Qy)'})
            assertEqual(scap, {'signal (Counts / Qx / Qy)'})
            
        end
        
        %--------------------------------------------------------------------------
        function test_5 (self)
            % Distribution along both axis
            x_axis = IX_axis('x-axis name','Qx');   x_dist = true;
            s_axis = IX_axis('signal');
            w1 = IX_dataset_1d(1:20,3+rand(20,1),rand(20,1),...
                'my object',x_axis,s_axis,x_dist);
            
            [xcap,scap] = make_label(w1);
            
            assertEqual(xcap, {'x-axis name (Qx)'})
            assertEqual(scap, {'signal (1 / Qx)'})
        end
        
        %--------------------------------------------------------------------------
        function test_6 (self)
            % Distribution along both axis
            x_axis = IX_axis('x-axis name','Qx');   x_dist = true;
            s_axis = IX_axis('signal','Counts');
            w1 = IX_dataset_1d(1:20,3+rand(20,1),rand(20,1),...
                'my object',x_axis,s_axis,x_dist);
            
            [xcap,scap] = make_label(w1);
            
            assertEqual(xcap, {'x-axis name (Qx)'})
            assertEqual(scap, {'signal (Counts / Qx)'})
        end
        %--------------------------------------------------------------------------
    end
end
