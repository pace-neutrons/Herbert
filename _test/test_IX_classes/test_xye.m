% - test with hist, point data
% - test with masked data



x = 1:10;
w1 = IX_dataset_1d(x,rand(size(x)),rand(size(x)));
S1 = xye(w1);




x1 = 1:10;
x2 = 100:5:140;
w2 = IX_dataset_2d(x1,x2,rand(10,9),rand(10,9));
S2 = xye(w2);


x1 = 1:10;
x2 = 100:5:140;
w2b = IX_dataset_2d(x1,x2,rand(10,8),rand(10,8));
S2b = xye(w2b);

w2arr = [w2,w2b];
S2arr = xye(w2arr);
isequal(S2arr,[S2,S2b])
