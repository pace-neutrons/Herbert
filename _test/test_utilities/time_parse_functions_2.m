function time_parse_functions_2(nloop)
% Time and test equivalence of parse_arguments and parse_arguments_simple
%
%   >> time_parse_functions_2           % Default 5000 loops
%   >> time_parse_functions_2 (nloop)


ncompare = 100;
if nargin==0
    nloop=5000;  % default value
end


keynames  = {'name','newplot','type', 'normalise', 'modulate', 'files'};
defaults = {'',     1,       'd',    300,          0, {'bob.txt', 'bert.txt'}};
isflag  = [0, 1, 0, 0, 1, 0];

argpars = {[13,14], 'hello', 'missus', true, {'Big', 'Fella', [44,33,22]}};
argkey = {[11,12,13,14], 'zoot', rand(4,3), 'suit', {'Hearty', 'broth'}, true, false};
             

tmp = make_row([keynames; repmat({[]}, 1, numel(keynames))]);
keyword_empty = struct(tmp{:});
for i=1:numel(keynames)
    keydef.(keynames{i}) = defaults{i};
end
flags = keynames(logical(isflag));

% Fill array of arguments to test parsing functions
disp('Creating some test input arguments...')
argcell=cell(1,nloop);             

nkey = numel(keynames);
for i=1:nloop
    % Random choice of parameters
    par_sel = logical(round(rand(size(argpars))));
    val_par_sel = argpars(par_sel);
    perm = randperm(numel(val_par_sel));
    val_par_sel = val_par_sel(perm);    % randomise
    
    % Random selection of keywords
    key_sel = logical(round(rand(size(keynames))));
    keynames_sel = keynames(key_sel);
    val_key_sel = cell(1, sum(key_sel));
    flag_sel = logical(isflag(key_sel));
    val_key_sel(flag_sel) = num2cell(round(rand(1,sum(flag_sel))));
    val_key_sel(~flag_sel) = argkey(randperm(nkey,sum(~flag_sel)));
    
    perm = randperm(numel(val_key_sel));
    val_key_sel = val_key_sel(perm);    % randomise
    keynames_sel = keynames_sel(perm);
    
    % Make argument list to parse
    argkey_sel = make_row([keynames_sel; val_key_sel]);
    argcell{i} = [val_par_sel, argkey_sel];
end
disp(' ')


% Check equivalent out from parse_arguments and parse_arguments_simple
% -----------------------------------------------------------------
disp('Check equivalence of parse_arguments and parse_arguments_simple')
for i=1:min(ncompare,nloop)
    [par, keyword, present] = parse_arguments (argcell{i}, keydef, flags);
    [par_simple, keyval_simple, present_simple] = parse_arguments_simple...
        (keynames, isflag, defaults, argcell{i});
    keyword_simple = keyword_empty;
    for j=1:numel(keynames)
        keyword_simple.(keynames{j}) = keyval_simple{j};
    end
    present = cell2mat(struct2cell(present))';
    if ~isequal(par,par_simple) || ~isequal(keyword,keyword_simple) ||...
            ~isequal(present,present_simple)
        error('parse_arguments and parse_arguments_simple give different results')
    end
end
disp(' ')


% Test relative speed of parse_arguments and parse_arguments_simple
% -----------------------------------------------------------------
n = 0;

% -----------------------------------------------------------------
disp('Parse_arguments')
tic
for i=1:nloop
    [par, keyword, present] = parse_arguments (argcell{i}, keydef, flags);
    n=n+numel(par)+numel(keyword)+numel(present);
end
t=toc;
disp(['     Time per function call (microseconds): ',num2str(1e6*t/nloop)]);
disp(' ')


% -----------------------------------------------------------------
disp('Parse_arguments_simple')
tic
for i=1:nloop
    [par, keyval, present] = parse_arguments_simple...
        (keynames, isflag, defaults, argcell{i});
    n=n+numel(par)+numel(keyval)+numel(present);
end
t=toc;
disp(['     Time per function call (microseconds): ',num2str(1e6*t/nloop)]);
disp(' ')


% -----------------------------------------------------------------
if n==2^45
    disp('Whoopee! (a message to prevent clever optimization by Matlab)')
end
