function x = sigvar_getx (obj)
% Get bin centres for the object
%
%   >> x = sigvar_getx (w)
%
% Input:
% ------
%   obj     Input object
%
% Output:
% -------
%   x       Arrays with point positions for each coordinate axis. Each array
%           has the same size as the signal array.
%           - one-dimensional object: column vector of point positions
%           - two or more dimensions: cell array of arrays, one per axis


nd = obj.ndim();    % works even if empty obj array, as static method

xyz = obj.xyz_;
ishist = ishistogram_(obj);

if nd==1
    % Catch case on one-dimensions for simplicity
    if ishist
        x = bin_centres (xyz{1}(:));
    else
        x = xyz{1}(:);
    end
else
    % Two or more dimensions
    x = cell(1,nd);
    xvectors = cell(1,nd);
    for i=1:nd
        if ishist(i)
            xvectors{i} = bin_centres (xyz{i});
        else
            xvectors{i} = xyz{i};
        end
    end
    [x{:}] = ndgrid(xvectors{:});
end
