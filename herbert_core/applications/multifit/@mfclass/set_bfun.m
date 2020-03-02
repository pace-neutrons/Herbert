function obj = set_bfun(obj,varargin)
% Set background function or functions
%
% Set all background functions
%   >> obj = obj.set_bfun (fun)
%   >> obj = obj.set_bfun (fun, pin)
%   >> obj = obj.set_bfun (fun, pin, free)
%   >> obj = obj.set_bfun (fun, pin, free, bind)
%   >> obj = obj.set_bfun (fun, pin, 'free', free, 'bind', bind)
%
% Set a particular background function or set of background functions:
%   >> obj = obj.set_bfun (ifun, fun,...)     % ifun is scalar or row vector
%
% Input:
% ------
%   fun     Function handle or cell array of function handles
%           e.g.  fun = @gauss                    % single function
%                 fun = {@gauss, @lorentzian}     % two functions
%
%           In general:
%           - If the fit function is global, then give only one function
%             handle: the same function applies to every dataset
%
%           - If the fit functions are local, then:
%               - if every dataset is to be fitted to the same function
%                give just one function handle (the parameters will be
%                independently fitted of course)
%
%               - if the functions are different for different datasets
%                give a cell array of function handles, one per dataset
%
%           Note: If a subset of functions is selected with the optional
%          parameter ifun, then the expansion of a single function
%          handle to an array applies only to that subset
%
% Optional arguments:
%   ifun    Scalar or row vector of integers giving the index or indicies
%          of the functions to be set. [Default: all functions]
%           EXAMPLE
%           If there are three datasets and the fit is local (i.e. each
%          datset has independent fit functions) then to set the function
%          to be Gaussians for the first and third datasets and a Lorentzian
%          for the second:
%              >> obj = obj.set_bfun ([1,3], @gauss)
%              >> obj = obj.set_bfun (2, @lorentzian)
%
%   pin     Initial parameter list or a cell array of initial parameter
%          lists. Depending on the function, the form of the parameter
%          list is either:
%               p
%          or:
%               {p,c1,c2,...}
%          where
%               p           A vector of numeric parameters that define
%                          the function (e.g. [A,x0,w] as area, position
%                          and width of a peak)
%               c1,c2,...   Any further constant arguments needed by the
%                          function e.g. the filenames of lookup tables)
%
%           In general:
%           - If the fit function is global, then give only one parameter
%             list: the one function applies to every dataset
%
%           - If the fit functions are local, then:
%               - if every dataset is to be fitted to the same function
%                and with the same initial parameter values, you can
%                give just one parameter list. The parameters will be
%                fitted independently (subject to any bindings that
%                can be set elsewhere)
%
%               - if the functions are different for different datasets
%                or the intiial parmaeter values are different, give a
%                cell array of function handles, one per dataset
%
%           This syntax allows an abbreviated argument list. For example,
%          if there are two datsets and the fit functions are local then:
%
%               >> obj = obj.set_bfun (@gauss, [100,10,0.5])
%
%               fits the datasets independently to Gaussians starting
%               with the same initial parameters
%
%               >> obj = obj.set_bfun (@gauss, {[100,10,0.5], [140,10,2]})
%
%               fits the datasets independently to Gaussians starting
%               with the different initial parameters
%
%           Note: If a subset of functions is selected with the optional
%          parameter ifun, then the expansion of a single parameter list
%          to an array applies only to that subset
%
%   free    Logical row vector or cell array of logical row vectors that
%          define which parameters are free to float in a fit.
%           Each element of a row vector consists of logical true or
%          false (or 1 or 0) indicating if the corresponding parameter
%          for a function is free to float during a fit or is fixed.
%
%           In general:
%           - If the fit function is global, then give only one row
%             vector: the one function applies to every dataset
%
%           - If the fit functions are local, then:
%               - if every dataset is to be fitted to the same function
%                you can give just one vector of fixed/float values if
%                you want the same parameters to be fixed or floating
%                for each dataset, even if the initial values are
%                different.
%
%               - if the functions are different for different datasets
%                or the float status of the parameters is different for
%                different datasets, give a cell array of function
%                handles, one per dataset
%
%   bind    Binding of one or more parameters to other parameters.
%           In general, bind has the form:
%               {b1, b2, ...}
%           where b1, b2 are binding descriptors.
%
%           Each binding descriptor is a cell array with the form:
%               { [ipar_bound, ifun_bound], [ipar_free, ifun_free] }
%         *OR*  { [ipar_bound, ifun_bound], [ipar_free, ifun_free], ratio }
%
%           where
%               [ipar_bound, ifun_bound]
%                   Parameter index and function index of the
%                   background parameter to be bound
%
%               [ipar_free, ifun_free]
%                   Parameter index and function index of the
%                   parameter to which the bound parameter is tied.
%                   The function index is positive for background
%                   functions, negative for foreground functions.
%
%               ratio
%                   Ratio of bound parameter value to floating
%                   parameter. If not given, or ratio=NaN, then the
%                   ratio is set from the initial parameter values
%
%           Binding descriptors that set multiple bindings
%           ----------------------------------------------
%           If ifun_bound and/or ifun_free are omitted a binding
%          descriptor has a more general interpretation that makes it
%          simple to specify bindings for many functions:
%
%           - ifun_bound missing:
%             -------------------
%             The descriptor applies for all background functions, or if
%            the optional first input argument ifun is given to those
%            background functions
%
%               { ipar_bound, [ipar_free, ifun_free] }
%         *OR*  { ipar_bound, [ipar_free, ifun_free], ratio }
%
%           EXAMPLE
%               {2, [2,1]}  % bind parameter 2 of every background function
%                           % to parameter 2 of the first function
%                           % (Effectively makes parameter 2 global)
%
%           - ifun_free missing:
%             ------------------
%             The descriptor assumes that the unbound parameter has the same
%            function index as the bound parameter
%
%               { [ipar_bound, ifun_bound], ipar_free }
%         *OR*  { [ipar_bound, ifun_bound], ipar_free, ratio }
%
%           EXAMPLE
%               {[2,3], 6}  % bind parameter 2 of background function 3
%                           % to parameter 6 of the same function
%
%           - Both ifun_bound and ifun_free missing:
%             --------------------------------------
%             Combines the above two cases: the descriptor applies for all
%            background functions (or those functions given by the
%            optional argument ifun described below), and that the unbound
%            parameter has the same  function index as the bound parameter
%            in each instance
%
%               { ipar_bound, ipar_free }
%         *OR*  { ipar_bound, ipar_free, ratio }
%
%           EXAMPLE
%               {2,5}       % bind parameter 2 to parameter 5 of the same
%                           % function, for every background function
%
%
% Form of background fit functions
% --------------------------------
% If fitting objects:
% -------------------
%   function wcalc = my_function (w,p)
%
% or, more generally:
%   function wcalc = my_function (w,p,c1,c2,...)
%
% where
%   w           Object on which to evaluate the function
%   p           A vector of numeric parameters that define the
%              function (e.g. [A,x0,w] as area, position and
%              width of a peak)
%   c1,c2,...   Any further arguments needed by the function (e.g.
%              they could be the filenames of lookup tables)
%
% If fitting x,y,e data:
% ----------------------
%   function ycalc = my_function (x,p)
%
% or, more generally:
%   function ycalc = my_function (x,p,c1,c2,...)
%
% where
%   x           Array of x values
%   p           A vector of numeric parameters that define the
%              function (e.g. [A,x0,w] as area, position and
%              width of a peak)
%   c1,c2,...   Any further arguments needed by the function (e.g.
%              they could be the filenames of lookup tables)
%
%     See <a href="matlab:edit('example_1d_function');">example_1d_function</a>
%     See <a href="matlab:edit('example_2d_function');">example_2d_function</a>
%     See <a href="matlab:edit('example_3d_function');">example_3d_function</a>
%
%
% See also set_bfun

% -----------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_set_fun_intro = fullfile(mfclass_doc,'doc_set_fun_intro.m')
%   doc_set_fun_obj_function_form = fullfile(mfclass_doc,'doc_set_fun_obj_function_form.m')
%   doc_set_fun_xye_function_form = fullfile(mfclass_doc,'doc_set_fun_xye_function_form.m')
%
%   type = 'back'
%   pre = 'b'
%   atype = 'fore'
%   x_arg = 'x'
%   x_descr = 'x           Array of x values'
%
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:> <doc_set_fun_intro> <type> <pre> <atype>
% If fitting objects:
% -------------------
%   <#file:> <doc_set_fun_obj_function_form> <x_arg> <x_descr>
%
% If fitting x,y,e data:
% ----------------------
%   <#file:> <doc_set_fun_xye_function_form> <x_arg> <x_descr>
%
%     See <a href="matlab:edit('example_1d_function');">example_1d_function</a>
%     See <a href="matlab:edit('example_2d_function');">example_2d_function</a>
%     See <a href="matlab:edit('example_3d_function');">example_3d_function</a>
%
%
% See also set_bfun
% <#doc_end:>
% -----------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


% Process input
isfore = false;
[ok, mess, obj] = set_fun_private_ (obj, isfore, varargin);
if ~ok, error(mess), end

