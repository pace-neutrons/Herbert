classdef test_parse_flags < TestCaseWithSave
    % Test of parse_flags
    properties
        flagnames
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_parse_flags (name)
            self@TestCaseWithSave(name);
            
            self.flagnames = {'alldata','sum','integrate','alleycat', 'all'};
            
            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_1 (self)
            % Ambiguous flag name
            f = @()parse_flags (self.flagnames, 'al');
            assertExceptionThrown(f, 'HERBERT:parse_flags:invalid_argument');
        end
        
        %--------------------------------------------------------------------------
        function test_2 (self)
            flags = parse_flags (self.flagnames, 'all');
            assertEqual (flags, logical([0,0,0,0,1]))
        end
        
        %--------------------------------------------------------------------------
        function test_3 (self)
            % Unrecognised flagname
            f = @()parse_flags (self.flagnames, 'all', 'poop');
            assertExceptionThrown(f, 'HERBERT:parse_flags:invalid_argument');
        end
        
        %--------------------------------------------------------------------------
        function test_4 (self)
            % 'all' is an exact match to the fifth flag name
            flags = parse_flags (self.flagnames, 'sum', 'all');
            assertEqual (flags, logical([0,1,0,0,1]))
        end
        
        %--------------------------------------------------------------------------
        function test_5 (self)
            % 'all' is an exact match to the fifth flag name
            flags = parse_flags (self.flagnames, 'alle', 'sum', 'alld');
            assertEqual (flags, logical([1,1,0,1,0]))
        end
        
        %--------------------------------------------------------------------------
        function test_6 (self)
            % 'sum' given twice
            f = @()parse_flags (self.flagnames, 'sum', 'all', 'su');
            assertExceptionThrown(f, 'HERBERT:parse_flags:invalid_argument');
        end
        
        %--------------------------------------------------------------------------
    end
end
