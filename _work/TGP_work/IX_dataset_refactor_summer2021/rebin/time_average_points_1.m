function time_average_points_1 (nx0, nw)
% Tests of timing of point averaging cf trapezoidal integration in one dimension
%
%   >> time_average_points_1              % use default nx0 and nw
%   >> time_average_points_1 (nx0, nw)
%
%   nx0     Number of bins along x axis (approximately; used as input to generate data)
%           Default = 500
%
%   nw      Number of 1D workspaces in array of IX_dataset_1d
%           Default = 500

%--------------------------------------------------------------------------
% T.G.Perring 2021-08-29:
%
%--------------------------------------------------------------------------

% Set default values for nx0 and nw
if nargin==0
    nx0=500; nw=500;
elseif nargin==1
    nw=500;
end

% Create test data sets
disp('Creating data for timing...')
tic
[x,s,e]=make_testdata_xye_point (nx0, nw);
toc
disp(' ')

% -----------------------------------------------
% Some timing tests with huge 1D arrays
% -----------------------------------------------
% Comment from old tests from c.2010 re point data rebinning algorithm
%    if point 'ave', then matlab and Fortran are comparable;
%    if point 'int', then matlab can be grossly more time-consuming
%                   for rebin(pp_1d_gau, [1,0.002,6],'int') is 30 times slower.
%                   (this is when the number of bins is comparable in the
%                   input and output dataset)

del=0.002;
xout = (1:del:6);   % 2500 bins
tol = 1e-14;

% disp('-----------------------------------------------------------------------------------')
% disp('Rebin compare original and new functions')
% disp('----------------------------------------')
% tic
% for i=1:min(10,numel(x))    % to keep number of comparisons down
%     [sout_ref, eout_ref] = integrate_1d_points_original (x{i}, s{i}, e{i}, xout);
%     
%     [sout, eout] = integrate_1d_points_for_loop (x{i}, s{i}, e{i}, xout);
%     if max(abs(sout_ref-sout))>tol || max(abs(eout_ref-eout))>tol
%         disp('Error !!')
%         error('Original and for-loop routines give different results')
%     end
%         
%     [sout_true, eout_true] = integrate_points_trueErrors (x{i}, s{i}, e{i}, 1, xout);
%     if max(abs(sout_ref-sout_true))>tol
%         disp('Error !!')
%         error('Original and trueError routines give different signals')
%     end
%     
% end
% disp('All tested outputs within tolerance')
% toc
% disp(' ')
% disp('-----------------------------------------------------------------------------------')

% Average points
% --------------
tic
S = 0;
for i=1:numel(x)
    [~, sout_ref, eout_ref] = average_points_ver1 (x{i}, s{i}, e{i}, 1, xout);
    S = S + sout_ref(1) + eout_ref(1);
end
disp(['                         Average points: ',num2str(toc), ' seconds.'])


% Integrate true error bars
% -------------------------
tic
S = 0;
for i=1:numel(x)
    [sout, eout] = integrate_points_trueErrors (x{i}, s{i}, e{i}, 1, xout);
    S = S + sout(1) + eout(1);
end
disp(['              Integrate true error bars: ',num2str(toc), ' seconds.'])


disp(' ')


% Average points production
% -------------------------
tic
S = 0;
for i=1:numel(x)
    [~, sout_ref, eout_ref] = average_points (x{i}, s{i}, e{i}, 1, xout);
    S = S + sout_ref(1) + eout_ref(1);
end
disp(['              Production average points: ',num2str(toc), ' seconds.'])


%--------------------------------------------------------------------------------
function [x,y,e]=make_testdata_xye_point (nx0, nw)
% Create arrays of xye data with random x axes and Gaussian signal
%
%   >> [x,y,e]=make_testdata_xye_point (nx0, nw)
%
% The objects are the same each time because the random number generator
% seed is always set to zero first (then set to incoming state afterwards)
%
% Input:
% -------
%   nx0                 Used to generate values of points along the x axis. Each
%                      IX_dataset_1d will have approximately nx0 points, with
%                      values approximately between 0 and 10.
%   nw                  Number of workspaces in the output IX_dataset_1d arrays
%
% Output:
% -------
%   x,y,e               Cellarrays of x,y,e for point data


xrange=10;

% A big histogram array
% ------------------------------
s = rng();
rng(0);

nx=nx0+round(0.2*nx0*rand(nw,1));
x=cell(nw,1);
y=cell(nw,1);
e=cell(nw,1);

for i=1:nw
    x{i}=xrange*((1+0.1*rand(1,1))*sort(rand(1,nx(i)))-0.05*rand(1,1));
    y{i}=10*exp(-0.5*(((x{i}'-xrange/2)/(xrange/4)).^2 + ((i-nw/2)/(nw/4)).^2));
    e{i}=0.5+rand(nx(i),1);
end

rng(s)
