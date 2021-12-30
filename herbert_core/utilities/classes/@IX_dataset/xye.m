function S = xye (obj)
% Return a structure containing unmasked x,y,e arrays for an array of IX_dataset_2d objects
%
%   >> d=xye(w)
%
% Fields are:
%   d.x     x values: a cell array of arrays, one for each x dimension
%   d.y     y values
%   d.e     standard deviations


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
