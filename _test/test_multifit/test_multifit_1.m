function test_multifit_1(varargin)
% Performs a number of tests of syntax and equivalence of multifit and fit.
% Optionally writes results to output file or tests output against stored output
%
%   >> test_multifit_1           % Compares with previously saved results in test_multifit_1_output.mat
%                                % in the same folder as this function
%   >> test_multifit_1 ('save')  % Save to  c:\temp\test_multifit_1_output.mat
%
% Reads previously created test data in .\make_data\test_multifit_datasets_1.mat

if nargin==1
    if ischar(varargin{1}) && size(varargin{1},1)==1 && isequal(lower(varargin{1}),'save')
        save_output=true;
    else
        error('Unrecognised option')
    end
elseif nargin==0
    save_output=false;
else
    error('Check number of input arguments')
end

%% =====================================================================================================================
%  Setup location of reference functions (fortran or matlab)
% ======================================================================================================================
rootpath=fileparts(mfilename('fullpath'));
load(fullfile(rootpath,'make_data','test_multifit_datasets_1.mat'));


%% =====================================================================================================================
%  Tests with single input data set
% ======================================================================================================================
pin=[100,50,7,0,0];     % Note that it is assumed that these are good starting parameters for the fits

% Reference output
% ----------------
% Create reference output
[y1_fref, wstruct1_fref, w1_fref, p1_fref] = mftest_mf_and_f_single_dataset (x1,y1,e1,wstruct1,w1, @mftest_gauss_bkgd, pin);

% Slow oonvergence, print output
[y1_fslow, wstruct1_fslow, w1_fslow, p1_fslow] = mftest_mf_and_f_single_dataset (x1,y1,e1,wstruct1,w1, @mftest_gauss_bkgd, pin, [1,0,1,0,0], 'list',2);   

% Equivalence of split foreground and background functions with single function
[y1_fsigfix, wstruct1_fsigfix, w1_fsigfix, p1_fsigfix] = mftest_mf_and_f_single_dataset (x1,y1,e1,wstruct1,w1,...
    @mftest_gauss_bkgd, pin, [1,0,1,1,1]);   
[y1_fsigfix_bk, wstruct1_fsigfix_bk, w1_fsigfix_bk, p1_fsigfix_bk] = mftest_mf_and_f_single_dataset (x1,y1,e1,wstruct1,w1,...
    @mftest_gauss, pin(1:3), [1,0,1], @mftest_bkgd, pin(4:5));

tol=0;
if ~equal_to_tol(y1_fsigfix,y1_fsigfix_bk,tol)
    error('Test failed: split foreground and background functions not equivalent to single function')
end

% Test binding
% ------------------

% Fix ratio of two of the foreground parameters
prat=[6,0,0,0,0]; pbnd=[3,0,0,0,0];
[y1_fbind1_ref, wstruct1_fbind1_ref, w1_fbind1_ref, p1_fbind1_ref] = mftest_mf_and_f_single_dataset (x1,y1,e1,wstruct1,w1,...
    @mftest_gauss_bkgd_bind, [pin,prat,pbnd], [0,0,1,1,0,zeros(1,10)]);

[y1_fbind1_1, wstruct1_fbind1_1, w1_fbind1_1, p1_fbind1_1] = mftest_mf_and_f_single_dataset (x1,y1,e1,wstruct1,w1,...
    @mftest_gauss, pin(1:3), [1,0,1], {1,3,0,6}, @mftest_bkgd, pin(4:5), [1,0]);

tol=0;
if ~equal_to_tol(y1_fbind1_ref,y1_fbind1_1,tol)     % can only compare output y values - we've fudged the reference fit function, and parameters are not 'real'
    error('Test failed: binding problem')
end

[y1_fbind1_2, wstruct1_fbind1_2, w1_fbind1_2, p1_fbind1_2] = mftest_mf_and_f_single_dataset (x1,y1,e1,wstruct1,w1,...    % Same, but pick ratio from input ht and sig
    @mftest_gauss, [6*pin(3),pin(2:3)], [1,0,1], {1,3}, @mftest_bkgd, pin(4:5), [1,0]);

tol=0;
if ~equal_to_tol(y1_fbind1_ref,y1_fbind1_2,tol)
    error('Test failed: binding problem')
end

% Fix ratio of two of the foreground, and two of the background parameters
prat=[6,0,0,0.01,0]; pbnd=[3,0,0,5,0];
[y1_fbind2_ref, wstruct1_fbind2_ref, w1_fbind2_ref, p1_fbind2_ref] = mftest_mf_and_f_single_dataset (x1,y1,e1,wstruct1,w1,...
    @mftest_gauss_bkgd_bind, [pin,prat,pbnd], [0,0,1,0,1,zeros(1,10)]);

[y1_fbind2, wstruct1_fbind2, w1_fbind2, p1_fbind2] = mftest_mf_and_f_single_dataset (x1,y1,e1,wstruct1,w1,...
    @mftest_gauss, pin(1:3), [1,0,1], {1,3,0,6}, @mftest_bkgd, pin(4:5),'', {{1,2,1,0.01}});

tol=0;
if ~equal_to_tol(y1_fbind2_ref,y1_fbind2,tol)     % can only compare output y values - we've fudged the reference fit function, and parameters are not 'real'
    error('Test failed: binding problem')
end

% Fix parameters across the foreground and background
prat=[0,0,0.2,0,1/300]; pbnd=[0,0,4,0,2];
[y1_fbind3_ref, wstruct1_fbind3_ref, w1_fbind3_ref, p1_fbind3_ref] = mftest_mf_and_f_single_dataset (x1,y1,e1,wstruct1,w1,...
    @mftest_gauss_bkgd_bind, [100,50,5,20,0,prat,pbnd], [0,1,0,1,0,zeros(1,10)]);

[y1_fbind3, wstruct1_fbind3, w1_fbind3, p1_fbind3] = mftest_mf_and_f_single_dataset (x1,y1,e1,wstruct1,w1,...
    @mftest_gauss, [100,50,5], [0,1,1], {3,1,1,0.2}, @mftest_bkgd, [20,0],'', {{2,2,0,1/300}});

tol=0;
if ~equal_to_tol(y1_fbind3_ref,y1_fbind3,tol)  % can only compare output y values - we've fudged the reference fit function, and parameters are not 'real'
    error('Test failed: binding problem')
end

% Yet more binding of parameters
prat=[2,0,0.2,0,1/300]; pbnd=[2,0,4,0,2];
[y1_fbind4_ref, wstruct1_fbind4_ref, w1_fbind4_ref, p1_fbind4_ref] = mftest_mf_and_f_single_dataset (x1,y1,e1,wstruct1,w1,...
    @mftest_gauss_bkgd_bind, [100,50,5,20,0,prat,pbnd], [0,1,0,1,0,zeros(1,10)]);

[y1_fbind4, wstruct1_fbind4, w1_fbind4, p1_fbind4] = mftest_mf_and_f_single_dataset (x1,y1,e1,wstruct1,w1,...
    @mftest_gauss, [100,50,5], '', {{1,2},{3,1,1,0.2}}, @mftest_bkgd, [20,0],'', {{2,2,0,1/300}});

tol=0;
if ~equal_to_tol(y1_fbind4_ref,y1_fbind4,tol)  % can only compare output y values - we've fudged the reference fit function, and parameters are not 'real'
    error('Test failed: binding problem')
end


%% =====================================================================================================================
% Test multiple datasets
% ======================================================================================================================
ww_objarr=[w1,w2,w3];
[ww_fobjarr_f,pp_fobjarr,ok,mess] = mftest_mf_and_f_multiple_datasets(ww_objarr, @mftest_gauss_bkgd, pin);
if ~ok, error('Unexpected failure'), end

ww_objcellarr={w1,w2,w3};
[ww_fobjcellarr_f,pp_fobjcellarr,ok,mess] = mftest_mf_and_f_multiple_datasets(ww_objcellarr, @mftest_gauss_bkgd, pin);
if ~ok, error('Unexpected failure'), end

ww_structarr=[wstruct1,wstruct2,wstruct3];
[ww_fstructarr_f,pp_fstructarr,ok,mess] = mftest_mf_and_f_multiple_datasets(ww_structarr, @mftest_gauss_bkgd, pin);
if ~ok, error('Unexpected failure'), end

ww_cellarr={wstruct1,w2,wstruct3};
[ww_fcellarr_f,pp_fcellarr,ok,mess] = mftest_mf_and_f_multiple_datasets(ww_cellarr, @mftest_gauss_bkgd, pin);
if ok, error('Should have failed, but did not'), end


%% =====================================================================================================================
% Compare with saved output
% ====================================================================================================================== 
if ~save_output
    disp('====================================')
    disp('    Comparing with saved output')
    disp('====================================')
    output_file=fullfile(rootpath,'test_multifit_1_output.mat');
    old=load(output_file);
    nam=fieldnames(old);
    tol=-1.0e-13;
    % The test proper
    for i=1:numel(nam)
        [ok,mess]=equal_to_tol(eval(nam{i}), old.(nam{i}), tol, 'min_denominator', 0.01);
        if ~ok 
            error(['[',nam{i},']',mess])
        else
            disp (['[',nam{i},']',': ok'])
        end
    end
    disp(' ')
    disp(' All OK')
    disp(' ')
end


%% =====================================================================================================================
% Save data
% ====================================================================================================================== 
if save_output
    disp('===========================')
    disp('    Save output')
    disp('===========================')
    
    output_file='c:\temp\test_multifit_1_output.mat';
    save(output_file,...
        'y1_fref', 'wstruct1_fref', 'w1_fref', 'p1_fref',...
        'y1_fslow', 'wstruct1_fslow', 'w1_fslow', 'p1_fslow',...
        'y1_fsigfix', 'wstruct1_fsigfix', 'w1_fsigfix', 'p1_fsigfix',...
        'y1_fsigfix_bk', 'wstruct1_fsigfix_bk', 'w1_fsigfix_bk', 'p1_fsigfix_bk',...
        'y1_fbind1_ref', 'wstruct1_fbind1_ref', 'w1_fbind1_ref', 'p1_fbind1_ref',...
        'y1_fbind1_1', 'wstruct1_fbind1_1', 'w1_fbind1_1', 'p1_fbind1_1',...
        'y1_fbind1_2', 'wstruct1_fbind1_2', 'w1_fbind1_2', 'p1_fbind1_2',...
        'y1_fbind2_ref', 'wstruct1_fbind2_ref', 'w1_fbind2_ref', 'p1_fbind2_ref',...
        'y1_fbind2', 'wstruct1_fbind2', 'w1_fbind2', 'p1_fbind2',...
        'y1_fbind3_ref', 'wstruct1_fbind3_ref', 'w1_fbind3_ref', 'p1_fbind3_ref',...
        'y1_fbind3', 'wstruct1_fbind3', 'w1_fbind3', 'p1_fbind3',...
        'y1_fbind4_ref', 'wstruct1_fbind4_ref', 'w1_fbind4_ref', 'p1_fbind4_ref',...
        'y1_fbind4', 'wstruct1_fbind4', 'w1_fbind4', 'p1_fbind4',...
        'ww_fobjarr_f','pp_fobjarr',...
        'ww_fobjcellarr_f','pp_fobjcellarr',...
        'ww_fstructarr_f','pp_fstructarr',...
        'ww_fcellarr_f','pp_fcellarr')

    disp(' ')
    disp(['Output saved to ',output_file])
    disp(' ')
end
