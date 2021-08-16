function obj = check_properties_consistency_(obj)
% Check validity of interconnected fields of the object
%
%   >> [ok, message] = check_properties_consistency_(obj)
%
% Input:
% ------
%   obj     IX_dataset object
%
% Output:
% -------
%   obj     Updated object
%
%
% Notes about sizes of arrays
% ---------------------------
% Dimensions method must return object dimensionality, nd, and extent along
% each dimension in a row vector, sz, according to the convention that
% size(sz) = [1,nd]. This is not necessarily the same at the size of the
% signal and error arrays as returned by the Matlab intrinsic function size.
%
% Object  nd  size                             Matlab signal size
%   0D  nd=0  sz=zeros(1,0)                    [1,1]
%   1D  nd=1  sz=n1                            [n1,1]
%   2D  nd=2  sz=[n1,n2]                       [n1,n2]
%   3D  nd=3  sz=[n1,n2,n3]     even if n3=1   [n1,n2,n3] less trailing singletons
%   4D  nd=4  sz=[n1,n2,n3,n4]  even if n4=1,  [n1,n2,n3,n4] "    "        "
%                               or n3=n4=1


% Check that the signal and error arrays have the same size
if ~(numel(size(obj.signal_))==numel(size(obj.error_))) ||...
        ~all(size(obj.signal_)==size(obj.error_))
    error('HERBERT:check_properties_consistency_:invalid_argument',...
        'The sizes of signal array (=[%s]) and error array (=[%s]) do not match',...
        str_compress(num2str(size(obj.signal_)),','),...
        str_compress(num2str(size(obj.error_)),','))
end


nd = obj.ndim();
sz = size(obj.signal_);         % size of signal array

% Catch some special cases that arise from common errors
if nd==0 && ~isscalar(obj.signal_)
    error('HERBERT:check_properties_consistency_:invalid_argument',...
        'A zero dimensional object requires a scalar signal and error');
    
elseif nd==1 && numel(sz)==2 && sz(1)==1 && sz(2)~=1
    % A common error is to give signal as a row vector for a one-dimensional
    % dataset. Because this can have no ambiguous interpretation, this
    % can be accepted as valid input. Transpose the signal and error vectors
    obj.signal_ = obj.signal_';
    obj.error_ = obj.error_';
    sz = fliplr(sz);
end

% Check the signal array size consistent with the object dimensionality
nd_min = find(sz~=1, 1, 'last');    % trailing singletons not significant
if isempty(nd_min)
    nd_min = 0;     % case of signal being scalar
end
if nd_min<=nd
    sz = [sz(1:nd_min), ones(1,nd-nd_min)]; % add trailing singletons
else
    error('HERBERT:check_properties_consistency_:invalid_argument',...
        ['The size of the signal array (=[%s]) is inconsistent with\n',...
        'the object dimensionality (=%s)'],...
        str_compress(num2str(sz),','), num2str(nd))
end


% Check that the extent along each dimension of the signal is consistent
% with the axis values: the same (point data) or one less (histogram data)
sx = cellfun(@numel, obj.xyz_); % size of axis extents - row vector length nd
del = sx-sz;
hist = (del==1);
point = (del==0);
bad = ~(hist | point);
if any(bad)
    error('HERBERT:check_properties_consistency_:invalid_argument',...
        ['The extent of the signal array and the number of axis values along\n',...
        'axes number(s) %s is inconsistent with both histogram and point data\n',...
        'for those axes'], str_compress(num2str(find(bad)),','))
end

% Check that histogram axes are *strictly* monotonic increasing, point data
% is monotonically increasing, but if 1D point data, sort the x-axis values
% and sort the signal and error to match

if nd==1 && point
    if any(diff(obj.xyz_{1})<=0)
        % Sort 1D data
        [obj.xyz_{1},ix] = sort(obj.xyz_{1});
        obj.signal_ = obj.signal_(ix);
        obj.error_ = obj.error_(ix);
    end
else
    for iax=find(hist)
        if any(diff(obj.xyz_{iax})<=0)
            error('HERBERT:check_properties_consistency_:invalid_argument',...
                ['Axis ', num2str(iax), ': histogram bin boundaries must ',...
                'have non-zero width']);
        end
    end
    for iax=find(point)
        if any(diff(obj.xyz_{iax})<0)
            error('HERBERT:check_properties_consistency_:invalid_argument',...
                ['Axis ', num2str(iax), ': coordinates for point data must ',...
                'be monotonically increasing for two-or higher dimensional data']);
        end
    end
end
