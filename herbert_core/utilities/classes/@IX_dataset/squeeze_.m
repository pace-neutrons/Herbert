function obj_out = squeeze_ (obj, iax)
% Remove dimensions of length one dimensions in an IX_dataset object
%
%   >> obj_out = squeeze_ (obj)         % check all axes
%   >> obj_out = squeeze_ (obj, iax)    % check selected axes
%
% Input:
% -------
%   obj     IX_dataset object or array of objects to squeeze
%           If the input is an array of objects, then it is possible that
%           different objects could have a different number of axes with
%           length one. In this case, only dimensions that have length one
%           in all objects are removed.
%
%   iax     [optional] axis index, or array of indicies, to check for
%           removal. Values must be in the range 1 to ndim
%           Default: 1:ndim  (i.e. check all axes)
%
% Output:
% -------
%   obj_out IX_dataset object or array of objects with dimensions of
%           length one removed, to produce an array of the same length with
%           reduced dimensionality.
%
%           If all axes are removed, then this is will be because all
%           dimensions have extent one and the signal is a scalar. The
%           output in this case is as follows:
%             - if obj is a single IX_dataset object, obj_out is a
%               structure
%                   obj_out.val     value
%                   obj_out.err     standard deviation
%
%             - if obj is an array of IX_dataset objects, then obj_out
%               is an IX_dataset_Xd object with dimensionality X
%               corresponding tosize(obj), where the signal and error
%               arrays give the scalar values of each of the input objects.

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('IX_dataset')),'_docify')
%
%   doc_file = fullfile(doc_dir,'doc_squeeze_method.m')
%
%   object = 'IX_dataset'
%   method = 'squeeze_'
%   ndim = 'ndim'
% -----------------------------------------------------------------------------
% <#doc_beg:> IX_dataset
%   <#file:> <doc_file>
% <#doc_end:>
% -----------------------------------------------------------------------------


nd = obj.ndim();    % works even if empty obj array, as static method

% Check the validity of the axis indices
if nargin==1
    iax = 1:nd;
else
    if isempty(iax) || ~isnumeric(iax) || any(rem(iax,1)~=0) ||...
            any(iax<1) || any(iax>nd) || numel(unique(iax))~=numel(iax)
        if nd==1
            mess = 'Axis indices can only take the value 1';
        else
            mess = ['Axis indices must be unique and in the range 1 to ',...
                num2str(nd)];
        end
        error('HERBERT:squeeze_:invalid_argument', mess)
    end
end

% Catch case of zero dimensional object array - do nothing
if numel(obj)==0
    obj_out = obj;
    return
end

% Get the sizes of all the objects
[~, sz] = dimensions (obj);
sz = reshape(sz, [nd, numel(obj)])';    % rows give sizes

% Determine which axes to squeeze
test = false(1, nd);
test(iax) = true;
keep = ~(all(sz==1, 1) & test);         % row vector

% Fill output object
if all(keep)
    % All axes are retained - nothing to do
    obj_out = obj;
    
elseif ~any(keep)
    % All dimensions have length one, so the signal is a scalar for each
    % object in obj
    
    if numel(obj)==1
        % Return as a structure fields val, err (for backwards compatibility)
        obj_out = struct('val', obj.signal, 'err', obj.error);
        
    else
        % Create IX_dataset_*d with the dimensionality of the object array
        % and signal, error arrays containing the scalar signal and error
        % for each object
        szout = size(obj);
        ndout = numel(szout);
        
        % Get values with which to populate properties
        x = arrayfun (@(n)(1:n), szout, 'UniformOutput', false);
        signal = zeros(szout);
        err = zeros(szout);
        for i=1:numel(obj)
            signal(i) = obj(i).signal;
            err(i) = obj(i).error;
        end
        title = obj(1).title_;  % take title of first object by default
        x_axis = arrayfun (@(n)(['Object array axis: ',int2str(n)]), ...
            (1:ndout), 'UniformOutput', false);
        s_axis = obj(1).s_axis_;% take signal axis of first object by default
        x_distribution = false(1:ndout);
        
        % Create the object
        obj_out = IX_dataset_nd (ndout);
        obj_out = init (obj_out, x, signal, err, title, x_axis, s_axis, ...
            x_distribution);
    end
    
else
    % Some but not all axes to be removed
    obj_out = repmat (IX_dataset_nd(nd), size(obj));
    sz = sz(:, keep);
    for i=1:numel(obj)
        obj_out(i) = init (obj_out(i), obj(i).xyz_(keep), ...
            reshape(obj(i).signal_, sz(i,:)), ...
            reshape(obj(i).error_, sz(i,:)), ...
            obj(i).title_, obj(i).xyz_axis_(keep), obj(i).s_axis_, ...
            obj(i).xyz_distribution_);
    end
end
