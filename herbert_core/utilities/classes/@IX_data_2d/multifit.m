function varargout = multifit (varargin)
% Simultaneously fit function(s) to one or more IX_dataset_2d objects
%
%   >> myobj = multifit (w1, w2, ...)      % w1, w2 objects or arrays of objects
%
% This creates a fitting object of class mfclass_IX_dataset_2d with the provided data,
% which can then be manipulated to add further data, set the fitting
% functions, initial parameter values etc. and fit or simulate the data.
% For details about how to do this  <a href="matlab:help('mfclass_IX_dataset_2d');">Click here</a>
%
% For example:
%
%   >> myobj = multifit (w1, w2, ...); % set the data
%       :
%   >> myobj = myobj.set_fun (@function_name, pars);  % set forgraound function(s)
%   >> myobj = myobj.set_bfun (@function_name, pars); % set background function(s)
%       :
%   >> myobj = myobj.set_free (pfree);      % set which parameters are floating
%   >> myobj = myobj.set_bfree (bpfree);    % set which parameters are floating
%   >> [wfit,fitpars] = myobj.fit;          % perform fit
%
% For the format of fit functions (foreground or background), see the example:
% <a href="matlab:edit('example_2d_function');">example_2d_function</a>

%-------------------------------------------------------------------------------
% <#doc_def:>
%   class_name = 'IX_dataset_2d'
%   method_name = 'multifit'
%   mfclass_name = 'mfclass_IX_dataset_2d'
%   function_tag = ''
%
%
%   multifit_doc = fullfile(fileparts(which('multifit')),'_docify')
%   IX_dataset_doc = fullfile(fileparts(which('mfclass_IX_dataset_1d')),'_docify')
%
%   doc_multifit_header = fullfile(multifit_doc,'doc_multifit_header.m')
%   doc_fit_functions = fullfile(IX_dataset_doc,'doc_multifit_fit_functions.m')
%
%-------------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:>  <doc_multifit_header>  <class_name>  <method_name>  <mfclass_name>  <function_tag>
%
%   <#file:>  <doc_fit_functions>  example_2d_function
% <#doc_end:>
%-------------------------------------------------------------------------------

mf_init = mfclass_wrapfun (@func_eval, [], @func_eval, []);
varargout{1} = mfclass_IX_dataset_2d (varargin{:}, 'IX_dataset_2d', mf_init);
