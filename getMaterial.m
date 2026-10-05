function m = getMaterial(T, name)
idx = strcmp(T.Name, name);
if ~any(idx)
    error('Cannot find: %s', name);
end
m = table2struct(T(idx,:));
end