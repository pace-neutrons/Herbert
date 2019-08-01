function wout=linspace(win,n)
% Make a datset with the same x,y and z ranges but with a uniform grid of values
%
%   >> wout = linspace(win,n)
%
%   win     IX_dataset_3d or array of IX_dataset_3d
%   n       Number of points in which to divide the x- and y-axes e.g.
%               >> wout=linspace(win,1000);         % 1000 points along all axes
%               >> wout=linspace(win,[100,200,150]);% Different numbers for the axes
%
%   wout    Output IX_datset_3d or array of IX_datset_3d. The signal and
%           error arrays are set to zeros.
%
% Useful e.g. when plotting the result of a fit: often one wants a dataset
% with a fine grid of x- and y-values over the range of the data to create a fine
% plot of the calculated function
%
%   >> [wfit,fitdata]=multifit(wdata,@gauss3d_bkgd,p_init);
%   >> wtmp = linspace(wdata,200);
%   >> wcalc = func_eval(wtmp,@gauss3d_bkgd,fitdata.p);
%   >> ds(wcalc)

nd=dimensions(win(1));

if nargin==1 || isempty(n)
    wout=win;   % do nothing if not given n
    return
elseif isnumeric(n) && all(rem(n,1)==0) && all(n>0)
    if isscalar(n)
        n=n*ones(1,nd);
    elseif numel(n)~=nd
        error(['Check requested number of subdisivions is a scalar or =',num2str(nd)])
    end
    
else
    error('Check number(s) of sub-divisions is(are) integer(s) bigger than zero')
end

wout=win;
status=ishistogram(win);
for i=1:numel(wout)
    [nd,sz0]=dimensions(win(i));
    sz=n-status(:,i)';
    if numel(win(i).x)>1
        xtmp=linspace(win.x(1),win.x(end),n(1));
    else
        xtmp=win(i).x;
        sz(1)=sz0(1);
    end
    if numel(win(i).y)>1
        ytmp=linspace(win.y(1),win.y(end),n(2));
    else
        ytmp=win(i).y;
        sz(2)=sz0(2);
    end
    if numel(win(i).z)>1
        ztmp=linspace(win.z(1),win.z(end),n(3));
    else
        ztmp=win(i).z;
        sz(3)=sz0(3);
    end
    stmp=zeros(sz);
    etmp=zeros(sz);
    wout(i).x=xtmp; wout(i).y=ytmp; wout(i).z=ztmp; wout(i).signal=stmp; wout(i).error=etmp;
end
