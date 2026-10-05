function r = thermalAnalysis(mat, lc, r2, tc)
% Thermo-mechanical analysis of one material (analytical 1D / lumped models).
%
% mat : material struct from getMaterial
% lc  : load case from Phase 2 (provides length and required FoS)
% r2  : Phase 2 result struct for the same material (stress, mass, deflection)
% tc  : thermal case from defineThermalCase
%
% Assumptions: uniform temperature (lumped), linear elastic, constant
% properties, thermal stress = restraint * E * alpha * dT, and thermal and
% mechanical stresses are added (conservative, same sign).

E     = mat.E * 1e3;            % GPa -> MPa
alpha = mat.alpha * 1e-6;       % 1/K
L     = lc.L;                   % mm
m     = r2.Mass_kg;             % kg (member mass from Phase 2)
dT    = tc.Top - tc.Tref;       % K

% --- Thermal expansion and stress ---------------------------------------
dL_free   = alpha * L * dT;                       % free expansion [mm]
sigma_th  = tc.restraint * E * alpha * dT;        % thermal stress [MPa]

% --- Heat required to reach Top (no losses) ------------------------------
Q = m * mat.cp * dT;                              % Q = m*cp*dT [J]
if tc.P > 0
    tHeat = Q / tc.P;                             % [s]
else
    tHeat = NaN;
end

% --- Lumped warm-up model: m*cp*dT/dt = P - h*A*(T - Tamb) --------------
t = linspace(0, tc.tEnd, 200);
if tc.P > 0 && tc.h*tc.Acool > 0
    hA    = tc.h * tc.Acool;
    Tss   = tc.Tamb + tc.P / hA;                  % steady-state temperature
    tau   = m * mat.cp / hA;                      % time constant [s]
    Tt    = Tss + (tc.Tamb - Tss) * exp(-t / tau);
else
    Tss = NaN; tau = NaN;
    Tt  = tc.Tamb * ones(size(t));
end

% --- Combined stress and temperature-derated strength -------------------
kT          = thermalDerating(mat, tc.Top);
Sy_T        = mat.Yield * kT;                     % yield at Top [MPa]
sigma_comb  = r2.Stress_MPa + abs(sigma_th);      % conservative sum [MPa]
FoS_comb    = Sy_T / sigma_comb;

strengthOK = FoS_comb >= lc.FoSReq;
tempWarn   = ~isnan(Tss) && Tss > tc.Top;         % steady state exceeds design T

% --- Pack results ---------------------------------------------------------
r.Material    = mat.Name;
r.dT_K        = dT;
r.dL_free_mm  = dL_free;
r.SigmaTh_MPa = sigma_th;
r.SigmaMech   = r2.Stress_MPa;
r.SigmaComb   = sigma_comb;
r.Derating    = kT;
r.YieldT_MPa  = Sy_T;
r.FoS_comb    = FoS_comb;
r.Q_kJ        = Q / 1e3;
r.tHeat_s     = tHeat;
r.Tss_C       = Tss;
r.Tau_s       = tau;
r.t           = t;
r.Tt          = Tt;
r.TempWarn    = tempWarn;
r.Status      = ternary(strengthOK && r2.DeflOK, 'PASS', 'FAIL');
end

function out = ternary(cond, a, b)
if cond, out = a; else, out = b; end
end