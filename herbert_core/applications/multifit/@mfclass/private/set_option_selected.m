function [val, ok, mess] = set_option_selected (val_in)
% Set 'selected' option
%
% Standard format function: must allow the following:
%
% Fill default:
%   >> [val, ok, mess] = set_option_optname
%
% Set value, checking if ok and parsing if necessary; mess='' if OK, error message if not
%   >> [val, ok, mess] = set_option_optname (val_in)


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


ok=true;
mess='';
if nargin==0
    % Default
    val = true;
    
else
    % Check values are OK
    if islognumscalar(val_in)
        val = logical(val_in);
    else
        [val,ok,mess] = set_option_error_return('''selected'' option must a logical scalar (or numeric 0 or 1)'); return
    end
end

