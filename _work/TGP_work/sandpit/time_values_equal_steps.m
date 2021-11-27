function s = time_values_equal_steps (n)

s = rng;
rng(0);

x1 = rand(1,n);
del = 0.5*(1+rand(1,n));
x2 = 10*(1+rand(1,n));
origin = 'x1';
tol = 0.01;

s = 0;
tic
for i=1:n
    [np, xout] = values_equal_steps_ref (x1(i), del(i), x2(i), origin, tol);
    s = s + np + xout(6);
end
toc


s = 0;
tic
for i=1:n
    [np, xout] = values_equal_steps (x1(i), del(i), x2(i), origin, tol);
    s = s + np + xout(6);
end
toc


