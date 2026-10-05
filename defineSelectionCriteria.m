function crit = defineSelectionCriteria(wStrength, wWeight, wFatigue, wThermal, wCost, wManuf)
% Build the criteria struct with normalised weights (sum = 1).
% Inputs can be any positive numbers (e.g. percentages): they are normalised.
%
% Criteria order: Strength, Weight, Fatigue, Thermal, Cost, Manufacturing

w = [wStrength wWeight wFatigue wThermal wCost wManuf];
if any(w < 0) || sum(w) <= 0
    error('Weights must be non-negative and not all zero.');
end

crit.names = {'Strength','Weight','Fatigue','Thermal','Cost','Manufacturing'};
crit.w     = w / sum(w);
end