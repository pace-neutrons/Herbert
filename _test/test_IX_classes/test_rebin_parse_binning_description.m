classdef test_rebin_parse_binning_description < TestCaseWithSave
    % Test of functions which are used to test and generate bin boundary
    % descriptions
    properties
        bin_opts_default
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_rebin_parse_binning_description (name)
            self@TestCaseWithSave(name);
            
            self.bin_opts_default = struct(...
                'empty_is_one_bin', false,...
                'range_is_one_bin', false,...
                'array_is_descriptor', true,...
                'values_are_boundaries', true);
            
            self.save()
        end
        
        %==========================================================================
        % Test rebin_parse_binning_description
        % Output is: [xout, is_descriptor, is_boundaries, resolved]
        %--------------------------------------------------------------------------
        function test_1 (self)
            % Full range, keep old bins
            bin_opts = self.bin_opts_default;
            bin_opts.range_is_one_bin = false;
            output = cell(1,4);
            [output{:}] = IX_dataset.test_gateway('rebin_parse_binning_description',...
                [-Inf,Inf], bin_opts);
            
            assertEqual (output, {[-Inf, 0, Inf], true, true, false})
        end
        
        %--------------------------------------------------------------------------
        function test_2 (self)
            % Full range, single bin
            bin_opts = self.bin_opts_default;
            bin_opts.range_is_one_bin = true;
            output = cell(1,4);
            [output{:}] = IX_dataset.test_gateway('rebin_parse_binning_description',...
                [-Inf,Inf], bin_opts);
            
            assertEqual (output, {[-Inf, Inf], false, true, false})
        end
        
        %--------------------------------------------------------------------------
        function test_3 (self)
            % Equal limits, valid single bin even if ~range_is_one_bin
            bin_opts = self.bin_opts_default;
            bin_opts.range_is_one_bin = false;
            output = cell(1,4);

            % [-inf,-Inf] is valid (as is [Inf,Inf])
            [output{:}] = IX_dataset.test_gateway('rebin_parse_binning_description',...
                [-Inf,-Inf], bin_opts);
            assertEqual (output, {[-Inf, -Inf], false, true, false})

            % Finite zero width bin
            [output{:}] = IX_dataset.test_gateway('rebin_parse_binning_description',...
                [46,46], bin_opts);
            assertEqual (output, {[46,46], false, true, true})
        end
        
        %--------------------------------------------------------------------------
        function test_4 (self)
            % Descriptor
            bin_opts = self.bin_opts_default;
            output = cell(1,4);
            [output{:}] = IX_dataset.test_gateway('rebin_parse_binning_description',...
                [-Inf,4,10,1,12,2,Inf], bin_opts);
            assertEqual (output, {[-Inf,4,10,1,12,2,Inf], true, true, false})
        end
        
        %--------------------------------------------------------------------------
        function test_5 (self)
            % Descriptor with zero interval is invalid
            bin_opts = self.bin_opts_default;
            f = @()IX_dataset.test_gateway('rebin_parse_binning_description',...
                [-Inf,4,10,1,10,2,Inf], bin_opts); 
            assertExceptionThrown(f, 'HERBERT:rebin_parse_binning_description:invalid_argument');
        end
        
        %--------------------------------------------------------------------------
        function test_6 (self)
            % Descriptor with negative logarithmic interval boundary invalid
            bin_opts = self.bin_opts_default;
            f = @()IX_dataset.test_gateway('rebin_parse_binning_description',...
                [-Inf,0,-4,-0.1,10,2,Inf], bin_opts); 
            assertExceptionThrown(f, 'HERBERT:rebin_parse_binning_description:invalid_argument');
        end
        
        %--------------------------------------------------------------------------
        function test_7 (self)
            % Descriptor with -Inf logarithmic interval boundary *is* valid
            bin_opts = self.bin_opts_default;
            output = cell(1,4);
            [output{:}] = IX_dataset.test_gateway('rebin_parse_binning_description',...
                [-Inf,-0.1,10,2,Inf], bin_opts); 
            assertEqual (output, {[-Inf,-0.1,10,2,Inf], true, true, false})
        end
        
        %--------------------------------------------------------------------------
    end
end
