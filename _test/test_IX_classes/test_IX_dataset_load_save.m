classdef test_IX_dataset_load_save <  TestCaseWithSave
    % Test making of labels
    
    properties
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_IX_dataset_load_save (name)
            self@TestCaseWithSave(name);

            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_1 (self)
            % Read pre-2017 .mat file format
            old = load('testdata_IX_datasets_xxxx-2017_format.mat');
            
            % Read 2017-2021 .mat file format
            new = load('testdata_IX_datasets_2017-2021_format.mat');
            
            % Convert to structures to test equality
            state = warning;
            c = onCleanup(@()warning(state));
            warning ('off','all')   % use of struct in next line triggers warnings
            old_struct = struct (old);
            new_struct = struct (new);
            warning (state)
            
            assertEqualToTol(orderfields(old_struct), orderfields(new_struct))
        end
        
        %--------------------------------------------------------------------------
        function test_2 (self)
            % Read 2017-2021 .mat file format
            old = load('testdata_IX_datasets_2017-2021_format.mat');
            
            % Read 2021-09-30 .mat file format
            new = load('testdata_IX_datasets_xxxx-2017_format.mat');
            
            % Convert to structures to test equality
            state = warning;
            c = onCleanup(@()warning(state));
            warning ('off','all')   % use of struct in next line triggers warnings
            old_struct = struct (old);
            new_struct = struct (new);
            warning (state)
            
            assertEqualToTol(orderfields(old_struct), orderfields(new_struct))
        end
        
        %--------------------------------------------------------------------------

    end
end
