classdef InitMessage < aMessage
    % Helper class desfines a message, used to transfer initial
    % information to a single task of a distributed job.
    %
    % is_blocking = true for this message
    properties(Dependent)
        %
        n_first_step
        n_steps

        common_data
        loop_data
        % if the task needs to return results
        return_results
    end

    properties(Access = protected)
    end

    methods
        function obj = InitMessage(varargin)
            % Construct the intialization message
            %
            % Inputs:
            % common_data -- the structure, contaning data common to any
            %                loop iteration
            % loop_data   -- either cellarray of data, with each cell
            %                specific to a single loop iteration or
            %                number of iterations (n_steps) to perform over
            %                common data
            % return_results --if task needs to return its results
            %              if true, task will return its results
            %              if false or empty, no results expected to be
            %              returned
            % n_first_step -- the number of the first step in the loop to
            %                 do n_steps, if absent or loop data provided as
            %                 a cellarray it assumed to be 1
            %
            obj = obj@aMessage('init');
            p = inputParser();
            p.StructExpand = false
            addOptional(p, 'common_data', [])
            addOptional(p, 'loop_data', 1)
            addOptional(p, 'return_results', false)
            addOptional(p, 'n_first_step', 1, @(x)(validateattributes(x, {'numeric'}, {'scalar', 'nonempty'})))
            parse(p, varargin{:});
            loop_data = p.Results.loop_data;
            obj.payload = struct('common_data', p.Results.common_data, ...
                'loopData', p.Results.loop_data, 'n_first_step', p.Results.n_first_step, 'n_steps', 0, ...
                'return_results', p.Results.return_results);

            if ~isscalar(loop_data)
                obj.payload.loopData = loop_data;
                obj.payload.n_steps   = numel(loop_data);
                obj.payload.n_first_step  = 1;
            elseif isstruct(loop_data)
                fn = fieldnames(loop_data);
                obj.payload.loopData = loop_data;
                % would not work correctly if the first field was string
                obj.payload.n_steps   = numel(loop_data.(fn{1}));
                obj.payload.n_first_step  = 1;
            else
                % Already set up
            end
        end

        function n_steps = get.n_steps(obj)
            n_steps =obj.payload.n_steps;
        end

        function cd = get.common_data(obj)
            cd = obj.payload.common_data;
        end

        function cd = get.loop_data(obj)
            cd = obj.payload.loopData;
        end

        function yesno = get.return_results(obj)
            yesno  = obj.payload.return_results;
        end

        function nfs = get.n_first_step(obj)
            nfs = obj.payload.n_first_step;
        end

    end

    methods(Static, Access=protected)
        function isblocking = get_blocking_state()
            % return the blocking state of a message
            isblocking = true;
        end
    end

end
