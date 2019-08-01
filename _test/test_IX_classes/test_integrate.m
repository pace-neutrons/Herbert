function test_integrate (varargin)
% Test integrate functions, optionally writing results to output file or testing against stored output
%
%   >> test_integrate           % Compare with previously saved results in test_integrate_output.mat
%                               % in the same folder as this function
%   >> test_integrate ('save')  % save to  test_integrate_output.mat in tempdir (type >> help tempdir
%                               % for information about the system specific location returned by tempdir)
%
% Reads IX_dataset_1d and IX_dataset_2d from .mat file as input to the tests
%
% Author: T.G.Perring
hc = herbert_config;
hc.saveable = false;

test_mex = hc.use_mex;
hc.force_mex_if_use_mex = true;
clob_set = onCleanup(@()set(herbert_config,...
    'saveable',true,'use_mex',test_mex,'force_mex_if_use_mex',false));
log_level = hc.log_level;

if log_level>0
    banner_to_screen(mfilename)
end

data_filename='testdata_IX_datasets_ref.mat';
results_filename='test_integrate_output.mat';

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
% Setup location of reference functions (fortran or matlab)
% ======================================================================================================================
rootpath=fileparts(mfilename('fullpath'));
warning('off','MATLAB:unknownObjectNowStruct');
clob = onCleanup(@()warning('on','MATLAB:unknownObjectNowStruct'));

load(fullfile(rootpath,data_filename));

%% =====================================================================================================================
% Test 1D integration
% ======================================================================================================================

clear('ih1_mex','ih1b_mex','ip1_mex','ip1b_mex','ihpa_mex','ihpb_mex','ihpc_mex',...
    'ih1',    'ih1b',    'ip1',    'ip1b',    'ihpa',    'ihpb',    'ihpc')
if log_level>0
    disp('===========================')
    disp('    1D: Test integrate')
    disp('===========================')
end


tol=-1e-13;
if test_mex
    
    
    hc.use_mex = true;
    
    ih1_mex=integrate(h1,5,10);
    hc.use_mex = false;
    
    ih1    =integrate(h1,5,10);
    delta_IX_dataset_nd(ih1_mex,ih1,tol)
    
    hc.use_mex = true;
    
    ih1b_mex=integrate(h1,0,20);
    hc.use_mex = false;
    ih1b    =integrate(h1,0,20);
    delta_IX_dataset_nd(ih1b_mex,ih1b,tol)
    
    hc.use_mex = true;
    ip1_mex=integrate(p1,5,10);
    hc.use_mex = false;
    ip1    =integrate(p1,5,10);
    delta_IX_dataset_nd(ip1_mex,ip1,tol)
    
    
    hc.use_mex = true;
    ip1b_mex=integrate(p1,0,20);
    hc.use_mex = false;
    ip1b    =integrate(p1,0,20);
    delta_IX_dataset_nd(ip1b_mex,ip1b,tol)
    
    
    % Big array
    % ----------
    tol=-1e-13;
    
    hc.use_mex = true;
    ihpa_mex=integrate(hp_1d_big,105,110);
    hc.use_mex = false;
    ihpa    =integrate(hp_1d_big,105,110);
    delta_IX_dataset_nd(ihpa_mex,ihpa,tol);
    
    hc.use_mex = true;
    ihpb_mex=integrate(hp_1d_big,-10,550);
    set(herbert_config,'use_mex',false,'-buffer');
    ihpb    =integrate(hp_1d_big,-10,550);
    delta_IX_dataset_nd(ihpb_mex,ihpb,tol);
    
    hc.use_mex = true;
    ihpc_mex=integrate(hp_1d_big,-20,620);
    hc.use_mex = false;
    ihpc    =integrate(hp_1d_big,-20,620);
    delta_IX_dataset_nd(ihpc_mex,ihpc,tol);
else
    ih1    =integrate(h1,5,10);
    ih1b    =integrate(h1,0,20);
    ip1    =integrate(p1,5,10);
    ip1b    =integrate(p1,0,20);
    
    % Big array
    % ----------
    ihpa    =integrate(hp_1d_big,105,110);
    ihpb    =integrate(hp_1d_big,-10,550);
    ihpc    =integrate(hp_1d_big,-20,620);
end
if log_level>0
    disp(' ')
    disp('Done')
    disp(' ')
end




%% =====================================================================================================================
% Test 2D integration
% ======================================================================================================================
clear('w2x_sim','w2y_sim','w2xy_sim','w2x_mex','w2y_mex','w2xy_mex','w2x','w2y','w2xy')

% Create IX_dataset_1d to be rebinned
pp1b=pp1; pp1.x_distribution=true;  pp1.y_distribution=true;
hp1b=hp1; hp1.x_distribution=false; hp1.y_distribution=true;
ph1b=ph1; ph1.x_distribution=true;  ph1.y_distribution=false;
hh1b=hh1; hh1.x_distribution=false; hh1.y_distribution=false;

w2ref=[pp1,hp1,ph1,hh1,pp1b,hp1b,ph1b,hh1b];

% Integration arguments
xdescr=[6,14];
ydescr=[4,10];
xint_arg={{xdescr}};
yint_arg={{ydescr}};
xyint_arg={{xdescr,ydescr}};

% Create arguments for output
clear tmp; tmp.val=0; tmp.err=0;
w2x_sim =repmat(IX_dataset_1d,numel(w2ref),numel(xint_arg));
w2y_sim =repmat(IX_dataset_1d,numel(w2ref),numel(xint_arg));
w2xy_sim=repmat(tmp,numel(w2ref),numel(xint_arg));
w2x_mex =repmat(IX_dataset_1d,numel(w2ref),numel(xint_arg));
w2y_mex =repmat(IX_dataset_1d,numel(w2ref),numel(xint_arg));
w2xy_mex=repmat(tmp,numel(w2ref),numel(xint_arg));
w2x =repmat(IX_dataset_1d,numel(w2ref),numel(xint_arg));
w2y =repmat(IX_dataset_1d,numel(w2ref),numel(xint_arg));
w2xy=repmat(tmp,numel(w2ref),numel(xint_arg));

% Set tolerance
tol=-1e-13;

% Test integrate_x
% ------------
if log_level>0
    disp('===========================')
    disp('    2D: Test integrate_x')
    disp('===========================')
end
for j=1:numel(xint_arg)
    if log_level>0;disp(['=== ',num2str(j),' ===']);end
    for i=1:numel(w2ref)
        if log_level>0;disp(['= ',num2str(i)]);end
        
        hc.use_mex = false;
        w2x_sim(i,j)=simple_integrate_x(w2ref(i),xint_arg{j}{:});
        w2x(i,j)=integrate_x(w2ref(i),xint_arg{j}{:});
        delta_IX_dataset_nd(w2x_sim(i,j),w2x(i,j),tol)
        
        if test_mex
            hc.use_mex = true;
            w2x_mex(i,j)=integrate_x(w2ref(i),xint_arg{j}{:});
            delta_IX_dataset_nd(w2x_sim(i,j),w2x_mex(i,j),tol)
        end
    end
end


% Test integrate_y
% ------------
if log_level>0
    disp('===========================')
    disp('    2D: Test integrate_y')
    disp('===========================')
end
for j=1:numel(yint_arg)
    if log_level>0;    disp(['=== ',num2str(j),' ===']); end
    for i=1:numel(w2ref)
        if log_level>0; disp(['= ',num2str(i)]); end
        hc.use_mex = false;
        w2y_sim(i,j)=simple_integrate_y(w2ref(i),yint_arg{j}{:});
        w2y(i,j)=integrate_y(w2ref(i),yint_arg{j}{:});
        delta_IX_dataset_nd(w2y_sim(i,j),w2y(i,j),tol)
        
        if test_mex
            hc.use_mex = true;
            w2y_mex(i,j)=integrate_y(w2ref(i),yint_arg{j}{:});
            delta_IX_dataset_nd(w2y_sim(i,j),w2y_mex(i,j),tol)
        end
        
    end
end


% Test integrate
% ------------
disp('===========================')
disp('    2D: Test integrate')
disp('===========================')
for j=1:numel(xyint_arg)
    if log_level>0; disp(['=== ',num2str(j),' ===']); end
    for i=1:numel(w2ref)
        if log_level>0; disp(['= ',num2str(i)]); end
        
        hc.use_mex = false;
        w2xy_sim(i,j)=simple_integrate(w2ref(i),xyint_arg{j}{:});
        w2xy(i,j)=integrate(w2ref(i),xyint_arg{j}{:});
        delta_IX_dataset_nd(w2xy_sim(i,j),w2xy(i,j),tol)
        
        if test_mex
            hc.use_mex = true;
            w2xy_mex(i,j)=integrate(w2ref(i),xyint_arg{j}{:});
            delta_IX_dataset_nd(w2xy_sim(i,j),w2xy_mex(i,j),tol)
        end
    end
end
if log_level>0
    disp(' ')
    disp('Done')
    disp(' ')
end



%% =====================================================================================================================
% Test 3D integration
% ======================================================================================================================
clear('w3x_sim','w3y_sim','w3z_sim','w3xyz_sim','w3x_mex','w3y_mex','w3z_max','w3xyz_mex','w3x','w3y','w3z','w3xyz')
if log_level>0
    disp('===========================')
    disp('    3D: Test integrate')
    disp('===========================')
end
tol=-1e-13;



hc.use_mex = false;
w3x_sim=simple_integrate_x(ppp1,[5,10]);
w3y_sim=simple_integrate_y(ppp1,[5,10]);
w3z_sim=simple_integrate_z(ppp1,[5,10]);
w3xyz_sim=simple_integrate(ppp1,[9,15],[6,11],[3,5]);


hc.use_mex = false;
w3x=integrate_x(ppp1,[5,10]);
w3y=integrate_y(ppp1,[5,10]);
w3z=integrate_z(ppp1,[5,10]);
w3xyz=integrate(ppp1,[9,15],[6,11],[3,5]);
delta_IX_dataset_nd(w3x_sim,w3x,tol)
delta_IX_dataset_nd(w3y_sim,w3y,tol)
delta_IX_dataset_nd(w3z_sim,w3z,tol)
delta_IX_dataset_nd(w3xyz_sim,w3xyz,tol)


if test_mex
    hc.use_mex = true;
    w3x_mex=integrate_x(ppp1,[5,10]);
    w3y_mex=integrate_y(ppp1,[5,10]);
    w3z_mex=integrate_z(ppp1,[5,10]);
    w3xyz_mex=integrate(ppp1,[9,15],[6,11],[3,5]);
    delta_IX_dataset_nd(w3x_sim,w3x_mex,tol)
    delta_IX_dataset_nd(w3y_sim,w3y_mex,tol)
    delta_IX_dataset_nd(w3z_sim,w3z_mex,tol)
    delta_IX_dataset_nd(w3xyz_sim,w3xyz_mex,tol)
end

if log_level>0
    disp(' ')
    disp('Done')
    disp(' ')
end

%% =====================================================================================================================
% Compare with saved output
% ======================================================================================================================
if ~save_output
    if log_level>0
        disp('====================================')
        disp('    Comparing with saved output')
        disp('====================================')
    end
    output_file=fullfile(rootpath,results_filename);
    old=load(output_file);
    nam=fieldnames(old);
    tol=-1.0e-13;
    for i=1:numel(nam)
        fld = nam{i};
        if ~test_mex
            len = length(fld);
            if strncmpi(fld(len-2:len),'mex',3)
                continue
            end
        end
        if isstruct(old.(fld)) && isa(eval(fld),'IX_dataset_1d')
            old.(fld) = IX_dataset_1d(old.(fld));
        end
        [ok,mess]=equal_to_tol(eval(fld),  old.(fld), tol);
        assertTrue(ok,['[',nam{i},']',mess]);
    end
    if log_level>0
        % Success announcement
        banner_to_screen([mfilename,': Test(s) passed (matches are within requested tolerances)'],'bot')
    end
end


%% =====================================================================================================================
% Save data
% ======================================================================================================================
if save_output
    disp('===========================')
    disp('    Save output')
    disp('===========================')
    
    output_file=fullfile(tempdir,results_filename);
    save(output_file,'ih1_mex','ih1b_mex','ip1_mex','ip1b_mex','ihpa_mex','ihpb_mex','ihpc_mex',...
        'ih1',    'ih1b',    'ip1',    'ip1b',    'ihpa',    'ihpb',    'ihpc',...
        'w2x_sim','w2y_sim','w2xy_sim','w2x_mex','w2y_mex','w2xy_mex','w2x','w2y','w2xy',...
        'w3x_sim','w3y_sim','w3z_sim','w3xyz_sim','w3x_mex','w3y_mex','w3z_mex','w3xyz_mex','w3x','w3y','w3z','w3xyz')
    
    disp(' ')
    disp(['Output saved to ',output_file])
    disp(' ')
end
