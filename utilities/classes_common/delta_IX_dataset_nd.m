function del_out=delta_IX_dataset_nd(w1,w2,tol,verbose)
% Report the different between two IX_dataset_nd objects
%
%   >> delta_IX_dataset_nd(w1,w2)
%   >> delta_IX_dataset_nd(w1,w2,tol)           % -ve tol then |tol| is relative tolerance
%   >> delta_IX_dataset_nd(w1,w2,tol,verbose)   % verbose=true then print message even if equal
%
%   >> del = delta_IX_dataset_nd(...)
%
% Input:
% ------
%   w1, w2  IX_datset_nd objects to be compared (must both be scalar)
%   tol     Tolerance criterion for equality
%               if tol>=0, then absolute tolerance
%               if tol<0, then relative tolerance
%   verbose If verbose=true then print message even if equal
%
% Output:
% -------
%   del     Array containing maximum differences [x_1, x_2, ...,x_nd, signal, error]
%           Absolute or relative according to sign of tol

if ~exist('tol','var')||isempty(tol), tol=0; end
if ~exist('verbose','var')||isempty(tol), verbose=false; end

fname={'val';'err'};
if isstruct(w1) && isstruct(w2) && isequal(fname,fields(w1)) && isequal(fname,fields(w2))     % assume structure with fields val and err, as produced by integration
    del=zeros(1,2);
    delrel=zeros(1,2);
    [del(1),delrel(1)]=del_calc(w1.val,w2.val);
    [del(2),delrel(2)]=del_calc(w1.err,w2.err);
else
    h1=ishistogram(w1);
    h2=ishistogram(w2);
    nd1=numel(h1);
    nd2=numel(h2);
    if nd1~=nd2
        disp('Different dimensionality')
        del_out=[];
        return
    end
    if ~all(h1==h2)
        disp('One or more corresponding axes are not both histogram or point data')
        if nargout>0, del_out=[]; end
        return
    end
    
    del=zeros(1,nd1+2);
    delrel=zeros(1,nd1+2);
    for i=1:nd1
        x1=axis(w1,i);
        x2=axis(w2,i);
        if x1.distribution~=x2.distribution
            disp(['Axis ',num2str(i),': one object is a distribution, the other not'])
            if nargout>0, del_out=[]; end
            return
        end
        if numel(x1.values)==numel(x2.values)
            [del(i),delrel(i)]=del_calc(x1.values,x2.values);
        else
            disp(['Axis ',num2str(i),': different number of data points along this axis'])
            if nargout>0, del_out=[]; end
            return
        end
        if ~isequal(x1.axis,x2.axis)
            disp(['Axis ',num2str(i),': IX_axis descriptions differ'])
            if nargout>0, del_out=[]; end
            return
        end
    end
    [del(nd1+1),delrel(nd1+1)]=del_calc(w1.signal(:),w2.signal(:));
    [del(nd1+2),delrel(nd1+2)]=del_calc(w1.error(:),w2.error(:));
end

delmax=max(del);
delrelmax=max(delrel);
if tol<0
    if nargout>0, del_out=delrel; end
    if delrelmax<=abs(tol)
        if verbose, disp('Numerically equal objects'), end
    else
        disp(['WARNING: Numerically unequal objects:    ',num2str(delrel)])
    end
else
    if nargout>0, del_out=del; end
    if delmax<=tol
        if verbose, disp('Numerically equal objects'), end
    else
        disp(['WARNING: Numerically unequal objects:    ',num2str(del)])
    end
end



%============================================================================================
function [del,delrel]=del_calc(v1,v2)
% Get absolute and relative differences between two column vectors.
%
%   >> [del,delrel]=del_calc(v1,v2)
%
% Where the maximum absolute magnitude of a pair of elements is less than unity, it is treated as unity
% i.e. the relative difference becomes the absolute difference, or equivalently, the
% returned relative difference is alway less than or equal to the absolute difference.
% This is to avoid problems with large relative differences from rounding errors, which
% is against the spirit of the check that this function is designed for.
%
% Note that if divide by zero, then the NaNs are ignored in the max function, so no problem!
num=v1-v2;
den=max(max(abs(v1),abs(v2)),1);
del=max(abs(num));
delrel=max(abs(num)./den);
