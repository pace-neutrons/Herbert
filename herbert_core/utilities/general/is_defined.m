function ok = is_defined(name)
% Alias for exist(name, 'var') == 1
% For agreement with other PACE "is_" functions

    ok = exist(name, 'var') == 1;

end
