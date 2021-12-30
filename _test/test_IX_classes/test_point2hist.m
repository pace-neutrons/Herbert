% - test with axes extent zero
% - test with data poiints at the same value
% - test with non-distribution data
% - test with an axis of non-zero length, but zero length on a histogram
%   axis on another dimension


x = 1:10;
w1 = IX_dataset_1d(x,rand(size(x)),rand(size(x)));
w1out = point2hist (w1);




x1 = 1:10;
x2 = 100:5:140;
w2 = IX_dataset_2d(x1,x2,rand(10,9),rand(10,9));
w2out = point2hist (w2);


x1 = 1:10;
x2 = 100:5:140;
w2b = IX_dataset_2d(x1,x2,rand(10,8),rand(10,8));
w2b_out = point2hist (w2b);


