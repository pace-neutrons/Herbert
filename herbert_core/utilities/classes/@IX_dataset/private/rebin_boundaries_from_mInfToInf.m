function xout = rebin_boundaries_from_mInfToInf (del, xref, tol)
% Bin boundaries for descriptor of form [-Inf,del,Inf]
%
%   >> xout = rebin_boundaries_from_mInfToInf (del, xref)
%
%   >> xout = rebin_boundaries_from_mInfToInf (del, xref, tol)
%
% Input:
% ------
%   del     Step size:
%               del > 0: equal size bins centred on x=0
%               del < 0: logarithmic bins centred on x=1
%
%   xref    Reference array of values. Assumed that it is strictly
%           monotonic increasing (i.e. all(diff(xref)>0). Used where
%           dx=0 in the descriptor.
%
%   tol     Tolerance: minimum size of first and final bins as fraction
%           of penultimate bins. Prevents overly small bins from being
%           created.
%               tol >= 0;    default = 1e-10
%
% Output:
% -------
%   xout    Bin boundaries with the outer bins determined by the full
%           data range. 


% *** This should use the algorithms for generating equally spaced and
%     logarithmic values for completeness of consistency should those
%     algorithms be changed to alter the tolerance levels, for example.


if nargin==2
    tol = 1e-10;    % fractional tolerance on bin width to account for rounding
else
    tol = abs(tol); % ensure >=0
end

xlo = xref(1);
xhi = xref(end);

if xlo==xhi
    xout = [xlo,xhi];   % case of a single point value input
    return
end

if del>0
    % Get measure w.r.t. boundary at x = del/2
    % Peculiar calculation for exactness if integer boundaries and tol=0
    
    nlo = ceil((2*xlo-del)/(2*del) + tol);
    nhi = floor((2*xlo-del)/(2*del) - tol);
    % If there are no values in the open interval (xlo,xhi) then nhi<nlo
    % but the following correcly given nlo:nhi as []
    xout = [xlo, del*((nlo:nhi)+0.5), xhi];
    
elseif del<0
    % The following algorithm is based on the fact that the bin centres 
    %       c(n) = r ^ n        (where r = c(n+1)/c(n) > 0)
    % can be created from bin boundaries
    %       b(n) = B * (r ^ n)  (so b(n+1)/b(n) = r)
    % where 
    %       B = 1/(1 + 1/r)    ratio = 1 + abs(del);
    
    B = 2/(1+1/ratio);     % smallest bin boundary greater than unity
    nlo = ceil(log(xlo/B)/log(ratio) + tol);
    nhi = floor(log(xhi/B)/log(ratio) - tol);
    % If there are no values in the open interval (xlo,xhi) then nhi<nlo
    % but the following correcly given nlo:nhi as []
    xout = [xlo, B*(ratio.^(nlo:nhi)), xhi];
    
else
    error('HERBERT:rebin_boundaries_from_mInfToInf:invalid_argument',...
        'Cannot have del = 0 if the data range is -Inf to Inf')
end
