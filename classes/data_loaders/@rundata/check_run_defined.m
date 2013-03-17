function [undefined,fields_to_load,fields_from_defaults,fields_undef] = check_run_defined(run,fields_needed)
% Method verifies if all necessary run parameters are defined by the class
%
% >> [undefined,fields_to_load,fields_from_defaults,fields_undef] = check_run_defined(run,fields_needed)
%
% Input:
% ------
%   run             Initated instance of the rundata class
%   fields_needed   List of the fields to verify (optional). If absent,
%                  it is derived from the class method.
%
% Output:
% -------
%   undefined       Status flag:
%                     0  - all data defined and loaded to memory
%                     1  - all data defined but some fields have to be read from file
%                     2  - some fields are needed, but no definition for them can be
%                          found in memory, file or from defaults
%
%   fields_to_load  Cellarray of field names which have to be loaded from file
%   fields_from_defaults    Cellarray of field names for which the values were
%                          loaded from hard-coded defaults
%   fields_undef    Cellarray of the fields which are unfilled

% $Author: Alex Buts; 20/10/2011
%
% $Revision$ ($Date$)


undefined           = 0; % false; all defined;
fields_to_load      ={};
fields_from_defaults={};

% Check if all necessary fields are already provided
s=warning('off','MATLAB:structOnObject');
all_values    = struct2cell(struct(run));
is_undef      = cellfun(@is_empty,all_values);
all_fields    = fields(run);
warning(s.state,'MATLAB:structOnObject');

% If everything is defined, no point to bother, finish
fields_undef  = all_fields(is_undef);
if isempty(fields_undef)
    return;
end

% What fields have to be defined (as function of crystal/powder parameter)?
if ~exist('fields_needed','var')
    fields_needed = what_fields_are_needed(run);
end

% Only some of undefined fields are needed to define run
is_needed     = ismember(fields_undef,fields_needed);
fields_undef  = fields_undef(is_needed);
if isempty(fields_undef)
    return;
end

% Something still undefined, let's check if we can deal with it;
undefined = 1;

% Can missing fields be obtained from data loader?
loader_provides = defined_fields(run.loader);
is_in_loader    = ismember(fields_undef,loader_provides);
if sum(is_in_loader)>0
    fields_to_load=fields_undef(is_in_loader);
else
    fields_to_load={};
end

% If we can obtain everything we need from a file?
fields_undef = fields_undef(~is_in_loader);
if isempty(fields_undef) % we can load everything
    fields_from_defaults={};
    return;
end

% Do the missing fields have defaults?
have_defaults        = ismember(fields_undef,run.fields_have_defaults);
fields_from_defaults = fields_undef(have_defaults);
% and now something else left:
fields_undef = fields_undef(~have_defaults);
% necessary fields are still undefined by the run
if ~isempty(fields_undef)
    undefined = 2;
    if get(herbert_config,'log_level')>-1
        for i=1:numel(fields_undef)
            fprintf('Necessary field undefined: %s \n',fields_undef{i});
        end
        disp(['The field(s) above are neither defined by the data reader ',class(run.loader),' nor by the command line arguments\n']);
    end
    
end

function isit=is_empty(the_cell)
% the function which is applied to each element of cell array verifying if
% it is empty
isit=false;
if isempty(the_cell)
    isit=true;
end
