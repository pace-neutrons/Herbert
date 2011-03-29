function [nd,sz] = dimensions(w)
% Find number of dimensions and extent along each dimension of
% the signal arrays. 
% - if w.s empty,         nd=[], sz=[] (nb: [] == zeros(0,0))
% - If w.s scalar,        nd=0,  sz=zeros(1,0)
% - if w.s column vector, nd=1,  sz=length(w.s)
% - if w.s row vector,    nd=2,  sz=size(w.s)
%
% - All other cases:      nd=length(size(w.s)),  sz=size(w.s)
%  (this is the case if row vector too)
%
% The convention is that size(sz)=1 x ndim
%
%   >> [nd,sz]=dimensions(w)

% Original author: T.G.Perring


if ~isempty(w.signal)
    if ~isscalar(w.signal)
        if size(w.signal,2)>1
            sz=size(w.signal);
            nd=length(sz);
        else
            sz=numel(w.signal);
            nd=1;
        end
    else
        nd=0;
        sz=zeros(1,0);
    end
else
    nd=[];
    sz=[];
end
