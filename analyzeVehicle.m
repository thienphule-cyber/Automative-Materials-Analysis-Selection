function V = analyzeVehicle(T, C, spec, par, crit, vehType, mode, custom)
% Vehicle-level analysis.
%
% vehType : 'ICE' | 'Hybrid' | 'BEV'
% mode    : 'Baseline'  = first candidate material of each component
%           'Optimised' = best-scoring eligible material (Phase 6 scoring)
% custom  : containers.Map (component name -> material name) with manual
%           overrides, may be empty. Overrides must be valid candidates.
%
% Vehicle mass = sum(m_i * qty_i), where m_i is the mass of the equivalent
% member of each component (NOT a full bill of materials).

col = ['n' vehType];
if ~ismember(col, spec.Properties.VariableNames)
    error('Unknown vehicle type: %s', vehType);
end
idx = find(spec.(col) > 0);
n   = numel(idx);

Component = cell(n,1); Category = cell(n,1); Material = cell(n,1);
Class = cell(n,1); Recommended = cell(n,1); Status = cell(n,1);
FailReason = cell(n,1);
Qty = zeros(n,1); MassEach = zeros(n,1); MassTotal = zeros(n,1);
CostTotal = zeros(n,1); Stress = zeros(n,1); Strain = zeros(n,1);
Defl_mm = zeros(n,1); FoS = zeros(n,1); Top = zeros(n,1);
dL_mm = zeros(n,1); SigmaTh = zeros(n,1); FoSThermal = zeros(n,1);
FoSGov = zeros(n,1); Cycles = zeros(n,1); LifeKm = zeros(n,1);
FoSf = zeros(n,1); Score = zeros(n,1);
rankInfo = cell(n,1);

for k = 1:n
    sp = getSpec(spec, idx(k));
    rk = rankComponentMaterials(T, C, sp, par, crit);

    j = [];
    if nargin >= 8 && ~isempty(custom) && isKey(custom, sp.Component)
        j = find(strcmp(rk.cands, custom(sp.Component)), 1);
    end
    if isempty(j)
        if strcmpi(mode, 'Optimised'), j = rk.best; else, j = 1; end
    end
    r = rk.results(j);

    q = sp.(col);
    Component{k}   = sp.Component;   Category{k}    = sp.Category;
    Material{k}    = r.Material;     Class{k}       = r.Class;
    Recommended{k} = rk.cands{rk.best};
    Status{k}      = r.Status;       FailReason{k}  = r.FailReason;
    Qty(k)         = q;              MassEach(k)    = r.Mass_kg;
    MassTotal(k)   = q * r.Mass_kg;  CostTotal(k)   = q * r.Cost_USD;
    Stress(k)      = r.Stress_MPa;   Strain(k)      = r.Strain;
    Defl_mm(k)     = r.Defl_mm;      FoS(k)         = r.FoS;
    Top(k)         = r.Top;          dL_mm(k)       = r.dL_mm;
    SigmaTh(k)     = r.SigmaTh_MPa;  FoSThermal(k)  = r.FoSThermal;
    FoSGov(k)      = r.FoSGov;       Cycles(k)      = r.N;
    LifeKm(k)      = r.LifeKm;       FoSf(k)        = r.FoSf;
    Score(k)       = rk.score(j);
    rankInfo{k}    = rk;
end

V.Tbl = table(Component, Category, Qty, Material, Class, MassEach, MassTotal, ...
    CostTotal, Stress, Strain, Defl_mm, FoS, Top, dL_mm, SigmaTh, FoSThermal, ...
    FoSGov, Cycles, LifeKm, FoSf, Score, Recommended, Status, FailReason);
V.rank = rankInfo;

% --- Vehicle totals --------------------------------------------------------
V.vehType   = vehType;
V.mode      = mode;
V.totalMass = sum(MassTotal);                 % M_vehicle = sum(m_i)
V.totalCost = sum(CostTotal);
V.nFail     = sum(strcmp(Status, 'FAIL'));
V.minFoS    = min(FoSGov);
V.avgScore  = mean(Score);

% --- Distributions ---------------------------------------------------------
[V.catNames, ~, ic] = unique(Category, 'stable');
V.massByCat = accumarray(ic, MassTotal);
V.costByCat = accumarray(ic, CostTotal);

[V.classNames, ~, ic] = unique(Class, 'stable');
V.massByClass = accumarray(ic, MassTotal);

[V.matNames, ~, ic] = unique(Material, 'stable');
V.massByMat = accumarray(ic, MassTotal);
end