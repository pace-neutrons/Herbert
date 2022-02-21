classdef IX_mask
    % IX_mask   Definition of mask class
    
    properties
        % Spectra to be masked. Row vector of integers greater than zero
        msk = ones(1,0)
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_mask (val)
            % Create IX_mask object.
            %
            %   >> obj = IX_mask (iarray)       % Array of spectra
            %   >> obj = IX_mask (filename)     % Read arrays from ascii file
            %
            % A mask object contains a list of spectra to be masked, where
            % all spectrum numbers are greater than or equal to one. The
            % array is sorted into numerically increasing order, with all
            % duplicates removed.
            %
            % Input:
            % ------
            %   iarray      Array of spectra to be masked
            %
            % *OR*
            %   filename    Name of ASCII file with list of spectra to mask
            %               The file can have comment lines indicated by %, !
            %              or blank lines
            %               Spectrum numbers are indicated by the contents
            %              of any valid matlab array constructor (i.er. with
            %              the leading '[' and closing ']' missing
            %
            %               EXAMPLE:
            %                   % A comment line
            %                   1:10, 15:20
            %
            %                   % Another comment line
            %                   11:3:35      % an in-line comment
            
            
            if isnumeric(val)
                % Numeric array
                msk = unique(val(:)');
                if ~(any(msk<1) || any(~isfinite(msk)))
                    obj.msk = msk;
                else
                    error ('HERBERT:IX_mask:invalid_argument',...
                        'Spectrum numbers must be finite and greater or equal to 1')
                end
                
            elseif is_string (val)
                % Assume a filename
                if ~isempty(val)
                    [wout,ok,mess] = get_mask(val);
                else
                    error('File name cannot be an empty string')
                end
                
            elseif ~isempty(val)
                % Unrecognised input
                error ('HERBERT:IX_mask:invalid_argument',...
                    'Input must be an array or file name')
            end
            
        end
    end
    
end
