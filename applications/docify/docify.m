function varargout=docify(varargin)
% Insert documentation constructed from meta documentation
%
% Acting on folder contents:
%   >> docify ()                % For all m files in current folder
%   >> docify (dirname)         % For all m files in named folder
%   >> docify (...'-recursive') % Include subfolders as well
%   >> docify (...'-key',val)   % Only files that contain one of the strings
%                               % in val on the <#doc_beg:> line (Here val is
%                               % a character string or cell array of strings)
% Acting on a single file:
%   >> docify (file_in)             % insert documentation and replace file
%   >> docify (file_in, file_out)   % insert documentation and write to new file
%   >> docify (...,'-key',val)      % Only if the file contains one of the keywords
%
% Reporting result of parsing to the screen and/or output
%   >> docify (...,'-list',n,...)
% 	        n=1 [Default] List changed files only, or if error (with full traceback)
%           n=2 list all checked files, and any errors (with full traceback)
%   >> report = docify (...,'-list',n,...)
%           n=1  or n=2 : Print to screen and return report
%           n=-1 or n=-2: Suppress output to screen
%
%
%
%
% Format of meta documentation
% ----------------------------
% Immediately following the definition lines starting with 'classdef',
% 'properties', 'methods' or 'function', the parser skips over leading comment
% lines, that is, a contiguous set of lines beginning with '%' until a meta
% documentation block is found, as defined below. If one or more such blocks
% are found, the leading comment lines before the first meta documentation
% block will be replaced by documentation constructed from the meta
% documentation blocks that follow.
%
% A meta documentation block is a set of comment lines before any executable
% code with the form:
%   % <#doc_beg:>
%   %   :
%   % <#doc_end:>
%
% or, more generally:
%
%   % <#doc_def:>
%   %   :
%   % <#doc_beg:>
%   %   :
%   % <#doc_end:>
%
% which contain argument definitions, conditional blocks of documentation,
% further files of meta documentation to be read etc. from which the actual
% comment lines will be constructed. More than one such block can appear in
% the leading comment block; any comment lines between the blocks (or
% following the last block) are ignored when constructing the replacement
% comment lines ahead of the first meta documentation block.
%
% The optional section between <#doc_def:> and <#doc_beg:> will contain the
% values of substitution strings and/or values of logical flags that select
% comment blocks in the section between <#doc_beg:> and <#doc_end:>
%
% EXAMPLE: Simple use:
%   % <#doc_beg:>
%   % Evaluate derivative of input spectrum
%   %   >> y = deriv (w, mderiv)
%   % Input:
%   %   w       Input data:
%   % <#file:> data_type_description.txt
%   %   mderiv  Order of derivative (1,2,...)
%   % Output:
%   %   y       Same object type as input
%   %
%   % <#file:> further_notes.txt
%   % <#doc_end:>
%
% EXAMPLE: More complex use: define the substitution strings func_suffix
% and my_file, and define the block of comments titled 'main' as active
%   % <#doc_def:>
%   %   func_suffix = '_sqw'
%   %   main = 1
%   %   my_file = 'stuff.txt'
%   % <#doc_beg:>
%   %   This line will appear as the first comment
%   %   <#file:> c:\temp\comments.txt
%   %   <main:>
%   %   This line will be written if main=1 in the definition block
%   %   and so the following file of comments be also read:
%   %   <#file:> <my_file>
%   %   <main/end:>
%   % <#doc_end:>
%
% Notes:
% (1) Substitution strings and logical block selection are global. In the above
%   example:
%       - All occurences of <func_suffix> will be replaced by '_sqw' in the
%         files that are read in the main documentation block, in this case
%         c:\temp\comments.txt and stuff.txt (and any further files that they
%         in turn may call - see nesting below).
%       - All blocks <main:> ... <main_end:> in those files will be retained;
%         any other blocks will be ignored (unless their value is set to 1 as
%         well).
%
%
% - Any file that will be read is assumed to be a documentation file, which
%   means that it can only contain leading matlab comment lines and
%   meta-documentation blocks. No following lines are permitted.
%       - The <#doc_end:> is optional (it is assumed to be at the end of the
%         file, as this is the only place it can occur).
%       - The <#doc_beg:> is optional - if not given it is assumed to be at
%         the very beginning.
%
%
% (2) Documentation files can be nested. In the above example stuff.txt could
%   itself have lines like:
%       :
%   % <#file:> another_file.txt
%       :
%
%   or, if the variable my_extra_file has been defined as e.g. 'my_extra_stuff.txt'
%       :
%   % <#file:>  <my_extra_file>
%       :
%
%     The <#file:> keyword can also take a matlabe expression to be evaluated
%   e.g. if <my_dir> and <my_file> are appropriately defined
%       :
%   % <#file:>  fullfile('<my_dir>','<my_file>')
%       :
%
%     If a file 
%
%
% (3) Global substitution strings and logical block selection can be overidden
%   in a documentation file by defining their values at the top. For
%   example, if 'stuff.txt' is:
%
%       %   Never use variables with the name multifit<func_suffix>
%       %   as this will cause a crash, as explained below:
%       %   <#file:> 'warning.txt'
%
%   then the value of main within warning.txt could be overridden by instead
%   having:
%       % <#doc_def:>
%       %   main=0
%       % <#doc_beg:>
%       %   Never use variables with the name multifit<func_suffix>
%       %   as this will cause a crash, as explained below:
%       %   <#file:> 'warning.txt'
%
%   Another way of overiding a value is to pass as an argument: in the .m
%   file in which the meta documentation will be placed:
%       % <#doc_def:>
%       %    :
%       %   main = 1
%       %   my_file = fullfile('c:\temp\rubbish','stuff.txt')
%       %    :
%       % <#doc_beg:>
%       %   This line will appear as the first comment
%       %       :
%       %   <#file:> <my_file>  0
%       %       :
%       % <#doc_end:>
%
%   then stuff.txt could contain the lines:
%       % <#doc_def:>
%       %   main='#1'
%       % <#doc_beg:>
%       %   Never use variables with the name multifit<func_suffix>
%       %   as this will cause a crash, as explained below:
%       %   <#file:> warning.txt
%
%
% (4) Comment lines that are not meant to be part of the output documentation
%   can be inserted into the meta-documentation block if they are preceeded
%  `by <<- (Note: this cannot be confused with a substitution name, as these
%   must start with a alphabetical character)
%   EXAMPLE:
%       %   :
%       % <#doc_beg:>
%       %   <<---The main help
%       %   This line will appear as the first comment in the output help
%       %   <#file:> <my_file>
%       %   <<---The following is used only if special is true
%       %   <special_case:>
%       %       <#file:> <special_information_file>
%       %   <special_case/end:>
%       % <#doc_end:>
%
%
% (5) Except in the top level file, lines beginning with a keyword
%   e.g. <#doc_beg:> or <#file:> do not need to start with '%' - this is
%   purely optional. The same is true of block names. For example
%       % <#doc_def:>
%       %   main=0
%       % <#doc_beg:>
%       % A little bit of detail
%       % can be found elsewhere
%       %   <main:>
%       %   <#file:> rubbish.m
%       %   <main/end:>
%       % <#doc_end:>
%
%   is equivalent to:
%       <#doc_def:>
%       %   main=0
%       <#doc_beg:>
%       % A little bit of detail
%       % can be found elsewhere
%          <main:>
%          <#file:> rubbish.m
%          <main/end:>
%       <#doc_end:>
%
%    This does not apply to the top level file of course if it is to be
%    properly executable m-code.
%
%
% (6) A final form of substitution is permitted: if a substitution definition
%   is a cell array of strings then a line of the form of a single variable name
%       % <var_name>
%   or
%       <var_name>
%   will be substituted by that cell array of strings. Any strings in that
%   cell array that do not begin with '%' have '% ' added at the front.


% T.G.Perring   03 November 2016  Original version modified to work on directories


% Parse input
% ------------
keyval_def = struct('recursive',false,'key',{{}},'list',1,'display',true);
flagnames = {'recursive','display'};
opt=struct('prefix','-','prefix_req',true);
[pars,keyval] = parse_arguments (varargin, keyval_def, flagnames, opt);

if isempty(pars)
    span_directory = true;
    directory = pwd;
elseif numel(pars)==1 && ~isempty(pars{1}) && is_string(pars{1})
    if exist(pars{1},'dir')
        span_directory = true;
        directory = pars{1};
    elseif exist(pars{1},'file')
        span_directory = false;
        file_in = pars{1};
        file_out = '';
    else
        error('Check input is a file or folder')
    end
elseif numel(pars)==2 && ~isempty(pars{1}) && is_string(pars{1}) &&...
        ~isempty(pars{2}) && is_string(pars{2})
    span_directory = false;
    file_in = pars{1};
    file_out = pars{2};
else
    error('Check number of parameters and their values')
end
if isempty(keyval.key)
    keyval.key={};
elseif iscellstr(keyval.key)
    keyval.key=keyval.key(:)';
elseif is_string(keyval.key)
    keyval.key={keyval.key};
else
    error('Check value of keyword ''-key'' is a character string or a cell array of strings')
end

% Get verbosity of listing
nlist = keyval.list;
if isnumeric(nlist) && isscalar(nlist)
    nlist = abs(round(nlist));
    if nlist<0, nlist=0; elseif nlist>2, nlist=2; end
else
    nlist = 2;
end
keyval.list = nlist;


% Loop over all directories
% --------------------------
report = {};

if span_directory && keyval.recursive
    directories=dir_name_list(directory,'','.svn');    % skip svn work folders
    for i=1:numel(directories)
        sub_directory=directories{i};
        % ignore '.' and '..'
        if (strcmp(sub_directory,'.') || strcmp(sub_directory,'..'))
            continue;
        end
        % Recurse down
        full_directory=fullfile(directory,sub_directory);
        key_args = make_row([cellfun(@(x)['-',x],fieldnames(keyval)','UniformOutput',false);struct2cell(keyval)']);
        report={report;...
            docify(full_directory,key_args{:})};
    end
end

% Run function (recursion operates from the bottom of each branch)
% -----------------------------------------------------------------
if span_directory
    files = dir(fullfile(directory,'*.m'));
    for ifile = 1:length(files)
        fname = fullfile(directory,files(ifile).name);
        [ok,mess,file_full_in,changed] = docify_single(fname,'',keyval.key);
        report = [report;...
            make_report(ok,mess,file_full_in,changed,keyval.list,keyval.display)];
    end
else
    [ok,mess,file_full_in,changed] = docify_single(file_in,file_out,keyval.key);
    report = [report;...
        make_report(ok,mess,file_full_in,changed,keyval.list,keyval.display)];
end

if nargout>=1, varargout{1}=report; end


%-----------------------------------------------------------------------------------------
function report = make_report (ok, mess, file_full_in, changed, nlist, disp_to_screen)
% Create a report and print to screen as requested
% 	list    n=1 List changed files only, or if error (with full traceback)
%           n=2 list all checked files, and any errors (with full traceback)


report={};

% Create report
if nlist==0
    if ~ok
        report = [{['***ERROR: ',file_full_in]}; mess; {' '}];
    end
elseif nlist==1
    if ok && changed
        report = {file_full_in};
    elseif ~ok
        report = [{['***ERROR: ',file_full_in]}; mess; {' '}];
    end
else
    if ok
        if ~changed
            report = {['     ok: ',file_full_in]};
        else
            report = {['Changed: ',file_full_in]};
        end
    else
        report = [{['***ERROR: ',file_full_in]}; mess; {' '}];
    end
end

% Display to screen if n>0
if disp_to_screen
    for i=1:numel(report)
        if ~isempty(report{i}), disp(report{i}), end
    end
end
