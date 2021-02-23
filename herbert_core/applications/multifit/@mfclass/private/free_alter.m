function Sfun = free_alter (Sfun_in, isfore, indfun, free)
% Fix/free parameters
%
%   >> Sfun = free_alter (Sfun_in, isfore, indfun)          % set to defaults
%   >> Sfun = free_alter (Sfun_in, isfore, indfun, free)
%
% Input:
% ------
%   Sfun_in Functions structure: fields are
%               foreground_is_local_, fun_, pin_, np_, free_
%               background_is_local_, bfun_, bpin_, nbp_, bfree_
%   isfore  True if foreground functions, false if background functions
%   indfun  Row vector if indicies of functions to which elements of
%          argument free refer. Can be empty.
%
% Optional:
%   free    Cell array of logical row vectors, where the number of elements
%          of the ith vector equals the number of parameters for the
%          function given by indfun(i), and with elements =true for free
%          parameters, =false for fixed parameters. Length of free must be
%          the same as indfun.
%           If not given, then all parameters are set to float for
%          functions given by indfun
%
% Output:
% -------
%   Sfun    Functions structure on output: fields are
%               foreground_is_local_, fun_, pin_, np_, free_
%               background_is_local_, bfun_, bpin_, nbp_, bfree_
%
%
% It is assumed that the input is consistent with the information in Sfun_in
% i.e. the number of parameters for each function, the number of functions etc.


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


% Fill output with default structure
Sfun = Sfun_in;
if isempty(indfun)  % nothing to alter
    return
end

% Replace logical arrays
if isfore
    if is_def('free')
        Sfun.free_(indfun) = free;
    else
        np = Sfun.np_(indfun);
        Sfun.free_(indfun) = mat2cell(true(1,sum(np)),1,np);
    end
else
    if is_def('free')
        Sfun.bfree_(indfun) = free;
    else
        np = Sfun.nbp_(indfun);
        Sfun.bfree_(indfun) = mat2cell(true(1,sum(np)),1,np);
    end
end

