function obj = thing (varargin)

if numel(varargin)>0
    if isnumeric(varargin{1})
        % Map information is given by spectrum data
        keywords = {'repeat','wkno'};
        flags = [false, false];
        default_repeat = 1;
        default_wkno = 1;
        defaults = {default_repeat, default_wkno};
        [par, val] = parse_arguments_simple (keywords, flags, defaults, varargin);
        
        % First checks on spectra information
        if numel(par)<1 || numel(par)>3 || ~all(cellfun(@isnumeric, par))
            error ('IX_map:parse_constructor_input:invalid_argument',...
                'Spectrum mapping data must all be numeric')
        end
        
        % Generic checks on repeats and workspace numbers
        if isempty(val{1})
            repeat = default_repeat;
        elseif isnumeric(val{1})
            repeat = val{1};
        else
            error ('IX_map:parse_constructor_input:invalid_argument',...
                'Repeat data must be numeric or empty')
        end
        if isempty(val{2})
            wkno = default_wkno;
        elseif isnumeric(val{2})
            wkno = val{2};
        else
            error ('IX_map:parse_constructor_input:invalid_argument',...
                'Workspace numbering must be numeric or empty')
        end
        obj = map_from_arrays (par, repeat, wkno);
        
        
    elseif is_string(varargin{1})
        % Read a .map file
        [par, val] = parse_arguments_simple ({'wkno'}, true, {true}, varargin);
        if numel(par)==1
            obj = IX_map.read (par{1});
            if ~val{1}
                obj = default_wkno (obj);   % 'wkno' is false, so strip away workspace numbers
            end
        else
            error ('IX_map:parse_constructor_input:invalid_argument',...
                'Too many input arguments')
        end
        
    else
        error ('IX_map:parse_constructor_input:invalid_argument',...
            'First argument must spectrum number data or a data file name')
    end
end
