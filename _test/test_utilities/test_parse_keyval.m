classdef test_parse_keyval < TestCaseWithSave
    % Test of parse_keyval
    properties
        keywords
        keyval_def
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_parse_keyval (name)
            self@TestCaseWithSave(name);
            
            self.keywords = {'alldata','sum','integrate'};
            self.keyval_def = {99, [], {'Minty', false}};
            
            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_1 (self)
            keyval = parse_keyval (self.keywords);
            assertEqual (keyval, {[], [], []})
        end
        
        %--------------------------------------------------------------------------
        function test_2 (self)
            keyval = parse_keyval (self.keywords,'all',[13,14]);
            assertEqual (keyval, {[13,14], [], []})
        end
        
        %--------------------------------------------------------------------------
        function test_3 (self)
            keyval = parse_keyval (self.keywords,'sum',{'Bart!',true},...
                'all',[13,14]);
            assertEqual (keyval, {[13,14], {'Bart!',true}, []})
        end
        
        %--------------------------------------------------------------------------
        function test_4 (self)
            % Repeated keyword - should result in error
            f = @()parse_keyval(self.keywords,'sum',{'Bart!',true},'all',...
                [13,14],'sum',11);
            assertExceptionThrown(f, 'HERBERT:parse_keyval:invalid_argument');
        end
        
        %--------------------------------------------------------------------------
        function test_5 (self)
            % Keyword not given a value
            f = @()parse_keyval (self.keywords,'sum',{'Bart!',true},'all',...
                [13,14],'integrate');
            assertExceptionThrown(f, 'HERBERT:parse_keyval:invalid_argument');
        end
        
        %--------------------------------------------------------------------------
        function test_6 (self)
            keyval = parse_keyval (self.keywords, self.keyval_def);
            assertEqual (keyval, self.keyval_def)
        end
        
        %--------------------------------------------------------------------------
        function test_7 (self)
            keyval = parse_keyval (self.keywords, self.keyval_def, 'all', [13,14]);
            assertEqual (keyval, {[13,14], [], {'Minty', false}})
        end
        
        %--------------------------------------------------------------------------
        function test_8 (self)
            keyval = parse_keyval (self.keywords, self.keyval_def,...
                'sum',{'Bart!',true}, 'all', [13,14]);
            assertEqual (keyval, {[13,14], {'Bart!',true}, {'Minty', false}})
        end
        
        %--------------------------------------------------------------------------
        function test_9 (self)
            % Keyword not given a value
            f = @()parse_keyval (self.keywords, self.keyval_def,...
                'sum', {'Bart!',true}, 'all', [13,14], 'integrate');
            assertExceptionThrown(f, 'HERBERT:parse_keyval:invalid_argument');
        end
        
        %--------------------------------------------------------------------------
    end
end
