function yout = time_waster (yin, nloop)
% Function to perform a very expensive operation that is almost an identity
%
%   >> yout = time_waster (yin)         % Perform the operation once
%   >> yout = time_waster (yin, nloop)  % perform the operation nloop times
%
% The output is an array in which each element differs by a factor of less
% than or equal to 10^-13 of the original, irrespective of the value of
% nloop.
%
% The time it takes for each loop is approximately 25x that of
% exponentiation.
%
% Input:
% ------
%   yin     Array of values
%   nloop   Number of times to perform the operation. If nloop <= 0 then
%           the operation is ignored.
%
% Output:
% -------
%   yout    Output array


if round(nloop)>0
    tiny = 1e-13;
    fac = 1;
    sz = size(yin);
    for i=1:round(nloop)
        fac = fac - tiny*rand(sz);
        fac = log(exp(fac) + tiny*rand(sz));
        fac = tan(atan(fac) - tiny*rand(sz));
        fac = asin(sin(fac) + tiny*rand(sz));
        fac = fac - 1;
        maxdev = max(abs(fac));
        if maxdev>0     % catch case of zero deviation
            fac = 1 + tiny*(fac./maxdev);
        else
            fac = 1;
        end
    end
    yout = yin .*fac;
    
else
    yout = yin;
end
