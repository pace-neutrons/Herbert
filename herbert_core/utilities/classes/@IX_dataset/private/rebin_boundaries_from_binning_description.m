function xout = rebin_boundaries_from_binning_description (xin,...
    is_descriptor, is_boundaries, varargin)
% Get new bin boundaries from binning description
%
% If binning description is resolved (i.e. no -Inf or +Inf, and no binning
% interval in a descriptor requires reference values to be retained):
%   >> xout = rebin_boundaries_from_binning_description ...
%                                     (xdescr, is_boundaries)
%
% General case:
%   >> xout = rebin_boundaries_from_binning_description ...
%                                     (xdescr, is_boundaries, xref, ishist)

if is_descriptor
    xout = rebin_boundaries_from_descriptor (xin, is_boundaries, varargin{:});
else
    xout = rebin_boundaries_from_values (xin, is_boundaries, varargin{:});
end
