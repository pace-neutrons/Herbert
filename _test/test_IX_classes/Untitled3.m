% Test dimensions

w1 = IX_dataset_1d(1:10,ones(1,10));
w2 = IX_dataset_1d(1:15,ones(1,15));
w3 = IX_dataset_1d(1,ones(0,1));
w4 = IX_dataset_1d(1:20,ones(1,20));

[nd,sz] = dimensions([w1,w2;w3,w4]);
assertEqual (nd, 1)
assertEqual (sz, [10,15; 0,20])


% 2D =========================================
w1 = IX_dataset_2d(1:10,1:20,ones(10,20),ones(10,20),...
    'my object','x-axis name','y-axis name','signal');

w2 = IX_dataset_2d(1:15,1:18,ones(14,17),ones(14,17),...
    'my object','x-axis name','y-axis name','signal');

w3 = IX_dataset_2d(1,[10,11],ones(0,1),ones(0,1),...
    'my object','x-axis name','y-axis name','signal');

w4 = IX_dataset_2d(1,[10,11,12],ones(1,2),ones(1,2),...
    'my object','x-axis name','y-axis name','signal');



[nd,sz] = dimensions(w1);
assertEqual (nd, 2)
assertEqual (sz, [10,20])

[nd,sz] = dimensions(w2);
assertEqual (nd, 2)
assertEqual (sz, [14,17])

[nd,sz] = dimensions(w3);
assertEqual (nd, 2)
assertEqual (sz, [0,1])


[nd,sz] = dimensions([w1,w2,w3]);
assertEqual (nd, 2)
assertEqual (sz, [10, 14, 0; 20, 17, 1])

[nd,sz] = dimensions([w1,w2,w3]');
assertEqual (nd, 2)
assertEqual (sz, [10, 14, 0; 20, 17, 1])

warr = reshape([w1,w2,w3], [1,1,1,3]);
[nd,sz] = dimensions(warr);
assertEqual (nd, 2)
assertEqual (sz, [10, 14, 0; 20, 17, 1])


