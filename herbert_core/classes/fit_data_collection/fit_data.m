classdef fit_data

    properties
        data = [];
        map = {};
        indices = 0;
        num_pixels = 0;
        nobj = 0;
    end

    methods
        function obj = fit_data(varargin)
            obj = obj.add_data(varargin{:});
        end

        function obj = add_data(obj, varargin)

            n_new = numel(varargin);
            new_indices = cumsum(cellfun(@(x)(x.data.num_pixels), varargin));
            obj.map = [obj.map, varargin];
            obj.indices = [obj.indices, (new_indices + obj.indices(end))];
            obj.num_pixels = obj.num_pixels + new_indices(end);
            tmp = cellfun(@(x)(x.data.pix.data), varargin, 'Unif', false);
            obj.data = [obj.data, horzcat(tmp{:})];
            obj.data = reshape(obj.data, 9, obj.num_pixels);
            obj.nobj = obj.nobj + n_new;

        end

    end
end
