function sz = sigvar_size (obj)
% Size of the signal array in the sigvar object created from the input object
%
%   >> sz = sigvar_size(obj)
%
% Exists to return the size without the overheads of actually creating the
% sigvar object.


sz = size(obj.signal_);     % is just the matlab size of the IX_dataset signal
