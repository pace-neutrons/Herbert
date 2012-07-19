function wout = unspike_z (w,varargin)
% Remove points deemed to be spikes along the z axis, and replace with values interpolated between good points
%
%   >> wout = unspike_z (w)
%   >> wout = unspike_z (w,smin,smax,fac,sigmafac)    % set to '' or [] to use default value of any argument
%
% Input:
% ------
%   w       Input IX_dataset_3d or array of IX_dataset_3d
%   smin    Lower filter (all points less than this will be removed) NaN or -Inf to ignore (default)
%   smax    Upper filter (all points greater than this will be removed) NaN or Inf to ignore (default)
%   fac     Peak threshold factor (default=2):
%               A point is a spike if signal is smaller or larger than both neighbours by this factor,
%              all three signals with same sign and satisfies 
%  sigmafac Peak fluctuation threshold (default=5):
%               A point is a spike if differs from it neighbours by this factor of standard deviations,
%              differeing by the same sign
%
%   Both the peak threshold and peak fluctuation criteria must be satisfied.
%
% Output:
% -------
%   wout    IX_dataset_3d or array of IX_dataset_3d with spikes removed

wout=w;
for i=1:numel(w)
    if numel(w(i).signal)>0    % if empty data, dont do anything
        if ishistogram(w(i),3)
            zc=0.5*(w(i).z(1:end-1)+w(i).z(2:end));
            [wout(i).signal,wout(i).error]=unspike_xye_n(3,zc,w(i).signal,w(i).error,varargin{:});
        else
            [wout(i).signal,wout(i).error]=unspike_xye_n(3,w(i).z,w(i).signal,w(i).error,varargin{:});
        end
    end
end
