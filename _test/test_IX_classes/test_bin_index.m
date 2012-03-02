% Test of bin_index for some trying input arguments
%
% With each of the xbounds, x combinations, check that indx makes sense for
% both of the values of the input argument 'inclusive'

xbounds=[1,4,5];
x=[0.9,1,1.1,4,5,6];
x=[15,16,17];
x=[2,3,3,4,4,4,5,5];


xbounds=[1,4,4,5];
x=[2,3,3,4,4,4,5,5];


xbounds=[1,4,5];
x=[4.2,4.3,4.7];
x=[2,5,5,5];
x=[2,4,4,4];
x=[4,4,4];
x=[5,5,5];


xbounds=[1,2,3,4,5];
x=[1.3,2,4,6];
x=[1.3,2,4,5];

% Test function calls:
ibin = bin_index (x,xbounds,true)


ibin = bin_index (x,xbounds,false)
