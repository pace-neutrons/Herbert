function wout = spe (varargin)
% Create mslice/Tobyfit spe object
% 
%   >> w=spe(file)          % read from file
%   >> w=spe(structure)     % create from structure
%
% spe object has the following fields
%   data.filename   Name of file excluding path
%   data.filepath   Path to file including terminating file separator
%   data.S          [ne x ndet] array of signal values; masked pixels indicated by NaN
%   data.ERR        [ne x ndet] array of error values (st. dev.); masked pixels have value 0
%   data.en         Column vector of energy bin boundaries

% Original author: T.G.Perring

classname='spe';


if nargin==1
    if isstruct(varargin{1})    % structure
        [ok,mess,wout]=checkfields(varargin{1});   % Make checkfields the ultimate arbiter of the validity of a structure
        if ok, wout = class(wout,classname); return, else error(mess); end
    elseif ischar(varargin{1}) && length(size(varargin{1}))==2 && size(varargin{1},1)==1
        if is_file(varargin{1}) % file name
            [wout,ok,mess]=get_spe(varargin{1});
            if ~ok, error(mess); end
            [ok,mess,wout]=checkfields(wout);   % Make checkfields the ultimate arbiter of the validity of a structure
            if ok, wout = class(wout,classname); return, else error(mess); end
        else
            error('File does not exist')
        end
    else
        error('Check arguments')
    end
elseif nargin==0   
% defauld spe structure;
    wout = struct(...
         'filename','',...
         'filepath','',...
         'S',       [],...
         'ERR',     [],...
         'en',      0 ...
    );    
    [ok,mess,wout]=checkfields(wout);   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, wout = class(wout,classname); return, else error(mess); end
else
    error('Check number of arguments')
end
