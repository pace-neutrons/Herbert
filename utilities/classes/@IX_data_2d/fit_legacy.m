function [wout, fitdata, ok, mess] = fit_legacy(win, varargin)
% Fits a function to an IX_dataset_2d object, with an optional background function.
%
% A background function can be added to the fit function.
% If passed an array of datasets, then each dataset is fitted independently.
%
%
% Fit several datasets in succession to a given function:
% -------------------------------------------------------
%   >> [wout, fitdata] = fit_legacy (w, func, pin)
%   >> [wout, fitdata] = fit_legacy (w, func, pin, pfree)
%   >> [wout, fitdata] = fit_legacy (w, func, pin, pfree, pbind)
%
% These cover the respective cases of:
%   - All parameters free
%   - Selected parameters free to fit
%   - Binding of various parameters in fixed ratios
%
%
% With optional background function added to the function:
% --------------------------------------------------------
%   >> [wout, fitdata] = fit_legacy (..., bkdfunc, bpin)
%   >> [wout, fitdata] = fit_legacy (..., bkdfunc, bpin, bpfree)
%   >> [wout, fitdata] = fit_legacy (..., bkdfunc, bpin, bpfree, bpbind)
%
%
% Additional keywords controlling the fit:
% ----------------------------------------
% You can alter the range of data to fit, alter convergence criteria,
% verbosity of output etc. with keywords, some of which need to be paired
% with input values, some of which are just logical flags:
%
%   >> [wout, fitdata] = fit_legacy (..., keyword, value, ...)
%
% Keywords that are logical flags (indicated by *) take the value true
% if the keyword is present, or their default if not.
%
%     Select points to fit:
%       'keep'          Range of x values to keep.
%       'remove'        Range of x values to remove.
%       'mask'          Logical mask array (true for those points to keep).
%   *   'select'        If present, calculate output function only at the
%                      points retained for fitting.
%
%     Control fit and output:
%       'fit'           Alter convergence criteria for the fit etc.
%       'list'          Level of verbosity of output during fitting (0,1,2...).
%
%     Evaluate at initial parameters only (i.e. no fitting):
%   *   'evaluate'      Evaluate function at initial parameter values only
%                      without doing a fit. Performs an argument check as well.
%                     [Default: false]
%   *   'foreground'    Evaluate foreground function only (if 'evaluate' is
%                      not set then ignored).
%   *   'background'    Evaluate background function only (if 'evaluate' is
%                      not set then ignored).
%   *   'chisqr'        Evaluate chi-squared at the initial parameter values
%                      (ignored if 'evaluate' not set).
%
%   EXAMPLES:
%   >> [wout, fitdata] = fit_legacy(...,'keep',[0.4,1.8],'list',2)
%
%   >> [wout, fitdata] = fit_legacy(...,'select')
%
% If unable to fit, then the program will halt and display an error message.
% To return if unable to fit without throwing an error, call with additional
% arguments that return status and error message:
%
%   >> [wout, fitdata, ok, mess] = fit_legacy (...)
%
%
%------------------------------------------------------------------------------
% Description in full
%------------------------------------------------------------------------------
% Input:
% ======
%   w       IX_dataset_2d object or array of IX_dataset_2d objects to be fitted
%
%   func    A handle to the function to be fitted to each of the datasets.
%               ycalc = my_function (x1,x2,p)
%
%             or, more generally:
%               ycalc = my_function (x1,x2,p,c1,c2,...)
%
%             where
%               - x1,x2     Arrays of x values along first and second
%                          dimensions
%               - p         A vector of numeric parameters that define the
%                          function (e.g. [A,x0,w] as area, position and
%                          width of a peak)
%               - c1,c2,... Any further arguments needed by the function (e.g.
%                          they could be the filenames of lookup tables)
%
%             Type >> help gauss2d   for an example
%
%   pin     Initial function parameter values
%            - If the function takes just a numeric array of parameters, p,
%              then pin contains the initial values, that is, pin is the
%              array [pin(1), pin(2)...]
%
%            - If further parameters are needed by the function, then wrap
%              them as a cell array, that is, pin is the cell array
%               {[pin(1), pin(2)...], c1, c2, ...}
%
%   pfree   [Optional] Indicates which are the free parameters in the fit.
%           e.g. pfree=[1,0,1,0,0] indicates first and third parameters
%           are free, and the 2nd, 4th and 5th are fixed.
%           Default: if pfree is omitted or pfree=[] all parameters are free.
%
%   pbind   [Optional] Cell array that indicates which parameters are bound
%           to other parameters in a fixed ratio determined by the initial
%           parameter values contained in pin.
%           Default: if pbind is omitted or pbind=[] all parameters are unbound.
%             pbind={1,3}               Parameter 1 is bound to parameter 3.
%
%           Multiple bindings are made from a cell array of cell arrays
%             pbind={{1,3},{4,3},{5,6}} Parameter 1 bound to 3, 4 bound to 3,
%                                      and 5 bound to 6.
%
%           To explicity give the ratio, ignoring that determined from pin:
%             pbind=(1,3,[],7.4)        Parameter 1 is bound to parameter 3
%                                      with ratio 7.4 (the [] is required to
%                                      indicate binding is to a parameter in
%                                      the same function i.e. the foreground
%                                      function rather than the optional
%                                      background function.
%             pbind={1,3,0,7.4}         Same meaning: 0 (or -1) for foreground
%                                      function
%
%           To bind to background function parameters (see below)
%             pbind={1,3,1}             Parameter 1 bound to parameter 3 of
%                                      the background function, in the ratio
%                                      given by the initial values.
%             pbind={1,3,1,3.14}        Give explicit binding ratio.
%
%           EXAMPLE:
%             pbind={{1,3,[],7.4},{4,3,0,0.023},{5,2,1},{6,3,1,3.14}}
%                                       Parameters 1 and 4 bound to parameter
%                                      3, and parameters5 and 6 bound to
%                                      parameters 2 and 3 of the background.
%
%           Note that you cannot bind a parameter to a parameter that is
%           itself bound to another parameter. You can bind to a fixed or free
%           parameter.
%
%
%   Optional background function:
%   -----------------------------
%   bkdfunc A handle to the background function to be fitted to each of the
%           datasets.
%               ycalc = my_function (x1,x2,p)
%
%             or, more generally:
%               ycalc = my_function (x1,x2,p,c1,c2,...)
%
%             where
%               - x1,x2     Arrays of x values along first and second
%                          dimensions
%               - p         A vector of numeric parameters that define the
%                          function (e.g. [A,x0,w] as area, position and
%                          width of a peak)
%               - c1,c2,... Any further arguments needed by the function (e.g.
%                          they could be the filenames of lookup tables)
%
%             Type >> help gauss2d   for an example
%
%   bpin    Initial parameter values for the background function.  See the
%           description of the foreground function for details.
%
%   bpfree  Array indicating which parameters are free. See the
%           description of the foreground function for details.
%
%   bpbind  [Optional] Cell array that that indicates which parameters are bound
%           to other parameters in a fixed ratio determined by the initial
%           parameter values contained in pin and bpin.
%           The syntax is the same as for the foreground function:
%
%             bpbind={1,3}              Parameter 1 is bound to parameter 3.
%
%           Multiple bindings are made from a cell array of cell arrays
%             bpbind={{1,3},{4,3},{5,6}} Parameter 1 bound to 3, 4 bound to 3,
%                                      and 5 bound to 6.
%
%           To explicity give the ratio, ignoring that determined from bpin:
%             bpbind=(1,3,[],7.4)       Parameter 1 is bound to parameter 3,
%                                      ratio 7.4 (the [] is required to
%                                      indicate binding is to a parameter in
%                                      the same function i.e. the background
%                                      function rather than the foreground
%                                      function.
%             bpbind={1,3,1,7.4}         Same meaning: 1 for background function
%
%           To bind to foreground function parameters:
%             bpbind={1,3,0}            Parameter 1 bound to parameter 3 of
%                                      the foreground function.
%             bpbind={1,3,0,3.14}       Give explicit binding ratio.
%
%
% Optional keywords:
% ------------------
% Keywords that are logical flags (indicated by *) take the value true
% if the keyword is present, or their default if not.
%
% Select points to fit:
%   'keep'  Array giving ranges along each x-axis to retain for fitting.
%           - If one dimension:
%               [xlo, xhi]
%           - If two dimensions:
%               [x1_lo, x1_hi, x2_lo, x2_hi]
%           - General case of n-dimensions:
%               [x1_lo, x1_hi, x2_lo, x2_hi,..., xn_lo, xn_hi]
%
%           More than one range to keep can be specified in additional rows:
%               [Range_1; Range_2; Range_3;...; Range_m]
%           where each of the ranges are given in the format above.
%
%
%   'remove' Ranges to remove from fitting. Follows the same format as 'keep'.
%           If a point appears within both xkeep and xremove, then it will
%           be removed from the fit i.e. 'remove' takes precedence over 'keep'.
%
%   'mask'  Array of ones and zeros, with the same number of elements as the
%           input data arrays in the input object(s) in w. Indicates which
%           of the data points are to be retained for fitting (1=keep, 0=remove).
%
%
% * 'select' Calculates the returned function values only at the points
%           that were selected for fitting by 'keep', 'remove', 'mask' (and
%           which were not eliminated for having zero error bar). This is
%           useful for plotting the output, as only those points that
%           contributed to the fit will be plotted. [Default: false]
%
% Control fit and output:
%   'fit'   Array of fit control parameters
%           fcp(1)  Relative step length for calculation of partial derivatives
%                   [Default: 1e-4]
%           fcp(2)  Maximum number of iterations [Default: 20]
%           fcp(3)  Stopping criterion: relative change in chi-squared
%                   i.e. stops if (chisqr_new-chisqr_old) < fcp(3)*chisqr_old
%                   [Default: 1e-3]
%
%   'list'  Numeric code to control output to Matlab command window to monitor
%           status of fit:
%               =0 for no printing to command window
%               =1 prints iteration summary to command window
%               =2 additionally prints parameter values at each iteration
%
% Evaluate at initial parameters only (i.e. no fitting):
% * 'evaluate'    Evaluate the fitting function at the initial parameter values
%                without doing a fit. Useful for checking the goodness of
%                starting parameters. Performs an argument check as well.
%                By default, then sum of the foreground and background
%                functions is calculated. [Default: false]
% * 'foreground'  Evaluate foreground function only (if 'evaluate' is
%                not set then ignored).
% * 'background'  Evaluate background function only (if 'evaluate' is
%                not set then ignored).
% * 'chisqr'      Evaluate chi-squared at the initial parameter values
%               (ignored if 'evaluate' not set).
%
%
%   Example:
%   >> [wout, fitdata] = fit_legacy(...,'keep',[0.4,1.8],'list',2)
%
%
% Output:
% =======
%   wout    IX_dataset_2d object or array of IX_dataset_2d objects evaluated at the
%           final fit parameter values.
%
%           If there was a problem for ith data set i.e. ok(i)==false, then
%           wout(i)==w(i)
%
%           If there was a fundamental problem e.g. incorrect input argument
%          syntax, or none of the fits succeeded (i.e. all(ok(:))==false)
%          then wout=[].
%
% fitdata   Structure with result of the fit for each dataset. The fields are:
%          	p      - Parameter values [Row vector]
%           sig    - Estimated errors of global parameters (=0 for fixed
%                    parameters) [Row vector]
%           bp     - Background parameter values [Row vector]
%        	bsig   - Estimated errors of background (=0 for fixed parameters)
%                    [Row vector]
%       	corr   - Correlation matrix for free parameters
%          	chisq  - Reduced Chi^2 of fit (i.e. divided by
%                                (no. of data points) - (no. free parameters))
%       	converged - True if the fit converged, false otherwise
%           pnames - Parameter names: a cell array (row vector)
%        	bpnames- Background parameter names: a cell array (row vector)
%
%           Single data set input:
%           ----------------------
%           If there was a problem i.e. ok==false, then fitdata=[]
%
%           Array of data sets:
%           -------------------
%           fitdata is an array of structures with the size of the input
%          data array.
%
%           If there was a problem for ith data set i.e. ok(i)==false, then
%          fitdata(i) will contain dummy information.
%
%           If there was a fundamental problem e.g. incorrect input argument
%          syntax, or none of the fits succeeded (i.e. all(ok(:))==false)
%          then fitdata=[].
%
%   ok      True: A fit coould be performed. This includes the cases of
%             both convergence and failure to converge
%           False: Fundamental problem with the input arguments e.g.
%             the number of free parameters equals or exceeds the number
%             of data points
%
%           Array of data sets:
%           -------------------
%           If an array of input datasets was given, then ok is an array with
%          the size of the input data array.
%
%           If there was a fundamental problem e.g. incorrect input argument
%          syntax, or none of the fits succeeded (i.e. all(ok(:))==false)
%          then ok is scalar and ok==false.
%
%   mess    Error message if ok==false; Empty string if ok==true.
%
%           Array of data sets:
%           -------------------
%           If an array of datasets was given, then mess is a cell array of
%          strings with the same size as the input data array.
%
%           If there was a fundamental problem e.g. incorrect input argument
%          syntax, or none of the fits succeeded (i.e. all(ok(:))==false)
%          then mess is a single character string.
%
%
% EXAMPLES:
% =========
%
% Fit a 2D Gaussian, allowing only height and position to vary:
%   >> ht=100; x0=1; y0=3; var_x=2; var_y=1.5;
%   >> [wout, fdata] = fit_legacy(w, @gauss2d, [ht,x0,y0,var_x,0,var_y], [1,1,1,0,0,0])
%
% Allow all parameters to vary, but remove two rectangles from the data
%   >> ht=100; x0=1; y0=3; var_x=2; var_y=1.5;
%   >> [wout, fdata] = fit_legacy(w, @gauss2d, [ht,x0,y0,var_x,0,var_y], ...
%                               'remove',[0.2,0.5,2,0.7; 1,2,1.4,3])
%
% The same, with a planar background:
%   >> ht=100; x0=1; y0=3; var_x=2; var_y=1.5;
%   >> const=0; dfdx=0; dfdy=0;
%   >> [wout, fdata] = fit_legacy(w, @gauss2d, [ht,x0,y0,var_x,0,var_y], ...
%                             @planar_bg, [const,dfdx,dfdy],...
%                               'remove',[0.2,0.5,2,0.7; 1,2,1.4,3])

%-------------------------------------------------------------------------------
% <#doc_def:>
%   multifit_doc = fullfile(fileparts(which('multifit_gateway_main')),'_docify');
%   first_line = {'% Fits a function to an IX_dataset_2d object, with an optional background function.'}
%   main = false;
%   method = true;
%   synonymous = false;
%
%   multifit=false;
%   func_prefix='fit_legacy';
%   func_suffix='';
%   differs_from = strcmpi(func_prefix,'multifit') || strcmpi(func_prefix,'fit')
%   obj_name = 'IX_dataset_2d'
%
%   doc_forefunc = fullfile(multifit_doc,'doc_func_simple_2d.m')
%   doc_backfunc = fullfile(multifit_doc,'doc_func_simple_2d.m')
%
%   custom_keywords = false;
%
% <#doc_beg:> multifit_legacy
%   <#file:> fullfile('<multifit_doc>','doc_fit_short.m')
%
%
%   <#file:> fullfile('<multifit_doc>','doc_fit_long.m')
%
%
%   <#file:> fullfile('<multifit_doc>','doc_fit_examples_2d.m')
% <#doc_end:>
%-------------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)


% *** This function is identical for IX_dataset_1d, _2d, _3d, ...
% *** The help has specific references to the class name


% Note: we could rely on the generic fit function in Herbert, but this would
% re-check the parsing for every element of the array of objects to be fitted.
% Furthermore, we cannot customise the help documentation.


% Catch case of a single dataset input
% ------------------------------------
if numel(win)==1
    [wout,fitdata,ok,mess]=multifit(win,varargin{:});
    if ~ok && nargout<3, error(mess), end
    return
end

% Case of more than one dataset input
% -----------------------------------
% Parse the input arguments, and repackage for fit func
[ok,mess,pos,func,plist,pfree,pbind,bpos,bfunc,bplist,bpfree,bpbind,narg] = ...
    multifit_gateway_parsefunc (win(1), varargin{:});
if ~ok
    wout=[]; fitdata=[];
    if nargout<3, error(mess), else return, end
end
ndata=1;     % There is just one argument before the varargin
pos=pos-ndata;
bpos=bpos-ndata;

% Wrap the foreground and background functions
args=multifit_gateway_wrap_functions (varargin,pos,func,plist,bpos,bfunc,bplist,...
                                                    @func_eval,{},@func_eval,{});

% Evaluate function for each element of the array of objects
wout=win;
fitdata=repmat(struct,size(wout));  % array of empty structures
ok=false(size(wout));
mess=cell(size(wout));

ok_fit_performed=false;
for i = 1:numel(win)    % use numel so no assumptions made about shape of input array
    [ok(i),mess{i},wout_tmp,fitdata_tmp] = multifit_gateway_main (win(i), args{:});
    if ok(i)
        wout(i)=wout_tmp;
        if ~ok_fit_performed
            ok_fit_performed=true;
            fitdata=expand_as_empty_structure(fitdata_tmp,size(wout),i);
        else
            fitdata(i)=fitdata_tmp;
        end
    else
        if nargout<3, error([mess{i}, ' (dataset ',num2str(i),')']), end
        disp(['ERROR (dataset ',num2str(i),'): ',mess{i}])
    end
end
