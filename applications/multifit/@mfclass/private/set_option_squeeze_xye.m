function [val, ok, mess] = set_option_squeeze_xye (val_in)
% Set 'squeeze_xye' option
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
% $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)


ok=true;
mess='';
if nargin==0
    % Default
    val = false;
    
else
    % Check values are OK
    if islognumscalar(val_in)
        val = logical(val_in);
    else
        [val,ok,mess] = set_option_error_return('''squeez_xye'' option must a logical scalar (or numeric 0 or 1)'); return
    end
end
