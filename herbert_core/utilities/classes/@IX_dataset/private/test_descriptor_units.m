% -------------------------------------------------------------------------
% Arithmetic increasing
[np,xout]=values_equal_steps(10,2,18-1e-4)
xout_ref = [10,12,14,16]

[np,xout]=values_equal_steps(10,2,18-1e-10)
xout_ref = [10,12,14,16]

[np,xout]=values_equal_steps(10,2,18)
xout_ref = [10,12,14,16]

[np,xout]=values_equal_steps(10,2,18+1e-10)
xout_ref = [10,12,14,16]

[np,xout]=values_equal_steps(10,2,18+1e-8)
xout_ref = [10,12,14,16,18]

[np,xout]=values_equal_steps(10,2,10)
xout_ref = []


% Arithmetic decreasing
[np,xout]=values_equal_steps(18,2,10-1e-4)
xout_ref = [18,16,14,12,10]

[np,xout]=values_equal_steps(18,2,10-1e-11)
xout_ref = [18,16,14,12]

[np,xout]=values_equal_steps(18,2,10)
xout_ref = [18,16,14,12]

[np,xout]=values_equal_steps(18,2,10+1e-11)
xout_ref = [18,16,14,12]

[np,xout]=values_equal_steps(18,2,10+1e-4)
xout_ref = [18,16,14,12]



% -------------------------------------------------------------------------
% Contained values increasing

xref = [];
[np, xout] = values_contained_points (3, xref, 6)
xout_ref = 3;

xref = [0,1,2];
[np, xout] = values_contained_points (3, xref, 6)
xout_ref = 3;

xref = [0,10];
[np, xout] = values_contained_points (3, xref, 6)
xout_ref = 3;

xref = [10,11,12];
[np, xout] = values_contained_points (3, xref, 6)
xout_ref = 3;

xref = 1:10;
[np, xout] = values_contained_points (3, xref, 6)
xout_ref = [3,4,5];

[np, xout] = values_contained_points (3, xref, 6.1)
xout_ref = [3,4,5,6];

[np, xout] = values_contained_points (3, xref, 3)
xout_ref = [];


% Contained values dencreasing
xref = [];
[np, xout] = values_contained_points (6, xref, 3)
xout_ref = 6;

xref = [0,1,2];
[np, xout] = values_contained_points (6, xref, 3)
xout_ref = 6;

xref = [0,10];
[np, xout] = values_contained_points (6, xref, 3)
xout_ref = 6;

xref = [10,11,12];
[np, xout] = values_contained_points (6, xref, 3)
xout_ref = 6;

xref = 1:10;
[np, xout] = values_contained_points (6, xref, 3)
xout_ref = [6,5,4];

[np, xout] = values_contained_points (6, xref, 2.9)
xout_ref = [6,5,4,3];


% -------------------------------------------------------------------------
% Logarithmic increasing
[np,xout]=values_logarithmic_steps (10,1,80-1e-6)
xout_ref = [10,20,40]

[np,xout]=values_logarithmic_steps (10,1,80-1e-8)
xout_ref = [10,20,40]


[np,xout]=values_logarithmic_steps (10,1,80+1e-10)
xout_ref = [10,20,40]

[np,xout]=values_logarithmic_steps (10,1,80+1e-8)
xout_ref = [10,20,40,80]

[np,xout]=values_logarithmic_steps (10,1,80-1e-6)
xout_ref = [10,20,40,80]


% Logarithmic decreasing
[np,xout]=values_logarithmic_steps (80,1,10+1e-6)
xout = [80,40,20]

[np,xout]=values_logarithmic_steps (80,1,10)
xout = [80,40,20]

[np,xout]=values_logarithmic_steps (80,1,10-1e-10)
xout = [80,40,20]

[np,xout]=values_logarithmic_steps (80,1,10-1e-6)
xout = [80,40,20,10]




% -------------------------------------------------------------------------
% 
rebin_boundaries_from_mInfToInf (2, [3-1e-6,4:12])  % extra boundary
rebin_boundaries_from_mInfToInf (2, [3-1e-12,4:12])
rebin_boundaries_from_mInfToInf (2, [3,4:12])
rebin_boundaries_from_mInfToInf (2, [3+1e-12,4:12])
rebin_boundaries_from_mInfToInf (2, [3-1e-6,4:12])


rebin_boundaries_from_mInfToInf (2, [3:12,13-1e-6])
rebin_boundaries_from_mInfToInf (2, [3:12,13-1e-12])
rebin_boundaries_from_mInfToInf (2, [3:12,13])
rebin_boundaries_from_mInfToInf (2, [3:12,13+1e-12])
rebin_boundaries_from_mInfToInf (2, [3:12,13+1e-6]) % extra boundary


