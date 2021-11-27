classdef test_integrate < TestCaseWithSave
    % Test of functions which are used to test and generate bin boundary
    % descriptions
    properties
        bin_opts_default
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_integrate (name)
            self@TestCaseWithSave(name);
            
            self.bin_opts_default = struct(...
                'empty_is_one_bin', false,...
                'range_is_one_bin', false,...
                'array_is_descriptor', true,...
                'values_are_boundaries', true);
            
            self.save()
        end
        
        %==========================================================================
        function test_1 (self)
            % Rebin from -Inf to Inf: should leave the datset unchanged
            w = IX_dataset_1d (1:10, 101:110, 0.5*(1:10));
            
            wi_ref = struct('val', 949.5, 'err', 8.5);
            wi = integrate (w, -Inf, Inf);
            
            tol = [1e-14,1e-14];
            assertEqualToTol (wi_ref, wi, tol)
        end
        
        %--------------------------------------------------------------------------
    end
end
