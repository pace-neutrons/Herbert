function [p_best,sig,cor,chisqr_red,converged]=multifit_lsqr_par(w,xye,func,bfunc,pin,bpin,...
                                                      f_pass_caller_info,bf_pass_caller_info,pfin,p_info,listing,fcp,perform_fit)
    % Perform least-squares minimisation
    %
    %   >> [p_best,sig,cor,chisqr_red,converged]=...
    %       multifit_lsqr(w,xye,func,bkdfunc,pin,bpin,pfin,p_info,listing)
    %
    %   >> [p_best,sig,cor,chisqr_red,converged]=...
    %       multifit_lsqr(w,xye,func,bkdfunc,pin,bpin,pfin,p_info,listing,fcp)
    %
    %   >> [p_best,sig,cor,chisqr_red,converged]=...
    %       multifit_lsqr(w,xye,func,bkdfunc,pin,bpin,pfin,p_info,listing,fcp,perform_fit)
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
    %   pin         Array of valid parameter lists, one list per foreground function,
    %              with the initial parameter values at the lowest level.
    %
    %   bin         Array of valid parameter lists, one list per background function,
    %              with the initial parameter values at the lowest level.
    %
    %   f_pass_caller_info  Determines the form of the foreground fit function argument lists:
    %               If false:
    %                   wout = my_func (win, @fun, plist, c1, c2, ...)
    %               If true:
    %                   [wout, state_out, store_out] = my_func (win, caller,...
    %                           state_in, store_in, @fun, plist, c1, c2, ...)
    %
    %               For details of these two forms, see 'Notes on format of fit functions'
    %               below.
    %
    %   bf_pass_caller_info Determines the form of the background fit function argument lists:
    %               See f_pass_caller_info, and 'Notes on format of fit functions' below.
    %
    %   pf          Free parameter initial values (that is, the independently
    %              varying parameters)
    %
    %   p_info      Structure with information needed to transform from pf to the
    %              parameter values needed for function evaluation
    %
    %   listing     Control diagnostic output to the screen:
    %               =0 for no printing to command window
    %               =1 prints iteration summary to command window
    %               =2 additionally prints parameter values at each iteration
    %               =3 additionally lists which datasets were computed for the
    %                  foreground and background functions. Diagnostic tool.
    %
    %   fcp         Fit control parameters:
    %           fcp(1)  Relative step length for calculation of partial derivatives
    %                   [Default: 1e-4]
    %           fcp(2)  Maximum number of iterations [Default: 20]
    %           fcp(3)  Stopping criterion: relative change in chi-squared
    %                   i.e. stops if (chisqr_new-chisqr_old) < fcp(3)*chisqr_old
    %                   [Default: 1e-3]
    %
    %   perform_fit Logical scalar = true if a fit is required, =false if
    %              just need the value of chisqr. [Default: True]
    %
    %
    % Output:
    % -------
    %   p_best      Column vector of final fit parameters - only for the
    %              independently varying parameters.
    %
    %   sig         Column vector of estimated standard deviations
    %
    %   cor         Correlation matrix for the free parameters
    %
    %   chisqr_red  Reduced chi-squared at final fit parameters
    %
    %   converged   True if fit converged; false if not.
    %
    % Note that for the final fit parameters to be reliable, test that
    % (ok && converged) is true.
    %
    %
    % ---------------------------------------------------------------------------------------
    % Notes on format of fit functions
    % ---------------------------------------------------------------------------------------
    %
    % Certain syntax and rules of behaviour are required of the fit functions.
    %
    % If caller information is not required by the function (i.e. f_pass_caller_info or
    % bf_pass_caller_info are false for the foreground and foreground functions, respectively):
    %
    %   >> wout = my_func (win, @fun, plist, c1, c2, ...)
    %
    % If caller information is required, either to index into lookup information
    % or to interpret stored internal state information:
    %
    %   >> [wout, state_out, store_out] = my_func (win, caller, state_in, store_in,...
    %                                                       @fun, plist, c1, c2, ...)
    %
    % where:
    %   caller      Stucture that contains information from the caller routine. Fields
    %                   reset_state     Logical scalar:
    %                                   If true: then for each element of win the
    %                                  internal state of my_func needs to be reset
    %                                  to the corresponding value in state_in (see
    %                                  below).
    %                                   If false: the internal state required to
    %                                  reproduce the same calculated output must be
    %                                  returned in the corresponding element of state_out
    %                                  (see below).
    %                   ind             Indicies of data sets in the full set of data
    %                                  sets that are being fitted. The number of elements
    %                                  of ind must match the number of elements of win
    %
    %               reset_state should be used if the output of my_func depends on the
    %              internal state of my_func e.g. the value of seeds for random number
    %              generators.
    %
    %               The index array ind is useful if, for example, some lookup tables
    %              have been created for the full set of data sets, and for which
    %              the actual index or indicies are needed inside my_func to be
    %              able to get to the relevant lookup table(s).
    %
    %   state_in    Cell array containing previously saved internal states for each
    %              element of win. This is information that can be used to reset the
    %              internal state (e.g. random number generators) so that calculations
    %              can be reproduced exactly for the same input parameters in plist.
    %               The number of elements must match the number of elements in win.
    %               The case of an empty state i.e. isempty(state_in{i}) is the
    %              case of no stored state. Appropriate default behaviour must be
    %              implemented; this will be the case on the initial call from
    %              mutlifit_lsqr.
    %               If the internal state is not needed, then reset_state and state_in
    %              can be ignored.
    %
    %   store_in    Stored information that could be used in the function evaluation,
    %              for example lookup tables that accumulate. This should be
    %              different from the state: the values of store should not affect
    %              the values of the calculated function, only the speed at which the
    %              values are calculated.
    %               The first call from multifit_lsqr it will be set to [].
    %               If no storage is needed, then it can be ignored.
    %
    %   state_out   Cell array containing internal states to be saved for a future call.
    %               The number of elements must match the number of elements in win.
    %               If the internal state is not needed, then state_out can be set
    %              to cell(size(win)) - but it must be set to a cell array with
    %              the same nmber of elements as win.
    %
    %   store_out   Updated stored values. Must always be returned, but can be
    %              set to [] if not used.
    %
    %
    %   Typical code fragment could be:
    %
    %   function [wout, state_out, store_out] = my_func (win, caller, state_in, store_in,...
    %                                                       @fun, plist, c1, c2, ...)
    %       :
    %   state_out = cell(size(win));    % create output argument
    %       :
    %   ind = caller.ind;
    %   for i=1:numel(ind)
    %       iw=ind(i);                  % index of workspace into lookup tables
    %       % Set random number generator if necessary, and save if required for later
    %       if reset_state
    %           if ~isempty(state_in{i})
    %               rng(state_in{i})
    %           end
    %       else
    %           state_out{i} = rng;     % capture the random number generator state
    %       end
    %        :
    %   end
    %
    % ---------------------------------------------------------------------------------------
    % History
    % ---------------------------------------------------------------------------------------
    %
    % T.G.Perring Jan 2016:
    % ------------------------
    % Change calls to fit functions so that caller information is passed direcetly rather than
    % via a function that stores persistent information. Makes cleanup easier and future
    % refactoring onto multiple cores more straightforward.
    %
    % T.G.Perring Jan 2009:
    % ------------------------
    % Generalise to arbitrary data objects which have a certain set of methods defined on them (see
    % notes elsewhere for details)
    %
    % T.G.Perring 11-Jan-2007:
    % ------------------------
    % Core Levenberg-Marquardt minimisation method inspired by speclsqr.m from spec1d, but massively
    % edited to make more memory efficient, remove redundant code, and especially rewrite the *AWFUL*
    % estimation of errors on the parameter values (which needed a temporary
    % array of size m^2, where m is the number of data values - 80GB RAM
    % for m=100,000!). The error estimates were also a factor sqrt(ndat/(ndat-npfree))
    % too large - as determined by comparing with analytical result for fitting to
    % a straight line, from e.g. G.L.Squires, Practical Physics, (CUP ~1980). The
    % current routine gives correct result.
    %
    % Previous history:
    % -----------------
    % Version 3.beta
    % Levenberg-Marquardt nonlinear regression of f(x,p) to y(x)
    % Richard I. Shrager (301)-496-1122
    % Modified by A.Jutan (519)-679-2111
    % Modified by Ray Muzic 14-Jul-1992

    p = inputParser();
    addOptional(p, 'listing', 0, @isnumeric);
    addOptional(p, 'fcp', [0.0001, 20, 0.001], @(n)(validateattributes(n,{'numeric'},{'vector','numel',3})));
    addOptional(p, 'perform_fit', 1, @islognumscalar);
    parse(p, listing,fcp,perform_fit);

    listing = p.Results.listing;
    fcp = p.Results.fcp;
    perform_fit = p.Results.perform_fit;

    if abs(fcp(1))<1e-12
        error('HERBERT:mfclass:multifit_lsqr',...
              'Derivative step length must be greater than or equal 10^-12')
    end
    if fcp(2)<0
        error('HERBERT:mfclass:multifit_lsqr','Number of iterations must be >=0')
    end

    jd = JobDispatcher('ParallelMF');

    % Allow splitting of bins if not averaged or dnd
    pars = arrayfun(@(x) x.plist, pin, 'UniformOutput', false);
    while any(cellfun(@iscell,pars)) % Flatten pars
        pars = [pars{cellfun(@iscell,pars)} pars(~cellfun(@iscell,pars))];
    end

    split_bins = any(cellfun(@(x) strcmp(x, '-ave'), pars)) || ...
        any(cellfun(@(x) isa(x, 'dndbase'), w));

    nWorkers = 4;

    % Potential issues follow if parallelism is used
    % Special casing for Tobyfit where arguments need to be distributed
    % as well as data. If functions require arguments distributing
    % these will fail in parallel

    if any(cellfun(@(x)(startsWith(functions(x).function, 'tobyfit')), func))
            [loop_data, merge_data] = split_data(w, xye, [], [], nWorkers, split_bins, arrayfun(@(x)(x.plist{3}), pin, 'UniformOutput', false));
    else
        [loop_data, merge_data] = split_data(w, xye, [], [], nWorkers, split_bins);
    end

    common_data = struct('func', {func}, ...
                         'bfunc', {bfunc}, ...
                         'pin', {pin}, ...
                         'bpin', {bpin}, ...
                         'f_pass_caller_info', {f_pass_caller_info}, ...
                         'bf_pass_caller_info', {bf_pass_caller_info}, ...
                         'p_info', {p_info}, ...
                         'fcp', {fcp}, ...
                         'merge_data', {merge_data}, ...
                         'perform_fit', {perform_fit});
    common_data.p = pfin;

    [outputs, n_failed, task_ids, jd] = jd.start_job('MFParallel_Job', common_data, loop_data, true, nWorkers);

    if n_failed

        if iscell(outputs)
            celldisp(outputs)
            outputs{1}.error
            struct2table(outputs{1}.error.stack)
            rethrow(outputs{1}.error)
            failure = cellfun(@(x)isa(x, 'MException'), outputs);
            failure = outputs{failure};
            rethrow(failure)
        else
            outputs.error
            struct2table(outputs.error.stack_r)
            struct2table(outputs.error.stack)
        end

    else
        [p_best, sig, cor, chisqr_red, converged] = map_back(outputs{1});
    end

end

function varargout = map_back(output)
    fn = fieldnames(output);
    nfn = numel(fn);
    varargout = cell(nfn,1);
    for i=1:nfn
        varargout{i} = output.(fn{i});
    end
end

function [loop_data, merge_data] = split_data(w, xye, S, Store, nWorkers, split_bins, tobyfit)
% Split up sqws and divvy xyes in w

    loop_data = cell(nWorkers, 1);
    merge_data = cell(numel(w), 1);

    for i=1:nWorkers
        loop_data{i} = struct('w', {cell(numel(w),1)}, 'xye', xye, 'S', S, 'Store', Store);
    end

    for i=1:numel(w)
        if xye(i)
            [data, merge_data{i}] = split_xye(w{i}, nWorkers);
        elseif isa(w{i}, 'SQWDnDBase')
            [data, merge_data{i}] = split_sqw(w{i}, 'nWorkers', nWorkers, 'split_bins', split_bins);
        elseif isa(w{i}, 'IX_dataset')
            [data, merge_data{i}] = split_dataset(w{i}, nWorkers);
        else
            error('HERBERT:split_data:invalid_argument', ...
                  'Unrecognised type: %s, data must be of type struct, SQWDnDBase or IX_dataset.', class(w{i}))
        end

        for j=1:nWorkers
            loop_data{j}.w{i} = data(j);
        end

    end

    if exist('tobyfit', 'var')
        a = RandStream.getGlobalStream()
        for i=1:nWorkers
            loop_data{i}.tobyfit_data = tobyfit;
            loop_data{i}.rng = a;
            for k = 1:numel(tobyfit)
                for j = 1:numel(tobyfit{k}.kf)

                    n = numel(tobyfit{k}.kf{j});
                    nPer = repmat(floor(n / nWorkers), nWorkers, 1);
                    nPer(1:mod(n, nWorkers)) = nPer(1:mod(n, nWorkers)) + 1;
                    points = [0; cumsum(nPer)];

                    loop_data{i}.tobyfit_data{k}.kf{j}     = tobyfit{k}.kf{j}(points(i)+1:points(i+1));
                    loop_data{i}.tobyfit_data{k}.dt{j}     = tobyfit{k}.dt{j}(points(i)+1:points(i+1));
                    loop_data{i}.tobyfit_data{k}.dq_mat{j} = tobyfit{k}.dq_mat{j}(:,:,points(i)+1:points(i+1));
                    for l=1:4
                        loop_data{i}.tobyfit_data{k}.qw{j}{l} = tobyfit{k}.qw{j}{l}(points(i)+1:points(i+1));
                    end
                end
            end
        end
    end
end

function [data, merge_data] = split_xye(w, nWorkers)
    n = numel(w.y);
    nPer = repmat(floor(n / nWorkers), nWorkers, 1);
    nPer(1:mod(n, nWorkers)) = nPer(1:mod(n, nWorkers)) + 1;
    points = [0; cumsum(nPer)];
    tmp = cellfun(@(x)(mat2cell(x, 1, nPer)), w.x(:), 'UniformOutput', false);

    data = struct('x', [], 'y', [], 'e', [], 'nomerge', repmat({true}, nWorkers, 1));
    merge_data = struct('nomerge', true, 'nelem', num2cell(nPer));

    for i=1:nWorkers
        tmp2 = cellfun(@(x) x(i), tmp, 'UniformOutput', false);
        data(i).x = tmp2{1};
        data(i).y = w.y(points(i)+1:points(i+1));
        data(i).e = w.e(points(i)+1:points(i+1));
    end
end

function [data, merge_data] = split_dataset(w, nWorkers)
    cls = class(w);
    dims = str2num(cls(12));
    n = numel(w.x);
    nPer = repmat(floor(n / nWorkers), nWorkers, 1);
    nPer(1:mod(n, nWorkers)) = nPer(1:mod(n, nWorkers)) + 1;
    points = [0; cumsum(nPer)];

    data(1:nWorkers) = w; % struct('w', cell(nWorkers,1));
    merge_data = struct('nomerge', true, 'nelem', num2cell(nPer));

    for i = 1:nWorkers
        data(i).x = w.x(points(i)+1:points(i+1));
        data(i).signal = w.signal(points(i)+1:points(i+1));
        data(i).error = w.error(points(i)+1:points(i+1));
    end

    if dims > 1
        for i = 1:nWorkers
            data(i).y = w.y(points(i)+1:points(i+1));
        end
    end
    if dims > 2
        for i = 1:nWorkers
            data(i).z = w.z(points(i)+1:points(i+1));
        end
    end


end

function out = merge_section(in, loop_data)
% Merge a compenent of split data into contiguous block, collating like sqw data
% Possibly inefficient, but should be a miniscule part of calculation

    nWorkers = numel(in);
    nw = numel(in{1});
    out = in{1};

    for iWorker=2:nWorkers
        for iw=1:nw
            if loop_data{iWorker}.nomerge{iw}
                out{iw} = cat(1, out{iw}, in{iWorker}{iw}(1:end));
            else
                out{iw}(end) = out{iw}(end)*loop_data{iWorker-1}.nelem(iw*2) + in{iWorker}{iw}(1)*loop_data{iWorker}.nelem(iw*2-1);
                out{iw}(end) = out{iw}(end) / (loop_data{iWorker-1}.nelem(iw*2) + loop_data{iWorker}.nelem(iw*2-1));
                out{iw} = cat(1, out{iw}, in{iWorker}{iw}(2:end));
            end
        end
    end

end

function [f, v, loop_data, Store, S] = merge_data(outputs, loop_data)
% Recombine data for use in serial segments (dfdpf).
% Also updates loop_data's store.

    data = cellfun(@(x)(x.f), outputs, 'UniformOutput', false);
    f = merge_section(data, loop_data);
    f = cat(1, f{:});

    data = cellfun(@(x)(x.v), outputs, 'UniformOutput', false);
    v = merge_section(data, loop_data);
    v = cat(1, v{:});

    for i=1:numel(outputs)
        loop_data{i}.S = outputs{i}.S;
        loop_data{i}.Store = outputs{i}.Store;
    end

    S = struct('pstore', {outputs{1}.S.pstore}, ...
               'bpstore', {outputs{1}.S.bpstore}, ...
               'fstate_store', {outputs{end}.S.fstate_store}, ...
               'bfstate_store', {outputs{end}.S.bfstate_store});
    S.store_filled = true;

    Store = struct('fore', [], 'back', []);

    if any(cellfun(@(x)(numel(x.S.fcalc_store{1})), outputs))
        tmp = cellfun(@(x)(x.S.fcalc_store), outputs, 'UniformOutput', false);
        S.fcalc_store = merge_section(tmp, loop_data);
        tmp = cellfun(@(x)(x.S.fvar_store), outputs, 'UniformOutput', false);
        S.fvar_store = merge_section(tmp, loop_data);
    else
        S.fcalc_store = [];
        S.fvar_store = [];
    end

    if any(cellfun(@(x)(numel(x.S.bcalc_store{1})), outputs))
        tmp = cellfun(@(x)(x.S.bcalc_store), outputs, 'UniformOutput', false);
        S.bcalc_store = merge_section(tmp, loop_data);
        tmp = cellfun(@(x)(x.S.bvar_store), outputs, 'UniformOutput', false);
        S.bvar_store = merge_section(tmp, loop_data);
    else
        S.bcalc_store = [];
        S.bvar_store = [];
    end

    for i=2:numel(outputs)
        S.store_filled = S.store_filled & outputs{i}.S.store_filled;
        Store.fore = [Store.fore, outputs{i}.Store.fore];
        Store.back = [Store.back, outputs{i}.Store.back];
    end

end
