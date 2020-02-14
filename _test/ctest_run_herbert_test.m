function result = ctest_run_herbert_test(test, varargin)
% Execute `runtests` with the given directory
%
%  >> run_herbert_test(test, [kwarg1, value1, kwarg2, value2...])
%
% Positional parameters:
%
%   test  The directory/test case to pass to the `runtests` call
%
% Keyword parameters:
%
%   'config_dir'  The directory to store the herbert config file within.
%
%   'shared_local_dir'  The shared local directory for parallel workers
%
%   'shared_remote_dir'  The shared remote directory for parallel workers
%
%   'parallel_working_dir'  The working directory for parallel workers
%

% Parse input parameters
ip = inputParser;
addRequired(ip, 'test');
addParameter(ip, 'config_dir', '');
addParameter(ip, 'shared_local_dir', '');
addParameter(ip, 'shared_remote_dir', '');
addParameter(ip, 'parallel_working_dir', '');
parse(ip, test, varargin{:});
config_dir = ip.Results.config_dir;
shared_local_dir = ip.Results.shared_local_dir;
shared_remote_dir = ip.Results.shared_remote_dir;

if isempty(which('herbert_init'))
    herbert_on;
end

% Move config directory to specified location
if config_dir
    config_store.set_config_folder(config_dir);
end
config_man = opt_config_manager;
config_man.this_pc_type = 'jenkins';
config_man.load_configuration('-set_config', '-change_only_default');

pc = parallel_config;
if shared_local_dir
    pc.shared_folder_on_local = shared_local_dir;
end
if shared_remote_dir
    pc.shared_folder_on_remote = shared_remote_dir;
end

result = runtests(test);
