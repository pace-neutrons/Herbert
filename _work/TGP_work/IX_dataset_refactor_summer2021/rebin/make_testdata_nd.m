function [x,s,e] = make_testdata_nd (n, hist)
% Create arrays of x-s-e data with random x axes and signal
%
%   >> [x,s,e] = make_testdata_nd (n, hist)
%
% The objects are the same each time because the random number generator
% seed is always set to zero first (then set to incoming state afterwards)
%
% Input:
% -------
%   n           Array giving extent along each dimension
%   hist        Logical array, true if hist axis, false if point
%               Length is same as length of n
%
% Output:
% -------
%   x           Cell array of bin boundaries or centres for each axis
%               Length is same as length of n and hist
%   s           Signal array
%   e           Error array


% A big histogram array
% ------------------------------
ndim = numel(n);
if numel(hist)~=ndim || ~islognum(hist)
    error('Check length and type of ''hist''')
end

status = rng();
rng(0);

x = cell(1,ndim);
for i=1:ndim
    if hist(i)
        x{i} = (1:n(i)+1) + 0.2*rand(1,n(i)+1);
    else
        x{i} = (1:n(i)) + 0.2*rand(1,n(i));
    end
end
s = rand([n,1]);
e = 0.2*rand([n,1]);
rng(status)
