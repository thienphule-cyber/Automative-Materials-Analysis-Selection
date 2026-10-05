%% PHASE 5 - Impact, Energy Absorption & Lightweight Analysis
clear; clc; close all;

load('materialLibrary.mat');    % T (materials), C (components)

%% ---- USER INPUT ---------------------------------------------------------
component = 'Bumper';

sec = struct('type','tube', 'dims',[60 54]);   % outer / inner diameter [mm]

% defineImpactCase(mVeh, vKmh, absorbFrac, stroke, section, L, baseline)
ic = defineImpactCase(1500, 15, 0.15, 150, sec, 1000, 'AHSS DP600');
% 1500 kg vehicle at 15 km/h, the beam must absorb 15% of the kinetic energy,
% 150 mm allowable deformation, 1000 mm span, baseline = AHSS DP600
% -------------------------------------------------------------------------

%% Analyse every candidate material of the selected component
cands = getCandidateMaterials(C, component);
res5  = [];
for i = 1:numel(cands)
    m = getMaterial(T, cands{i});
    r = impactAnalysis(m, ic);
    if isempty(res5), res5 = r; else, res5(end+1) = r; end %#ok<SAGROW>
end

%% Lightweighting indices relative to the baseline material
bIdx = find(strcmp({res5.Material}, ic.baseline), 1);
if isempty(bIdx)
    warning('Baseline "%s" is not a candidate, using %s instead.', ...
        ic.baseline, res5(1).Material);
    bIdx = 1;
end
base = res5(bIdx);
for i = 1:numel(res5)
    res5(i).MassSaving_pct   = (base.Mass_kg   - res5(i).Mass_kg)   / base.Mass_kg   * 100;
    res5(i).EqMassSaving_pct = (base.EqMass_kg - res5(i).EqMass_kg) / base.EqMass_kg * 100;
end

%% Print report
fprintf('\n=== IMPACT & LIGHTWEIGHT ANALYSIS: %s ===\n', component);
fprintf('Vehicle %.0f kg @ %.1f km/h | Ek = %.2f kJ | required absorption = %.2f kJ\n', ...
    ic.mVeh, ic.vKmh, ic.Ek/1e3, ic.Ereq/1e3);
fprintf('Stroke = %.0f mm | span = %.0f mm | baseline = %s\n\n', ...
    ic.stroke, ic.L, base.Material);
fprintf('%-18s %8s %9s %9s %9s %9s %9s %9s %7s %6s\n', ...
    'Material','Mass[kg]','Ecap[kJ]','Fpk[kN]','Def[mm]','SEA','EqMass','EqSave%','Cost$','Status');
for i = 1:numel(res5)
    r = res5(i);
    fprintf('%-18s %8.2f %9.2f %9.1f %9.1f %9.3f %9.2f %9.1f %7.1f %6s', ...
        r.Material, r.Mass_kg, r.Ecap_kJ, r.Fpeak_kN, r.DefReq_mm, ...
        r.SEA_kJkg, r.EqMass_kg, r.EqMassSaving_pct, r.EqCost_USD, r.Status);
    if r.Brittle,     fprintf('  <-- brittle, elastic energy only'); end
    if r.DuctLimited, fprintf('  <-- ductility limits the stroke'); end
    fprintf('\n');
end
fprintf('\n(SEA in kJ/kg. EqMass = mass needed to absorb the required energy at the same SEA.)\n');
fprintf('(Def = deformation needed to absorb the required energy.)\n');

%% Plots
names = categorical({res5.Material});
names = reordercats(names, {res5.Material});
cols  = lines(numel(res5));

figure('Name','Phase 5 - Impact results');

subplot(2,2,1); hold on;
for i = 1:numel(res5)
    plot(res5(i).d_mm, res5(i).F_kN, 'Color', cols(i,:), 'LineWidth', 1.5);
end
xlabel('Deformation [mm]'); ylabel('Force [kN]');
title('Force-deformation (area = absorbed energy)');
legend({res5.Material}, 'Location','best'); grid on;

subplot(2,2,2);
bar(names, [res5.Ecap_kJ]); hold on;
yline(ic.Ereq/1e3, 'r--', 'Required energy', 'LineWidth', 1.5);
ylabel('Energy capacity [kJ]'); title('Absorbed energy'); grid on;

subplot(2,2,3);
bar(names, [res5.SEA_kJkg]);
ylabel('SEA [kJ/kg]'); title('Specific energy absorption'); grid on;

subplot(2,2,4);
bar(names, [[res5.Mass_kg]' [res5.EqMass_kg]']);
ylabel('Mass [kg]'); title('Actual mass vs equivalent mass');
legend('Actual mass','Equivalent mass','Location','best'); grid on;

%% Save results for later phases
save('phase5_results.mat', 'res5', 'ic');
disp('Saved phase5_results.mat');