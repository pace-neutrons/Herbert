function path=herbert_on(non_default_path)
% The function intended to swich herbert on and
% return the path were herbert is resided or 
% empty string if herbert has not been found
%
%
% The function has to be present in Matlab search path 
% and modified for each machine to know default herbert location
%
%Usage:
%>>path=herbert_on(); 
%       enables herbert and initiates herbert default search path
%>>path=herbert_on('where'); 
%       reports current location of herbert or empty if not found
%
%>>path=herbert_on('a path'); 
%       initiates herbert on non-default search path
%
%
%
%
her_default_path='c:/Users/wkc26243/Documents/work/svn/Herbert';
%
if exist('non_default_path','var') && strcmpi(non_default_path,'where')
    path = find_default_path(her_default_path);   
    return;
end
if nargin==1 
    start_app(non_default_path);    
else
    start_app(her_default_path);    
end
path = fileparts(which('herbert_init.m'));


function start_app(path)

try
    herbert_off;
catch
end
addpath(path);
herbert_init;

function path =find_default_path(her_default_path)
path = which('herbert_init.m');
if isempty(path)
    path = her_default_path;
    if ~exist(fullfile(path,'herbert_init.m'),'file')
        path='';
    end
else
    path=fileparts(path);
end
