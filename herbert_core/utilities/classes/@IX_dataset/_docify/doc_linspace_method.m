% Make a <object> with the same axis ranges but with a uniform grid of values
%
%   >> obj_out = <method> (obj, n)
%
% Input:
% ------
%   obj     <object> object or array of objects
%
%   n       Number of data points in which to divide the <axis_or_axes>
%           <one_dim:>
%               e.g.  >> wout = linspace (win, <nval_scalar>);
%           <one_dim/end:>
%           <multi_dim:>
%           - n is a scalar: each axis divided into the same number of points
%               e.g.  >> wout = linspace (win, <nval_scalar>);
%           - n is a vector with length <ndim>: each axis divided differently
%               e.g.  >> wout = linspace (win, <nval_vector>);
%             Use zero  where you want an axis to remain unchanged
%               e.g.  >> wout = linspace (win, <nval_vector0>);
%           <multi_dim/end:>
%
%           The number of bin boundaries in the output object is n+1 for a 
%           histogram axis, which corresponds to n data points on that axis.
%
%           If the extent of an axis is zero (e.g. the data is point data
%           and there is only one point along that axis), then the
%           axis is not subdivided.
%
% Output:
% -------
%   obj_out Output <object> or array of <object>. 
%           The signal and error arrays are set to zeros.
%
% Useful, for example, when plotting the result of a fit: often one wants
% a dataset with a fine grid over the range of the data to create a fine
% plot of the calculated function:
%
%   >> kk = multifit (wdata);
%   >>      :
%   >> [wfit, fitdata] = kk.fit (wdata, @<func>, p_init);
%   >> wtmp = linspace(wdata, <nval_scalar>);
%   >> wcalc = func_eval (wtmp ,@<func>, fitdata.p);
%   >> plot (wcalc)