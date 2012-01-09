function aaa_generate_rebin_cut_integrate
% Create rebin, cut and integrate functions for all IX_dataset_nd types
%
%   >> rebin_cut_integrate_generator
%
% Run from the folder that contains this utility function

dir_1d='../@IX_dataset_1d';
dir_2d='../@IX_dataset_2d';
dir_3d='../@IX_dataset_3d';

% Construct list of files and substitutions:
template_file{1}='rebin_template.txt';
template_file{2}='rebin2_template.txt';
template_file{3}='integrate_template.txt';
template_file{4}='integrate2_template.txt';
template_file{5}='cut_template.txt';

output_file{1}={fullfile(dir_1d,'rebin.m'),...
                fullfile(dir_2d,'rebin.m'),...
                fullfile(dir_2d,'rebin_x.m'),...
                fullfile(dir_2d,'rebin_y.m'),...
                fullfile(dir_3d,'rebin.m'),...
                fullfile(dir_3d,'rebin_x.m'),...
                fullfile(dir_3d,'rebin_y.m'),...
                fullfile(dir_3d,'rebin_z.m'),...
                };

output_file{2}={fullfile(dir_1d,'rebin2.m'),...
                fullfile(dir_2d,'rebin2.m'),...
                fullfile(dir_2d,'rebin2_x.m'),...
                fullfile(dir_2d,'rebin2_y.m'),...
                fullfile(dir_3d,'rebin2.m'),...
                fullfile(dir_3d,'rebin2_x.m'),...
                fullfile(dir_3d,'rebin2_y.m'),...
                fullfile(dir_3d,'rebin2_z.m'),...
                };

output_file{3}={fullfile(dir_1d,'integrate.m'),...
                fullfile(dir_2d,'integrate.m'),...
                fullfile(dir_2d,'integrate_x.m'),...
                fullfile(dir_2d,'integrate_y.m'),...
                fullfile(dir_3d,'integrate.m'),...
                fullfile(dir_3d,'integrate_x.m'),...
                fullfile(dir_3d,'integrate_y.m'),...
                fullfile(dir_3d,'integrate_z.m'),...
                };
            
output_file{4}={fullfile(dir_1d,'integrate2.m'),...
                fullfile(dir_2d,'integrate2.m'),...
                fullfile(dir_2d,'integrate2_x.m'),...
                fullfile(dir_2d,'integrate2_y.m'),...
                fullfile(dir_3d,'integrate2.m'),...
                fullfile(dir_3d,'integrate2_x.m'),...
                fullfile(dir_3d,'integrate2_y.m'),...
                fullfile(dir_3d,'integrate2_z.m'),...
                };

output_file{5}={fullfile(dir_1d,'cut.m'),...
                fullfile(dir_2d,'cut.m'),...
                fullfile(dir_2d,'cut_x.m'),...
                fullfile(dir_2d,'cut_y.m'),...
                fullfile(dir_3d,'cut.m'),...
                fullfile(dir_3d,'cut_x.m'),...
                fullfile(dir_3d,'cut_y.m'),...
                fullfile(dir_3d,'cut_z.m'),...
                };

substr_in={'$FUNC_NAME','$FUNC_MIRROR','$IX_DATASET_ND','$AXIS','$DESCR','$ONE_PER_AXIS','$CONTINUATION',...
           '$IAX_VAL','$EMPTY_FLAG','$RANGE_FLAG','$ARRAY_FLAG','$BIN_FLAG'};
       
rebin_descr_opt     ={'false', 'false', 'true',  'true' };
rebin2_descr_opt    ={'false', 'true',  'false', 'true' };
integrate_descr_opt ={'true',  'true',  'true',  'true' };
integrate2_descr_opt={'true',  'true',  'false', 'true' };
cut_descr_opt       ={'false', 'true',  'true',  'false'};

substr_out{1}={[{'rebin',  'rebin2',  'IX_dataset_1d','x-axis','descr','',''},{'1'},rebin_descr_opt],...
               [{'rebin',  'rebin2',  'IX_dataset_2d','x- and y-axes','descr_x, descr_y','(one per axis)',',...'},{'[1,2]'},rebin_descr_opt],...
               [{'rebin_x','rebin2_x','IX_dataset_2d','x-axis','descr','',''},{'1'},rebin_descr_opt],...
               [{'rebin_y','rebin2_y','IX_dataset_2d','y-axis','descr','',''},{'2'},rebin_descr_opt],...
               [{'rebin',  'rebin2',  'IX_dataset_3d','x-,y- and z-axes','descr_x, descr_y, descr_z','(one per axis)',',...'},{'[1,2,3]'},rebin_descr_opt],...
               [{'rebin_x','rebin2_x','IX_dataset_3d','x-axis','descr','',''},{'1'},rebin_descr_opt],...
               [{'rebin_y','rebin2_y','IX_dataset_3d','y-axis','descr','',''},{'2'},rebin_descr_opt],...
               [{'rebin_z','rebin2_z','IX_dataset_3d','z-axis','descr','',''},{'3'},rebin_descr_opt],...
              };
substr_out{2}={[{'rebin2',  'rebin',  'IX_dataset_1d','x-axis','descr','',''},{'1'},rebin2_descr_opt],...
               [{'rebin2',  'rebin',  'IX_dataset_2d','x- and y-axes','descr_x, descr_y','(one per axis)',',...'},{'[1,2]'},rebin2_descr_opt],...
               [{'rebin2_x','rebin_x','IX_dataset_2d','x-axis','descr','',''},{'1'},rebin2_descr_opt],...
               [{'rebin2_y','rebin_y','IX_dataset_2d','y-axis','descr','',''},{'2'},rebin2_descr_opt],...
               [{'rebin2',  'rebin',  'IX_dataset_3d','x-,y- and z-axes','descr_x, descr_y, descr_z','(one per axis)',',...'},{'[1,2,3]'},rebin2_descr_opt],...
               [{'rebin2_x','rebin_x','IX_dataset_3d','x-axis','descr','',''},{'1'},rebin2_descr_opt],...
               [{'rebin2_y','rebin_y','IX_dataset_3d','y-axis','descr','',''},{'2'},rebin2_descr_opt],...
               [{'rebin2_z','rebin_z','IX_dataset_3d','z-axis','descr','',''},{'3'},rebin2_descr_opt],...
              };
substr_out{3}={[{'integrate',  'integrate2',  'IX_dataset_1d','x-axis','descr','',''},{'1'},integrate_descr_opt],...
               [{'integrate',  'integrate2',  'IX_dataset_2d','x- and y-axes','descr_x, descr_y','(one per axis)',',...'},{'[1,2]'},integrate_descr_opt],...
               [{'integrate_x','integrate2_x','IX_dataset_2d','x-axis','descr','',''},{'1'},integrate_descr_opt],...
               [{'integrate_y','integrate2_y','IX_dataset_2d','y-axis','descr','',''},{'2'},integrate_descr_opt],...
               [{'integrate',  'integrate2',  'IX_dataset_3d','x-,y- and z-axes','descr_x, descr_y, descr_z','(one per axis)',',...'},{'[1,2,3]'},integrate_descr_opt],...
               [{'integrate_x','integrate2_x','IX_dataset_3d','x-axis','descr','',''},{'1'},integrate_descr_opt],...
               [{'integrate_y','integrate2_y','IX_dataset_3d','y-axis','descr','',''},{'2'},integrate_descr_opt],...
               [{'integrate_z','integrate2_z','IX_dataset_3d','z-axis','descr','',''},{'3'},integrate_descr_opt],...
              };
substr_out{4}={[{'integrate2',  'integrate',  'IX_dataset_1d','x-axis','descr','',''},{'1'},integrate2_descr_opt],...
               [{'integrate2',  'integrate',  'IX_dataset_2d','x- and y-axes','descr_x, descr_y','(one per axis)',',...'},{'[1,2]'},integrate2_descr_opt],...
               [{'integrate2_x','integrate_x','IX_dataset_2d','x-axis','descr','',''},{'1'},integrate2_descr_opt],...
               [{'integrate2_y','integrate_y','IX_dataset_2d','y-axis','descr','',''},{'2'},integrate2_descr_opt],...
               [{'integrate2',  'integrate',  'IX_dataset_3d','x-,y- and z-axes','descr_x, descr_y, descr_z','(one per axis)',',...'},{'[1,2,3]'},integrate2_descr_opt],...
               [{'integrate2_x','integrate_x','IX_dataset_3d','x-axis','descr','',''},{'1'},integrate2_descr_opt],...
               [{'integrate2_y','integrate_y','IX_dataset_3d','y-axis','descr','',''},{'2'},integrate2_descr_opt],...
               [{'integrate2_z','integrate_z','IX_dataset_3d','z-axis','descr','',''},{'3'},integrate2_descr_opt],...
              };
substr_out{5}={[{'cut',  'cut2',  'IX_dataset_1d','x-axis','descr','',''},{'1'},cut_descr_opt],...
               [{'cut',  'cut2',  'IX_dataset_2d','x- and y-axes','descr_x, descr_y','(one per axis)',',...'},{'[1,2]'},cut_descr_opt],...
               [{'cut_x','cut2_x','IX_dataset_2d','x-axis','descr','',''},{'1'},cut_descr_opt],...
               [{'cut_y','cut2_y','IX_dataset_2d','y-axis','descr','',''},{'2'},cut_descr_opt],...
               [{'cut',  'cut2',  'IX_dataset_3d','x-,y- and z-axes','descr_x, descr_y, descr_z','(one per axis)',',...'},{'[1,2,3]'},cut_descr_opt],...
               [{'cut_x','cut2_x','IX_dataset_3d','x-axis','descr','',''},{'1'},cut_descr_opt],...
               [{'cut_y','cut2_y','IX_dataset_3d','y-axis','descr','',''},{'2'},cut_descr_opt],...
               [{'cut_z','cut2_z','IX_dataset_3d','z-axis','descr','',''},{'3'},cut_descr_opt],...
              };


% Generate code
for i=1:numel(template_file)
    aaa_generate_mcode_from_template (template_file{i}, output_file{i}, substr_in, substr_out{i})
end
