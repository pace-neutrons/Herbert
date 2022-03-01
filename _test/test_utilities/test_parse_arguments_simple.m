classdef test_parse_arguments_simple < TestCaseWithSave
    % Test of parse_arguments_simple
    properties
        keywords
        flags
        defaults

        keywords2
        flags2
        defaults2
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_parse_arguments_simple (name)
            self@TestCaseWithSave(name);
            
            self.keywords = {'alldata','sum','integrate'};
            self.flags = [0,0,0];
            self.defaults = {99, [], {'Minty', false}};
            
            self.keywords2 = {'background','normalise','modulation','output'};
            self.flags2 = [0,1,1,0];
            self.defaults2 = {[12000,18000], 1, 0, 'data.txt'};
            
            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_k1 (self)
            [~, keyval] = parse_arguments_simple (self.keywords, self.flags, self.defaults);
            assertEqual (keyval, self.defaults)
        end
        
        %--------------------------------------------------------------------------
        function test_k2 (self)
            [~, keyval] = parse_arguments_simple (self.keywords, self.flags, self.defaults,...
                'all',[13,14]);
            assertEqual (keyval, {[13,14], [], {'Minty', false}})
        end
        
        %--------------------------------------------------------------------------
        function test_k3 (self)
            [~, keyval] = parse_arguments_simple (self.keywords, self.flags, self.defaults,...
                'sum',{'Bart!',true},'all',[13,14]);
            assertEqual (keyval, {[13,14], {'Bart!',true}, {'Minty', false}})
        end
        
        %--------------------------------------------------------------------------
        function test_k4 (self)
            % Repeated keyword - should result in error
            f = @()parse_arguments_simple(self.keywords, self.flags, self.defaults,...
                'sum',{'Bart!',true},'all',[13,14],'sum',11);
            assertExceptionThrown(f, 'HERBERT:parse_arguments_simple:invalid_argument');
        end
        
        %--------------------------------------------------------------------------
        function test_k5 (self)
            % Keyword not given a value
            f = @()parse_arguments_simple (self.keywords, self.flags, self.defaults,...
                'sum',{'Bart!',true},'all',[13,14],'integrate');
            assertExceptionThrown(f, 'HERBERT:parse_arguments_simple:invalid_argument');
        end
        
        %--------------------------------------------------------------------------
        function test_1 (self)
            % Straightforward use, with 'noflag'
            
            [par, keyval, present] = parse_arguments_simple (...
                self.keywords2, self.flags2, self.defaults2,...
                'input_file.dat', 18, {'hello','tiger'},...
                'back', [15000,19000], 'mod', 'norm', 0);
            
            par_ref = {'input_file.dat', 18, {'hello','tiger'}};
            keyval_ref = {[15000,19000], false, true, 'data.txt'};
            present_ref = logical([1,1,1,0]);
            
            assertEqual (par_ref, par)
            assertEqual (keyval_ref, keyval)
            assertEqual (present_ref, present)
        end
        
        %--------------------------------------------------------------------------
        function test_2  (self)
            % Try to set a flag to an invalid value
            % Should throw an error
            
            f = @()parse_arguments_simple (...
                self.keywords2, self.flags2, self.defaults2,...
                'input_file.dat', 18, {'hello','tiger'},...
                'back', [15000,19000], 'mod','invalid_value','nonorm');
            assertExceptionThrown(f, 'HERBERT:parse_arguments_simple:invalid_argument');
        end
        
        %--------------------------------------------------------------------------
        function test_3 (self)
            % Test a keyword value also being a string that matches a 
            % keyword. This is valid
            
            [par, keyval, present] = parse_arguments_simple (...
                self.keywords2, self.flags2, self.defaults2,...
                'input_file.dat', 18, {'hello','tiger'},...
                'back', 'normalise', 'mod');
            
            par_ref = {'input_file.dat', 18, {'hello','tiger'}};
            keyval_ref = {'normalise', true, true, 'data.txt'};
            present_ref = logical([1,0,1,0]);
            
            assertEqual (par_ref, par)
            assertEqual (keyval_ref, keyval)
            assertEqual (present_ref, present)
        end

        %--------------------------------------------------------------------------
    end
end
