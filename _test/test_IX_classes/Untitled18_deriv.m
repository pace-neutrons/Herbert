function [S,Snew] = Untitled18_deriv (npnt, n_integration)
%% ------------------------------------------------------------------------
% Time differentiation
% -------------------------------------------------------------------------

% Test if the old method without reshaping is much faster

nx = npnt;
ni = n_integration;

x = (1:nx) + 0.1*rand(1,nx);
y = rand(ni,nx);
e = rand(ni,nx);

S = 0;
tic
for i=1:ni
    yin = y(i,:);
    ein = e(i,:);
    [yd, ed] = deriv_xye (x, yin, ein);
    S = S + yd(4) + ed(4);
end
toc

idim = 2;
Snew = 0;
tic
for i=1:ni
    yin = y(i,:);
    ein = e(i,:);
    [ydnew, ednew] = deriv_points (x, yin, ein, idim);
    Snew = Snew + ydnew(4) + ednew(4);
end
toc

[isequal(yd,ydnew), isequal(ed,ednew)]

