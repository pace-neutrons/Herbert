function [out,varargout]= get(this,varargin)
% Get values of one or more fields from a configuration class
%
%   >> S = get(config_obj)      % returns a structure with the current values
%                               % of the fields in the requested configuration object
%

%   >> S = get(config_obj,'defaults')   % returns the defaults this
%                                       % configuration has
%
%   >> [val1,val2,...] = get(config_obj,'field1','field2',...); % returns named fields
%
%
%
% This is deprecated function kept for compatibility with old interface

% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)
options = {'-public','defaults'};
[ok,mess,public,defaults,fields_to_get]=parse_char_options(varargin,options);
if ~ok; error('CONFIG_BASE:get',mess); end
% public field is not currently used
if defaults
    if numel(fields_to_get) == 0
        out = this.get_defaults();
        return;
    else
        this.returns_defaults = true;
    end
end
if numel(fields_to_get) == 0 % form 1
    out = this.get_data_to_store();
    return;
end

out = this.(fields_to_get{1});
for i=2:nargout
    varargout{i-1} = this.(fields_to_get{i});
end


