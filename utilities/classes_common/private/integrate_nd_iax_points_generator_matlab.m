function integrate_nd_iax_points_generator_matlab(target_dir)
% Create integration functions for point data from template
%
%>> integrate_nd_iax_points_generator_matlab
%
% Inputs:
% target_dif -- if present, specifies the folder for target files to place
%               into. if the folder does not exist, it will be created
%
%
% Run from the folder that contains this utility function

% Construct list of files and substitutions:
template_file='integrate_nd_iax_points_template_matlab.m';

output_file={'integrate_1d_points_matlab.m',...
             'integrate_2d_x_points_matlab.m',...
             'integrate_2d_y_points_matlab.m',...
             'integrate_3d_x_points_matlab.m',...
             'integrate_3d_y_points_matlab.m',...
             'integrate_3d_z_points_matlab.m'};
if nargin>0
    if ~exist(target_dir,'dir')
        mkdir(target_dir);
    end
    for i=1:numel(output_file)
        output_file{i}=fullfile(target_dir,output_file{i});
    end
end         

substr_in={'integrate_nd_iax_points_template_matlab','iax=1','ndim=2','(ib,:)','(ilo,:)','(ihi,:)',...
    '(ml-1,:)','(ml,:)','(mu,:)','(mu+1,:)','(ml:mu-1,:)','(ml+1:mu-1,:)','(ml+1:mu,:)'};

substr_out{1}={'integrate_1d_points_matlab',  'iax=1','ndim=1','(ib)','(ilo)',    '(ihi)',...
    '(ml-1)','(ml)','(mu)','(mu+1)','(ml:mu-1)','(ml+1:mu-1)','(ml+1:mu)'};

substr_out{2}={'integrate_2d_x_points_matlab','iax=1','ndim=2','(ib,:)','(ilo,:)',  '(ihi,:)',...
    '(ml-1,:)','(ml,:)','(mu,:)','(mu+1,:)','(ml:mu-1,:)','(ml+1:mu-1,:)','(ml+1:mu,:)'};

substr_out{3}={'integrate_2d_y_points_matlab','iax=2','ndim=2','(:,ib)','(:,ilo)',  '(:,ihi)',...
    '(:,ml-1)','(:,ml)','(:,mu)','(:,mu+1)','(:,ml:mu-1)','(:,ml+1:mu-1)','(:,ml+1:mu)'};

substr_out{4}={'integrate_3d_x_points_matlab','iax=1','ndim=3','(ib,:,:)','(ilo,:,:)','(ihi,:,:)',...
    '(ml-1,:,:)','(ml,:,:)','(mu,:,:)','(mu+1,:,:)','(ml:mu-1,:,:)','(ml+1:mu-1,:,:)','(ml+1:mu,:,:)'};

substr_out{5}={'integrate_3d_y_points_matlab','iax=2','ndim=3','(:,ib,:)','(:,ilo,:)','(:,ihi,:)',...
    '(:,ml-1,:)','(:,ml,:)','(:,mu,:)','(:,mu+1,:)','(:,ml:mu-1,:)','(:,ml+1:mu-1,:)','(:,ml+1:mu,:)'};

substr_out{6}={'integrate_3d_z_points_matlab','iax=3','ndim=3','(:,:,ib)','(:,:,ilo)','(:,:,ihi)',...
    '(:,:,ml-1)','(:,:,ml)','(:,:,mu)','(:,:,mu+1)','(:,:,ml:mu-1)','(:,:,ml+1:mu-1)','(:,:,ml+1:mu)'};

% Generate code
aaa_generate_mcode_from_template (template_file, output_file, substr_in, substr_out)
