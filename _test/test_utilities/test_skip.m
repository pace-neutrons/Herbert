classdef test_skip < TestCase
    methods
        function this=test_skip(varargin)
            if nargin>0
                name = varargin{1};
            else
                name  = 'test_skip';
            end
            this = this@TestCase(name);

        end

        %------------------------------------------------------------------
        function test_skip_with_message(this)
            skipTest('This test is skipped because of custom reasons.');
        end

        function test_skip_without_message(this)
            skipTest();
        end
    end
end