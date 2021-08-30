function method = rebin_point_averaging_parse(option, nax)
% Check point rebinning option: trapezoidal integration or point averaging
%
%   >> method = rebin_point_averaging_parse (option, nax)
%
% Input:
% ------
%   option  Point integration method:
%           - character string, one of 'integrate' or 'average'
%           - cell array of character strings, length=nax
%
%   nax     Number of axes for which to return the option
%
% Output:
% -------
%   method  Cell array size [1,nax] containing averaging method for each
%           axis


valid_options = {'average','interpolate'};

[ok, cout] = str_make_cellstr(option);
if ok
    if numel(cout)==1 || numel(cout)==nax
        ind = cellfun(@(x)(unique_stringmatchi (x, valid_options)), cout);
        if all(ind>0)
            method = valid_options(repmat(ind(:)',[1,nax/numel(ind)]));
        else
            error('HERBERT:rebin_point_averaging_parse:invalid_argument',...
                ['An ambiguous abbreviation or an invalid point ',...
                'averaging option has been given']);
        end
    else
        error('HERBERT:rebin_point_averaging_parse:invalid_argument',...
            ['Must give just one point averaging method, or one for ',...
            'each of the %d rebinning axes'], nax);
    end
else
    error('HERBERT:rebin_point_averaging_parse:invalid_argument',...
        'Point averaging option has incorrect format');
end


%--------------------------------------------------------------------------
function ind = unique_stringmatchi (option, valid_options)
% Returns index of unique stringmatchi (if one), or 0 otherwise
ind = stringmatchi (option, valid_options);
if ~isscalar(ind)
    ind = 0;
end
