function obj = build_IX_axis_(obj, varargin)
% Build IX axis object
%
%   >> obj = build_IX_axis_(obj, caption)
%   >> obj = build_IX_axis_(obj, caption, units)
%   >> obj = build_IX_axis_(obj, caption, units, code)  % tag with a units code
%
% Setting custom tick positions and labels
%   >> obj = build_IX_axis_(obj, ..., positions)        % positions
%   >> obj = build_IX_axis_(obj, ..., positions, labels)% positions and labels
%   >> obj = build_IX_axis_(obj, ..., ticks)            % structure with fields
%                                                       % 'position' and 'labels'

narg = nargin - 1;

if narg<=4 && isstruct(varargin{end})    
    % Final argument is structure: assume arguments form (..., ticks)
    nch = narg - 1;
    if nch>=1, obj.caption_ = varargin{1}; end
    if nch>=2, obj.units_ = varargin{2};  end
    if nch>=3, obj.code_ = varargin{3};  end
    obj.ticks_ = varargin{end};
    
elseif narg<=4 && isnumeric(varargin{end})   
    % Final argument is numeric array: assume arguments form (..., positions)
    nch=narg - 1;
    if nch>=1, obj.caption_ = varargin{1};  end
    if nch>=2, obj.units_ = varargin{2};   end
    if nch>=3, obj.code_ = varargin{3};   end
    obj.positions = varargin{end};
    
elseif narg>=2 && narg<=5 && isnumeric(varargin{end-1}) 
    % Penultimate argument is numeric array: assume arguments form
    % (..., positions, labels)
    nch = narg - 2;
    if nch>=1, obj.caption = varargin{1}; end
    if nch>=2, obj.units = varargin{2}; end
    if nch>=3, obj.code = varargin{3};  end
    obj.positions = varargin{end-1};
    obj.labels = varargin{end};
    
elseif narg<=3
    % Leading arguments from (obj, caption, units, code)
    nch = narg;
    if nch>=1, obj.caption = varargin{1};end
    if nch>=2, obj.units = varargin{2};  end
    if nch>=3, obj.code = varargin{3}; end    
    
else
    error('HERBERT:build_IX_axis_:invalid_argument',...
        'Wrong number and/or type of input arguments')
end
