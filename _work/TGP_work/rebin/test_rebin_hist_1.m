%% ========================================================================
% Test error bars by rebinning into smaller bins that are commensurate with
% old boundaries, and then rebin back to where we were

x = [10,20,25,31];
s = [7,9,5]';
e = [1.5,2,0.7]';

win = IX_dataset_1d(x,s,e);
acolor k
dh(win); pe(win); lx 5 35; ly 0 12; keep_figure
title ('Initial dataset')

xout = [10,12,13,14,16,17,20,...
    21,21.5,22,22.5,23.5,25,...
    27,31];

% Original routine, as used for several years prior to July 2021
[stmp, etmp] = rebin_hist_ (x,s,e,xout);
[sout_ref, eout_ref] = rebin_hist_(xout,stmp,etmp,x);
wout_ref = IX_dataset_1d(x, sout_ref, eout_ref);
acolor b
dh(wout_ref); pe(wout_ref); lx 5 35; ly 0 12; keep_figure
title ('Original algorithm: divided and rebinned to original dataset')


idim = 1;
[stmp, etmp] = rebin_hist_trueErrors_xN (x,s,e,idim,xout);
[sout_EBAR, eout_EBAR] = rebin_hist_trueErrors_xN (xout,stmp,etmp,idim,x);
wout_ebar = IX_dataset_1d(x, sout_EBAR, eout_EBAR);
acolor m
dh(wout_ebar); pe(wout_ebar); lx 5 35; ly 0 12; keep_figure
title ('Correct algorithm: divided and rebinned to original dataset')



%% ========================================================================
% Show that error bars are identical if no splitting of bins

nbins = 10;
x = (1:nbins+1)' + rand(nbins+1,1);
y = rand(nbins,1);
e = 0.3*rand(nbins,1);

xout = x(1:2:end);


wout2 = IX_dataset_1d(x,y,e);
acolor k
dh(wout2); pe(wout2); lx(0,nbins+2); ly 0 2; keep_figure
title ('Initial dataset')


[sout2_ref, eout2_ref] = rebin_hist_ (x,y,e,xout);
wout2_ref = IX_dataset_1d(xout ,sout2_ref, eout2_ref);
acolor b
dh(wout2_ref); pe(wout2_ref); lx(0,nbins+2); ly 0 2; keep_figure
title ('Original algorithm')


idim = 1;
[sout2_new, eout2_new] = rebin_hist_trueErrors_xN (x,y,e,idim,xout);
wout2_new = IX_dataset_1d(xout ,sout2_new, eout2_new);
acolor r
dh(wout2_new); pe(wout2_new); lx(0,nbins+2); ly 0 2; keep_figure
title ('Correct algorithm')



