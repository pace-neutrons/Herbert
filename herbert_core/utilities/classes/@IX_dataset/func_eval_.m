function obj_out = func_eval_ (obj, func_handle, pars, opt)
% Evaluate a function over a IX_dataset object or array of objects.
%
%   >> obj_out = func_eval_ (obj, func_handle, pars)
%   >> obj_out = func_eval_ (obj, func_handle, pars, 'all')
%
% Input:
% ------
%   obj         IX_dataset object or array of objects
%
%   func_handle Handle to the function to be evaluated
%               e.g. @gauss_nd
%
%               The function to be evaluated must have the form
%                   val = my_func (x1, x2, x3..., arg1, arg2, arg3,...)
%
%               where
%               - x1, x2, x3... are arrays of coordinates of a set of points
%               - arg1, arg2, args,... are arguments needed by the function
%
%               Typically, the first argument will be a vector of numeric
%               parameters p = [p1, p2, p3,...], and further arguments (if
%               there are any) might be numeric or other constants used in
%               the function evaluation, keyword arguments, or the name of
%               a file containing lookup tables. If the function has one of
%               these forms it can also be used in multifit to fit the
%               numeric parameters.
%                   val = my_func (x1, x2, x3..., p)
%                   val = my_func (x1, x2, x3..., p, c1, c2, c3...)
%               e.g.
%                   val = my_func (x1, x2, x3..., [ht, decay, power])
%                   val = my_func (x1, x2, x3..., [ht, decay, power], sym_op, 'real')
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
%   obj_out     Output IX_dataset object or array of objects
%
%
% EXAMPLE
%   >> wout = func_eval (w, @gauss_nd, [p1, p2, p3,...])

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('IX_dataset')),'_docify')
%
%   doc_file = fullfile(doc_dir,'doc_func_eval_method.m')
%
%   object = 'IX_dataset'
%   method = 'func_eval_'
%   func = 'gauss_nd'
%   xyz = 'x1, x2, x3...'
%   xyz_description = 'are arrays of coordinates of a set of points'
%   pars = '[p1, p2, p3,...]'
% -----------------------------------------------------------------------------
% <#doc_beg:> IX_dataset
%   <#file:> <doc_file>
% <#doc_end:>
% -----------------------------------------------------------------------------


% Check optional argument
if nargin<4                         % no option given
    all_bins = false;
elseif is_stringmatchi(opt,'all')   % option 'all' given *** make more general
    all_bins = true;
else
    error ('HERBERT:func_eval_:invalid_input', 'Unrecognised keyword option')
end

% Perform function evaluation
if ~iscell(pars)
    pars_cell = {pars}; % package parameters as a cell for convenience
else
    pars_cell = pars;
end

obj_out = arrayfun (@(x)(func_eval_single_(x, func_handle, pars_cell, all_bins)), obj);


%--------------------------------------------------------------------------
function obj_out = func_eval_single_ (obj, func_handle, pars_cell, all_bins)
% Perform function evluation for a single object


% Get bin centres on all axes
ishist = ishistogram (obj);
x = obj.xyz_;
for i=find(ishist)
    x{i} = bin_centres(x{i});
end

% Get mesh of x values and turn into column vectors
nd = numel(x);
xgrid = cell(1,numel(x));
[xgrid{:}] = ndgrid (x{:});
for i=1:nd
    xgrid{i} = xgrid{i}(:);
end

% Evaluate function
obj_out = obj;
sz = size(obj.signal);

if all_bins
    signal_new = func_handle (xgrid{:}, pars_cell{:});
    obj_out.signal = reshape(signal_new, sz);
    obj_out.error = zeros(sz);
else
    ok = ~isnan(obj.signal);
    if all(ok)
        signal_new = func_handle (xgrid{:}, pars_cell{:});
        obj_out.signal = reshape(signal_new, sz);
        obj_out.error = zeros(sz);
    else
        for i=1:nd
            xgrid{i} = xgrid{i}(ok);
        end
        obj_out.signal(ok) = func_handle (xgrid{:}, pars_cell{:});
        obj_out.error = zeros(sz);
        obj_out.error(~ok) = NaN;
    end
end
