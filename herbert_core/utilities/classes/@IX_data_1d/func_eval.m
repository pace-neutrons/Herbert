function obj_out = func_eval (obj, func_handle, pars, varargin)
% Evaluate a function over a IX_dataset_1d object or array of objects.
%
%   >> obj_out = func_eval (obj, func_handle, pars)
%   >> obj_out = func_eval (obj, func_handle, pars, 'all')
%
% Input:
% ------
%   obj         IX_dataset_1d object or array of objects
%
%   func_handle Handle to the function to be evaluated
%               e.g. @gauss
%
%               The function to be evaluated must have the form
%                   val = my_func (x, arg1, arg2, arg3,...)
%
%               where
%               - x is an array of a set of points along the x-axis
%               - arg1, arg2, args,... are arguments needed by the function
%
%               Typically, the first argument will be a vector of numeric
%               parameters p = [p1, p2, p3,...], and further arguments (if
%               there are any) might be numeric or other constants used in
%               the function evaluation, keyword arguments, or the name of
%               a file containing lookup tables. If the function has one of
%               these forms it can also be used in multifit to fit the
%               numeric parameters.
%                   val = my_func (x, p)
%                   val = my_func (x, p, c1, c2, c3...)
%               e.g.
%                   val = my_func (x, [ht, decay, power])
%                   val = my_func (x, [ht, decay, power], sym_op, 'real')
%
%   pars        Argument(s) needed by the function.
%               - If the function just takes a single argument that is a
%                 numeric vector, then set pars to that vector
%                   e.g. pars = [ht, decay, power]
%
%               - If the function takes a more general set of parameters
%                 arg1, arg2,..., then package these into a cell array and
%                 pass that as pars
%                   e.g. pars = {[ht, decay, power], sym_op, 'real'}
%
%   'all'       [option] Requests that the calculated function be returned over
%              the whole of the domain of the input dataset. If not given, then
%              the function will be returned only at those points of the dataset
%              that contain data i,e, where signal ~= NaN
%
% Output:
% -------
%   obj_out     Output IX_dataset_1d object or array of objects
%
%
% EXAMPLE
%   >> wout = func_eval (w, @gauss, [height, centre, st_deviation])

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('IX_dataset')),'_docify')
%
%   doc_file = fullfile(doc_dir,'doc_func_eval_method.m')
%
%   object = 'IX_dataset_1d'
%   method = 'func_eval'
%   func = 'gauss'
%   xyz = 'x'
%   xyz_description = 'is an array of a set of points along the x-axis'
%   pars = '[height, centre, st_deviation]'
% -----------------------------------------------------------------------------
% <#doc_beg:> IX_dataset
%   <#file:> <doc_file>
% <#doc_end:>
% -----------------------------------------------------------------------------


obj_out = func_eval_ (obj, func_handle, pars, varargin{:});
