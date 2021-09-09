% Remove dimensions of length one dimensions in an <object> object
%
%   >> obj_out = <method> (obj)         % check all axes
%   >> obj_out = <method> (obj, iax)    % check selected axes
%
% Input:
% -------
%   obj     <object> object or array of objects to squeeze
%           If the input is an array of objects, then it is possible that 
%           different objects could have a different number of axes with
%           length one. In this case, only dimensions that have length one
%           in all objects are removed.
%
%   iax     [optional] axis index, or array of indicies, to check for
%           removal. Values must be in the range 1 to <ndim>
%           Default: 1:<ndim>  (i.e. check all axes)
%
% Output:
% -------
%   obj_out <object> object or array of objects with dimensions of
%           length one removed, to produce an array of the same length with 
%           reduced dimensionality.
%
%           If all axes are removed, then this is will be because all
%           dimensions have extent one and the signal is a scalar. The
%           output in this case is as follows: 
%             - if obj is a single <object> object, obj_out is a 
%               structure
%                   obj_out.val     value
%                   obj_out.err     standard deviation
%
%             - if obj is an array of <object> objects, then obj_out
%               is an IX_dataset_Xd object with dimensionality X
%               corresponding tosize(obj), where the signal and error
%               arrays give the scalar values of each of the input objects.
