


bob = IX_dataset_1d (1:10, 101:110, 0.5*(1:10));


bert = integrate(bob, 3.5, 5.5);
assertEqualToTol(bert, struct('val',209,'err',3.221024681681282),1e-15)

bri = rebin(bob, [0,0.25,5]);
assertEqual(bri.x, 1:5)     % as point data
acolor b
dl(bob)
acolor r
ph(bri)


bobh = IX_dataset_1d (1:11, 101:110, 0.5*(1:10));


bri2 = rebin(bobh, [0,-0.1,5]);  % correctly fails

bri2 = rebin(bobh, [2,-0.2,5]);
acolor b
dl(bob)
acolor r
ph(bri2)
pm(bri2)


%---------------------------------------------
% Integrate a function

x = -6:0.1:6;
y = gauss_area (x, [1,0,0.5]);  % normed gaussian sigma=0.5

w1 = IX_dataset_1d (x,y)
dl(w1)

a = integrate (w1)

a = integrate (w1, [0,Inf])
