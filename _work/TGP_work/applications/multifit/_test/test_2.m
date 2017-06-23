function test_2
% Test of multifit2 with IX_dataset_1d

% Assumes have created a data file
test_dir = fileparts(mfilename('fullpath'));
S=load(fullfile(test_dir,'/data/testdata_multifit_1.mat'));


%--------------------------------------------------------------------------------------------------------------------
SS.warr3 = [S.w1,S.w2,S.w3];
SS.sarr3 = [S.wstruct1,S.wstruct2,S.wstruct3];



w = SS.warr3;


%--------------------------------------------------------------------------------------------------------------------
% An exanple fit with old multifit
[wfit_ref,fitdata_ref] = multifit (w, @mftest_gauss, [100,45,10], @mftest_bkgd, {[10,0],[20,0],[30,0]}, 'list', 2);


% Same with mfclass
kk = multifit2(w);
kk = kk.set_fun (@mftest_gauss, [100,45,10]);
kk = kk.set_bfun (@mftest_bkgd, {[10,0],[20,0],[30,0]});
kk = kk.set_options('listing',2);

% Perform simulation
% ------------------
% Simulate sum 
[wsim, fitcalc] = kk.simulate;

% Simulate components
wsim_comp = kk.simulate('comp');    
if ~isequaln(wsim_comp.sum,wsim)
    error('Problem with simulation options')
end

acolor r b k
dl(wsim_comp.sum)
pl(wsim_comp.fore)
pl(wsim_comp.back)
keep_figure


% Perform fit
% ------------
% Fit default output
[wfit, fitdata] = kk.fit;
if ~isequaln(wfit_ref,wfit) || ~isequaln(fitdata_ref,fitdata)
    error('Not equal fits')
end

% Fit outputting components
[wfit, fitdata] = kk.fit ('comp');
if ~isequaln(wfit_ref,wfit.sum) || ~isequaln(fitdata_ref,fitdata)
    error('Not equal fits')
end

acolor r b k
dp(w)
pl(wfit.sum)
pl(wfit.fore)
pl(wfit.back)
keep_figure


% Check parameter transfer feature
wdef = kk.simulate(fitdata);
wsum = kk.simulate(fitdata,'sum');
wfore = kk.simulate(fitdata,'fore');
wback = kk.simulate(fitdata,'back');
if ~isequaln(wfit.sum,wdef), error('Problem with simulation options'), end
if ~isequaln(wfit.sum,wsum), error('Problem with simulation options'), end
if ~isequaln(wfit.fore,wfore), error('Problem with simulation options'), end
if ~isequaln(wfit.back,wback), error('Problem with simulation options'), end
