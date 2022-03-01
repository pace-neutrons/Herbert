function [par,keyval,present,filled,ok,mess]=parse_arguments(args,varargin)
% Parse a cell array of arguments to get values of positional and keyword parameters
%
% Basic use:
% ----------
% Allow an unlimited number of optional positional parameters, and specify
% a structure giving permissible keywords and their default values:
%   >> [par,keyval,present,filled,ok,mess]=...
%              parse_arguments (args, keyval_default)
%
% Specify the number of required and optional positional parameters:
%   >> [...] = parse_arguments (args, npar_req, npar_opt, keyval_default)
%
% Specify the names of required positional parameters as a cell array of
% strings, and optional positional parameters as a structure giving names
% and default values:
%   >> [...] = parse_arguments (args, par_req, par_opt_default, keyval_default)
%
%
% Optional additional arguments (one or both, in either order)
% ------------------------------------------------------------
% Indicate which keywords are logical flags:
%   >> [...] = parse_arguments (..., flagnames)
%
% Additional options (contained in a structure):
%   >> [...] = parse_arguments (..., opt)
%
% Both:
%   >> [...] = parse_arguments (..., flagnames, opt)
%
%
% Input:
% ------
%   args        Cell array of arguments to be parsed. The list of arguments is
%              in general a set of parameters followed by optional keyword-value
%              pairs:
%                 {par_1, par_2, par_3, ..., name_1, val_1, name_2, val_2, ...}
%
%              where
%                 par_1, par_2, ... are the values of positional parameters
%
%                 name_1 ,val_1, ... are optional named arguments and their
%                                     corresponding values.
%               Note:
%               - The valid keywords are the field names of the structure
%                keyval_default (details below), and their default output values
%                are given by the values of those fields.
%
%               - The keyword names can be exact matches or unambiguous
%                abbreviations [exact only if opt.keys_exact ia set to true].
%                Note that the case of characters in keywords and named
%                positional arguments is ignored in any character string
%                comparisons.
%
%               - Keyword names that are also defined as logical flags in
%                flagnames (below) can also be given as their negation
%                (change this by setting opt.flags_noneg==true
%                 e.g. if 'mask' is a keyword, 'nomask' is also valid.
%
%               - The value of a logical flag does not need to be given a
%                value: if 'foo' is a flag then
%                   ...,'foo',1,...          sets argout.foo = 1
%                   ...,'foo',...            sets argout.foo = 1
%                   ...,'foo',0,...          sets argout.foo = 0
%                   ...,'nofoo',...          sets argout.foo = 0
%
%               - If a keyword is not given, then the default value defined by
%                keyval_default is returned.
%
%               - A prefix to the keywords can be specified in the options
%                (see below). For example if a field of keyval_default is
%                'mask' and the prefix '-' is specified then the keyowrd
%                must appear in args as '-mask', and its negative (if it is
%                a logical flag) is '-nomask'.
%
%               - By default, all positional parameters must appear first; the
%                first time a character string is encountered that matches a
%                parameter name that marks the point when only keyword-value
%                pairs and logical flags can follow. This default can be changed
%                to allow mixed parameters and keywords if opt.keys_at_end is
%                set to false.
%
% Optionally:
% Give the number of required and optional positional parameters:
%   npar_req    The number of required positional parameters. It can be
%              0,1,2,... {Default if empty: = 0]
%
%   npar_opt    The number of optional positional parameters. It
%              can be 0,1,2,... Inf [Default if empty: = 0]
%
% *OR*
% Give the names of required positional parameters and both the names and
% values of optional positional parameters:
%   par_req     Cell array with the names of required positional parameters
%
%   par_opt_default Structure with the names and values of optional positional
%              parameters. The names of the parameters are given by the
%              field names of the structure, and the values by the values of
%              the fields
%
% Default: If neither option above is given, or both optional parameters
% are empty, then this is interpreted as no required parameters and an
% unlimited number of optional parameters i.e. it is the same as
% npar_req=0, npar_opt=Inf
%
%
%   keyval_default  Structure with field names giving the parameter names,
%              and their values giving the default parameter values.
%               - Note that some keywords may not be permitted if negation
%                 of logical flags is permitted (which is the default
%                 behaviour - see input argument 'opt' below for details)
%                 e.g. if 'mask' is a logical flag then 'nomask' is
%                 implicitly also a name, so 'nomask' is not permiitted
%                 to be a field of keyval_default.
%
%   flagnames   [Optional] Cell array containing the names of the keywords
%              in keyval_default that can only be logical 0 or 1. The names
%              must be given in full (i.e. not abbreviations), and the
%              corresponding default values given in keyval_default must be
%              false, true, 0 or 1, otherwise an error is returned.
%               If empty or omitted, then no keywords are constrained to be
%              logical flags.
%
%   opt         [Optional] Structure giving values of options that control
%              the parsing of the input arguments. Valid fields are given
%              below, together with the default values if the field is
%              not given.
%               To override any of the defaults, provide a structure with
%              those fieldnames for which you want values that are different
%              from the defaults.
%               e.g. create
%                   opt.prefix = '-';
%                   opt.flags_noval = true;
% 
%               You can use a different built-in starting point for defaults
%              by giving the name of the set of defaults
%               e.g. create
%                   opt.default = 'dashprefix_noneg'
%                   opt.keys_exact = true;
%               Built in starting points are listed below
%   
%               If empty or omitted, then the standard default options will
%              be set.
%
%               prefix      Value of prefix to keywords. Must be a character
%                          string e.g. '-'.
%                           Most commonly a single character like '-' or '\'
%                          It can be a non-alphanumeric character (e.g. '-'
%                          or '\'), or an alphanumeric character string
%                          followed by a non-alphanumeric character string
%                          (e.g. 'key:')
%                           [Default: '' i.e. no prefix]
%
%               prefix_ctrl Control character to distinguish between a
%                          keyword a positional parameter that is the same
%                          character string. Must be non-alphanumeric
%                          for example '\' or '-'.
%                           For example, if there is keyword with value
%                         'norm', then the positional argument with value
%                         'norm' cannot be distinguished the keyword.
%                          If prefix_ctrl='\' then '\norm' resolves this.
%                          If the positional parameter '\norm' is required,
%                          then type '\\norm' etc.
%                           Note:
%                           - If prefix is not given, then you cannot give
%                            a prefix_ctrl character
%                           - If a prefix is required (i.e. prefix_req==true)
%                            then prefix and prefix_ctrl cannot be the same.
%                           [Default: '' i.e. no control character]
%
%
%               prefix_req  If true requires that the prefix be present on
%                          keywords, if false then otherwise. Ignored if the
%                          prefix is empty.
%                           For example if 'mask' is a keyword, opt.prefix='-'
%                          and opt.prefix_req=false, then 'mask' and '-mask'
%                          are both valid.
%                           [Default: true]
%
%               flags_noneg If true then flags cannot be negated prefixing
%                          the name with 'no'. For example, if 'full' is
%                          a flag, 'nofull' is not permitted.
%                           [Default: false]
%
%               flags_noval If true then flags cannot be given values in the
%                          argument list to be parsed. For example,
%                          ...,'foo',1,... is not permitted; the value is
%                          set by specifing ...,'foo',... or ...,'nofoo',...
%                           Note: opt.flags_noneg and opt.flags_noval cannot
%                          both be true if a logical flag has default value
%                          true in keyval_default, because then there is no way
%                          to set its value to false.
%                           [Default: false]
%
%               keys_exact  True if exact match to keywords is required
%                           [Default: false]
%
%               keys_at_end True if keywords must appear at the end of the
%                          argument list; otherwise keywords and un-named
%                          parameters can be mixed.
%                           [Default: true]
%
%               keys_once   True if keywords are only allowed to appear once
%                          in the argument list.
%                           If false i.e. keywords can be repeated; in this
%                          case the last occurence takes precedence.
%                           [Default: true]
%
%               noffset     Offset (>=0) for error message display.
%                          If not all arguments are passed to parse_arguments
%                          then if an error is found at the third position
%                          in args, the error message that parse_arguments
%                          gives will be stated at the third position, but
%                          this will not be at the true position in the list.
%                          Give the offset here. For example, you might not
%                          pass the first three arguments because these must
%                          always be present, set opt.noffset=3.
%                           [Default: 0]
%
%               A different set of defaults to use as a starting point can
%              be set:
%               - enforces keywords must start with '-'
%               - flagnames cannot be negated
%
%               opt.default = 'dashprefix_noneg'
%
%               prefix      '-'     
%               prefix_req  true
%               prefix_ctrl '-'
%               flags_noneg true
%               flags_noval false
%               keys_exact  false
%               keys_at_end true
%               keys_once   true
%               noffset     0
%
% Output:
% -------
%   par     If only the number of required and optional positional parameters
%          was given (or neither this nor the names of positional parameters):
%           - Cell array (row) that contains the values of arguments that
%            do not correspond to keywords.
%
%           If the names of required and optional parameters were given:
%           - Structure with fieldnames corresponding to the parameter
%            names and the values of those fields set to the parameter
%            values. Optional parameters that did not appear are set to
%            the default values as given in the input argument par_opt_default.
%
%   keyval  Structure with fieldnames corresponding to the keywords and
%           values that are read form the argument list, or from the default
%          values in keyval_default for those keywords that were not in the
%          argument list.
%
%   present Structure with field names matching the positional parameter names
%          (if they were given) and the keyword names, and which have values
%          logical 0 or 1 indicating if the parameter or keyword appeared in args.
%          If a keyword appeared as its negation e.g. 'nofoo', then it is deemed
%          to have been present i.e. present.foo = 1
%
%   filled  Structure with field names matching the positional parameter names
%          (if they were given) and the keyword names, and which have values
%          logical 0 or 1 indicating if the argument is non-empty (whether
%          that be because it was supplied with a non-empty default, or
%          because it was given a non-empty value on the command line).
%
%   ok      True if all is OK, false if not. If there is an error, but ok is
%          not a return argument, then an exception will be thrown. If ok is
%          a return argument, then an error will not throw an exception, so
%          you must test the value of ok on return.
%
%   mess    Error message of not ok; empty string if all is ok.
%
%
% EXAMPLE 1: Unlimited number of positional parameters:
% =====================================================
% Consider the function:
%       function parse_test (varargin)
%
%       % Argument names and default values:
%       keyval_default = struct('background',[12000,18000], ...
%                           'normalise', 1, ...
%                           'modulation', 0, ...
%                           'output', 'data.txt');
%
%       % Arguments which are logical flags:
%       flagnames = {'normalise','modulation'};
%
%       % Parse input:
%       [par, keyval, present] = parse_arguments...
%                   (varargin, keyval_default, flagnames);
%
%       % Display results
%       par
%       keyval
%       present
%
%       end
%
% Then calling parse_test with input as follows:
%   >> parse_test('input_file.dat',18,{'hello','tiger'},...
%                       'back',[15000,19000],'mod','nonorm')
%
% results in the output:
%   par =
%        'input_file.dat'    [18]    {1x2 cell}
%
%   argout =
%        background: [15000 19000]
%         normalise: 0
%        modulation: 1
%            output: 'data.txt'
%
%   present =
%        background: 1
%         normalise: 1
%        modulation: 1
%            output: 0
%
%
% EXAMPLE 2: Named required and optional parameters
% =================================================
%
%       function parse_test (varargin)
%
%       % Required parameters:
%       par_req = {'data_source', 'ei'};
%
%       % Optional parameters:
%       par_opt_default = struct('emin', -0.3, 'emax', 0.95, 'de', 0.005);
%
%       % Argument names and default values:
%       keyval_default = struct('background',[12000,18000], ...
%                           'normalise', 1, ...
%                           'modulation', 0, ...
%                           'output', 'data.txt');
%
%       % Arguments which are logical flags:
%       flagnames = {'normalise','modulation'};
%
%       % Parse input:
%       [par,argout,present] = parse_arguments(varargin,...
%                       par_req, par_opt_default, keyval_default, flagnames);
%
%       % Display results
%       par
%       argout
%       present
%
%       end
%
% Then calling parse_test with input:
%   >> parse_test('input_file.dat',18,-0.5,0.6,...
%                       'back',[15000,19000],'mod','nonorm')
%
% results in the output:
%     par =
%
%         data_source: 'input_file.dat'
%                  ei: 18
%                emin: -0.5000
%                emax: 0.6000
%                  de: 0.0050
%
%
%     argout =
%
%         background: [15000 19000]
%          normalise: 0
%         modulation: 1
%             output: 'data.txt'
%
%
%     present =
%
%         data_source: 1
%                  ei: 1
%                emin: 1
%                emax: 1
%                  de: 0
%          background: 1
%           normalise: 1
%          modulation: 1
%              output: 0


% Original author: T.G.Perring


% Retain the original capability to suppress throwing of an error if
% return argument 'ok' is provided. This is for backwards compatibility
% with widespread use of parse_arguments. Revised (May 2021) convention
% is that an error is caught with a try...catch block in the caller.
throw_error = (nargout<=4);


% Check input arguments format
% ----------------------------
if nargin>=2 && nargin<=4 && isstruct(varargin{1})
    % Original input format: (args, keyval_default, [flagnames], [opt])
    par_req = 0;
    par_opt_default = Inf;
    keyval_default = varargin{1};
    pos_opt_start = 2;
    
elseif nargin>=4
    % New format, one of:
    %   (args, npar_req, npar_opt, keyval_default, [flagnames], [opt])
    %   (args, par_req, par_opt_default, keyval_default, [flagnames], [opt])
    par_req = varargin{1};
    par_opt_default = varargin{2};
    keyval_default = varargin{3};
    pos_opt_start = 4;
    
else
    % Format error
    if throw_error
        error('HERBERT:parse_arguments:invalid_argument',...
            'Invalid input argument format')
    else
        ok = false;
        mess='Check number and type of input arguments';
        [par,keyval,present,filled] = error_return;
        return
    end
end


% Get flagnames and options structure
% -----------------------------------
try
    [flagnames, opt_update] = parse_optional_arguments (varargin{pos_opt_start:end});
catch ME
    if throw_error
        switch ME.identifier
            case 'HERBERT:parse_optional_arguments:invalid_argument'
                msg = 'Incorrect number and/or type of optional arguments';
                causeException = MException('HERBERT:parse_arguments:invalid_arguments', msg);
                ME = addCause(ME,causeException);
        end
        rethrow(ME)
    else
        ok = false;
        mess='Check number and type of input arguments';
        [par,keyval,present,filled] = error_return;
        return
    end
end


% Update the default options structure
% ------------------------------------
try
    opt = update_options (opt_update);
catch ME
    if throw_error
        switch ME.identifier
            case 'HERBERT:update_options:invalid_argument'
                msg = 'Invalid field name or value in options argument';
                causeException = MException('HERBERT:parse_arguments:invalid_arguments', msg);
                ME = addCause(ME,causeException);
        end
        rethrow(ME)
    else
        ok = false;
        mess='Check number and type of input arguments';
        [par,keyval,present,filled] = error_return;
        return
    end
end


% Check arguments that defined positional parameter format
% --------------------------------------------------------
try
    [par, par_names, npar_req, npar_opt] = check_positional_arguments(par_req, par_opt_default);
catch ME
    if throw_error
        switch ME.identifier
            case 'HERBERT:check_positional_arguments:invalid_argument'
                msg = 'Invalid or inconsistent information defining positional arguments';
                causeException = MException('HERBERT:parse_arguments:invalid_arguments', msg);
                ME = addCause(ME,causeException);
        end
        rethrow(ME)
    else
        ok = false;
        mess='Check number and type of input arguments';
        [par,keyval,present,filled] = error_return;
        return
    end
end


% Check keyword arguments and get variables for parsing
% -----------------------------------------------------
try
    [keyval, key_names, key_names_all, ind_rootkey, isflagname, isnegflagname] =...
        check_keyword_arguments(keyval_default, flagnames, opt);
catch ME
    if throw_error
        switch ME.identifier
            case 'HERBERT:check_keyword_arguments:invalid_argument'
                msg = 'Invalid or inconsistent information defining keyword arguments';
                causeException = MException('HERBERT:parse_arguments:invalid_arguments', msg);
                ME = addCause(ME,causeException);
        end
        rethrow(ME)
    else
        ok = false;
        mess='Check number and type of input arguments';
        [par,keyval,present,filled] = error_return;
        return
    end
end


% Check parameter names and keywords are collectively unique
% ----------------------------------------------------------
if ~(isempty(par_names) || isempty(key_names))
    tmp=sort([par_names;key_names]);
    for i = 2:numel(tmp)
        if strcmpi(tmp{i-1},tmp{i})
            if throw_error
                error('HERBERT:parse_arguments:invalid_argument',...
                    ['The combined parameter and keyword name list contains ''',tmp{i},...
                    ''' at least twice (accounting for permissible keyword negation &/or prefix.'])
            else
                ok = false;
                mess=['The combined parameter and keyword name list contains ''',tmp{i},...
                    ''' at least twice (accounting for permissible keyword negation &/or prefix.'];
                [par,keyval,present,filled] = error_return;
                return
            end
        end
    end
end


% Parse the input argument list
% -----------------------------
try
    [par, keyval, present, filled] = parse_args_main(args, par, par_names, npar_req, npar_opt,...
        keyval, key_names, key_names_all, ind_rootkey, isflagname, isnegflagname, opt);
catch ME
    if throw_error
        switch ME.identifier
            case 'HERBERT:parse_args:invalid_argument'
                msg = 'Input arguments to parse_arguments do not satisfy the specified requirements';
                causeException = MException('HERBERT:parse_arguments:invalid_arguments', msg);
                ME = addCause(ME,causeException);
        end
        rethrow(ME)
    else
        ok = false;
        mess='Check number and type of input arguments';
        [par,keyval,present,filled] = error_return;
        return
    end
end

% For backwards compatibility, return ok and mess
ok = true;
mess = '';


%----------------------------------------------------------------------------------------
function [flagnames, opt] = parse_optional_arguments (varargin)
% Parse optional arguments to parse_arguments.
%
%   >> [flagnames, opt] = parse_optional_arguments ()
%   >> [flagnames, opt] = parse_optional_arguments (flagnames_in)
%   >> [flagnames, opt] = parse_optional_arguments (opt_in)
%   >> [flagnames, opt] = parse_optional_arguments (flagnames_in, opt_in)
%
% This function simply ensures the correct argument type(s)
%
% Input:
% ------
%   flagnames   Cell array with the full names of logical flags, or empty
%              argument (of any type)
%   opt         Structure from which to update the default options structure.
%              empty argument (of any type)
%
% Output:
% -------
%   flagnames   Cell array with the full names of flags, or empty cell array
%   opt         Structure, or empty structure

narg=numel(varargin);
if narg==2
    if iscellstr(varargin{1})
        flagnames = varargin{1};
    elseif isempty(varargin{1})
        flagnames = {};
    else
        error('HERBERT:parse_optional_arguments:invalid_argument',...
            'Invalid flagname argument type')
    end
    
    if isstruct(varargin{2})
        opt = varargin{2};
    elseif isempty(varargin{2})
        opt = struct();
    else
        error('HERBERT:parse_optional_arguments:invalid_argument',...
            'Invalid options argument type')
    end
    
elseif narg==1
    if iscellstr(varargin{1})
        flagnames=varargin{1};
        opt=struct();
        
    elseif isstruct(varargin{1})
        flagnames={};
        opt = varargin{1};
        
    elseif isempty(varargin{1})
        flagnames={};
        opt=struct();
        
    else
        error('HERBERT:parse_optional_arguments:invalid_argument',...
            'Invalid optional argument type')
    end
    
elseif narg==0
    flagnames={};
    opt=struct();
    
else
    error('HERBERT:parse_optional_arguments:invalid_argument',...
        'Too many optional arguments')
end


%----------------------------------------------------------------------------------------
function opt = update_options (opt_update)
% Update the values of the fields in the options structure
%
%   >> opt = update_options (opt_update)
%
% Checks that changes have valid values, and that the input structure does
% not contain unexpected fields. If it does this will likely be due to
% typos, given that parse_arguments is mainly to be used by developers, not
% users
%
% Input:
% ------
%   opt_update  Structure with fields selected from the valid fields for
%               the options, and with values to updates those in the
%               default options structure.
%
% Output:
% -------
%   opt         Updated options structure.

nam={'prefix'; 'prefix_req'; 'prefix_ctrl'; 'flags_noneg'; 'flags_noval';...
    'keys_exact'; 'keys_at_end'; 'keys_once'; 'noffset'};

val_default = {''; true; ''; false; false; false; true; true; 0};
val_dashprefix_noneg  = {'-'; true; '-'; true; false; false; true; true; 0};

optnam=fieldnames(opt_update);

% Set default values
if ~isempty(find(strcmpi('default', optnam), 1))
    if ~isempty(opt_update.default) && is_string (opt_update.default)
        if strcmpi(opt_update.default, 'default')
            val = val_default;
        elseif strcmpi(opt_update.default, 'dashprefix_noneg')
            val = val_dashprefix_noneg;
        else
            error('HERBERT:update_options:invalid_argument',...
                ['Unrecognised options default name ''',opt_update.default,''''])
        end
    elseif isempty(opt_update.default)
        val = val_default;
    else
        error('HERBERT:update_options:invalid_argument',...
            'Default option field ''default'' must be empty one of the recognised options names')
    end
else
    val = val_default;
end

% Update default values
for i = 1:numel(optnam)
    ind=find(strcmpi(optnam{i},nam),1);
    if ~isempty(ind)
        if ind==1 && is_string(opt_update.(optnam{i}))
            val{1}=opt_update.(optnam{i});     % this way we dont worry about letter case
            
        elseif ind==2 && islognumscalar(opt_update.(optnam{i}))
            val{2}=logical(opt_update.(optnam{i}));
            
        elseif ind==3 && is_string(opt_update.(optnam{i}))
            val{3}=opt_update.(optnam{i});
            
        elseif ind==4 && islognumscalar(opt_update.(optnam{i}))
            val{4}=logical(opt_update.(optnam{i}));
            
        elseif ind==5 && islognumscalar(opt_update.(optnam{i}))
            val{5}=logical(opt_update.(optnam{i}));
            
        elseif ind==6 && islognumscalar(opt_update.(optnam{i}))
            val{6}=logical(opt_update.(optnam{i}));
            
        elseif ind==7 && islognumscalar(opt_update.(optnam{i}))
            val{7}=logical(opt_update.(optnam{i}));
            
        elseif ind==8 && islognumscalar(opt_update.(optnam{i}))
            val{8}=logical(opt_update.(optnam{i}));
            
        elseif ind==9 && isnumeric(opt_update.(optnam{i})) && opt_update.(optnam{i})>=0
            val{9}=logical(opt_update.(optnam{i}));
            
        else
            error('HERBERT:update_options:invalid_argument',...
                ['Invalid option type or value for fieldname ''',optnam{i},''''])
        end
        
    elseif ~strcmpi(optnam{i}, 'default')
        error('HERBERT:update_options:invalid_argument',...
            ['Invalid option name ''',optnam{i},''''])
    end
end
opt=cell2struct(val,nam);

% Check options are valid
if ~isempty(opt.prefix)
    % If given, prefix must be a non-alphanumeric character optionally
    % preceded by an alphanumeric string
    if ~isempty(regexp(opt.prefix(end), '^[A-Za-z0-9]+$', 'once')) ||...
            (numel(opt.prefix)>1 &&...
            isempty(regexp(opt.prefix(1:end-1), '^[A-Za-z0-9]+$', 'once')))
        error('HERBERT:update_options:invalid_argument',...
            ['Invalid form of keyword prefix: ''',opt.prefix,''''])
    end
end

if ~isempty(opt.prefix_ctrl)
    if isempty(opt.prefix)
        % Cannot give prefix_ctrl if prefix is empty
        error('HERBERT:update_options:invalid_argument',...
            'Cannot give a prefix control character if there is no prefix string')
    else
        % If given, prefix_ctrl must be a single non-alphanumeric character
        if ~isempty(regexp(opt.prefix_ctrl, '^[A-Za-z0-9]+$', 'once'))
            error('HERBERT:update_options:invalid_argument',...
                ['Invalid prefix control character: ''',opt.prefix_ctrl,...
                '''. Must be a single non-alphanumeric character'])
        else
            
        end
    end
end

if ~opt.prefix_req && ~isempty(opt.prefix) && strcmpi(opt.prefix,opt.prefix_ctrl)
    error('HERBERT:update_options:invalid_argument',...
        ['If a keyword prefix is given but not required, then it cannot ',...
        'be the same as the prefix control character'])
end



%----------------------------------------------------------------------------------------
function [par, par_names, npar_req, npar_opt] = check_positional_arguments...
    (par_req, par_opt_default)
% Check the validity of the arguments defining required and positional parameters
%
%   >> [par, nam, nreq, nopt] = check_positional_arguments(par_req, par_opt)
%
% Input:
% ------
%   par_req         Required positional parameter information, one of:
%                    - scalar positive number 0,1,2,...
%                    - cell array of parameter names
%                   Default if empty: 0
%
%   par_opt_default Optional positional parameter information, one of:
%                    - scalar positive number 0,1,2,..., or Inf
%                    - structure giving names and default values
%                   Default if empty: 0
%
%   If both are empty, then interpreted as no required parameters and an
%   unlimited number of optional parameters.
%
% Output:
% -------
%   par         If parameters are not named:
%                - Empty cell array
%               If parameters are named:
%                - Structure with names of the parameters and pre-initialised
%                  with default values of any optional parameters
%                  (Note: required parameters are given the value [], but by
%                  definition these will be required to be given a value by the
%                  caller of parse_arguments)
%
%   par_names   If parameters are not named:
%                - Empty cell array
%               If parameters are named:
%                - Cell array of names of parameters. (Column vector)
%                  This is precisely the result of fieldnames(par)
%
%   npar_req    Number of required parameters: 0,1,2,...
%
%   npar_opt    Number of optional parameters: 0,1,2,...  or Inf



% Check required parameter names
%-------------------------------
if ~isempty(par_req)
    par_req_empty = false;
    if isnumeric(par_req)
        if isscalar(par_req) && par_req>=0 && isfinite(par_req) && rem(par_req,1)==0
            npar_req = par_req;
            nam_req = {};
        else
            error('HERBERT:check_positional_arguments:invalid_argument',...
                'If set, the number of required parameters must be 0,1,2,...')
        end
        
    elseif iscellstr(par_req)
        for i = 1:numel(par_req)
            if ~isvarname(par_req{i})
                error('HERBERT:check_positional_arguments:invalid_argument',...
                    ['Requested required parameter name ''',par_req{i},...
                    ''' is not a valid Matlab variable name'])
            end
        end
        if numel(par_req)>1
            tmp=sort(par_req);
            for i = 2:numel(par_req)
                if strcmpi(tmp{i-1},tmp{i})
                    error('HERBERT:check_positional_arguments:invalid_argument',...
                        ['The requested required parameters name list contains ''',...
                        tmp{i},''' at least twice. Names must be unique.'])
                end
            end
        end
        npar_req = numel(par_req);
        nam_req = par_req(:);     % ensure column vector
    else
        error('HERBERT:check_positional_arguments:invalid_argument',...
            ['Required parameters must be given as a list of names or ',...
            'the number of required parameters'])
    end
else
    % Empty argument assumed to mean no required parameters
    par_req_empty = true;
    npar_req = 0;
    nam_req = {};
end


% Optional parameters
%--------------------
if ~isempty(par_opt_default)
    par_opt_empty = false;
    if isnumeric(par_opt_default)
        if isscalar(par_opt_default) && par_opt_default>=0 && (isinf(par_opt_default) || rem(par_opt_default,1)==0)
            npar_opt = par_opt_default;
            nam_opt = {};
        else
            error('HERBERT:check_positional_arguments:invalid_argument',...
                ['The number of optional parameters must be 0,1,2,...',...
                ', or Inf for an unlimited number of optional parameters'])
        end
    elseif isstruct(par_opt_default)
        nam_opt = fieldnames(par_opt_default);
        if numel(nam_opt)>0
            npar_opt = numel(nam_opt);
        else
            % A structure can have no fields but still be non-empty
            % Treat just like an empty object (see below)
            par_opt_empty = true;
            npar_opt = 0;
            nam_opt = {};
        end
    else
        error('HERBERT:check_positional_arguments:invalid_argument',...
            ['Optional parameters must given as a structure or the ',...
            'number of required parameters'])
    end
else
    % Empty argument assumed to mean an unlimited number of optional parameters
    par_opt_empty = true;
    npar_opt = 0;
    nam_opt = {};
end


% Combine the input
% -----------------
% If both arguments were empty, then treat as no required parameters, and
% infinite number of optional parameters
if par_req_empty && par_opt_empty
    npar_opt = Inf;
    nam_opt = {};
end

% If required and optional parameters are both >0, must both be un-named or
% both named.
if npar_req>0 && npar_opt>0
    % Both required parameters and optional parameters are specified
    if ~isempty(nam_req) && ~isempty(nam_opt)
        % Both defined by names
        par_names=[nam_req;nam_opt];
        tmp=sort(par_names);
        for i = 2:numel(tmp)
            if strcmpi(tmp{i-1},tmp{i})
                error('HERBERT:check_positional_arguments:invalid_argument',...
                    ['The combined list of required and optional parameter names contain ''',...
                    tmp{i},''' at least twice. Names must be unique.'])
            end
        end
        par=catstruct(cell2struct(repmat({[]},npar_req,1),nam_req), par_opt_default);
        
    elseif isempty(nam_req) && isempty(nam_opt)
        % Neither defined by names
        par={};
        par_names={};
    else
        error('HERBERT:check_positional_arguments:invalid_argument',...
            ['If a non-zero number of both required and optional parameters',...
            ' is given, they must both be given numerically or both named'])
    end
    
elseif npar_req>0
    % Required parameters only
    if ~isempty(nam_req)
        par=cell2struct(repmat({[]},npar_req,1),nam_req);
        par_names=nam_req;
    else
        par={};
        par_names={};
    end
    
elseif npar_opt>0
    % Optional parameters only
    if ~isempty(nam_opt)
        par=par_opt_default;
        par_names=nam_opt;
    else
        par={};
        par_names={};
    end
    
else
    % No required and no optional parameters
    par={};
    par_names={};
end


%----------------------------------------------------------------------------------------
function [keyval, key_names, key_names_all, ind_rootkey, isflagname, isnegflagname] =...
    check_keyword_arguments(keyval_default, flagnames, opt)
% Check the validity of the arguments defining keyword arguments
%
%   >> [keyval, key_names, key_names_all, ind, isflagname, isnegflagname] =...
%               check_keyword_arguments(keyval_default, flagnames, opt)
%
% Input:
% ------
%   keyval_default  Structure: fieldnames are names of keywords, field values
%                  are the default values
%   flagnames       Cell array with names of flags. The names must fields of
%                  keyval_default
%   opt             Structure with values of options: required fields are:
%
%               prefix      Value of prefix to keywords. Must be a character
%                          string e.g. '-'.
%
%               prefix_req  If true requires that the prefix be present on
%                          keywords, if false then otherwise.
%
%               flags_noneg If true then flags cannot be negated prefixing
%                          the name with 'no'. For example, if 'full' is
%                          a flag, 'nofull' is not permitted.
%
% Output:
% -------
%   keyval          Structure with defaults for flags turned in logicals
%
%
%   key_names       Cellstr of keywords (==fieldnames(keyval)) [Column vector]
%
%   key_names_all   Cellstr of keywords with all permissible prefixing or
%                  negation, as determined by options set in opt [Column vector]
%
%   ind_rootkey     Index of keywords including those generated by prefixing
%                  or negation into the root keyword list [Column vewctor]
%
%   isflagname      Logical array with true where key_names_all is a flag
%                  or negation of a flag
%
%   isnegflagname   Logical array with true where key_names_all is the
%                  negation of a flag
%
%
% If a keyword='hello' and prefix='-', and if opt.prefix_req==false, then
% valid keywords are:
%       'hello' and '-hello'
%
% If the keyword is also a flag, then the full list is:
%       'hello', '-hello', 'nohello' and '-nohello'
%
% Checks are performed to ensure that prefix and flag status do not construct
% duplicate names. For example:
% - 'nohello' and 'hello' are not permitted if 'hello' is a flag
%       (because the negation of 'hello' matches 'nohello').
% - 'nohello' and 'hello' are permitted if 'hello' is NOT a flag


% Note about efficiency: In ~2010? TGP did timing tests of the 'N^2' algorithm
% where for each keyword we check against all others, and an algorithm where
% the keywords are sorted and then compare adjacent keywords. For 300 keywords
% or less, the N^2 algorithm is about 5 times slower, and about 2x slower
% for N<20. Given the fact that in practice N<20, the other overheads,
% that the calling function will march through the list anyway at least once,
% it is not worth the effort of optimising where the comparison keyword comes
% from a second list that also needs to be incremented.


if isempty(keyval_default)
    % Catch case of empty input
    keyval = struct([]);  % empty structure
    key_names = cell(0,1);
    
elseif isstruct(keyval_default)
    % Keyword structure given
    key_names=fieldnames(keyval_default);
    if ~isempty(key_names)
        keyval=keyval_default;
    else
        keyval = struct([]);  % empty structure
    end
    
else
    error('HERBERT:check_keyword_arguments:invalid_argument',...
        'Keywords and their defaults can only be given as a structure')
end

n=numel(key_names);
isflagname=false(n,1);

% Determine which names are flags
if ~isempty(flagnames)
    for i = 1:numel(flagnames)
        ipos = find(strcmpi(flagnames{i},key_names),1);    % can only be 0 or 1 match
        if ~isempty(ipos)
            isflagname(ipos)=true;
            val=keyval.(key_names{ipos});
            if islognumscalar(val)
                % Ensure default is a logical scalar
                keyval.(key_names{ipos}) = logical(val);
                if opt.flags_noneg && opt.flags_noval && keyval.(key_names{ipos})
                    error('HERBERT:check_keyword_arguments:invalid_argument',...
                        ['Default value of flag ''',key_names{ipos},...
                        ''' must be false if flags_noneg and flags_noval are both true'])
                end
            else
                error('HERBERT:check_keyword_arguments:invalid_argument',...
                    ['Default value of flag ''',key_names{ipos},...
                    ''' must be 0 or 1, or true or false'])
            end
        else
            error('HERBERT:check_keyword_arguments:invalid_argument',...
                ['Flag name ''',flagnames{i},''' is not in the list of    keywords'])
        end
    end
end

% Determine full list of names allowing for prefix and negation of flags
if any(isflagname) && ~opt.flags_noneg
    negnam = key_names(isflagname);
    for i = 1:numel(negnam)
        negnam{i} = ['no',negnam{i}];
    end
    key_names_all = [key_names;negnam];
    ind_rootkey = [(1:n)'; find(isflagname)];
    isflagname = [isflagname; true(numel(negnam),1)];
    isnegflagname = [false(n,1); true(numel(negnam),1)];
else
    key_names_all = key_names;
    ind_rootkey = (1:n)';
    isnegflagname = false(n,1);
end

if ~isempty(opt.prefix)
    prefix = opt.prefix;
    if opt.prefix_req
        for i = 1:numel(key_names_all)
            key_names_all{i} = [prefix, key_names_all{i}];
        end
    else
        pre_key_names_all = cell(size(key_names_all));
        for i = 1:numel(key_names_all)
            pre_key_names_all{i} = [prefix,key_names_all{i}];
        end
        key_names_all = [key_names_all; pre_key_names_all];
        ind_rootkey = [ind_rootkey; ind_rootkey];
        isflagname = [isflagname; isflagname];
        isnegflagname = [isnegflagname; isnegflagname];
    end
end

% Check there are no duplications in the list arising from negation and/or prefixing
if numel(key_names_all)>1
    [tmp, ix] = sort(key_names_all);
    for i = 2:numel(key_names_all)
        if strcmpi(tmp{i-1},tmp{i})
            error('HERBERT:check_keyword_arguments:invalid_argument',...
                ['The keywords ''',key_names{ind_rootkey(ix(i-1))},''' and ''',key_names{ind_rootkey(ix(i))},...
                ''' are ambiguous due to prefixing and/or negation'])
        end
    end
end


%----------------------------------------------------------------------------------------
function [par, keyval, present, filled] = parse_args_main(args, par_default, par_names,...
    npar_req, npar_opt, keyval_default, key_names, key_names_all, ind_rootkey,...
    isflagname, isnegflagname, opt)
% Parse a cell array of arguments according to parsing data
%
%   >> [par, keyval, present, filled] = parse_args(args, par, par_names,...
%           npar_req, npar_opt, keyval, key_names, key_names_all, ind,...
%           isflagname, isnegflagname, opt)
%
% Input:
% ------
%   par_default If parameters are not named:
%                - Empty cell array
%               If parameters are named:
%                - Structure with names of the parameters and pre-initialised
%                  with default values of any optional parameters
%                  (Note: required parameters are given the value [], but by
%                  definition these will be required to be given a value by the
%                  caller of parse_arguments)
%
%   par_names   If parameters are not named:
%                - Empty cell array
%               If parameters are named:
%                - Cell array of names of parameters. (Column vector)
%                  This is precisely the result of fieldnames(par)
%
%   npar_req    Number of required parameters: 0,1,2,...
%
%   npar_opt    Number of optional parameters: 0,1,2,...  or Inf
%
%   keyval_default  Structure with defaults for flags turned in logicals
%
%   key_names       Cellstr of keywords (==fieldnames(keyval)) [Column vector]
%
%   key_names_all   Cellstr of keywords with all permissible prefixing or
%                  negation, as determined by options set in opt [Column vector]
%
%   ind_rootkey     Index of keywords including those generated by prefixing
%                  or negation into the root keyword list [Column vewctor]
%
%   isflagname      Logical array with true where key_names_all is a flag
%                  or negation of a flag
%
%   isnegflagname   Logical array with true where key_names_all is the
%                  negation of a flag
%
%   opt             Structure with values of options: required fields are:
%
%               flags_noval If true then flags cannot be given values in the
%                          argument list to be parsed.
%
%               keys_exact  True if exact match to keywords is required
%
%               keys_at_end True if keywords must appear at the end of the
%                          argument list; otherwise keywords and un-named
%                          parameters can be mixed.
%
%               keys_once   True if keywords are only allowed to appear once
%                          in the argument list.
%                           If false i.e. keywords can be repeated; in this
%                          case the last occurence takes precedence.
%
%               noffset     Offset (>=0) for error message display.
%                          If not all arguments are passed to parse_arguments
%                          then if an error is found at the third position
%                          in args, the error message that parse_arguments
%                          gives will be stated at the third position, but
%                          this will not be at the true position in the list.
%                          Give the offset here. For example, you might not
%                          pass the first three arguments because these must
%                          always be present, set opt.noffset=3.
% Output:
% -------
%   par     If only the number of required and optional positional parameters
%          was given (or neither this nor the names of positional parameters):
%           - Cell array (row) that contains the values of arguments that
%            do not correspond to keywords.
%
%           If the names of required and optional parameters were given:
%           - Structure with fieldnames corresponding to the parameter
%            names and the values of those fields set to the parameter
%            values. Optional parameters that did not appear are set to
%            the default values as given in the input argument par_opt_default.
%
%   keyval  Structure with fieldnames corresponding to the keywords and
%           values that are read form the argument list, or from the default
%          values in keyval_default for those keywords that were not in the
%          argument list.
%
%   present Structure with field names matching the positional parameter names
%          (if they were given) and the keyword names, and which have values
%          logical 0 or 1 indicating if the parameter or keyword appeared in args.
%          If a keyword appeared as its negation e.g. 'nofoo', then it is deemed
%          to have been present i.e. present.foo = 1
%
%   filled  Structure with field names matching the positional parameter names
%          (if they were given) and the keyword names, and which have values
%          logical 0 or 1 indicating if the argument is non-empty (whether
%          that be because it was supplied with a non-empty default, or
%          because it was given a non-empty value on the command line).


keyval = keyval_default;

narg = numel(args);
ispar = false(1,narg);
npar_max = npar_req + npar_opt;
nkey = numel(key_names);

i = 1;
npar = 0;
key_present = false(nkey, 1);
expect_key = false;     % true if keywords and values only are permitted
while i<=narg
    % Determine if argument is a keyword; ambiguous keywords are an error
    iskey = false;
    if nkey>0 && is_string(args{i}) && ~isempty(args{i})
        ipos = stringmatchi (args{i}, key_names_all, opt.keys_exact);
        if numel(ipos)==1
            iskey = true;
        elseif ~isempty(ipos)
            error('HERBERT:parse_args:invalid_argument',...
                ['Ambiguous keyword at position ',...
                num2str(i+opt.noffset),' in the argument list'])
        end
    end
    
    % Branch on parameter or keyword
    if ~iskey
        % Argument is not a keyword, so must be a parameter
        if ~expect_key
            npar = npar+1;
            if npar<=npar_max
                ispar(i) = true;
            else
                error('HERBERT:parse_args:invalid_argument',...
                    ['The number of positional parameter(s) exceeds ',...
                    'the maximum request of ',num2str(npar_max)])
            end
        else
            error('HERBERT:parse_args:invalid_argument',...
                ['Expected a keyword but found ',disp_string(args{i}),...
                ' at position ',num2str(i+opt.noffset),' in the argument list'])
        end
        
    else
        % Argument is a keyword
        ikey = ind_rootkey(ipos);
        
        % Check if the keyword has already appeared, and, if so, reject if
        % multiple occurences are not permitted
        if ~key_present(ikey)
            key_present(ikey) = true;
        elseif opt.keys_once
            error('HERBERT:parse_args:invalid_argument',...
                ['Keyword ''',key_names{ikey},...
                ''' (or its negation if a flag) appears more than once'])
        end
        
        % Get value corresponding to keyword
        if isflagname(ipos)
            % Case of keyword is a flag
            if opt.flags_noval || i==narg || ~islognumscalar(args{i+1})
                % Value is determined solely by the presence of the
                % flagname or its negation, either because values are not
                % permitted, there is no following argument, or the
                % following argument is not interpretable as a logical
                % scalar and so must be the next parameter or keyword in
                % the argument list
                keyval.(key_names{ikey}) = ~isnegflagname(ipos);
            else
                % Value is determined by the following input argument, as
                % values are permitted, there is a value, and it is a
                % lognumscalar. The trick here is that if the flagname is
                % negated, the value of the flag is the inverse of the
                % value, hence the use of xor (use a truth table to check)
                i = i + 1;
                keyval.(key_names{ikey}) = xor(isnegflagname(ipos),logical(args{i}));
            end
        else
            % Keyword-value pair
            % The logic here insists that next value is the keyword value,
            % even if it is a valid keyword. That is, we assume that the
            % user meant to give a string value that is the same as a
            % keyword rather than they forgot to give the value
            if i<narg
                i = i + 1;
                keyval.(key_names{ikey}) = args{i};
            else
                error('HERBERT:parse_args:invalid_argument',...
                    ['Keyword ''',key_names{ikey},...
                    ''' expects a value, but the keyword is the final argument'])
            end
        end
        expect_key = opt.keys_at_end;   % if true, will expect only keywords from now
    end
    i = i + 1;
end

% Searched the argument list. Now pack final output
if npar >= npar_req
    if isempty(par_names)
        % Parameters are not named
        par = args(ispar);
        for i=1:npar
            if is_string(par{i})
                par{i} = strip_prefix_ctrl (par{i}, key_names_all,...
                    opt.prefix, opt.prefix_ctrl, opt.prefix_req, opt.keys_exact);
            end
        end
        present = cell2struct(num2cell(key_present), key_names);
    else
        % Parameters are named
        par = par_default;
        if npar>0
            ix = find(ispar);
            for i = 1:npar
                if ~is_string(args{ix(i)})
                    par.(par_names{i}) = args{ix(i)};
                else
                    par.(par_names{i}) = strip_prefix_ctrl (args{ix(i)}, key_names_all,...
                        opt.prefix, opt.prefix_ctrl, opt.prefix_req, opt.keys_exact);
                end
            end
            par_present = [true(npar,1); false(npar_max-npar, 1)];
            present = cell2struct(num2cell([par_present; key_present]), [par_names; key_names]);
        else
            present = cell2struct(num2cell(key_present), key_names);
        end
    end
else
    error('HERBERT:parse_args:invalid_argument',...
        ['The number of positional parameter(s) is less than the ',...
        'minimum request of ',num2str(npar_req)])
end

npar_names = numel(par_names);
filled = false (npar_names + nkey, 1);
for i = 1:npar_names
    if ~isempty(par.(par_names{i}))
        filled(i)=true;
    end
end
for i = 1:nkey
    if ~isempty(keyval.(key_names{i}))
        filled(i+npar_names)=true;
    end
end
filled=cell2struct(num2cell(filled),[par_names; key_names]);


%----------------------------------------------------------------------------------------
function val_out = strip_prefix_ctrl (val, key_names_all,...
    prefix, prefix_ctrl, prefix_req, keys_exact)
% Strip prefix control character from character string
%
%   val_out = strip_prefix_ctrl (val, key_names_all,...
%                   prefix, prefix_ctrl, prefix_req, keys_exact)
%
% Only need to call if prefix_ctrl is non-empty
%
% Input:
% ------
%   val             Character string parameter value
%                   Recall there is nothing to check if empty, but this
%                   function will work even if val is empty
%                   [Assumed not to match any entry in key_names - should
%                   have previously been determined to be a keyword]
%
%   key_names_all   Cell array of all possible keyword names (including
%                   with prefix and/or negation if either are permitted)
%
%   prefix          Prefix string
%                   [Recall that this will be non-empty if prefix_ctrl is
%                    non-empty]
%
%   prefix_ctrl     Prefix control character
%                   Recall there is nothing to check if empty, but this
%                   function will work even if prefix_ctrl is empty
%                   [Recall if present it is a single non-alphanumeric character]
%
%   prefix_req      True if prefix character is required, false if not.
%                   [Recall it is ignored if prefix is empty]
%
% Output:
% -------
%   val_out         val stripped of control character
%
%
% Explanation of algoirthm:
% -------------------------
% If this function is called we know that the value is a positional parameter,
% and so all we need to do is strip off (possibly multiple repetitions of)
% the control character that would have been used to prevent it from being
% interpreted as a keyword in the first place.
%
% The only legal place to have used the control character is when without
% it a positional argument could have been interpreted as a keyword e.g.
% if 'bob' is a keyword, then we would type '\bob' (where '\' is the
% prefix_ctrl character) in order for the string to be recognised as a
% positional parameter; the '\' will be stripped away.
%
% In detail: to implement we need to consider various cases. For
% definiteness in the explanation below, take the prefix as '-' and the
% control as '\' or '-'.
%
% - If a prefix is required and the prefix is non-empty:
%    - If the prefix_ctrl ('\') is not the same as the prefix ('-'):
%           want:   'bob'       give:   'bob'       (as not a keyword)
%                   '\bob'              '\bob'      (as not a keyword)
%                   '\\bob'             '\\bob'     (as not a keyword)
%                      :                   :                :
%                   '-bob'              '\-bob'
%                   '\-bob'             '\\-bob'
%                   '\\-bob'            '\\\-bob'
%                      :                   :
%
%    - If the prefix_ctrl ('-') *is* the same as the prefix:
%           want:   'bob'       give:   'bob'       (as not a keyword)
%                   '-bob'              '--bob'
%                   '--bob'             '---bob'
%                      :                   :
%
% - If the prefix is not required (prefix_req==false):
%    - If the prefix_ctrl ('\') is not the same as the prefix ('-'):
%           want:   'bob'       give:   '\bob'
%                   '\bob'              '\\bob'
%                   '\\bob'            '\\\bob'
%                      :                   :
%                   '-bob'              '\-bob'
%                   '\-bob'             '\\-bob'
%                   '\\-bob'            '\\\-bob'
%                      :                   :
%
%    - If the prefix_ctrl ('-') *is* the same as the prefix:
%           want:   'bob'       give:   '-bob'  but this is not allowed, as
%                                               is a keyword
%             so:   'bob'               '--bob' a possible solution?
%    No: if want:   '-bob'      give:   '--bob' by meaning of a ctrl flag
%        which is therefore ambiguous: do we want 'bob' or '-bob' ?
%
%    We therefore demand elsewhere that if ~prefix_req then prefix and
%    prefix_ctrl cannot be the same.


if ~isempty(prefix_ctrl)
    % Control character given
    ind = find(val~=prefix_ctrl, 1);    % index of first non-ctrl character
    if ind==1
        % No leading control characters, so nothing to parse
        val_out = val;
    else
        if ~strcmpi(prefix, prefix_ctrl)
            val_test = val(ind:end);
        elseif prefix_req
            val_test = val(ind-1:end);
        else
            % Final ctrl character is actually the prefix string
            % If a non-empty prefix is optional, we forbid the case of it being
            % the same as the prefix control character. This should have been
            % tested outside this function, but catch as an error here for surety.
            error('HERBERT:strip_prefix_ctrl:invalid_argument',...
                ['If a non-empty prefix is optional, then it cannot match ',...
                'the prefix control character'])
        end
        if ~isempty(val_test) && any(stringmatchi(val_test, key_names_all, keys_exact))
            % The tests with stringmatchi must be the same as that used in
            % parse_args_main to test if a character string is a keyword
            % If the determination of a putative keyword is multifold, this
            % is not an error, because we assume that the user used the
            % control character to pre-empt ambiguity between a positional
            % parameter and a keyword.
            val_out = val(2:end);
        else
            val_out = val;
        end
    end
else
    % Catch case of no control character - should have been caught outside this
    % function, but for surety check here
    val_out = val;
end


%----------------------------------------------------------------------------------------
function str=disp_string(var)
% Encapsulate information about unexpected variable as a string

nchar_max=20;
if is_string(var)
    if isempty(var)
        str='empty string';
    else
        if numel(var)<=nchar_max
            str=['string ''',var,''''];
        else
            str=['string ''',var(1:nchar_max),'...'''];
        end
    end
else
    if isscalar(var)
        str=['argument of class ',class(var)];
    else
        str=['argument size ',mat2str(size(var)),' of class ',class(var)];
    end
end


%----------------------------------------------------------------------------------------
function [ok, par, keyval, present, filled] = error_return
% Default output if there is an error. For legacy output format
ok = false;
par = {};     % this could be erroneous type if parameters are named
keyval = struct([]);
present = struct([]);
filled = struct([]);
