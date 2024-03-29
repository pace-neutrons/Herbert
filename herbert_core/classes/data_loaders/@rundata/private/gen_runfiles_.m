function [runfiles,file_exist] = gen_runfiles_(name_of_class,spe_files,...
    varargin)
% Returns array of rundata objects created by the input arguments.
%
%   >> [runfiles_list,file_exist] = gen_runfiles(spe_file,[par_file],arg1,arg2,...)
%
% Input:
% ------
%   name_of_class   string with the name of the classes to generate.
%                   Classes should suppord rundata interface
%
%   spe_file       Full file name of any kind of supported "spe" file
%                  e.g. original ASCII spe file, nxspe file etc.
%                  Character string or cell array of character strings for
%                  more than one file
%^1 par_file       [Optional] full file name of detector parameter file
%                  i.e. Tobyfit format detector parameter file. Will override
%                  any detector inofmration in the "spe" files
%
% Addtional information can be included in the rundata objects, or override
% if the fields are in the rundata object as follows:
%
%^1 efix            Fixed energy (meV)   [scalar or vector length nfile] ^1
%   emode           Direct geometry=1, indirect geometry=2
%^1 lattice         The instance of oriented lattice object or
%                   array of such objects
%  instrument       the instance or array of instruments
%  sample           the instance or array of samples
%
% additional control keywords could modify the behaviour of the routine, namely:
%  -allow_missing   - if such keyword is present, routine allows
%                     some or all spe files to be missing. resulting
%                     rundata class would contain runfile with undefined
%                     loader. Par file(s) if provided, still have always be
%                     defined
% -check_validity   - if present, check if the generated runfiles are
%                     valid, i.e. can be used for transformation
%
%
% Output:
% -------
%   runfiles        Array of rundata objects
%   file_exist   boolean array  containing true for files which were found
%                   and false for which have been not. runfiles list
%                   would then contain members, which do not have loader
%                   defined. Missing files are allowed only if -allow_missing
%                   option is present as input
%
% Notes:
% ^1    This parameter is optional for some formats of spe files. If
%       provided, overides the information contained in the the "spe" file.

%
%
%
control_keys = {'-allow_missing','-check_validity'};
[ok,mess,allow_missing,check_validity,params]=parse_char_options(varargin,control_keys);
if ~ok
    error('HERBERT:rundata:invalid_argument',mess);
end

% Input files
% -----------
% Check spe files
if ischar(spe_files) &&  size(spe_files,1)==1
    spe_files=cellstr(spe_files);
elseif isempty(spe_files) && allow_missing
    spe_files = cell(1,1);
elseif ~(iscellstr(spe_files)||isstring(spe_files))
    if ~allow_missing && iscell(spe_files)
        error('HERBERT:rundata:invalid_argument',...
            'spe file input must be a single file name or cell array of file names')
    end
end

% Check if second parameter is a par file or list of par files and
% remove par_files variable from the list of input parameters;
if nargin>1
    parfile_is_det = false;
    if ischar(params{1}) && size(params{1},1)==1    % single par file provided as input
        par_files = params(1);    % cell array with one character array
    elseif iscellstr(params{1})   % list of par files provided
        par_files = params{1};
    elseif isempty(params{1})     % empty par file definition provided
        par_files = {};
    else
        [is,par_files] = isdetpar(params{1}); % will throw if array in wrong format
        if is % detector's structure or det array is provided
            parfile_is_det = true;
            par_files = {par_files};
        end
    end
    params = params(2:end);
else
    par_files = {};
end
% Check number of par files is one, no, or matches the number of spe files
if ~(numel(par_files)==1 || numel(par_files)==numel(spe_files) || numel(par_files) == 0)
    error('HERBERT:rundata:invalid_argument',...
        'par files list should be empty, have one par file or number of par files should be equal to the number of spe files');
end
% Check if all requested par files exist:
if ~parfile_is_det
    for i=1:numel(par_files)
        file=check_file_exist(par_files{i},{'.par','.nxspe'});
        if isempty(file)
            error('HERBERT:rundata:invalid_argument',...
                ' par file %s specified but can not be found',file);
        end
    end
end

% Remaining parameters names list:
parameter_nams={'efix','emode','lattice','instrument','sample'};
if numel(params)>2 && isnumeric(params{3}) && rem(numel(params{3}),3)==0 % old format call
    % instead of lattice, one have long row of the lattice and goniometer
    % parameters.
    is_present = cellfun(@(x)isa(x,'IX_inst')||isa(x,'IX_samp'),params);
    if any(is_present)
        inst_samp = params(is_present);
    else
        inst_samp = {};
    end
    params = params(~is_present);
    lat = convert_old_input_to_lat(params{3:end});
    params = [params(1:2),{lat},inst_samp];
end


% Check other parameters
% ----------------------
if numel(spe_files)==1 && isempty(spe_files{1})
    if numel(params)>0
        n_files = numel(params{1});
        spe_files = cell(1,n_files);
        spe_files = cellfun(@(x)'',spe_files,'UniformOutput',false);
    else
        n_files = 1;
    end
else
    n_files       = numel(spe_files);
end

n_dfnd_params = numel(params);
if n_dfnd_params>4 % sample provided
    default_sample = arrayfun(@(x)(isa(x,'IX_null_sample')),params{5});
    if all(default_sample) % ignore it. Default sample is already on rundata,
        % and was set from lattice. Setting it again will break rundata
        % TODO: merge IX_samp and oriented_lattice
        n_dfnd_params = 4;
        params = params(1:4);
        parameter_nams = parameter_nams(1:4);
    end
end
if n_dfnd_params>3 && isa(params{4},'IX_inst') % instrument provided
    default_inst = arrayfun(@(x)(isa(x,'IX_null_inst')),params{4});
    if all(default_inst) % some instrument may have already been set on rundata
        % so better to ignore them here. (not happens currently but let's do it for consistence)
        n_dfnd_params = n_dfnd_params - 1;
        params = [params(1:3),params(5:end)];
        parameter_nams = [parameter_nams(1:3),parameter_nams(5:end)];
    end
end

args=cell(1,n_dfnd_params);
emode = params{2};
emode = emode(1);
% let's try to establish if efix range is provided for indirect instrument
if emode == 2
    n_det_efix_guess = 1;
    e_fix = params{1};
    if numel(e_fix) > 1
        if size(e_fix,2) == n_files && size(e_fix,1) ~= n_files
            e_fix = e_fix';
            params{1} = e_fix;
        end
        n_det_efix_guess = size(e_fix,2);
    end
end

% Transform all arrays with one dimension of n_files into cell arrays
for i=1:n_dfnd_params
    val = params{i};
    name= parameter_nams{i};
    if emode == 2 && strcmpi(name,'efix')
        if n_det_efix_guess >1
            args{i} = spread_vector(val,n_files,n_det_efix_guess,parameter_nams{i});
        else
            args{i} = spread_scalar(val,n_files,parameter_nams{i});
        end
    else
        args{i} = spread_scalar(val,n_files,parameter_nams{i});
    end
end
if numel(args) < numel(parameter_nams)
    parameter_nams = parameter_nams(1:numel(args));
end
% Make structure array with parameter names as fields and args as values
struct_names_and_vals=[parameter_nams;args];
dfnd_params = struct(struct_names_and_vals{:});



% Create rundata objects
% ----------------------
runfiles  = cell(1,n_files);
for i=1:n_files
    runfiles{i} = feval(name_of_class);
end
%runfiles = cellfun(@()(feval(name_of_class)),runfiles,'UniformOutput',false);

file_exist = true(n_files,1);



% Do we build runfiles from one, multiple or no par files?
if isempty(par_files)
    for i=1:n_files
        [runfiles{i},file_exist(i)] = init_runfile_no_par(runfiles{i},...
            spe_files{i},dfnd_params(i),allow_missing);
    end
elseif numel(par_files)==1
    [runfiles{1},file_exist(1)]= init_runfile_with_par(runfiles{1},spe_files{1},...
        par_files{1},'',dfnd_params(1),allow_missing,parfile_is_det);
    if file_exist(1) &&  ~runfiles{1}.isvalid
        [ok,mess,runfiles{1}] = runfiles{1}.check_combo_arg();
        if ~ok; error('HERBERT:gen_runfiles:invalid_argument',mess)
        end
    end
    % Save time on multiple load of the same par into memory by reading it just once
    if n_files>1
        [par,runfiles{1}] = get_par(runfiles{1});
    end
    for i=2:n_files
        [runfiles{i},file_exist(i)]= init_runfile_with_par(runfiles{i},...
            spe_files{i},par_files{1},par,dfnd_params(i),allow_missing,parfile_is_det);
        if file_exist(i) && ~runfiles{i}.isvalid
            [ok,mess,runfiles{i}] = runfiles{i}.check_combo_arg();
            if ~ok
                error('HERBERT:gen_runfiles:invalid_argument',mess)
            end
        end
    end
else   % multiple par and spe files;
    for i=1:n_files
        [runfiles{i},file_exist(i)]= init_runfile_with_par(runfiles{i},...
            spe_files{i},par_files{i},'',dfnd_params(i),allow_missing,parfile_is_det);
        if file_exist(i) && ~runfiles{i}.isvalid
            [ok,mess,runfiles{i}] = runfiles{i}.check_combo_arg();
            if ~ok
                error('HERBERT:gen_runfiles:invalid_argument',mess)
            end
        end

    end
end

% Check if all information necessary to define the run is present
if check_validity
    for i=1:n_files
        if file_exist(i)
            if ~runfiles{i}.isvalid
                [ok,mess,runfiles{i}] = runfiles{i}.check_combo_arg();
                if ~ok
                    error('HERBERT:gen_runfiles:invalid_argument', ...
                        ' The run data for data file %s are not fully defined: %s', ...
                        runfiles{i}.data_file_name,mess);
                end
            end
        end
    end
end

function [runfile,file_found] = init_runfile_no_par(runfile,spe_file_name,param,allow_missing)
% init runfile in the case of no par file is present
file_found = true;
if allow_missing
    if check_file_exist(spe_file_name)
        runfile = runfile.init(spe_file_name,param);
    else
        file_found = false;
        par_fields = fieldnames(param);
        for i=1:numel(par_fields)
            field = par_fields{i};
            runfile.(field) = param.(field);
        end
    end
else
    runfile = runfile.init(spe_file_name,param);
end
%
function [runfile,file_found] = init_runfile_with_par(runfile,spe_file_name,...
    par_file,par_data,param,allow_missing,par_is_det)
% init runfile in the case of par file being present
file_found = true;
if allow_missing
    if check_file_exist(spe_file_name)
        if par_is_det
            runfile = runfile.init(spe_file_name,param);
            runfile.det_par = par_file;
        else
            runfile = runfile.init(spe_file_name,par_file,param);
        end
    else
        file_found = false;
        if par_is_det
            runfile.det_par = par_file;
        else
            runfile.par_file_name = par_file;
        end
        par_fields = fieldnames(param);
        for i=1:numel(par_fields)
            field = par_fields{i};
            runfile.(field) = param.(field);
        end
    end
else
    file_found = check_file_exist(spe_file_name);
    if par_is_det
        runfile = runfile.init(spe_file_name,param);
        runfile.det_par = par_file;
    else
        runfile = runfile.init(spe_file_name,par_file,param);
    end
end
%
if ~isempty(par_data)
    runfile.det_par = par_data;
end

function [is,input]=isdetpar(input)
if ~isstruct(input)
    if isnumeric(input) && isvector(input(:,1)) && isvector(input(:,2))
        % will throw if conversion is impossible
        input = get_hor_format(input,'mem_par_file');
        is = true;
        return
    else
        is = false;
    end
    return
end
detpar_fields = {'group','x2','phi','azim','width','height'};
fields = fieldnames(input);
if all(ismember(detpar_fields,fields))
    is = true;
else
    is = false;
end

function res = spread_scalar(val,n_files,name)
if numel(val)==n_files
    res=num2cell(val(:)');  % 1 x nfiles cell array
elseif numel(val)==1
    if isobject(val)
        res = num2cell(repmat(val,1,n_files));
    else
        res=num2cell(val*ones(1,n_files));  % 1 x nfiles cell array
    end
else
    error('HERBERT:gen_runfiles:invalid_argument',...
        'parameter %s must be a single value or a vector of %d values',name,n_files);
end

function res = spread_vector(val,n_files,n_components,name)
if numel(size(val))==2 && all(size(val)==[n_files,n_components])
    res=num2cell(val,2)';   % 1 x nfiles cell array
elseif numel(val)==n_components
    res=num2cell(repmat(val(:)',[n_files,1]),2)';   % 1 x nfiles cell array containing n_components vectors
else
    error('HERBERT:gen_runfiles:invalid_argument',...
        'parameter %s must be a %d-element vector or a [%d x %d] array of doubles',...
        name,n_components,n_files,n_components);
end

