classdef IX_map
    % IX_map   Definition of map class
    
    properties (Access=private)
        % Row vector size [1,n], n>=0, of number of spectra in each workspace.
        % The case of no workspaces is permitted (i.e. numel(ns)==0).
        % Workspaces can contain zero spectra (i.e. ns(i)==0 for some i)
        ns_ = zeros(1,0)

        % Row vector of spectrum indices in workspaces, concatenated
        % according to increasing workspace number.
        % Spectrum numbers are sorted into numerically increasing
        % order for each workspace.
        % The order of workspaces is numerically increasing workspace number
        % and in the case of un-numbered workspaces, the order they appear 
        % in the constructor
        s_ = zeros(1,0)

        % Row vector of workspace numbers (think of them as the 'names' of
        % the workspaces).
        % Must be unique, and greater than or equal to one.
        % If [], this means leave undefined.
        wkno_ = []
    end
    
    properties (Dependent)
        nw      % Number of workspaces
        wkno    % Workspace numbers
        ns      % Row vector of number of spectra in each workspace
        s       % Row vector spectrum indices
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_map (varargin)
            % Constructor for IX_map object. There are numerous ways to specify the map
            %
            % Spectrum numbers:
            % -----------------
            % Single workspace with single spectrum
            %   >> w = IX_map(isp)                      % Single workspace with a single spectrum
            %   >> w = IX_map(isp, 'wkno', iw)          % With workspace number
            % 
            % One spectrum per workspace, starting at isp_lo ending at isp_hi
            %   >> w = IX_map(isp_lo, isp_hi)
            %   >> w = IX_map(isp_lo, isp_hi, 'wkno', iw)   % starting workspace (scalar) (increment +ve)
            %                                               % or array length equal to number spectra
            %
            % Group nstep spectra in a workspace starting at isp_lo, isp_lo+|nstep|, isp_lo+2*|nstep|...
            % The sign of nstep determines if the workspace number increases or decreases between groups
            %   >> w = IX_map(isp_lo, isp_hi, nstep)
            %   >> w = IX_map(isp_lo, isp_hi, nstep, 'wkno', iw)% starting workspace (scalar) (increment +ve)
            %                                                   % or array length equal to number spectra
            %
            % As above, but repeat nrepeat times with the starting spectrum offset by delta_isp
            %   >> w = IX_map(..., 'repeat',  nrepeat)          % delta_isp = |isp_hi-isp_lo| + 1
            %   >> w = IX_map(..., 'repeat', [nrepeat, delta_isp])
            %
            %   >> w = IX_map(..., 'wkno',  iw)                 % delta_iw to ensure continuous set of iw
            %   >> w = IX_map(..., 'wkno', [iw, delta_iw])
            %
            %
            % The arguments isp, isp_lo, isp_hi, nstep etc. can be vectors. The result is
            % equivalent to the concatenation of IX_map applied to the arguments element-
            % by-element e.g.
            %       IX_map (is_lo, is_hi, step)
            %
            % is equivalent to a combination of the output of
            %       IX_map(is_lo(1), is_hi(1), nstep(1))
            %       IX_map(is_lo(2), is_hi(2), nstep(2))
            %           :
            %
            %
            % Cell array specification:
            % -------------------------
            % Cell array where each element is an array of spectrum numbers
            %   >> w = IX_map(cell)             
            %
            %   >> w = IX_map(cell, 'wkno', iw)     % starting workspace (scalar) (increment +ve)
            %                                       % or array length equal to number spectra
            %
            %
            % Read from file:
            % ---------------
            %   >> w = IX_map(filename)                 % Read from ascii file
            %   >> w = IX_map(filename, 'wkno', TF)     % TF = True:  Read workspace numbers (default)
            %                                           % TF = False: Ignore worspace numbers
            %
            % In all cases, if the workspace numbers are not given (i.e. they are 'un-named')
            % they will be left undefined, and workspaces can be addressed by their index
            % in the range 1 to nw, where nw is the total number of workspaces.
            
            
        end
    end
    %------------------------------------------------------------------
    % I/O methods
    %------------------------------------------------------------------
    methods
        function save (obj, file)
            % Save a map object to an ASCII file
            %
            %   >> save (obj)              % prompts for file
            %   >> save (obj, file)
            %
            % Input:
            % ------
            %   w       Map object (single object only, not an array)
            %   file    [optional] File for output.
            %           If none given, then prompts for a file
            
            
            % Get file name - prompting if necessary
            % --------------------------------------
            if nargin==1
                file='*.map';
            end
            [file_full, ok, mess] = putfilecheck (file);
            if ~ok
                error ('IX_map:save:io_error', mess)
            end
            
            % Write data to file
            % ------------------
            disp(['Writing map data to ', file_full, '...'])
            put_mask (obj, file_full);
            
        end
    end
    
    methods (Static)
        function obj = read (file)
            % Read map data from an ASCII file
            %
            %   >> obj = IX_map.read           % prompts for file
            %   >> obj = IX_map.read (file)
            
            
            % Get file name - prompt if file does not exist
            % ---------------------------------------------
            % The chosen file resets default seach location and extension
            if nargin==0 || ~is_file(file)
                file = '*.map';     % default for file prompt
            end
            [file_full, ok, mess] = getfilecheck (file);
            if ~ok
                error ('IX_map:read:io_error', mess)
            end
            
            % Read data from file
            % ---------------------
            S = get_map(file_full);
            obj = IX_map (S);
            
        end
        
    end
    
end
