function out = rankComponentMaterials(T, C, sp, par, crit)
% Evaluate every candidate material of one component and rank them with the
% Phase 6 scoring (scoreMaterials).
%
% Per-component mapping to the Phase 6 criteria (no impact data here):
%   Strength = static FoS, Weight = member mass, Fatigue = log10(cycles),
%   Thermal = combined FoS at Top, Cost = member material cost,
%   Manufacturing = manufacturingScore.
% A material that FAILS static, thermal or fatigue is not eligible.

cands = getCandidateMaterials(C, sp.Component);
n = numel(cands);

results = [];
FoS = zeros(n,1); LogN = zeros(n,1); FoSTh = zeros(n,1);
Mass = zeros(n,1); Cost = zeros(n,1); Manuf = zeros(n,1);
AllPass = false(n,1);

for i = 1:n
    m = getMaterial(T, cands{i});
    r = analyzeComponent(m, sp, par);
    if isempty(results), results = r; else, results(end+1) = r; end %#ok<AGROW>

    FoS(i)     = r.FoS;
    LogN(i)    = log10(min(max(r.N, 1), 1e9));   % Inf -> 1e9
    FoSTh(i)   = r.FoSThermal;
    Mass(i)    = r.Mass_kg;
    Cost(i)    = r.Cost_USD;
    Manuf(i)   = manufacturingScore(m);
    AllPass(i) = strcmp(r.Status, 'PASS');
end

D = table(cands(:), FoS, FoS, LogN, FoSTh, Mass, Cost, Manuf, AllPass, ...
    'VariableNames', {'Material','FoS','EnergyRatio','LogN','FoSThermal', ...
    'EqMass','EqCost','Manuf','AllPass'});

sc = scoreMaterials(D, crit, true);

out.cands      = cands;
out.results    = results;
out.score      = sc.total;
out.order      = sc.order;
out.best       = sc.best;          % index into cands
out.feasible   = sc.feasible;
out.noFeasible = sc.noFeasible;
end