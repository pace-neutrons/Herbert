% sigvar_getx:
% ------------
% test hit and point axes
%
% sigvar:
% -------
% - test with some signal as NaN


% point
x = 1:10;
w1 = IX_dataset_1d(x,rand(size(x)),rand(size(x)));
xs = sigvar_getx (w1);

% hist
x = 1:10;
w1b = IX_dataset_1d(x,rand(9,1),rand(9,1));
xsb = sigvar_getx (w1b);



% point
x1 = 1:10;
x2 = 100:5:140;
w2 = IX_dataset_2d(x1,x2,rand(10,9),rand(10,9));
xxs = sigvar_getx (w2);

% hist on second axis
x1 = 1:10;
x2 = 100:5:140;
w2b = IX_dataset_2d(x1,x2,rand(10,8),rand(10,8));
xxsb = sigvar_getx (w2b);


