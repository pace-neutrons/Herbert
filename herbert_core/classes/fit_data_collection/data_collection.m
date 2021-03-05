classdef data_collection

    properties (Access=public)
        sources_ = {};

        signal_ = [];
        variance_ = [];

        indices_ = [];

        npix_ = 0;

        ncoll_ = 0;

        map_ = {};

    end

    methods
        function obj = data_collection(varargin)
            if isempty(varargin)
                return
            end

            cls = class(varargin{1});
            cellfun(@(x)class(x), varargin, 'UniformOutput', false)
            if any(~strcmp(cellfun(@(x)class(x), varargin, 'UniformOutput', false), class(varargin{1})))
                error('HORACE:data_collection:mixed_args', 'Arguments to data collection are of inconsistent type')
            end

            switch cls
              case 'sqw'
                obj.ncoll_ = numel(varargin);
                obj.npix_ = cellfun(@(x)(x.data.num_pixels), varargin);
                obj.indices_ = [0, cumsum(obj.npix_)];
                obj.signal_ = zeros(1, sum(obj.npix_));
                obj.variance_ = zeros(1, sum(obj.npix_));
                obj.sources_ = varargin;
                for i = 1:obj.ncoll_
                    obj.signal_(obj.indices_(i)+1:obj.indices_(i+1)) = varargin{i}.data.pix.signal;
                    obj.variance_(obj.indices_(i)+1:obj.indices_(i+1)) = varargin{i}.data.pix.variance;
                end
              otherwise
                error('HORACE:data_collection:bad_arg', 'Object %s is not supported by data_collection', cls)
            end
        end

        function out = data(obj)
            out = struct('sig', obj.signal_, 'var', obj.variance_);
        end

       function scatter(obj)
           "hello"
       end
%
%        function gather(obj)
%
%        end
%
%        function map(obj)
%
%        end
    end


end