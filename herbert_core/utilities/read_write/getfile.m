function file_out = getfile (filterspec, dialogtitle)
% Utility to get file name for input
%
%   >> file_out = getfile (filterspec, dialogtitle)
%
% It is identical to the Matlab built-in function uigetfile, except that
% - Returns filename including path; ='' if no file selected
%
% - If a dialog box is opened, the default operation of uigetfile is altered:
%   (1) The default directory is that of the file most recently selected
%       by getfile (if filespec is a simple string)
%   (2) The default extension is *.* rather than Matlab files
%   (3) It does not fail if dialogtitle is not a string
%
%
% Input:
% ------
%   filterspec      File filter to apply in dialog box
%                   - Default folder is the most recent folder selected with
%                    getfile
%                   - Default file filter *.*
%
%   dialogtitle     Title of 'Select File' box changed to dialogtitle
%
% Output:
% -------
%   file_out        Full file name (path and name)
%                   If no file selected, then empty
%
% EXAMPLES
%   >> file = getfile
%   >> file = getfile ('c:\temp')
%   >> file = getfile ('*.spe')
%   >> file = getfile ('d:\data\*.spe')
%   >> file = getfile ('c:\mprogs\add_spe.m')
%
% See also putfile


persistent path_save

% Initialise the default path on first use
if (isempty(path_save))
    path_save ='';
end

% Get file
if (nargin==0)
    [file,path] = uigetfile (fullfile(path_save,'*.*'));
    
elseif (nargin>0)
    if (ischar(filterspec) && isvector(filterspec))
        if (is_folder(filterspec))
            filterspec_in = fullfile(filterspec,'*.*');
        elseif startsWith(filterspec, '*.')
            filterspec_in = fullfile(path_save,filterspec);
        else
            [pathstr,~,~] = fileparts(filterspec);
            if (isempty(pathstr))
                filterspec_in = fullfile(path_save,filterspec);
            else
                filterspec_in = filterspec;
            end
        end
    elseif (iscellstr(filterspec) && (size(filterspec,2)==1 || size(filterspec,2)==2))
        filterspec_in = filterspec;
    else
        error ('FILTERSPEC argument must be a string or an M by 1 or M by 2 cell array.')
    end

    if (nargin==1)
        [file,path] = uigetfile(filterspec_in);
    elseif (nargin==2)
        if (isa(dialogtitle,'char'))
            [file,path] = uigetfile(filterspec_in, dialogtitle);
        else
            [file,path] = uigetfile(filterspec_in);
        end
    end
end

% Store path for future calls to getfile if user did not select cancel
if (isequal(file,0) || isequal(path,0))
    file_out = '';
else
    file_out = fullfile(path,file);
    path_save = path;
end

end
