% Adds random noise to an <object> object or array of <object> objects
%
%   >> obj_out = <method> (obj)
%           Add noise with Gaussian distribution, with standard deviation
%           = 0.1*(maximum y value)
%
%   >> obj_out = <method> (obj, factor)
%           Add noise with Gaussian distribution, with standard deviation
%           = factor*(maximum y value)
%
%   >> obj_out = <method> (obj, 'poisson')
%           Add noise with Poisson distribution, where the mean value at
%           a point is the value y