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

nw = numel(w);

[p,bp]=ptrans_par(pf,p_info);    % Get latest numerical parameters
caller.reset_state=~store_calc;
caller.ind=[];

if all(xye)
    if ~f_pass_caller_info
        [fcalc, fvar, fcalc_filled, fcalculated, S.fcalc_store, S.fvar_store] = ...
            calc_xye(w, p, plist, func, S.pstore, S.fcalc_store, S.fvar_store, store_calc, S.store_filled);

        [bcalc, bvar, bcalc_filled, bcalculated, S.bcalc_store, S.bvar_store] = ...
            calc_xye(w, bp, bplist, bfunc, S.bpstore, S.bcalc_store, S.bvar_store, store_calc, S.store_filled);

    else
        [fcalc, fvar, fcalc_filled, fcalculated, S.fcalc_store, S.fvar_store, S.fstate_store] = ...
            calc_xye_w_info(w, p, plist, caller, func, S.pstore, S.fcalc_store, S.fvar_store, store_calc, S.store_filled, S.fstate_store, Store.fore);

        [bcalc, bvar, bcalc_filled, bcalculated, S.bcalc_store, S.bvar_store, S.bstate_store] = ...
            calc_xye_w_info(w, bp, bplist, caller, bfunc, S.bpstore, S.bcalc_store, S.bvar_store, store_calc, S.store_filled, S.bstate_store, Store.back);

    end

elseif all(~xye)
    if ~f_pass_caller_info
        [fcalc, fvar, fcalc_filled, fcalculated, S.fcalc_store, S.fvar_store] = ...
            calc_sqw(w, p, plist, func, S.pstore, S.fcalc_store, S.fvar_store, store_calc, S.store_filled);

        [bcalc, bvar, bcalc_filled, bcalculated, S.bcalc_store, S.bvar_store] = ...
            calc_sqw(w, bp, bplist, bfunc, S.bpstore, S.bcalc_store, S.bvar_store, store_calc, S.store_filled);

    else
        [fcalc, fvar, fcalc_filled, fcalculated, S.fcalc_store, S.fvar_store, S.fstate_store] = ...
            calc_sqw_w_info(w, p, plist, caller, func, S.fcalc_store, S.fvar_store, store_calc, S.store_filled, S.fstate_store, Store.fore);

        [bcalc, bvar, bcalc_filled, bcalculated, S.bpstore, S.bcalc_store, S.bvar_store, S.bstate_store] = ...
            calc_sqw_w_info(w, bp, bplist, caller, bfunc, S.bpstore, S.bcalc_store, S.bvar_store, store_calc, S.store_filled, S.bstate_store, Store.back);

    end

else

    error('HERBERT:mfclass:badxye', 'temperror')
end

% $$$ celldisp(S.pstore)
% $$$ celldisp(p)
% $$$ celldisp(S.bpstore)
% $$$ celldisp(bp)

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

function [calc, var, calc_filled, calculated, pstore, calc_store, var_store] = ...
        calc_xye(w, p, plist, func, pstore, calc_store, var_store, store_calc, store_filled)

    nw=numel(w);
    calc_filled=false(nw,1);
    calculated=false(nw,1);
    calc = cell(nw, 1);
    var = cell(nw, 1);

    if numel(func) == 1
        jw = @()(1);
    else
        jw = @() evalin('caller', 'iw');
    end


    for iw=1:nw
        k = jw();
        if isempty(func{k})
            continue;
        end
        calc_filled(iw)=true;

        if store_filled && all(p{k}==pstore{k})
            calc{iw}=calc_store{iw};
            var{iw}=var_store{iw};
            continue;
        end
        pars=plist_update(plist(k),p{k});
        calc{iw}=func{k}(w{iw}.x{:},pars{:});
        var{iw}=zeros(size(calc{iw}));
        calc{iw}=calc{iw}(:); % make column vector
        var{iw}=var{iw}(:);
        calculated(iw)=true;

        if store_calc
            calc_store{iw}=calc{iw};
            var_store{iw}=var{iw};
        end

    end
end

function [calc, var, calc_filled, calculated, calc_store, var_store] = ...
        calc_sqw(w, p, plist, func, pstore, calc_store, var_store, store_calc, store_filled)

    nw=numel(w);
    calc_filled=false(nw, 1);
    calculated=false(nw, 1);
    calc = cell(nw, 1);
    var = cell(nw, 1);

    if numel(func) == 1
        jw = @()(1);
    else
        jw = @() evalin('caller', 'iw');
    end

    for iw=1:nw
        k = jw();
        if isempty(func{k})
            continue;
        end

        calc_filled(iw)=true;

        if store_filled && all(p{k}==pstore{k})
            calc{iw}=calc_store{iw};
            var{iw}=var_store{iw};
            continue;
        end

        pars=plist_update(plist(k),p{k});

        wcalc=func{k}(w{iw},pars{:});
        [calc{iw},var{iw},msk]=sigvar_get(wcalc);

        calc{iw}=calc{iw}(msk);       % remove the points that we are told to ignore
        var{iw}=var{iw}(msk);
        calc{iw}=calc{iw}(:); % make column vector
        var{iw}=var{iw}(:);

        if store_calc
            calc_store{iw}=calc{iw};
            var_store{iw}=var{iw};
        end

        calculated(iw)=true;
    end

end


function [calc, var, calc_filled, calculated, pstore, calc_store, var_store, state_store] = ...
        calc_xye_w_info(w, p, plist, caller, func, pstore, calc_store, var_store, store_calc, store_filled, state_store, foreback)

    nw=numel(w);
    calc_filled=false(nw,1);
    calculated=false(nw,1);
    calc = cell(nw, 1);
    var = cell(nw, 1);

    if numel(func) == 1
        jw = @()(1);
    else
        jw = @() evalin('caller', 'iw');
    end

    for iw=1:nw
        k = jw();
        caller.ind=iw;
        if isempty(func{k})
            continue;
        end
        calc_filled(iw)=true;
        if store_filled && all(p{k}==pstore{k})
            calc{iw}=calc_store{iw};
            var{iw}=var_store{iw};
            continue;
        end
        pars=plist_update(plist(k),p{k});
        [calc{iw},state,foreback]=func{k}(w{iw}.x{:},caller,...
                                                state_store(iw),foreback,pars{:});
        var{iw}=zeros(size(calc{iw}));
        calc{iw}=calc{iw}(:); % make column vector
        var{iw}=var{iw}(:);
        if store_calc
            calc_store{iw}=calc{iw};
            var_store{iw}=var{iw};
            state_store(iw)=state;
        end
        calculated(iw)=true;
    end
end

function [calc, var, calc_filled, calculated, calc_store, var_store, state_store] = ...
        calc_sqw_w_info(w, p, plist, caller, func, pstore, calc_store, var_store, store_calc, store_filled, state_store, foreback)

    nw=numel(w);
    calc_filled=false(nw, 1);
    calculated=false(nw, 1);
    calc = cell(nw, 1);
    var = cell(nw, 1);

    if numel(func) == 1
        jw = @()(1);
    else
        jw = @() evalin('caller', 'iw');
    end

    for iw=1:nw
        k = jw();
        caller.ind=iw;
        if isempty(func{k})
            continue;
        end
        calc_filled(iw)=true;
        if store_filled && all(p{k}==pstore{k})
            calc{iw}=calc_store{iw};
            var{iw}=var_store{iw};
            continue;
        end
        pars=plist_update(plist(k),p{k});
        [wcalc,state,foreback]=func{k}(w{iw},caller,state_store(iw),foreback,pars{:});
        [calc{iw},var{iw},msk]=sigvar_get(wcalc);
        calc{iw}=calc{iw}(msk);       % remove the points that we are told to ignore
        var{iw}=var{iw}(msk);
        calc{iw}=calc{iw}(:); % make column vector
        var{iw}=var{iw}(:);
        if store_calc
            calc_store{iw}=calc{iw};
            var_store{iw}=var{iw};
            state_store(iw)=state;
        end
        calculated(iw)=true;
    end
end