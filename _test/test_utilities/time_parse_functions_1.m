function time_parse_functions_1(nloop)
% Time some parsing functions
%
%   >> time_parse_functions_1           % Default 5000 loops
%   >> time_parse_functions_1 (nloop)


if nargin==0
    nloop=5000;  % default value
end


inpars={[13,14],'hello','missus',true};
argname={'name','newplot','type'};
argdef={'',true,'d'};
arglist = struct('name','',...
    'newplot',true,...
    'type','d');
argflag={};
logflag=[false,false,false];
argvals={[11,12,13,14],'zoot',rand(4,3),true,false,'suit'};
             
% Fill array of arguments to test parsing functions
disp('Creating some test input arguments...')
argcell=cell(1,nloop);             
argcell_key=cell(1,nloop);             
for i=1:nloop
    indpar=logical(round(rand(size(inpars))));
    indarg=logical(round(rand(size(argname))));
    indval=round(0.501+5.990*rand(1,sum(indarg)));
    args=[argname(indarg);argvals(indval)];
    argcell{i}=[inpars(indpar),args(:)'];
    argcell_key{i}=args(:)';
end
disp(' ')


% Test relative speeds
% ---------------------------------------------------------
n = 0;

% ---------------------------------------------------------
disp('Parse_keyval')
tic
for i=1:nloop
    keywrd = parse_keyval(argname,argcell_key{i}{:});
    n=n+numel(keywrd);
end
t=toc;
disp(['     Time per function call (microseconds): ',num2str(1e6*t/nloop)]);
disp(' ')

% ---------------------------------------------------------
disp('Parse_arguments')
tic
for i=1:nloop
    [par,keyword,present] = parse_arguments(argcell{i},arglist,argflag);
    n=n+numel(par)+numel(keyword)+numel(present);
end
t=toc;
disp(['     Time per function call (microseconds): ',num2str(1e6*t/nloop)]);
disp(' ')


% ---------------------------------------------------------
disp('Parse_keywords')
tic
for i=1:nloop
    [ok,mess,ind,val] = parse_keywords(argname,argcell_key{i}{:});
    if ~ok, assertTrue(false,mess), end
    n=n+sum(ind)+numel(val);
end
t=toc;
disp(['     Time per function call (microseconds): ',num2str(1e6*t/nloop)]);
disp(' ')

% ---------------------------------------------------------
disp('Parse_arguments_simple')
tic
for i=1:nloop
    [par,keyval,present] = parse_arguments_simple(argname,logflag,argdef,argcell{i});
    n=n+numel(par)+numel(keyval)+numel(present);
end
t=toc;
disp(['     Time per function call (microseconds): ',num2str(1e6*t/nloop)]);
disp(' ')


% ---------------------------------------------------------
if n==2^45
    disp('Whoopee! (a message to prevent clever optimization by Matlab)')
end
