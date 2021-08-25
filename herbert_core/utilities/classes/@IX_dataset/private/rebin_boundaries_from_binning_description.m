function xout = rebin_boundaries_from_binning_description (xin,...
    is_descriptor, is_boundaries, xref, ishist)
% Get new bin boundaries from binning description
%
% If no retained input values and description ranges all finite:
%   >> xout = rebin_boundaries_from_binning_description (xdescr,...
%                                                           is_boundaries)
%
% General case:
%   >> xout = rebin_boundaries_from_binning_description (xdescr,...
%                                              is_boundaries, xref, ishist)

if is_descriptor
    xout = rebin_boundaries_from_descriptor (xin, is_boundaries,...
        xref, ishist);
else
    xout = rebin_boundaries_from_values (xin, is_boundaries, xref);
end
