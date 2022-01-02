function x=get_x(w,iax)
% OBSOLETE: Get the x-axis data for an object
%
%**************************************************************************
% 2021-12-31:
%
% This method is now obsolete. Please replace with
%   >> d = axis(obj)        % structure with axis and distribution information
%
%**************************************************************************
%
%   >> x=getx(w)        % cell array of row vectors, one per axis
%   >> x=getx(w,iax)    % iax=1,2,3...; row vector for indicated axis


classname = class(w);
error ('HERBERT:get_xsigerr:obsolete', ['This function is now obsolete.',...
    'Type ''doc ', classname, '/get_x'' for more information'])
