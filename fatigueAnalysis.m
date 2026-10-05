function r = fatigueAnalysis(mat, r2, r3, fc, Top)
% Fatigue life estimate of one material (stress-life, analytical model).
%
% mat : material struct from getMaterial
% r2  : Phase 2 result struct (peak stress sigma_max)
% r3  : Phase 3 result struct for the same material ([] if not used)
% fc  : fatigue case from defineFatigueCase
% Top : operating temperature [degC] (used for strength derating)
%
% Model:
%   - S-N curve (Basquin) through two points:
%       (1e3 cycles, 0.9*UTS) and (Nk cycles, Se)
%       Nk = 1e6 for ferrous metals (endurance limit, infinite life below Se)
%       Nk = 1e7 for non-ferrous metals, polymers, composites (no true limit)
%   - Se = material fatigue strength * ks * kz * kr * temperature derating
%   - Mean stress correction: modified Goodman
%       sigma_ar = Kf*sigma_a / (1 - sigma_m/UTS)
%   - Life: N = (sigma_ar / a)^(1/b)
%
% Assumptions: uniform cyclic load of constant amplitude, no damage
% accumulation (no Miner's rule), no corrosion, compressive mean stress
% is ignored (treated as zero) which is conservative.

UTS = mat.UTS;
Sy  = mat.Yield;
Se0 = mat.Fatigue;

% --- Thermal effects (from Phase 3) ---------------------------------------
kT    = 1;
sigTh = 0;
if fc.includeThermal && ~isempty(r3)
    kT    = thermalDerating(mat, Top);
    sigTh = abs(r3.SigmaTh_MPa);        % thermal stress acts as mean stress
end
UTS_T = UTS * kT;
Sy_T  = Sy  * kT;

% --- Corrected endurance / fatigue strength -------------------------------
Se = Se0 * kT * fc.ks * fc.kz * fc.kr;

isFerrous = strcmp(mat.Class, 'Metal') && ~contains(mat.Name, 'Aluminium');
if isFerrous, Nk = 1e6; else, Nk = 1e7; end

% --- Basquin parameters: sigma = a * N^b ----------------------------------
Sf1k = 0.9 * UTS_T;                     % strength at 1e3 cycles
Se   = min(Se, 0.95 * Sf1k);            % keep the curve decreasing
b    = log10(Se / Sf1k) / log10(Nk / 1e3);
a    = Sf1k / (1e3)^b;

% --- Stress cycle ----------------------------------------------------------
smax = r2.Stress_MPa;                   % peak stress from Phase 2
smin = fc.R * smax;
sa   = (smax - smin) / 2;               % stress amplitude [MPa]
sm   = (smax + smin) / 2 + sigTh;       % mean stress incl. thermal [MPa]
sa_e = fc.Kf * sa;                      % amplitude with stress concentration
smG  = max(sm, 0);                      % ignore compressive mean stress

% --- Goodman equivalent fully reversed amplitude and fatigue FoS -----------
if smG >= UTS_T
    sar = Inf;  N = 0;  FoSf = 0;
else
    sar  = sa_e / (1 - smG/UTS_T);
    FoSf = 1 / (sa_e/Se + smG/UTS_T);   % Goodman safety factor
    if isFerrous && sar <= Se
        N = Inf;                        % below endurance limit
    else
        N = (sar / a)^(1/b);            % Basquin
    end
end

lowCycle = N < 1e3;                     % outside S-N validity range

% Langer yield check on the first cycle (nominal peak stress incl. thermal)
yieldOK = (sa + sm) <= Sy_T;

% --- Service life ----------------------------------------------------------
lifeKm  = N / fc.cyclesPerKm;
lifeOK  = N >= fc.Nreq;

% --- S-N curve for plotting -------------------------------------------------
Nvec = logspace(3, 8, 200);
Svec = a * Nvec.^b;
if isFerrous, Svec(Nvec > Nk) = Se; end

% --- Pack results -------------------------------------------------------------
r.Material   = mat.Name;
r.Sa_MPa     = sa;
r.Sm_MPa     = sm;
r.Sar_MPa    = sar;
r.Se_MPa     = Se;
r.Derating   = kT;
r.N          = N;
r.LifeKm     = lifeKm;
r.Nreq       = fc.Nreq;
r.FoS_f      = FoSf;
r.IsFerrous  = isFerrous;
r.LowCycle   = lowCycle;
r.YieldOK    = yieldOK;
r.Nvec       = Nvec;
r.Svec       = Svec;
r.Status     = ternary(lifeOK && yieldOK, 'PASS', 'FAIL');
end

function out = ternary(cond, a, b)
if cond, out = a; else, out = b; end
end