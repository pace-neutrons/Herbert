function xyz_axis_ = check_and_set_x_axis_ (val, iax)
% Set axis information for all axes
%
%   >> xyz_axis_ = check_and_set_x_axis_ (val)
%
% Input:
% ------
%   val     Array of IX_axis objects or cell array of caption information,
%           one element per axis. Caption information is one of
%           - cellstr
%           - character string or 2D character array
%           - string array
%
%           If val is empty for an axis, then the corresponding axis
%           caption will be set to the default
%
%   iax     Axis index. Assumed to be unique integers greater or equal to
%           one. One axis index per expected value. The number of expected
%           values is numel(iax).
%
% Output:
% -------
%   xyz_    Verified, and if necessary reformatted, axis information
%           Output is a row array of IX_axis objects


niax = numel(iax);

if ~isempty(val)
    % Fill axis or axes with provided values
    % *** Problem? : is a cell array of character strings a single caption
    %                with multiple lines, or multiple captions, one
    %                character string per axis?
    if iscell(val) && numel(val)==niax
        xyz_axis_ = repmat(IX_axis(), 1, numel(val));
        for i=1:niax
            xyz_axis_(i) = check_and_set_x_axis_single_ (val{i}, iax(i));
        end
        
    elseif isa(val,'IX_axis') && numel(val)==niax
        xyz_axis_ = val(:)';    % make a row vector
        
    elseif niax==1
        xyz_axis_ = check_and_set_x_axis_single_ (val, iax);
        
    else
        error('HERBERT:check_and_set_x_axis_single_:invalid_argument',...
            ['Axis caption values must be a vector length %s of IX_axis ',...
            'objects, a cell\narray of IX_axis objects, or a cell array\n',...
            'of cell arrays of character strings'],...
            num2str(niax));

    end
else
    % Fill axis or axes with the default
    xyz_axis_def = check_and_set_x_axis_single_ ([], 1);
    xyz_axis_ = repmat(xyz_axis_def, 1, 0);
end


%--------------------------------------------------------------------------
function x_axis_ = check_and_set_x_axis_single_ (val, iax)
% Set axis information for one axis, converting to column cellstr if needed
%
%   >> x_axis_ = check_and_set_x_axis_single_ (val, iax)
%
% Input:
% ------
%   val     IX_axis object, or axis caption which is one of
%           - cellstr
%           - character string or 2D character array
%           - string array
%           If val is empty, then the axis caption will be set to the
%           default
%
%   iax     Axis index, assumed to be a scalar in range 1,2,... ndim()
%
% Output:
% -------
%   x_axis_ Verified, and  if necessary reformated, axis information


if ~isempty(val)
    if isa(val,'IX_axis') && numel(val)==1
        x_axis_ = val;
    else
        [ok, cout] = str_make_cellstr(val);
        if ok
            x_axis_ = IX_axis(cout);
        else
            error('HERBERT:check_and_set_x_axis_:invalid_argument',...
                ['Axis ', num2str(iax), ': axis caption must be a ',...
                'IX_axis object (type help IX_axis),\n',...
                'or character string, string array or cell array of strings']);
        end
    end
    
else
    x_axis_ = IX_axis();
end
