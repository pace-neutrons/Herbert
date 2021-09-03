function [xave, sout, eout, npnt, kept] = average_points (x, s, e, idim,...
    xout, varargin)
% Average point data along one dimension of signal and error arrays
%
% Return average position and signal in bins with one or more points
%   >> [xave, sout, eout, nout, kept] = average_points (x, s, e, idim, xout)
%
% Options:
%   >> ... = average_points (..., 'alldata', TF,...)    % retain all bins
%   >> ... = average_points (..., 'sum', TF,...)        % sum (not average)
%   >> ... = average_points (..., 'integrate', TF,...)  % average * binwidth
%
%
% Input:
% ------
%   x       Positions of points to be averaged in bins (row or column
%          vector).
%           It is assumed that the values of x are monotonic increasing.
%          They need not be structly monotonic i.e. there can be points
%          with zero spacing.
%
%   s       Signal array. The extent along dimension idim must match the
%          number of points i.e. numel(x).
%
%   e       Standard deviations on the values in the signal array.
%          The sizes of the signal and error arrays must be the same
%
%   idim    Dimension of signal and error arrays to be rebinned (scalar).
%          Assumes idim >= 1.
%
%   xout    Output integration axis bin boundaries (row or column vector).
%           There must be at least two bin boundaries i.e. at least one bin.
%           It is assumed that the values of xout are strictly monotonic
%          increasing i.e. all bins have width greater than zero.
%           The averaged signal and standard deviation in the ith bin
%          i.e. from xout(i) to xout(i+1) are placed in the output arrays
%          at position i i.e. sout(i) and eout(i).
%
%   alldata Logical flag  [Default: false]
%           true:  Keep signal and error even where no contributing points
%                  to the bins defined by xout: their values will be set to
%                  zero.
%           false: Retain only the signal and error where there were
%                  contributing points.
%
% Output:
% -------
%   xave    Average values of x-coordinates of points in each bin.
%           Vector with same orientation as xout. If xout was scalar, and
%           xave is empty, then takes size [1,0] i.e. row priority.
%           - alldata==true:  average of x-values of contributing points,
%                             and bin centres where no contributing points
%           - alldata==false: average of x-values of contributing points;
%                             the other bins are eliminated. This means
%                             that it is possible for xave to be empty.
%
%   sout    Averaged signal array. The size of the array is the same as
%          the input array except for dimension number idim, which has
%          extent equal to the number of output points i.e. (numel(xave)-1).
%
%   eout    Standard deviations on averaged signal. Has the same size as
%          the rebinned signal array, sout.
%
%   npnt    Number of contributing points to each bin. Same size as xave.
%           - alldata==true:  Includes bins for which there were no
%                             contributing points. The input bins defined
%                             by xout that would be retained are given by
%                             keep = logical(nout).
%           - alldata==false: Only those bins for which there were
%                             contributing points
%
%   kept    Logical array (row vector) of those bins defined by xout that
%           were retained
%           - alldata==true:  All retained: kept = true(1,numel(xout))
%           - alldata==false: 

% The rebinning is performed by permuting and reshaping the signal and
% error arrays to size = [n,mx] where mx is the number of bins along the
% axis to be rebinned, and n = prod(size(s))/mx. The loop over bins for
% array sections in this 2D array turns out to be optimised by the Matlab
% JIT compiler (tested in R2021a on Dell 5540 mobile workstation running
% Win10, August 2021).


% Perform checks on input parameters and get size of output arrays
% ----------------------------------------------------------------
mx = numel(x);      % number of points along the input axis
if mx<1
    error('HERBERT:average_points:invalid_argument',...
        'The input point position array must have at least one value')
end

if numel(size(s))~=numel(size(s)) || ~all(size(s)==size(e))
    error('HERBERT:average_points:invalid_argument',...
        'The sizes of signal array (=[%s]) and error array (=[%s]) do not match',...
        str_compress(num2str(size(s)),','),...
        str_compress(num2str(size(e)),','))
end

nx = numel(xout) - 1;   % number of bins along the output rebin axis
if nx<1
    error('HERBERT:average_points:invalid_argument',...
        'The output bin boundary array must have at least two bin boundaries')
end

% Matlab size of signal array with trailing singletons if idim is larger
% than the dimension of input signal array, s
sz = [size(s), ones(1, idim-numel(size(s)))];

if sz(idim) ~= mx
    error('HERBERT:average_points:invalid_argument',...
        ['The extent of the signal array along axes number %s and the ',...
        'number of values in the input point position array is ',...
        'inconsistent with point data along that axis'], num2str(idim))
end

% Size of output arrays
% (note: any trailing singletons will be eliminated on allocation)
sz_out = [sz(1:idim-1), nx, sz(idim+1:end)];

% Check optional parameters
flagnames = {'alldata', 'sum', 'integrate'};
flags = parse_flags (flagnames, varargin{:});
alldata = flags(1);
integrate = flags(2);
sum_signal = flags(3);
if sum_signal && integrate
    error('HERBERT:average_points:invalid_argument',...
        'Cannot have both optional arguments ''sum'' and ''integrate''')
end 

% flagnames = {'alldata', 'sum', 'integrate'};
% flags = parse_flags (flagnames, varargin{:});
% alldata = flags.alldata;
% integrate = flags.integrate;
% sum_signal = flags.sum;
% if sum_signal && integrate
%     error('HERBERT:average_points:invalid_argument',...
%         'Cannot have both optional arguments ''sum'' and ''integrate''')
% end 


% Perform averaging
% -----------------
% Find the first output bin to which there is a contribution from the input
% data and find the index of the first point which makes that contribution

% - Smallest iin such that xout(1) =< x(iin)
iin = lower_index(x, xout(1));
% - Largest index such that xout(iout) <= x(1), or unity if xout(1)>x(1):
iout= max(1, upper_index(xout, x(1)));

if iin==mx+1 || iout==nx+1
    % Return if there is no overlap between x and xout
    if alldata
        xave = bin_centres(xout);
        sout = zeros(sz_out);
        eout = zeros(sz_out);
    else
        if isrowvector(xout)    % will be selected if xout is scalar too
            xave = zeros(1,0);
        else
            xave = zeros(0,1);
        end
        sz_out = [sz(1:idim-1), 0, sz(idim+1:end)];
        sout = zeros(sz_out);
        eout = zeros(sz_out);
    end
    npnt = zeros(size(xave));
    kept = false(size(xout));
    return
end

% Reshape input array for performing averaging to size [p,mx,q], permute
% axes to place the rebin axis at the end, and allocate output arrays
% (The following works for any length of sz and value of idim >=1, because
% prod([])=1)
s = reshape (s, [prod(sz(1:idim-1)), mx, prod(sz(idim+1:end))]);
e = reshape (e, [prod(sz(1:idim-1)), mx, prod(sz(idim+1:end))]);
s = permute(s,[3,1,2]);
e = permute(e,[3,1,2]);
s = reshape(s,[prod(sz)/mx, mx]);
e = reshape(e,[prod(sz)/mx, mx]);
sout = zeros([prod(sz)/mx, nx]);
eout = zeros([prod(sz)/mx, nx]);

% Perform the averaging
if isrowvector(xout)    % will be selected if xout is scalar too
    xave = zeros(1,nx);
    npnt = zeros(1,nx);
else
    xave = zeros(nx,1);
    npnt = zeros(nx,1);
end

while true
    if (xout(iout+1) > x(iin)) || ((iout == nx) && (xout(iout+1) == x(iin)))
        % Accumulate counts
        xave(iout) = xave(iout) + x(iin);
        sout(:,iout) = sout(:,iout) + s(:,iin);
        eout(:,iout) = eout(:,iout) + e(:,iin).*e(:,iin);
        npnt(iout) = npnt(iout) + 1;
        % Increment input point counter; break if no further points
        if iin < mx
            iin = iin + 1;
        else
            if ~(npnt(iout)==0 || sum_signal)
                xave(iout) = xave(iout) / npnt(iout);
                if integrate
                    dx_out = xout(iout+1) - xout(iout);
                    sout(:,iout) = sout(:,iout) * (dx_out / npnt(iout));
                    eout(:,iout) = sqrt(eout(:,iout)) * (dx_out / npnt(iout));
                else
                    sout(:,iout) = sout(:,iout) / npnt(iout);
                    eout(:,iout) = sqrt(eout(:,iout)) / npnt(iout);
                end
            end
            break
        end
    else
        % Increment output bin counter; break if no further bins
        if ~(npnt(iout)==0 || sum_signal)
            xave(iout) = xave(iout) / npnt(iout);
            if integrate
                dx_out = xout(iout+1) - xout(iout);
                sout(:,iout) = sout(:,iout) * (dx_out / npnt(iout));
                eout(:,iout) = sqrt(eout(:,iout)) * (dx_out / npnt(iout));
            else
                sout(:,iout) = sout(:,iout) / npnt(iout);
                eout(:,iout) = sqrt(eout(:,iout)) / npnt(iout);
            end
        end
        if iout < nx
            iout = iout + 1;
        else
            break
        end
    end
end

filled = (npnt>0);
if ~all(filled)
    if alldata
        % Fill xave for empty bins with the bin centres
        xcent = bin_centres(xout);
        xave(~filled) = xcent(~filled);
    else
        % Recompute nx and sz_out as we will eliminated points
        nx = sum(filled);
        sz_out = [sz(1:idim-1), nx, sz(idim+1:end)];
        if nx>0
            xave = xave(filled);
            npnt = npnt(filled);
        else
            % To ensure our convention of size [1,0] or [0,1]
            if isrowvector(xout)    % will be selected if xout is scalar too
                xave = zeros(1,0);  
            else
                xave = zeros(0,1);
            end
            npnt = zeros(size(xave));
        end
        sout = sout(:,filled);
        eout = eout(:,filled);
    end
end
kept = filled;

% Reshape output arrays
sout = reshape(sout, [prod(sz(idim+1:end)), prod(sz(1:idim-1)), nx]);
eout = reshape(eout, [prod(sz(idim+1:end)), prod(sz(1:idim-1)), nx]);
sout = permute(sout, [2,3,1]);
eout = permute(eout, [2,3,1]);
sout = reshape(sout, sz_out);
eout = reshape(eout, sz_out);
