%% ------------------------------------------------------------------------
% Test differentiation
% -------------------------------------------------------------------------

% 1D example
% ----------
nx = 1000;

x = (1:nx) + 0.1*rand(1,nx);
y = rand(1,nx);
e = rand(1,nx);

[yd, ed] = deriv_xye (x, y, e);

idim = 2;
[ydnew, ednew] = deriv_points (x, y, e, idim);

[isequal(yd,ydnew), isequal(ed,ednew)]


% 2D example
% ----------
nx1 = 10; nx2 = 15;

x = (1:nx2) + 0.1*rand(1,nx2);
y = rand(nx1,nx2);
e = rand(nx1,nx2);

[yd, ed] = deriv_xye_n (2, x, y, e);

idim = 2;
[ydnew, ednew] = deriv_points (x, y, e, idim);

[isequal(yd,ydnew), isequal(ed,ednew)]




% 4D example
% ----------
nx1 = 100; nx2 = 15; nx3 = 20; nx4 = 250;

x = (1:nx2) + 0.1*rand(1,nx2);
y = rand(nx1,nx2,nx3,nx4);
e = rand(nx1,nx2,nx3,nx4);

tic
[yd, ed] = deriv_xye_n (2, x, y, e);
toc

idim = 2;
tic
[ydnew, ednew] = deriv_points (x, y, e, idim);
toc

[isequal(yd,ydnew), isequal(ed,ednew)]


%% ------------------------------------------------------------------------
% Time differentiation
% -------------------------------------------------------------------------

% Test if the old method without reshaping is much faster

nx = 1000;
ni = 10000;

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




