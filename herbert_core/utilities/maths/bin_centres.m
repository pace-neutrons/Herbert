function xc = bin_centres(xb)
% Get bin centres
%
%   >> xc = bin_centres (xb)
%
% Input:
% ------
%   xb      Vector of bin boundaries; must be monotonic increasing.
%           Must have at least one bin boundary.
%
%
% Output:
% -------
%   xc      Vector of point positions; same orientation (i.e row or column)
%          as input.
%           Set to zeros(1,0) if only one bin centre (i.e. assumes row
%          priority)


if isvector(xb) && numel(xb)>=1
    if numel(xb)==1
        xc = zeros(1,0);
    elseif ~any(diff(xb)<0)
        % Divide by 2 (rather than multiply by 0.5) to be exact for those
        % cases of integer boundaries where the centres are integer
        xc = (xb(2:end) + xb(1:end-1))/2;   
    else
        error ('HERBERT:bin_centres:invalid_input',...
            'Bin boundaries must be monotonic increasing')
    end
    
else
    error ('HERBERT:bin_centres:invalid_input',...
        'Bin boundaries must be a vector with at least one element')
end
