function [ycalc,varcalc,S,Store]=multifit_lsqr_func_eval(w,xye,func,bfunc,plist,bplist,...
                                                      f_pass_caller_info,bf_pass_caller_info,pf,p_info,store_calc,Sin,Store_in,listing)
% Calculate the intensities and variances for the data in multifit.
%
%   >> [ycalc,varcalc,S]=multifit_lsqr_func_eval(w,xye,func,bfunc,plist,bplist,...
%                   f_pass_caller_info,bf_pass_caller_info,pf,p_info,store_calc,Sin,listing)
%
%   >> multifit_lsqr_func_eval     % cleanup stored arguments
%
% Input:
% ------
%   w           Cell array where each element w(i) is either
%                 - an x-y-e triple with w(i).x a cell array of arrays, one
%                  for each x-coordinate,
%                 - a scalar object
%               All bad points will have been masked from an x-y-e triple
%               Objects will have their bad points internally masked too.
%
%   xye         Logical array, size(w): indicating which data are x-y-e
%              triples (true) or objects (false)
%
%   func        Handles to foreground functions:
%                 - A cell array with a single function handle (which will
%                  be applied to all the data sets);
%                 - Cell array of function handles, one per data set.
%               Some, but not all, elements of the cell array can be empty.
%              Empty elements are interpreted as not having a function to
%              evaluate for the corresponding data set.
%
%   bfunc       Handles to background functions; same format as func, above
%
%   plist       Array of valid parameter lists, one list per foreground function.
%
%   bplist      Array of valid parameter lists, one list per background function.
%
%   f_pass_caller_info  Keep internal state of foreground function evaluation e.g. seed of random
%               number generator. Dictates the format of the fit fuction argument list.
%
%   bf_pass_caller_info Keep internal state of background function evaluation e.g. seed of random
%               number generator. Dictates the format of the fit fuction argument list.
%
%   pf          Free parameter values (that is, the independently
%              varying parameters)
%
%   p_info      Structure with information needed to transform from pf to the
%              parameter values needed for function evaluation
%
%   store_calc  Logical scalar: =true if calculated signal and variance on
%              on calculation are to be stored; =false otherwise
%
%   Sin         Structure containing stored values and internal states of functions.
%               Can be an empty argument, in which case the output stored values
%              structure will be initialised.
%
%   Store_in    Stored values of e.g. expensively evaluated lookup tables that
%              have been accumulated to during evaluation of the fit functions
%
%   listing     Control diagnostic output to the screen:
%                - if >=3 then list which datasets were computed for the
%                  foreground and background functions
%
% Output:
% -------
%   ycalc       Calculated signal on those data points to be retained in fitting
%               A column vector of all the points.
%
%   varcalc     Estimated variance on the calculated values
%               A column vector of all the points.
%
%   S           Structure containing stored values and internal states of functions.
%               If store_calc is true, this will have been updated from Sin by calls
%              to the fitting function.
%               In the case when store_calc is false, the structure will be
%              created with the correct fields, but they will be initalised
%              only as cell arrays with empty elemeents.
%
%   Store       Updated stored values of e.g. expensively evaluated lookup tables that
%              have been accumulated to during evaluation of the fit functions
%
%
% Notes on format of fit functions
% --------------------------------
% For details, see the help to multifit_lsqr
%
%   >> wout = my_func (win, @fun, plist, c1, c2, ...)
% OR
%   >> [wout, state_out, store_out] = my_func (win, caller, state_in, store_in,...
%                                           @fun, plist, c1, c2, ...)
%
% where:
%   caller      Stucture that contains information from the caller routine. Fields
%                   reset_state     Logical scalar
%                   ind             Indicies of data sets in the full set of data
%   state_in    Cell array containing previously saved internal states for each
%              element of win
%   store_in    Stored values of e.g. expensively evaluated lookup tables
%              passed from caller.
%   state_out   Cell array containing internal states to be saved for a future call.
%   store_out   Updated stored values.
%
% NOTES:
%  - The calculated intensities can be stored to minimise expensive calculation
%   of functions.
%  - If xye data, it is assumed that only those points which are being fitted have
%   been passed to this function. If data objects, then it is required that masked
%   points can be implicitly indicated in the object, so that the required method
%   sigvar_get for the object returns a mask array.


% Original author: T.G.Perring

% Initialise store if required
    S=Sin;
    if isempty(S)
        S.store_filled=false;
        S.pstore=cell(size(plist));
        S.bpstore=cell(size(bplist));
        S.fcalc_store=cell(size(w));
        S.fvar_store=cell(size(w));
        S.bcalc_store=cell(size(w));
        S.bvar_store=cell(size(w));
        S.fstate_store=cell(size(w));
        S.bfstate_store=cell(size(w));
    end
    Store=Store_in;
    if isempty(Store)
        Store.fore=[];
        Store.back=[];
    end

    fcalc=cell(size(w)); fvar=cell(size(w)); bcalc=cell(size(w)); bvar=cell(size(w));

    [p,bp]=ptrans_par(pf,p_info);    % Get latest numerical parameters
    caller.reset_state=~store_calc;
    caller.ind=[];

    nw=numel(w);

    % Get foreground function calculated values for non-empty functions, and store if required
    fcalc_filled=false(nw,1);
    fcalculated=false(nw,1);

    for iw=1:nw
        caller.ind=iw;
        if numel(func) == 1
            mw = 1;
        else
            mw = iw;
        end

        if S.store_filled && all(p{mw}==S.pstore{mw})
            fcalc{iw}=S.fcalc_store{iw};
            fvar{iw}=S.fvar_store{iw};
            fcalc_filled(iw) = true;
        else

            [fcalc{iw}, fvar{iw}, fcalc_filled(iw), fcalculated(iw), fstate, Store.fore] = ...
                calculate(func{mw}, xye(iw), w{iw}, plist(mw), p{mw}, S.fstate_store(iw), Store.fore, f_pass_caller_info, caller);
        end
        if store_calc
            S.fcalc_store{iw}=fcalc{iw};
            S.fvar_store{iw}=fvar{iw};
            if f_pass_caller_info
                S.fstate_store(iw)=fstate;
            end
        end
    end

    % Update background function calculated values for non-empty functions, and store if required
    bcalc_filled=false(nw,1);
    bcalculated=false(nw,1);

    for iw=1:nw
        caller.ind=iw;

        if numel(bfunc) == 1
            mw = 1;
        else
            mw = iw;
        end

        if S.store_filled && all(bp{mw}==S.bpstore{mw})
            bcalc{iw}=S.bcalc_store{iw};
            bvar{iw}=S.bvar_store{iw};
            bcalc_filled(iw) = true;
        else

            [bcalc{iw}, bvar{iw}, bcalc_filled(iw), bcalculated(iw), bfstate, Store.back] = ...
                calculate(bfunc{mw}, xye(iw), w{iw}, bplist(mw), bp{mw}, S.bfstate_store(iw), Store.back, bf_pass_caller_info, caller);
        end
        if store_calc
            S.bcalc_store{iw}=bcalc{iw};
            S.bvar_store{iw}=bvar{iw};
            if bf_pass_caller_info
                S.bfstate_store(iw)=bfstate;
            end
        end
    end

% Update parameters in store
    if store_calc
        S.store_filled=true;
        S.pstore=p;
        S.bpstore=bp;
    end

% Create zeros for calculated function values for empty functions
% (There will be either a calculated foreground or calculated background for every dataset
%  We can only do this now because we have no way of knowing the size of the zero arrays for objects)

    if nw==1
        if fcalc_filled && bcalc_filled
            ycalc = fcalc{1}+bcalc{1};
            varcalc = fvar{1}+bvar{1};
        elseif ~fcalc_filled && bcalc_filled
            ycalc = bcalc{1};
            varcalc = bvar{1};
        elseif fcalc_filled && ~bcalc_filled
            ycalc = fcalc{1};
            varcalc = fvar{1};
        else
            error('Logic error in multifit. See T.G.Perring')
        end
    else
        for iw=1:nw
            if ~fcalc_filled(iw) && bcalc_filled(iw)
                fcalc{iw}=zeros(size(bcalc{iw}));
                fvar{iw}=zeros(size(bvar{iw}));
            elseif fcalc_filled(iw) && ~bcalc_filled(iw)
                bcalc{iw}=zeros(size(fcalc{iw}));
                bvar{iw}=zeros(size(fvar{iw}));
            elseif ~fcalc_filled(iw) && ~bcalc_filled(iw)
                error('Logic error in multifit. See T.G.Perring')
            end
        end
% Package data for return
        ycalc = cat(1,fcalc{:}) + cat(1,bcalc{:});    % one long column vector
        varcalc = cat(1,fvar{:}) + cat(1,bvar{:});    % one long column vector
    end

% Write diagnostics to screen, if requested
    if listing>2
        list_calculated_funcs(fcalculated,bcalculated)
    end
end

%------------------------------------------------------------------------------
function plist_cell = plist_update (plist, pnew)
% Take mfclass_plist object and replacement numerical parameter list with same number
% of elements, return cell array of parameters to pass to evaluation function.
    tmp=plist;
    tmp.p=reshape(pnew,size(plist.p));  % ensure same orientation
    if iscell(tmp.plist)
        plist_cell=tmp.plist;           % case of {@func,plist,c1,c2,...}, {p,c1,c2,...}, {c1,c2,...} or {}
    else
        plist_cell={tmp.plist};         % catch case of p or c1<0> (see mfclass_plist)
    end
end
%------------------------------------------------------------------------------
function list_calculated_funcs(f,b)
% List the indicies of datasets that were computed
    str=iarray_to_str(find(f),80);
    if numel(str)>0
        str{1}=['    Calculated foreground datasets:  ',str{1}];
        for i=1:numel(str)
            disp(str{i})
        end
    else
        disp('    Calculated foreground datasets:  n/a')
    end
    str=iarray_to_str(find(b),80);
    if numel(str)>0
        str{1}=['    Calculated background datasets:  ',str{1}];
        for i=1:numel(str)
            disp(str{i})
        end
    else
        disp('    Calculated background datasets:  n/a')
    end
    disp(' ')
end

function [calc, var, calc_filled, calculated, state, Store] = ...
        calculate(func, xye, w, plist, pIn, state, Store, pass_caller_info, caller)

    if isempty(func)
        calc_filled = false;
        calc = 0.0;
        var = 0.0;
        calculated = false;
        return
    end

    calc_filled = true;
    pars = plist_update(plist,pIn);

    if xye
        input = w.x{:};
    else
        input = w;
    end

    if ~pass_caller_info
        calc=func(input,pars{:});
    else
        [calc,state,Store] = func(input,caller,state,Store,pars{:});
    end

    if xye
        var=zeros(size(calc));
    else
        [calc,var,msk] = sigvar_get(calc);
        calc=calc(msk);       % remove the points that we are told to ignore
        var=var(msk);
    end

    calc=calc(:); % make column vector
    var=var(:);
    calculated = true;

end
