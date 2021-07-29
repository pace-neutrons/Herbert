function [y, name, pnames, pin] = expon(x, p, flag)
% Exponential function
%
%   >> y = expon(x,p)
%   >> [y, name, pnames, pin] = expon(x,p,flag)
%
% Input:
% =======
%   x   Vector of x-axis values at which to evaluate function
%   p   Vector of parameters: defines y = p(1)*exp(-x/p(2))
%           p = [height_at_x=0, decay]
%
% Optional:
%   flag    Alternative behaviour to follow other than function evaluation [optional]:
%           flag=1  (identify) returns just the function name and parameters
%           flag=2  (interactive guess) returns starting values for parameters
%
% Output:
% ========
%   y       Vector of calculated y-axis values
%
% if flag=1 or 2:
%   y       =[]
%   name    Name of function (used in mfit and possibly other fitting routines)
%   pnames  Parameter names
%   pin     iflag=1: = [];
%           iflag=2: = values of the parameters returned from interactive prompting

% T.G.Perring

if nargin==2
    % Simply calculate function at input values
    y=p(1)*exp(-x/p(2));
else
    % Return parameter names or interactively prompt for parameter values
        y=[];
        name='Exponential';
        pnames=char('Height','Decay');
        if flag==1
            pin=[];
        elseif flag==2
            mf_msg('Click on one point');
            [x1,~]=ginput(1);
            mf_msg('Click on 2nd point');
            [x2,~]=ginput(1);
            tau = (x2-x1)/log(y1/y2);
            ht  = y1*exp(x1/tau);
            pin=[ht,tau];
        end
end

end
