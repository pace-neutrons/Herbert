function test_translate_read_write
% Test the utility that translates global paths in filenames
%
% Author: T.G.Perring

banner_to_screen(mfilename)

% Create folders for tests
% ------------------------
root_dir=tmp_dir;   % Get temporary folder location
dir0=fullfile(root_dir,'herbert_tests','herb_dir0');
dir1=fullfile(root_dir,'herbert_tests','herb_dir1');
dir2=fullfile(root_dir,'herbert_tests','herb_dir2');
dir3=fullfile(root_dir,'herbert_tests','herb_dir3');
file1='test_1.dat';
file2='test_2.dat';
file3='test_3.dat';
if is_folder(dir0), rmdir(dir0,'s'); end
if is_folder(dir1), rmdir(dir1,'s'); end
if is_folder(dir2), rmdir(dir2,'s'); end
if is_folder(dir3), rmdir(dir3,'s'); end
mkdir(dir1);
mkdir(dir2);
mkdir(dir3);
cleanup_obj=onCleanup(@()translate_read_write_cleanup(dir1,dir2,dir3,fullfile(root_dir,'herbert_tests')));

% Create ascii files
tmp=IX_dataset_1d(1:10,11:20,rand(1,10),'The title','Counts','Hours');
save_ascii(tmp,fullfile(dir1,file1));
tmp=IX_dataset_1d(1:10,11:20,rand(1,10),'The title','Counts','Hours');
save_ascii(tmp,fullfile(dir2,file2));
tmp=IX_dataset_1d(1:10,11:20,rand(1,10),'The title','Counts','Hours');
save_ascii(tmp,fullfile(dir3,file3));

% Create some global paths and environment variables
if existgpath('path_0'), delgpath('path_0'); end    % global path to dir0
if existgpath('path_0123'), delgpath('path_0123'); end    % global path to dir0, dir1, dir2, dir3
if existgpath('path_123'), delgpath('path_123'); end    % global path to dir1, dir2, dir3
if existgpath('path_1e3'), delgpath('path_1e3'); end    % global path to dir1, env vble, dir3
mkgpath('path_0',dir0)
mkgpath('path_0123',dir0,dir1,dir2,dir3)
mkgpath('path_123',dir1,dir2,dir3)
mkgpath('path_1e3',dir1,'herbert_env',dir3)
setenv('herbert_env',dir2)

if existgpath('path_31'), delgpath('path_31'); end      % global path to dir3, dir1
mkgpath('path_31',dir3,dir1)

if existgpath('path_e31'), delgpath('path_e31'); end    % global path to dir1, env vble, dir3
if existgpath('path_deep'), delgpath('path_deep'); end  % global path to dir1, env vble, dir3
mkgpath('path_e31','herbert_env',dir3,dir1)
mkgpath('path_deep',dir1,'herbert_env_top')
setenv('herbert_env_top','path_e31')

% Now perform some tests
% --------------------------
% Reading

[file_out,ok,mess]=translate_read(['path_123:::',file1]);
assertTrue(isequal(file_out,fullfile(dir1,file1)),['Error in translate_read ',mess])

[file_out,ok,mess]=translate_read(['path_123:::',file2]);
assertTrue(isequal(file_out,fullfile(dir2,file2)),'Error in translate_read')

[file_out,ok,mess]=translate_read(['path_123:::',file3]);
assertTrue(isequal(file_out,fullfile(dir3,file3)),'Error in translate_read')

[file_out,ok,mess]=translate_read(['path_123:::','nog.dat']);
assertFalse(ok,['Error in translate_read',mess]);

[file_out,ok,mess]=translate_read(['path_deep:',file2]);
assertTrue(isequal(file_out,fullfile(dir2,file2)),'Error in translate_read')

[file_out,ok,mess]=translate_read(['herbert_env:',file2]);
assertTrue(isequal(file_out,fullfile(dir2,file2)),'Error in translate_read')

[file_out,ok,mess]=translate_read(fullfile(dir2,file2));
assertTrue(isequal(file_out,fullfile(dir2,file2)),'Error in translate_read')

[file_out,ok,mess]=translate_read(['path_0:',file2]);
assertFalse(ok,'Error in translate_read')

% Writing
[file_out,ok,mess]=translate_write(['path_0123:::',file1]);
assertTrue(isequal(file_out,fullfile(dir1,file1)),['Error in translate_write',mess])

[file_out,ok,mess]=translate_write(['herbert_env:',file2]);
assertTrue(isequal(file_out,fullfile(dir2,file2)),'Error in translate_write')

[file_out,ok,mess]=translate_write(['path_deep:','crap.dat']);
assertTrue(isequal(file_out,fullfile(dir1,'crap.dat')),'Error in translate_write')

[file_out,ok,mess]=translate_write(['path_0:',file1]);
assertFalse(ok,'Error in translate_write -- created file on non-existent path')


% Success announcement
% --------------------
banner_to_screen([mfilename,': Test(s) passed'],'bot')

function translate_read_write_cleanup(varargin)

for i=1:nargin
    rmdir(varargin{i},'s');
end