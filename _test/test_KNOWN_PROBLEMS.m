%% Problems

%1
hh=IX_dataset_2d(h1);
kk=rebin(hh,[5,15],[0.5,0.9]);

kk=rebin(hh,[5,15],[0.5,0.9],'int');

%2 Why different?
da(hp1)
lx 2 14; ly 4 7; lc 0 8
keep_figure
c2=cut(hp1,[2,0,14],[4,0,7]);
da(c2)
lc 0 8
keep_figure


