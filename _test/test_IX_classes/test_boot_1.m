%==========================================================================
% 1D dataset
% ----------
w1_3_p = IX_dataset_1d ([11,12,15],  [5,-4,-6], [9,9,9]);   % length 3

w1_1_h = IX_dataset_1d ([11,12],  5, 9);   % length 1

w1_1_h = IX_dataset_1d (11, zeros(0,1));   % histogram, with zero


% Error cases
% -----------
w1_1_h = IX_dataset_1d ([11,12],  [5,-4], 9);   % signal & error inconsistent

w1_1_h = IX_dataset_1d (11,  [], []);           % signal must be size [0,1]

%w1b = IX_dataset_1d ([21,5,9; 23,7,4; 26,-2,16]')




%==========================================================================
% 2D dataset
% ----------
w2_2_3_ph = IX_dataset_2d ([11,12], [15,16,17,18], rand(2,3));
[nd, sz] = dimensions(w2_2_3_ph);
status = ishistogram(w2_2_3_ph);
[ax, hist] = axis(w2_2_3_ph)
[ax, hist] = axis(w2_2_3_ph, 2)

w2_2_1_pp = IX_dataset_2d ([11,12], 13, rand(2,1));
[nd, sz] = dimensions(w2_2_1_pp);

w2_2_1_hh = IX_dataset_2d ([11,12], 13, ones(1,0));
[nd, sz] = dimensions(w2_2_1_hh);


w2_arr = [w2_2_3_ph, w2_2_1_pp, w2_2_1_hh]  % Must check that matches individual
%[nd, sz] = dimensions(w2_arr)
status = ishistogram(w2_arr)
status = ishistogram(w2_arr, 2)
[ax, hist] = axis(w2_arr)
[ax, hist] = axis(w2_arr, 2)



%==========================================================================
% 3D dataset
% ----------
w3 = IX_dataset_3d ([11,12], [15,16,17,18], [35,38], rand(2,3));





