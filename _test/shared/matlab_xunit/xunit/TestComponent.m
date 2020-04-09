classdef TestComponent < handle
    %TestComponent Abstract base class for TestCase and TestSuite
    %
    %   TestComponent methods:
    %       run          - Run all test cases in test component
    %       print        - Display summary of test component to Command Window
    %       numTestCases - Number of test cases in test component
    %       setUp        - Initialize test fixture
    %       tearDown     - Clean up text fixture
    %
    %   TestComponent properties:
    %       Name - Name of test component
    %       Location - Directory where test component is defined
    %
    %   See TestCase, TestSuite
    
    %   Steven L. Eddins
    %   Copyright 2008-2009 The MathWorks, Inc.
    
    properties
        Name = '';
        Location = '';
        % If true, prings the names of rest cases beeing run in addition to
        % normal test output. Usftul for debugging test folders, failing on
        % time-out. Default  - false;
        print_running_tests = false;
    end
    
    properties (Access = 'protected')
        PrintIndentationSize = 4
    end
    
    methods (Abstract)
        print()
        %print Display summary of test component to Command Window
        %   obj.print() displays information about the test component to the
        %   Command Window.
        
        run()
        %run Execute test cases
        %   obj.run() executes all the test cases in the test component
        
        numTestCases()
        %numTestCases Number of test cases in test component
    end
    
    methods
        function setUp(self)
            %setUp Set up test fixture
            %   test_component.setUp() is called at the beginning of the run()
            %   method.  Test writers can override setUp if necessary to
            %   initialize a test fixture.
        end
        
        function tearDown(self)
            %tearDown Tear down test fixture
            %   test_component.tearDown() is at the end of the method.  Test
            %   writers can override tearDown if necessary to clean up a test
            %   fixture.
        end
        %
        function name = getShortName(self)
            % return short name of the test component, if the test
            % component name was build from method name and class name using
            % :: sign. Return just self.Name if it was not.
            cont = regexp(self.Name,'::','split');
            if numel(cont) > 1
                name = cont{1};
            else
                name = cont{end};
            end
        end
        
        
    end
end
