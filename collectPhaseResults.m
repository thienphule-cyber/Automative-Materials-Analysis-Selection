function D = collectPhaseResults(res2, res3, res4, res5, T)
% Gather raw metrics of Phases 2-5 for the materials present in ALL phases.
%
% Output table D (one row per material):
%   FoS        : static factor of safety (Phase 2)
%   EnergyRatio: absorbed energy capacity / required energy (Phase 5)
%   LogN       : log10 of fatigue life, capped to [1e0, 1e9] (Phase 4)
%   FoSThermal : combined FoS at operating temperature (Phase 3)
%   EqMass     : equivalent mass to absorb the required energy [kg] (Phase 5)
%   EqCost     : cost of the equivalent mass [USD] (Phase 5)
%   Manuf      : manufacturability score (0..100)
%   AllPass    : true if the material PASSES in every phase

common = {res2.Material};
for X = {res3, res4, res5}
    common = common(ismember(common, {X{1}.Material}));
end

if numel(common) < 2
    error(['Fewer than 2 materials are common to Phases 2-5.' newline ...
        'Run Phases 2-5 with the SAME component (e.g. set component = ''Bumper'' ' ...
        'in phase2_main.m), then run Phase 6 again.']);
end

n = numel(common);
Material = common(:);
FoS = zeros(n,1); EnergyRatio = zeros(n,1); LogN = zeros(n,1);
FoSThermal = zeros(n,1); EqMass = zeros(n,1); EqCost = zeros(n,1);
Manuf = zeros(n,1); AllPass = false(n,1);

for i = 1:n
    nm = common{i};
    a = res2(strcmp({res2.Material}, nm));
    b = res3(strcmp({res3.Material}, nm));
    c = res4(strcmp({res4.Material}, nm));
    d = res5(strcmp({res5.Material}, nm));
    m = getMaterial(T, nm);

    FoS(i)         = a.FoS;
    FoSThermal(i)  = b.FoS_comb;
    LogN(i)        = log10(min(max(c.N, 1), 1e9));   % Inf -> 1e9, 0 -> 1
    EnergyRatio(i) = d.EnergyRatio;
    EqMass(i)      = d.EqMass_kg;
    EqCost(i)      = d.EqCost_USD;
    Manuf(i)       = manufacturingScore(m);
    AllPass(i)     = strcmp(a.Status,'PASS') && strcmp(b.Status,'PASS') && ...
        strcmp(c.Status,'PASS') && strcmp(d.Status,'PASS');
end

D = table(Material, FoS, EnergyRatio, LogN, FoSThermal, EqMass, EqCost, Manuf, AllPass);
end