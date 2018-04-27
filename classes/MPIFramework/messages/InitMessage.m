classdef InitMessage < aMessage
    % Helper class desfines a message, used to transfer information to a
    % remote job
    %
    properties(Dependent)
        %
        n_steps
        common_data
        cycle_data
        % if job needs to return results
        return_results
    end
    properties(Access = protected)
        return_results_ = false;
    end
    
    methods
        function obj = InitMessage(common_data,loop_data,varargin)
            obj = obj@aMessage('init');
            obj.payload = struct('common_data',common_data,...
                'loopData',[]);
            obj.payload.loop_data = loop_data;
            if nargin > 2
                obj.payload.n_steps = varargin{1};
            end
            if nargin > 3
                obj.return_results_  = logical(varargin{2});
            end
            
        end
        
        function n_steps = get.n_steps(obj)
            if isfield(obj.payload,'n_steps')
                n_steps =obj.payload.n_steps;
            else
                n_steps =numel(obj.payload.cycle_data);
            end
        end
        function cd = get.common_data(obj)
            cd = obj.payload.common_data;
        end
        function cd = get.cycle_data(obj)
            cd = obj.payload.cycle_data;
        end
        
    end
end

