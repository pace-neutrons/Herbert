function w = sigvar_set(w,sigvarobj)
% Set output object signal and variance fields from input sigvar object
%
%   >> w = sigvar_set(w,sigvarobj)

% Original author: T.G.Perring

if ~isequal(size(w.signal),size(sigvarobj.s))
    error('IX_dataset_2d and sigvar object have inconsistent sizes')
end
w.signal=sigvarobj.s;
w.error=sqrt(sigvarobj.e);
