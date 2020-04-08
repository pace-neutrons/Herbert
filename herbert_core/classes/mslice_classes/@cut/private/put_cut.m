function [ok,mess,filename,filepath]=put_cut(data,file)
% Writes ASCII .cut file
%   >> [ok,mess,filename,filepath]=put_cut(data,file)
%
% The format of the file is described in get_cut. Must make sure get_cut and put_cut are consistent.
%
% Output:
% -------
%   ok              True if all OK, false otherwise
%   mess            Error message; empty if ok=true
%   filename        Name of file excluding path; empty if problem
%   filepath        Path to file including terminating file separator; empty if problem
%

% T.G.Perring   15 August 2009

ok=true;
mess='';

% Remove blanks from beginning and end of filename
file_tmp=strtrim(file);

% Get file name and path (incl. final separator)
[path,name,ext]=fileparts(file_tmp);
filename=[name,ext];
filepath=[path,filesep];

% Make labels to go as footer in the file
if strcmp(cut_type(data),'sx_mfit')
    titles=struct('x_label',data.x_label,'y_label',data.y_label,'title',{data.title});
    labels=[put_struct_to_labels(titles), put_struct_to_labels(data.appendix)];
else    % bare cut object
    labels='';
end

% Write to file
use_mex=get(herbert_config,'use_mex');
if use_mex
    try
        footer=char(labels)';
        line_len=size(footer,1);    % maximum string length
        footer=footer(:)';          % make a single string
        ierr = put_cut_mex (file_tmp,data.x',data.y',data.e',data.npixels',data.pixels',footer,line_len);
        if round(ierr)~=0
            error(['Error writing cut data to ',file_tmp])
        end
    catch
        force_mex=get(herbert_config,'force_mex_if_use_mex');
        if ~force_mex
            display(['Error calling mex function ',mfilename,'_mex. Calling matlab equivalent'])
            use_mex=false;
        else
            ok=false;
            mess=['Error writing cut data to ',file_tmp]';
            filename='';
            filepath='';
        end
    end
end
if ~use_mex
    try     % matlab write
		if get(herbert_config,'log_level')>-1
			disp(['Matlab writing of .cut file : ' file_tmp]);
		end
        [ok,mess]=put_cut_matlab(data,labels,file_tmp);
        if ~ok
            error(mess)
        end
    catch
        ok=false;
        mess=['Error writing cut data to ',file_tmp]';
        filename='';
        filepath='';
    end
end