% =========================================================================
%  Test value generation
%
%   >> xout = rebin_boundaries_from_values (xin, is_boundaries, xref)


% Bin centres with one or no finite value
xref = 3;
xout = rebin_boundaries_from_values ([-Inf,Inf], false, xref);
xout_ref = [3,3];
assertEqual(xout, xout_ref)

xref = [3,3,3,3];
xout = rebin_boundaries_from_values ([-Inf,Inf], false, xref);
xout_ref = [3,3];
assertEqual(xout, xout_ref)

xref = [3,3,3,4];
xout = rebin_boundaries_from_values ([-Inf,Inf], false, xref);
xout_ref = [3,4];
assertEqual(xout, xout_ref)

xref = [3,4,5,6];
xout = rebin_boundaries_from_values ([-Inf,5.5], false, xref);
xout_ref = [3,5.5];
assertEqual(xout, xout_ref)


% Bin boundaries
xref = 3;
xout = rebin_boundaries_from_values ([-Inf,Inf], true, xref);
xout_ref = [3,3];
assertEqual(xout, xout_ref)

xref = [3,3,3,3];
xout = rebin_boundaries_from_values ([-Inf,Inf], true, xref);
xout_ref = [3,3];
assertEqual(xout, xout_ref)

xref = [3,3,3,4];
xout = rebin_boundaries_from_values ([-Inf,Inf], true, xref);
xout_ref = [3,4];
assertEqual(xout, xout_ref)

xref = [3,4,5,6];
xout = rebin_boundaries_from_values ([-Inf,5.5], true, xref);
xout_ref = [3,5.5];
assertEqual(xout, xout_ref)


% Bin centres, at least two finite values
xref = 3;
xout = rebin_boundaries_from_values ([-Inf,-4,0,Inf], false, xref);
xout_ref = [3,3];
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



            
            