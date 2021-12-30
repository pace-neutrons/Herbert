% Check:
% - plain
% - with additional pars
% - plain with 'all'
% - hist axis, point axis
% - All the above with some masked out
%
% Make sure that the w have non-empty titles captions etc.



x = 1:10;
w1 = IX_dataset_1d(x,rand(size(x)),rand(size(x)));

wc = func_eval(w1, @gauss, [100,5,2]);




x1 = 1:10;
x2 = 100:5:140;
w2 = IX_dataset_2d(x1,x2,rand(10,9),rand(10,9));

wc = func_eval(w2, @gauss2d, [1000,5,120,5,10,50]);
