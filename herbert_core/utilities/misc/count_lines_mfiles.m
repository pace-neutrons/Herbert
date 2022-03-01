function report=count_lines_mfiles(varargin)
% Count number of lines and characters in .m files in a file or directory
%
% In a file:
%   >> report = count_lines_mfiles (filename)   % In named file
%
% In all files in a directory:
%   >> report = count_lines_mfiles              % All files in current directory
%   >> report = count_lines_mfiles ('-all')     % Recursively through all
%                                               % sub-directories too
%   >> report = count_lines_mfiles (dirname)    % Named directory
%   >> report = count_lines_mfiles (dirname,'-all')
%
% Skips folders with name '.', '.. , '.svn', '.git*'

% T.G.Perring   10 August 2007  Original
%               20 August 2011  Modified
%               10 July 2021    Tidied and added single file functionality

% Parse input
opt.default = 'dashprefix_noneg';
keyval_default.all = false;
flags = {'all'};
[par,keyval] = parse_arguments (varargin, 0, 1, keyval_default, flags, opt);

% Count lines
if numel(par)==0
    report = count_lines_mfiles_private (pwd, [], keyval.all);
    
elseif numel(par)==1
    name = par{1};
    if is_folder(name)
        report = count_lines_mfiles_private (name, [], keyval.all);
        
    elseif is_file(name)
        report = count_lines_mfile_private (name);
    else
        error('HERBERT:count_lines_mfiles:invalid_argument',...
            'Input argument is not an extant folder or file')
    end
else
    error('HERBERT:count_lines_mfiles:invalid_argument',...
        'Input argument must be an extant folder, file, or empty(==current folder)')
end


%--------------------------------------------------------------------------
function report = count_lines_mfiles_private (folder, report, recurse)
% Count lines in all m-files in a folder and accumulate in a report

if recurse
    sub_folders = dir_name_list(folder,'', '.;..;.svn;.git*');  % skip svn and git folders
    for i = 1:numel(sub_folders)
        name = fullfile(folder, sub_folders{i});
        report = count_lines_mfiles_private(name, report, recurse); % recurse down
    end
end
files = dir(fullfile(folder, '*.m'));
disp(folder)
for i = 1:length(files)
    filename = fullfile(folder, files(i).name);
    tmp = count_lines_mfile_private (filename);
    if ~isempty(report)
        report.nfile = report.nfile + tmp.nfile;
        report.nline = report.nline + tmp.nline;
        report.ncodeline = report.ncodeline + tmp.ncodeline;
        report.ncommline = report.ncommline + tmp.ncommline;
        report.nblankline = report.nblankline + tmp.nblankline;
        report.nchar = report.nchar + tmp.nchar;
        report.bytes = report.bytes + tmp.bytes;
    else
        report = tmp;
    end
end


%--------------------------------------------------------------------------
function report = count_lines_mfile_private (filename)
% Count lines in an m-file and return a report
%
%   >> report = count_lines_mfiles_private (filename)
%
% Input:
% ------
%   filename    File name
%
% Output:
% -------
%   report      Structure with various items of information
%                   nline       number of lines
%                   ncodeline   number of lines of m-code
%                   ncommline   number of comment lines
%                   nblankline  number of lines with just white space
%                   nchar       number of characters
%                   bytes       number of bytes


nline = 0;
ncodeline = 0;
ncommline = 0;
nblankline = 0;
nchar= 0;

fid = fopen(filename,'rt');
if fid<0
    disp(['Cannot open: ',filename])
    report = struct([]);
else
    while true
        tline = fgetl(fid);
        if (~isa(tline,'numeric'))
            nline = nline + 1;
            strline = strtrim(tline);
            if ~isempty(strline)
                if strline(1:1)~='%'
                    ncodeline = ncodeline + 1;
                else
                    ncommline = ncommline + 1;
                end
            else
                nblankline = nblankline + 1;
            end
            nchar = nchar + numel(strline);
        else
            break
        end
    end
    fseek(fid, 0, 'eof');
    bytes = ftell(fid);
    fclose(fid);
    report = struct('nfile', 1, 'nline', nline, 'ncodeline', ncodeline,...
        'ncommline', ncommline, 'nblankline', nblankline, 'nchar', nchar,...
        'bytes', bytes);
end
