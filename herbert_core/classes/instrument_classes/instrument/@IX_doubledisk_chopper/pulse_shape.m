function [y, t] = pulse_shape (obj, t)
% Calculate normalised chopper pulse shape as a function of time in microseconds
%
%   >> [y, t] = pulse_shape (obj)
%   >> y = pulse_shape (obj, t)
%
% Input:
% -------
%   obj     IX_doubledisk_chopper object (scalar)
%
%   t       Array of times at which to evaluate pulse shape (microseconds)
%           If omitted, a default suitable set of points for a plot is used
%
% Output:
% -------
%   y       Array of values of pulse shape.
%           Normalised so pulse area is transmission(disk)
%           Note that transmission(disk) is in fact unity independent of energy
%
%   t       If input was not empty, same as imput argument
%           If input was not given, the default set of points


if ~isscalar(obj)
    error('IX_doubledisk_chopper:pulse_shape:invalid_argument',...
        'Method only takes a scalar double disk chopper object')
end

[T1,T2] = hat_times(obj);

if ~exist('t', 'var')
    if T1==T2
        t = 0.5*[-(T1+T2), 0,(T1+T2)];
    else
        t = 0.5*[-(T1+T2),-(T2-T1),(T2-T1),(T1+T2)];
    end
end
y = conv_hh (t,T1,T2);

end
