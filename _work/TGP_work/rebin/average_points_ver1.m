function [xave, sout, eout] = average_points (x, s, e, idim, xout, alldata)
% Average point data along one dimension of signal and error arrays
%
%   >> [xave, sout, eout] = average_points (x, s, e, idim, xout)
%
%   >> [xave, sout, eout] = average_points (x, s, e, idim, xout, alldata)
%
%
% Input:
% ------
%   x       Positions of points to be averaged in bins (row or column
%          vector).
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
%           Vector with same orientation as xout.
%           - alldata==true:  average of x-values of contributing points,
%                             and bin centres where no contributing points
%           - alldata==false: average of x-values of contributing points;
%                             the other bins are eliminated
%
%   sout    Averaged signal array. The size of the array is the same as
%          the input array except for dimension number idim, which has
%          extent equal to the number of output points i.e. (numel(xave)-1).
%
%   eout    Standard deviations on averaged signal. Has the same size as
%          the rebinned signal array, sout.

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

% Check optional parameter
if nargin==6
    if islognumscalar(alldata)
        alldata = logical(alldata);
    else
        error('HERBERT:average_points:invalid_argument',...
            'Optional argument ''alldata'' must be logical true or false (or 1 or 0)')
    end
else
    alldata = false;
end


% Perform averaging
% -----------------
% Find the first output bin to which there is a contribution from the input
% data and find the index of the first point which makes that contribution

% - Smallest iin such that xout(1) =< x(iin)
iin = lower_index(x, xout(1));
% % - Largest iin such that x(iin) <= xout(end)
% iin_end = upper_index(x, xout(end));
% - Largest index such that xout(iout) <= x(1), or unity if xout(1)>x(1):
iout= max(1, upper_index(xout, x(1)));

if iin==mx+1 || iout==nx+1
    % Return if there is no overlap between x and xout
    sout = zeros(sz_out);
    eout = zeros(sz_out);
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
xave = zeros(1,nx);
npnt = zeros(1,nx);
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
            if npnt(iout)>0
                xave(iout) = xave(iout) / npnt(iout);
                sout(:,iout) = sout(:,iout) / npnt(iout);
                eout(:,iout) = sqrt(eout(:,iout)) / npnt(iout);
            end
            break
        end
    else
        % Increment output bin counter; break if no further bins
        if npnt(iout)>0
            xave(iout) = xave(iout) / npnt(iout);
            sout(:,iout) = sout(:,iout) / npnt(iout);
            eout(:,iout) = sqrt(eout(:,iout)) / npnt(iout);
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
        xave(~filled) = xcent(~filled) ;
    else
        % Recompute nx and sz_out as we will eliminated points
        nx = sum(filled);
        sz_out = [sz(1:idim-1), nx, sz(idim+1:end)];
        xave = xave(filled);
        sout = sout(:,filled);
        eout = eout(:,filled);
    end
end

% Reshape output arrays
sout = reshape(sout, [prod(sz(idim+1:end)), prod(sz(1:idim-1)), nx]);
eout = reshape(eout, [prod(sz(idim+1:end)), prod(sz(1:idim-1)), nx]);
sout = permute(sout, [2,3,1]);
eout = permute(eout, [2,3,1]);
sout = reshape(sout, sz_out);
eout = reshape(eout, sz_out);
