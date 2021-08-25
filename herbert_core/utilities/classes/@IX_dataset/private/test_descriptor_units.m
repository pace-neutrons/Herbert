% -------------------------------------------------------------------------
% Equally spaced, origin is beginning of interval
% -----------------------------------------------
[np, xout]=values_equal_steps(10, 2, 18-1e-4, 'x1');
xout_ref = [10, 12, 14, 16];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_equal_steps(10, 2, 18-1e-10, 'x1');
xout_ref = [10, 12, 14, 16];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_equal_steps(10, 2, 18, 'x1');
xout_ref = [10, 12, 14, 16];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_equal_steps(10, 2, 18+1e-10, 'x1');
xout_ref = [10, 12, 14, 16];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_equal_steps(10, 2, 18+1e-8, 'x1');
xout_ref = [10, 12, 14, 16, 18];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_equal_steps(10, 2, 10, 'x1');
xout_ref = [];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)


% Equally spaced, origin is end of interval
% -----------------------------------------
[np, xout]=values_equal_steps(10-1e-4, 2, 18, 'x2');
xout_ref = [10-1e-4, 10, 12, 14, 16];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_equal_steps(10-1e-11, 2, 18, 'x2');
xout_ref = [10-1e-11, 12, 14, 16];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_equal_steps(10, 2, 18, 'x2');
xout_ref = [10, 12, 14, 16];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_equal_steps(10+1e-11, 2, 18, 'x2');
xout_ref = [10+1e-11, 12, 14, 16];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_equal_steps(10+1e-4, 2, 18, 'x2');
xout_ref = [10+1e-4, 12, 14, 16];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_equal_steps(10, 2, 10, 'x2');
xout_ref = [];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)


% Equally spaced, midpoints centred on zero
% ------------------------------------------
[np, xout]=values_equal_steps (-3-1e-6, 2, 7-1e-6, 'c0');
xout_ref = [-3-1e-6, -3, -1, 1, 3, 5];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_equal_steps (-3-1e-11, 2, 7-1e-6, 'c0');
xout_ref = [-3-1e-11, -1, 1, 3, 5];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_equal_steps (-3, 2, 7-1e-6, 'c0');
xout_ref = [-3, -1, 1, 3, 5];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_equal_steps (-3+1e-11, 2, 7-1e-6, 'c0');
xout_ref = [-3+1e-11, -1, 1, 3, 5];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_equal_steps (-2.9, 2, 7-1e-6, 'c0');
xout_ref = [-2.9, -1, 1, 3, 5];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_equal_steps (-2.9, 2, 7-1e-11, 'c0');
xout_ref = [-2.9, -1, 1, 3, 5];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_equal_steps (-2.9, 2, 7, 'c0');
xout_ref = [-2.9, -1, 1, 3, 5];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_equal_steps (-2.9, 2, 7+1e-11, 'c0');
xout_ref = [-2.9, -1, 1, 3, 5];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_equal_steps (-2.9, 2, 7+1e-6, 'c0');
xout_ref = [-2.9, -1, 1, 3, 5, 7];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)


% Negative interval
% -----------------
[np, xout]=values_equal_steps(10, 2, 4, 'x1');
xout_ref = [];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)


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
% Logarithmic origin x1
% ---------------------
[np, xout]=values_logarithmic_steps (10, 1, 80-1e-6, 'x1');
xout_ref = [10, 20, 40];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_logarithmic_steps (10, 1, 80-1e-8, 'x1');
xout_ref = [10, 20, 40];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_logarithmic_steps (10, 1, 80+1e-10, 'x1');
xout_ref = [10, 20, 40];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_logarithmic_steps (10, 1, 80+1e-8, 'x1');
xout_ref = [10, 20, 40, 80];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_logarithmic_steps (10, 1, 80+1e-6, 'x1');
xout_ref = [10, 20, 40, 80];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)


% Logarithmic origin x2
% ---------------------
[np, xout]=values_logarithmic_steps (10+1e-6, 1, 80, 'x2');
xout_ref = [10+1e-6, 20, 40];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_logarithmic_steps (10, 1, 80, 'x2');
xout_ref = [10, 20, 40];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_logarithmic_steps (10-1e-10, 1, 80, 'x2');
xout_ref = [10-1e-10, 20, 40];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_logarithmic_steps (10-1e-6, 1, 80, 'x2');
xout_ref = [10-1e-6, 10, 20, 40];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)


% Logarithmic centred on unity
% ----------------------------
[np, xout]=values_logarithmic_steps ((1/3)+1e-6, 1, 16/3, 'c0');
xout_ref = [(1/3)+1e-6, 2/3, 4/3, 8/3];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_logarithmic_steps ((1/3)-1e-11, 1, 16/3, 'c0');
xout_ref = [(1/3)-1e-11, 2/3, 4/3, 8/3];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_logarithmic_steps ((1/3)-1e-6, 1, 16/3, 'c0');
xout_ref = [(1/3)-1e-6, 1/3, 2/3, 4/3, 8/3];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_logarithmic_steps ((1/3)-1e-6, 1, (16/3)+1e-11, 'c0');
xout_ref = [(1/3)-1e-6, 1/3, 2/3, 4/3, 8/3];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)

[np, xout]=values_logarithmic_steps ((1/3)-1e-6, 1, (16/3)+1e-6, 'c0');
xout_ref = [(1/3)-1e-6, 1/3, 2/3, 4/3, 8/3, 16/3];
assertEqual(np, numel(xout))
assertEqual(xout, xout_ref)


% -------------------------------------------------------------------------
% 
rebin_boundaries_from_mInfToInf (2, [3-1e-6, 4:12])  % extra boundary
[]
rebin_boundaries_from_mInfToInf (2, [3-1e-12, 4:12])
rebin_boundaries_from_mInfToInf (2, [3, 4:12])
rebin_boundaries_from_mInfToInf (2, [3+1e-12, 4:12])
rebin_boundaries_from_mInfToInf (2, [3-1e-6, 4:12])


xout = rebin_boundaries_from_mInfToInf (2, [3:12, 13-1e-6]);
xout_ref = [3:2:11, 13-1e-6];
assertEqual(xout, xout_ref)

xout = rebin_boundaries_from_mInfToInf (2, [3:12,13-1e-12]);
xout_ref = [3:2:11, 13-1e-12];
assertEqual(xout, xout_ref)

xout = rebin_boundaries_from_mInfToInf (2, [3:12,13]);
xout_ref = [3:2:11, 13];
assertEqual(xout, xout_ref)

xout = rebin_boundaries_from_mInfToInf (2, [3:12,13+1e-12]);
xout_ref = [3:2:11, 13+1e-12];
assertEqual(xout, xout_ref)

xout = rebin_boundaries_from_mInfToInf (2, [3:12,13+1e-6]); % extra boundary
xout_ref = [3:2:13, 13+1e-6];
assertEqual(xout, xout_ref)


