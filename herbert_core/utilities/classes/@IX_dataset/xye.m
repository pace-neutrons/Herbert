function S = xye (obj)
% Return a structure containing unmasked x,y,e data
%
%   >> S = xye (obj)
%
% Input:
% ------
%   obj     Input object
%
% Output:
% -------
%   S       Structure containing x-y-e data with the following fields:
%               x   Arrays with point positions for each coordinate axis.
%                   - one-dimensional object: column vector
%                   - two or more dimensions: cell array of column vectors
%                     one vector per axis.
%
%               y   Signal values. Column vector
%
%               e   Standard deviation on signal values. Column vector


if numel(obj)==1
    S = xye_single (obj);
else
    S = repmat (struct('x',[],'y',[],'e',[]), size(obj));
    for i=1:numel(obj)
        S(i) = xye_single (obj(i));
    end
end


%--------------------------------------------------------------------------
function S = xye_single (obj)
% Return a structure containing unmasked x,y,e arrays for a single object

x = sigvar_getx (obj);
[s, var, msk] = sigvar_get (obj);

S = struct('x',[],'y',[],'e',[]);
if ~iscell(x)   % obj is one-dimensional
    S.x = x(msk);
else
    for i = 1:numel(x)
        S.x{i} = x{i}(msk); % if x is a matrix, msk is true same size => column
    end
end
S.y = s(msk);
S.e = sqrt(var(msk));
