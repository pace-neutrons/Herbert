function fitdata = repackage_output_parameters (p_best, sig, cor, chisqr_red, converged, p_info, bkd)
% Pack the output fit parameters into standard form
%
%   >> fitdata = repackage_output_parameters (p_best, sig, cor, chisqr_red, converged, p_info, bkd)
%
%
% Output:
% -------
%   fitdata     Structure containing information about parameter values from the fit
%              The fields are:
%               p      - Best fit foreground function parameter values
%                          If only one function, a row vector
%                          If more than one function: a row cell array of row vectors
%               sig    - Estimated errors of foreground parameters (=0 for fixed parameters)
%                          If only one function, a row vector
%                          If more than one function: a row cell array of row vectors
%               bp     - Background parameter values (if background function(s) present)
%                          If only one function, a row vector
%                          If more than one function: a row cell array of row vectors
%               bsig   - Estimated errors of background, if present (=0 for fixed parameters)
%                          If only one function, a row vector
%                          If more than one function: a row cell array of row vectors
%               corr   - Correlation matrix for free parameters
%               chisq  - Reduced Chi^2 of fit i.e. divided by:
%                           (no. of data points) - (no. free parameters))
%               converged - True if fit converged, false otherwise
%               pnames - Foreground parameter names
%                          If only one function, a cell array (row vector) of names
%                          If more than one function: a row cell array of row vector cell arrays
%               bpnames- Background parameter names  (if background function(s) present)
%                          If only one function, a cell array (row vector) of names
%                          If more than one function: a row cell array of row vector cell arrays
%
%
% Note about parameter names:
% ---------------------------
%  Purely for backwards compatibility original 'fit' function, return names of the parameters
% but only the default names.
%  No longer try assuming form of mfit function and catch in case not, because the line:
%    try, [dummy1,dummy2,pnames] = func(x{:}, p{1}, 1); catch...
% could invoke a very lengthy calculation.

[p_tmp,bp_tmp]=ptrans_par(p_best,p_info);
[psig_tmp,bsig_tmp]=ptrans_sigma(sig,p_info);

np=p_info.np;
nbp=p_info.nbp;
nforefunc=numel(np);
nbkdfunc=numel(nbp);

for i=1:numel(p_tmp)
    p_tmp{i}=p_tmp{i}';         % make a row vector
    psig_tmp{i}=psig_tmp{i}';   % make a row vector
end
if nforefunc==1 % Only one foreground function
    fitdata.p=p_tmp{1};
    fitdata.sig=psig_tmp{1};
else
    fitdata.p=p_tmp';           % make a row vector
    fitdata.sig=psig_tmp';      % make a row vector
end

if bkd
    for i=1:numel(bp_tmp)
        bp_tmp{i}=bp_tmp{i}';       % make a row vector
        bsig_tmp{i}=bsig_tmp{i}';   % make a row vector
    end
    if nbkdfunc==1  % Only one background function
        fitdata.bp=bp_tmp{1};
        fitdata.bsig=bsig_tmp{1};
    else
        fitdata.bp=bp_tmp';         % make a row vector
        fitdata.bsig=bsig_tmp';     % make a row vector
    end
end

fitdata.corr=cor;
fitdata.chisq=chisqr_red;
fitdata.converged=converged;

if nforefunc==1
    fitdata.pnames=cell(1,np(1));
    for ip=1:np(1), fitdata.pnames{ip}=['p',num2str(ip)]; end
else
    fitdata.pnames=cell(1,numel(np));
    for i=1:numel(np)
        fitdata.pnames{i}=cell(1,np(i));
        for ip=1:np(i), fitdata.pnames{i}{ip}=['p',num2str(ip)]; end
    end
end
    
if bkd
    if nbkdfunc==1
        fitdata.bpnames=cell(1,nbp(1));
        for ip=1:nbp(1), fitdata.bpnames{ip}=['p',num2str(ip)]; end
    else
        fitdata.bpnames=cell(1,numel(nbp));
        for i=1:numel(nbp)
            fitdata.bpnames{i}=cell(1,nbp(i));
            for ip=1:nbp(i), fitdata.bpnames{i}{ip}=['p',num2str(ip)]; end
        end
    end
end
