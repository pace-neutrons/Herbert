function wout=set_simple_xsigerr(win,iax,x,signal,err,xdistr)
% OBSOLETE: Set signal, error and selected axes in a single input object
%
%**************************************************************************
% 2021-12-31:
%
% This method is now obsolete; it was only ever intended for internal use
% and permitted inconsistent class property values if used without care.
%
% Please replace with appropriate calls to the relevant object property set
% methods.
%
%**************************************************************************
%
%   >> wout=set_simple_xsigerr(win,iax,x,signal,err)
%   >> wout=set_simple_xsigerr(win,iax,x,signal,err,xdistr)
%
% Input:
% ------
%   win     Input object
%   iax     Array of axes indicies that are to be replaced by elements of x
%   x       Cell array of coordinate values (numel(x)==numel(iax))
%   signal  Signal array
%   err     Associated error bars
%   xdistr  (Optional) replacement distribution flag (scalar or array with
%           length matching length of iax)
%
% Output:
% -------
%   wout    Output object
%
% Simple substitution - lots of room for errors in use of this method - so
% only for experts


classname = class(win);
error ('HERBERT:set_simple_xsigerr:obsolete', ['This function is now obsolete.',...
    'Type ''doc ', classname, '/set_simple_xsigerr'' for more information'])
