function [ns, s, wkno] = map_from_arrays (specpar, repeat, wkno)
% Input:
% ------
%   specpar     Cell array with length
%               - 1: isp (spectrum number or array of spectrum numbers)
%               - 2: isp_lo, isp_hi (scalars, or arrays same length) with
%                    start and finish limits of a contiguous block of spectra.
%                    Note: can have isp_lo(i) > isp_hi(i), when the mapping
%                    of spectra to workspaces is in decreasing spectrum index
%               - 3: isp_lo, isp_hi, nstep (scalars or arrays)
%                    nstep is the ganging together of spectra; cannot be 0
%                    The sign of nstep determines if workspace number increases
%                    or decreases between groups.
%                    If nstep is scalar, then expanded to the same length as
%                    isp_lo and isp_hi.
%
%   repeat      Numeric size [m, 1] or [m, 2] where m=1 or m=number of blocks
%               of spectra

if numel(specpar)==1
    % Single spectrum or array of spectra, one spectrum per workspace
    isp = specpar{1};
    if all_positive_integers(isp)
        ns = numel(isp);    % if repeats, the default will be delta_isp +ve
        [nrepeat, delta_isp] = parse_repeat (numel(isp), repeat);
        nw = ns;
        [iw_beg, delta_wkno] = parse_wkno (nw, wkno);
    else
        error ('IX_map:map_from_arrays:invalid_argument',...
            'Spectra must all be integer and greater or equal to unity')
    end
    
elseif numel(specpar) <=3
    if numel(specpar)==2
        
        
    else
    end
    
else
    error ('IX_map:map_from_arrays:invalid_argument',...
        'Spectra must all be integer and greater or equal to unity')
    
    
    
    
end

end


%--------------------------------------------------------------------------
function [nrepeat, delta_isp] = parse_repeat (ns, repeat)
% Parse the repeat argument
%
%   >> [nrepeat, delta_isp] = parse_repeat (ns, repeat)
%
% Input:
% ------
%   ns      Vector length nblock containing the total number of spectra
%           in each block. The number of blocks is given by numel(ns).
%           Elements of ns are -ve where the
%
%   repeat  The repeat information. Possible sizes for repeat are
%           array size [m,1] or [m,2] where
%            - m=1      Use the same repeat information for all blocks
%            - m=nblock Repeat information can be different for each block
%
%           The contents fo the repeat block are:
%            - repeat(:,1)  Number of repeats in each block, nrepeat:
%                           Integers >= 1
%            - repeat(:,2)  Step in spectrum index between each repeat
%                           in the block, delta_isp:
%                           The step can be -ve
%                           Integers or NaNs; where elements are NaN
%                           they will be set to the corresponding values of
%                           ns to ensure a continuous list of spectra.

nblock = numel(ns);
sz = size(repeat);

% Check valid size of repeat
if ~(sz(1)==1 || sz(1)==nblock) || sz(2)<1 || sz(2)>2
    error ('IX_map:map_from_arrays:invalid_argument',...
        'Argument ''repeat'' must be a column vector length %s or array size [%s, 2]',...
        num2str(nblock))
end

% Expand repeat to required size, if necessary
if sz(2)==1
    repeat = [repeat, NaN(sz)];
end
if sz(1)~=nblock
    repeat = repmat(repeat,[nblock,1]);
end

% Check values
if all_positive_integers(repeat(:,1))
    nrepeat = repeat(:,1);
else
    error ('IX_map:map_from_arrays:invalid_argument',...
        'The value(s) of ''nrepeat'' must (all) be positive integer(s)')
end

if all_integer_or_nan(repeat(:,2))
    delta_isp = repeat(:,2);
    place_holder = isnan(delta_isp);
    delta_isp(place_holder) = ns(place_holder);
else
    error ('IX_map:map_from_arrays:invalid_argument',...
        'The value of ''nrepeat'' must be a positive integer')
end

end


%--------------------------------------------------------------------------
function [iw_beg, delta_iw] = parse_wkno (nw, wkno)
% Parse the workspace numbering argument
%
%   >> [iw_beg, delta_wkno] = parse_wkno (nw, wkno)
%
% Input:
% ------
%   nw      Vector length nblock containing the total number of workspaces
%           in each block. The number of blocks is given by numel(nw)
%
%   wkno    The workspace numbnering information. Possible sizes for repeat
%           are array size [m,1] or [m,2] where
%            - m=1      Use the same repeat information for all blocks
%            - m=nblock Repeat information can be different for each block
%
%           The contents fo the repeat block are:
%            - wkno(:,1)    Starting workspace number in each block, iw_beg:
%                           Integers >= 1
%            - wkno(:,2)    Step in workspace number between each repeat
%                           in the block, delta_iw:
%                           Integers or NaNs; where elements are NaN
%                           they will be set to the corresponding values of
%                           nw to ensure a continuous list of workspaces


nblock = numel(nw);
sz = size(wkno);

% Check valid size of repeat
if ~(sz(1)==1 || sz(1)==nblock) || sz(2)<1 || sz(2)>2
    error ('IX_map:map_from_arrays:invalid_argument',...
        'Argument ''wkno'' must be a column vector length %s or array size [%s, 2]',...
        num2str(nblock))
end

% Expand repeat to required size, if necessary
if sz(2)==1
    wkno = [wkno, NaN(sz)];
end
if sz(1)~=nblock
    wkno = repmat(wkno,[nblock,1]);
end

% Check values
if all_positive_integers(wkno(:,1))
    iw_beg = wkno(:,1);
else
    error ('IX_map:map_from_arrays:invalid_argument',...
        'The value(s) of ''iw_beg'' must (all) be positive integer(s)')
end

if all_integer_or_nan(wkno(:,2))
    delta_iw = wkno(:,2);
    place_holder = isnan(delta_iw);
    delta_iw(place_holder) = nw(place_holder);
else
    error ('IX_map:map_from_arrays:invalid_argument',...
        'The value of ''nrepeat'' must be a positive integer')
end

end

%--------------------------------------------------------------------------
function ok = all_positive_integers (isp)
% Check that all elements of an array are integers >=1
if numel(isp)==1
    ok = ~(~isfinite(isp) || rem(isp,1)~=0 || isp<1);
else
    ok = ~(~all(isfinite(isp(:))) || any(rem(isp(:),1)~=0) || any(isp(:)<1));
end

end

%--------------------------------------------------------------------------
function ok = all_integer_or_nan (isp)
% Check that all elements of an array are integers >=1 or are NaN
if numel(isp)==1
    ok = isnan(isp) || ~(~isfinite(isp) || rem(isp,1)~=0);
else
    ok = all(isnan(isp(:)) | ~(~isfinite(isp(:)) | rem(isp(:),1)~=0));
end

end
