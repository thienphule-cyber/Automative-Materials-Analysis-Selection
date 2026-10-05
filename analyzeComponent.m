function r = analyzeComponent(mat, sp, par)
% Run the Phase 2 (static), Phase 3 (thermal) and Phase 4 (fatigue) models
% for ONE component made of ONE material.
%
% mat : material struct from getMaterial
% sp  : component spec struct from getSpec
% par : global parameters from defineVehicleDB
%
% Thermal model: uniform temperature Top, no warm-up model (P = 0).

sec = struct('type', sp.SecType, 'dims', [sp.Dim1 sp.Dim2]);
lc  = defineLoadCase(sp.LoadType, sp.F, sp.L, sec, sp.FoSReq, sp.DeflRatio);
tc  = defineThermalCase(par.Tref, sp.Top, par.Tamb, sp.Restraint, 0, 10, 0.01, 1);
fc  = defineFatigueCase(sp.R, sp.Kf, par.ks, par.kz, par.kr, ...
    sp.CyclesPerKm, par.designKm, true);

r2 = staticAnalysis(mat, lc);
r3 = thermalAnalysis(mat, lc, r2, tc);
r4 = fatigueAnalysis(mat, r2, r3, fc, sp.Top);

ok = [strcmp(r2.Status,'PASS'), strcmp(r3.Status,'PASS'), strcmp(r4.Status,'PASS')];
phaseNames = {'static','thermal','fatigue'};

r.Material    = mat.Name;
r.Class       = mat.Class;
r.Mass_kg     = r2.Mass_kg;
r.Cost_USD    = r2.Mass_kg * mat.Cost;
r.Stress_MPa  = r2.Stress_MPa;
r.Strain      = r2.Strain;
r.Defl_mm     = r2.Defl_mm;          % NaN for torsion
r.FoS         = r2.FoS;
r.Top         = sp.Top;
r.dL_mm       = r3.dL_free_mm;
r.SigmaTh_MPa = r3.SigmaTh_MPa;
r.FoSThermal  = r3.FoS_comb;
r.FoSGov      = min(r2.FoS, r3.FoS_comb);   % governing factor of safety
r.N           = r4.N;
r.LifeKm      = r4.LifeKm;
r.FoSf        = r4.FoS_f;
r.OK          = ok;
if all(ok)
    r.Status     = 'PASS';
    r.FailReason = '';
else
    r.Status     = 'FAIL';
    r.FailReason = strjoin(phaseNames(~ok), '+');
end
end