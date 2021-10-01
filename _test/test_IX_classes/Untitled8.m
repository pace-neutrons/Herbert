bin_opts_default = struct('empty_is_one_bin', false, 'range_is_one_bin', false,...
    'array_is_descriptor', true, 'values_are_boundaries', true);




[xout, isdescr, isbnd, res] = rebin_binning_description_parse(xin, bin_opts)


% Shouldnt be permitted:
bin_opts = bin_opts_default; bin_opts.range_is_one_bin = true;
[xout, isdescr, isbnd, res] = rebin_binning_description_parse([-Inf,-Inf], bin_opts)

% Correctly forbidden:
bin_opts = bin_opts_default; bin_opts.range_is_one_bin = false;
[xout, isdescr, isbnd, res] = rebin_binning_description_parse([-Inf,-Inf], bin_opts)

