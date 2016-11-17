function [doc_out, ok, mess] = parse_doc_section (cstr, S, doc)
% Parse meta documentation
%
%   >> [douc_out, ok, mess] = parse_doc_section (cstr, S, doc)
%
% Input:
% ------
%   cstr    Cell array of strings with the new documentation to be parsed
%          in this function. Each must be valid block start or end line,
%          keyword/value line, substitution name for a cell array, or a
%          comment line i.e. begin with '%'. Assumed to have been trimmed
%          of leading and trailing whitespace and to be non-empty.
%
%   S       Structure whose fields are the names of variables and their
%          values. Fields can be:
%               - string
%               - cell array of strings (column vector)
%               - logical true or false (retain value for blocks)
%
%   doc     Cellarray of strings that contain the accumulated parsed
%          documentation so far (row vector)
%
% Output:
% -------
%   doc_out Cellarray of strings with newly parsed documentation appended
%          (row vector)
%
%   ok      If all OK, then true; otherwise false
%
%   mess    Error message if not OK; empty if all OK


% Initialise output
doc_out = doc;

% Resolve S:
%   substr  Structure whose fields contain strings.
%           Each field name is a substitution name e.g. substr.mynam
%           contains the string that will replace every occurence of <mynam>
%           in cstr.
%   subcell Structure whose fields contain cellarrays of strings.
%           Each field name is a substitution name e.g. substr.mynam
%           contains the cell array of strings that will replace
%           every occurence of <mynam> in cstr. It is required that each
%           string in the cell array begins with '%' and is assumed trimmed.
%   block   Structure with fields corresponding to sections marked by
%           % <nam:>   and ending with  % <nam/end:> (optionally without
%           the leading % sign). The value of the field is 0 or 1 corresponding
%           to skipping or retaining the section
Snam=fieldnames(S);
[substr,subcell,block]=Ssplit(S);

% Split substr and subcell into a more useful forms
substrnam=fieldnames(substr);
substrnam_bra=cell(size(substrnam));
for i=1:numel(substrnam)
    substrnam_bra{i}=['<',substrnam{i},'>'];
end
substrval=struct2cell(substr);

subcellnam=fieldnames(subcell);
subcellnam_bra=cell(size(subcellnam));
for i=1:numel(subcellnam)
    subcellnam_bra{i}=['<',subcellnam{i},'>'];
end
subcellval=struct2cell(subcell);


main_block='$main';
storing=true;
state=blockobj([],'add',main_block,storing);

% Find keyword and logical block lines, and determine if a line is to be buffered
nstr=numel(cstr);
for i=1:nstr
    [var,iskey,isblock,isdcom,issub,ismcom,argstr,isend,ok,mess] = parse_line (cstr{i});
    if ~ok, return, end
    if isblock
        % Block name. As part of checks, even if we are not reading the
        % current block (so the block name value may be undefined) we
        % check that the block beginning and end is actually defined
        % properly
        if strcmpi(var,blockobj(state,'current')) && isend
            % End of current block
            state=blockobj(state,'remove');         % move up to the parent block
            storing=blockobj(state,'storing');      % update storing status
        elseif ~isend
            % Start of new block
            if storing
                if isfield(block,var)
                    storing=block.(var);
                    state=blockobj(state,'add',var,storing);
                else
                    ok=false;
                    mess={['Unrecognised block name ''',var,''' in line:'],cstr{i}};
                    return
                end
            else
                state=blockobj(state,'add',var,storing);
            end
        else
            ok=false;
            mess={['Block end for ''',var,''' does not match current block ''',blockobj(state,'current'),''' in line:'],...
                cstr{i}};
            return
        end
    elseif iskey
        % Keyword line
        % We require that any substitutions are strings, not cell arrays. Check only
        % if storing, as substitutions may not be defined for blocks that are not being parsed.
        if strcmpi(var,'file') && ~isend
            if numel(argstr)<1
                ok=false;
                mess={'Must give file name in line:',cstr{i}};
                return
            end
            if storing
                % Resolve any string substitutions
                [argstr,ok,mess]=resolve(argstr,substrnam_bra,substrval);
                if ok
                    args=argstr;
                    for j=1:numel(args)
                        % Substitute strings as variables, if can
                        ix=find(strcmpi(args{j},Snam),1);
                        if ~isempty(ix)
                            args{ix}=S.(args{j});
                        end
                    end
                    [ok,mess,doc_out]=parse_doc(args{1},args(2:end),S,doc_out);
                    if ~ok
                        [~,mess]=str_make_cellstr(mess,'in line:',cstr{i}); % accumulate error message (recursive call to parse_doc)
                        return
                    end
                else
                    mess={[mess,' in line:'],cstr{i}};
                    return
                end
            end
        else
            ok=false;
            mess={['Unrecognised keyword ''',var,''' in line:'],cstr{i}};
            return
        end
    elseif issub
        % Line substitution - the line has form '<var_name>', and we demand
        % that var_name is a cellstr
        if storing
            tf=strcmp(var,subcellnam);
            if any(tf)
                tmp=subcellval(tf);
                doc_out=[doc_out,make_matlab_comment(tmp{1})'];
            else
                ok=false;
                mess={'Substitution must be a cell array of strings in line:',cstr{i}};
                return
            end
        end
    elseif ismcom
        % Matlab comment line
        if storing
            tmp=strtrim(cstr{i}(2:end));
            if length(tmp)>2 && tmp(1)=='<' && tmp(end)=='>' && isvarname(tmp(2:end-1)) &&...
                    any(strcmp(tmp(2:end-1),subcellnam))
                % Catch case of possible cellstr substitution i.e. '% <var_name>'
                tf=strcmp(tmp(2:end-1),subcellnam);
                tmp=subcellval(tf);
                doc_out=[doc_out,make_matlab_comment(tmp{1})'];
            else
                if storing
                    [line,ok,mess]=resolve(cstr{i},substrnam_bra,substrval);
                    if ok
                        doc_out=[doc_out,{line}];
                    else
                        mess={[mess,' in line:'],cstr{i}};
                        return
                    end
                end
            end
        end
    elseif isdcom
        % docify comment - do nothing
    else
        error('Logic error in docify application - see developers')
    end
end

% Check that blocks are consistent
if ~strcmpi(main_block,blockobj(state,'current'))
    ok=false;
    mess='Block start and end(s) are inconsistent';
    return
end

%--------------------------------------------------------------------------------------
function cstr_out = make_matlab_comment (cstr)
% Make a cell array of strings valid Matlab comments by prepending '% ' where necessary
% and turning into a column vector
cstr_out=cstr(:);
for j=1:numel(cstr_out)
    if cstr_out{j}(1)~='%'
        cstr_out{j}=['% ',cstr_out{j}];     % prepend '% ' if not a Matlab comment
    end
end
