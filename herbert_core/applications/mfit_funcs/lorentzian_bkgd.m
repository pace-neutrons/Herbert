function [y, name, pnames, pin] = lorentzian_bkgd(x, p, flag)
% Lorentzian on linear background
%
%   >> y = lorentzian_bkgd(x,p)
%   >> [y, name, pnames, pin] = lorentzian_bkgd(x,p,flag)
%
% Input:
% =======
%   x   Vector of x-axis values at which to evaluate function
%   p   Vector of parameters needed by the function:
%           p = [height, centre, gamma, bkgd_const, bkgd_slope]
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
    y=(p(1)*p(3)^2)./((x-p(2)).^2 + p(3)^2) + (p(4)+x*p(5));
else
    % Return parameter names or interactively prompt for parameter values
    y=[];
    name='Lorentzian';
    pnames=char('Height','Centre','Sigma','Constant','Slope');
    if flag==1
        pin=zeros(size(p));
    elseif flag==2
        mf_msg('Click on peak maximum');
        [centre,height]=ginput(1);
        mf_msg('Click on half-height');
        [width,~]=ginput(1);
        gamma=abs(width-centre);
        mf_msg('Click on left background');
        [x1,y1]=ginput(1);
        mf_msg('Click on right background');
        [x2,y2]=ginput(1);
        const=(x2*y1-x1*y2)/(x2-x1);
        slope=(y2-y1)/(x2-x1);
        if isnan(const)||isnan(slope)
            const=0;
            slope=0;
        end
        pin=[height-(const+slope*centre),centre,gamma,const,slope];
    end
end

end

