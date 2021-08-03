function [xb, status] = bin_boundaries (xc, varargin)
% Return bin boundaries given a vector of bin centres
%
%   >> xb = bin_boundaries (xc)             % default solution method
%
%   >> xb = bin_boundaries (xc, '-lsqr')    % specific solution method
%   >> xb = bin_boundaries (xc, '-maxent')  % specific solution method
%
%   >> [xb, status] = bin_boundaries (...)  % true boundaries status
%
% In the case where true bin boundaries cannot be found (see notes below),
% then bin boundaries are returned as the mid-points between the points in
% xc, and the status flag is set to false.
%
%
% Input:
% ------
%   xc      Vector of bin centres; must be monotonic increasing.
%           Must have at least one bin centre.
%
%   opt     Solution method (see notes for details)
%               '-lsqr'     Minimise the deviation between the half-way
%                           points between the bin centres and xb(2:end-1)
%                           [DEFAULT]
%
%               '-maxent'   Maximise the entropy as defined by the ratios
%                           of the computed bin widths dx = diff(xb)
%                               s = sum (dx .* log(dx))
%
%           If the bin centres are equally spaced, both methods produce
%           equally spaced bin boundaries.
%
%           If a solution could not be found, then bin boundaries are 
%           returned as the mid-points between the points in xc, and the
%           status flag is set to false.
%
% Output:
% -------
%   xb      Vector of bin boundaries; same orientation (i.e row or column)
%           as input.
%           If one point only, then bin boundaries are set to [x-0.5,x+0.5]
%           i.e. assumes row priority)
%
%   status  Status flag:
%           = true      if a true solution for bin boundaries was found
%           = false     if bin boundaries at the mid-points were returned
%
% Notes:
% - Generally, a set of bin centres does not define a unique set of bin 
%   boundaries. For example the bin centres are [8,16,20] for both sets
%   of bin boundaries [3,13,19,21] and [2,14,18,22]. In fact there is a 
%   continuum of possible bin boundaries. This algorithm provides two
%   different methods that aim to minimise the spread of the bin
%   boundary widths.
%
% - Not every vector of points has a solution for bin boundaries, for
%   example the points [2,3,8,9] has no solution.


reltol = 2e-15;

status = true;  % assume the best!
if isvector(xc) && numel(xc)>=1
    if numel(xc)>1
        del = diff(xc);
        if ~any(del<0)
            % At least two points; centres are monotonically increasing
            
            % Catch case of equally spaced bin centres
            xb = bin_boundaries_bin_widths_equal (xc, del, reltol);
            
            % Try general algorithm if unequally spaced
            if isempty(xb)
                xb = bin_boundaries_solve (xc, varargin{:});
            end
            
            % Set bin boundaries to halfway points if no solution found
            if isempty(xb)
                xb = bin_boundaries_halfway (xc);
                status = false;
            end
        else
            error ('HERBERT:bin_boundaries:invalid_input',...
                'Bin centres must be monotonic increasing')
        end
        
    else
        xb = [xc-0.5, xc+0.5];
    end
    
else
    error ('HERBERT:bin_boundaries:invalid_input',...
        'Bin centres must be a vector with at least one element')
end


%========================================================================================
function xb = bin_boundaries_bin_widths_equal (xc, del, reltol)
% Return bin boundaries if widths are equal within a relative tolerance
%
%   >> xb = bin_boundaries_bin_widths_equal (xc, del, reltol)
%
% Input:
% ------
%   xc      Bin centres (vector; assumes at least two elements and
%          monotonic increasing)
%
%   del     diff(xc)
%
%   reltol  Relative tolerance (positive number e.g. 2e-15)
%
% Output:
% -------
%   xb      Computed bin boundaries. If the bin centres and boundaries are
%          all integers, then the algorithm will return exact bin
%          boundaries.
%           The orientation of the vector xb is the same as xc.
%           
%           If the points are not all equally spaced, then xb==[]


% Compute bin boundaries as a row
del0 = (xc(end)-xc(1))/(numel(xc)-1);
if del0 > 0
    if all((del-del0)/del0 < reltol)
        % Compute bin boundaries, exact for case when integer bin boundaries
        nb = numel(xc)+1;   % number of bin boundaries
        xb = (xc(1) * (2*nb-3:-2:-1) + xc(end) * (-1:2:2*nb-3)) / (2*nb-4);
    else
        xb = [];
        return
    end
else
    xb = xc(1)*ones(1, numel(xc)+1);
end

% Get correct orientation
if size(xc,2)==1    % is a column
    xb = xb(:);
end


%========================================================================================
function xb = bin_boundaries_solve (xc, opt)
% Solve for bin widths in general case
%
%   >> xb = bin_boundaries_solve (xc)
%   >> xb = bin_boundaries_solve (xc, opt)
%
% Input:
% ------
%   xc      Bin centres (vector; assumes at least two elements and
%          monotonic increasing)
%
%   opt     Solution method:
%               '-lsqr'     Minimise the deviation between the half-way
%                           points between the bin centres and xb(2:end-1)
%
%               '-maxent'   Maximise the entropy as defined by the ratios
%                           of the computed bin widths dx = diff(xb)
%                               s = sum (dx .* log(dx))
%                           
%
% Output:
% -------
%   xb      Computed bin boundaries. The orientation of the vector xb is
%          the same as xc.
%           If unable to find a solution, then xb = []

if nargin==1
    opt = '-lsqr';
end

% Under-determined particular solution to 2*xc(i) = xb(i) + xb(i+1)
% Use sparse matrix in case of large number of bin boundaries
n = numel(xc);
B = spdiags(ones(n,2),[0,1],n,n+1);
xb0 = 2*(B\xc(:));  % solves: B * xb0 = 2 * xc(:)

% Homogeneous solution: can add arbirary amounts of solution to B * xb = 0
% This solution is (within an arbitrary non-zero constant) [1,-1,1,-1,...]'
% i.e. xb = xb0 + lam*[1,-1,1,...]'/2
%   xb(1) = xb0(1) + lam/2
%   xb(2) = xb0(2) - lam/2
%   xb(3) = xb0(3) + lam/2
%     :       :        :
% To retain the order of the bin boundaries, this imposes limits on the
% range of lam to retain the order xb(i+1) >= xb(i)
dx = diff(xb0);
lam_min = max(-dx(2:2:numel(dx)));
lam_max = min(dx(1:2:numel(dx)));

if lam_min < lam_max
    % Find a solution according to a cost function
    [lam, ~, exitflag] = fminbnd(...
        @(lam)(binopt_cost_function(lam, xb0, xc(:), opt)),...
        lam_min, lam_max, optimset('Display','none','TolX',1e-12));
%==========================================================
% Useful for debugging:
%
%     [lam, ~, exitflag, output] = fminbnd(...
%         @(lam)(binopt_cost_function(lam, xb0, xc(:), opt)),...
%         lam_min, lam_max, optimset('Display','iter','TolX',1e-12));
%     lams=[lam_min,lam,lam_max]
%     diff(lams)
%==========================================================
    if exitflag==1
        % Converged to a solution
        xb = xb_calc (xb0, lam);
        
        % Check that the solution is valid (as was numerical solution,
        % rounding errors may have resulted in a problem
        if any(diff(xb)<0)
            xb = [];
            return
        end
    else
        xb = [];
        return
    end
    
elseif lam_min == lam_max
    % Unique solution
    xb = xb_calc(xb0, lam_min);
    
else
    % No solution is possible
    xb = [];
    return
end

% Get correct orientation
if size(xc,1)==1    % input bin centres form a row vector
    xb = xb';
end


%--------------------------------------------------------------------------
function cost = binopt_cost_function (lam, xb0, xc, opt)
% Cost function to be minimised 
%
%   >> cost = binopt_cost_function (lam, xb0, xc)
%
% Input:
% ------
%   lam     Independent variable
%   xb0     Particular solution for lam=0
%   xc      Input bin centres
%
% Output:
% -------
%   C       Value of cost function

xb = xb_calc(xb0, lam);

if strcmpi(opt,'-lsqr')
    % Square of deviation of mid-points between centres and solution for xb
    xmid = (xc(2:end) + xc(1:end-1))/2;     % mid-points of bin centres
    cost = sum((xb(2:end-1) - xmid).^2);
    
elseif strcmpi(opt,'-maxent')
    % Maximum entropy
    dx = diff(xb) / (xb(end) - xb(1));  % normalised bin widths
    cost = sum(dx.*log(dx));    % +ve sign to give (-entropy)
    
else
    error ('HERBERT:bin_boundaries:invalid_input',...
        ['Invalid solution method: ''',opt,''''])
end


%--------------------------------------------------------------------------
function xb = xb_calc (xb0, lam)
% General solution to bin boundaries: xb = xb0 + lam*[1,-1,1,...]'/2
xb = xb0;
xb(1:2:numel(xb)) = xb0(1:2:numel(xb)) + lam/2;
xb(2:2:numel(xb)) = xb0(2:2:numel(xb)) - lam/2;


%========================================================================================
function xb = bin_boundaries_halfway (xc)
% Return bin boundaries if widths are equal within a relative tolerance
%
%   >> xb = bin_boundaries_halfway (xc, del, reltol)
%
% Input:
% ------
%   xc      Bin centres (vector; assumes at least two elements and
%          monotonic increasing)
%
% Output:
% -------
%   xb      Computed bin boundaries. If the bin centres and boundaries are
%          all integers, then the algorithm will return exact bin
%          boundaries.
%           The orientation of the vector xb is the same as xc.


% Exact if xc and xb are integers (as divide by 2, not multiply by 0.5)
if size(xc,1)==1    % is a row
    xb = [2*xc(1)-(xc(2)-xc(1)), (xc(2:end) + xc(1:end-1)),...
        2*xc(end)+(xc(end)-xc(end-1))] / 2;
else
    xb = [2*xc(1)-(xc(2)-xc(1)); (xc(2:end) + xc(1:end-1));...
        2*xc(end)+(xc(end)-xc(end-1))] / 2;
end
