function time_rebin_hist_2
% Tests of timing of rebin in different dimensions of a 4D dataset
%
% The goal is to determine which of the two permute-and-reshape solutions
% is faster.
%
% Conclude (August 2021) that the faster is rebin_hist_trueErrors_xN, which
% reshapes so that the loop is over the outer dimension.


n = [30,50,20,40];
hist = true(size(n));
[x,s,e] = make_testdata_nd (n, hist);

x1_out = (5:3:25);
x3_out = (1:0.3:100);

tol = 1e-12;

% Rebin along 3rd axis
idim = 3;
tic; [sout1, eout1] = rebin_hist_trueErrors_xN(x{idim}, s, e, idim, x3_out); toc
tic; [sout2, eout2] = rebin_hist_trueErrors_Nx(x{idim}, s, e, idim, x3_out); toc
tic; [sout_simple, eout_simple] = rebin_hist_trueErrors_simple(x{idim}, s, e, idim, x3_out); toc
disp(' ')

if max(abs(sout_simple(:)-sout1(:)))>tol || max(abs(eout_simple(:)-eout1(:)))>tol
    disp('Error !!')
    error('trueError_xN and trueError routines give different results')
end

if max(abs(sout_simple(:)-sout2(:)))>tol || max(abs(eout_simple(:)-eout2(:)))>tol
    disp('Error !!')
    error('trueError_Nx and trueError routines give different results')
end

% Now rebin along the first axis
idim = 1;
tic; [sout1, eout1] = rebin_hist_trueErrors_xN(x{idim}, sout1, eout1, idim, x1_out); toc
tic; [sout2, eout2] = rebin_hist_trueErrors_Nx(x{idim}, sout2, eout2, idim, x1_out); toc
tic; [sout_simple, eout_simple] = rebin_hist_trueErrors_simple(x{idim},...
    sout_simple, eout_simple, idim, x1_out); toc

if max(abs(sout_simple(:)-sout1(:)))>tol || max(abs(eout_simple(:)-eout1(:)))>tol
    disp('Error !!')
    error('trueError_xN and trueError routines give different results')
end

if max(abs(sout_simple(:)-sout2(:)))>tol || max(abs(eout_simple(:)-eout2(:)))>tol
    disp('Error !!')
    error('trueError_Nx and trueError routines give different results')
end

