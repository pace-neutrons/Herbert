function ok = isindex(vec)
    ok = isvector(vec) && (islogical(vec) || (all(vec > 0 & all(floor(vec) == vec))));
end
