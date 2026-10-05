function mats = getCandidateMaterials(C, componentName)
idx = strcmp(C.Component, componentName);
if ~any(idx)
    error('Cannot find component: %s', componentName);
end
mats = C.Materials{idx};
end