function obj = build_IXdataset_1d_(obj,varargin)
% Create IX_dataset_1d object
%
%   >> w = IX_dataset_1d (x)
%   >> w = IX_dataset_1d (x,signal)
%   >> w = IX_dataset_1d (x,signal,error)
%   >> w = IX_dataset_1d (x,signal,error,title,x_axis,s_axis)
%   >> w = IX_dataset_1d (x,signal,error,title,x_axis,s_axis, x_distribution)
%   >> w = IX_dataset_1d (title, signal, error, s_axis, x, x_axis, x_distribution)
%
%  Creates an IX_dataset_1d object with the following elements:
%
% 	title				char/cellstr	Title of dataset for plotting purposes (character array or cellstr)
% 	signal              double  		Signal (vector)
% 	error				        		Standard error (vector)
% 	s_axis				IX_axis			Signal axis object containing caption and units codes
%                   (or char/cellstr    Can also just give caption; multiline input in the form of a
%                                      cell array or a character array)
% 	x					double      	Values of bin boundaries (if histogram data)
% 						                Values of data point positions (if point data)
% 	x_axis				IX_axis			x-axis object containing caption and units codes
%                   (or char/cellstr    Can also just give caption; multiline input in the form of a
%                                      cell array or a character array)
% 	x_distribution      logical         Distribution data flag (true is a distribution; false otherwise)



% Various input options
if nargin==2
    if isa(varargin{1},'IX_dataset_1d')  % if already IX_dataset_1d object, return
        obj=varargin{1};
        return
    end
    in = varargin{1};
    if isstruct(in)   % structure input
        if numel(in) > 1
            obj = repmat(IX_dataset_1d(),numel(in),1);
            in1d = reshape(in,numel(in),1);
            for i = 1:numel(in)
                obj(i) = IX_dataset_1d(in1d(i));
            end
            obj = reshape(obj,size(in));
            return
        end
        fld_names = fieldnames(in);
        accepted_flds = obj.public_fields_list_;
        memb = ismember(fld_names,accepted_flds);
        if ~all(memb)
            err_fields = fld_names(~memb);
            err_fields = cellfun(@(fld)([fld,'; ']),err_fields,'UniformOutput',false);
            err_str = [err_fields{:}];
            error('IX_dataset_1d:invalid_argument',...
                'Input structure fields: %s can not be used to set IX_dataset_1d',err_str);
        end
        for i=1:numel(fld_names)
            fld = fld_names{i};
            obj.(fld) = in.(fld);
        end
%     elseif iscell(in) % does not work with cellarray
%         tob = cell(numel(in),1);
%         in1d = reshape(in,numel(in),1);
%         for i=1:numel(in)
%             tob{i} = IX_dataset_1d(in1d{i});
%         end
%         obj = reshape(tob,size(in));
%         return;
    elseif isnumeric(in)
        if size(in,1) == 3 && size(in,2) > 1
            obj = check_and_set_x_(obj,in(1,:));
            obj = check_and_set_sig_err_(obj,'signal',in(2,:));
            obj = check_and_set_sig_err_(obj,'error',in(3,:));
        else
            obj = check_and_set_x_(obj,in);
            obj.x = in;
            obj = check_and_set_sig_err_(obj,'signal',zeros(size(in)));
            obj = check_and_set_sig_err_(obj,'error',zeros(size(in)));
        end
    end
    
elseif nargin<=4
    obj = check_and_set_x_(obj,varargin{1});
    if nargin==3
        obj = check_and_set_sig_err_(obj,'signal',varargin{2});
        obj = check_and_set_sig_err_(obj,'error',zeros(size(obj.signal)));
    end
    if nargin==4
        obj = check_and_set_sig_err_(obj,'signal',varargin{2});
        obj = check_and_set_sig_err_(obj,'error',varargin{3});
    end
elseif nargin==7 || (nargin==8 && isnumeric(varargin{1}))
    obj = check_and_set_x_(obj,varargin{1});
    obj = check_and_set_sig_err_(obj,'signal',varargin{2});
    obj = check_and_set_sig_err_(obj,'error',varargin{3});
    
    obj.title=varargin{4};
    obj.s_axis=varargin{6};
    obj.x_axis=varargin{5};
    if nargin==8
        obj.x_distribution=varargin{7};
    else
        obj.x_distribution=true;
    end
elseif nargin==8
    obj.title=varargin{1};
    obj.s_axis=varargin{4};
    obj.x_axis=varargin{6};
    
    obj = check_and_set_x_(obj,varargin{5});
    obj = check_and_set_sig_err_(obj,'signal',varargin{2});
    obj = check_and_set_sig_err_(obj,'error',varargin{3});
    
    obj.x_distribution=varargin{7};
else
    error('IX_dataset_1d:invalid_argument','Wrong number of arguments');
end
%
[ok,mess]=check_common_fields_(obj);
if ok
    obj.valid_  = true;
else
    error('IX_dataset_1d:invalid_argument',mess);
end


