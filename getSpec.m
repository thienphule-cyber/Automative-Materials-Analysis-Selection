function sp = getSpec(spec, i)
% Return row i of the component spec table as a plain struct.
sp    = struct();
names = spec.Properties.VariableNames;
for k = 1:numel(names)
    col = spec.(names{k});
    if iscell(col)
        sp.(names{k}) = col{i};
    else
        sp.(names{k}) = col(i,:);
    end
end
end